--[[
AnimalCellVillageBuilder.server.lua
Creates a village-scale, explorable animal-cell model in Roblox Studio.

How to use:
1. In Roblox Studio, create a new Script in ServerScriptService.
2. Paste this file into it and press Play, or run it from the Command Bar in Studio.
3. The script creates Workspace.AnimalCellVillage_Model with nested models for each organelle.
4. Keep the script enabled if you want the vesicle/cytoplasm animations. Disable it after generation if you only want a static model.

Design goal: not a tiny textbook diagram. This is a walkable cell interior roughly the size of a small Roblox village.
]]

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local CONFIG = {
	ModelName = "AnimalCellVillage_Model",
	RebuildExisting = true,
	Seed = 1729,
	CellRadius = 600,
	CellCenter = Vector3.new(0, 95, 0),
	EnableLabels = true,
	EnableAnimations = true,
	SpawnPlayersInsideCell = true,
	LabelMaxDistance = 1350,
}

math.randomseed(CONFIG.Seed)

local COLORS = {
	MembraneOuter = Color3.fromRGB(255, 168, 82),
	MembraneInner = Color3.fromRGB(255, 206, 126),
	Cytoplasm = Color3.fromRGB(255, 147, 51),
	CytoplasmParticle = Color3.fromRGB(255, 197, 112),
	Cytoskeleton = Color3.fromRGB(98, 217, 236),
	Microtubule = Color3.fromRGB(109, 171, 255),
	NuclearEnvelope = Color3.fromRGB(255, 188, 133),
	Nucleoplasm = Color3.fromRGB(255, 123, 50),
	Nucleolus = Color3.fromRGB(196, 37, 49),
	Chromatin = Color3.fromRGB(121, 38, 79),
	NuclearPore = Color3.fromRGB(112, 91, 80),
	RoughER = Color3.fromRGB(229, 90, 62),
	SmoothER = Color3.fromRGB(255, 125, 55),
	Ribosome = Color3.fromRGB(82, 56, 156),
	Golgi = Color3.fromRGB(176, 60, 142),
	GolgiEdge = Color3.fromRGB(255, 151, 210),
	Vesicle = Color3.fromRGB(188, 92, 210),
	MitoOuter = Color3.fromRGB(63, 142, 220),
	MitoInner = Color3.fromRGB(96, 198, 255),
	MitoCristae = Color3.fromRGB(18, 78, 151),
	Lysosome = Color3.fromRGB(210, 106, 151),
	Peroxisome = Color3.fromRGB(97, 176, 85),
	PeroxisomeCore = Color3.fromRGB(226, 241, 94),
	CentrosomeCloud = Color3.fromRGB(250, 212, 139),
	Centriole = Color3.fromRGB(237, 239, 231),
	Cilium = Color3.fromRGB(253, 196, 128),
	CiliumFiber = Color3.fromRGB(255, 241, 170),
	Path = Color3.fromRGB(225, 234, 255),
	Panel = Color3.fromRGB(28, 34, 45),
	PanelText = Color3.fromRGB(245, 250, 255),
}

local old = Workspace:FindFirstChild(CONFIG.ModelName)
if old and CONFIG.RebuildExisting then
	old:Destroy()
end

local root = Instance.new("Model")
root.Name = CONFIG.ModelName
root.Parent = Workspace

local folders = {}
local function folder(name: string, parent: Instance?): Folder
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent or root
	folders[name] = f
	return f
end

local F = {
	Shell = folder("01_Cell_shell_and_cytoplasm"),
	Navigation = folder("02_Player_navigation_and_scale_guides"),
	Nucleus = folder("03_Nucleus_complex"),
	ER = folder("04_Endoplasmic_reticulum"),
	Golgi = folder("05_Golgi_and_secretory_pathway"),
	Mito = folder("06_Mitochondria"),
	LysPerox = folder("07_Lysosomes_and_peroxisomes"),
	Centrosome = folder("08_Centrosome_centrioles_and_microtubules"),
	Cilium = folder("09_Cilium_and_basal_body"),
	Ribosomes = folder("10_Free_ribosomes"),
	Labels = folder("99_Labels_and_info_panels"),
}

local animatedPulsers = {}
local animatedSpinners = {}
local animatedMovers = {}

local function clamp01(x: number): number
	if x < 0 then return 0 end
	if x > 1 then return 1 end
	return x
end

local function smoothStep(t: number): number
	t = clamp01(t)
	return t * t * (3 - 2 * t)
end

local function safeUnit(v: Vector3, fallback: Vector3?): Vector3
	if v.Magnitude < 0.001 then
		return fallback or Vector3.yAxis
	end
	return v.Unit
end

local function basisFromY(yAxis: Vector3)
	local up = safeUnit(yAxis, Vector3.yAxis)
	local reference = math.abs(up:Dot(Vector3.yAxis)) > 0.96 and Vector3.xAxis or Vector3.yAxis
	local right = safeUnit(reference:Cross(up), Vector3.xAxis)
	local back = safeUnit(right:Cross(up), Vector3.zAxis)
	return right, up, back
end

local function basisFromZ(zAxis: Vector3)
	local back = safeUnit(zAxis, Vector3.zAxis)
	local reference = math.abs(back:Dot(Vector3.yAxis)) > 0.96 and Vector3.xAxis or Vector3.yAxis
	local right = safeUnit(reference:Cross(back), Vector3.xAxis)
	local up = safeUnit(back:Cross(right), Vector3.yAxis)
	return right, up, back
end

local function cfFromY(pos: Vector3, yAxis: Vector3): CFrame
	local right, up, back = basisFromY(yAxis)
	return CFrame.fromMatrix(pos, right, up, back)
end

local function cfFromZ(pos: Vector3, zAxis: Vector3, roll: number?): CFrame
	local right, up, back = basisFromZ(zAxis)
	local cf = CFrame.fromMatrix(pos, right, up, back)
	if roll and roll ~= 0 then
		cf = cf * CFrame.Angles(0, 0, roll)
	end
	return cf
end

local function createModel(name: string, parent: Instance?): Model
	local m = Instance.new("Model")
	m.Name = name
	m.Parent = parent or root
	return m
end

local function createPart(args): BasePart
	local p = Instance.new("Part")
	p.Name = args.Name or "Part"
	p.Shape = args.Shape or Enum.PartType.Block
	p.Size = args.Size or Vector3.new(4, 4, 4)
	p.CFrame = args.CFrame or CFrame.new()
	p.Color = args.Color or Color3.new(1, 1, 1)
	p.Material = args.Material or Enum.Material.SmoothPlastic
	p.Transparency = args.Transparency or 0
	p.Anchored = if args.Anchored == nil then true else args.Anchored
	p.CanCollide = args.CanCollide == true
	p.CanQuery = if args.CanQuery == nil then true else args.CanQuery
	p.CanTouch = if args.CanTouch == nil then false else args.CanTouch
	p.CastShadow = if args.CastShadow == nil then false else args.CastShadow
	p.Parent = args.Parent or root
	if args.Tag then
		CollectionService:AddTag(p, args.Tag)
	end
	return p
