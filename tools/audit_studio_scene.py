#!/usr/bin/env python3
"""Print a concise structural audit of the generated Roblox cell scene."""

from __future__ import annotations

from roblox_mcp_smoke import DEFAULT_SERVER, RobloxMCPClient, text_content


AUDIT_COMMAND = r"""
local root = workspace:FindFirstChild("CellBiologyExperience")
assert(root, "CellBiologyExperience missing")
local generated = root:FindFirstChild("GeneratedModels")
assert(generated, "GeneratedModels missing")

local function fmtVector(v)
    return string.format("(%.1f, %.1f, %.1f)", v.X, v.Y, v.Z)
end

local names = {
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

for _, name in ipairs(names) do
    local model = generated:FindFirstChild(name)
    assert(model, name .. " missing")
    local cframe, size = model:GetBoundingBox()
    print("bbox", name, "center", fmtVector(cframe.Position), "size", fmtVector(size), "descendants", tostring(#model:GetDescendants()))
end

local hotspots = root:FindFirstChild("LearningHotspots")
local titles = {}
for _, child in ipairs(hotspots:GetChildren()) do
    if child:IsA("BasePart") then
        table.insert(titles, child:GetAttribute("Title") or child.Name)
    end
end
table.sort(titles)
print("hotspot_titles", table.concat(titles, " | "))

local materialCounts = {}
for _, descendant in ipairs(root:GetDescendants()) do
    if descendant:IsA("BasePart") then
        local key = descendant.Material.Name
        materialCounts[key] = (materialCounts[key] or 0) + 1
    end
end
local materials = {}
for material, count in pairs(materialCounts) do
    table.insert(materials, material .. ":" .. count)
end
table.sort(materials)
print("materials", table.concat(materials, ", "))
"""


def main() -> int:
    with RobloxMCPClient(DEFAULT_SERVER, timeout=45.0) as client:
        response = client.call_tool("run_code", {"command": AUDIT_COMMAND})
        print(text_content(response).strip())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
