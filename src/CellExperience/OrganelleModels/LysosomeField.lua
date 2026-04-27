local EnergySpec = require(script.Parent.Parent.Data.Generated.EnergySpec)

local LysosomeField = {}

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

function LysosomeField.build(parent, utils, spec)
    local model = utils.model(parent, "LysosomeField")
    local hotspots = {}

    model:SetAttribute("OrganelleType", "LysosomeField")
    model:SetAttribute("BodyCount", #EnergySpec.lysosomes)

    for index, lysosome in ipairs(EnergySpec.lysosomes) do
        local center = pointFromSpec(lysosome.position)
        local size = lysosome.size
        local phase = index * 6.47
        local lysosomeModel = utils.model(model, string.format("Lysosome_%02d", index))
        local driftAxis = unitOrFallback(Vector3.new(math.cos(phase), math.sin(phase * 0.7) * 0.35, math.sin(phase * 0.93)), Vector3.yAxis)
        local tangent = unitOrFallback(driftAxis:Cross(Vector3.yAxis), Vector3.xAxis)
        local bitangent = unitOrFallback(driftAxis:Cross(tangent), Vector3.zAxis)
        local membraneOffset = tangent * math.sin(phase * 0.8) * size * 0.12 + bitangent * math.cos(phase * 0.65) * size * 0.1

        setMotionAttributes(
            lysosomeModel,
            center,
            driftAxis,
            phase,
            0.11 + (index % 3) * 0.015,
            0.19 + (index % 4) * 0.014,
            0.03,
            0.04
        )
        lysosomeModel:SetAttribute("OrganelleType", "Lysosome")

        local membraneFilm = utils.ellipsoid(
            lysosomeModel,
            "MembraneFilm",
            center - membraneOffset * 0.18,
            Vector3.new(size * 1.14, size * 0.98, size * 1.08),
            scaledColor(spec.palette.lysosome, 1.08),
            0.34,
            Enum.Material.Glass
        )
        membraneFilm:SetAttribute("MotionPhase", phase + 0.3)

        local shell = utils.ellipsoid(
            lysosomeModel,
            "Shell",
            center,
            Vector3.new(size * 1.06, size * 0.92, size * 1.0),
            spec.palette.lysosome,
            0.12,
            Enum.Material.SmoothPlastic
        )
        shell:SetAttribute("MotionPhase", phase + 0.55)
        if index % 2 == 0 then
            utils.addPointLight(shell, Color3.fromRGB(236, 90, 132), 0.78, 42)
        end

        local membraneShoulder = utils.ellipsoid(
            lysosomeModel,
            "MembraneShoulder",
            center + membraneOffset,
            Vector3.new(size * 0.74, size * 0.5, size * 0.68),
            scaledColor(spec.palette.lysosome, 0.96),
            0.18,
            Enum.Material.SmoothPlastic
        )
        membraneShoulder:SetAttribute("MotionPhase", phase + 0.82)

        local acidicCore = utils.ellipsoid(
            lysosomeModel,
            "AcidicCore",
            center + Vector3.new(0.45, -0.28, 0.36) + membraneOffset * 0.2,
            Vector3.new(size * 0.7, size * 0.54, size * 0.62),
            Color3.fromRGB(171, 36, 72),
            0.26,
            Enum.Material.SmoothPlastic
        )
        acidicCore:SetAttribute("MotionPhase", phase + 1.05)

        local enzymeCloud = utils.ellipsoid(
            lysosomeModel,
            "EnzymeCloud",
            center - membraneOffset * 0.12 + driftAxis * (size * 0.08),
            Vector3.new(size * 0.46, size * 0.36, size * 0.4),
            Color3.fromRGB(224, 102, 130),
            0.42,
            Enum.Material.Glass
        )
        enzymeCloud:SetAttribute("MotionPhase", phase + 1.3)

        for lobeIndex, lobe in ipairs({
            tangent * (size * 0.2) + bitangent * (size * 0.06) - driftAxis * (size * 0.08),
            -tangent * (size * 0.18) - bitangent * (size * 0.08) + driftAxis * (size * 0.14),
            tangent * (size * 0.05) + bitangent * (size * 0.16) + driftAxis * (size * 0.1),
            -tangent * (size * 0.04) + bitangent * (size * 0.18) - driftAxis * (size * 0.12),
        }) do
            local lobePart = utils.ellipsoid(
                lysosomeModel,
                string.format("MembraneLobe_%02d", lobeIndex),
                center + lobe,
                Vector3.new(size * 0.42, size * 0.3, size * 0.38),
                scaledColor(spec.palette.lysosome, 0.92 + lobeIndex * 0.04),
                0.2,
                Enum.Material.SmoothPlastic
            )
            lobePart:SetAttribute("MotionPhase", phase + 1.45 + lobeIndex * 0.18)
        end

        for granuleIndex = 1, 6 do
            local angle = phase + (granuleIndex / 6) * math.pi * 2
            local offset = tangent * math.cos(angle) * size * 0.22
                + bitangent * math.sin(angle) * size * 0.18
                + driftAxis * (((granuleIndex % 3) - 1) * size * 0.08)
            local granule = utils.sphere(
                lysosomeModel,
                string.format("DigestiveGranule_%02d", granuleIndex),
                center + offset,
                size * (0.11 + (granuleIndex % 2) * 0.025),
                spec.palette.ribosome,
                0.12,
                Enum.Material.SmoothPlastic
            )
            granule:SetAttribute("MotionPhase", phase + 1.9 + granuleIndex * 0.14)
        end

        if index % 3 == 0 then
            local fusionBud = utils.sphere(
                lysosomeModel,
                "FusionBud",
                center + driftAxis * (size * 0.56) - tangent * (size * 0.12),
                size * 0.28,
                scaledColor(spec.palette.lysosome, 1.04),
                0.24,
                Enum.Material.Glass
            )
            fusionBud:SetAttribute("MotionPhase", phase + 2.4)
        end
    end

    addHotspot(
        hotspots,
        "lysosomes",
        "Lysosomes",
        "Lysosomes are acidic recycling compartments packed with enzymes that break down molecules and worn-out cell parts.",
        pointFromSpec(EnergySpec.lysosomes[2].position),
        72
    )

    return model, hotspots
end

return LysosomeField
