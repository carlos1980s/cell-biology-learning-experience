local Geometry = require(script.Parent.Parent.Builders.OrganicGeometry)
local NucleusSpec = require(script.Parent.Parent.Data.Generated.NucleusSpec)

local RoughER = {}

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

local function averageAxis(points)
    local total = Vector3.zero
    for index = 1, #points - 1 do
        local delta = points[index + 1] - points[index]
        if delta.Magnitude > 0.01 then
            total += delta.Unit
        end
    end

    if total.Magnitude <= 0.01 then
        return Vector3.yAxis
    end

    return total.Unit
end

local function segmentFrame(a, b, upHint)
    local delta = b - a
    if delta.Magnitude <= 0.01 then
        return CFrame.new(a)
    end

    local look = delta.Unit
    local midpoint = a:Lerp(b, 0.5)
    local up = upHint or Vector3.yAxis
    if math.abs(look:Dot(up.Unit)) > 0.97 then
        up = Vector3.xAxis
    end

    return CFrame.lookAt(midpoint, midpoint + look, up)
end

local function scatterPathFrames(points, step, upHint)
    local samples = {}
    for index = 1, #points - 1 do
        local a = points[index]
        local b = points[index + 1]
        local delta = b - a
        local length = delta.Magnitude
        if length > 0.01 then
            local frame = segmentFrame(a, b, upHint)
            local count = math.max(1, math.floor(length / step))
            for sampleIndex = 0, count do
                if not (index > 1 and sampleIndex == 0) then
                    local alpha = sampleIndex / count
                    table.insert(samples, {
                        position = a:Lerp(b, alpha),
                        tangent = delta.Unit,
                        right = frame.RightVector,
                        up = frame.UpVector,
                    })
                end
            end
        end
    end
    return samples
end

