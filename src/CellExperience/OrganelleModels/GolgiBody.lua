local Geometry = require(script.Parent.Parent.Builders.OrganicGeometry)
local EnergySpec = require(script.Parent.Parent.Data.Generated.EnergySpec)

local GolgiBody = {}

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

local function unitOrFallback(vector, fallback)
    if vector.Magnitude < 0.001 then
        return fallback
    end
    return vector.Unit
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

local function annotateParts(parts, phase, amplitude, pulseAmplitude)
    for partIndex, part in ipairs(parts) do
        part:SetAttribute("MotionPhase", phase + partIndex * 0.18)
        part:SetAttribute("MotionAmplitude", amplitude)
        part:SetAttribute("PulseAmplitude", pulseAmplitude)
    end
end

local function offsetPoints(points, verticalOffset, lateralAxis, lateralAmount)
    local shifted = {}
    for pointIndex, point in ipairs(points) do
        local alpha = (pointIndex - 1) / math.max(#points - 1, 1)
        local rimBias = 0.72 + math.sin(alpha * math.pi) * 0.28
        shifted[pointIndex] = point + Vector3.yAxis * verticalOffset + lateralAxis * lateralAmount * rimBias
    end
    return shifted
end

local function makeBudCluster(parent, utils, name, anchorPoint, direction, vesicleColor, stemColor, phase, budSize)
    local cluster = utils.model(parent, name)
    local driftAxis = unitOrFallback(direction, Vector3.xAxis)
    local sideAxis = unitOrFallback(driftAxis:Cross(Vector3.yAxis), Vector3.zAxis)
    local budCenter = anchorPoint + driftAxis * (budSize * 1.16)
    local stalkPoints = {
        anchorPoint - driftAxis * 0.9,
        anchorPoint + driftAxis * (budSize * 0.3) + Vector3.yAxis * 0.35,
        budCenter,
    }

    setMotionAttributes(cluster, budCenter, driftAxis, phase, 0.08, 0.26, 0.024, 0.022)
    Geometry.buildPolyline(
        cluster,
        utils,
        "Stem",
        stalkPoints,
        math.max(0.42, budSize * 0.12),
        scaledColor(stemColor, 0.92),
        0.1,
        Enum.Material.SmoothPlastic
    )

    local shell = utils.ellipsoid(
        cluster,
        "Shell",
        budCenter,
        Vector3.new(budSize * 1.72, budSize * 1.18, budSize * 1.5),
        vesicleColor,
        0.2,
        Enum.Material.Glass
    )
    shell:SetAttribute("MotionPhase", phase + 0.4)

    local membraneRidge = utils.ellipsoid(
        cluster,
        "MembraneRidge",
        budCenter + sideAxis * (budSize * 0.16),
        Vector3.new(budSize * 0.84, budSize * 0.46, budSize * 0.72),
        scaledColor(vesicleColor, 0.94),
        0.28,
        Enum.Material.Glass
    )
    membraneRidge:SetAttribute("MotionPhase", phase + 0.7)

    local lumen = utils.ellipsoid(
        cluster,
        "Lumen",
        budCenter - driftAxis * (budSize * 0.1),
        Vector3.new(budSize * 0.76, budSize * 0.48, budSize * 0.62),
        scaledColor(vesicleColor, 1.08),
        0.4,
        Enum.Material.SmoothPlastic
    )
    lumen:SetAttribute("MotionPhase", phase + 0.95)

    local satellite = utils.sphere(
        cluster,
        "Satellite",
        budCenter + sideAxis * (budSize * 0.88) - driftAxis * (budSize * 0.16),
        budSize * 0.42,
        vesicleColor,
        0.3,
        Enum.Material.Glass
    )
    satellite:SetAttribute("MotionPhase", phase + 1.18)

    return cluster
end

function GolgiBody.build(parent, utils, spec)
    local model = utils.model(parent, "GolgiBody")
    local stackModel = utils.model(model, "Stacks")
    local budModel = utils.model(model, "BuddingVesicles")
    local hotspots = {}
    local golgiCenter = pointFromSpec(EnergySpec.golgiCenter)
    local golgiColor = spec.palette.golgi or Color3.fromRGB(247, 191, 75)

    model:SetAttribute("OrganelleType", "Golgi")
    model:SetAttribute("StackCount", #EnergySpec.golgiCisternae)
    setMotionAttributes(model, golgiCenter, Vector3.yAxis, 12.8, 0.12, 0.2, 0.028, 0.025)

    local glowAnchor = utils.part(model, "GlowAnchor", {
        Size = Vector3.new(1, 1, 1),
        CFrame = CFrame.new(golgiCenter),
        Transparency = 1,
        Material = Enum.Material.SmoothPlastic,
        CanCollide = false,
        CanTouch = false,
        CanQuery = false,
    })
    glowAnchor.CastShadow = false
    utils.addPointLight(glowAnchor, Color3.fromRGB(255, 199, 112), 1.2, 84)

    for index, cisterna in ipairs(EnergySpec.golgiCisternae) do
        local points = {}
        for _, point in ipairs(cisterna.points) do
            table.insert(points, pointFromSpec(point))
        end
        local cisternaModel = utils.model(stackModel, string.format("Cisterna_%02d", index))
        local spanAxis = unitOrFallback(points[#points] - points[1], Vector3.xAxis)
        local lateralAxis = unitOrFallback(spanAxis:Cross(Vector3.yAxis), Vector3.zAxis)
        local cisternaCenter = points[math.ceil(#points / 2)]
        local phase = index * 1.41

        setMotionAttributes(
            cisternaModel,
            cisternaCenter,
            lateralAxis,
            phase,
            0.09 + index * 0.004,
            0.18 + (index % 3) * 0.014,
            0.022,
            0.018
        )

        local mainRibbon = Geometry.buildRibbon(
            cisternaModel,
            utils,
            "MainSac",
            points,
            cisterna.width,
            1.9,
            scaledColor(golgiColor, 1.03 - index * 0.012),
            0.04,
            Enum.Material.SmoothPlastic,
            Vector3.yAxis
        )
        annotateParts(mainRibbon, phase, 0.018, 0.02)

        local lumenRibbon = Geometry.buildRibbon(
            cisternaModel,
            utils,
            "Lumen",
            offsetPoints(points, 0.24, lateralAxis, -0.35),
            cisterna.width * 0.74,
            0.86,
            scaledColor(golgiColor, 1.12),
            0.16,
            Enum.Material.SmoothPlastic,
            Vector3.yAxis
        )
        annotateParts(lumenRibbon, phase + 0.35, 0.015, 0.018)

        local upperRim = Geometry.buildRibbon(
            cisternaModel,
            utils,
            "UpperRim",
            offsetPoints(points, 0.84, lateralAxis, 0.6),
            cisterna.width * 0.8,
            0.62,
            scaledColor(golgiColor, 1.18),
            0.08,
            Enum.Material.SmoothPlastic,
            Vector3.yAxis
        )
        annotateParts(upperRim, phase + 0.68, 0.014, 0.016)

        local lowerRim = Geometry.buildRibbon(
            cisternaModel,
            utils,
            "LowerRim",
            offsetPoints(points, -0.72, lateralAxis, -0.52),
            cisterna.width * 0.72,
            0.56,
            scaledColor(golgiColor, 0.88),
            0.14,
            Enum.Material.SmoothPlastic,
            Vector3.yAxis
        )
        annotateParts(lowerRim, phase + 0.92, 0.014, 0.016)

        for pointIndex = 3, #points - 2, 3 do
            local swelling = utils.ellipsoid(
                cisternaModel,
                string.format("Swelling_%02d", pointIndex),
                points[pointIndex] + lateralAxis * ((pointIndex % 2 == 0) and 1.05 or -0.8),
                Vector3.new(cisterna.width * 0.34, 2.2 + index * 0.04, cisterna.width * 0.48),
                scaledColor(golgiColor, 0.95 + pointIndex * 0.01),
                0.12,
                Enum.Material.SmoothPlastic
            )
            swelling:SetAttribute("MotionPhase", phase + pointIndex * 0.13)
        end

        local endPoint = points[#points]
        local transDirection = unitOrFallback(endPoint - points[#points - 1] + lateralAxis * 1.2 + Vector3.new(0.8, 0.1, 0.4), lateralAxis)
        makeBudCluster(
            budModel,
            utils,
            string.format("TransBud_%02d", index),
            endPoint,
            transDirection,
            spec.palette.vesicle,
            golgiColor,
            6 + phase,
            3.3 + index * 0.22
        )

        if index % 2 == 1 then
            local startPoint = points[1]
            local cisDirection = unitOrFallback(startPoint - points[2] - lateralAxis * 0.85 + Vector3.new(-0.4, 0.1, -0.3), -lateralAxis)
            makeBudCluster(
                budModel,
                utils,
                string.format("CisBud_%02d", index),
                startPoint,
                cisDirection,
                scaledColor(spec.palette.vesicle, 0.96),
                scaledColor(golgiColor, 1.06),
                10 + phase,
                2.5 + (index % 3) * 0.3
            )
        end
    end

    addHotspot(
        hotspots,
        "golgi",
        "Golgi Body",
        "The Golgi body sorts, modifies, and packages molecules into vesicles that travel to their next destination.",
        golgiCenter,
        72
    )

    return model, hotspots
end

return GolgiBody
