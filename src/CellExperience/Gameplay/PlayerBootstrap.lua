local PlayerBootstrap = {}

function PlayerBootstrap.build(_, _, spec)
    local starterPlayer = game:GetService("StarterPlayer")
    local starterPlayerScripts = starterPlayer:WaitForChild("StarterPlayerScripts")

    local template = [[
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local ROOT_NAME = "__ROOT_NAME__"
local PLAYER_START = Vector3.new(__PLAYER_START__)
local FALLBACK_LOOK_TARGET = Vector3.new(__LOOK_TARGET__)
local FALLBACK_CENTER = Vector3.new(__CYTOPLASM_CENTER__)
local FALLBACK_RADII = Vector3.new(__CYTOPLASM_RADII__)
local CALM_ZONE_RADIUS = 34
local CALM_ZONE_HEIGHT = 22

local localPlayer = Players.LocalPlayer

local colorEffect = Lighting:FindFirstChild("CellCytoplasmGrade") or Instance.new("ColorCorrectionEffect")
colorEffect.Name = "CellCytoplasmGrade"
colorEffect.Saturation = 0
colorEffect.Contrast = 0
colorEffect.TintColor = Color3.fromRGB(255, 255, 255)
colorEffect.Parent = Lighting

local blurEffect = Lighting:FindFirstChild("CellCytoplasmBlur") or Instance.new("BlurEffect")
blurEffect.Name = "CellCytoplasmBlur"
blurEffect.Size = 0
blurEffect.Parent = Lighting

local atmosphere = Lighting:FindFirstChild("CellCytoplasmAtmosphere")
local originalFogColor = Lighting.FogColor
local originalFogStart = Lighting.FogStart
local originalFogEnd = Lighting.FogEnd
local originalAtmosphere
if atmosphere then
    originalAtmosphere = {
        Color = atmosphere.Color,
        Decay = atmosphere.Decay,
        Density = atmosphere.Density,
        Haze = atmosphere.Haze,
        Glare = atmosphere.Glare,
    }
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CellFlowUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local hintLabel = Instance.new("TextLabel")
hintLabel.Name = "FlowHint"
hintLabel.AnchorPoint = Vector2.new(0.5, 1)
hintLabel.Position = UDim2.fromScale(0.5, 0.97)
hintLabel.Size = UDim2.fromOffset(420, 42)
hintLabel.BackgroundColor3 = Color3.fromRGB(10, 24, 36)
hintLabel.BackgroundTransparency = 0.26
hintLabel.BorderSizePixel = 0
hintLabel.Font = Enum.Font.GothamMedium
hintLabel.TextColor3 = Color3.fromRGB(232, 245, 251)
hintLabel.TextSize = 17
hintLabel.Text = UserInputService.TouchEnabled
    and "Touch controls appear while piloting the capsule."
    or "W/A/S/D drift  |  Space rise  |  Ctrl sink"
hintLabel.Visible = false
hintLabel.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = hintLabel

local function getRoot()
    return Workspace:FindFirstChild(ROOT_NAME)
end

local function setDockVisibility(visible)
    local root = getRoot()
    if not root then
        return
    end

    for _, name in ipairs({ "ExplorerLaunchPad", "CellExplorerSpawn" }) do
        local part = root:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            part.LocalTransparencyModifier = visible and 0 or 1
            if part:IsA("SpawnLocation") then
                pcall(function()
                    part.Enabled = visible
                end)
            end
        end
    end
end

local function getCytoplasmSettings()
    local root = getRoot()
    if root then
        return {
            center = root:GetAttribute("CytoplasmCenter") or FALLBACK_CENTER,
            radii = root:GetAttribute("CytoplasmRadii") or FALLBACK_RADII,
            maxSpeed = root:GetAttribute("CytoplasmMaxSpeed") or 24,
            currentStrength = root:GetAttribute("CytoplasmCurrentStrength") or 5.5,
            buoyancyScale = root:GetAttribute("CytoplasmBuoyancyScale") or 1.04,
            drag = root:GetAttribute("CytoplasmDrag") or 0.9,
        }
    end

    return {
        center = FALLBACK_CENTER,
        radii = FALLBACK_RADII,
        maxSpeed = 24,
        currentStrength = 5.5,
        buoyancyScale = 1.04,
        drag = 0.9,
    }
end

local function getEntryLookTarget()
    local root = getRoot()
    if root then
        return root:GetAttribute("EntryLookTarget") or FALLBACK_LOOK_TARGET
    end
    return FALLBACK_LOOK_TARGET
end

local function isInsideCell(position, center, radii)
    local offset = position - center
    local normalized = Vector3.new(
        offset.X / math.max(radii.X, 1),
        offset.Y / math.max(radii.Y, 1),
        offset.Z / math.max(radii.Z, 1)
    )
    return normalized:Dot(normalized) <= 1
end

local function isInsideCalmZone(position)
    local offset = position - PLAYER_START
    local horizontal = Vector3.new(offset.X, 0, offset.Z)
    return horizontal.Magnitude <= CALM_ZONE_RADIUS and math.abs(offset.Y) <= CALM_ZONE_HEIGHT
end

local function buildInputVector(camera)
    local look = camera.CFrame.LookVector
    local forward = Vector3.new(look.X, look.Y * 0.45, look.Z)
    if forward.Magnitude < 0.01 then
        forward = Vector3.new(0, 0, -1)
    else
        forward = forward.Unit
    end

    local rightLook = camera.CFrame.RightVector
    local right = Vector3.new(rightLook.X, rightLook.Y * 0.2, rightLook.Z)
    if right.Magnitude < 0.01 then
        right = Vector3.new(1, 0, 0)
    else
        right = right.Unit
    end

    local move = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        move += forward
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        move -= forward
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        move += right
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        move -= right
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        move += Vector3.yAxis
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl)
        or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
        or UserInputService:IsKeyDown(Enum.KeyCode.Q)
    then
        move -= Vector3.yAxis
    end

    if move.Magnitude > 0.01 then
        return move.Unit
    end
    return Vector3.zero
end

local function computeFlowField(position, center, strength, timeNow)
    local offset = position - center
    local horizontal = Vector3.new(offset.X, 0, offset.Z)
    local swirl = Vector3.zero
    if horizontal.Magnitude > 0.01 then
        swirl = Vector3.new(-horizontal.Z, 0, horizontal.X).Unit * (strength * 0.55)
    end

    local vertical = Vector3.new(0, math.sin(timeNow * 0.65 + offset.X * 0.025 + offset.Z * 0.03) * strength * 0.18, 0)
    local inward = Vector3.zero
    if offset.Magnitude > 1 then
        inward = -offset.Unit * math.cos(timeNow * 0.4 + offset.Y * 0.03) * strength * 0.12
    end

    return swirl + vertical + inward
end

local currentCharacter
local currentHumanoid
local currentRoot
local attachment
local buoyancy
local velocity
local align
local wakeEmitter
local insideFlow = false
local visualsActive = false
local storedWalkSpeed = 16
local storedJumpPower = 50

local function cleanupControllers()
    for _, instance in ipairs({ wakeEmitter, align, velocity, buoyancy, attachment }) do
        if instance then
            instance:Destroy()
        end
    end

    wakeEmitter = nil
    align = nil
    velocity = nil
    buoyancy = nil
    attachment = nil
end

local function clearFluidVisuals()
    colorEffect.Saturation = 0
    colorEffect.Contrast = 0
    colorEffect.TintColor = Color3.fromRGB(255, 255, 255)
    blurEffect.Size = 0
    Lighting.FogColor = originalFogColor
    Lighting.FogStart = originalFogStart
    Lighting.FogEnd = originalFogEnd
    if atmosphere and originalAtmosphere then
        atmosphere.Color = originalAtmosphere.Color
        atmosphere.Decay = originalAtmosphere.Decay
        atmosphere.Density = originalAtmosphere.Density
        atmosphere.Haze = originalAtmosphere.Haze
        atmosphere.Glare = originalAtmosphere.Glare
    end
    setDockVisibility(true)
    visualsActive = false
end

local function applyFluidVisuals()
    colorEffect.Saturation = -0.12
    colorEffect.Contrast = 0.12
    colorEffect.TintColor = Color3.fromRGB(181, 216, 228)
    blurEffect.Size = 2
    Lighting.FogColor = Color3.fromRGB(58, 92, 112)
    Lighting.FogStart = 4
    Lighting.FogEnd = 110
    if atmosphere then
        atmosphere.Color = Color3.fromRGB(92, 158, 178)
        atmosphere.Decay = Color3.fromRGB(18, 12, 28)
        atmosphere.Density = 0.58
        atmosphere.Haze = 3.2
        atmosphere.Glare = 0.02
    end
    setDockVisibility(false)
    visualsActive = true
end

local function applyCalmZoneVisuals()
    colorEffect.Saturation = -0.1
    colorEffect.Contrast = 0.06
    colorEffect.TintColor = Color3.fromRGB(196, 224, 234)
    blurEffect.Size = 1
    Lighting.FogColor = Color3.fromRGB(72, 104, 122)
    Lighting.FogStart = 10
    Lighting.FogEnd = 150
    if atmosphere then
        atmosphere.Color = Color3.fromRGB(102, 166, 184)
        atmosphere.Decay = Color3.fromRGB(18, 14, 28)
        atmosphere.Density = 0.36
        atmosphere.Haze = 2.1
        atmosphere.Glare = 0.03
    end
    setDockVisibility(true)
    visualsActive = true
end

local function deactivateFlow()
    insideFlow = false
    hintLabel.Visible = false
    clearFluidVisuals()

    if currentHumanoid then
        currentHumanoid.AutoRotate = true
        currentHumanoid.WalkSpeed = storedWalkSpeed
        currentHumanoid.JumpPower = storedJumpPower
        currentHumanoid:ChangeState(Enum.HumanoidStateType.Running)
    end

    if velocity then
        velocity.VectorVelocity = Vector3.zero
    end
    if buoyancy then
        buoyancy.Force = Vector3.zero
    end
    if wakeEmitter then
        wakeEmitter.Rate = 0
    end

    cleanupControllers()
end

local function ensureControllers()
    if not currentRoot or attachment then
        return
    end

    attachment = Instance.new("Attachment")
    attachment.Name = "CytoplasmAttachment"
    attachment.Parent = currentRoot

    buoyancy = Instance.new("VectorForce")
    buoyancy.Name = "CytoplasmBuoyancy"
    buoyancy.Attachment0 = attachment
    buoyancy.RelativeTo = Enum.ActuatorRelativeTo.World
    buoyancy.ApplyAtCenterOfMass = true
    buoyancy.Force = Vector3.zero
    buoyancy.Parent = currentRoot

    velocity = Instance.new("LinearVelocity")
    velocity.Name = "CytoplasmVelocity"
    velocity.Attachment0 = attachment
    velocity.RelativeTo = Enum.ActuatorRelativeTo.World
    velocity.MaxForce = 1e9
    velocity.VectorVelocity = Vector3.zero
    velocity.Parent = currentRoot

    align = Instance.new("AlignOrientation")
    align.Name = "CytoplasmOrientation"
    align.Mode = Enum.OrientationAlignmentMode.OneAttachment
    align.Attachment0 = attachment
    align.Responsiveness = 12
    align.MaxTorque = 1e9
    align.CFrame = currentRoot.CFrame
    align.Parent = currentRoot

    wakeEmitter = Instance.new("ParticleEmitter")
    wakeEmitter.Name = "CytoplasmWake"
    wakeEmitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(227, 247, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(118, 221, 255)),
    })
    wakeEmitter.LightEmission = 0.35
    wakeEmitter.Lifetime = NumberRange.new(0.4, 0.8)
    wakeEmitter.Rate = 0
    wakeEmitter.Speed = NumberRange.new(0.2, 1.1)
    wakeEmitter.SpreadAngle = Vector2.new(28, 28)
    wakeEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.25),
        NumberSequenceKeypoint.new(1, 0.05),
    })
    wakeEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.18),
        NumberSequenceKeypoint.new(1, 1),
    })
    wakeEmitter.Parent = attachment
