local Geometry = require(script.Parent.Parent.Builders.OrganicGeometry)
local NucleusMeshAssets = require(script.Parent.Parent.Data.NucleusMeshAssets)
local NucleusSpec = require(script.Parent.Parent.Data.Generated.NucleusSpec)

local Nucleus = {}

local TAU = math.pi * 2

local COLORS = {
    outerWall = Color3.fromRGB(218, 83, 44),
    outerWallDark = Color3.fromRGB(142, 47, 70),
    innerWall = Color3.fromRGB(122, 55, 128),
    wallHighlight = Color3.fromRGB(245, 137, 70),
    floor = Color3.fromRGB(128, 57, 82),
    floorTrim = Color3.fromRGB(248, 175, 82),
    poreRing = Color3.fromRGB(54, 38, 76),
    poreGate = Color3.fromRGB(255, 217, 91),
    chromatinA = Color3.fromRGB(74, 143, 226),
    chromatinB = Color3.fromRGB(86, 64, 197),
    chromatinC = Color3.fromRGB(35, 188, 188),
    nucleolus = Color3.fromRGB(93, 43, 164),
    nucleolusLight = Color3.fromRGB(169, 72, 220),
    transportMRNA = Color3.fromRGB(255, 230, 72),
    transportSubunit = Color3.fromRGB(112, 231, 255),
    collision = Color3.fromRGB(255, 255, 255),
}

local function addHotspot(hotspots, id, title, body, position, labelDistance)
    table.insert(hotspots, {
        id = id,
        title = title,
        body = body,
        position = position,
        labelDistance = labelDistance,
    })
end

local function pointFromSpec(value)
    return Vector3.new(value[1], value[2], value[3])
end

local function blendColor(a, b, alpha)
    return Color3.new(
        a.R + (b.R - a.R) * alpha,
        a.G + (b.G - a.G) * alpha,
        a.B + (b.B - a.B) * alpha
    )
end

local function ellipsePoint(center, angle, radiusX, radiusZ, y)
    return center + Vector3.new(math.cos(angle) * radiusX, y, math.sin(angle) * radiusZ)
end

local function makePart(utils, parent, name, props)
    local part = utils.part(parent, name, props)
    part.CastShadow = props.CastShadow == true
    return part
end

local function normalizedMeshId(meshId)
    if type(meshId) ~= "string" or meshId == "" then
        return nil
    end
    if string.match(meshId, "^rbxassetid://") then
        return meshId
    end
    return "rbxassetid://" .. meshId
end

local function makeMeshPart(parent, name, meshId, props)
    local assetId = normalizedMeshId(meshId)
    if not assetId then
        return nil
    end

    local mesh = Instance.new("MeshPart")
    mesh.Name = name
    mesh.Anchored = true
    mesh.CanCollide = props.CanCollide == true
    mesh.CanTouch = false
    mesh.CanQuery = props.CanQuery ~= false
    mesh.CastShadow = props.CastShadow == true
    mesh.Color = props.Color or Color3.new(1, 1, 1)
    mesh.Material = props.Material or Enum.Material.SmoothPlastic
    mesh.Transparency = props.Transparency or 0
    mesh.Size = props.Size
    mesh.CFrame = props.CFrame

    local ok = pcall(function()
        mesh.MeshId = assetId
    end)
    if not ok then
        mesh:Destroy()
        return nil
    end

    mesh.Parent = parent
    return mesh
end

local function makeCylinderDisk(utils, parent, name, position, radiusX, radiusZ, height, color, transparency, material, canCollide)
    local disk = makePart(utils, parent, name, {
        Shape = Enum.PartType.Cylinder,
        Size = Vector3.new(radiusX * 2, height, radiusZ * 2),
        CFrame = CFrame.new(position),
        Color = color,
        Transparency = transparency or 0,
        Material = material or Enum.Material.SmoothPlastic,
        CanCollide = canCollide == true,
        CanTouch = false,
        CanQuery = true,
        CastShadow = true,
    })
    return disk
end

local function makeWallSegment(utils, parent, name, center, angle, radiusX, radiusZ, y, size, color, transparency, material, canCollide)
    local position = ellipsePoint(center, angle, radiusX, radiusZ, y)
    local lookAt = Vector3.new(center.X, y, center.Z)
    return makePart(utils, parent, name, {
        Size = size,
        CFrame = CFrame.lookAt(position, lookAt),
        Color = color,
        Transparency = transparency or 0,
        Material = material or Enum.Material.SmoothPlastic,
        CanCollide = canCollide == true,
        CanTouch = false,
        CanQuery = true,
        CastShadow = true,
    })
