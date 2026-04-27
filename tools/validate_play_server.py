#!/usr/bin/env python3
"""Run a short server-only play validation for generated Roblox scripts."""

from __future__ import annotations

from roblox_mcp_smoke import DEFAULT_SERVER, RobloxMCPClient, text_content


PLAY_COMMAND = r"""
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local root = workspace:WaitForChild("CellBiologyExperience", 10)
assert(root, "CellBiologyExperience missing")

local craft = root.GeneratedModels:WaitForChild("ExplorerSubmarine", 10)
local core = craft:WaitForChild("Core", 10)
local seat = craft:WaitForChild("PilotSeat", 10)
local driveScript = craft:WaitForChild("ExplorerDrive", 10)
assert(core.Anchored == false, "Explorer core anchored in play")
assert(seat:IsA("VehicleSeat"), "PilotSeat is not a VehicleSeat")
assert(driveScript:IsA("Script"), "ExplorerDrive is not a Script")
assert(core:FindFirstChild("DriveAlign"), "DriveAlign missing in play")
assert(core:FindFirstChild("DriveVelocity"), "DriveVelocity missing in play")
assert(core:FindFirstChild("BuoyancyForce"), "BuoyancyForce missing in play")
assert(#Players:GetPlayers() >= 1, "No player joined in start_play mode")
local player = Players:GetPlayers()[1]
assert(player.Character, "Player character missing")
local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
assert(humanoidRootPart, "HumanoidRootPart missing")
assert((humanoidRootPart.Position - Vector3.new(-128, 58, 42)).Magnitude < 20, "Player spawned far from launch pad")

for _ = 1, 5 do
    RunService.Heartbeat:Wait()
end

print("play_validation_root_descendants", #root:GetDescendants())
print("play_validation_drive_script_disabled", tostring(driveScript.Disabled))
print("play_validation_core_anchored", tostring(core.Anchored))
print("play_validation_player_character", player.Name)
return "play_validation_ok"
"""


def main() -> int:
    with RobloxMCPClient(DEFAULT_SERVER, timeout=240.0) as client:
        response = client.call_tool(
            "run_script_in_play_mode",
            {"code": PLAY_COMMAND, "mode": "start_play", "timeout": 90},
        )
        print(text_content(response).strip())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
