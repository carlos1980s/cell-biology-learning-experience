from __future__ import annotations

from collections import defaultdict, deque
from dataclasses import dataclass
from time import monotonic

from fastapi import HTTPException, status


@dataclass(slots=True)
class RateLimitRule:
    max_requests: int
    window_seconds: float


class InMemoryRateLimiter:
    def __init__(self, rule: RateLimitRule | None = None) -> None:
        self.rule = rule or RateLimitRule(max_requests=120, window_seconds=60.0)
        self._requests: dict[str, deque[float]] = defaultdict(deque)

    def check(self, key: str) -> None:
        now = monotonic()
        entries = self._requests[key]
        cutoff = now - self.rule.window_seconds
        while entries and entries[0] < cutoff:
            entries.popleft()
        if len(entries) >= self.rule.max_requests:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Rate limit exceeded",
            )
        entries.append(now)

