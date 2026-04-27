local Geometry = require(script.Parent.Parent.Builders.OrganicGeometry)
local EnergySpec = require(script.Parent.Parent.Data.Generated.EnergySpec)

local Mitochondria = {}

local function scaledColor(color, factor)
    return Color3.new(
        math.clamp(color.R * factor, 0, 1),
        math.clamp(color.G * factor, 0, 1),
        math.clamp(color.B * factor, 0, 1)
    )
end

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

local function setMotionAttributes(instance, center, axis, phase, amplitude, frequency, lateralAmplitude, pulseAmplitude)
    instance:SetAttribute("MotionCenter", center)
    instance:SetAttribute("MotionAxis", axis)
    instance:SetAttribute("MotionPhase", phase)
    instance:SetAttribute("MotionAmplitude", amplitude)
    instance:SetAttribute("MotionFrequency", frequency)
    instance:SetAttribute("MotionLateralAmplitude", lateralAmplitude)
    instance:SetAttribute("PulseAmplitude", pulseAmplitude)
end

local function annotateRibbon(parts, phase, amplitude, pulseAmplitude)
    for partIndex, part in ipairs(parts) do
        part:SetAttribute("MotionPhase", phase + partIndex * 0.17)
        part:SetAttribute("MotionAmplitude", amplitude)
        part:SetAttribute("PulseAmplitude", pulseAmplitude)
    end
end

