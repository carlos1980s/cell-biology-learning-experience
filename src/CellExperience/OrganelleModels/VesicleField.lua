local EnergySpec = require(script.Parent.Parent.Data.Generated.EnergySpec)

local VesicleField = {}

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

function VesicleField.build(parent, utils, spec)
    local model = utils.model(parent, "VesicleField")
    local hotspots = {}

    model:SetAttribute("OrganelleType", "VesicleField")
    model:SetAttribute("BodyCount", #EnergySpec.vesicles)

    for index, vesicle in ipairs(EnergySpec.vesicles) do
        local center = pointFromSpec(vesicle.position)
        local diameter = vesicle.size
        local phase = index * 5.29 + vesicle.cargo * 0.9
        local vesicleModel = utils.model(model, string.format("Vesicle_%02d", index))
        local driftAxis = unitOrFallback(Vector3.new(math.cos(phase), math.sin(phase * 0.72) * 0.3, math.sin(phase)), Vector3.yAxis)
        local tangent = unitOrFallback(driftAxis:Cross(Vector3.yAxis), Vector3.xAxis)
        local bitangent = unitOrFallback(driftAxis:Cross(tangent), Vector3.zAxis)
        local membraneOffset = driftAxis * (diameter * 0.08) + tangent * (diameter * 0.05)

        setMotionAttributes(
            vesicleModel,
            center,
            driftAxis,
            phase,
            0.08 + (index % 3) * 0.012,
            0.21 + (index % 4) * 0.016,
            0.026,
            0.03
        )
        vesicleModel:SetAttribute("OrganelleType", "Vesicle")
        vesicleModel:SetAttribute("CargoLoaded", vesicle.cargo == 1)

        local membraneFilm = utils.ellipsoid(
            vesicleModel,
            "MembraneFilm",
            center - membraneOffset * 0.24,
            Vector3.new(diameter * 1.16, diameter * 0.96, diameter * 1.08),
            scaledColor(spec.palette.vesicle, 1.06),
            0.34,
            Enum.Material.Glass
        )
        membraneFilm:SetAttribute("MotionPhase", phase + 0.25)

        local shell = utils.ellipsoid(
            vesicleModel,
            "Shell",
            center,
            Vector3.new(diameter * 1.08, diameter * 0.9, diameter * 1.0),
            spec.palette.vesicle,
            0.18,
            Enum.Material.Glass
        )
        shell:SetAttribute("MotionPhase", phase + 0.48)

        local membraneShoulder = utils.ellipsoid(
            vesicleModel,
            "MembraneShoulder",
            center + membraneOffset,
            Vector3.new(diameter * 0.42, diameter * 0.32, diameter * 0.38),
            scaledColor(spec.palette.vesicle, 0.94),
            0.24,
            Enum.Material.Glass
        )
        membraneShoulder:SetAttribute("MotionPhase", phase + 0.74)

        local microBud = utils.sphere(
            vesicleModel,
            "MicroBud",
            center - tangent * (diameter * 0.32) + driftAxis * (diameter * 0.18),
            diameter * 0.22,
            scaledColor(spec.palette.vesicle, 1.02),
            0.28,
            Enum.Material.Glass
        )
        microBud:SetAttribute("MotionPhase", phase + 0.98)

        if vesicle.cargo == 1 then
            local cargoCore = utils.ellipsoid(
                vesicleModel,
                "CargoCore",
                center + membraneOffset * 0.34 + bitangent * (diameter * 0.08),
                Vector3.new(diameter * 0.48, diameter * 0.34, diameter * 0.4),
                spec.palette.hotspot,
                0.26,
                Enum.Material.Neon
            )
            cargoCore:SetAttribute("MotionPhase", phase + 1.2)
            utils.addPointLight(cargoCore, spec.palette.hotspot, 0.18, math.max(diameter * 3.4, 10))

            for packetIndex = 1, 2 do
                local angle = phase + packetIndex * math.pi
                local cargoPacket = utils.sphere(
                    vesicleModel,
                    string.format("CargoPacket_%02d", packetIndex),
                    center + tangent * math.cos(angle) * diameter * 0.16 + bitangent * math.sin(angle) * diameter * 0.12,
                    diameter * 0.16,
                    scaledColor(spec.palette.hotspot, 0.94),
                    0.2,
                    Enum.Material.Neon
                )
                cargoPacket:SetAttribute("MotionPhase", phase + 1.35 + packetIndex * 0.18)
            end
        else
            local aqueousCore = utils.ellipsoid(
                vesicleModel,
                "AqueousCore",
                center - membraneOffset * 0.18 + bitangent * (diameter * 0.05),
                Vector3.new(diameter * 0.34, diameter * 0.26, diameter * 0.28),
                Color3.fromRGB(201, 250, 240),
                0.36,
                Enum.Material.SmoothPlastic
            )
            aqueousCore:SetAttribute("MotionPhase", phase + 1.18)

            local soluteCloud = utils.ellipsoid(
                vesicleModel,
                "SoluteCloud",
                center + driftAxis * (diameter * 0.08),
                Vector3.new(diameter * 0.28, diameter * 0.2, diameter * 0.24),
                Color3.fromRGB(177, 235, 224),
                0.5,
                Enum.Material.Glass
            )
            soluteCloud:SetAttribute("MotionPhase", phase + 1.42)

            for granuleIndex = 1, 2 do
                local angle = phase + granuleIndex * math.pi * 0.9
                local granule = utils.sphere(
                    vesicleModel,
                    string.format("SoluteGranule_%02d", granuleIndex),
                    center + tangent * math.cos(angle) * diameter * 0.14 - bitangent * math.sin(angle) * diameter * 0.1,
                    diameter * 0.11,
                    Color3.fromRGB(215, 255, 246),
                    0.3,
                    Enum.Material.SmoothPlastic
                )
                granule:SetAttribute("MotionPhase", phase + 1.6 + granuleIndex * 0.2)
            end
        end
    end

    addHotspot(
        hotspots,
        "vesicles",
        "Vesicles",
        "Vesicles are membrane bubbles that shuttle cargo through the cytoplasm or deliver it to the cell surface.",
        pointFromSpec(EnergySpec.vesicles[5].position),
        72
    )

    return model, hotspots
end

return VesicleField