end

local function createSphere(name: string, parent: Instance, pos: Vector3, size: Vector3, color: Color3, material: Enum.Material?, transparency: number?, collide: boolean?): BasePart
	return createPart({
		Name = name,
		Parent = parent,
		Shape = Enum.PartType.Ball,
		Size = size,
		CFrame = CFrame.new(pos),
		Color = color,
		Material = material or Enum.Material.SmoothPlastic,
		Transparency = transparency or 0,
		CanCollide = collide == true,
	})
end

local function createTube(name: string, parent: Instance, a: Vector3, b: Vector3, radius: number, color: Color3, material: Enum.Material?, transparency: number?, collide: boolean?): BasePart?
	local axis = b - a
	local length = axis.Magnitude
	if length < 0.05 then return nil end
	return createPart({
		Name = name,
		Parent = parent,
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(radius * 2, length, radius * 2),
		CFrame = cfFromY((a + b) * 0.5, axis),
		Color = color,
		Material = material or Enum.Material.SmoothPlastic,
		Transparency = transparency or 0,
		CanCollide = collide == true,
	})
end

local function createBlockBetween(name: string, parent: Instance, a: Vector3, b: Vector3, width: number, thickness: number, color: Color3, material: Enum.Material?, transparency: number?, collide: boolean?, roll: number?): BasePart?
	local axis = b - a
	local length = axis.Magnitude
	if length < 0.05 then return nil end
	return createPart({
		Name = name,
		Parent = parent,
		Shape = Enum.PartType.Block,
		Size = Vector3.new(width, thickness, length),
		CFrame = cfFromZ((a + b) * 0.5, axis, roll or 0),
		Color = color,
		Material = material or Enum.Material.SmoothPlastic,
		Transparency = transparency or 0,
		CanCollide = collide == true,
	})
end

local function addHighlight(model: Instance, color: Color3, outline: Color3?)
	local h = Instance.new("Highlight")
	h.Name = "Soft_readability_highlight"
	h.FillColor = color
	h.OutlineColor = outline or color
	h.FillTransparency = 0.92
	h.OutlineTransparency = 0.55
	h.DepthMode = Enum.HighlightDepthMode.Occluded
	h.Parent = model
	return h
end

local function createLabel(name: string, pos: Vector3, title: string, body: string, color: Color3?)
	if not CONFIG.EnableLabels then return end
	local anchor = createPart({
		Name = name .. "_LabelAnchor",
		Parent = F.Labels,
		Size = Vector3.new(2, 2, 2),
		CFrame = CFrame.new(pos),
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
	})
	local gui = Instance.new("BillboardGui")
	gui.Name = name .. "_Billboard"
	gui.AlwaysOnTop = true
	gui.LightInfluence = 0
	gui.MaxDistance = CONFIG.LabelMaxDistance
	gui.Size = UDim2.new(0, 360, 0, 120)
	gui.StudsOffset = Vector3.new(0, 4, 0)
	gui.Parent = anchor

	local frame = Instance.new("Frame")
	frame.Name = "Panel"
	frame.BackgroundColor3 = color or COLORS.Panel
	frame.BackgroundTransparency = 0.12
	frame.BorderSizePixel = 0
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 2
	stroke.Transparency = 0.35
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Parent = frame

	local text = Instance.new("TextLabel")
	text.Name = "Text"
	text.BackgroundTransparency = 1
	text.Size = UDim2.new(1, -18, 1, -14)
	text.Position = UDim2.new(0, 9, 0, 7)
	text.Font = Enum.Font.Gotham
	text.TextColor3 = COLORS.PanelText
	text.TextWrapped = true
	text.TextScaled = true
	text.RichText = true
	text.Text = "<b>" .. title .. "</b>\n" .. body
	text.Parent = frame
end

local function createStationPanel(name: string, cf: CFrame, title: string, body: string, color: Color3?)
	local panel = createPart({
		Name = name,
		Parent = F.Navigation,
		Shape = Enum.PartType.Block,
		Size = Vector3.new(82, 46, 5),
		CFrame = cf,
		Color = color or COLORS.Panel,
		Material = Enum.Material.SmoothPlastic,
		Transparency = 0,
		CanCollide = true,
		CanTouch = true,
	})
	local gui = Instance.new("SurfaceGui")
	gui.Name = "ReadableSurface"
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 18
	gui.LightInfluence = 0
	gui.Parent = panel

	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = color or COLORS.Panel
	frame.BackgroundTransparency = 0.03
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BorderSizePixel = 0
	frame.Parent = gui

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, -20, 0, 72)
	titleLabel.Position = UDim2.new(0, 10, 0, 6)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextColor3 = COLORS.PanelText
	titleLabel.TextScaled = true
	titleLabel.TextWrapped = true
	titleLabel.Text = title
	titleLabel.Parent = frame

	local bodyLabel = Instance.new("TextLabel")
	bodyLabel.BackgroundTransparency = 1
	bodyLabel.Size = UDim2.new(1, -20, 1, -84)
	bodyLabel.Position = UDim2.new(0, 10, 0, 80)
	bodyLabel.Font = Enum.Font.Gotham
	bodyLabel.TextColor3 = COLORS.PanelText
	bodyLabel.TextScaled = true
	bodyLabel.TextWrapped = true
	bodyLabel.TextYAlignment = Enum.TextYAlignment.Top
	bodyLabel.Text = body
	bodyLabel.Parent = frame
	return panel
end

local function createPath(name: string, a: Vector3, b: Vector3, width: number?)
	return createBlockBetween(name, F.Navigation, a, b, width or 30, 5, COLORS.Path, Enum.Material.Glass, 0.48, true)
end

local function makeRibosome(parent: Instance, name: string, pos: Vector3, scale: number, tint: Color3?)
	local m = createModel(name, parent)
	local c = tint or COLORS.Ribosome
	local large = createSphere("large_subunit", m, pos + Vector3.new(0, scale * 0.9, 0), Vector3.new(scale * 2.4, scale * 1.4, scale * 2.0), c, Enum.Material.SmoothPlastic, 0, false)
	local small = createSphere("small_subunit", m, pos + Vector3.new(scale * 0.85, -scale * 0.35, 0), Vector3.new(scale * 1.45, scale * 0.9, scale * 1.35), c:Lerp(Color3.new(1, 1, 1), 0.18), Enum.Material.SmoothPlastic, 0, false)
	table.insert(animatedSpinners, {Part = large, Speed = 0.12 + math.random() * 0.05})
	table.insert(animatedSpinners, {Part = small, Speed = -0.10 - math.random() * 0.05})
	return m
end

