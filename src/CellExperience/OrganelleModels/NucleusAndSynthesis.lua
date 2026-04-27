local CellExperience = script.Parent.Parent
local DefaultUtils = require(CellExperience.BuildUtils)
local CellSpec = require(CellExperience.CellSpec)

local Module = {}

local function scaleValue(spec, value)
    local baseRadius = CellSpec.cellRadius
    local currentRadius = (spec and spec.cellRadius) or baseRadius
    return value * (currentRadius / baseRadius)
end

local function makeAnchor(utils, parent, name, position)
    return utils.part(parent, name, {
        Anchored = true,
        CanCollide = false,
        CanTouch = false,
        CanQuery = false,
        Transparency = 1,
        Size = Vector3.new(1, 1, 1),
        CFrame = CFrame.new(position),
    })
end

local function rotateOffset(origin, rotation, offset)
    return origin + rotation:VectorToWorldSpace(offset)
end

local function createLoop(utils, parent, name, center, rotation, radiusX, radiusY, rise, thickness, color, transparency, material, segments)
    local loopFolder = utils.folder(parent, name)
    local points = {}

    for i = 0, segments do
        local t = i / segments
        local angle = t * math.pi * 2
        local wobble = math.sin(angle * 2.0 + 0.35) * rise
        local localPoint = Vector3.new(
            math.cos(angle) * radiusX,
            wobble,
            math.sin(angle) * radiusY
        )
        points[#points + 1] = rotateOffset(center, rotation, localPoint)
    end

    for i = 1, #points - 1 do
        utils.cylinderBetween(loopFolder, name .. "Segment" .. i, points[i], points[i + 1], thickness, color, transparency, material)
    end

    return loopFolder, points
end

local function addRibosome(utils, parent, label, position, size, color)
    local bead = utils.sphere(parent, label, position, size, color, 0, Enum.Material.SmoothPlastic)
    bead.CastShadow = true
    return bead
end

local function chromatinStrand(utils, parent, name, center, rotation, radiusX, radiusY, height, color)
    local strandFolder = utils.folder(parent, name)
    local points = {}
    local segments = 14

    for i = 0, segments do
        local t = i / segments
        local angle = (t * math.pi * 2) + 0.35
        local ripple = math.sin(t * math.pi * 4 + 0.15) * height * 0.28
        local twist = math.cos(t * math.pi * 3 + 0.55) * height * 0.12
        local localPoint = Vector3.new(
            math.cos(angle) * radiusX + twist,
            math.sin(t * math.pi * 2 + 0.2) * height * 0.45 + ripple,
            math.sin(angle) * radiusY
        )
        points[#points + 1] = rotateOffset(center, rotation, localPoint)
    end

    for i = 1, #points - 1 do
        utils.cylinderBetween(strandFolder, name .. "Link" .. i, points[i], points[i + 1], 1.15, color, 0.08, Enum.Material.SmoothPlastic)
    end

    return strandFolder, points
end

local function pore(utils, parent, name, innerPoint, outerPoint, color)
    local part = utils.cylinderBetween(parent, name, innerPoint, outerPoint, 1.8, color, 0.18, Enum.Material.SmoothPlastic)
    if part then
        part.CastShadow = true
    end
    return part
end

function Module.build(parent, utils, spec)
    local U = utils or DefaultUtils
    local palette = (spec and spec.palette) or CellSpec.palette
    local center = (spec and spec.worldCenter) or CellSpec.worldCenter

    local model = U.model(parent, "NucleusAndSynthesis")
    local root = makeAnchor(U, model, "CoreAnchor", center)
    model.PrimaryPart = root

    local nucleusCenter = center + Vector3.new(
        scaleValue(spec, -7),
        scaleValue(spec, 7),
        scaleValue(spec, 4)
    )

    local core = U.folder(model, "Core")
    local chromatin = U.folder(model, "Chromatin")
    local roughER = U.folder(model, "RoughER")
    local smoothER = U.folder(model, "SmoothER")
    local ribosomes = U.folder(model, "Ribosomes")

    local nucleusSize = Vector3.new(
        scaleValue(spec, 84),
        scaleValue(spec, 72),
        scaleValue(spec, 80)
    )
    local envelopeSize = Vector3.new(
        scaleValue(spec, 90),
        scaleValue(spec, 78),
        scaleValue(spec, 86)
    )
    local innerShellSize = Vector3.new(
        scaleValue(spec, 82),
        scaleValue(spec, 70),
        scaleValue(spec, 78)
    )

    local envelope = U.ellipsoid(core, "NuclearEnvelope", nucleusCenter, envelopeSize, Color3.fromRGB(183, 146, 245), 0.58, Enum.Material.Glass)
    envelope.CastShadow = false

    local envelopeInner = U.ellipsoid(core, "NuclearInnerShell", nucleusCenter, innerShellSize, Color3.fromRGB(120, 81, 189), 0.74, Enum.Material.SmoothPlastic)
    envelopeInner.CastShadow = false

    local nucleusBody = U.ellipsoid(core, "NucleusBody", nucleusCenter, nucleusSize, palette.nucleus, 0.18, Enum.Material.SmoothPlastic)
    nucleusBody.CastShadow = true

    local nucleolusCenter = nucleusCenter + Vector3.new(
        scaleValue(spec, 8),
        scaleValue(spec, -4),
        scaleValue(spec, 3)
    )
    local nucleolus = U.ellipsoid(core, "Nucleolus", nucleolusCenter, Vector3.new(
        scaleValue(spec, 24),
        scaleValue(spec, 20),
        scaleValue(spec, 24)
    ), palette.nucleolus, 0, Enum.Material.SmoothPlastic)
    nucleolus.CastShadow = true
    U.addPointLight(nucleolus, palette.nucleolus, 1.8, scaleValue(spec, 32))

    local poreAngles = {
        { 0.1, 0.0 },
        { 0.9, 0.25 },
        { 1.7, -0.2 },
        { 2.5, 0.1 },
        { 3.2, -0.28 },
        { 4.0, 0.16 },
        { 4.9, -0.08 },
        { 5.7, 0.22 },
    }
    local poreRadius = scaleValue(spec, 43)

    for i, pair in ipairs(poreAngles) do
        local azimuth = pair[1]
        local elevation = pair[2]
        local direction = Vector3.new(
            math.cos(azimuth) * math.cos(elevation),
            math.sin(elevation),
            math.sin(azimuth) * math.cos(elevation)
        ).Unit
        local innerPoint = nucleusCenter + direction * poreRadius
        local outerPoint = nucleusCenter + direction * scaleValue(spec, 49)
        pore(U, core, "NuclearPore" .. i, innerPoint, outerPoint, Color3.fromRGB(74, 53, 114))
    end

    local chromatinSpecs = {
        { "ChromatinStrandA", CFrame.Angles(0.36, 0.12, 0.18), scaleValue(spec, 22), scaleValue(spec, 15), scaleValue(spec, 12), Color3.fromRGB(216, 193, 255) },
        { "ChromatinStrandB", CFrame.Angles(-0.52, 1.12, -0.2), scaleValue(spec, 21), scaleValue(spec, 13), scaleValue(spec, 10), Color3.fromRGB(196, 171, 248) },
        { "ChromatinStrandC", CFrame.Angles(0.86, 2.3, 0.15), scaleValue(spec, 19), scaleValue(spec, 14), scaleValue(spec, 11), Color3.fromRGB(172, 143, 235) },
        { "ChromatinStrandD", CFrame.Angles(-0.34, 0.7, -0.42), scaleValue(spec, 18), scaleValue(spec, 12), scaleValue(spec, 9), Color3.fromRGB(205, 179, 251) },
    }

    for _, entry in ipairs(chromatinSpecs) do
        local _, points = chromatinStrand(U, chromatin, entry[1], nucleusCenter, entry[2], entry[3], entry[4], entry[5], entry[6])
        for i = 2, #points - 1, 4 do
            local beadColor = Color3.fromRGB(243, 236, 255)
            addRibosome(U, chromatin, entry[1] .. "Bead" .. i, points[i], scaleValue(spec, 2.2), beadColor)
        end
    end

    local roughColor = palette.roughER
    local smoothColor = palette.smoothER

    local roughLoops = {
        {
            name = "RoughERLoopA",
            rotation = CFrame.Angles(0.22, 0.1, 0.95),
            radiusX = scaleValue(spec, 66),
            radiusY = scaleValue(spec, 34),
            rise = scaleValue(spec, 5),
            thickness = scaleValue(spec, 3.8),
            transparency = 0.12,
        },
        {
            name = "RoughERLoopB",
            rotation = CFrame.Angles(-0.34, 1.42, 0.14),
            radiusX = scaleValue(spec, 58),
            radiusY = scaleValue(spec, 30),
            rise = scaleValue(spec, 4),
            thickness = scaleValue(spec, 3.4),
            transparency = 0.15,
        },
    }

    for index, entry in ipairs(roughLoops) do
        local _, points = createLoop(U, roughER, entry.name, nucleusCenter, entry.rotation, entry.radiusX, entry.radiusY, entry.rise, entry.thickness, roughColor, entry.transparency, Enum.Material.SmoothPlastic, 16)
        for i = 2, #points - 1, 2 do
            local radial = (points[i] - nucleusCenter)
            if radial.Magnitude > 0.01 then
                local ribosomePos = points[i] + radial.Unit * scaleValue(spec, 3.1)
                addRibosome(U, roughER, entry.name .. "Ribo" .. i, ribosomePos, scaleValue(spec, 1.9), palette.ribosome)
            end
        end
        if index == 1 then
            U.addPointLight(root, roughColor, 0.45, scaleValue(spec, 72))
        end
    end

    local smoothLoops = {
        {
            name = "SmoothERLoopA",
            rotation = CFrame.Angles(0.72, 2.1, -0.22),
            radiusX = scaleValue(spec, 60),
            radiusY = scaleValue(spec, 27),
            rise = scaleValue(spec, 4.5),
            thickness = scaleValue(spec, 3.0),
            transparency = 0.08,
        },
        {
            name = "SmoothERLoopB",
            rotation = CFrame.Angles(-0.18, 0.56, 0.88),
            radiusX = scaleValue(spec, 52),
            radiusY = scaleValue(spec, 25),
            rise = scaleValue(spec, 3.5),
            thickness = scaleValue(spec, 2.8),
            transparency = 0.11,
        },
    }

    for _, entry in ipairs(smoothLoops) do
        createLoop(U, smoothER, entry.name, nucleusCenter, entry.rotation, entry.radiusX, entry.radiusY, entry.rise, entry.thickness, smoothColor, entry.transparency, Enum.Material.SmoothPlastic, 16)
    end

    local freeRibosomePositions = {
        nucleusCenter + Vector3.new(scaleValue(spec, 73), scaleValue(spec, 14), scaleValue(spec, -12)),
        nucleusCenter + Vector3.new(scaleValue(spec, 61), scaleValue(spec, -18), scaleValue(spec, 24)),
        nucleusCenter + Vector3.new(scaleValue(spec, -54), scaleValue(spec, 9), scaleValue(spec, 18)),
        nucleusCenter + Vector3.new(scaleValue(spec, -68), scaleValue(spec, -12), scaleValue(spec, -16)),
        nucleusCenter + Vector3.new(scaleValue(spec, 22), scaleValue(spec, 26), scaleValue(spec, 58)),
        nucleusCenter + Vector3.new(scaleValue(spec, -18), scaleValue(spec, 18), scaleValue(spec, -60)),
    }

    for i, position in ipairs(freeRibosomePositions) do
        addRibosome(U, ribosomes, "FreeRibosome" .. i, position, scaleValue(spec, 2.1), palette.ribosome)
    end

    local hotspotPositions = {
        nucleus = nucleusCenter,
        nucleolus = nucleolusCenter,
        roughER = nucleusCenter + Vector3.new(scaleValue(spec, 56), scaleValue(spec, 0), scaleValue(spec, -4)),
        smoothER = nucleusCenter + Vector3.new(scaleValue(spec, -52), scaleValue(spec, 4), scaleValue(spec, 18)),
        ribosomes = freeRibosomePositions[1],
    }

    return model, {
        {
            id = "nucleus",
            title = "Nucleus",
            body = "The cell's control center. It protects DNA and helps decide which genes are active.",
            position = hotspotPositions.nucleus,
            labelDistance = 66,
        },
        {
            id = "nucleolus",
            title = "Nucleolus",
            body = "A dense region inside the nucleus where ribosome parts begin to assemble.",
            position = hotspotPositions.nucleolus,
            labelDistance = 56,
        },
        {
            id = "rough_er",
            title = "Rough ER",
            body = "Folded membranes covered with ribosomes. They help build and move proteins.",
            position = hotspotPositions.roughER,
            labelDistance = 62,
        },
        {
            id = "smooth_er",
            title = "Smooth ER",
            body = "A smoother membrane network that helps make lipids and process chemicals.",
            position = hotspotPositions.smoothER,
            labelDistance = 62,
        },
        {
            id = "ribosomes",
            title = "Ribosomes",
            body = "Tiny protein builders that read RNA instructions and join amino acids together.",
            position = hotspotPositions.ribosomes,
            labelDistance = 52,
        },
    }
end

return Module
