from __future__ import annotations

import json

from fastapi.testclient import TestClient

from app.schemas.cell_state import CellState
from app.sim.scenarios import build_initial_cell_state


def test_health_and_session_start(
    client: TestClient,
    auth_headers: dict[str, str],
    session_request: dict[str, str],
) -> None:
    health = client.get("/health")
    assert health.status_code == 200
    assert health.json() == {"ok": True, "version": "0.1.0"}

    response = client.post("/v1/sessions", headers=auth_headers, json=session_request)
    assert response.status_code == 200
    payload = response.json()
    assert payload["session_id"].startswith("session-")
    assert payload["cell_id"].startswith("cell-")
    assert payload["initial_state"]["cell_id"] == payload["cell_id"]
    assert payload["initial_delta"]["cell_id"] == payload["cell_id"]


def test_tick_full_state_and_inspect_endpoints(
    client: TestClient,
    auth_headers: dict[str, str],
    session_bundle: dict[str, object],
) -> None:
    cell_id = session_bundle["cell_id"]
    session_id = session_bundle["session_id"]

    tick = client.post(
        f"/v1/cells/{cell_id}/tick",
        headers=auth_headers,
        json={
            "session_id": session_id,
            "dt": 1.0,
            "last_seen_version": 0,
            "max_events": 20,
        },
    )
    assert tick.status_code == 200
    tick_payload = tick.json()
    assert tick_payload["delta"]["tick"] >= 1
    assert tick_payload["recommended_next_poll_ms"] >= 500

    full_state = client.get(
        f"/v1/cells/{cell_id}",
        headers=auth_headers,
        params={"session_id": session_id},
    )
    assert full_state.status_code == 200
    assert full_state.json()["cell_id"] == cell_id

    inspect = client.post(
        f"/v1/cells/{cell_id}/organelles/nucleus-1/inspect",
        headers=auth_headers,
        params={"session_id": session_id},
    )
    assert inspect.status_code == 200
    assert inspect.json()["display_name"] == "Nucleus"


def test_cell_state_serialization_round_trip() -> None:
    cell = build_initial_cell_state(session_id="session-test", cell_id="cell-test")
    payload = cell.model_dump_json()
    round_tripped = CellState.model_validate_json(payload)
    assert round_tripped.cell_id == "cell-test"
    assert "nucleus-1" in round_tripped.organelles


def test_roblox_delta_json_serializable(
    client: TestClient,
    auth_headers: dict[str, str],
    session_bundle: dict[str, object],
) -> None:
    response = client.post(
        f"/v1/cells/{session_bundle['cell_id']}/tick",
        headers=auth_headers,
        json={
            "session_id": session_bundle["session_id"],
            "dt": 1.0,
            "last_seen_version": 0,
            "max_events": 10,
        },
    )
    assert response.status_code == 200
    json.dumps(response.json()["delta"])

