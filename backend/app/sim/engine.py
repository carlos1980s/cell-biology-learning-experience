from __future__ import annotations

import logging
from datetime import datetime, timezone

from app.agents.organelle_cards import get_organelle_card
from app.agents.runtime import AgentRuntime
from app.config import Settings
from app.observability.metrics import InMemoryMetrics
from app.schemas.api import InspectOrganelleResponse
from app.schemas.cell_state import CellState
from app.schemas.events import OrganelleVisualUpdate, StateDelta
from app.sim.biological_rules import validate_action
from app.sim.cell_cycle import tick_cycle, update_mode_and_health
from app.sim.reducer import apply_action
from app.sim.resources import resource_snapshot
from app.storage.memory_store import MemoryStore

logger = logging.getLogger(__name__)


class SimulationEngine:
    def __init__(
        self,
        settings: Settings,
        store: MemoryStore,
        runtime: AgentRuntime,
        metrics: InMemoryMetrics,
    ) -> None:
        self.settings = settings
        self.store = store
        self.runtime = runtime
        self.metrics = metrics

    def build_delta(
        self,
        cell: CellState,
        from_version: int,
        events_limit: int,
    ) -> StateDelta:
        events = self.store.list_events(cell.cell_id, after_seq=0, limit=events_limit)[-events_limit:]
        updates = [
            OrganelleVisualUpdate(
                organelle_id=organelle.organelle_id,
                type=organelle.type,
                display_name=organelle.display_name,
                health=organelle.health,
                activity=organelle.activity,
                stress=organelle.stress,
                current_task=organelle.current_task,
                task_progress=organelle.task_progress,
                visual_cue=organelle.visual_state.cue,
                speech=organelle.visual_state.speech,
                alerts=organelle.visual_state.alerts,
            )
            for organelle in cell.organelles.values()
        ]
        alerts = list(dict.fromkeys(cell.queues.alerts + cell.cycle.checkpoint_failures))
        return StateDelta(
            cell_id=cell.cell_id,
            from_version=from_version,
            to_version=cell.version,
            tick=cell.tick,
            organelle_updates=updates,
            resource_updates=resource_snapshot(cell.resources),
            cell_mode=cell.mode,
            cycle_phase=cell.cycle.phase,
            alerts=alerts,
            events=events,
        )

    def apply_environment_effects(self, cell: CellState, dt: float) -> None:
        basal_atp = 0.3 * dt
        cell.resources.atp = max(0.0, cell.resources.atp - basal_atp)
        cell.resources.adp += basal_atp
        cell.resources.ros += cell.environment.toxins * 0.03 * dt
        cell.resources.waste += max(0.0, cell.environment.membrane_damage) * 0.04 * dt
        cell.cycle.dna_damage = min(1.0, cell.cycle.dna_damage + cell.environment.toxins * 0.01 * dt)

        for organelle in cell.organelles.values():
            organelle.activity *= 0.7
            organelle.task_progress *= 0.6
            organelle.stress = min(
                1.0,
                max(
                    0.0,
                    organelle.stress * 0.85
                    + (0.04 if cell.resources.ros > 2.0 else 0.0)
                    + (0.03 if cell.resources.atp < 4 else 0.0),
                ),
            )

    async def step(
        self,
        cell_id: str,
        dt: float,
        last_seen_version: int = 0,
        max_events: int = 50,
    ) -> StateDelta:
        cell = self.store.get_cell(cell_id)
        if not cell:
            raise KeyError(f"Unknown cell: {cell_id}")

        from_version = cell.version if last_seen_version == 0 else last_seen_version
        cell.tick += 1
        cell.sim_time_seconds += dt

        self.apply_environment_effects(cell, dt)
        tick_cycle(cell, dt)

        proposed_actions = await self.runtime.collect_actions(cell)
        new_events = []
        for action in proposed_actions:
            validation = validate_action(cell, action)
            if not validation.accepted or not validation.adjusted_action:
                self.metrics.incr("action_validation_rejections")
                logger.info(
                    "Rejected action %s for %s: %s",
                    action.action_type,
                    action.organelle_id,
                    validation.reasons,
                )
                continue
            if validation.reasons:
                self.metrics.incr("action_validation_adjustments")
            cell, events = apply_action(cell, validation.adjusted_action)
            new_events.extend(events)

        appended_events = self.store.append_events(cell.cell_id, new_events)
        cell.recent_events = appended_events[-10:]
        update_mode_and_health(cell)

        cell.version += 1
        self.store.save_cell(cell)
        self.metrics.incr("ticks_total")

        return self.build_delta(cell, from_version=from_version, events_limit=max_events)

    def inspect_organelle(self, cell: CellState, organelle_id: str) -> InspectOrganelleResponse:
        organelle = cell.organelles[organelle_id]
        card = get_organelle_card(organelle.type)
        inputs_needed = [
            item
            for item in card.consumes
            if any(item.lower().replace(" ", "_") in key for key in ("atp", "oxygen", "glucose", "amino", "nucleotide", "lipid"))
        ]
        explanation = organelle.visual_state.speech or (
            f"The {organelle.display_name} is focused on {organelle.current_task.lower()} "
            f"while helping with {card.role.lower()}."
        )
        return InspectOrganelleResponse(
            organelle_id=organelle.organelle_id,
            display_name=organelle.display_name,
            status=organelle.current_task,
            health=organelle.health,
            stress=organelle.stress,
            inputs_needed=inputs_needed or card.consumes,
            outputs=card.produces,
            explanation=explanation,
        )

    def now(self) -> datetime:
        return datetime.now(timezone.utc)

