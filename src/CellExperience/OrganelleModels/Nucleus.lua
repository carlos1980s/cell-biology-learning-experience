local Geometry = require(script.Parent.Parent.Builders.OrganicGeometry)
local NucleusSpec = require(script.Parent.Parent.Data.Generated.NucleusSpec)

local Nucleus = {}

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

local function setMotionAttributes(instance, mode, phase, amplitude, lateral, frequency, axis)
    instance:SetAttribute("OrganelleMotionMode", mode)
    instance:SetAttribute("OrganelleMotionPhase", phase)
    instance:SetAttribute("OrganelleMotionAmplitude", amplitude)
    instance:SetAttribute("OrganelleMotionLateralAmplitude", lateral)
    instance:SetAttribute("OrganelleMotionFrequency", frequency)
    if axis then
        instance:SetAttribute("OrganelleMotionAxis", axis)
    end
end

local function buildPore(model, utils, center, scale, poreSpec, index, palette)
    local normal = Vector3.new(poreSpec.n[1], poreSpec.n[2], poreSpec.n[3]).Unit
    local tangent, bitangent = Geometry.basisFromNormal(normal, poreSpec.twist)
    local outer = surfacePoint(center, normal, 48, scale)
    local inner = surfacePoint(center, normal, 40, scale)
    local poreFolder = utils.folder(model, string.format("Pore_%03d", index))

    utils.cylinderBetween(poreFolder, "Channel", outer, inner, 1.2, Color3.fromRGB(254, 246, 176), 0.16, Enum.Material.Neon)

    for ringIndex = 1, 8 do
        local angle = (ringIndex / 8) * math.pi * 2
        local offset = tangent * math.cos(angle) * 3.2 + bitangent * math.sin(angle) * 3.2
        utils.sphere(poreFolder, "OuterRing_" .. ringIndex, outer + offset, 2.2, palette.nucleolus, 0.08, Enum.Material.SmoothPlastic)
        utils.sphere(poreFolder, "InnerRing_" .. ringIndex, inner + offset * 0.92, 1.9, palette.nucleus, 0.1, Enum.Material.SmoothPlastic)
        utils.cylinderBetween(poreFolder, "Spoke_" .. ringIndex, inner + offset * 0.85, outer + offset * 0.85, 0.24, Color3.fromRGB(226, 214, 255), 0.08, Enum.Material.SmoothPlastic)
    end

    local basketHubPosition = inner - normal * 6.1
    utils.sphere(
        poreFolder,
        "BasketHub",
        basketHubPosition,
        1.1,
        Color3.fromRGB(238, 226, 255),
        0.12,
        Enum.Material.SmoothPlastic
    )

    for filamentIndex = 1, 4 do
        local angle = ((filamentIndex - 0.5) / 4) * math.pi * 2 + poreSpec.twist * 0.35
        local offset = tangent * math.cos(angle) * 2.4 + bitangent * math.sin(angle) * 2.4
        local rimPoint = inner + offset * 0.88
        local basketPoint = inner + offset * 0.42 - normal * 4.2
        utils.sphere(
            poreFolder,
            "BasketAnchor_" .. filamentIndex,
            basketPoint,
            0.72,
            blendColor(palette.nucleus, Color3.fromRGB(247, 240, 255), 0.55),
            0.08,
            Enum.Material.SmoothPlastic
        )
        utils.cylinderBetween(
            poreFolder,
            "BasketFilament_" .. filamentIndex,
            rimPoint,
            basketPoint,
            0.11,
            Color3.fromRGB(236, 223, 255),
            0.1,
            Enum.Material.SmoothPlastic
        )
        utils.cylinderBetween(
            poreFolder,
            "BasketSpoke_" .. filamentIndex,
            basketPoint,
            basketHubPosition,
            0.08,
            Color3.fromRGB(223, 206, 255),
            0.12,
            Enum.Material.SmoothPlastic
        )
    end
end

