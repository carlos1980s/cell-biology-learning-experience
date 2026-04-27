local BuildCellExperience = {}

local function requireChild(root, path)
    local current = root
    for segment in string.gmatch(path, "[^/]+") do
        current = current:WaitForChild(segment)
    end
    return require(current)
end

local ORGANELLE_LAYOUT_OFFSETS = {
    Nucleus = Vector3.new(-24, 0, -10),
    RoughER = Vector3.new(-18, 6, -26),
    SmoothER = Vector3.new(-24, -10, 26),
    Ribosomes = Vector3.new(-8, -18, 16),
    Mitochondria = Vector3.new(40, -6, 12),
    GolgiBody = Vector3.new(70, -4, -22),
    LysosomeField = Vector3.new(82, -16, 28),
    VesicleField = Vector3.new(34, -8, -2),
}

local function translateCFrame(cframe, offset)
    return CFrame.fromMatrix(
        cframe.Position + offset,
        cframe.RightVector,
        cframe.UpVector,
        -cframe.LookVector
    )
end

local function applyLayoutOffset(model, hotspots)
    local offset = model and ORGANELLE_LAYOUT_OFFSETS[model.Name]
    if not offset then
        return
    end

    model:PivotTo(translateCFrame(model:GetPivot(), offset))
    for _, hotspot in ipairs(hotspots or {}) do
        hotspot.position += offset
    end
end

local function configureWorld()
    local Lighting = game:GetService("Lighting")
    local Workspace = game:GetService("Workspace")

    Lighting.ClockTime = 13.5
    Lighting.Brightness = 0.92
    Lighting.Ambient = Color3.fromRGB(18, 22, 30)
    Lighting.OutdoorAmbient = Color3.fromRGB(6, 4, 12)
    Lighting.EnvironmentDiffuseScale = 0.12
    Lighting.EnvironmentSpecularScale = 0.1
    Lighting.GlobalShadows = true

    local atmosphere = Lighting:FindFirstChild("CellCytoplasmAtmosphere") or Instance.new("Atmosphere")
    atmosphere.Name = "CellCytoplasmAtmosphere"
    atmosphere.Color = Color3.fromRGB(58, 88, 114)
    atmosphere.Decay = Color3.fromRGB(20, 12, 28)
    atmosphere.Density = 0.28
    atmosphere.Haze = 1.1
    atmosphere.Glare = 0.01
    atmosphere.Parent = Lighting

    Workspace.Gravity = 36

    local baseplate = Workspace:FindFirstChild("Baseplate")
    if baseplate and baseplate:IsA("BasePart") then
        baseplate:Destroy()
    end
end

local function addBoundaryFloor(root, utils, spec)
    local playerStart = spec.organelleAnchors.playerStart
    local floor = utils.part(root, "ExplorerLaunchPad", {
        Size = Vector3.new(24, 1.2, 24),
        CFrame = CFrame.new(playerStart + Vector3.new(0, -8.4, 0)),
        Color = Color3.fromRGB(24, 63, 88),
        Transparency = 0.78,
        Material = Enum.Material.SmoothPlastic,
        CanCollide = true,
    })
    floor.Reflectance = 0

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "CellExplorerSpawn"
    spawn.Size = Vector3.new(8, 1, 8)
    spawn.CFrame = CFrame.new(playerStart)
    spawn.Anchored = true
    spawn.CanCollide = true
    spawn.Material = Enum.Material.SmoothPlastic
    spawn.Color = Color3.fromRGB(32, 78, 106)
    spawn.Transparency = 1
    spawn.Duration = 0
    spawn.Parent = root
end

local function createBackdropEllipsoid(parent, utils, name, position, size, color, transparency, material, angles)
    local part = utils.part(parent, name, {
        Shape = Enum.PartType.Ball,
        Size = size,
        CFrame = CFrame.new(position) * CFrame.Angles(math.rad(angles.X), math.rad(angles.Y), math.rad(angles.Z)),
        Color = color,
        Transparency = transparency,
        Material = material,
        CanCollide = false,
        CanTouch = false,
        CanQuery = false,
    })
    part.CastShadow = false
    return part
end

local function addTissueCluster(parent, utils, name, center, baseSize, color, transparency, lobes)
    local cluster = utils.model(parent, name)
    createBackdropEllipsoid(
        cluster,
        utils,
        "Core",
        center,
        baseSize,
        color,
        transparency,
        Enum.Material.SmoothPlastic,
        Vector3.new(6, 0, -8)
    )

    for index, lobe in ipairs(lobes) do
        createBackdropEllipsoid(
            cluster,
            utils,
            string.format("Lobe_%02d", index),
            center + lobe.offset,
            lobe.size,
            lobe.color or color,
            lobe.transparency or transparency + 0.03,
            lobe.material or Enum.Material.SmoothPlastic,
            lobe.angles or Vector3.new(0, 0, 0)
        )
    end

    return cluster
