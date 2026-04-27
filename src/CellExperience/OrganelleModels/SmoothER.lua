local Geometry = require(script.Parent.Parent.Builders.OrganicGeometry)
local NucleusSpec = require(script.Parent.Parent.Data.Generated.NucleusSpec)

local SmoothER = {}

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

local function tangentAt(points, index)
    local delta
    if index <= 1 then
        delta = points[2] - points[1]
    elseif index >= #points then
        delta = points[#points] - points[#points - 1]
    else
        delta = points[index + 1] - points[index - 1]
    end

    if delta.Magnitude <= 0.01 then
        return Vector3.yAxis
    end

    return delta.Unit
end

local function buildTubulePath(parent, utils, namePrefix, points, radius, color, transparency)
    Geometry.buildPolyline(
        parent,
        utils,
        namePrefix,
        points,
        radius,
        color,
        transparency or 0,
        Enum.Material.SmoothPlastic
    )

    for nodeIndex = 2, #points - 1, 3 do
        utils.ellipsoid(
            parent,
            string.format("%s_Node_%02d", namePrefix, nodeIndex),
            points[nodeIndex],
            Vector3.new(radius * 2.3, radius * 1.85, radius * 2.15),
            blendColor(color, Color3.fromRGB(255, 241, 214), 0.22),
            math.max(0.02, (transparency or 0) - 0.02),
            Enum.Material.SmoothPlastic
        )
    end
end

local function buildLoopBranch(parent, utils, namePrefix, startPoint, endPoint, phase, radius, color)
    local delta = endPoint - startPoint
    if delta.Magnitude <= 0.01 then
        return
    end

    local span = delta.Magnitude
    local side, lift = Geometry.basisFromNormal(delta.Unit, phase)
    local sign = math.sin(phase * 1.7) >= 0 and 1 or -1
    local arcOffset = side * sign * (radius * 3.5 + span * 0.22) + lift * (radius * 1.8 + span * 0.06)
    local midpoint = startPoint:Lerp(endPoint, 0.5)
    local branchPoints = {
        startPoint,
        startPoint:Lerp(midpoint, 0.45) + arcOffset * 0.56,
        midpoint + arcOffset,
        midpoint:Lerp(endPoint, 0.55) + arcOffset * 0.48,
        endPoint,
    }

    buildTubulePath(parent, utils, namePrefix, branchPoints, radius, color, 0.1)
    utils.sphere(
        parent,
        namePrefix .. "_JunctionStart",
        startPoint,
        radius * 1.55,
        blendColor(color, Color3.fromRGB(255, 246, 225), 0.18),
        0.1,
        Enum.Material.SmoothPlastic
    )
    utils.sphere(
        parent,
        namePrefix .. "_JunctionEnd",
        endPoint,
        radius * 1.55,
        blendColor(color, Color3.fromRGB(255, 246, 225), 0.18),
        0.1,
        Enum.Material.SmoothPlastic
    )
end

local function buildTerminalTwig(parent, utils, namePrefix, anchorPoint, tangent, phase, radius, color)
    local side, lift = Geometry.basisFromNormal(tangent, phase)
    local sign = math.sin(phase) >= 0 and 1 or -1
    local branchPoints = {
        anchorPoint,
        anchorPoint + side * sign * (radius * 4.2) + lift * (radius * 1.1),
        anchorPoint + tangent * (radius * 3.6) + side * sign * (radius * 7.8) + lift * (radius * 2.2),
        anchorPoint + tangent * (radius * 5.8) + side * sign * (radius * 10.2) - lift * (radius * 0.7),
    }

    buildTubulePath(parent, utils, namePrefix, branchPoints, radius, color, 0.12)
    utils.sphere(
        parent,
        namePrefix .. "_Junction",
        anchorPoint,
        radius * 1.6,
        blendColor(color, Color3.fromRGB(255, 242, 214), 0.14),
        0.08,
        Enum.Material.SmoothPlastic
    )

    local tipAxis = branchPoints[#branchPoints] - branchPoints[#branchPoints - 1]
    return branchPoints[#branchPoints], tipAxis.Magnitude > 0.01 and tipAxis.Unit or tangent
end

local function buildBudCluster(parent, utils, namePrefix, centerPoint, axis, radius, vesicleColor, membraneColor)
    local side, lift = Geometry.basisFromNormal(axis, radius * 0.35)
    local neckPoint = centerPoint - axis * (radius * 1.55)
    utils.cylinderBetween(
        parent,
        namePrefix .. "_Neck",
        neckPoint,
        centerPoint,
        math.max(0.18, radius * 0.26),
        blendColor(membraneColor, vesicleColor, 0.28),
        0.18,
        Enum.Material.SmoothPlastic
    )
    utils.ellipsoid(
        parent,
        namePrefix .. "_Core",
        centerPoint,
        Vector3.new(radius * 3.1, radius * 2.35, radius * 2.8),
        vesicleColor,
        0.22,
        Enum.Material.Glass
    )
    utils.ellipsoid(
        parent,
        namePrefix .. "_LobeA",
        centerPoint + side * (radius * 0.72) - lift * (radius * 0.22),
        Vector3.new(radius * 1.52, radius * 1.1, radius * 1.34),
        blendColor(vesicleColor, Color3.fromRGB(255, 245, 252), 0.16),
        0.26,
        Enum.Material.Glass
    )
    utils.sphere(
        parent,
        namePrefix .. "_LobeB",
        centerPoint - side * (radius * 0.56) + lift * (radius * 0.34),
        radius * 0.92,
        blendColor(vesicleColor, membraneColor, 0.2),
        0.18,
        Enum.Material.SmoothPlastic
    )
end

function SmoothER.build(parent, utils, spec)
    local model = utils.model(parent, "SmoothER")
    local tubeModel = utils.model(model, "Tubules")
    local vesicleModel = utils.model(model, "Buds")
    local hotspots = {}

    setMotionAttributes(model, "Drift", 0.9, 0.78, 0.24, 0.2, Vector3.new(-0.12, 0.98, 0.16).Unit)
    setMotionAttributes(tubeModel, "Drift", 1.6, 0.48, 0.14, 0.19, Vector3.new(-0.08, 0.99, 0.1).Unit)
    setMotionAttributes(vesicleModel, "Pulse", 4.8, 0.18, 0.04, 0.26, Vector3.new(0.06, 1, -0.08).Unit)

    for index, branch in ipairs(NucleusSpec.smoothER) do
        local points = {}
        for _, point in ipairs(branch.points) do
            table.insert(points, pointFromSpec(point))
        end

        local networkModel = utils.model(tubeModel, string.format("Network_%02d", index))
        local budGroup = utils.model(vesicleModel, string.format("BudCluster_%02d", index))
        local axis = averageAxis(points)
        local branchColor = index % 2 == 0
            and blendColor(spec.palette.smoothER, Color3.fromRGB(255, 238, 214), 0.12)
            or spec.palette.smoothER
        local highlightColor = blendColor(branchColor, Color3.fromRGB(255, 247, 226), 0.24)
        setMotionAttributes(
            networkModel,
            "Drift",
            index * 0.72,
            0.46 + (index % 3) * 0.06,
            0.18,
            0.19 + (index % 4) * 0.01,
            axis
        )
        setMotionAttributes(
            budGroup,
            "Pulse",
            index * 0.58 + 3.1,
            0.14,
            0.03,
            0.24,
            axis
        )

        buildTubulePath(
            networkModel,
            utils,
            "MainTube",
            points,
            branch.radius,
            branchColor,
            0.08
        )

        if #points >= 7 then
            buildLoopBranch(
                networkModel,
                utils,
                "LoopA",
                points[3],
                points[7],
                index * 0.61,
                branch.radius * 0.72,
                highlightColor
            )
        end

        if #points >= 9 and index % 2 == 0 then
            buildLoopBranch(
                networkModel,
                utils,
                "LoopB",
                points[2],
                points[9],
                index * 0.61 + 1.2,
                branch.radius * 0.58,
                blendColor(branchColor, Color3.fromRGB(255, 229, 198), 0.18)
            )
        end

        local twigAnchorIndex = math.max(3, math.floor(#points * 0.5))
        local twigTipA, twigAxisA = buildTerminalTwig(
            networkModel,
            utils,
            "TwigA",
            points[twigAnchorIndex],
            tangentAt(points, twigAnchorIndex),
            index * 0.78 + 0.4,
            branch.radius * 0.62,
            highlightColor
        )
        buildBudCluster(
            budGroup,
            utils,
            "TwigBudA",
            twigTipA,
            twigAxisA,
            branch.radius * 0.72,
            spec.palette.vesicle,
            branchColor
        )

        if index % 3 ~= 0 then
            local twigAnchorIndexB = math.min(#points - 1, math.max(2, twigAnchorIndex - 2))
            local twigTipB, twigAxisB = buildTerminalTwig(
                networkModel,
                utils,
                "TwigB",
                points[twigAnchorIndexB],
                tangentAt(points, twigAnchorIndexB),
                index * 0.94 + 1.5,
                branch.radius * 0.5,
                blendColor(branchColor, Color3.fromRGB(255, 246, 229), 0.18)
            )
            buildBudCluster(
                budGroup,
                utils,
                "TwigBudB",
                twigTipB,
                twigAxisB,
                branch.radius * 0.58,
                spec.palette.vesicle,
                branchColor
            )
        end

        local budPoint = points[#points]
        buildBudCluster(
            budGroup,
            utils,
            "TerminalBud",
            budPoint,
            tangentAt(points, #points),
            1.45 + branch.radius * 0.48,
            spec.palette.vesicle,
            branchColor
        )
    end

    addHotspot(
        hotspots,
        "smooth_er",
        "Smooth ER",
        "The smooth endoplasmic reticulum helps build lipids, stores calcium, and processes chemicals.",
        pointFromSpec(NucleusSpec.smoothER[3].points[5]),
        62
    )

    return model, hotspots
end

return SmoothER
