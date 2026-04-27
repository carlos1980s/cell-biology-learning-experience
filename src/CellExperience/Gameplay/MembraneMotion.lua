local MembraneMotion = {}

function MembraneMotion.build(_, _, spec)
    local starterPlayer = game:GetService("StarterPlayer")
    local starterPlayerScripts = starterPlayer:WaitForChild("StarterPlayerScripts")

    local template = [[
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local ROOT_NAME = "__ROOT_NAME__"
local MAX_UPDATE_DISTANCE = 540

local function basisFromNormal(normal)
    local reference = math.abs(normal.Y) > 0.92 and Vector3.new(1, 0, 0) or Vector3.new(0, 1, 0)
    local tangent = reference:Cross(normal)
    if tangent.Magnitude < 0.001 then
        tangent = Vector3.new(0, 0, 1):Cross(normal)
    end
    tangent = tangent.Unit
    local bitangent = normal:Cross(tangent)
    if bitangent.Magnitude < 0.001 then
        bitangent = Vector3.new(0, 0, 1)
    else
        bitangent = bitangent.Unit
    end
    return tangent, bitangent
end

local function collectSectors()
    local root = Workspace:FindFirstChild(ROOT_NAME)
    if not root then
        return nil
    end

    local generated = root:FindFirstChild("GeneratedModels")
    local envelope = generated and generated:FindFirstChild("CellEnvelope")
    local membrane = envelope and envelope:FindFirstChild("MembraneBilayer")
    if not membrane then
        return nil
    end

    local sectors = {}
    for _, child in ipairs(membrane:GetChildren()) do
        local normal = child:GetAttribute("MembraneNormal")
        if child:IsA("Model") and typeof(normal) == "Vector3" and normal.Magnitude > 0.001 then
            table.insert(sectors, {
                model = child,
                basePivot = child:GetPivot(),
                normal = normal.Unit,
                phase = child:GetAttribute("MembranePhase") or 0,
                amplitude = child:GetAttribute("MembraneAmplitude") or 0.35,
                lateral = child:GetAttribute("MembraneLateralAmplitude") or 0.09,
                frequency = child:GetAttribute("MembraneFrequency") or 0.28,
            })
        end
    end

    return sectors
end

local sectors
local refreshTimer = 10
local elapsed = 0

RunService.RenderStepped:Connect(function(dt)
    elapsed += dt
    refreshTimer += dt

    if not sectors or refreshTimer >= 4 then
        sectors = collectSectors()
        refreshTimer = 0
    end

    if not sectors then
        return
    end

    local camera = Workspace.CurrentCamera
    local focusPosition = camera and camera.CFrame.Position or Vector3.zero

    for _, sector in ipairs(sectors) do
        local model = sector.model
        if not model.Parent then
            sectors = nil
            break
        end

        local basePivot = sector.basePivot
        local basePosition = basePivot.Position
        if (basePosition - focusPosition).Magnitude > MAX_UPDATE_DISTANCE then
            model:PivotTo(basePivot)
        else
            local tangent, bitangent = basisFromNormal(sector.normal)
            local timeScale = elapsed * sector.frequency
            local noiseA = math.noise(sector.phase, timeScale, 0)
            local noiseB = math.noise(sector.phase + 13.7, timeScale * 0.73, 4.1)
            local noiseC = math.noise(sector.phase - 8.3, timeScale * 0.51, -6.2)

            local radialOffset = sector.normal * noiseA * sector.amplitude
            local lateralOffset = tangent * noiseB * sector.lateral + bitangent * noiseC * sector.lateral * 0.72
            model:PivotTo(
                CFrame.fromMatrix(
                    basePosition + radialOffset + lateralOffset,
                    basePivot.RightVector,
                    basePivot.UpVector,
                    -basePivot.LookVector
                )
            )
        end
    end
end)
]]

    local scriptSource = template:gsub("__ROOT_NAME__", spec.rootName)

    local localScript = starterPlayerScripts:FindFirstChild("CellMembraneMotion") or Instance.new("LocalScript")
    localScript.Name = "CellMembraneMotion"
    localScript.Source = scriptSource
    localScript.Parent = starterPlayerScripts

    return nil, {}
end

return MembraneMotion
