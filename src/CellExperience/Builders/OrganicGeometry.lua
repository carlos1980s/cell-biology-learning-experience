local OrganicGeometry = {}

local function vec3(value)
    return Vector3.new(value[1], value[2], value[3])
end

local function basisFromNormal(normal, twist)
    local up = normal.Unit
    local seed = math.abs(up.Y) < 0.94 and Vector3.yAxis or Vector3.xAxis
    local tangent = seed:Cross(up).Unit
    local bitangent = up:Cross(tangent).Unit
    local ct = math.cos(twist or 0)
    local st = math.sin(twist or 0)
    local rotatedTangent = (tangent * ct + bitangent * st).Unit
    local rotatedBitangent = up:Cross(rotatedTangent).Unit
    return rotatedTangent, rotatedBitangent, up
end

local function segmentCFrame(a, b, upHint)
    local midpoint = a:Lerp(b, 0.5)
    local look = (b - a).Unit
    local up = upHint
    if math.abs(look:Dot(up.Unit)) > 0.97 then
        up = Vector3.xAxis
    end
    return CFrame.lookAt(midpoint, midpoint + look, up)
end

function OrganicGeometry.vec(value)
    return vec3(value)
end

function OrganicGeometry.basisFromNormal(normal, twist)
    return basisFromNormal(normal, twist)
end

function OrganicGeometry.placeBlockSegment(parent, utils, name, a, b, width, thickness, color, transparency, material, upHint)
    local delta = b - a
    local length = delta.Magnitude
    if length < 0.01 then
        return nil
    end

    return utils.part(parent, name, {
        Size = Vector3.new(width, thickness, length),
        CFrame = segmentCFrame(a, b, upHint or Vector3.yAxis),
        Color = color,
        Transparency = transparency or 0,
        Material = material or Enum.Material.SmoothPlastic,
        CanCollide = false,
        CanTouch = false,
        CanQuery = false,
    })
end

function OrganicGeometry.buildPolyline(parent, utils, namePrefix, points, radius, color, transparency, material)
    local parts = {}
    for index = 1, #points - 1 do
        local part = utils.cylinderBetween(
            parent,
            string.format("%s_%02d", namePrefix, index),
            points[index],
            points[index + 1],
            radius,
            color,
            transparency or 0,
            material or Enum.Material.SmoothPlastic
        )
        if part then
            table.insert(parts, part)
        end
    end
    return parts
end

function OrganicGeometry.buildRibbon(parent, utils, namePrefix, points, width, thickness, color, transparency, material, upHint)
    local parts = {}
    for index = 1, #points - 1 do
        local part = OrganicGeometry.placeBlockSegment(
            parent,
            utils,
            string.format("%s_%02d", namePrefix, index),
            points[index],
            points[index + 1],
            width,
            thickness,
            color,
            transparency or 0,
            material or Enum.Material.SmoothPlastic,
            upHint or Vector3.yAxis
        )
        if part then
            table.insert(parts, part)
        end
    end
    return parts
end

function OrganicGeometry.scatterAlongPath(points, step)
    local samples = {}
    for index = 1, #points - 1 do
        local a = points[index]
        local b = points[index + 1]
        local delta = b - a
        local length = delta.Magnitude
        local count = math.max(1, math.floor(length / step))
        for sampleIndex = 0, count do
            local alpha = sampleIndex / count
            table.insert(samples, a:Lerp(b, alpha))
        end
    end
    return samples
end

return OrganicGeometry