local function buildEnvelopeBulges(model, utils, center, scale, palette)
    local bulgeNormals = {
        Vector3.new(0.88, 0.12, 0.18).Unit,
        Vector3.new(-0.76, 0.24, -0.34).Unit,
        Vector3.new(0.22, -0.64, 0.74).Unit,
        Vector3.new(-0.18, 0.58, 0.8).Unit,
        Vector3.new(0.54, -0.3, -0.78).Unit,
        Vector3.new(-0.44, -0.26, 0.86).Unit,
        Vector3.new(0.76, 0.44, -0.36).Unit,
        Vector3.new(-0.68, 0.5, 0.34).Unit,
    }

    for index, normal in ipairs(bulgeNormals) do
        local tangent, bitangent = Geometry.basisFromNormal(normal, index * 0.73)
        local position = surfacePoint(center, normal, 44 + (index % 2) * 2.2, scale)
        local bulge = utils.ellipsoid(
            model,
            string.format("EnvelopeBulge_%02d", index),
            position,
            Vector3.new(18 + index * 1.5, 13 + (index % 3) * 2.0, 15 + (index % 2) * 2.8),
            index % 2 == 0 and Color3.fromRGB(188, 150, 248) or palette.nucleus,
            0.34,
            Enum.Material.Glass
        )
        bulge.CastShadow = false

        utils.ellipsoid(
            model,
            string.format("EnvelopeShoulder_%02d", index),
            position - normal * 2.4 + tangent * (2.4 + (index % 3) * 0.6) + bitangent * ((index % 2 == 0 and 1 or -1) * 2.1),
            Vector3.new(10.6 + (index % 3), 8.8 + (index % 2) * 0.8, 9.4 + index * 0.25),
            blendColor(palette.nucleus, Color3.fromRGB(214, 190, 255), 0.42),
            0.42,
            Enum.Material.Glass
        )

        utils.ellipsoid(
            model,
            string.format("EnvelopePlaque_%02d", index),
            surfacePoint(center, normal, 40.6 + (index % 2) * 0.7, scale) + tangent * 2.1 - bitangent * 1.6,
            Vector3.new(7.8 + (index % 2) * 0.9, 5.4, 6.6 + (index % 3) * 0.7),
            blendColor(Color3.fromRGB(122, 88, 206), palette.nucleus, 0.35),
            0.28,
            Enum.Material.SmoothPlastic
        )
    end
end

local function buildIrregularNucleolus(model, utils, center, palette)
    local core = utils.ellipsoid(
        model,
        "NucleolusCore",
        center,
        Vector3.new(30, 24, 28),
        palette.nucleolus,
        0.02,
        Enum.Material.SmoothPlastic
    )
    utils.addPointLight(core, palette.nucleolus, 1.1, 28)

    for index, offset in ipairs({
        Vector3.new(8, -2, 3),
        Vector3.new(-7, 4, -4),
        Vector3.new(2, 7, 6),
        Vector3.new(-3, -6, 5),
    }) do
        utils.ellipsoid(
            model,
            string.format("NucleolusLobe_%02d", index),
            center + offset,
            Vector3.new(11 + index, 9 + (index % 2), 10 + (index % 3)),
            index % 2 == 0 and Color3.fromRGB(246, 120, 156) or Color3.fromRGB(255, 178, 205),
            0.04,
            Enum.Material.SmoothPlastic
        )
    end

    for index, offset in ipairs({
        Vector3.new(10, 3, -5),
        Vector3.new(-9, -4, 4),
        Vector3.new(5, -8, -2),
    }) do
        utils.ellipsoid(
            model,
            string.format("NucleolusCap_%02d", index),
            center + offset,
            Vector3.new(12.5 - index, 8.8 + index * 0.4, 10.2 + (index % 2) * 1.1),
            blendColor(palette.nucleolus, Color3.fromRGB(255, 225, 234), 0.38),
            0.28,
            Enum.Material.Glass
        )
    end
end