local function makeBumpyOrb(parent: Instance, name: string, center: Vector3, radius: number, color: Color3, bumpColor: Color3?, bumpCount: number)
	local m = createModel(name, parent)
	local core = createSphere("main_mass", m, center, Vector3.new(radius * 2, radius * 2, radius * 2), color, Enum.Material.SmoothPlastic, 0, false)
	table.insert(animatedPulsers, {Part = core, BaseTransparency = 0, Amplitude = 0.10, Speed = 0.9, Phase = math.random() * 10})
	for i = 1, bumpCount do
		local theta = math.random() * math.pi * 2
		local z = math.random() * 2 - 1
		local r = math.sqrt(1 - z * z)
		local normal = Vector3.new(math.cos(theta) * r, z, math.sin(theta) * r)
		local bumpSize = radius * (0.18 + math.random() * 0.11)
		createSphere("surface_lobule_" .. i, m, center + normal * radius * 0.92, Vector3.new(bumpSize * 1.25, bumpSize, bumpSize * 1.25), bumpColor or color:Lerp(Color3.new(1, 1, 1), 0.12), Enum.Material.SmoothPlastic, 0.04, false)
	end
	return m
end

local function makeRibbon(parent: Instance, name: string, points: {Vector3}, width: number, thickness: number, color: Color3, material: Enum.Material?, transparency: number?, collide: boolean?, rollNoise: number?)
	local m = createModel(name, parent)
	for i = 1, #points - 1 do
		local roll = rollNoise and math.sin(i * 1.7) * rollNoise or 0
		createBlockBetween("cisterna_or_sheet_segment_" .. i, m, points[i], points[i + 1], width, thickness, color, material or Enum.Material.SmoothPlastic, transparency or 0, collide == true, roll)
	end
	return m
end

local function makeTubePath(parent: Instance, name: string, points: {Vector3}, radius: number, color: Color3, material: Enum.Material?, transparency: number?, collide: boolean?)
	local m = createModel(name, parent)
	for i = 1, #points - 1 do
		createTube("tube_segment_" .. i, m, points[i], points[i + 1], radius, color, material or Enum.Material.SmoothPlastic, transparency or 0, collide == true)
	end
	return m
end

local function samplePolyline(points: {Vector3}, alpha: number): Vector3
	if #points == 0 then return Vector3.zero end
	if #points == 1 then return points[1] end
	local n = #points - 1
	local x = (alpha % 1) * n
	local i = math.floor(x) + 1
	if i > n then i = n end
	local t = smoothStep(x - (i - 1))
	return points[i]:Lerp(points[i + 1], t)
end

local function addMovingSphere(name: string, parent: Instance, pathPoints: {Vector3}, radius: number, color: Color3, speed: number, phase: number)
	local p = createSphere(name, parent, pathPoints[1], Vector3.new(radius * 2, radius * 2, radius * 2), color, Enum.Material.Neon, 0.12, false)
	table.insert(animatedMovers, {Part = p, Points = pathPoints, Speed = speed, Phase = phase})
	return p
end

local function addPoreRing(parent: Instance, name: string, center: Vector3, normal: Vector3, radius: number, subunitRadius: number)
	local m = createModel(name, parent)
	local up = safeUnit(normal, Vector3.yAxis)
	local reference = math.abs(up:Dot(Vector3.yAxis)) > 0.96 and Vector3.xAxis or Vector3.yAxis
	local right = safeUnit(reference:Cross(up), Vector3.xAxis)
	local forward = safeUnit(up:Cross(right), Vector3.zAxis)
	for i = 1, 12 do
		local a = (i / 12) * math.pi * 2
		local p = center + right * math.cos(a) * radius + forward * math.sin(a) * radius
		createSphere("pore_scaffold_subunit_" .. i, m, p, Vector3.new(subunitRadius * 2, subunitRadius * 1.35, subunitRadius * 2), COLORS.NuclearPore, Enum.Material.SmoothPlastic, 0.02, false)
	end
	createSphere("central_transport_channel_visual", m, center + up * 1.2, Vector3.new(radius * 1.15, subunitRadius * 0.9, radius * 1.15), Color3.fromRGB(54, 43, 40), Enum.Material.SmoothPlastic, 0.15, false)
	return m
end

local function buildVillageNavigation()
	if CONFIG.SpawnPlayersInsideCell then
		local spawn = Instance.new("SpawnLocation")
		spawn.Name = "Player_spawn_inside_cytoplasm"
		spawn.Size = Vector3.new(16, 2, 16)
		spawn.CFrame = CFrame.new(-420, 12, 330)
		spawn.Color = Color3.fromRGB(96, 191, 255)
		spawn.Material = Enum.Material.Neon
		spawn.Transparency = 0.15
		spawn.Anchored = true
		spawn.CanCollide = true
		spawn.Parent = F.Navigation
	end

	createPart({
		Name = "transparent_main_walkable_cytoplasm_floor",
		Parent = F.Navigation,
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(1040, 6, 1040),
		CFrame = CFrame.new(CONFIG.CellCenter.X, 3, CONFIG.CellCenter.Z),
		Color = COLORS.Path,
		Material = Enum.Material.Glass,
		Transparency = 0.78,
		CanCollide = true,
		CanTouch = true,
	})

	local hub = Vector3.new(-50, 9, 20)
	local waypoints = {
		Vector3.new(-420, 9, 330),
		Vector3.new(-270, 9, -210),
		Vector3.new(255, 9, -230),
		Vector3.new(360, 9, 160),
		Vector3.new(-330, 9, 130),
		Vector3.new(80, 9, 350),
	}
	for i, p in ipairs(waypoints) do
		createPath("village_walkway_spoke_" .. i, hub, p, 28)
		createPart({
			Name = "organelle_observation_pad_" .. i,
			Parent = F.Navigation,
			Shape = Enum.PartType.Cylinder,
			Size = Vector3.new(95, 5, 95),
			CFrame = CFrame.new(p.X, p.Y + 1, p.Z),
			Color = COLORS.Path,
			Material = Enum.Material.Glass,
			Transparency = 0.47,
			CanCollide = true,
		})
	end

	createPath("sloped_walkway_into_nucleus", Vector3.new(-205, 12, 78), Vector3.new(-103, 92, 30), 26)
	createPath("sloped_walkway_to_membrane_gate", Vector3.new(260, 12, 225), Vector3.new(505, 76, 270), 28)

	createStationPanel(
		"ScaleGuide_station_at_spawn",
		CFrame.new(-445, 44, 305) * CFrame.Angles(0, math.rad(-38), 0),
		"Animal Cell Village Scale",
		"Cell radius is about 600 studs. The shell is transparent so players can navigate while still seeing the membrane boundary.",
		Color3.fromRGB(38, 43, 57)
	)
end

