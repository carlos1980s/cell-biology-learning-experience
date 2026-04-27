from __future__ import annotations

import asyncio
import logging

from app.agents.base import AgentObservation, OrganelleAgent
from app.agents.organelle_cards import get_organelle_card
from app.agents.provider_base import AgentProvider
from app.schemas.actions import AgentAction
from app.schemas.cell_state import CellState
from app.schemas.organelles import OrganelleState
from app.sim.resources import queue_snapshot, resource_snapshot

logger = logging.getLogger(__name__)


class RuleBasedOrganelleAgent(OrganelleAgent):
    def __init__(self, organelle_type: str) -> None:
        self.organelle_type = organelle_type

    def build_observation(self, cell: CellState, self_state: OrganelleState) -> AgentObservation:
        return AgentObservation(
            cell_id=cell.cell_id,
            tick=cell.tick,
            mode=cell.mode,
            cycle_phase=cell.cycle.phase,
            resources=resource_snapshot(cell.resources),
            queues=queue_snapshot(cell.queues),
            environment=cell.environment.model_dump(),
            organelle_id=self_state.organelle_id,
            organelle_type=self_state.type,
            organelle_health=self_state.health,
            organelle_stress=self_state.stress,
            current_task=self_state.current_task,
            inbox_messages=[signal.message for signal in self_state.inbox],
            recent_actions=self_state.memory.recent_actions,
        )

    async def decide(self, observation: AgentObservation) -> list[AgentAction]:
        t = observation.organelle_type
        if t == "nucleus":
            return self._nucleus_actions(observation)
        if t == "ribosome":
            return self._ribosome_actions(observation)
        if t == "rough_er":
            return self._rough_er_actions(observation)
        if t == "smooth_er":
            return self._smooth_er_actions(observation)
        if t == "golgi":
            return self._golgi_actions(observation)
        if t == "mitochondrion":
            return self._mitochondrion_actions(observation)
        if t == "plasma_membrane":
            return self._membrane_actions(observation)
        if t == "cytoskeleton":
            return self._cytoskeleton_actions(observation)
        if t == "lysosome":
            return self._lysosome_actions(observation)
        if t == "peroxisome":
            return self._peroxisome_actions(observation)
        if t == "centrosome":
            return self._centrosome_actions(observation)
        return []

    def _nucleus_actions(self, obs: AgentObservation) -> list[AgentAction]:
        if obs.mode == "dna_repair" or obs.current_task == "Repair":
            return [
                AgentAction(
                    action_id=f"{obs.organelle_id}-repair-{obs.tick}",
                    organelle_id=obs.organelle_id,
                    action_type="repair_dna",
                    priority=9,
                    magnitude=0.7,
                    duration_ticks=1,
                    consumes={"atp": 0.5, "nucleotides": 0.2},
                    explanation="Repair pathways are active because DNA damage is elevated.",
                    confidence=0.9,
                )
            ]
        if obs.cycle_phase == "S":
            return [
                AgentAction(
                    action_id=f"{obs.organelle_id}-replicate-{obs.tick}",
                    organelle_id=obs.organelle_id,
                    action_type="replicate_dna",
                    priority=8,
                    magnitude=0.7,
                    duration_ticks=1,
                    consumes={"atp": 0.8, "nucleotides": 1.0},
                    explanation="DNA replication is progressing through S phase.",
                    confidence=0.85,
                )
            ]
        if obs.resources["mrna"] < 6.0:
            return [
                AgentAction(
                    action_id=f"{obs.organelle_id}-transcribe-{obs.tick}",
                    organelle_id=obs.organelle_id,
                    action_type="transcribe_gene",
                    priority=7,
                    magnitude=0.6,
                    duration_ticks=1,
                    consumes={"atp": 0.5, "nucleotides": 0.4},
                    produces={"mrna": 1.5},
                    explanation="The nucleus is producing mRNA instructions for protein synthesis.",
                    confidence=0.85,
                )
            ]
        if obs.cycle_phase in {"G1", "G2", "M_PROPHASE", "M_PROMETAPHASE", "M_METAPHASE", "M_ANAPHASE", "M_TELOPHASE", "CYTOKINESIS"}:
            return [
                AgentAction(
                    action_id=f"{obs.organelle_id}-advance-{obs.tick}",
                    organelle_id=obs.organelle_id,
                    action_type="advance_cell_cycle",
                    priority=6,
                    magnitude=0.3,
                    duration_ticks=1,
                    explanation="Checkpoint conditions are being tested for the next cell-cycle phase.",
                    confidence=0.6,
                )
            ]
        return []

    def _ribosome_actions(self, obs: AgentObservation) -> list[AgentAction]:
        if obs.resources["amino_acids"] < 1.0:
            return [
                AgentAction(
                    action_id=f"{obs.organelle_id}-request-aa-{obs.tick}",
                    organelle_id=obs.organelle_id,
                    action_type="request_resource",
                    priority=8,
                    magnitude=0.5,
                    duration_ticks=1,
                    explanation="Ribosomes need more amino acids before translation can continue.",
                    confidence=0.8,
                )
            ]
        if obs.resources["mrna"] > 0.5 and obs.resources["atp"] > 0.5:
            return [
                AgentAction(
                    action_id=f"{obs.organelle_id}-translate-{obs.tick}",
                    organelle_id=obs.organelle_id,
                    action_type="translate_mrna",
                    priority=8,
                    magnitude=0.7,
                    duration_ticks=1,
                    consumes={"mrna": 0.8, "amino_acids": 1.0, "atp": 0.5},
                    produces={"proteins": 0.8, "secretory_cargo": 0.4},
                    explanation="Ribosomes are translating mRNA into proteins.",
                    confidence=0.9,
                )
            ]
        return []

    def _rough_er_actions(self, obs: AgentObservation) -> list[AgentAction]:
        if obs.queues["unfolded_proteins"] > 0.2:
            return [
                AgentAction(
                    action_id=f"{obs.organelle_id}-fold-{obs.tick}",
                    organelle_id=obs.organelle_id,
                    action_type="fold_protein",
                    priority=7,
                    magnitude=0.6,
                    duration_ticks=1,
                    consumes={"unfolded_proteins": 0.6, "atp": 0.2},
                    produces={"folded_proteins": 0.5},
                    explanation="The rough ER is folding newly synthesized cargo.",
                    confidence=0.85,
                )
            ]
        if obs.resources["folded_proteins"] > 0.6:
            return [
                AgentAction(
                    action_id=f"{obs.organelle_id}-package-{obs.tick}",
                    organelle_id=obs.organelle_id,
                    action_type="package_cargo",
                    priority=6,
                    magnitude=0.5,
                    duration_ticks=1,
                    consumes={"folded_proteins": 0.5},
                    produces={"golgi_cargo": 0.5},
                    explanation="Folded cargo is being packed for Golgi transfer.",
                    confidence=0.8,
                )
            ]
        return []

    def _smooth_er_actions(self, obs: AgentObservation) -> list[AgentAction]:
        if obs.resources["ros"] > 1.0 or obs.mode in {"growth", "recovery"}:
            return [
                AgentAction(
                    action_id=f"{obs.organelle_id}-calm-{obs.tick}",
                    organelle_id=obs.organelle_id,
                    action_type="reduce_stress",
                    priority=5,
                    magnitude=0.4,
                    duration_ticks=1,
                    consumes={"atp": 0.1},
                    produces={"lipids": 0.2},
                    explanation="The smooth ER is buffering stress and supporting membrane lipids.",
                    confidence=0.7,
                )
            ]
        return []

    def _golgi_actions(self, obs: AgentObservation) -> list[AgentAction]:
        if obs.queues["golgi_cargo"] > 0.2:
            return [
                AgentAction(
                    action_id=f"{obs.organelle_id}-golgi-package-{obs.tick}",
                    organelle_id=obs.organelle_id,
                    action_type="package_cargo",
                    priority=7,
                    magnitude=0.6,
                    duration_ticks=1,
                    consumes={"golgi_cargo": 0.6},
                    produces={"vesicle_jobs": 0.5, "secretory_cargo": 0.2, "membrane_proteins": 0.2},
                    explanation="The Golgi is sorting and labeling cargo for delivery.",
                    confidence=0.85,
                )
            ]
        if obs.queues["vesicle_jobs"] > 0.2:
            return [
                AgentAction(
                    action_id=f"{obs.organelle_id}-dispatch-{obs.tick}",
                    organelle_id=obs.organelle_id,
                    action_type="dispatch_vesicle",
                    priority=6,
                    magnitude=0.5,
                    duration_ticks=1,
                    consumes={"vesicle_jobs": 0.4},
                    explanation="Golgi vesicles are being dispatched to their destinations.",
                    confidence=0.8,
                )
            ]
        return []

    def _mitochondrion_actions(self, obs: AgentObservation) -> list[AgentAction]:
        if obs.resources["glucose"] < 1.0 or obs.resources["oxygen"] < 1.0:
            return [
                AgentAction(
                    action_id=f"{obs.organelle_id}-fuel-request-{obs.tick}",
                    organelle_id=obs.organelle_id,
                    action_type="request_resource",
                    priority=9,
                    magnitude=0.6,
                    duration_ticks=1,
                    explanation="Mitochondria are requesting more glucose and oxygen.",
                    confidence=0.85,
                )
            ]
        if obs.resources["atp"] < 14.0:
            return [
                AgentAction(
                    action_id=f"{obs.organelle_id}-atp-{obs.tick}",
                    organelle_id=obs.organelle_id,
                    action_type="produce_atp",
                    priority=9,
                    magnitude=0.8,
                    duration_ticks=1,
                    consumes={"glucose": 0.9, "oxygen": 0.9, "adp": 0.8},
                    produces={"atp": 1.8, "ros": 0.1},
                    explanation="The mitochondrion is converting nutrients into ATP.",
                    confidence=0.92,
                )
            ]
        return []

    def _membrane_actions(self, obs: AgentObservation) -> list[AgentAction]:
        produces: dict[str, float] = {}
        if obs.resources["glucose"] < 2.0 and obs.environment["available_glucose"] > 0.2:
            produces["glucose"] = 1.2
        if obs.resources["oxygen"] < 2.0 and obs.environment["available_oxygen"] > 0.2:
            produces["oxygen"] = 1.2
        if obs.resources["amino_acids"] < 2.0 and obs.environment["available_amino_acids"] > 0.2:
            produces["amino_acids"] = 1.0
        if produces:
            return [
                AgentAction(
                    action_id=f"{obs.organelle_id}-import-{obs.tick}",
                    organelle_id=obs.organelle_id,
                    action_type="import_resource",
                    priority=8,
                    magnitude=0.7,
                    duration_ticks=1,
                    consumes={"atp": 0.2},
                    produces=produces,
                    explanation="The plasma membrane is importing needed resources from the environment.",
                    confidence=0.9,
                )
            ]
        if obs.resources["waste"] > 1.5:
            return [
                AgentAction(
                    action_id=f"{obs.organelle_id}-export-waste-{obs.tick}",
                    organelle_id=obs.organelle_id,
                    action_type="export_waste",
                    priority=6,
                    magnitude=0.5,
                    duration_ticks=1,
                    consumes={"waste": 0.4},
                    explanation="The plasma membrane is exporting excess waste.",
                    confidence=0.75,
                )
            ]
        return []

    def _cytoskeleton_actions(self, obs: AgentObservation) -> list[AgentAction]:
        if obs.cycle_phase in {"G2", "M_PROPHASE", "M_PROMETAPHASE", "M_METAPHASE"}:
            return [
                AgentAction(
                    action_id=f"{obs.organelle_id}-spindle-{obs.tick}",
                    organelle_id=obs.organelle_id,
                    action_type="prepare_spindle",
                    priority=7,
                    magnitude=0.5,
                    duration_ticks=1,
                    consumes={"atp": 0.2},
                    explanation="The cytoskeleton is organizing mitotic spindle elements.",
                    confidence=0.8,
                )
            ]
        if obs.queues["vesicle_jobs"] > 0.2:
            return [
                AgentAction(
                    action_id=f"{obs.organelle_id}-move-{obs.tick}",
                    organelle_id=obs.organelle_id,
                    action_type="move_cargo",
                    priority=6,
                    magnitude=0.5,
                    duration_ticks=1,
                    consumes={"vesicle_jobs": 0.2, "atp": 0.1},
                    explanation="The cytoskeleton is transporting vesicle cargo.",
                    confidence=0.75,
                )
            ]
        return []

    def _lysosome_actions(self, obs: AgentObservation) -> list[AgentAction]:
        if obs.resources["waste"] > 1.0 or obs.resources["damaged_components"] > 0.8:
            return [
                AgentAction(
                    action_id=f"{obs.organelle_id}-recycle-{obs.tick}",
                    organelle_id=obs.organelle_id,
                    action_type="recycle_waste",
                    priority=7,
                    magnitude=0.6,
                    duration_ticks=1,
                    consumes={"waste": 0.6, "damaged_components": 0.2, "atp": 0.1},
                    produces={"amino_acids": 0.3, "lipids": 0.2},
                    explanation="The lysosome is recycling waste into reusable building blocks.",
                    confidence=0.85,
                )
            ]
        return []

    def _peroxisome_actions(self, obs: AgentObservation) -> list[AgentAction]:
        if obs.resources["ros"] > 0.9:
            return [
                AgentAction(
                    action_id=f"{obs.organelle_id}-detox-{obs.tick}",
                    organelle_id=obs.organelle_id,
                    action_type="reduce_stress",
                    priority=7,
                    magnitude=0.6,
                    duration_ticks=1,
                    consumes={"ros": 0.4},
                    explanation="The peroxisome is reducing oxidative stress.",
                    confidence=0.88,
                )
            ]
        return []

    def _centrosome_actions(self, obs: AgentObservation) -> list[AgentAction]:
        if obs.cycle_phase in {"G2", "M_PROPHASE", "M_PROMETAPHASE", "M_METAPHASE"}:
            return [
                AgentAction(
                    action_id=f"{obs.organelle_id}-align-{obs.tick}",
                    organelle_id=obs.organelle_id,
                    action_type="prepare_spindle",
                    priority=7,
                    magnitude=0.5,
                    duration_ticks=1,
                    consumes={"atp": 0.2},
                    explanation="The centrosome is coordinating spindle readiness.",
                    confidence=0.82,
                )
            ]
        return []


