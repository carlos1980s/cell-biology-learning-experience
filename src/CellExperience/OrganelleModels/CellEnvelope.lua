local Geometry = require(script.Parent.Parent.Builders.OrganicGeometry)
local MembraneProteins = require(script.Parent.Parent.Data.Generated.MembraneProteins)
local MembraneInterior = require(script.Parent.Parent.Data.Generated.MembraneInterior)

local CellEnvelope = {}
local LATITUDE_BANDS = 6
local LONGITUDE_BANDS = 8

local function addHotspot(hotspots, id, title, body, position, labelDistance)
    table.insert(hotspots, {
        id = id,
        title = title,
        body = body,
        position = position,
        labelDistance = labelDistance,
    })
end

local function surfacePoint(center, normal, distance, scale)
    return center + Vector3.new(
        normal.X * distance * scale.X,
        normal.Y * distance * scale.Y,
        normal.Z * distance * scale.Z
    )
end

local function fromOffset(center, offset, scale)
    return center + Vector3.new(offset[1] * scale.X, offset[2] * scale.Y, offset[3] * scale.Z)
end

local function colorLerp(a, b, t)
    return Color3.new(
        a.R + (b.R - a.R) * t,
        a.G + (b.G - a.G) * t,
        a.B + (b.B - a.B) * t
    )
end

local function ellipsoidSurfacePoint(center, scale, cellRadius, theta, phi)
    local sinPhi = math.sin(phi)
    local cosPhi = math.cos(phi)
    local localPoint = Vector3.new(
        math.cos(theta) * sinPhi * cellRadius * scale.X,
        cosPhi * cellRadius * scale.Y,
        math.sin(theta) * sinPhi * cellRadius * scale.Z
    )
    local normal = Vector3.new(
        localPoint.X / math.max(scale.X * scale.X, 0.001),
        localPoint.Y / math.max(scale.Y * scale.Y, 0.001),
        localPoint.Z / math.max(scale.Z * scale.Z, 0.001)
    )
    if normal.Magnitude < 0.001 then
        normal = Vector3.yAxis
    else
        normal = normal.Unit
    end
    return center + localPoint, normal
end

local function generateMembraneLipidField(spec)
    local center = spec.worldCenter
    local scale = spec.ellipsoidScale or Vector3.new(1, 1, 1)
    local cellRadius = spec.cellRadius
    local spacing = (spec.performance and spec.performance.membraneSurfaceSpacing) or 5.2
    local headDiameter = (spec.performance and spec.performance.membraneHeadDiameter) or 4.6
    local coreDiameter = (spec.performance and spec.performance.membraneCoreDiameter) or 3.1
    local surfaceJitter = (spec.performance and spec.performance.membraneSurfaceJitter) or 0.28
    local averageRadius = cellRadius * ((scale.X + scale.Y + scale.Z) / 3)
    local ringCount = math.max(56, math.floor((math.pi * averageRadius) / spacing))
    local lipids = {}

    for ringIndex = 0, ringCount do
        local phi = (ringIndex / ringCount) * math.pi
        local sinPhi = math.max(math.sin(phi), 0.03)
        local ringRadius = cellRadius * sinPhi * ((scale.X + scale.Z) * 0.5)
        local ringCircumference = math.max(ringRadius * math.pi * 2, spacing * 8)
        local pointCount = math.max(8, math.floor(ringCircumference / spacing + 0.5))
        local ringOffset = (ringIndex % 2) * 0.5 + math.noise(ringIndex * 0.09, 0.0, 2.0) * 0.35

        for pointIndex = 0, pointCount - 1 do
            local theta = ((pointIndex + ringOffset) / pointCount) * math.pi * 2
            theta += math.noise(ringIndex * 0.13, pointIndex * 0.11, 1.7) * (spacing / math.max(ringRadius, spacing * 2)) * 1.8
            local phiJitter = math.noise(ringIndex * 0.07, pointIndex * 0.09, 5.1) * (spacing / averageRadius) * 0.45
            local localPhi = math.clamp(phi + phiJitter, 0, math.pi)
            local surface, normal = ellipsoidSurfacePoint(center, scale, cellRadius, theta, localPhi)
            local tangent, bitangent = Geometry.basisFromNormal(normal, theta + ringIndex * 0.17)
            local jitterA = math.noise(ringIndex * 0.17, pointIndex * 0.31, 0.0) * surfaceJitter
            local jitterB = math.noise(ringIndex * 0.23, pointIndex * 0.27, 4.0) * surfaceJitter * 0.82
            local surfacePosition = surface + tangent * jitterA + bitangent * jitterB
            local variance = (math.noise(ringIndex * 0.11, pointIndex * 0.13, 7.0) + 1) * 0.5

            table.insert(lipids, {
                surface = surfacePosition,
                normal = normal,
                head = headDiameter * (0.92 + variance * 0.18),
                core = coreDiameter * (0.9 + variance * 0.14),
                phase = ringIndex * 0.19 + pointIndex * 0.07,
            })
        end
    end

    return lipids
