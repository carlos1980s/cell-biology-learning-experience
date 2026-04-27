local NucleusSpec = require(script.Parent.Parent.Data.Generated.NucleusSpec)

local Ribosomes = {}

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

function Ribosomes.build(parent, utils, spec)
    local model = utils.model(parent, "Ribosomes")
    local hotspots = {}
    local hotspotPosition

    for index, ribosome in ipairs(NucleusSpec.freeRibosomes) do
        if index % 4 == 0 then
            local offset = pointFromSpec(ribosome.offset)
            local position = offset + spec.worldCenter
            local cluster = utils.model(model, string.format("FreeRibosome_%03d", index))
            local baseDiameter = 0.2 + (index % 3) * 0.04

            for beadIndex, beadOffset in ipairs({
                Vector3.new(0, 0, 0),
                Vector3.new(0.12, 0.04, -0.08),
                Vector3.new(-0.1, -0.03, 0.07),
            }) do
                local bead = utils.sphere(
                    cluster,
                    string.format("Bead_%02d", beadIndex),
                    position + beadOffset,
                    baseDiameter - beadIndex * 0.02,
                    spec.palette.ribosome,
                    0.08,
                    Enum.Material.SmoothPlastic
                )
                bead.CastShadow = false
                bead.CanTouch = false
                bead.CanQuery = false
            end

            hotspotPosition = hotspotPosition or position
        end
    end

    addHotspot(
        hotspots,
        "ribosomes",
        "Ribosomes",
        "Ribosomes read RNA instructions and link amino acids together to build proteins.",
        hotspotPosition or (spec.worldCenter + pointFromSpec(NucleusSpec.freeRibosomes[18].offset)),
        50
    )

    return model, hotspots
end

return Ribosomes