local function buildCellShellAndCytoplasm()
	local shell = createModel("Cell_membrane_cytoplasm_and_surface_features", F.Shell)
	local r = CONFIG.CellRadius
	local c = CONFIG.CellCenter

	local cytoplasm = createSphere("cytoplasm_translucent_volume", shell, c, Vector3.new(r * 1.90, r * 1.82, r * 1.90), COLORS.Cytoplasm, Enum.Material.Glass, 0.82, false)
	local inner = createSphere("inner_leaflet_of_cell_membrane", shell, c, Vector3.new(r * 1.96, r * 1.90, r * 1.96), COLORS.MembraneInner, Enum.Material.Glass, 0.72, false)
	local outer = createSphere("outer_leaflet_of_cell_membrane", shell, c, Vector3.new(r * 2.02, r * 1.96, r * 2.02), COLORS.MembraneOuter, Enum.Material.Glass, 0.66, false)
	addHighlight(shell, COLORS.MembraneOuter)
	table.insert(animatedPulsers, {Part = cytoplasm, BaseTransparency = 0.82, Amplitude = 0.025, Speed = 0.4, Phase = 0})
	table.insert(animatedPulsers, {Part = outer, BaseTransparency = 0.66, Amplitude = 0.02, Speed = 0.5, Phase = 2.0})

	-- Surface transport proteins and membrane pores: placed as visible ovals on the membrane boundary.
	for i = 1, 52 do
		local theta = math.random() * math.pi * 2
		local y = -0.35 + math.random() * 1.15
		local radial = math.sqrt(math.max(0, 1 - y * y))
		local normal = Vector3.new(math.cos(theta) * radial, y, math.sin(theta) * radial).Unit
		local pos = c + normal * (r * 1.01)
		local p = createSphere("membrane_channel_or_receptor_" .. i, shell, pos, Vector3.new(28 + math.random() * 10, 12 + math.random() * 7, 28 + math.random() * 10), Color3.fromRGB(120, 87, 58), Enum.Material.SmoothPlastic, 0.08, false)
		p.CFrame = cfFromY(pos, normal)
	end

	-- Local, walk-up phospholipid bilayer patch so the membrane is not just a sphere.
	local patch = createModel("walk_through_phospholipid_bilayer_patch", shell)
	local patchCF = CFrame.new(505, 118, 278) * CFrame.Angles(0, math.rad(42), 0)
	for x = -7, 7 do
		local xStud = x * 13
		local outerHead = patchCF:PointToWorldSpace(Vector3.new(xStud, 18, 0))
		local innerHead = patchCF:PointToWorldSpace(Vector3.new(xStud, -18, 0))
		createSphere("outer_hydrophilic_head_" .. x, patch, outerHead, Vector3.new(10, 10, 10), Color3.fromRGB(255, 215, 120), Enum.Material.SmoothPlastic, 0, false)
		createSphere("inner_hydrophilic_head_" .. x, patch, innerHead, Vector3.new(10, 10, 10), Color3.fromRGB(255, 215, 120), Enum.Material.SmoothPlastic, 0, false)
		createTube("fatty_acid_tail_outer_A_" .. x, patch, patchCF:PointToWorldSpace(Vector3.new(xStud - 2, 12, 0)), patchCF:PointToWorldSpace(Vector3.new(xStud - 2, 1, 0)), 2.2, Color3.fromRGB(245, 153, 66), Enum.Material.SmoothPlastic, 0, false)
		createTube("fatty_acid_tail_outer_B_" .. x, patch, patchCF:PointToWorldSpace(Vector3.new(xStud + 2, 12, 0)), patchCF:PointToWorldSpace(Vector3.new(xStud + 2, 1, 0)), 2.2, Color3.fromRGB(245, 153, 66), Enum.Material.SmoothPlastic, 0, false)
		createTube("fatty_acid_tail_inner_A_" .. x, patch, patchCF:PointToWorldSpace(Vector3.new(xStud - 2, -12, 0)), patchCF:PointToWorldSpace(Vector3.new(xStud - 2, -1, 0)), 2.2, Color3.fromRGB(245, 153, 66), Enum.Material.SmoothPlastic, 0, false)
		createTube("fatty_acid_tail_inner_B_" .. x, patch, patchCF:PointToWorldSpace(Vector3.new(xStud + 2, -12, 0)), patchCF:PointToWorldSpace(Vector3.new(xStud + 2, -1, 0)), 2.2, Color3.fromRGB(245, 153, 66), Enum.Material.SmoothPlastic, 0, false)
	end
	for i = 1, 5 do
		local x = -78 + i * 31
		local ch = createTube("transmembrane_protein_channel_" .. i, patch, patchCF:PointToWorldSpace(Vector3.new(x, -25, 0)), patchCF:PointToWorldSpace(Vector3.new(x, 25, 0)), 5.5, Color3.fromRGB(80, 149, 221), Enum.Material.Neon, 0.15, false)
		table.insert(animatedPulsers, {Part = ch, BaseTransparency = 0.15, Amplitude = 0.18, Speed = 1.0, Phase = i})
	end

	createLabel("CellMembrane", c + Vector3.new(470, 180, 345), "Cell membrane", "Outer boundary with a bilayer patch, transport channels, and receptor-like proteins.", Color3.fromRGB(91, 55, 30))
	createLabel("Cytoplasm", c + Vector3.new(-120, 80, 390), "Cytoplasm", "Transparent cytosol volume with suspended particles, vesicles, and cytoskeleton tracks.", Color3.fromRGB(92, 53, 28))

	-- Cytosol particles: visual noise, not labels.
	for i = 1, 115 do
		local theta = math.random() * math.pi * 2
		local rad = math.sqrt(math.random()) * (r * 0.82)
		local y = -55 + math.random() * 310
		local pos = Vector3.new(math.cos(theta) * rad, y, math.sin(theta) * rad) + Vector3.new(0, 30, 0)
		if (pos - Vector3.new(-55, 155, 10)).Magnitude > 230 then
			createSphere("cytosol_particle_" .. i, shell, pos, Vector3.new(5, 5, 5), COLORS.CytoplasmParticle, Enum.Material.SmoothPlastic, 0.35 + math.random() * 0.25, false)
		end
	end
end

local NUCLEUS_CENTER = Vector3.new(-70, 154, 30)
local NUCLEUS_OUTER_RADIUS = 188