end

local function buildLipidMolecule(parent, utils, thickness, lipid, index, colors)
    local normal = lipid.normal
    local tangent, bitangent = Geometry.basisFromNormal(normal, lipid.phase)
    local localSway = tangent * math.noise(index * 0.09, lipid.phase, 0.0) * 0.14
        + bitangent * math.noise(index * 0.07, lipid.phase, 3.2) * 0.12
    local outerPoint = lipid.surface + normal * 0.22 + localSway * 0.25
    local innerPoint = lipid.surface - normal * (thickness - 0.22) - localSway * 0.18
    local corePoint = lipid.surface - normal * (thickness * 0.5) + localSway * 0.08

    local outerTone = colorLerp(
        colors.outer,
        Color3.fromRGB(255, 192, 208),
        (math.noise(index * 0.05, lipid.phase, 1.0) + 1) * 0.09
    )
    local innerTone = colorLerp(
        colors.inner,
        Color3.fromRGB(255, 225, 154),
        (math.noise(index * 0.05, lipid.phase, 5.0) + 1) * 0.08
    )
    local coreTone = colorLerp(
        colors.tail,
        Color3.fromRGB(255, 213, 140),
        (math.noise(index * 0.05, lipid.phase, 9.0) + 1) * 0.06
    )

    local outer = utils.sphere(parent, string.format("Outer_%05d", index), outerPoint, lipid.head, outerTone, 0.01, Enum.Material.SmoothPlastic)
    outer.CastShadow = false
    outer.CanTouch = false
    outer.CanQuery = false

    local core = utils.sphere(parent, string.format("Core_%05d", index), corePoint, lipid.core, coreTone, 0.08, Enum.Material.SmoothPlastic)
    core.CastShadow = false
    core.CanTouch = false
    core.CanQuery = false

    local inner = utils.sphere(parent, string.format("Inner_%05d", index), innerPoint, lipid.head * 0.96, innerTone, 0.02, Enum.Material.SmoothPlastic)
    inner.CastShadow = false
    inner.CanTouch = false
    inner.CanQuery = false
end