end

local function makeRamp(utils, parent, name, a, b, width, thickness, color)
    local delta = b - a
    local flat = Vector3.new(delta.X, 0, delta.Z)
    local length = delta.Magnitude
    local pitch = math.atan2(delta.Y, math.max(flat.Magnitude, 0.001))
    local yaw = math.atan2(delta.X, delta.Z)
    return makePart(utils, parent, name, {
        Size = Vector3.new(width, thickness, length),
        CFrame = CFrame.new(a:Lerp(b, 0.5)) * CFrame.Angles(-pitch, yaw, 0),
        Color = color,
        Transparency = 0,
        Material = Enum.Material.SmoothPlastic,
        CanCollide = true,
        CanTouch = false,
        CanQuery = true,
        CastShadow = true,
    })
end

local function buildOrganicEnvelope(utils, model, center, layout)
    local envelope = utils.model(model, "OrganicEnvelope")
    local wallSegments = utils.folder(envelope, "OuterWallSegments")
    local wallLobes = utils.folder(envelope, "IrregularWallLobes")
    local innerRim = utils.folder(envelope, "InnerWallRim")
    local lamina = utils.folder(envelope, "LaminaBands")

    local count = 28
    local gateIndex = 1
    for index = 1, count do
        local angle = ((index - 1) / count) * TAU
        local wobble = math.sin(index * 1.73) * 2.5 + math.cos(index * 0.91) * 1.8
        local height = layout.wallHeight + (index % 4) * 3.0
        local width = 17 + (index % 5) * 2.4
        local thickness = 8 + (index % 3) * 1.8

        if index ~= gateIndex and index ~= count then
            local color = index % 3 == 0 and COLORS.outerWallDark or COLORS.outerWall
            makeWallSegment(
                utils,
                wallSegments,
                string.format("WallPanel_%02d", index),
                center,
                angle,
                layout.radiusX + wobble,
                layout.radiusZ + wobble * 0.65,
                layout.midY + ((index % 2 == 0) and 1.5 or -1.0),
                Vector3.new(width, height, thickness),
                color,
                0,
                Enum.Material.SmoothPlastic,
                false
            )
        end

        local lobeY = layout.baseY + 14 + (index % 6) * 9
        local lobePosition = ellipsePoint(center, angle + 0.035 * (index % 3), layout.radiusX + 5 + wobble, layout.radiusZ + 4, lobeY)
        local lobeColor = index % 4 == 0 and COLORS.wallHighlight or blendColor(COLORS.outerWall, COLORS.outerWallDark, (index % 5) * 0.12)
        local lobe = utils.ellipsoid(
            wallLobes,
            string.format("OrganicLobe_%02d", index),
            lobePosition,
            Vector3.new(18 + (index % 5) * 3, 13 + (index % 4) * 2, 12 + (index % 3) * 2.5),
            lobeColor,
            0,
            Enum.Material.SmoothPlastic
        )
        lobe.CastShadow = true
    end

    for bandIndex, y in ipairs({ layout.levels[2].y + 1.2, layout.levels[3].y + 1.2, layout.levels[4].y + 1.2 }) do
        makeCylinderDisk(
            utils,
            lamina,
            string.format("LaminaRing_%02d", bandIndex),
            center + Vector3.new(0, y, 0),
            layout.radiusX - 8,
            layout.radiusZ - 8,
            1.1,
            blendColor(COLORS.innerWall, COLORS.floorTrim, 0.45),
            0.18,
            Enum.Material.Neon,
            false
        )
    end

    for index = 1, 18 do
        local angle = (index / 18) * TAU + 0.07
        makeWallSegment(
            utils,
            innerRim,
            string.format("InnerRimPanel_%02d", index),
            center,
            angle,
            layout.radiusX - 10,
            layout.radiusZ - 10,
            layout.midY + math.sin(index) * 3,
            Vector3.new(14, layout.wallHeight - 10, 2.3),
            COLORS.innerWall,
            0.08,
            Enum.Material.SmoothPlastic,
            false
        )
    end

    return envelope
end

