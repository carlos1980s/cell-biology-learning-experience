local EnergyTransport = {}

local function scaledColor(color, factor)
    return Color3.new(
        math.clamp(color.R * factor, 0, 1),
        math.clamp(color.G * factor, 0, 1),
        math.clamp(color.B * factor, 0, 1)
    )
end

local function unitOrFallback(vector, fallback)
    if vector.Magnitude < 0.001 then
        return fallback
    end
    return vector.Unit
end

local function makeMitochondrion(parent, utils, spec, name, center, axis, size)
    local palette = spec.palette
    local model = utils.model(parent, name)
    local mainAxis = unitOrFallback(axis, Vector3.new(1, 0, 0))
    local upAxis = unitOrFallback(mainAxis:Cross(Vector3.new(0, 1, 0)), Vector3.new(0, 0, 1))
    local sideAxis = unitOrFallback(upAxis:Cross(mainAxis), Vector3.new(0, 1, 0))

    local outer = utils.ellipsoid(model, "OuterMembrane", center, size, palette.mitochondrion, 0.25, Enum.Material.SmoothPlastic)
    outer.CastShadow = false

    local inner = utils.ellipsoid(
        model,
        "InnerMembrane",
        center + mainAxis * 0.5,
        Vector3.new(size.X * 0.82, size.Y * 0.82, size.Z * 0.82),
        scaledColor(palette.mitochondrion, 1.1),
        0.48,
        Enum.Material.SmoothPlastic
    )
    inner.CastShadow = false

    local matrix = utils.ellipsoid(
        model,
        "Matrix",
        center,
        Vector3.new(size.X * 0.62, size.Y * 0.62, size.Z * 0.62),
        scaledColor(palette.mitochondrion, 0.78),
        0.62,
        Enum.Material.SmoothPlastic
    )
    matrix.CastShadow = false

    local width = math.max(size.X, size.Y) * 0.28
    local cristaOffsets = {
        -0.42,
        -0.16,
        0.12,
        0.34,
    }

    for index, offset in ipairs(cristaOffsets) do
        local centerLine = center + mainAxis * (offset * size.Z * 0.5)
        local cross = sideAxis * (width * 0.38)
        local bend = upAxis * (width * 0.2 * (index % 2 == 0 and 1 or -1))
        local startPoint = centerLine - cross + bend
        local endPoint = centerLine + cross - bend

        local crista = utils.cylinderBetween(
            model,
            string.format("Crista_%02d", index),
            startPoint,
            endPoint,
            math.max(size.Y * 0.07, 0.7),
            scaledColor(palette.mitochondrion, 1.12),
            0.22,
            Enum.Material.SmoothPlastic
        )
        if crista then
            crista.CastShadow = false
        end
    end

    local granuleOffsets = {
        Vector3.new(-0.22, 0.18, -0.06),
        Vector3.new(0.13, -0.12, 0.15),
        Vector3.new(0.04, 0.2, 0.2),
        Vector3.new(-0.1, -0.18, 0.06),
    }
    for index, offset in ipairs(granuleOffsets) do
        local granule = utils.sphere(
            model,
            string.format("Granule_%02d", index),
            center + Vector3.new(offset.X * size.X, offset.Y * size.Y, offset.Z * size.Z),
            math.max(size.Y * 0.14, 1.1),
            scaledColor(palette.mitochondrion, 1.2),
            0.42,
            Enum.Material.SmoothPlastic
        )
        granule.CastShadow = false
    end

    utils.addPointLight(model.PrimaryPart or outer, palette.mitochondrion, 0.55, math.max(size.Z * 1.2, 16))
    return model
end