local function buildProtein(parent, utils, center, scale, cellRadius, thickness, protein, index, colors)
    local normal = Vector3.new(protein.n[1], protein.n[2], protein.n[3]).Unit
    local tangent, bitangent = Geometry.basisFromNormal(normal, protein.twist)
    local channelModel = utils.model(parent, string.format("ProteinChannel_%03d", index))
    local outer = surfacePoint(center, normal, cellRadius - 0.4, scale)
    local inner = surfacePoint(center, normal, cellRadius - thickness + 0.4, scale)
    local mid = surfacePoint(center, normal, cellRadius - thickness * 0.5, scale)
    local ringRadius = 0.92 + protein.channelRadius * 0.18
    local beadDiameter = 0.72 + protein.channelRadius * 0.08

    for step = 0, 6 do
        local alpha = step / 6
        local position = outer:Lerp(inner, alpha)
        local edgeScale = (step == 0 or step == 6) and 1.08 or 0.94
        local core = utils.sphere(
            channelModel,
            string.format("Core_%02d", step),
            position,
            beadDiameter * edgeScale,
            colors.channel,
            0.08,
            Enum.Material.SmoothPlastic
        )
        core.CastShadow = false
        core.CanTouch = false
        core.CanQuery = false
    end

    for ringIndex, ringCenter in ipairs({ outer, mid, inner }) do
        for petal = 1, 6 do
            local angle = (petal / 6) * math.pi * 2
            local offset = tangent * math.cos(angle) * ringRadius + bitangent * math.sin(angle) * ringRadius
            local node = utils.sphere(
                channelModel,
                string.format("Ring_%02d_%02d", ringIndex, petal),
                ringCenter + offset,
                beadDiameter * (ringIndex == 2 and 0.78 or 0.9),
                ringIndex == 2 and colors.portal or colors.outer,
                ringIndex == 2 and 0.2 or 0.08,
                ringIndex == 2 and Enum.Material.Neon or Enum.Material.SmoothPlastic
            )
            node.CastShadow = false
            node.CanTouch = false
            node.CanQuery = false
        end
    end
end

local function buildReceptor(parent, utils, center, scale, cellRadius, receptor, index, colors)
    local normal = Vector3.new(receptor.n[1], receptor.n[2], receptor.n[3]).Unit
    local tangent, bitangent = Geometry.basisFromNormal(normal, receptor.twist)
    local base = surfacePoint(center, normal, cellRadius + 0.2, scale)
    local tip = surfacePoint(center, normal, cellRadius + receptor.stem * 0.3 + receptor.cap * 0.18, scale)
    local receptorModel = utils.model(parent, string.format("Receptor_%03d", index))

    for step = 0, 4 do
        local alpha = step / 4
        local position = base:Lerp(tip, alpha)
        local stem = utils.sphere(
            receptorModel,
            string.format("Stem_%02d", step),
            position,
            0.11 + alpha * 0.02,
            colors.stem,
            0.16,
            Enum.Material.SmoothPlastic
        )
        stem.CastShadow = false
        stem.CanTouch = false
        stem.CanQuery = false
    end

    for clusterIndex = 1, receptor.clusters do
        local angle = (clusterIndex / receptor.clusters) * math.pi * 2
        local radialOffset = tangent * math.cos(angle) * 0.28 + bitangent * math.sin(angle) * 0.28
        local node = utils.sphere(
            receptorModel,
            string.format("Cap_%02d", clusterIndex),
            tip + radialOffset + normal * (clusterIndex % 2 == 0 and 0.08 or 0.14),
            0.16 + (clusterIndex % 2) * 0.03,
            colors.cap,
            0.12,
            Enum.Material.SmoothPlastic
        )
        node.CastShadow = false
        node.CanTouch = false
        node.CanQuery = false
    end
end

local function buildCytoskeleton(parent, utils, center, scale, fibers, color)
    for index, fiber in ipairs(fibers) do
        local points = {}
        for _, point in ipairs(fiber.points) do
            table.insert(points, fromOffset(center, point, scale))
        end
        Geometry.buildPolyline(parent, utils, string.format("Fiber_%02d", index), points, fiber.radius, color, 0.14, Enum.Material.SmoothPlastic)
    end
end

local function longitudeFromNormal(normal)
    local planar = Vector3.new(normal.X, 0, normal.Z)
    if planar.Magnitude < 0.001 then
        return 0
    end

    local unit = planar.Unit
    local angle = math.acos(math.clamp(unit:Dot(Vector3.new(1, 0, 0)), -1, 1))
    if unit.Z < 0 then
        angle = math.pi * 2 - angle
    end
    return angle
end