class AgentRuntime:
    def __init__(
        self,
        provider: AgentProvider | None = None,
        llm_max_concurrency: int = 2,
        llm_timeout_seconds: float = 8.0,
    ) -> None:
        self.provider = provider
        self.llm_timeout_seconds = llm_timeout_seconds
        self._semaphore = asyncio.Semaphore(llm_max_concurrency)
        organelle_types = [
            "nucleus",
            "nucleolus",
            "ribosome",
            "rough_er",
            "smooth_er",
            "golgi",
            "mitochondrion",
            "plasma_membrane",
            "cytoplasm",
            "cytoskeleton",
            "lysosome",
            "endosome",
            "peroxisome",
            "centrosome",
        ]
        self.agents = {organelle_type: RuleBasedOrganelleAgent(organelle_type) for organelle_type in organelle_types}

    def should_deliberate(self, cell: CellState, organelle: OrganelleState) -> bool:
        return self.provider is not None and (
            cell.tick % 10 == 0 or organelle.stress > 0.6 or cell.mode in {"stress_response", "dna_repair"}
        )

    async def _provider_actions(self, observation: AgentObservation) -> list[AgentAction]:
        if not self.provider:
            return []
        async with self._semaphore:
            card = get_organelle_card(observation.organelle_type)
            try:
                return await asyncio.wait_for(
                    self.provider.propose_actions(card, observation),
                    timeout=self.llm_timeout_seconds,
                )
            except Exception:
                logger.exception("Provider deliberation failed for %s", observation.organelle_id)
                return []

    async def collect_actions(self, cell: CellState) -> list[AgentAction]:
        rule_actions: list[AgentAction] = []
        provider_tasks: list[asyncio.Task[list[AgentAction]]] = []
        for organelle in cell.organelles.values():
            agent = self.agents.get(organelle.type)
            if not agent:
                continue
            observation = agent.build_observation(cell, organelle)
            rule_actions.extend(await agent.decide(observation))
            if self.should_deliberate(cell, organelle):
                provider_tasks.append(asyncio.create_task(self._provider_actions(observation)))

        provider_actions: list[AgentAction] = []
        if provider_tasks:
            for action_batch in await asyncio.gather(*provider_tasks):
                provider_actions.extend(action_batch)

        actions = rule_actions + provider_actions
        return sorted(actions, key=lambda action: (-action.priority, action.action_id))