local function buildMitochondrion(parent, utils, mito, index, palette)
    local model = utils.model(parent, string.format("Mitochondrion_%02d", index))
    local center = pointFromSpec(mito.center)
    local axis = pointFromSpec(mito.axis).Unit
    local tangent, bitangent = Geometry.basisFromNormal(axis, 0)
    local membraneModel = utils.model(model, "Membranes")
    local cristaModel = utils.model(model, "Cristae")
    local matrixModel = utils.model(model, "MatrixDetails")
    local phase = index * 8.13

    model:SetAttribute("OrganelleType", "Mitochondrion")
    model:SetAttribute("CristaeDensity", #mito.cristae)
    setMotionAttributes(
        model,
        center,
        axis,
        phase,
        0.16 + (index % 3) * 0.02,
        0.2 + (index % 4) * 0.018,
        0.045 + (index % 2) * 0.01,
        0.03
    )

    for segmentIndex = 0, 7 do
        local alpha = segmentIndex / 7
        local offset = (alpha - 0.5) * mito.size[3] * 0.9
        local widthScale = 0.82 + math.sin(alpha * math.pi) * 0.34 + math.sin(index * 0.7 + alpha * math.pi * 3) * 0.05
        local wobble = tangent * math.sin(index * 0.9 + alpha * math.pi * 2) * 1.0 + bitangent * math.cos(index * 0.6 + alpha * math.pi * 1.8) * 0.75
        local position = center + axis * offset + wobble
        local outerSize = Vector3.new(
            mito.size[1] * widthScale * (1.02 + segmentIndex * 0.012),
            mito.size[2] * widthScale * (0.98 + math.abs(alpha - 0.5) * 0.08),
            mito.size[2] * widthScale * 0.92
        )

        local outerMembrane = utils.ellipsoid(
            membraneModel,
            string.format("OuterMembrane_%02d", segmentIndex),
            position,
            outerSize,
            scaledColor(palette.mitochondrion, 1.02 + alpha * 0.05),
            0.08,
            Enum.Material.SmoothPlastic
        )
        outerMembrane:SetAttribute("MotionPhase", phase + segmentIndex * 0.19)

        local intermembraneShell = utils.ellipsoid(
            membraneModel,
            string.format("IntermembraneShell_%02d", segmentIndex),
            position + bitangent * math.sin(alpha * math.pi * 3 + phase) * 0.35,
            Vector3.new(outerSize.X * 0.9, outerSize.Y * 0.82, outerSize.Z * 0.82),
            scaledColor(palette.mitochondrion, 0.86),
            0.22,
            Enum.Material.SmoothPlastic
        )
        intermembraneShell:SetAttribute("MotionPhase", phase + segmentIndex * 0.21 + 0.3)

        local innerMembrane = utils.ellipsoid(
            membraneModel,
            string.format("InnerMembrane_%02d", segmentIndex),
            position,
            Vector3.new(outerSize.X * 0.76, outerSize.Y * 0.68, outerSize.Z * 0.7),
            Color3.fromRGB(214, 102, 67),
            0.14,
            Enum.Material.SmoothPlastic
        )
        innerMembrane:SetAttribute("MotionPhase", phase + segmentIndex * 0.24 + 0.5)

        local matrixCore = utils.ellipsoid(
            membraneModel,
            string.format("MatrixCore_%02d", segmentIndex),
            position + tangent * math.sin(alpha * math.pi * 2 + phase) * 0.28,
            Vector3.new(outerSize.X * 0.56, outerSize.Y * 0.5, outerSize.Z * 0.54),
            Color3.fromRGB(143, 55, 41),
            0.34,
            Enum.Material.SmoothPlastic
        )
        matrixCore:SetAttribute("MotionPhase", phase + segmentIndex * 0.16 + 0.9)

        if segmentIndex % 2 == 1 then
            local pocket = utils.ellipsoid(
                matrixModel,
                string.format("MatrixPocket_%02d", segmentIndex),
                position + tangent * math.sin(alpha * math.pi * 4 + phase) * 1.25 + bitangent * 0.7,
                Vector3.new(outerSize.X * 0.22, outerSize.Y * 0.32, outerSize.Z * 0.28),
                Color3.fromRGB(232, 164, 108),
                0.3,
                Enum.Material.SmoothPlastic
            )
            pocket:SetAttribute("MotionPhase", phase + segmentIndex * 0.28)
        end
    end

    local lightAnchor = utils.part(model, "GlowAnchor", {
        Size = Vector3.new(1, 1, 1),
        CFrame = CFrame.new(center),
        Transparency = 1,
        Material = Enum.Material.SmoothPlastic,
        CanCollide = false,
        CanTouch = false,
        CanQuery = false,
    })
    lightAnchor.CastShadow = false
    utils.addPointLight(lightAnchor, Color3.fromRGB(255, 154, 96), 1.45, 92)
    lightAnchor:SetAttribute("MotionPhase", phase + 1.7)

    for cristaIndex, crista in ipairs(mito.cristae) do
        local centerLine = center + axis * (crista.offset * mito.size[3] * 0.94)
        local width = mito.size[1] * (0.34 + crista.width * 0.82)
        local depth = mito.size[2] * (0.32 + math.abs(crista.wave) * 0.18)
        local arch = bitangent * crista.wave * mito.size[2] * 0.26
        local sweep = tangent * width
        local cristaPhase = phase + cristaIndex * 0.53
        local outerFold = {
            centerLine - sweep * 0.84 + arch * 0.48 - axis * 0.9,
            centerLine - sweep * 0.3 + arch + bitangent * depth * 0.44,
            centerLine + arch * 0.16 + bitangent * depth,
            centerLine + sweep * 0.32 - arch * 0.18 + bitangent * depth * 0.5,
            centerLine + sweep * 0.84 - arch * 0.4 + axis * 0.9,
        }
        local innerFold = {
            centerLine - sweep * 0.56 + arch * 0.34,
            centerLine - sweep * 0.14 + arch * 0.72 + bitangent * depth * 0.5,
            centerLine + bitangent * depth * 0.78,
            centerLine + sweep * 0.18 - arch * 0.08 + bitangent * depth * 0.54,
            centerLine + sweep * 0.58 - arch * 0.22,
        }

        local outerRibbon = Geometry.buildRibbon(
            cristaModel,
            utils,
            string.format("Crista_%02d", cristaIndex),
            outerFold,
            2.6 + crista.width * 1.9,
            1.18,
            Color3.fromRGB(255, 204, 157),
            0.02,
            Enum.Material.SmoothPlastic,
            axis
        )
        annotateRibbon(outerRibbon, cristaPhase, 0.028, 0.035)

        local innerRibbon = Geometry.buildRibbon(
            cristaModel,
            utils,
            string.format("CristaCore_%02d", cristaIndex),
            innerFold,
            1.54 + crista.width,
            0.72,
            Color3.fromRGB(255, 228, 193),
            0.12,
            Enum.Material.SmoothPlastic,
            axis
        )
        annotateRibbon(innerRibbon, cristaPhase + 0.4, 0.024, 0.028)
    end

    for granuleIndex = 1, 4 do
        local angle = phase + (granuleIndex / 4) * math.pi * 2
        local radialOffset = tangent * math.cos(angle) * mito.size[1] * 0.17
            + bitangent * math.sin(angle) * mito.size[2] * 0.18
            + axis * ((granuleIndex - 2.5) * mito.size[3] * 0.08)
        local granule = utils.sphere(
            matrixModel,
            string.format("MatrixGranule_%02d", granuleIndex),
            center + radialOffset,
            math.max(mito.size[2] * 0.12, 1.2),
            Color3.fromRGB(248, 186, 140),
            0.26,
            Enum.Material.SmoothPlastic
        )
        granule:SetAttribute("MotionPhase", phase + granuleIndex * 0.61)
        granule:SetAttribute("PulseAmplitude", 0.05)
    end
end

function Mitochondria.build(parent, utils, spec)
    local model = utils.model(parent, "Mitochondria")
    local hotspots = {}

    model:SetAttribute("OrganelleType", "MitochondriaField")
    model:SetAttribute("BodyCount", #EnergySpec.mitochondria)

    for index, mito in ipairs(EnergySpec.mitochondria) do
        buildMitochondrion(model, utils, mito, index, spec.palette)
    end

    addHotspot(
        hotspots,
        "mitochondria",
        "Mitochondria",
        "Mitochondria convert energy from food into forms the cell can use, and their folded inner membranes increase working surface area.",
        pointFromSpec(EnergySpec.mitochondria[1].center),
        74
    )

    return model, hotspots
end

return Mitochondria