end

local function bindCharacter(character)
    cleanupControllers()
    currentCharacter = character
    currentHumanoid = character:WaitForChild("Humanoid", 10)
    currentRoot = character:WaitForChild("HumanoidRootPart", 10)
    if not currentHumanoid or not currentRoot then
        return
    end

    storedWalkSpeed = currentHumanoid.WalkSpeed
    storedJumpPower = currentHumanoid.JumpPower

    local camera = Workspace.CurrentCamera
    if camera then
        camera.CameraType = Enum.CameraType.Custom
        camera.CameraSubject = currentHumanoid
    end
    currentRoot.CFrame = CFrame.lookAt(PLAYER_START, getEntryLookTarget(), Vector3.yAxis)
    deactivateFlow()
end

if localPlayer.Character then
    bindCharacter(localPlayer.Character)
end

localPlayer.CharacterAdded:Connect(bindCharacter)

RunService.Heartbeat:Connect(function(dt)
    if not currentCharacter or not currentRoot or not currentHumanoid or currentHumanoid.Health <= 0 then
        return
    end

    local settings = getCytoplasmSettings()
    local seatPart = currentHumanoid.SeatPart
    local seatedInExplorer = seatPart
        and seatPart.Name == "PilotSeat"
        and seatPart.Parent
        and seatPart.Parent:GetAttribute("ExplorerCraft")
    local referencePosition = seatedInExplorer and seatPart.Parent.PrimaryPart and seatPart.Parent.PrimaryPart.Position or currentRoot.Position
    local inCell = isInsideCell(referencePosition, settings.center, settings.radii)
    local inCalmZone = isInsideCalmZone(referencePosition)

    if not inCell then
        if insideFlow then
            deactivateFlow()
        elseif visualsActive then
            clearFluidVisuals()
        end
        return
    end

    if seatedInExplorer then
        if insideFlow then
            deactivateFlow()
        end
        hintLabel.Visible = false
        applyFluidVisuals()
        return
    end

    if inCalmZone then
        if insideFlow then
            deactivateFlow()
        else
            hintLabel.Visible = false
        end
        applyCalmZoneVisuals()
        return
    end

    ensureControllers()
    insideFlow = true
    hintLabel.Visible = true
    applyFluidVisuals()

    currentHumanoid.AutoRotate = false
    currentHumanoid.WalkSpeed = 0
    currentHumanoid.JumpPower = 0
    currentHumanoid:ChangeState(Enum.HumanoidStateType.Physics)

    local camera = Workspace.CurrentCamera
    if not camera then
        return
    end

    local inputDirection = buildInputVector(camera)
    local flowVector = computeFlowField(currentRoot.Position, settings.center, settings.currentStrength, workspace:GetServerTimeNow())
    local desiredVelocity = flowVector
    if inputDirection.Magnitude > 0.01 then
        desiredVelocity += inputDirection * settings.maxSpeed
    end

    local response = math.clamp(dt * (3.2 - settings.drag * 1.4), 0, 1)
    velocity.VectorVelocity = currentRoot.AssemblyLinearVelocity:Lerp(desiredVelocity, response)
    buoyancy.Force = Vector3.new(0, currentRoot.AssemblyMass * workspace.Gravity * settings.buoyancyScale, 0)

    local facing = desiredVelocity.Magnitude > 1 and desiredVelocity.Unit or camera.CFrame.LookVector
    align.CFrame = CFrame.lookAt(currentRoot.Position, currentRoot.Position + facing, Vector3.yAxis)

    if wakeEmitter then
        wakeEmitter.Rate = inputDirection.Magnitude > 0.01 and 24 or 8
    end
end)
]]

    local scriptSource = template
        :gsub("__ROOT_NAME__", spec.rootName)
        :gsub("__PLAYER_START__", string.format("%0.1f, %0.1f, %0.1f", spec.organelleAnchors.playerStart.X, spec.organelleAnchors.playerStart.Y + 6, spec.organelleAnchors.playerStart.Z))
        :gsub("__LOOK_TARGET__", string.format("%0.1f, %0.1f, %0.1f", (spec.organelleAnchors.entryLookTarget or spec.organelleAnchors.nucleus).X, (spec.organelleAnchors.entryLookTarget or spec.organelleAnchors.nucleus).Y, (spec.organelleAnchors.entryLookTarget or spec.organelleAnchors.nucleus).Z))
        :gsub("__CYTOPLASM_CENTER__", string.format("%0.1f, %0.1f, %0.1f", spec.worldCenter.X, spec.worldCenter.Y, spec.worldCenter.Z))
        :gsub(
            "__CYTOPLASM_RADII__",
            string.format(
                "%0.1f, %0.1f, %0.1f",
                spec.cytoplasmRadius * spec.ellipsoidScale.X,
                spec.cytoplasmRadius * spec.ellipsoidScale.Y,
                spec.cytoplasmRadius * spec.ellipsoidScale.Z
            )
        )

    local localScript = starterPlayerScripts:FindFirstChild("CellPlayerBootstrap") or Instance.new("LocalScript")
    localScript.Name = "CellPlayerBootstrap"
    localScript.Source = scriptSource
    localScript.Parent = starterPlayerScripts

    return nil, {}
end

return PlayerBootstrap
