local ExplorerControls = {}

function ExplorerControls.build(_, _, spec)
    local starterPlayer = game:GetService("StarterPlayer")
    local starterPlayerScripts = starterPlayer:WaitForChild("StarterPlayerScripts")

    local template = [[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local ROOT_NAME = "__ROOT_NAME__"
local localPlayer = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ExplorerDriveUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

local touchPanel = Instance.new("Frame")
touchPanel.Name = "TouchPanel"
touchPanel.AnchorPoint = Vector2.new(1, 1)
touchPanel.Position = UDim2.new(1, -26, 1, -28)
touchPanel.Size = UDim2.fromOffset(264, 188)
touchPanel.BackgroundTransparency = 1
touchPanel.Visible = false
touchPanel.Parent = screenGui

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(20, 0)
title.Size = UDim2.fromOffset(220, 24)
title.Font = Enum.Font.GothamMedium
title.Text = "Explorer Controls"
title.TextColor3 = Color3.fromRGB(214, 236, 244)
title.TextSize = 16
title.Parent = touchPanel

local keyboardHint = Instance.new("TextLabel")
keyboardHint.Name = "KeyboardHint"
keyboardHint.AnchorPoint = Vector2.new(0.5, 1)
keyboardHint.Position = UDim2.new(0.5, 0, 1, -26)
keyboardHint.Size = UDim2.fromOffset(340, 34)
keyboardHint.BackgroundColor3 = Color3.fromRGB(10, 24, 36)
keyboardHint.BackgroundTransparency = 0.24
keyboardHint.BorderSizePixel = 0
keyboardHint.Font = Enum.Font.GothamMedium
keyboardHint.Text = "W/S thrust   A/D turn   R or Space rise   F or Shift sink"
keyboardHint.TextColor3 = Color3.fromRGB(224, 241, 248)
keyboardHint.TextSize = 15
keyboardHint.Visible = false
keyboardHint.Parent = screenGui

local keyboardCorner = Instance.new("UICorner")
keyboardCorner.CornerRadius = UDim.new(0, 10)
keyboardCorner.Parent = keyboardHint

local function makeButton(name, text, position, size)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Position = position
    button.Size = size
    button.AutoButtonColor = false
    button.BackgroundColor3 = Color3.fromRGB(18, 42, 58)
    button.BackgroundTransparency = 0.16
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.TextColor3 = Color3.fromRGB(232, 245, 251)
    button.TextSize = 16
    button.Parent = touchPanel

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button

    return button
end

local buttonForward = makeButton("Forward", "Fwd", UDim2.fromOffset(88, 38), UDim2.fromOffset(70, 48))
local buttonReverse = makeButton("Reverse", "Rev", UDim2.fromOffset(88, 132), UDim2.fromOffset(70, 48))
local buttonLeft = makeButton("Left", "Left", UDim2.fromOffset(10, 86), UDim2.fromOffset(70, 48))
local buttonRight = makeButton("Right", "Right", UDim2.fromOffset(166, 86), UDim2.fromOffset(70, 48))
local buttonRise = makeButton("Rise", "Rise", UDim2.fromOffset(184, 24), UDim2.fromOffset(64, 42))
local buttonSink = makeButton("Sink", "Sink", UDim2.fromOffset(184, 138), UDim2.fromOffset(64, 42))

local function getCraft()
    local root = Workspace:FindFirstChild(ROOT_NAME)
    local generated = root and root:FindFirstChild("GeneratedModels")
    local craft = generated and generated:FindFirstChild("ExplorerSubmarine")
    if not craft then
        return nil
    end
    return craft, craft:FindFirstChild("PilotSeat"), craft:FindFirstChild("DriveInput")
end

local state = {
    throttle = 0,
    steer = 0,
    lift = 0,
}

local function setButtonActive(button, active)
    button.BackgroundColor3 = active and Color3.fromRGB(46, 104, 128) or Color3.fromRGB(18, 42, 58)
end

local function bindHold(button, field, value)
    local function begin()
        state[field] = value
        setButtonActive(button, true)
    end

    local function finish()
        if state[field] == value then
            state[field] = 0
        end
        setButtonActive(button, false)
    end

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            begin()
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            finish()
        end
    end)
end

bindHold(buttonForward, "throttle", 1)
bindHold(buttonReverse, "throttle", -1)
bindHold(buttonLeft, "steer", -1)
bindHold(buttonRight, "steer", 1)
bindHold(buttonRise, "lift", 1)
bindHold(buttonSink, "lift", -1)

local lastPayload = ""

local function currentCharacterHumanoid()
    local character = localPlayer.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

RunService.RenderStepped:Connect(function()
    local craft, seat, driveEvent = getCraft()
    local humanoid = currentCharacterHumanoid()
    local seatedInCraft = humanoid and seat and humanoid.SeatPart == seat

    touchPanel.Visible = seatedInCraft and UserInputService.TouchEnabled
    keyboardHint.Visible = seatedInCraft and UserInputService.KeyboardEnabled

    if not seatedInCraft or not driveEvent then
        state.throttle = 0
        state.steer = 0
        state.lift = 0
        keyboardHint.Visible = false
        for _, button in ipairs({ buttonForward, buttonReverse, buttonLeft, buttonRight, buttonRise, buttonSink }) do
            setButtonActive(button, false)
        end
        local payload = "0|0|0"
        if payload ~= lastPayload and driveEvent then
            driveEvent:FireServer({ throttle = 0, steer = 0, lift = 0 })
            lastPayload = payload
        end
        return
    end

    local keyboardLift = 0
    if UserInputService.KeyboardEnabled then
        if UserInputService:IsKeyDown(Enum.KeyCode.R) or UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            keyboardLift += 1
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.F)
            or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
            or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
            or UserInputService:IsKeyDown(Enum.KeyCode.Q)
        then
            keyboardLift -= 1
        end
    end

    local effectiveLift = math.clamp(state.lift + keyboardLift, -1, 1)

    local payload = string.format("%.2f|%.2f|%.2f", state.throttle, state.steer, effectiveLift)
    if payload ~= lastPayload then
        driveEvent:FireServer({
            throttle = state.throttle,
            steer = state.steer,
            lift = effectiveLift,
        })
        lastPayload = payload
    end
end)
]]

    local scriptSource = template:gsub("__ROOT_NAME__", spec.rootName)

    local localScript = starterPlayerScripts:FindFirstChild("ExplorerControls") or Instance.new("LocalScript")
    localScript.Name = "ExplorerControls"
    localScript.Source = scriptSource
    localScript.Parent = starterPlayerScripts

    return nil, {}
end

return ExplorerControls
