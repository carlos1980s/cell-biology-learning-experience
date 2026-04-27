from __future__ import annotations

import logging

from app.agents.base import AgentObservation, OrganelleCard
from app.agents.provider_base import AgentProvider
from app.config import Settings
from app.schemas.actions import AgentAction

logger = logging.getLogger(__name__)


class OpenAIResponsesProvider(AgentProvider):
    def __init__(self, settings: Settings) -> None:
        self.settings = settings

    async def propose_actions(
        self,
        agent_card: OrganelleCard,
        observation: AgentObservation,
    ) -> list[AgentAction]:
        if not self.settings.openai_api_key:
            logger.warning("OpenAI provider selected without OPENAI_API_KEY; falling back to no-op")
            return []
        try:
            from openai import AsyncOpenAI
        except ImportError:
            logger.warning("OpenAI provider selected without optional openai package installed")
            return []

        client = AsyncOpenAI(api_key=self.settings.openai_api_key)
        response = await client.responses.create(
            model=self.settings.openai_model,
            input=[
                {
                    "role": "system",
                    "content": [
                        {
                            "type": "input_text",
                            "text": (
                                f"{agent_card.name}: {agent_card.role}. "
                                "Return only a compact JSON array of action objects."
                            ),
                        }
                    ],
                },
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "input_text",
                            "text": observation.model_dump_json(),
                        }
                    ],
                },
            ],
        )
        logger.info("OpenAI response received for organelle %s", observation.organelle_id)
        output_text = getattr(response, "output_text", "") or ""
        if not output_text.strip():
            return []
        try:
            return [AgentAction.model_validate_json(item) for item in output_text.splitlines()]
        except Exception:
            logger.warning("OpenAI provider returned unparsable actions for %s", observation.organelle_id)
            return []