local function makeGolgiCisternae(parent, utils, spec, center)
    local palette = spec.palette
    local model = utils.model(parent, "GolgiBody")
    local cisternaColor = palette.golgi
    local stackOffsets = {
        Vector3.new(-4, -4, -3),
        Vector3.new(-1, -2, -1),
        Vector3.new(2, 0, 1),
        Vector3.new(4, 2, 2),
        Vector3.new(6, 4, 3),
    }

    for index, offset in ipairs(stackOffsets) do
        local width = 24 + index * 2
        local thickness = 2.2 + (index % 2) * 0.35
        local cisterna = utils.part(model, string.format("Cisterna_%02d", index), {
            Shape = Enum.PartType.Cylinder,
            Size = Vector3.new(width, thickness, width),
            CFrame = CFrame.new(center + offset) * CFrame.Angles(math.rad(6 + index * 2), math.rad(10 - index * 3), math.rad(index * 11)),
            Color = scaledColor(cisternaColor, 0.98 - index * 0.03),
            Material = Enum.Material.SmoothPlastic,
        })
        cisterna.CastShadow = false
        if index == 1 then
            utils.addPointLight(cisterna, palette.golgi, 0.45, 22)
        end
    end

    local buddingPositions = {
        Vector3.new(16, -3, 7),
        Vector3.new(18, 0, 4),
        Vector3.new(20, 3, 1),
        Vector3.new(14, 5, -2),
    }
    for index, offset in ipairs(buddingPositions) do
        local vesicle = utils.sphere(
            model,
            string.format("BuddingVesicle_%02d", index),
            center + offset,
            4.2 + index * 0.3,
            scaledColor(palette.vesicle, 1.03),
            0.2,
            Enum.Material.SmoothPlastic
        )
        vesicle.CastShadow = false
        utils.addPointLight(vesicle, palette.vesicle, 0.15, 10)
    end

    local faceVesicles = {
        Vector3.new(-18, 2, -5),
        Vector3.new(-20, -1, -1),
    }
    for index, offset in ipairs(faceVesicles) do
        local vesicle = utils.sphere(
            model,
            string.format("FaceVesicle_%02d", index),
            center + offset,
            3.6,
            scaledColor(palette.golgi, 1.05),
            0.36,
            Enum.Material.SmoothPlastic
        )
        vesicle.CastShadow = false
    end

    return model
end

local function makeLysosome(parent, utils, spec, name, center, diameter)
    local palette = spec.palette
    local model = utils.model(parent, name)

    local body = utils.sphere(model, "Membrane", center, diameter, palette.lysosome, 0.18, Enum.Material.SmoothPlastic)
    body.CastShadow = false

    local core = utils.sphere(
        model,
        "DigestiveCore",
        center + Vector3.new(0.6, -0.4, 0.3),
        diameter * 0.58,
        scaledColor(palette.lysosome, 0.82),
        0.5,
        Enum.Material.SmoothPlastic
    )
    core.CastShadow = false

    local granules = {
        Vector3.new(-0.22, 0.14, -0.12),
        Vector3.new(0.15, -0.06, 0.16),
        Vector3.new(0.1, 0.18, -0.08),
    }
    for index, offset in ipairs(granules) do
        local dot = utils.sphere(
            model,
            string.format("EnzymeDot_%02d", index),
            center + Vector3.new(offset.X * diameter, offset.Y * diameter, offset.Z * diameter),
            math.max(diameter * 0.12, 0.8),
            scaledColor(palette.ribosome, 1.04),
            0.24,
            Enum.Material.SmoothPlastic
        )
        dot.CastShadow = false
    end

    utils.addPointLight(body, palette.lysosome, 0.35, diameter * 3.2)
    return model
end

local function makeVesicle(parent, utils, spec, name, center, diameter, fillColor, transparency)
    local model = utils.model(parent, name)
    local palette = spec.palette

    local shell = utils.sphere(model, "Shell", center, diameter, fillColor or palette.vesicle, transparency or 0.22, Enum.Material.SmoothPlastic)
    shell.CastShadow = false

    local cargo = utils.sphere(
        model,
        "Cargo",
        center + Vector3.new(0.4, -0.3, 0.25),
        diameter * 0.48,
        scaledColor(palette.ribosome, 1.06),
        0.55,
        Enum.Material.SmoothPlastic
    )
    cargo.CastShadow = false

    utils.addPointLight(shell, fillColor or palette.vesicle, 0.18, diameter * 2.1)
    return model
end

local function makeTransportParticles(parent, utils, spec, center)
    local palette = spec.palette
    local model = utils.model(parent, "TransportParticles")
    local points = {
        Vector3.new(-8, 0, -2),
        Vector3.new(-4, 0.9, 0),
        Vector3.new(0, 1.5, 1),
        Vector3.new(4, 1.8, 0),
        Vector3.new(8, 1.0, -1),
        Vector3.new(12, 0.3, -2),
        Vector3.new(16, -0.2, -2.5),
    }

    for index, offset in ipairs(points) do
        local particle = utils.sphere(
            model,
            string.format("Particle_%02d", index),
            center + offset,
            1.3 + (index % 2) * 0.2,
            scaledColor(palette.hotspot, 0.92 + index * 0.01),
            0.08,
            Enum.Material.Neon
        )
        particle.CastShadow = false
    end

    return model
