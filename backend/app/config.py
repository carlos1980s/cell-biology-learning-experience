from functools import lru_cache
from typing import Literal

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    app_env: Literal["development", "test", "production"] = "development"
    backend_auth_token: str = "change-me-local-dev-token"
    openai_api_key: str | None = None
    openai_model: str = "gpt-5.4-mini"
    agent_provider: Literal["mock", "openai", "hybrid"] = "mock"
    database_url: str = "sqlite:///./cell_agents.db"
    tick_rate_hz: int = Field(default=2, ge=1, le=60)
    llm_max_concurrency: int = Field(default=2, ge=1, le=32)
    llm_timeout_seconds: float = Field(default=8.0, ge=0.5, le=60.0)
    dev_endpoints_enabled: bool = True
    max_event_history: int = Field(default=250, ge=25, le=5000)
    snapshot_interval_ticks: int = Field(default=5, ge=1, le=1000)
    long_poll_sleep_ms: int = Field(default=250, ge=50, le=2000)
    api_prefix: str = "/v1"
    service_version: str = "0.1.0"

    @property
    def sqlite_path(self) -> str:
        prefix = "sqlite:///"
        if self.database_url.startswith(prefix):
            return self.database_url.removeprefix(prefix)
        return "./cell_agents.db"


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()

