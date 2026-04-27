from __future__ import annotations

from pathlib import Path

import pytest
from fastapi.testclient import TestClient

from app.config import get_settings
from app.dependencies import get_services

ROOT = Path(__file__).resolve().parents[1]


@pytest.fixture()
def client(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> TestClient:
    monkeypatch.setenv("APP_ENV", "test")
    monkeypatch.setenv("BACKEND_AUTH_TOKEN", "test-token")
    monkeypatch.setenv("DATABASE_URL", f"sqlite:///{tmp_path / 'cell_agents.db'}")
    monkeypatch.chdir(ROOT)
    get_settings.cache_clear()
    get_services.cache_clear()

    from app.main import app

    with TestClient(app) as test_client:
        yield test_client

    get_services.cache_clear()
    get_settings.cache_clear()


@pytest.fixture()
def auth_headers() -> dict[str, str]:
    return {"Authorization": "Bearer test-token"}


@pytest.fixture()
def session_request() -> dict[str, str]:
    return {
        "roblox_server_id": "server-1",
        "universe_id": "universe-1",
        "place_id": "place-1",
        "player_id_hash": "player-hash",
        "cell_type": "animal",
        "frontend_version": "test-client",
    }


@pytest.fixture()
def session_bundle(
    client: TestClient,
    auth_headers: dict[str, str],
    session_request: dict[str, str],
) -> dict[str, object]:
    response = client.post("/v1/sessions", headers=auth_headers, json=session_request)
    assert response.status_code == 200
    return response.json()