local function buildNucleus()
	local nucleus = createModel("Nucleus", F.Nucleus)
	local envelope = createModel("nuclear_envelope_double_membrane", nucleus)
	local pores = createModel("nuclear_pore_complexes", nucleus)
	local chromatin = createModel("chromatin_threads_in_nucleoplasm", nucleus)

	local outer = createSphere("outer_nuclear_envelope", envelope, NUCLEUS_CENTER, Vector3.new(NUCLEUS_OUTER_RADIUS * 2, NUCLEUS_OUTER_RADIUS * 1.74, NUCLEUS_OUTER_RADIUS * 2), COLORS.NuclearEnvelope, Enum.Material.Glass, 0.48, false)
	local inner = createSphere("inner_nuclear_envelope", envelope, NUCLEUS_CENTER, Vector3.new(NUCLEUS_OUTER_RADIUS * 1.78, NUCLEUS_OUTER_RADIUS * 1.55, NUCLEUS_OUTER_RADIUS * 1.78), COLORS.NuclearEnvelope:Lerp(Color3.new(1, 1, 1), 0.12), Enum.Material.Glass, 0.63, false)
	local nucleo = createSphere("nucleoplasm_translucent_fill", nucleus, NUCLEUS_CENTER, Vector3.new(NUCLEUS_OUTER_RADIUS * 1.60, NUCLEUS_OUTER_RADIUS * 1.38, NUCLEUS_OUTER_RADIUS * 1.60), COLORS.Nucleoplasm, Enum.Material.Glass, 0.70, false)
	table.insert(animatedPulsers, {Part = nucleo, BaseTransparency = 0.70, Amplitude = 0.045, Speed = 0.35, Phase = 3.0})
	addHighlight(nucleus, COLORS.NuclearEnvelope)

	-- Walkable platform inside the nucleus.
	createPart({
		Name = "walkable_nucleoplasm_platform",
		Parent = nucleus,
		Shape = Enum.PartType.Cylinder,
		Size = Vector3.new(245, 5, 245),
		CFrame = CFrame.new(NUCLEUS_CENTER.X, 75, NUCLEUS_CENTER.Z),
		Color = Color3.fromRGB(255, 223, 186),
		Material = Enum.Material.Glass,
		Transparency = 0.54,
		CanCollide = true,
	})

	makeBumpyOrb(nucleus, "nucleolus_bumpy_rRNA_zone", NUCLEUS_CENTER + Vector3.new(18, -5, -12), 46, COLORS.Nucleolus, Color3.fromRGB(235, 76, 85), 32)

	-- Nuclear pores on the envelope. Rings are visible so players can distinguish envelope vs pore complexes.
	local poreIndex = 0
	for ring = 1, 4 do
		local yNorm = -0.55 + ring * 0.26
		local count = 7 + ring * 2
		for i = 1, count do
			poreIndex += 1
			local theta = (i / count) * math.pi * 2 + ring * 0.31
			local r = math.sqrt(1 - yNorm * yNorm)
			local normal = Vector3.new(math.cos(theta) * r, yNorm, math.sin(theta) * r).Unit
			local pos = NUCLEUS_CENTER + Vector3.new(normal.X * NUCLEUS_OUTER_RADIUS, normal.Y * NUCLEUS_OUTER_RADIUS * 0.86, normal.Z * NUCLEUS_OUTER_RADIUS)
			addPoreRing(pores, "nuclear_pore_complex_" .. poreIndex, pos, normal, 14, 4.2)
		end
	end

	-- Chromatin as several coiled strand paths inside nucleoplasm.
	for strand = 1, 8 do
		local points = {}
		local baseTheta = math.random() * math.pi * 2
		local strandRadius = 38 + math.random() * 70
		local yBase = -40 + math.random() * 78
		for k = 1, 18 do
			local t = (k - 1) / 17
			local theta = baseTheta + t * math.pi * 2.4 + math.sin(t * math.pi * 8 + strand) * 0.25
			local localR = strandRadius + math.sin(t * math.pi * 6 + strand) * 16
			table.insert(points, NUCLEUS_CENTER + Vector3.new(math.cos(theta) * localR, yBase + math.sin(t * math.pi * 3 + strand) * 30, math.sin(theta) * localR))
		end
		makeTubePath(chromatin, "chromatin_coil_thread_" .. strand, points, 4.5, COLORS.Chromatin, Enum.Material.SmoothPlastic, 0.03, false)
	end

	createLabel("Nucleus", NUCLEUS_CENTER + Vector3.new(-35, 205, -20), "Nucleus", "Village-sized control chamber: envelope, pores, nucleoplasm, nucleolus, and chromatin are separate submodels.", Color3.fromRGB(80, 44, 29))
	createLabel("NuclearPores", NUCLEUS_CENTER + Vector3.new(185, 80, 155), "Nuclear pores", "Ring-shaped gateways in the nuclear envelope. Each pore is built from visible scaffold subunits.", Color3.fromRGB(66, 52, 46))
	createLabel("Nucleolus", NUCLEUS_CENTER + Vector3.new(40, 58, 45), "Nucleolus", "Bumpy inner body representing the ribosome-production zone inside the nucleoplasm.", Color3.fromRGB(87, 19, 25))
end