local function buildPeripheralChromatin(model, utils, center, scale, palette)
    local anchorNormals = {
        Vector3.new(0.68, 0.34, 0.64).Unit,
        Vector3.new(-0.72, 0.18, 0.67).Unit,
        Vector3.new(-0.63, -0.44, 0.64).Unit,
        Vector3.new(0.5, -0.56, 0.66).Unit,
        Vector3.new(0.78, 0.14, -0.6).Unit,
        Vector3.new(-0.7, 0.34, -0.63).Unit,
        Vector3.new(-0.2, -0.74, -0.64).Unit,
        Vector3.new(0.34, 0.7, -0.63).Unit,
    }

    for index, normal in ipairs(anchorNormals) do
        local tangent, bitangent = Geometry.basisFromNormal(normal, index * 0.59)
        local clusterCenter = surfacePoint(center, normal, 67 - (index % 3) * 2.5, scale)
        local mainColor = index % 2 == 0 and Color3.fromRGB(202, 178, 252) or Color3.fromRGB(169, 136, 235)
        for beadIndex, offset in ipairs({
            tangent * 2.6 + bitangent * 0.9,
            tangent * -2.1 + bitangent * 1.4,
            bitangent * -2.4,
        }) do
            utils.sphere(
                model,
                string.format("PeripheralChromatin_%02d_%02d", index, beadIndex),
                clusterCenter + offset,
                4.4 + (index % 2) * 0.7 - beadIndex * 0.45,
                beadIndex == 1 and mainColor or blendColor(mainColor, Color3.fromRGB(246, 239, 255), 0.25),
                0.08,
                Enum.Material.SmoothPlastic
            )
        end

        if index % 2 == 0 then
            utils.cylinderBetween(
                model,
                string.format("PeripheralBridge_%02d", index),
                clusterCenter + tangent * 2.2,
                clusterCenter - bitangent * 2.0,
                0.36,
                blendColor(palette.nucleus, Color3.fromRGB(245, 238, 255), 0.45),
                0.12,
                Enum.Material.SmoothPlastic
            )
        end
    end
end