local function buildMeshEnvelope(utils, model, center, layout)
    local envelope = utils.model(model, "OrganicEnvelope")
    local meshVisuals = utils.folder(envelope, "MeshVisuals")
    local lamina = utils.folder(envelope, "LaminaBands")

    local shell = makeMeshPart(meshVisuals, "OrganicShellMesh", NucleusMeshAssets.organicShellMeshId, {
        Size = Vector3.new(layout.radiusX * 2.32, layout.wallHeight + 20, layout.radiusZ * 2.32),
        CFrame = CFrame.new(center + Vector3.new(0, layout.midY, 0)),
        Color = COLORS.outerWall,
        Material = Enum.Material.SmoothPlastic,
        Transparency = 0,
        CanCollide = false,
        CanQuery = true,
        CastShadow = true,
    })
    if not shell then
        return buildOrganicEnvelope(utils, model, center, layout)
    end

    shell:SetAttribute("SourceAsset", "organelle_projects/04_nucleus/assets/mesh/nucleus_organic_shell_v1.obj")

    for index = 1, 10 do
        local angle = (index / 10) * TAU + 0.11
        local accent = utils.ellipsoid(
            meshVisuals,
            string.format("OrganicSurfaceAccent_%02d", index),
            ellipsePoint(center, angle, layout.radiusX + 8, layout.radiusZ + 6, layout.baseY + 18 + (index % 5) * 13),
            Vector3.new(15 + (index % 3) * 4, 9 + (index % 4) * 2, 12 + (index % 2) * 4),
            index % 2 == 0 and COLORS.wallHighlight or COLORS.outerWallDark,
            0,
            Enum.Material.SmoothPlastic
        )
        accent.CastShadow = true
    end

    for bandIndex, y in ipairs({ layout.levels[2].y + 1.2, layout.levels[3].y + 1.2, layout.levels[4].y + 1.2 }) do
        makeCylinderDisk(
            utils,
            lamina,
            string.format("LaminaRing_%02d", bandIndex),
            center + Vector3.new(0, y, 0),
            layout.radiusX - 8,
            layout.radiusZ - 8,
            1.1,
            blendColor(COLORS.innerWall, COLORS.floorTrim, 0.45),
            0.18,
            Enum.Material.Neon,
            false
        )
    end

    return envelope
end

local function buildNavigation(utils, model, center, layout)
    local navigation = utils.model(model, "NavigationCollision")
    local floors = utils.folder(navigation, "Floors")
    local ramps = utils.folder(navigation, "Ramps")
    local invisibleGuides = utils.folder(navigation, "InvisibleWallGuides")
    local levelModel = utils.model(model, "InteriorLevels")

    for index, level in ipairs(layout.levels) do
        local folder = utils.folder(levelModel, level.name)
        local radiusX = layout.radiusX - 18 - (index - 1) * 6
        local radiusZ = layout.radiusZ - 16 - (index - 1) * 5
        makeCylinderDisk(
            utils,
            floors,
            level.name .. "_WalkableFloor",
            center + Vector3.new(0, level.y, 0),
            radiusX,
            radiusZ,
            1.8,
            index % 2 == 0 and COLORS.floor or blendColor(COLORS.floor, COLORS.floorTrim, 0.2),
            0,
            Enum.Material.SmoothPlastic,
            true
        )
        makeCylinderDisk(
            utils,
            folder,
            level.name .. "_VisualTrim",
            center + Vector3.new(0, level.y + 1.2, 0),
            radiusX + 3,
            radiusZ + 3,
            0.7,
            COLORS.floorTrim,
            0.12,
            Enum.Material.Neon,
            false
        )
    end

    for index = 1, #layout.levels - 1 do
        local a = center + Vector3.new(-layout.radiusX * 0.52 + index * 8, layout.levels[index].y + 2, -layout.radiusZ * 0.32)
        local b = center + Vector3.new(-layout.radiusX * 0.2 + index * 10, layout.levels[index + 1].y + 2, layout.radiusZ * 0.3)
        makeRamp(utils, ramps, string.format("Ramp_%d_To_%d", index, index + 1), a, b, 13, 1.6, COLORS.floorTrim)
    end

    for index = 1, 12 do
        local angle = (index / 12) * TAU
        if math.abs(math.cos(angle)) < 0.9 then
            makeWallSegment(
                utils,
                invisibleGuides,
                string.format("CollisionGuide_%02d", index),
                center,
                angle,
                layout.radiusX - 5,
                layout.radiusZ - 5,
                layout.midY,
                Vector3.new(20, layout.wallHeight + 8, 2.0),
                COLORS.collision,
                1,
                Enum.Material.SmoothPlastic,
                true
            )
        end
    end

    return navigation
end