end

local function addExperienceBackdrop(root, utils, spec)
    local center = spec.worldCenter

    local tissueModel = utils.model(root, "TissueBackdrop")

    local backdrop = utils.ellipsoid(
        root,
        "ExperienceBackdrop",
        center,
        Vector3.new(1500, 1220, 1500),
        Color3.fromRGB(14, 5, 14),
        0.02,
        Enum.Material.SmoothPlastic
    )
    backdrop.CanCollide = false
    backdrop.CanTouch = false
    backdrop.CanQuery = false
    backdrop.CastShadow = false

    local glow = utils.ellipsoid(
        root,
        "ExperienceBackdropGlow",
        center + Vector3.new(0, 40, 0),
        Vector3.new(1380, 1140, 1380),
        Color3.fromRGB(52, 16, 28),
        0.992,
        Enum.Material.Neon
    )
    glow.CanCollide = false
    glow.CanTouch = false
    glow.CanQuery = false
    glow.CastShadow = false

    addTissueCluster(
        tissueModel,
        utils,
        "TissueMass_01",
        center + Vector3.new(0, -238, 0),
        Vector3.new(860, 240, 860),
        Color3.fromRGB(64, 20, 30),
        0.04,
        {
            {
                offset = Vector3.new(-120, 26, 110),
                size = Vector3.new(420, 170, 340),
                color = Color3.fromRGB(72, 26, 38),
                transparency = 0.08,
                angles = Vector3.new(0, 18, 12),
            },
            {
                offset = Vector3.new(140, -12, -130),
                size = Vector3.new(360, 150, 300),
                color = Color3.fromRGB(81, 31, 43),
                transparency = 0.06,
                angles = Vector3.new(12, -14, 0),
            },
            {
                offset = Vector3.new(0, 40, -16),
                size = Vector3.new(520, 150, 380),
                color = Color3.fromRGB(54, 18, 28),
                transparency = 0.12,
                angles = Vector3.new(-10, 0, 18),
            },
        }
    )

    addTissueCluster(
        tissueModel,
        utils,
        "TissueMass_02",
        center + Vector3.new(-250, -166, -126),
        Vector3.new(360, 170, 310),
        Color3.fromRGB(82, 30, 44),
        0.12,
        {
            {
                offset = Vector3.new(-48, 18, 70),
                size = Vector3.new(150, 90, 120),
                color = Color3.fromRGB(104, 42, 56),
                transparency = 0.12,
                angles = Vector3.new(8, 24, 0),
            },
            {
                offset = Vector3.new(66, -18, -46),
                size = Vector3.new(180, 110, 132),
                color = Color3.fromRGB(66, 22, 36),
                transparency = 0.18,
                angles = Vector3.new(-14, 10, 16),
            },
            {
                offset = Vector3.new(20, 56, 0),
                size = Vector3.new(160, 96, 104),
                color = Color3.fromRGB(76, 24, 40),
                transparency = 0.18,
                angles = Vector3.new(0, -18, -10),
            },
        }
    )

    addTissueCluster(
        tissueModel,
        utils,
        "TissueMass_03",
        center + Vector3.new(246, -144, 86),
        Vector3.new(390, 184, 294),
        Color3.fromRGB(74, 24, 40),
        0.1,
        {
            {
                offset = Vector3.new(-72, 34, 42),
                size = Vector3.new(156, 96, 136),
                color = Color3.fromRGB(95, 35, 48),
                transparency = 0.12,
                angles = Vector3.new(14, 6, -18),
            },
            {
                offset = Vector3.new(78, -12, -64),
                size = Vector3.new(182, 102, 128),
                color = Color3.fromRGB(58, 18, 34),
                transparency = 0.18,
                angles = Vector3.new(-8, -24, 12),
            },
        }
    )

    addTissueCluster(
        tissueModel,
        utils,
        "TissueMass_04",
        center + Vector3.new(-160, 36, 252),
        Vector3.new(278, 202, 238),
        Color3.fromRGB(44, 14, 30),
        0.22,
        {
            {
                offset = Vector3.new(-44, -24, 46),
                size = Vector3.new(130, 104, 120),
                color = Color3.fromRGB(60, 22, 36),
                transparency = 0.18,
                angles = Vector3.new(18, 0, 26),
            },
            {
                offset = Vector3.new(54, 20, -30),
                size = Vector3.new(122, 86, 100),
                color = Color3.fromRGB(42, 12, 24),
                transparency = 0.26,
                angles = Vector3.new(-12, 18, -8),
            },
        }
    )

    addTissueCluster(
        tissueModel,
        utils,
        "TissueMass_05",
        center + Vector3.new(214, 58, -246),
        Vector3.new(326, 228, 272),
        Color3.fromRGB(50, 16, 34),
        0.2,
        {
            {
                offset = Vector3.new(-68, 12, 52),
                size = Vector3.new(140, 108, 126),
                color = Color3.fromRGB(66, 20, 40),
                transparency = 0.18,
                angles = Vector3.new(0, -20, 10),
            },
            {
                offset = Vector3.new(70, -30, -58),
                size = Vector3.new(160, 120, 118),
                color = Color3.fromRGB(38, 10, 26),
                transparency = 0.25,
                angles = Vector3.new(16, 10, -22),
            },
        }
    )

    for index, band in ipairs({
        { position = center + Vector3.new(0, -176, 0), size = Vector3.new(980, 84, 640), color = Color3.fromRGB(36, 10, 22), transparency = 0.38, angles = Vector3.new(0, 0, 6) },
        { position = center + Vector3.new(0, 218, -420), size = Vector3.new(860, 116, 420), color = Color3.fromRGB(28, 8, 20), transparency = 0.52, angles = Vector3.new(12, 0, 0) },
    }) do
        createBackdropEllipsoid(
            tissueModel,
            utils,
            string.format("TissueBand_%02d", index),
            band.position,
            band.size,
            band.color,
            band.transparency,
            Enum.Material.SmoothPlastic,
            band.angles
        )
    end

    for index, streak in ipairs({
        { position = center + Vector3.new(-180, -60, 260), size = Vector3.new(26, 180, 26), color = Color3.fromRGB(123, 38, 52) },
        { position = center + Vector3.new(210, 10, -240), size = Vector3.new(24, 210, 24), color = Color3.fromRGB(131, 48, 67) },
        { position = center + Vector3.new(0, -120, -320), size = Vector3.new(22, 240, 22), color = Color3.fromRGB(105, 28, 46) },
    }) do
        local vessel = utils.part(tissueModel, string.format("Vessel_%02d", index), {
            Shape = Enum.PartType.Cylinder,
            Size = streak.size,
            CFrame = CFrame.new(streak.position) * CFrame.Angles(0, 0, math.pi / 2),
            Color = streak.color,
            Transparency = 0.16,
            Material = Enum.Material.Neon,
            CanCollide = false,
        })
        vessel.CastShadow = false
    end