end

function EnergyTransport.build(parent, utils, spec)
    local model = utils.model(parent, "EnergyTransport")
    local palette = spec.palette
    local origin = spec.worldCenter or Vector3.new()

    local mitochondriaFolder = utils.folder(model, "Mitochondria")
    local golgiFolder = utils.folder(model, "GolgiApparatus")
    local lysosomeFolder = utils.folder(model, "Lysosomes")
    local vesicleFolder = utils.folder(model, "Vesicles")

    local mitoOne = makeMitochondrion(
        mitochondriaFolder,
        utils,
        spec,
        "Mitochondrion_01",
        origin + Vector3.new(-112, 34, -68),
        Vector3.new(1, 0.08, 0.24),
        Vector3.new(22, 16, 48)
    )
    local mitoTwo = makeMitochondrion(
        mitochondriaFolder,
        utils,
        spec,
        "Mitochondrion_02",
        origin + Vector3.new(72, -42, 88),
        Vector3.new(-0.72, 0.2, 0.66),
        Vector3.new(20, 15, 44)
    )
    local mitoThree = makeMitochondrion(
        mitochondriaFolder,
        utils,
        spec,
        "Mitochondrion_03",
        origin + Vector3.new(106, 54, -54),
        Vector3.new(0.36, -0.12, 0.93),
        Vector3.new(21, 15, 46)
    )

    mitoOne.Parent = mitochondriaFolder
    mitoTwo.Parent = mitochondriaFolder
    mitoThree.Parent = mitochondriaFolder

    local golgiCenter = origin + Vector3.new(42, -8, -82)
    local golgi = makeGolgiCisternae(golgiFolder, utils, spec, golgiCenter)
    golgi.Parent = golgiFolder

    local lysosomeOne = makeLysosome(
        lysosomeFolder,
        utils,
        spec,
        "Lysosome_01",
        origin + Vector3.new(-96, -48, 78),
        13
    )
    local lysosomeTwo = makeLysosome(
        lysosomeFolder,
        utils,
        spec,
        "Lysosome_02",
        origin + Vector3.new(96, -72, 30),
        11
    )
    lysosomeOne.Parent = lysosomeFolder
    lysosomeTwo.Parent = lysosomeFolder

    local vesicleA = makeVesicle(
        vesicleFolder,
        utils,
        spec,
        "TransportVesicle_01",
        origin + Vector3.new(78, 12, -42),
        8.8,
        scaledColor(palette.vesicle, 1.02),
        0.18
    )
    local vesicleB = makeVesicle(
        vesicleFolder,
        utils,
        spec,
        "SmallVacuole_01",
        origin + Vector3.new(-66, 42, -20),
        12.5,
        scaledColor(palette.vesicle, 0.92),
        0.36
    )
    local vesicleC = makeVesicle(
        vesicleFolder,
        utils,
        spec,
        "TransportVesicle_02",
        origin + Vector3.new(122, 22, -92),
        8.2,
        scaledColor(palette.vesicle, 1.08),
        0.14
    )
    vesicleA.Parent = vesicleFolder
    vesicleB.Parent = vesicleFolder
    vesicleC.Parent = vesicleFolder

    local transportParticles = makeTransportParticles(model, utils, spec, golgiCenter)
    transportParticles.Parent = model

    return model, {
        {
            id = "mitochondria",
            title = "Mitochondria",
            body = "Mitochondria release usable energy from food. Their folded inner membrane gives extra room for this work.",
            position = origin + Vector3.new(-112, 34, -68),
        },
        {
            id = "golgi",
            title = "Golgi Body",
            body = "The Golgi body sorts and packages cell materials into vesicles so they reach the right place.",
            position = golgiCenter,
        },
        {
            id = "lysosomes",
            title = "Lysosomes",
            body = "Lysosomes hold digestive enzymes that break down worn-out parts and large food pieces.",
            position = origin + Vector3.new(96, -72, 30),
        },
        {
            id = "vesicles",
            title = "Vesicles",
            body = "Vesicles are tiny membrane bubbles that carry cargo around the cell or help release it.",
            position = origin + Vector3.new(78, 12, -42),
        },
    }
end

return EnergyTransport
