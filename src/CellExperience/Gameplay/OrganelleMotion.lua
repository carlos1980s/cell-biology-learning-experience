local OrganelleMotion = {}

function OrganelleMotion.build(_, _, spec)
    local starterPlayer = game:GetService("StarterPlayer")
    local starterPlayerScripts = starterPlayer:WaitForChild("StarterPlayerScripts")

    local template = [[
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local ROOT_NAME = "__ROOT_NAME__"
local REFRESH_INTERVAL = 4
local MAX_UPDATE_DISTANCE = 760

local function getGenerated()
    local root = Workspace:FindFirstChild(ROOT_NAME)
    return root and root:FindFirstChild("GeneratedModels")
end

local function hasMotionData(instance)
    return instance:GetAttribute("OrganelleMotionPhase") ~= nil
        or instance:GetAttribute("MotionPhase") ~= nil
        or instance:GetAttribute("PulseAmplitude") ~= nil
end

local function motionNumber(instance, primary, secondary, fallback)
    local value = instance:GetAttribute(primary)
    if value == nil and secondary then
        value = instance:GetAttribute(secondary)
    end
    if typeof(value) == "number" then
        return value
    end
    return fallback
end

local function motionVector(instance, primary, secondary, fallback)
    local value = instance:GetAttribute(primary)
    if value == nil and secondary then
        value = instance:GetAttribute(secondary)
    end
    if typeof(value) == "Vector3" and value.Magnitude > 0.001 then
        return value.Unit
    end
    return fallback
end

local function targetFromInstance(instance)
    if not instance or not (instance:IsA("Model") or instance:IsA("BasePart")) then
        return nil
    end

    local base = instance:IsA("Model") and instance:GetPivot() or instance.CFrame
    local mode = instance:GetAttribute("OrganelleMotionMode") or instance:GetAttribute("MotionMode") or "Drift"
    local amplitude = motionNumber(instance, "OrganelleMotionAmplitude", "MotionAmplitude", 0.25)
    local lateral = motionNumber(instance, "OrganelleMotionLateralAmplitude", "MotionLateralAmplitude", amplitude * 0.3)
    local frequency = motionNumber(instance, "OrganelleMotionFrequency", "MotionFrequency", 0.22)
    local phase = motionNumber(instance, "OrganelleMotionPhase", "MotionPhase", 0)
    local pulse = motionNumber(instance, "PulseAmplitude", nil, 0.04)
    local axis = motionVector(instance, "OrganelleMotionAxis", "MotionAxis", Vector3.yAxis)

    return {
        kind = instance:IsA("Model") and "model" or "part",
        instance = instance,
        base = base,
        mode = mode,
        amplitude = amplitude,
        lateral = lateral,
        frequency = frequency,
        phase = phase,
        pulse = pulse,
        axis = axis,
    }
end

local function collectTargets()
    local generated = getGenerated()
    if not generated then
        return nil
    end

    local targets = {}
    local function push(target)
        if target then
            table.insert(targets, target)
        end
    end

    for _, descendant in ipairs(generated:GetDescendants()) do
        if hasMotionData(descendant) then
            push(targetFromInstance(descendant))
        end
    end

    if #targets == 0 then
        for _, fallback in ipairs({
            generated:FindFirstChild("Nucleus"),
            generated:FindFirstChild("RoughER"),
            generated:FindFirstChild("SmoothER"),
            generated:FindFirstChild("GolgiBody"),
            generated:FindFirstChild("LysosomeField"),
            generated:FindFirstChild("VesicleField"),
        }) do
            if fallback then
                push({
                    kind = "model",
                    instance = fallback,
                    base = fallback:GetPivot(),
                    mode = "Drift",
                    amplitude = 0.35,
                    lateral = 0.1,
                    frequency = 0.2,
                    phase = #targets * 3.1,
                    pulse = 0.04,
                    axis = Vector3.yAxis,
                })
            end
        end
    end

    return targets
end

local function offsetFor(target, t)
    local phase = target.phase
    local frequency = target.frequency
    local axis = target.axis
    local reference = math.abs(axis.Y) > 0.92 and Vector3.xAxis or Vector3.yAxis
    local tangent = reference:Cross(axis)
    if tangent.Magnitude <= 0.001 then
        tangent = Vector3.zAxis:Cross(axis)
    end
    tangent = tangent.Unit
    local bitangent = axis:Cross(tangent).Unit

    local axial = math.sin(t * frequency + phase) * target.amplitude
    local lateralA = math.noise(phase + 5.3, t * frequency * 0.71, 0) * target.lateral
    local lateralB = math.noise(phase - 3.1, t * frequency * 0.57, 4.8) * target.lateral * 0.72
    local pulse = math.sin(t * frequency * 1.6 + phase * 1.2) * target.pulse

    local offset
    local rotation
    if target.mode == "Pulse" then
        offset = axis * axial + tangent * lateralA * 0.4 + bitangent * lateralB * 0.4
        rotation = Vector3.new(pulse * 0.08, lateralA * 0.03, pulse * 0.08)
    elseif target.mode == "Undulate" then
        offset = axis * axial * 0.55 + tangent * lateralA + bitangent * lateralB
        rotation = Vector3.new(lateralA * 0.05, pulse * 0.05, lateralB * 0.05)
    elseif target.mode == "Ripple" then
        offset = axis * axial * 0.22 + tangent * lateralA * 0.6 + bitangent * lateralB * 0.6
        rotation = Vector3.new(pulse * 0.04, lateralA * 0.04, lateralB * 0.04)
    else
        offset = axis * axial * 0.4 + tangent * lateralA + bitangent * lateralB
        rotation = Vector3.new(lateralA * 0.05, pulse * 0.05, lateralB * 0.05)
    end

    return offset, rotation
end

local targets
local refreshElapsed = REFRESH_INTERVAL
local timeElapsed = 0

RunService.RenderStepped:Connect(function(dt)
    timeElapsed += dt
    refreshElapsed += dt

    if not targets or refreshElapsed >= REFRESH_INTERVAL then
        targets = collectTargets()
        refreshElapsed = 0
    end

    if not targets then
        return
    end

    local camera = Workspace.CurrentCamera
    local focus = camera and camera.CFrame.Position or Vector3.zero

    for _, target in ipairs(targets) do
        local instance = target.instance
        if not instance or not instance.Parent then
            targets = nil
            break
        end

        local basePosition = target.kind == "model" and target.base.Position or target.base.Position
        if (basePosition - focus).Magnitude > MAX_UPDATE_DISTANCE then
            if target.kind == "model" then
                instance:PivotTo(target.base)
            else
                instance.CFrame = target.base
            end
        else
            local offset, rotation = offsetFor(target, timeElapsed)
            if target.kind == "model" then
                instance:PivotTo(target.base * CFrame.new(offset) * CFrame.Angles(rotation.X, rotation.Y, rotation.Z))
            else
                instance.CFrame = target.base * CFrame.new(offset) * CFrame.Angles(rotation.X, rotation.Y, rotation.Z)
            end
        end
    end
end)
]]

    local scriptSource = template:gsub("__ROOT_NAME__", spec.rootName)

    local localScript = starterPlayerScripts:FindFirstChild("CellOrganelleMotion") or Instance.new("LocalScript")
    localScript.Name = "CellOrganelleMotion"
    localScript.Source = scriptSource
    localScript.Parent = starterPlayerScripts

    return nil, {}
end

return OrganelleMotion