local function sectorIndicesFromNormal(normal)
    local latitudeT = (math.asin(math.clamp(normal.Y, -1, 1)) + math.pi * 0.5) / math.pi
    local longitudeT = longitudeFromNormal(normal) / (math.pi * 2)
    local latitudeIndex = math.clamp(math.floor(latitudeT * LATITUDE_BANDS) + 1, 1, LATITUDE_BANDS)
    local longitudeIndex = math.clamp(math.floor(longitudeT * LONGITUDE_BANDS) + 1, 1, LONGITUDE_BANDS)
    return latitudeIndex, longitudeIndex
end

local function getOrCreateSector(sectors, parent, utils, normal)
    local latitudeIndex, longitudeIndex = sectorIndicesFromNormal(normal)
    local key = string.format("%02d_%02d", latitudeIndex, longitudeIndex)
    local sector = sectors[key]
    if sector then
        sector.normalSum += normal
        sector.count += 1
        return sector
    end

    local model = utils.model(parent, "Sector_" .. key)
    sector = {
        model = model,
        lipids = utils.model(model, "Lipids"),
        proteins = utils.model(model, "Proteins"),
        receptors = utils.model(model, "Receptors"),
        normalSum = normal,
        count = 1,
        latitudeIndex = latitudeIndex,
        longitudeIndex = longitudeIndex,
    }
    sectors[key] = sector
    return sector
end

local function finalizeSectorAttributes(sectors)
    for _, sector in pairs(sectors) do
        local averageNormal = sector.normalSum / math.max(sector.count, 1)
        if averageNormal.Magnitude < 0.001 then
            averageNormal = Vector3.new(1, 0, 0)
        else
            averageNormal = averageNormal.Unit
        end

        local phase = sector.latitudeIndex * 11.37 + sector.longitudeIndex * 7.91
        local amplitude = 0.03 + ((sector.latitudeIndex * 5 + sector.longitudeIndex * 3) % 5) * 0.008
        local frequency = 0.34 + ((sector.latitudeIndex + sector.longitudeIndex) % 4) * 0.02

        sector.model:SetAttribute("MembraneNormal", averageNormal)
        sector.model:SetAttribute("MembranePhase", phase)
        sector.model:SetAttribute("MembraneAmplitude", amplitude)
        sector.model:SetAttribute("MembraneLateralAmplitude", amplitude * 0.1)
        sector.model:SetAttribute("MembraneFrequency", frequency)
    end
end

local function addFlowEmitter(parent, utils, name, position, colors, acceleration, rate)
    local anchor = utils.part(parent, name .. "Anchor", {
        Size = Vector3.new(2, 2, 2),
        CFrame = CFrame.new(position),
        Transparency = 1,
        Material = Enum.Material.SmoothPlastic,
        CanCollide = false,
        CanTouch = false,
        CanQuery = false,
        CastShadow = false,
    })

    local attachment = utils.addAttachment(anchor, "Emitter")
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = name
    emitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, colors[1]),
        ColorSequenceKeypoint.new(1, colors[2]),
    })
    emitter.LightEmission = 0
    emitter.Lifetime = NumberRange.new(5.5, 8.5)
    emitter.Rate = rate
    emitter.Speed = NumberRange.new(0.03, 0.12)
    emitter.SpreadAngle = Vector2.new(38, 38)
    emitter.Acceleration = acceleration
    emitter.Drag = 3.6
    emitter.Rotation = NumberRange.new(0, 360)
    emitter.RotSpeed = NumberRange.new(-16, 16)
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.025),
        NumberSequenceKeypoint.new(0.55, 0.018),
        NumberSequenceKeypoint.new(1, 0.008),
    })
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(0.25, 0.58),
        NumberSequenceKeypoint.new(1, 1),
    })
    emitter.Parent = attachment
    return emitter
end

