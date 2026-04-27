local ExplorerSubmarine = {}

local function weldPart(root, part)
	local weld = Instance.new("WeldConstraint")
	weld.Name = part.Name .. "_Weld"
	weld.Part0 = root
	weld.Part1 = part
	weld.Parent = part
	return weld
end

local function attachScript(parent, name, source)
	local script = Instance.new("Script")
	script.Name = name
	script.Parent = parent

	local ok = pcall(function()
		script.Source = source
	end)

	if not ok then
		local fallback = Instance.new("StringValue")
		fallback.Name = name .. "_Source"
		fallback.Value = source
		fallback.Parent = script
	end

	return script
end

local function compose(baseCFrame, offset, angles)
	angles = angles or Vector3.zero
	return baseCFrame
		* CFrame.new(offset)
		* CFrame.Angles(math.rad(angles.X), math.rad(angles.Y), math.rad(angles.Z))
end

function ExplorerSubmarine.build(parent, utils, spec)
	local palette = spec.palette
	local playerStart = spec.organelleAnchors.playerStart or Vector3.new()
	local entryTarget = spec.organelleAnchors.entryLookTarget or spec.organelleAnchors.nucleus or Vector3.new(0, playerStart.Y, 0)
	local spawnPosition = playerStart + Vector3.new(0, -6.8, -12)
	local flatTarget = Vector3.new(entryTarget.X, spawnPosition.Y, entryTarget.Z)
	if (flatTarget - spawnPosition).Magnitude < 1 then
		flatTarget = spawnPosition + Vector3.new(0, 0, -1)
	end
	local craftCFrame = CFrame.lookAt(spawnPosition, flatTarget, Vector3.yAxis)

	local model = utils.model(parent, "ExplorerSubmarine")
	model:SetAttribute("ExplorerCraft", true)

	local core = utils.part(model, "Core", {
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(13.5, 7.6, 26.5),
		CFrame = craftCFrame,
		Color = Color3.fromRGB(18, 24, 34),
		Material = Enum.Material.SmoothPlastic,
		Anchored = false,
		CanCollide = true,
		CastShadow = true,
	})
	model.PrimaryPart = core

	local shell = utils.part(model, "Shell", {
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(14.6, 8.5, 28.4),
		CFrame = craftCFrame,
		Color = Color3.fromRGB(123, 200, 224),
		Transparency = 0.74,
		Material = Enum.Material.Glass,
		CanCollide = false,
		CastShadow = false,
	})

	local canopy = utils.part(model, "ObservationCanopy", {
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(9.8, 5.4, 14.2),
		CFrame = compose(craftCFrame, Vector3.new(0, 1.1, -3.8)),
		Color = Color3.fromRGB(171, 221, 239),
		Transparency = 0.58,
		Material = Enum.Material.Glass,
		CanCollide = false,
		CastShadow = false,
	})

	local nose = utils.part(model, "NoseCone", {
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(7.6, 4.8, 9.2),
		CFrame = compose(craftCFrame, Vector3.new(0, 0.15, -8.6)),
		Color = Color3.fromRGB(220, 229, 238),
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
	})

	local dorsalSpine = utils.part(model, "DorsalSpine", {
		Size = Vector3.new(1.2, 1.1, 15.0),
		CFrame = compose(craftCFrame, Vector3.new(0, 2.95, 0.8)),
		Color = Color3.fromRGB(42, 56, 76),
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
	})
	local ventralKeel = utils.part(model, "VentralKeel", {
		Size = Vector3.new(1.0, 1.0, 13.5),
		CFrame = compose(craftCFrame, Vector3.new(0, -2.7, 1.8)),
		Color = Color3.fromRGB(30, 42, 60),
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
	})

	local frameLeft = utils.part(model, "FrameLeft", {
		Size = Vector3.new(0.7, 2.2, 18.4),
		CFrame = compose(craftCFrame, Vector3.new(-4.6, 0.2, -0.2), Vector3.new(0, 0, 12)),
		Color = Color3.fromRGB(44, 60, 82),
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
	})
	local frameRight = utils.part(model, "FrameRight", {
		Size = Vector3.new(0.7, 2.2, 18.4),
		CFrame = compose(craftCFrame, Vector3.new(4.6, 0.2, -0.2), Vector3.new(0, 0, -12)),
		Color = Color3.fromRGB(44, 60, 82),
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
	})

	local portNacelle = utils.part(model, "PortNacelle", {
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(3.2, 4.1, 10.6),
		CFrame = compose(craftCFrame, Vector3.new(-6.3, -0.25, 6.3), Vector3.new(0, 4, 0)),
		Color = Color3.fromRGB(24, 34, 48),
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
	})
	local starboardNacelle = utils.part(model, "StarboardNacelle", {
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(3.2, 4.1, 10.6),
		CFrame = compose(craftCFrame, Vector3.new(6.3, -0.25, 6.3), Vector3.new(0, -4, 0)),
		Color = Color3.fromRGB(24, 34, 48),
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
	})

	local rear = utils.part(model, "EnginePod", {
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(6.8, 4.6, 8.4),
		CFrame = compose(craftCFrame, Vector3.new(0, 0.0, 9.2)),
		Color = Color3.fromRGB(21, 31, 47),
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
	})

	local rearGlow = utils.part(model, "EngineGlow", {
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(1.8, 1.8, 2.2),
		CFrame = compose(craftCFrame, Vector3.new(0, 0.0, 12.1)),
		Color = Color3.fromRGB(138, 209, 232),
		Transparency = 0.38,
		Material = Enum.Material.Neon,
		CanCollide = false,
		CastShadow = false,
	})
	utils.addPointLight(rearGlow, Color3.fromRGB(138, 209, 232), 0.16, 7)

	local nacelleGlowLeft = utils.part(model, "PortGlow", {
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(1.2, 1.2, 1.6),
		CFrame = compose(craftCFrame, Vector3.new(-6.3, -0.2, 10.4)),
		Color = Color3.fromRGB(124, 193, 223),
		Transparency = 0.48,
		Material = Enum.Material.Neon,
		CanCollide = false,
		CastShadow = false,
	})
	local nacelleGlowRight = utils.part(model, "StarboardGlow", {
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(1.2, 1.2, 1.6),
		CFrame = compose(craftCFrame, Vector3.new(6.3, -0.2, 10.4)),
		Color = Color3.fromRGB(124, 193, 223),
		Transparency = 0.48,
		Material = Enum.Material.Neon,
		CanCollide = false,
		CastShadow = false,
	})

	local finLeft = utils.part(model, "FinLeft", {
		Size = Vector3.new(0.45, 4.8, 10.2),
		CFrame = compose(craftCFrame, Vector3.new(-7.5, -0.9, 2.4), Vector3.new(0, 0, 24)),
		Color = Color3.fromRGB(40, 58, 82),
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
	})
	local finRight = utils.part(model, "FinRight", {
		Size = Vector3.new(0.45, 4.8, 10.2),
		CFrame = compose(craftCFrame, Vector3.new(7.5, -0.9, 2.4), Vector3.new(0, 0, -24)),
		Color = Color3.fromRGB(40, 58, 82),
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
	})
	local finTop = utils.part(model, "FinTop", {
		Size = Vector3.new(0.45, 4.4, 7.8),
		CFrame = compose(craftCFrame, Vector3.new(0, 4.0, 4.4), Vector3.new(24, 0, 0)),
		Color = Color3.fromRGB(40, 58, 82),
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
	})

	local cockpit = utils.part(model, "Cockpit", {
		Size = Vector3.new(5.2, 2.7, 6.0),
		CFrame = compose(craftCFrame, Vector3.new(0, 0.4, -1.4)),
		Color = Color3.fromRGB(20, 28, 39),
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
	})

	local boardingPrompt = Instance.new("ProximityPrompt")
	boardingPrompt.Name = "BoardPrompt"
	boardingPrompt.ActionText = "Board"
	boardingPrompt.ObjectText = "Explorer Capsule"
	boardingPrompt.KeyboardKeyCode = Enum.KeyCode.E
	boardingPrompt.HoldDuration = 0
	boardingPrompt.MaxActivationDistance = 18
	boardingPrompt.RequiresLineOfSight = false
	boardingPrompt.Parent = cockpit

	local console = utils.part(model, "Console", {
		Size = Vector3.new(4.0, 0.95, 2.1),
		CFrame = compose(craftCFrame, Vector3.new(0, -0.55, -3.7)),
		Color = Color3.fromRGB(34, 48, 69),
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
	})
	local consoleGlow = utils.part(model, "ConsoleGlow", {
		Size = Vector3.new(2.8, 0.14, 0.72),
		CFrame = compose(craftCFrame, Vector3.new(0, -0.08, -4.55)),
		Color = Color3.fromRGB(108, 188, 222),
		Material = Enum.Material.Neon,
		CanCollide = false,
		CastShadow = false,
	})
	utils.addPointLight(consoleGlow, Color3.fromRGB(108, 188, 222), 0.08, 5)

	local cabinLight = utils.part(model, "CabinLight", {
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(0.55, 0.55, 0.55),
		CFrame = compose(craftCFrame, Vector3.new(0, 1.85, -1.1)),
		Color = Color3.fromRGB(210, 236, 245),
		Material = Enum.Material.Neon,
		CanCollide = false,
		CastShadow = false,
	})
	utils.addPointLight(cabinLight, Color3.fromRGB(210, 236, 245), 0.05, 5)

	local seat = Instance.new("VehicleSeat")
	seat.Name = "PilotSeat"
	seat.Size = Vector3.new(2.2, 1.2, 2.2)
	seat.CFrame = compose(craftCFrame, Vector3.new(0, -0.85, -0.4))
	seat.Anchored = false
	seat.CanCollide = false
	seat.CanQuery = true
	seat.CanTouch = true
	seat.Material = Enum.Material.SmoothPlastic
	seat.Color = Color3.fromRGB(16, 22, 31)
	seat.Transparency = 0.08
	seat.Parent = model

	local cabinDeck = utils.part(model, "CabinDeck", {
		Size = Vector3.new(5.2, 0.28, 7.8),
		CFrame = compose(craftCFrame, Vector3.new(0, -1.25, -0.2)),
		Color = Color3.fromRGB(31, 49, 69),
		Material = Enum.Material.SmoothPlastic,
		Anchored = false,
		CanCollide = false,
	})

	local rootAttachment = Instance.new("Attachment")
	rootAttachment.Name = "DriveAttachment"
	rootAttachment.Position = Vector3.new()
	rootAttachment.Parent = core

	local driveEvent = Instance.new("RemoteEvent")
	driveEvent.Name = "DriveInput"
	driveEvent.Parent = model

	local align = Instance.new("AlignOrientation")
	align.Name = "DriveAlign"
	align.Mode = Enum.OrientationAlignmentMode.OneAttachment
	align.Attachment0 = rootAttachment
	align.Responsiveness = 16
	align.MaxTorque = math.huge
	align.RigidityEnabled = false
	align.Parent = core

	local glide = Instance.new("LinearVelocity")
	glide.Name = "DriveVelocity"
	glide.Attachment0 = rootAttachment
	glide.RelativeTo = Enum.ActuatorRelativeTo.World
	glide.MaxForce = math.huge
	glide.VectorVelocity = Vector3.zero
	glide.Parent = core

	local buoyancy = Instance.new("VectorForce")
	buoyancy.Name = "BuoyancyForce"
	buoyancy.Attachment0 = rootAttachment
	buoyancy.RelativeTo = Enum.ActuatorRelativeTo.World
	buoyancy.ApplyAtCenterOfMass = true
	buoyancy.Force = Vector3.zero
	buoyancy.Parent = core

	for _, part in ipairs({
		shell,
		canopy,
		nose,
		dorsalSpine,
		ventralKeel,
		frameLeft,
		frameRight,
		portNacelle,
		starboardNacelle,
		rear,
		rearGlow,
		nacelleGlowLeft,
		nacelleGlowRight,
		finLeft,
		finRight,
		finTop,
		cockpit,
		console,
		consoleGlow,
		cabinLight,
		cabinDeck,
		seat,
	}) do
		part.Anchored = false
		weldPart(core, part)
	end

	local hint = utils.billboard(model, "ControlHint", cockpit, "Explorer Capsule", "Board the sub. W/S thrust, A/D turn, R or Space rise, F or Shift sink.")
	hint.StudsOffsetWorldSpace = Vector3.new(0, 7.5, 0)
	hint.MaxDistance = 84

	attachScript(model, "BoardCapsule", [[
local model = script.Parent
local seat = model:WaitForChild("PilotSeat")
local prompt = model:WaitForChild("Cockpit"):WaitForChild("BoardPrompt")

prompt.Triggered:Connect(function(player)
	local character = player.Character
	if not character then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then
		return
	end

	root.CFrame = seat.CFrame + seat.CFrame.UpVector * 2.4
	task.wait()
	seat:Sit(humanoid)
end)
]])

	attachScript(model, "ExplorerDrive", [[
local model = script.Parent
local seat = model:WaitForChild("PilotSeat")
local core = model:WaitForChild("Core")
local align = core:WaitForChild("DriveAlign")
local glide = core:WaitForChild("DriveVelocity")
local buoyancy = core:WaitForChild("BuoyancyForce")
local driveEvent = model:WaitForChild("DriveInput")

local players = game:GetService("Players")
local runService = game:GetService("RunService")

local yaw = select(2, core.CFrame:ToOrientation())
	local turnRate = math.rad(96)
	local cruiseSpeed = 28
	local verticalSpeed = 42
	local idleDamp = 0.95
	local buoyancyScale = 1.0
local touchThrottle = 0
local touchSteer = 0
local touchLift = 0

driveEvent.OnServerEvent:Connect(function(player, payload)
	if typeof(payload) ~= "table" then
		return
	end

	local occupant = seat.Occupant
	if not occupant then
		return
	end

	local occupantPlayer = players:GetPlayerFromCharacter(occupant.Parent)
	if occupantPlayer ~= player then
		return
	end

	touchThrottle = math.clamp(tonumber(payload.throttle) or 0, -1, 1)
	touchSteer = math.clamp(tonumber(payload.steer) or 0, -1, 1)
	touchLift = math.clamp(tonumber(payload.lift) or 0, -1, 1)
end)

seat:GetPropertyChangedSignal("Occupant"):Connect(function()
	local occupant = seat.Occupant
	if not occupant then
		pcall(function()
			core:SetNetworkOwnershipAuto()
		end)
		touchThrottle = 0
		touchSteer = 0
		touchLift = 0
		return
	end

	local occupantPlayer = players:GetPlayerFromCharacter(occupant.Parent)
	if occupantPlayer then
		pcall(function()
			core:SetNetworkOwner(occupantPlayer)
		end)
	end
end)

runService.Heartbeat:Connect(function(dt)
	if not model.Parent then
		return
	end

	local throttle = 0
	local steer = 0
	local lift = 0
	local occupant = seat.Occupant
	if occupant then
		throttle = math.abs(touchThrottle) > 0.01 and touchThrottle or seat.ThrottleFloat
		steer = math.abs(touchSteer) > 0.01 and touchSteer or seat.SteerFloat
		lift = touchLift
	end

	yaw += steer * turnRate * dt
	local target = CFrame.new(core.Position) * CFrame.Angles(0, yaw, 0)
	align.CFrame = target
		local desiredHorizontal = target.LookVector * (throttle * cruiseSpeed)
		local currentVelocity = glide.VectorVelocity
		local horizontalVelocity = Vector3.new(currentVelocity.X, 0, currentVelocity.Z)
		local smoothedHorizontal = horizontalVelocity:Lerp(
			Vector3.new(desiredHorizontal.X, 0, desiredHorizontal.Z),
			math.clamp(dt * 4.8, 0, 1)
		)
		local desiredVertical = lift * verticalSpeed
		local smoothedVertical = currentVelocity.Y + (desiredVertical - currentVelocity.Y) * math.clamp(dt * 7.2, 0, 1)
		glide.VectorVelocity = Vector3.new(smoothedHorizontal.X, smoothedVertical, smoothedHorizontal.Z)
		buoyancy.Force = Vector3.new(0, core.AssemblyMass * workspace.Gravity * buoyancyScale, 0)

	if not occupant then
		glide.VectorVelocity *= idleDamp
	end
end)
]])

		local hotspots = {
			{
				id = "explorer-capsule",
				title = "Explorer Capsule",
				body = "A survey capsule built to drift through cytoplasm and inspect organelles up close with full 3-axis flight controls.",
				position = spawnPosition + Vector3.new(-18, 7, 10),
				labelDistance = 12,
				showLabel = false,
			},
			{
				id = "helm-controls",
				title = "Helm Controls",
				body = "Board the capsule to pilot it. Touch controls handle thrust, turn, rise, and sink while seated.",
				position = spawnPosition + Vector3.new(18, 6.5, -4),
				labelDistance = 10,
				showLabel = false,
			},
		}

	return model, hotspots
end

return ExplorerSubmarine
