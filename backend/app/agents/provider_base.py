from __future__ import annotations

from typing import Protocol

from app.agents.base import AgentObservation, OrganelleCard
from app.schemas.actions import AgentAction


class AgentProvider(Protocol):
    async def propose_actions(
        self,
        agent_card: OrganelleCard,
        observation: AgentObservation,
    ) -> list[AgentAction]: ...