local function buildBoundaryVeil(parent, utils, center, scale, cellRadius, thickness, lipidSpec)
    for index, cluster in ipairs(lipidSpec) do
        if index % 12 == 0 then
            local normal = Vector3.new(cluster.n[1], cluster.n[2], cluster.n[3]).Unit
            local tangent, bitangent = Geometry.basisFromNormal(normal, cluster.twist)
            local distance = cellRadius - thickness - 0.4 - (index % 4) * 0.08
            local position = surfacePoint(center, normal, distance, scale)
                + tangent * cluster.spread * (index % 2 == 0 and 0.06 or -0.04)
                + bitangent * cluster.sway * 0.03

            local cloud = utils.sphere(
                parent,
                string.format("BoundaryCloud_%03d", index),
                position,
                0.04 + (index % 3) * 0.006,
                Color3.fromRGB(122, 146, 168),
                0.96,
                Enum.Material.Glass
            )
            cloud.CastShadow = false
            cloud.CanTouch = false
            cloud.CanQuery = false

            if index % 72 == 0 then
                local spark = utils.sphere(
                    parent,
                    string.format("BoundarySpark_%03d", index),
                    position + normal * 0.04,
                    0.016,
                    Color3.fromRGB(184, 206, 224),
                    0.92,
                    Enum.Material.Neon
                )
                spark.CastShadow = false
                spark.CanTouch = false
                spark.CanQuery = false
            end
        end
    end
end

local function buildMacroRelief(parent, utils, center, scale, cellRadius, thickness, index, relief)
    local normal = relief.normal.Unit
    local tangent, bitangent = Geometry.basisFromNormal(normal, relief.twist or 0)
    local position = surfacePoint(center, normal, cellRadius - thickness * 0.25 + relief.radialOffset, scale)
        + tangent * relief.offset.X
        + bitangent * relief.offset.Y

    local ridge = utils.part(parent, string.format("MacroRelief_%02d", index), {
        Shape = Enum.PartType.Ball,
        Size = relief.size,
        CFrame = CFrame.new(position) * CFrame.Angles(math.rad(relief.rotation.X), math.rad(relief.rotation.Y), math.rad(relief.rotation.Z)),
        Color = relief.color,
        Transparency = relief.transparency,
        Material = relief.material,
        CanCollide = false,
        CanTouch = false,
        CanQuery = false,
    })
    ridge.CastShadow = false

    local fold = utils.part(parent, string.format("MacroFold_%02d", index), {
        Shape = Enum.PartType.Ball,
        Size = relief.foldSize,
        CFrame = CFrame.new(position - normal * relief.foldInset + tangent * relief.foldShift.X + bitangent * relief.foldShift.Y)
            * CFrame.Angles(math.rad(relief.rotation.X * 0.5), math.rad(relief.rotation.Y - 10), math.rad(relief.rotation.Z + 8)),
        Color = relief.foldColor,
        Transparency = relief.foldTransparency,
        Material = Enum.Material.Glass,
        CanCollide = false,
        CanTouch = false,
        CanQuery = false,
    })
    fold.CastShadow = false
end