local function buildPoreGate(utils, model, center, layout)
    local pores = utils.model(model, "PoreGates")
    local walkable = utils.model(pores, "WalkablePoreGate")
    local visuals = utils.folder(pores, "VisualPores")

    local gateAngle = 0
    local gatePosition = ellipsePoint(center, gateAngle, layout.radiusX + 2, layout.radiusZ + 2, layout.levels[1].y + 11)
    local gateLook = Vector3.new(center.X, gatePosition.Y, center.Z)
    local gateFrame = CFrame.lookAt(gatePosition, gateLook)

    makePart(utils, walkable, "GateTunnelFloor", {
        Size = Vector3.new(28, 2, 42),
        CFrame = gateFrame * CFrame.new(0, -11, 8),
        Color = COLORS.floorTrim,
        Transparency = 0,
        Material = Enum.Material.SmoothPlastic,
        CanCollide = true,
        CanTouch = false,
        CanQuery = true,
        CastShadow = true,
    })

    local gateMesh = makeMeshPart(walkable, "GateRingMesh", NucleusMeshAssets.poreGateRingMeshId, {
        Size = Vector3.new(7, 54, 54),
        CFrame = gateFrame,
        Color = COLORS.poreGate,
        Material = Enum.Material.Neon,
        Transparency = 0,
        CanCollide = false,
        CanQuery = true,
        CastShadow = true,
    })

    if gateMesh then
        gateMesh:SetAttribute("SourceAsset", "organelle_projects/04_nucleus/assets/mesh/nuclear_pore_gate_ring_v1.obj")
    end

    for ringIndex, radius in ipairs(gateMesh and { 18 } or { 19, 25 }) do
        for bead = 1, 12 do
            local angle = (bead / 12) * TAU
            local localOffset = Vector3.new(math.cos(angle) * radius, math.sin(angle) * radius, 0)
            utils.sphere(
                walkable,
                string.format("GateRing_%02d_%02d", ringIndex, bead),
                (gateFrame * CFrame.new(localOffset)).Position,
                bead % 3 == 0 and 5.6 or 4.4,
                ringIndex == 1 and COLORS.poreRing or COLORS.poreGate,
                0,
                ringIndex == 1 and Enum.Material.SmoothPlastic or Enum.Material.Neon
            )
        end
    end

    makePart(utils, walkable, "SelectiveGatePanel", {
        Size = Vector3.new(22, 16, 1.2),
        CFrame = gateFrame * CFrame.new(0, 0, -1.5),
        Color = COLORS.poreGate,
        Transparency = 0.52,
        Material = Enum.Material.Neon,
        CanCollide = false,
        CanTouch = false,
        CanQuery = false,
    })

    for index = 1, 24 do
        local angle = (index / 24) * TAU + 0.13
        if math.abs(math.cos(angle)) < 0.92 then
            local y = layout.baseY + 16 + (index % 5) * 10
            local position = ellipsePoint(center, angle, layout.radiusX + 2, layout.radiusZ + 2, y)
            local lookAt = Vector3.new(center.X, y, center.Z)
            local frame = CFrame.lookAt(position, lookAt)
            local pore = makePart(utils, visuals, string.format("VisualPore_%02d", index), {
                Shape = Enum.PartType.Cylinder,
                Size = Vector3.new(8 + (index % 3), 2.0, 8 + (index % 3)),
                CFrame = frame * CFrame.Angles(math.pi / 2, 0, 0),
                Color = COLORS.poreRing,
                Transparency = 0,
                Material = Enum.Material.SmoothPlastic,
                CanCollide = false,
                CanTouch = false,
                CanQuery = true,
                CastShadow = true,
            })
            utils.addPointLight(pore, COLORS.poreGate, 0.12, 15)
        end
    end

    return pores
end

