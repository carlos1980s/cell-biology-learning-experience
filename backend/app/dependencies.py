from __future__ import annotations

from dataclasses import dataclass
from functools import lru_cache

from app.agents.provider_mock import MockAgentProvider
from app.agents.provider_openai import OpenAIResponsesProvider
from app.agents.runtime import AgentRuntime
from app.config import Settings, get_settings
from app.observability.metrics import InMemoryMetrics
from app.security.rate_limit import InMemoryRateLimiter
from app.sim.engine import SimulationEngine
from app.storage.memory_store import MemoryStore
from app.storage.sqlite_store import SQLiteStore


@dataclass
class Services:
    settings: Settings
    metrics: InMemoryMetrics
    limiter: InMemoryRateLimiter
    sqlite_store: SQLiteStore
    store: MemoryStore
    runtime: AgentRuntime
    engine: SimulationEngine


@lru_cache(maxsize=1)
def get_services() -> Services:
    settings = get_settings()
    metrics = InMemoryMetrics()
    sqlite_store = SQLiteStore(settings.sqlite_path)
    store = MemoryStore(settings=settings, sqlite_store=sqlite_store)
    provider = None
    if settings.agent_provider == "mock":
        provider = MockAgentProvider()
    elif settings.agent_provider in {"openai", "hybrid"}:
        provider = OpenAIResponsesProvider(settings)
    runtime = AgentRuntime(
        provider=provider,
        llm_max_concurrency=settings.llm_max_concurrency,
        llm_timeout_seconds=settings.llm_timeout_seconds,
    )
    engine = SimulationEngine(settings=settings, store=store, runtime=runtime, metrics=metrics)
    limiter = InMemoryRateLimiter()
    return Services(
        settings=settings,
        metrics=metrics,
        limiter=limiter,
        sqlite_store=sqlite_store,
        store=store,
        runtime=runtime,
        engine=engine,
    )