end

function BuildCellExperience.build()
    local sourceRoot = script.Parent
    local spec = requireChild(sourceRoot, "CellSpec")
    local utils = requireChild(sourceRoot, "BuildUtils")
    local registry = requireChild(sourceRoot, "OrganelleRegistry")

    configureWorld()
    utils.clearExisting(spec.rootName)

    local root = utils.model(workspace, spec.rootName)
    root:SetAttribute("BuiltBy", "Codex")
    root:SetAttribute("Experience", "Cell Biology Learning")
    root:SetAttribute("CytoplasmCenter", spec.worldCenter)
    root:SetAttribute(
        "CytoplasmRadii",
        Vector3.new(
            spec.cytoplasmRadius * spec.ellipsoidScale.X,
            spec.cytoplasmRadius * spec.ellipsoidScale.Y,
            spec.cytoplasmRadius * spec.ellipsoidScale.Z
        )
    )
    root:SetAttribute("EntryLookTarget", spec.organelleAnchors.entryLookTarget or spec.organelleAnchors.nucleus)
    root:SetAttribute("CytoplasmMaxSpeed", 24)
    root:SetAttribute("CytoplasmCurrentStrength", 5.5)
    root:SetAttribute("CytoplasmBuoyancyScale", 1.04)
    root:SetAttribute("CytoplasmDrag", 0.9)

    addExperienceBackdrop(root, utils, spec)
    addBoundaryFloor(root, utils, spec)

    local scene = utils.folder(root, "GeneratedModels")
    local allHotspots = {}

    for _, modulePath in ipairs(registry.organelleModules) do
        local module = requireChild(sourceRoot, modulePath)
        local model, hotspots = module.build(scene, utils, spec)
        applyLayoutOffset(model, hotspots)
        for _, hotspot in ipairs(hotspots or {}) do
            table.insert(allHotspots, hotspot)
        end
    end

    local PlayerBootstrap = requireChild(sourceRoot, "Gameplay/PlayerBootstrap")
    PlayerBootstrap.build(root, utils, spec)

    local ExplorerControls = requireChild(sourceRoot, "Gameplay/ExplorerControls")
    ExplorerControls.build(root, utils, spec)

    local MembraneMotion = requireChild(sourceRoot, "Gameplay/MembraneMotion")
    MembraneMotion.build(root, utils, spec)

    local OrganelleMotion = requireChild(sourceRoot, "Gameplay/OrganelleMotion")
    OrganelleMotion.build(root, utils, spec)

    local Hotspots = requireChild(sourceRoot, "Education/Hotspots")
    Hotspots.build(root, utils, spec, allHotspots)

    print(string.format(
        "Built %s with %d learning hotspots.",
        spec.rootName,
        #allHotspots
    ))

    return root
end

return BuildCellExperience