local function buildNucleolus(utils, model, center, layout)
    local nucleolus = utils.model(model, "NucleolusCore")
    local coreCenter = center + Vector3.new(5, layout.levels[3].y + 10, 0)

    local core = makeMeshPart(nucleolus, "RibosomeBiogenesisHubMesh", NucleusMeshAssets.nucleolusCoreMeshId, {
        Size = Vector3.new(42, 68, 42),
        CFrame = CFrame.new(coreCenter),
        Color = COLORS.nucleolus,
        Material = Enum.Material.SmoothPlastic,
        Transparency = 0,
        CanCollide = false,
        CanQuery = true,
        CastShadow = true,
    })

    if core then
        core:SetAttribute("SourceAsset", "organelle_projects/04_nucleus/assets/mesh/nucleolus_core_v1.obj")
    else
        core = utils.ellipsoid(
            nucleolus,
            "RibosomeBiogenesisHub",
            coreCenter,
            Vector3.new(28, 56, 28),
            COLORS.nucleolus,
            0,
            Enum.Material.SmoothPlastic
        )
        core.CastShadow = true

        for index, offset in ipairs({
            Vector3.new(13, -12, 5),
            Vector3.new(-11, 5, -8),
            Vector3.new(7, 18, 10),
            Vector3.new(-8, 23, 4),
            Vector3.new(3, -25, -9),
        }) do
            utils.ellipsoid(
                nucleolus,
                string.format("NucleolusLobe_%02d", index),
                coreCenter + offset,
                Vector3.new(15 + index * 1.5, 12 + (index % 3) * 2, 14 + (index % 2) * 3),
                index % 2 == 0 and COLORS.nucleolusLight or blendColor(COLORS.nucleolus, COLORS.nucleolusLight, 0.32),
                0,
                Enum.Material.SmoothPlastic
            )
        end
    end
    utils.addPointLight(core, COLORS.nucleolusLight, 1.1, 72)

    for index, cluster in ipairs(NucleusSpec.nucleolusClusters) do
        if index <= 24 then
            local angle = (index / 24) * TAU
            local position = coreCenter + Vector3.new(math.cos(angle) * (12 + index % 4), -18 + (index % 9) * 5, math.sin(angle) * (11 + index % 3))
            utils.sphere(
                nucleolus,
                string.format("SubunitAssemblyMarker_%02d", index),
                position,
                math.max(cluster.size, 1.8),
                index % 2 == 0 and COLORS.transportSubunit or Color3.fromRGB(255, 150, 208),
                0.02,
                Enum.Material.Neon
            )
        end
    end

    return nucleolus, coreCenter
end