function CellEnvelope.build(parent, utils, spec)
    local model = utils.model(parent, "CellEnvelope")
    local center = spec.worldCenter
    local scale = spec.ellipsoidScale or Vector3.new(1, 1, 1)
    local cellRadius = spec.cellRadius
    local thickness = spec.membraneThickness
    local hotspots = {}

    local membraneModel = utils.model(model, "MembraneBilayer")
    local cytoplasmModel = utils.model(model, "Cytoplasm")
    local currentFieldModel = utils.model(cytoplasmModel, "CurrentField")
    local boundaryVeilModel = utils.model(cytoplasmModel, "BoundaryVeil")
    local cytoskeletonModel = utils.model(model, "Cytoskeleton")

    local colors = {
        outer = spec.palette.membraneOuter,
        inner = spec.palette.membraneInner,
        tail = Color3.fromRGB(255, 232, 185),
        channel = Color3.fromRGB(150, 206, 255),
        portal = Color3.fromRGB(253, 246, 161),
        stem = Color3.fromRGB(243, 231, 175),
        cap = Color3.fromRGB(247, 243, 236),
    }

    for index, field in ipairs({
        { offset = Vector3.new(-78, 42, 34), accel = Vector3.new(0.06, 0.02, 0.08), rate = 54 },
        { offset = Vector3.new(62, -18, -44), accel = Vector3.new(-0.08, 0.03, -0.06), rate = 62 },
        { offset = Vector3.new(-26, 58, -82), accel = Vector3.new(0.05, -0.02, 0.05), rate = 48 },
        { offset = Vector3.new(36, 34, 88), accel = Vector3.new(-0.05, 0.03, -0.05), rate = 56 },
        { offset = Vector3.new(94, 8, 26), accel = Vector3.new(-0.08, 0.02, 0.04), rate = 64 },
        { offset = Vector3.new(-96, -26, -18), accel = Vector3.new(0.07, 0.03, 0.03), rate = 50 },
    }) do
        addFlowEmitter(
            currentFieldModel,
            utils,
            string.format("CurrentEmitter_%02d", index),
            center + Vector3.new(field.offset.X * scale.X, field.offset.Y * scale.Y, field.offset.Z * scale.Z),
            { Color3.fromRGB(226, 247, 255), Color3.fromRGB(136, 231, 255) },
            field.accel,
            field.rate
        )
    end

    local membraneSectors = {}
    local lipidField = generateMembraneLipidField(spec)

    for index, lipid in ipairs(lipidField) do
        local normal = lipid.normal
        local sector = getOrCreateSector(membraneSectors, membraneModel, utils, normal)
        buildLipidMolecule(
            sector.lipids,
            utils,
            thickness,
            lipid,
            index,
            colors
        )
    end

    for index, protein in ipairs(MembraneProteins.proteins) do
        local normal = Vector3.new(protein.n[1], protein.n[2], protein.n[3]).Unit
        local sector = getOrCreateSector(membraneSectors, membraneModel, utils, normal)
        buildProtein(sector.proteins, utils, center, scale, cellRadius, thickness, protein, index, colors)
    end

    for index, receptor in ipairs(MembraneProteins.receptors) do
        local normal = Vector3.new(receptor.n[1], receptor.n[2], receptor.n[3]).Unit
        local sector = getOrCreateSector(membraneSectors, membraneModel, utils, normal)
        buildReceptor(sector.receptors, utils, center, scale, cellRadius, receptor, index, colors)
    end

    finalizeSectorAttributes(membraneSectors)
    buildBoundaryVeil(boundaryVeilModel, utils, center, scale, cellRadius, thickness, {})

    for index, particle in ipairs(MembraneInterior.floatingParticles) do
        if index % 48 == 0 then
            local position = fromOffset(center, particle.offset, scale)
            local diameter = particle.kind == "vesicle" and 0.022 or 0.012
            local speck = utils.sphere(
                cytoplasmModel,
                string.format("Particle_%03d", index),
                position,
                diameter,
                particle.kind == "vesicle" and spec.palette.vesicle or Color3.fromRGB(212, 228, 235),
                particle.kind == "vesicle" and 0.88 or 0.94,
                particle.kind == "vesicle" and Enum.Material.Glass or Enum.Material.SmoothPlastic
            )
            speck.CastShadow = false
            speck.CanTouch = false
            speck.CanQuery = false
        end
    end

    buildCytoskeleton(cytoskeletonModel, utils, center, scale, MembraneInterior.cytoskeletonFibers, spec.palette.cytoskeleton)

    addHotspot(
        hotspots,
        "membrane",
        "Cell Membrane",
        "A dynamic phospholipid bilayer packed with channels, receptors, and transport proteins that controls the cell boundary.",
        center + Vector3.new(cellRadius * scale.X, 0, 0),
        84
    )
    addHotspot(
        hotspots,
        "cytoplasm",
        "Cytoplasm",
        "The cell interior is a dense fluid full of dissolved molecules, suspended organelles, and constant traffic.",
        center + Vector3.new(36, -8, -16),
        76
    )
    addHotspot(
        hotspots,
        "cytoskeleton",
        "Cytoskeleton",
        "Interlocking protein filaments brace the cell, resist deformation, and help move cargo from region to region.",
        center + Vector3.new(-78, -24, 62),
        76
    )

    return model, hotspots
end

return CellEnvelope