local function buildEndoplasmicReticulum()
	local rough = createModel("rough_endoplasmic_reticulum_ribosome_studded_sheets", F.ER)
	local smooth = createModel("smooth_endoplasmic_reticulum_tubular_network", F.ER)
	addHighlight(rough, COLORS.RoughER)
	addHighlight(smooth, COLORS.SmoothER)

	-- Rough ER: flattened cisternae wrapping around the nucleus, with bound ribosomes on the outside.
	for band = 1, 7 do
		local points = {}
		local startAngle = math.rad(-95)
		local endAngle = math.rad(80)
		for k = 1, 18 do
			local t = (k - 1) / 17
			local a = startAngle + (endAngle - startAngle) * t
			local radius = NUCLEUS_OUTER_RADIUS + 30 + band * 18 + math.sin(t * math.pi * 6 + band) * 10
			local y = NUCLEUS_CENTER.Y - 70 + band * 15 + math.sin(t * math.pi * 4 + band) * 12
			table.insert(points, NUCLEUS_CENTER + Vector3.new(math.cos(a) * radius, y - NUCLEUS_CENTER.Y, math.sin(a) * radius))
		end
		local ribbon = makeRibbon(rough, "rough_ER_flattened_cisterna_band_" .. band, points, 42, 7, COLORS.RoughER, Enum.Material.SmoothPlastic, 0.05, false, 0.18)
		for k = 2, #points - 1, 2 do
			local outward = safeUnit(points[k] - NUCLEUS_CENTER, Vector3.zAxis)
			makeRibosome(ribbon, "bound_ribosome_on_band_" .. band .. "_" .. k, points[k] + outward * 27 + Vector3.new(0, 5, 0), 4.2, COLORS.Ribosome)
		end
	end

	-- Smooth ER: branched tubules with no ribosomes, using warmer color and thinner round tubes.
	for branch = 1, 8 do
		local points = {}
		local angle0 = math.rad(20 + branch * 25)
		for k = 1, 12 do
			local t = (k - 1) / 11
			local angle = angle0 + t * math.rad(95) + math.sin(t * 8 + branch) * 0.18
			local radius = NUCLEUS_OUTER_RADIUS + 90 + branch * 7 + math.sin(t * 7) * 28
			local y = NUCLEUS_CENTER.Y + 28 + math.sin(t * math.pi * 3 + branch) * 46
			table.insert(points, NUCLEUS_CENTER + Vector3.new(math.cos(angle) * radius, y - NUCLEUS_CENTER.Y, math.sin(angle) * radius))
		end
		makeTubePath(smooth, "smooth_ER_branching_tubule_" .. branch, points, 9, COLORS.SmoothER, Enum.Material.SmoothPlastic, 0.02, false)
		if branch % 2 == 0 then
			for fork = 1, 2 do
				local base = points[math.floor(#points * (0.35 + fork * 0.18))]
				local forkPoints = {base}
				for k = 1, 5 do
					local offset = Vector3.new(math.sin(k + branch) * 42, math.cos(k + fork) * 19, k * 20 * (fork == 1 and 1 or -1))
					table.insert(forkPoints, base + offset)
				end
				makeTubePath(smooth, "smooth_ER_side_tubule_" .. branch .. "_" .. fork, forkPoints, 7, COLORS.SmoothER:Lerp(Color3.new(1, 1, 1), 0.08), Enum.Material.SmoothPlastic, 0.04, false)
			end
		end
	end

	createLabel("RoughER", NUCLEUS_CENTER + Vector3.new(260, 55, -70), "Rough ER", "Flattened membrane sheets continuous with the nuclear envelope. Purple two-part ribosomes are attached to the outside.", Color3.fromRGB(86, 36, 35))
	createLabel("SmoothER", NUCLEUS_CENTER + Vector3.new(325, 145, 65), "Smooth ER", "Ribosome-free tubular network. Built as branching tubes rather than stacked sheets.", Color3.fromRGB(102, 46, 25))
end

local function buildGolgiAndSecretoryPathway()
	local golgi = createModel("Golgi_apparatus_stacked_curved_cisternae", F.Golgi)
	addHighlight(golgi, COLORS.Golgi)
	local base = Vector3.new(-292, 70, -210)

	for stack = 1, 7 do
		local points = {}
		for k = 1, 18 do
			local t = (k - 1) / 17
			local x = -92 + t * 184
			local curve = math.sin((t - 0.5) * math.pi) * 42
			local z = curve + math.sin(t * math.pi * 4 + stack) * 5
			local y = (stack - 1) * 13
			table.insert(points, base + Vector3.new(x, y, z))
		end
		local c = COLORS.Golgi:Lerp(COLORS.GolgiEdge, stack / 9)
		makeRibbon(golgi, "golgi_flat_cisterna_stack_layer_" .. stack, points, 38, 7, c, Enum.Material.SmoothPlastic, 0.02, false, 0.08)
	end

	-- Transport vesicles around the Golgi, with cargo dots.
	local vesFolder = createModel("secretory_vesicles_and_transport_route", F.Golgi)
	local transportPath = {
		NUCLEUS_CENTER + Vector3.new(280, -42, -90),
		Vector3.new(-68, 70, -155),
		base + Vector3.new(98, 58, 30),
		Vector3.new(-105, 82, -330),
		Vector3.new(215, 82, -418),
		CONFIG.CellCenter + Vector3.new(485, 78, -282),
	}
	makeTubePath(vesFolder, "faint_secretory_path_ER_to_Golgi_to_membrane", transportPath, 3.2, Color3.fromRGB(255, 219, 98), Enum.Material.Neon, 0.30, false)
	for i = 1, 12 do
		local p = addMovingSphere("animated_secretory_vesicle_" .. i, vesFolder, transportPath, 10 + math.random() * 4, COLORS.Vesicle:Lerp(Color3.new(1, 1, 1), math.random() * 0.18), 0.022 + math.random() * 0.016, math.random())
		p.Transparency = 0.05
	end
	for i = 1, 22 do
		local pos = base + Vector3.new(-135 + math.random() * 265, -8 + math.random() * 105, -85 + math.random() * 180)
		local ves = createSphere("static_budding_or_fusing_vesicle_" .. i, vesFolder, pos, Vector3.new(16 + math.random() * 12, 16 + math.random() * 12, 16 + math.random() * 12), COLORS.Vesicle, Enum.Material.Glass, 0.12, false)
		table.insert(animatedPulsers, {Part = ves, BaseTransparency = 0.12, Amplitude = 0.12, Speed = 0.7, Phase = i})
	end

	createLabel("Golgi", base + Vector3.new(-120, 142, 20), "Golgi apparatus", "Curved stacks of cisternae with vesicles budding around the edges. This area connects ER output to secretory vesicles.", Color3.fromRGB(75, 28, 65))
	createLabel("SecretoryVesicles", Vector3.new(95, 128, -390), "Secretory vesicles", "Animated spheres move from ER to Golgi and toward the membrane to show transport.", Color3.fromRGB(84, 41, 100))
end

local function buildMitochondrion(name: string, pos: Vector3, size: Vector3, rotY: number, rotZ: number)
	local m = createModel(name, F.Mito)
	local cf = CFrame.new(pos) * CFrame.Angles(0, rotY, rotZ)
	local outer = createPart({
		Name = "outer_mitochondrial_membrane_ellipsoid",
		Parent = m,
		Shape = Enum.PartType.Ball,
		Size = size,
		CFrame = cf,
		Color = COLORS.MitoOuter,
		Material = Enum.Material.Glass,
		Transparency = 0.26,
		CanCollide = false,
	})
	local inner = createPart({
		Name = "inner_matrix_volume_visible_through_outer_membrane",
		Parent = m,
		Shape = Enum.PartType.Ball,
		Size = size * 0.78,
		CFrame = cf,
		Color = COLORS.MitoInner,
		Material = Enum.Material.Glass,
		Transparency = 0.58,
		CanCollide = false,
	})
	for ridge = 1, 7 do
		local points = {}
		local z = -size.Z * 0.25 + ridge * (size.Z * 0.5 / 7)
		for k = 1, 16 do
			local t = (k - 1) / 15
			local x = -size.X * 0.32 + t * size.X * 0.64
			local y = math.sin(t * math.pi * 4 + ridge) * size.Y * 0.18
			table.insert(points, cf:PointToWorldSpace(Vector3.new(x, y, z)))
		end
		makeTubePath(m, "folded_inner_membrane_crista_" .. ridge, points, 4.4, COLORS.MitoCristae, Enum.Material.SmoothPlastic, 0.02, false)
	end
	for i = 1, 18 do
		local localPos = Vector3.new((math.random() - 0.5) * size.X * 0.48, (math.random() - 0.5) * size.Y * 0.32, (math.random() - 0.5) * size.Z * 0.42)
		createSphere("matrix_granule_" .. i, m, cf:PointToWorldSpace(localPos), Vector3.new(4, 4, 4), Color3.fromRGB(20, 80, 145), Enum.Material.SmoothPlastic, 0.20, false)
	end
	table.insert(animatedPulsers, {Part = outer, BaseTransparency = 0.26, Amplitude = 0.055, Speed = 0.5, Phase = math.random() * 3})
	table.insert(animatedSpinners, {Part = inner, Speed = 0.035})
	return m
end

local function buildMitochondria()
	buildMitochondrion("Mitochondrion_A_large_cutaway_cristae", Vector3.new(300, 78, -155), Vector3.new(138, 52, 82), math.rad(-25), math.rad(4))
	buildMitochondrion("Mitochondrion_B_near_membrane", Vector3.new(285, 120, 245), Vector3.new(112, 48, 74), math.rad(42), math.rad(-10))
	buildMitochondrion("Mitochondrion_C_left_cytoplasm", Vector3.new(-355, 118, 85), Vector3.new(124, 55, 78), math.rad(-52), math.rad(12))
	buildMitochondrion("Mitochondrion_D_bottom_observation", Vector3.new(-5, 56, -322), Vector3.new(132, 50, 74), math.rad(13), math.rad(3))
	createLabel("Mitochondrion", Vector3.new(360, 160, -170), "Mitochondrion", "Each mitochondrion has a translucent outer membrane, inner matrix volume, and folded cristae tubes inside.", Color3.fromRGB(26, 66, 116))
end

local function buildLysosomesPeroxisomes()
	local lys = createModel("lysosomes_digestive_vesicles", F.LysPerox)
	local per = createModel("peroxisomes_detox_microbodies", F.LysPerox)

	local lysPositions = {
		Vector3.new(-315, 74, 205),
		Vector3.new(42, 108, 310),
		Vector3.new(128, 120, -85),
	}
	for i, p in ipairs(lysPositions) do
		local lm = createModel("lysosome_" .. i .. "_acidic_enzyme_sphere", lys)
		local outer = createSphere("lysosome_membrane", lm, p, Vector3.new(50, 45, 50), COLORS.Lysosome, Enum.Material.Glass, 0.18, false)
		for j = 1, 13 do
			local off = Vector3.new((math.random() - 0.5) * 32, (math.random() - 0.5) * 26, (math.random() - 0.5) * 32)
			createSphere("digestive_enzyme_granule_" .. j, lm, p + off, Vector3.new(5, 5, 5), Color3.fromRGB(122, 42, 85), Enum.Material.SmoothPlastic, 0.05, false)
		end
		table.insert(animatedPulsers, {Part = outer, BaseTransparency = 0.18, Amplitude = 0.16, Speed = 0.9, Phase = i})
	end

	local perPositions = {
		Vector3.new(-430, 74, -20),
		Vector3.new(180, 94, 190),
		Vector3.new(-115, 62, -318),
	}
	for i, p in ipairs(perPositions) do
		local pm = createModel("peroxisome_" .. i .. "_crystalloid_core", per)
		local outer = createSphere("peroxisome_membrane", pm, p, Vector3.new(45, 45, 45), COLORS.Peroxisome, Enum.Material.Glass, 0.12, false)
		createSphere("oxidase_catalase_core_visual", pm, p, Vector3.new(22, 18, 22), COLORS.PeroxisomeCore, Enum.Material.Neon, 0.12, false)
		for j = 1, 8 do
			local a = j / 8 * math.pi * 2
			createTube("core_spoke_" .. j, pm, p, p + Vector3.new(math.cos(a) * 22, math.sin(a * 2) * 7, math.sin(a) * 22), 1.9, COLORS.PeroxisomeCore, Enum.Material.SmoothPlastic, 0.05, false)
		end
		table.insert(animatedPulsers, {Part = outer, BaseTransparency = 0.12, Amplitude = 0.10, Speed = 0.65, Phase = i * 2})
	end

	createLabel("Lysosome", Vector3.new(-355, 130, 218), "Lysosome", "Membrane vesicle with internal enzyme granules. Pink-purple to distinguish it from peroxisomes.", Color3.fromRGB(86, 37, 69))
	createLabel("Peroxisome", Vector3.new(-455, 128, -35), "Peroxisome", "Green microbody with a bright core/spokes so it reads differently from lysosomes.", Color3.fromRGB(43, 86, 44))
end

local function buildCentrosomeAndMicrotubules()
	local centrosome = createModel("centrosome_with_two_perpendicular_centrioles", F.Centrosome)
	local center = NUCLEUS_CENTER + Vector3.new(-190, 65, -88)
	local cloud = createSphere("pericentriolar_material_cloud", centrosome, center, Vector3.new(92, 72, 92), COLORS.CentrosomeCloud, Enum.Material.Glass, 0.56, false)
	table.insert(animatedPulsers, {Part = cloud, BaseTransparency = 0.56, Amplitude = 0.08, Speed = 0.75, Phase = 1.2})

	local function makeCentriole(name: string, cf: CFrame)
		local cm = createModel(name, centrosome)
		local length = 82
		local ringRadius = 24
		for i = 1, 9 do
			local a = (i / 9) * math.pi * 2
			for triplet = 1, 3 do
				local lateral = (triplet - 2) * 4.3
				local localOffset = Vector3.new(math.cos(a) * ringRadius + math.cos(a + math.pi / 2) * lateral, math.sin(a) * ringRadius + math.sin(a + math.pi / 2) * lateral, 0)
				local p0 = cf:PointToWorldSpace(localOffset + Vector3.new(0, 0, -length / 2))
				local p1 = cf:PointToWorldSpace(localOffset + Vector3.new(0, 0, length / 2))
				createTube("microtubule_triplet_" .. i .. "_" .. triplet, cm, p0, p1, 2.8, COLORS.Centriole, Enum.Material.SmoothPlastic, 0.02, false)
			end
		end
		for k = 1, 4 do
			createTube("cross_bridge_ring_" .. k, cm, cf:PointToWorldSpace(Vector3.new(-ringRadius, 0, -length / 2 + k * length / 5)), cf:PointToWorldSpace(Vector3.new(ringRadius, 0, -length / 2 + k * length / 5)), 1.3, Color3.fromRGB(220, 226, 210), Enum.Material.SmoothPlastic, 0.2, false)
		end
	end

	makeCentriole("centriole_A_9_triplet_microtubule_cylinder", CFrame.new(center) * CFrame.Angles(math.rad(90), 0, math.rad(18)))
	makeCentriole("centriole_B_perpendicular_9_triplet_microtubule_cylinder", CFrame.new(center + Vector3.new(17, 15, 4)) * CFrame.Angles(0, math.rad(82), math.rad(95)))

	-- Microtubules radiating from centrosome through cytoplasm.
	local targets = {
		Vector3.new(-520, 22, 360), Vector3.new(-500, 40, -330), Vector3.new(-150, 52, -470), Vector3.new(320, 55, -390),
		Vector3.new(480, 80, 65), Vector3.new(260, 72, 350), Vector3.new(-420, 66, 160), Vector3.new(40, 140, 420),
		Vector3.new(125, 70, -60), Vector3.new(-230, 120, 310), Vector3.new(370, 135, 250), Vector3.new(-350, 130, -210),
	}
	for i, target in ipairs(targets) do
		local points = {center}
		for k = 1, 5 do
			local t = k / 5
			table.insert(points, center:Lerp(target, t) + Vector3.new(math.sin(t * 8 + i) * 22, math.cos(t * 4 + i) * 15, math.cos(t * 7 + i) * 20))
		end
		makeTubePath(F.Centrosome, "radiating_cytoskeleton_microtubule_" .. i, points, 3.5, COLORS.Microtubule, Enum.Material.Neon, 0.25, false)
	end

	createLabel("Centrosome", center + Vector3.new(-55, 95, 10), "Centrosome", "Two perpendicular centrioles, each modeled with 9 microtubule triplet groups, plus a surrounding organizing cloud.", Color3.fromRGB(82, 71, 45))
end

local function buildCilium()
	local cilium = createModel("single_cilium_with_axoneme_and_basal_body", F.Cilium)
	local normal = Vector3.new(0.32, 0.87, 0.28).Unit
	local base = CONFIG.CellCenter + normal * CONFIG.CellRadius
	local tangentA = normal:Cross(Vector3.yAxis).Magnitude < 0.05 and Vector3.xAxis or normal:Cross(Vector3.yAxis).Unit
	local tangentB = normal:Cross(tangentA).Unit

	-- Curved centerline protruding from the membrane.
	local centerline = {}
	for k = 0, 10 do
		local t = k / 10
		local bend = tangentA * math.sin(t * math.pi) * 55 + tangentB * math.sin(t * math.pi * 1.5) * 18
		table.insert(centerline, base + normal * (t * 250) + bend)
	end
	makeTubePath(cilium, "ciliary_membrane_sheath", centerline, 20, COLORS.Cilium, Enum.Material.Glass, 0.36, false)

	-- 9+2 axoneme fibers inside. The offsets stay in the same local cross-section basis for readability.
	for i = 1, 9 do
		local a = (i / 9) * math.pi * 2
		local offset = tangentA * math.cos(a) * 13 + tangentB * math.sin(a) * 13
		local fiber = {}
		for _, p in ipairs(centerline) do
			table.insert(fiber, p + offset)
		end
		makeTubePath(cilium, "outer_axoneme_microtubule_doublet_" .. i, fiber, 2.4, COLORS.CiliumFiber, Enum.Material.Neon, 0.10, false)
	end
	for i = 1, 2 do
		local offset = tangentA * (i == 1 and -4.5 or 4.5)
		local fiber = {}
		for _, p in ipairs(centerline) do
			table.insert(fiber, p + offset)
		end
		makeTubePath(cilium, "central_pair_microtubule_" .. i, fiber, 2.6, COLORS.CiliumFiber:Lerp(Color3.new(1, 1, 1), 0.12), Enum.Material.Neon, 0.05, false)
	end

	-- Basal body at the membrane resembles a centriole.
	for i = 1, 9 do
		local a = (i / 9) * math.pi * 2
		local offset = tangentA * math.cos(a) * 19 + tangentB * math.sin(a) * 19
		createTube("basal_body_triplet_group_" .. i, cilium, base - normal * 42 + offset, base + normal * 30 + offset, 3, COLORS.Centriole, Enum.Material.SmoothPlastic, 0.02, false)
	end

	createLabel("Cilium", base + normal * 205 + tangentA * 75, "Cilium", "A membrane projection with a 9+2 axoneme: nine outer fibers plus a central pair, anchored by a basal body.", Color3.fromRGB(91, 58, 26))
end

local function buildFreeRibosomes()
	local free = createModel("free_ribosomes_in_cytoplasm", F.Ribosomes)
	local r = CONFIG.CellRadius * 0.72
	local nucleusAvoid = 235
	local count = 92
	local made = 0
	local tries = 0
	while made < count and tries < 700 do
		tries += 1
		local theta = math.random() * math.pi * 2
		local rad = math.sqrt(math.random()) * r
		local y = 36 + math.random() * 245
		local pos = Vector3.new(math.cos(theta) * rad, y, math.sin(theta) * rad)
		if (pos - NUCLEUS_CENTER).Magnitude > nucleusAvoid and pos.Magnitude < CONFIG.CellRadius * 0.87 then
			made += 1
			makeRibosome(free, "free_ribosome_two_subunit_" .. made, pos, 3.2 + math.random() * 1.2, COLORS.Ribosome:Lerp(Color3.new(1, 1, 1), math.random() * 0.12))
		end
	end
	createLabel("Ribosomes", Vector3.new(92, 230, 345), "Ribosomes", "Free ribosomes appear as paired subunits in cytoplasm; rough ER has separate bound ribosomes on its sheets.", Color3.fromRGB(42, 31, 82))
end

local function buildCytoskeletonMesh()
	local mesh = createModel("additional_cytoskeleton_mesh_near_membrane", F.Shell)
	for ring = 1, 5 do
		local y = -25 + ring * 48
		local radius = CONFIG.CellRadius * (0.80 + ring * 0.015)
		local points = {}
		for i = 1, 34 do
			local a = (i / 34) * math.pi * 2
			table.insert(points, CONFIG.CellCenter + Vector3.new(math.cos(a) * radius, y, math.sin(a) * radius))
		end
		table.insert(points, points[1])
		makeTubePath(mesh, "actin_like_submembrane_ring_" .. ring, points, 2.2, COLORS.Cytoskeleton, Enum.Material.Neon, 0.48, false)
	end
	for i = 1, 14 do
		local a0 = (i / 14) * math.pi * 2
		local points = {}
		for k = 1, 13 do
			local t = (k - 1) / 12
			local angle = a0 + t * 0.8 + math.sin(t * 8 + i) * 0.07
			local radius = CONFIG.CellRadius * (0.18 + t * 0.68)
			local y = 25 + math.sin(t * math.pi + i) * 42
			table.insert(points, Vector3.new(math.cos(angle) * radius, y, math.sin(angle) * radius))
		end
		makeTubePath(mesh, "long_cytoskeleton_filament_" .. i, points, 2.0, COLORS.Cytoskeleton, Enum.Material.Neon, 0.55, false)
	end
	createLabel("Cytoskeleton", Vector3.new(-210, 210, 430), "Cytoskeleton", "Blue/cyan filaments and microtubules give the cytoplasm an internal transport scaffold.", Color3.fromRGB(27, 75, 91))
end

buildVillageNavigation()
buildCellShellAndCytoplasm()
buildNucleus()
buildEndoplasmicReticulum()
buildGolgiAndSecretoryPathway()
buildMitochondria()
buildLysosomesPeroxisomes()
buildCentrosomeAndMicrotubules()
buildCilium()
buildFreeRibosomes()
buildCytoskeletonMesh()

local centerMarker = createPart({
	Name = "PrimaryPart_CellVillageCenter",
	Parent = root,
	Shape = Enum.PartType.Ball,
	Size = Vector3.new(6, 6, 6),
	CFrame = CFrame.new(CONFIG.CellCenter),
	Transparency = 1,
	CanCollide = false,
	CanQuery = false,
})
root.PrimaryPart = centerMarker

if CONFIG.EnableAnimations then
	RunService.Heartbeat:Connect(function()
		local now = os.clock()
		for _, item in ipairs(animatedPulsers) do
			if item.Part and item.Part.Parent then
				item.Part.Transparency = clamp01(item.BaseTransparency + math.sin(now * item.Speed + item.Phase) * item.Amplitude)
			end
		end
		for _, item in ipairs(animatedSpinners) do
			if item.Part and item.Part.Parent then
				item.Part.CFrame = item.Part.CFrame * CFrame.Angles(0, item.Speed * 0.016, 0)
			end
		end
		for _, item in ipairs(animatedMovers) do
			if item.Part and item.Part.Parent then
				local alpha = (now * item.Speed + item.Phase) % 1
				local pos = samplePolyline(item.Points, alpha)
				item.Part.CFrame = CFrame.new(pos)
			end
		end
	end)
end

print("AnimalCellVillage_Model generated. Nested organelle models, labels, walkways, membrane patch, and basic animations are ready in Workspace.")