function Nucleus.build(parent, utils, spec)
    local model = utils.model(parent, "Nucleus")
    local palette = spec.palette
    local scale = Vector3.new(1, 0.86, 0.95)
    local center = pointFromSpec(NucleusSpec.nucleusCenter)
    local hotspots = {}

    local shellModel = utils.model(model, "Envelope")
    local bulgeModel = utils.model(shellModel, "SurfaceBulges")
    local poreModel = utils.model(model, "PoreComplexes")
    local chromatinModel = utils.model(model, "Chromatin")
    local peripheralChromatinModel = utils.model(chromatinModel, "PeripheralCondensation")
    local nucleolusModel = utils.model(model, "Nucleolus")

    setMotionAttributes(model, "Pulse", 2.1, 0.58, 0.08, 0.14, Vector3.yAxis)
    setMotionAttributes(shellModel, "Pulse", 2.5, 0.34, 0.04, 0.12, Vector3.yAxis)
    setMotionAttributes(chromatinModel, "Drift", 5.4, 0.24, 0.11, 0.19, Vector3.new(0.18, 0.96, 0.11).Unit)
    setMotionAttributes(nucleolusModel, "Pulse", 1.2, 0.4, 0.04, 0.22, Vector3.new(-0.14, 0.98, 0.12).Unit)

    local outerShell = utils.ellipsoid(
        shellModel,
        "OuterEnvelope",
        center,
        Vector3.new(92 * scale.X, 92 * scale.Y, 92 * scale.Z),
        Color3.fromRGB(171, 132, 243),
        0.52,
        Enum.Material.Glass
    )
    outerShell.CastShadow = false

    local innerShell = utils.ellipsoid(
        shellModel,
        "InnerEnvelope",
        center,
        Vector3.new(84 * scale.X, 84 * scale.Y, 84 * scale.Z),
        palette.nucleus,
        0.72,
        Enum.Material.SmoothPlastic
    )
    innerShell.CastShadow = false

    local nucleusBody = utils.ellipsoid(
        shellModel,
        "Nucleoplasm",
        center,
        Vector3.new(78 * scale.X, 78 * scale.Y, 78 * scale.Z),
        Color3.fromRGB(108, 76, 188),
        0.24,
        Enum.Material.SmoothPlastic
    )
    nucleusBody.CastShadow = false
    utils.addPointLight(nucleusBody, Color3.fromRGB(124, 104, 212), 1.75, 160)

    buildEnvelopeBulges(bulgeModel, utils, center, scale, palette)
    buildPeripheralChromatin(peripheralChromatinModel, utils, center, scale, palette)

    for index, poreSpec in ipairs(NucleusSpec.pores) do
        buildPore(poreModel, utils, center, scale, poreSpec, index, palette)
    end

    for index, strand in ipairs(NucleusSpec.chromatin) do
        local points = {}
        for _, point in ipairs(strand.points) do
            table.insert(points, pointFromSpec(point))
        end
        Geometry.buildPolyline(
            chromatinModel,
            utils,
            string.format("Chromatin_%02d", index),
            points,
            strand.radius,
            index % 2 == 0 and Color3.fromRGB(222, 201, 255) or Color3.fromRGB(188, 160, 246),
            0.04,
            Enum.Material.SmoothPlastic
        )

        for pointIndex, point in ipairs(points) do
            if pointIndex % 2 == 0 then
                utils.sphere(
                    chromatinModel,
                    string.format("ChromatinBead_%02d_%02d", index, pointIndex),
                    point,
                    strand.bead * 2.2,
                    Color3.fromRGB(245, 237, 255),
                    0.1,
                    Enum.Material.SmoothPlastic
                )
            end

            if pointIndex > 1 and pointIndex < #points and pointIndex % 2 == 0 then
                local tangent = (points[pointIndex + 1] - points[pointIndex - 1]).Unit
                local orbitTangent, orbitBitangent = Geometry.basisFromNormal(tangent, index * 0.57 + pointIndex * 0.18)
                local satellitePosition = point
                    + orbitTangent * strand.bead * (1.3 + (index % 2) * 0.16)
                    + orbitBitangent * strand.bead * (0.95 + (pointIndex % 3) * 0.12)
                utils.sphere(
                    chromatinModel,
                    string.format("ChromatinSatellite_%02d_%02d", index, pointIndex),
                    satellitePosition,
                    strand.bead * 1.45,
                    blendColor(Color3.fromRGB(228, 213, 255), Color3.fromRGB(255, 248, 255), 0.35),
                    0.08,
                    Enum.Material.SmoothPlastic
                )
                utils.cylinderBetween(
                    chromatinModel,
                    string.format("ChromatinLink_%02d_%02d", index, pointIndex),
                    point,
                    satellitePosition,
                    strand.radius * 0.22,
                    Color3.fromRGB(213, 192, 252),
                    0.12,
                    Enum.Material.SmoothPlastic
                )
            end
        end
    end

    buildIrregularNucleolus(nucleolusModel, utils, pointFromSpec(NucleusSpec.nucleolusCenter), palette)

    for index, cluster in ipairs(NucleusSpec.nucleolusClusters) do
        utils.sphere(
            nucleolusModel,
            string.format("NucleolarGranule_%02d", index),
            pointFromSpec(cluster.position),
            cluster.size,
            index % 3 == 0 and Color3.fromRGB(255, 192, 213) or Color3.fromRGB(242, 120, 158),
            0.06,
            Enum.Material.SmoothPlastic
        )
    end

    addHotspot(
        hotspots,
        "nucleus",
        "Nucleus",
        "The nucleus stores DNA and coordinates the cell by controlling which genes are active.",
        center,
        64
    )
    addHotspot(
        hotspots,
        "nucleolus",
        "Nucleolus",
        "Inside the nucleus, the nucleolus assembles the components that will become ribosomes.",
        pointFromSpec(NucleusSpec.nucleolusCenter),
        54
    )

    return model, hotspots
end

return Nucleus
