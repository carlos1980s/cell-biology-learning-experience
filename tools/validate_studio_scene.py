#!/usr/bin/env python3
"""Validate the generated cell biology scene in Roblox Studio edit mode."""

from __future__ import annotations

from roblox_mcp_smoke import DEFAULT_SERVER, RobloxMCPClient, text_content


VALIDATION_COMMAND = r"""
local root = workspace:FindFirstChild("CellBiologyExperience")
assert(root, "CellBiologyExperience missing")

local generated = root:FindFirstChild("GeneratedModels")
assert(generated, "GeneratedModels missing")

local requiredModels = {
    "CellEnvelope",
    "Nucleus",
    "RoughER",
    "SmoothER",
    "Ribosomes",
    "Mitochondria",
    "GolgiBody",
    "LysosomeField",
    "VesicleField",
    "ExplorerSubmarine",
}
for _, name in ipairs(requiredModels) do
    assert(generated:FindFirstChild(name), name .. " missing")
end

local hotspots = root:FindFirstChild("LearningHotspots")
assert(hotspots, "LearningHotspots missing")

local promptCount = 0
for _, descendant in ipairs(hotspots:GetDescendants()) do
    if descendant:IsA("ProximityPrompt") then
        promptCount += 1
    end
end
assert(promptCount >= 14, "Expected at least 14 prompts, got " .. promptCount)

local craft = generated:FindFirstChild("ExplorerSubmarine")
local core = craft:FindFirstChild("Core")
assert(core, "Explorer core missing")
assert(core.Anchored == false, "Explorer core should be unanchored for piloting")
assert(craft:FindFirstChild("PilotSeat"), "PilotSeat missing")
assert(core:FindFirstChild("DriveAlign"), "DriveAlign missing")
assert(core:FindFirstChild("DriveVelocity"), "DriveVelocity missing")
assert(core:FindFirstChild("BuoyancyForce"), "BuoyancyForce missing")

local sourceRoot = game:GetService("ServerScriptService"):FindFirstChild("CellExperience")
assert(sourceRoot, "Source modules missing from ServerScriptService")
local starterPlayerScripts = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
assert(starterPlayerScripts and starterPlayerScripts:FindFirstChild("CellPlayerBootstrap"), "CellPlayerBootstrap missing")

print("validation_root_descendants", #root:GetDescendants())
print("validation_source_descendants", #sourceRoot:GetDescendants())
print("validation_prompt_count", promptCount)
print("validation_craft_core_anchored", tostring(core.Anchored))
print("validation_ok")
"""


def main() -> int:
    with RobloxMCPClient(DEFAULT_SERVER, timeout=45.0) as client:
        response = client.call_tool("run_code", {"command": VALIDATION_COMMAND})
        print(text_content(response).strip())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