local function buildChromatinRoutes(utils, model, center, layout)
    local routes = utils.model(model, "GenomeRoutes")
    local cables = utils.folder(routes, "ChromatinCables")
    local markers = utils.folder(routes, "GeneActivationMarkers")

    local routeSpecs = {
        { name = "OpenChromatinGallery_A", y = layout.levels[2].y + 7, radiusX = layout.radiusX - 26, radiusZ = layout.radiusZ - 24, color = COLORS.chromatinA, phase = 0.0 },
        { name = "CondensedChromatinBundle_B", y = layout.levels[2].y + 18, radiusX = layout.radiusX - 34, radiusZ = layout.radiusZ - 30, color = COLORS.chromatinB, phase = 0.8 },
        { name = "MixedChromatinRoute_C", y = layout.levels[4].y + 5, radiusX = layout.radiusX - 40, radiusZ = layout.radiusZ - 34, color = COLORS.chromatinC, phase = 1.6 },
    }

    for routeIndex, route in ipairs(routeSpecs) do
        local points = {}
        for step = 0, 15 do
            local angle = (step / 15) * TAU + route.phase
            local wave = math.sin(step * 1.2 + route.phase) * 5
            points[#points + 1] = ellipsePoint(center, angle, route.radiusX + wave, route.radiusZ - wave * 0.35, route.y + math.sin(step * 0.9) * 3)
        end
        Geometry.buildPolyline(cables, utils, route.name, points, routeIndex == 2 and 1.45 or 1.0, route.color, 0, Enum.Material.SmoothPlastic)

        for markerIndex = 2, #points - 1, 5 do
            local marker = utils.sphere(
                markers,
                string.format("GeneMarker_%d_%02d", routeIndex, markerIndex),
                points[markerIndex] + Vector3.new(0, 2.5, 0),
                4.2,
                blendColor(route.color, Color3.fromRGB(255, 245, 182), 0.42),
                0,
                Enum.Material.Neon
            )
            utils.addPointLight(marker, route.color, 0.22, 18)
        end
    end

    return routes
end

local function buildTransportPaths(utils, model, center, layout, nucleolusCenter)
    local transport = utils.model(model, "TransportPaths")
    local poreExit = ellipsePoint(center, 0.08, layout.radiusX - 8, layout.radiusZ - 8, layout.levels[4].y + 8)
    local mrnaStart = center + Vector3.new(-24, layout.levels[2].y + 12, -14)
    local mrnaMid = center + Vector3.new(4, layout.levels[4].y + 8, 12)
    Geometry.buildPolyline(
        transport,
        utils,
        "MRNAExportPath",
        { mrnaStart, mrnaMid, poreExit },
        0.65,
        COLORS.transportMRNA,
        0,
        Enum.Material.Neon
    )
    Geometry.buildPolyline(
        transport,
        utils,
        "RibosomalSubunitExportPath",
        { nucleolusCenter + Vector3.new(0, 18, 0), center + Vector3.new(28, layout.levels[4].y + 10, -10), poreExit + Vector3.new(0, 7, 0) },
        0.85,
        COLORS.transportSubunit,
        0,
        Enum.Material.Neon
    )

    for index, position in ipairs({
        mrnaStart,
        mrnaMid,
        poreExit,
        nucleolusCenter + Vector3.new(0, 18, 0),
        center + Vector3.new(28, layout.levels[4].y + 10, -10),
    }) do
        utils.sphere(
            transport,
            string.format("TransportParticle_%02d", index),
            position,
            index <= 3 and 3.1 or 3.8,
            index <= 3 and COLORS.transportMRNA or COLORS.transportSubunit,
            0,
            Enum.Material.Neon
        )
    end

    return transport
end

function Nucleus.build(parent, utils, spec)
    local model = utils.model(parent, "Nucleus")
    local center = pointFromSpec(NucleusSpec.nucleusCenter)
    local hotspots = {}

    model:SetAttribute("OrganelleId", "nucleus")
    model:SetAttribute("DisplayName", "Nucleus")
    model:SetAttribute("BiologyRole", "Protected genome chamber with selective nuclear pore gates")
    model:SetAttribute("DesignMode", "FunctionalOrganicBuilding")
    model:SetAttribute("EducationalScale", "Walkable 4-level model, not literal microscopic scale")

    local layout = {
        radiusX = 82,
        radiusZ = 66,
        baseY = -34,
        wallHeight = 88,
        midY = 10,
        levels = {
            { name = "Level1_EnvelopeEntry", y = -30 },
            { name = "Level2_ChromatinGallery", y = -5 },
            { name = "Level3_NucleolusCore", y = 20 },
            { name = "Level4_TransportOverlook", y = 45 },
        },
    }

    local pivot = makePart(utils, model, "PivotCore", {
        Size = Vector3.new(2, 2, 2),
        CFrame = CFrame.new(center),
        Color = COLORS.collision,
        Transparency = 1,
        Material = Enum.Material.SmoothPlastic,
        CanCollide = false,
        CanTouch = false,
        CanQuery = false,
    })
    model.PrimaryPart = pivot

    buildNavigation(utils, model, center, layout)
    buildMeshEnvelope(utils, model, center, layout)
    buildPoreGate(utils, model, center, layout)
    buildChromatinRoutes(utils, model, center, layout)
    local _, nucleolusCenter = buildNucleolus(utils, model, center, layout)
    buildTransportPaths(utils, model, center, layout, nucleolusCenter)

    addHotspot(
        hotspots,
        "nucleus_envelope",
        "Nuclear Envelope",
        "This solid wall is an educational model of the double nuclear envelope: it protects DNA but stays connected to the cell through pores.",
        center + Vector3.new(-34, layout.levels[1].y + 8, -46),
        74
    )
    addHotspot(
        hotspots,
        "nuclear_pore_gate",
        "Nuclear Pore Gate",
        "Nuclear pores are selective gates. Small molecules pass easily, but large proteins and RNA cargo need the right transport signals.",
        ellipsePoint(center, 0, layout.radiusX, layout.radiusZ, layout.levels[1].y + 12),
        78
    )
    addHotspot(
        hotspots,
        "chromatin_gallery",
        "Chromatin Gallery",
        "Chromatin is DNA plus proteins. Open cable routes represent accessible genes; dense bundles represent more compact DNA packaging.",
        center + Vector3.new(-20, layout.levels[2].y + 10, 34),
        76
    )
    addHotspot(
        hotspots,
        "nucleolus_core",
        "Nucleolus Core",
        "The nucleolus is a dense non-membrane production hub where rRNA is made and ribosomal subunits begin assembly.",
        nucleolusCenter,
        78
    )
    addHotspot(
        hotspots,
        "transport_overlook",
        "Transport Overlook",
        "mRNA and ribosomal subunits leave the nucleus through pores, while DNA stays protected inside the chamber.",
        center + Vector3.new(20, layout.levels[4].y + 10, 22),
        82
    )

    return model, hotspots
end

return Nucleus
