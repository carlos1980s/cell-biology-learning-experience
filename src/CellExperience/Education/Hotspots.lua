local Hotspots = {}

local function safeBody(text)
    if #text <= 145 then
        return text
    end
    return string.sub(text, 1, 142) .. "..."
end

function Hotspots.build(parent, utils, spec, hotspotSpecs)
    local model = utils.model(parent, "LearningHotspots")

    for index, hotspot in ipairs(hotspotSpecs) do
        local marker = utils.sphere(
            model,
            string.format("%02d_%s", index, hotspot.id or "hotspot"),
            hotspot.position,
            hotspot.size or 2.2,
            spec.palette.hotspot,
            0.78,
            Enum.Material.Glass
        )
        marker.CanCollide = false
        marker.CanTouch = false
        marker.CanQuery = false
        marker.CastShadow = false
        marker:SetAttribute("Title", hotspot.title)
        marker:SetAttribute("Body", hotspot.body)

        if hotspot.showLabel ~= false then
            local label = utils.billboard(model, marker.Name .. "_Label", marker, hotspot.title, safeBody(hotspot.body))
            label.MaxDistance = hotspot.labelDistance or 82
            label.Size = UDim2.fromOffset(210, 72)
            label.StudsOffsetWorldSpace = Vector3.new(0, 5.5, 0)
        end

        local prompt = Instance.new("ProximityPrompt")
        prompt.Name = "StudyPrompt"
        prompt.ActionText = "Study"
        prompt.ObjectText = hotspot.title
        prompt.HoldDuration = 0
        prompt.MaxActivationDistance = 20
        prompt.RequiresLineOfSight = false
        prompt.Parent = marker
    end

    return model
end

return Hotspots