local function offsetRibbonPoints(points, sideOffset, liftOffset, phase)
    local shifted = {}
    for index, point in ipairs(points) do
        local tangent
        if index == 1 then
            tangent = (points[2] - point).Unit
        elseif index == #points then
            tangent = (point - points[#points - 1]).Unit
        else
            tangent = (points[index + 1] - points[index - 1]).Unit
        end

        local side, lift = Geometry.basisFromNormal(tangent, phase + index * 0.18)
        local lateralWave = math.sin(index * 0.92 + phase * 1.4)
        local verticalWave = math.cos(index * 0.64 + phase)
        table.insert(
            shifted,
            point
                + side * (sideOffset + lateralWave * math.max(0.18, math.abs(sideOffset) * 0.15))
                + lift * (liftOffset + verticalWave * math.max(0.26, math.abs(liftOffset) * 0.22))
        )
    end
    return shifted
end

local function buildRibosomeCluster(parent, utils, namePrefix, sample, baseRadius, palette, clusterIndex)
    local surfaceAnchor = sample.position + sample.up * (0.2 + baseRadius * 0.22)
    local clusterCenter = surfaceAnchor
        + sample.up * (0.24 + baseRadius * 0.26)
        + sample.right * (((clusterIndex % 3) - 1) * 0.12)

    local stalk = utils.cylinderBetween(
        parent,
        namePrefix .. "_Stalk",
        surfaceAnchor,
        clusterCenter,
        math.max(0.05, baseRadius * 0.12),
        Color3.fromRGB(248, 235, 205),
        0.16,
        Enum.Material.SmoothPlastic
    )
    if stalk then
        stalk.CastShadow = false
    end

    local beads = {
        {
            suffix = "Large",
            position = clusterCenter,
            diameter = 0.34 + baseRadius * 0.1,
        },
        {
            suffix = "Small",
            position = clusterCenter + sample.right * 0.18 + sample.up * 0.05 - sample.tangent * 0.07,
            diameter = 0.22 + baseRadius * 0.08,
        },
        {
            suffix = "Cap",
            position = clusterCenter - sample.right * 0.12 + sample.up * 0.11 + sample.tangent * 0.08,
            diameter = 0.17 + baseRadius * 0.06,
        },
    }

    for _, beadSpec in ipairs(beads) do
        local bead = utils.sphere(
            parent,
            string.format("%s_%s", namePrefix, beadSpec.suffix),
            beadSpec.position,
            beadSpec.diameter,
            beadSpec.suffix == "Large"
                and palette.ribosome
                or blendColor(palette.ribosome, Color3.fromRGB(255, 243, 231), 0.22),
            0.06,
            Enum.Material.SmoothPlastic
        )
        bead.CastShadow = false
        bead.CanTouch = false
        bead.CanQuery = false
    end
end

function RoughER.build(parent, utils, spec)
    local model = utils.model(parent, "RoughER")
    local ribbonModel = utils.model(model, "MembraneSheets")
    local ribosomeModel = utils.model(model, "BoundRibosomes")
    local hotspots = {}

    setMotionAttributes(model, "Undulate", 1.8, 0.82, 0.22, 0.18, Vector3.new(0.16, 0.98, 0.1).Unit)
    setMotionAttributes(ribbonModel, "Undulate", 2.4, 0.46, 0.12, 0.16, Vector3.new(0.12, 0.98, 0.14).Unit)
    setMotionAttributes(ribosomeModel, "Ripple", 5.7, 0.14, 0.06, 0.24, Vector3.new(-0.08, 0.99, 0.06).Unit)

    for index, ribbon in ipairs(NucleusSpec.roughER) do
        local points = {}
        for _, point in ipairs(ribbon.points) do
            table.insert(points, pointFromSpec(point))
        end

        local sheetGroup = utils.model(ribbonModel, string.format("Sheet_%02d", index))
        local ribosomeGroup = utils.model(ribosomeModel, string.format("RibosomeField_%02d", index))
        local axis = averageAxis(points)
        local foldPhase = index * 0.63
        local foldA = offsetRibbonPoints(points, ribbon.width * 0.15, ribbon.thickness * 0.64, foldPhase)
        local foldB = offsetRibbonPoints(points, -ribbon.width * 0.12, -ribbon.thickness * 0.56, foldPhase + 1.3)
        local rimOuter = offsetRibbonPoints(points, ribbon.width * 0.44, ribbon.thickness * 0.16, foldPhase + 0.2)
        local rimInner = offsetRibbonPoints(points, -ribbon.width * 0.42, ribbon.thickness * 0.12, foldPhase + 0.9)

        setMotionAttributes(
            sheetGroup,
            "Undulate",
            index * 0.54,
            0.44 + (index % 3) * 0.06,
            0.16,
            0.16 + (index % 4) * 0.01,
            axis
        )
        setMotionAttributes(
            ribosomeGroup,
            "Ripple",
            index * 0.81 + 4.0,
            0.12,
            0.04,
            0.24,
            axis
        )

        Geometry.buildRibbon(
            sheetGroup,
            utils,
            "CoreRibbon",
            points,
            ribbon.width,
            ribbon.thickness,
            spec.palette.roughER,
            0.1,
            Enum.Material.SmoothPlastic,
            Vector3.yAxis
        )

        Geometry.buildRibbon(
            sheetGroup,
            utils,
            "FoldRibbonA",
            foldA,
            ribbon.width * 0.84,
            ribbon.thickness * 0.86,
            blendColor(spec.palette.roughER, Color3.fromRGB(255, 239, 211), 0.16),
            0.14,
            Enum.Material.SmoothPlastic,
            Vector3.yAxis
        )
        Geometry.buildRibbon(
            sheetGroup,
            utils,
            "FoldRibbonB",
            foldB,
            ribbon.width * 0.76,
            ribbon.thickness * 0.8,
            blendColor(spec.palette.roughER, Color3.fromRGB(255, 246, 231), 0.22),
            0.18,
            Enum.Material.SmoothPlastic,
            Vector3.yAxis
        )
        Geometry.buildPolyline(
            sheetGroup,
            utils,
            "RimOuter",
            rimOuter,
            math.max(0.24, ribbon.thickness * 0.22),
            blendColor(spec.palette.roughER, Color3.fromRGB(255, 246, 229), 0.38),
            0.08,
            Enum.Material.SmoothPlastic
        )
        Geometry.buildPolyline(
            sheetGroup,
            utils,
            "RimInner",
            rimInner,
            math.max(0.22, ribbon.thickness * 0.2),
            blendColor(spec.palette.roughER, Color3.fromRGB(251, 221, 181), 0.24),
            0.12,
            Enum.Material.SmoothPlastic
        )

        for bridgeIndex = 2, #points - 1, 3 do
            utils.cylinderBetween(
                sheetGroup,
                string.format("FoldBridgeA_%02d", bridgeIndex),
                points[bridgeIndex],
                foldA[bridgeIndex],
                math.max(0.14, ribbon.thickness * 0.12),
                blendColor(spec.palette.roughER, Color3.fromRGB(255, 241, 214), 0.3),
                0.16,
                Enum.Material.SmoothPlastic
            )
            utils.cylinderBetween(
                sheetGroup,
                string.format("FoldBridgeB_%02d", bridgeIndex),
                foldA[bridgeIndex],
                foldB[bridgeIndex],
                math.max(0.12, ribbon.thickness * 0.1),
                blendColor(spec.palette.roughER, Color3.fromRGB(255, 230, 194), 0.24),
                0.18,
                Enum.Material.SmoothPlastic
            )
        end

        local ribosomeSamples = scatterPathFrames(foldA, 3.1, Vector3.yAxis)
        local clusterStep = math.max(1, math.floor(ribbon.ribosomeStep))
        for sampleIndex = 1, #ribosomeSamples, clusterStep do
            buildRibosomeCluster(
                ribosomeGroup,
                utils,
                string.format("BoundRibosome_%02d_%03d", index, sampleIndex),
                ribosomeSamples[sampleIndex],
                ribbon.thickness,
                spec.palette,
                sampleIndex
            )
        end
    end

    addHotspot(
        hotspots,
        "rough_er",
        "Rough ER",
        "The rough endoplasmic reticulum is a folded membrane factory lined with ribosomes that assemble many proteins.",
        pointFromSpec(NucleusSpec.roughER[3].points[6]),
        62
    )

    return model, hotspots
end

return RoughER
