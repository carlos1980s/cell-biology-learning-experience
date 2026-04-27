from __future__ import annotations

from app.agents.base import AgentObservation, OrganelleCard
from app.agents.provider_base import AgentProvider
from app.schemas.actions import AgentAction


class MockAgentProvider(AgentProvider):
    async def propose_actions(
        self,
        agent_card: OrganelleCard,
        observation: AgentObservation,
    ) -> list[AgentAction]:
        if observation.organelle_type == "mitochondrion" and observation.resources["atp"] < 8:
            return [
                AgentAction(
                    action_id=f"{observation.organelle_id}-mock-produce-atp-{observation.tick}",
                    organelle_id=observation.organelle_id,
                    action_type="produce_atp",
                    priority=8,
                    magnitude=0.5,
                    duration_ticks=1,
                    consumes={"glucose": 0.8, "oxygen": 0.8, "adp": 0.8},
                    produces={"atp": 1.4},
                    explanation="Energy production is being increased to stabilize ATP.",
                    confidence=0.85,
                )
            ]

        if observation.organelle_type == "nucleus" and observation.organelle_stress > 0.5:
            return [
                AgentAction(
                    action_id=f"{observation.organelle_id}-mock-signal-{observation.tick}",
                    organelle_id=observation.organelle_id,
                    action_type="send_signal",
                    priority=7,
                    magnitude=0.4,
                    duration_ticks=1,
                    explanation="The nucleus is warning other organelles that the cell is under stress.",
                    confidence=0.8,
                )
            ]

        return []

