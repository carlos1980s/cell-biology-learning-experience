local BuildUtils = {}

function BuildUtils.clearExisting(name)
    local existing = workspace:FindFirstChild(name)
    if existing then
        existing:Destroy()
    end
end

function BuildUtils.model(parent, name)
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = parent
    return model
end

function BuildUtils.folder(parent, name)
    local folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = parent
    return folder
end

function BuildUtils.part(parent, name, props)
    local part = Instance.new("Part")
    part.Name = name
    part.Anchored = props.Anchored ~= false
    part.CanCollide = props.CanCollide == true
    part.CanTouch = props.CanTouch == true
    part.CanQuery = props.CanQuery ~= false
    part.Material = props.Material or Enum.Material.SmoothPlastic
    part.Color = props.Color or Color3.new(1, 1, 1)
    part.Transparency = props.Transparency or 0
    part.CastShadow = props.CastShadow == true
    part.Size = props.Size or Vector3.new(4, 4, 4)
    part.CFrame = props.CFrame or CFrame.new()
    part.Shape = props.Shape or Enum.PartType.Block
    part.Parent = parent
    return part
end

function BuildUtils.sphere(parent, name, position, diameter, color, transparency, material)
    return BuildUtils.part(parent, name, {
        Shape = Enum.PartType.Ball,
        Size = Vector3.new(diameter, diameter, diameter),
        CFrame = CFrame.new(position),
        Color = color,
        Transparency = transparency or 0,
        Material = material or Enum.Material.SmoothPlastic,
    })
end

function BuildUtils.ellipsoid(parent, name, position, size, color, transparency, material)
    return BuildUtils.part(parent, name, {
        Shape = Enum.PartType.Ball,
        Size = size,
        CFrame = CFrame.new(position),
        Color = color,
        Transparency = transparency or 0,
        Material = material or Enum.Material.SmoothPlastic,
    })
end

function BuildUtils.cylinderBetween(parent, name, a, b, radius, color, transparency, material)
    local delta = b - a
    local length = delta.Magnitude
    if length < 0.01 then
        return nil
    end

    return BuildUtils.part(parent, name, {
        Shape = Enum.PartType.Cylinder,
        Size = Vector3.new(radius * 2, length, radius * 2),
        CFrame = CFrame.lookAt(a:Lerp(b, 0.5), b) * CFrame.Angles(math.pi / 2, 0, 0),
        Color = color,
        Transparency = transparency or 0,
        Material = material or Enum.Material.SmoothPlastic,
    })
end

function BuildUtils.billboard(parent, name, adornee, title, body)
    local gui = Instance.new("BillboardGui")
    gui.Name = name
    gui.Adornee = adornee
    gui.AlwaysOnTop = true
    gui.MaxDistance = 140
    gui.Size = UDim2.fromOffset(260, 86)
    gui.StudsOffsetWorldSpace = Vector3.new(0, 11, 0)

    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Color3.fromRGB(11, 24, 37)
    frame.BackgroundTransparency = 0.08
    frame.BorderSizePixel = 0
    frame.Size = UDim2.fromScale(1, 1)
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextColor3 = Color3.fromRGB(255, 248, 199)
    titleLabel.TextSize = 17
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = title
    titleLabel.Position = UDim2.fromOffset(12, 8)
    titleLabel.Size = UDim2.new(1, -24, 0, 22)
    titleLabel.Parent = frame

    local bodyLabel = Instance.new("TextLabel")
    bodyLabel.Name = "Body"
    bodyLabel.BackgroundTransparency = 1
    bodyLabel.Font = Enum.Font.Gotham
    bodyLabel.TextColor3 = Color3.fromRGB(232, 242, 250)
    bodyLabel.TextSize = 13
    bodyLabel.TextWrapped = true
    bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
    bodyLabel.TextYAlignment = Enum.TextYAlignment.Top
    bodyLabel.Text = body
    bodyLabel.Position = UDim2.fromOffset(12, 34)
    bodyLabel.Size = UDim2.new(1, -24, 1, -42)
    bodyLabel.Parent = frame

    gui.Parent = parent
    return gui
end

function BuildUtils.addPointLight(parent, color, brightness, range)
    local light = Instance.new("PointLight")
    light.Color = color
    light.Brightness = brightness
    light.Range = range
    light.Parent = parent
    return light
end

function BuildUtils.addAttachment(part, name, position)
    local attachment = Instance.new("Attachment")
    attachment.Name = name
    attachment.Position = position or Vector3.new()
    attachment.Parent = part
    return attachment
end

function BuildUtils.addBeam(parent, a0, a1, color, width, transparency)
    local beam = Instance.new("Beam")
    beam.Name = "Fiber"
    beam.Attachment0 = a0
    beam.Attachment1 = a1
    beam.Color = ColorSequence.new(color)
    beam.Width0 = width
    beam.Width1 = width
    beam.Transparency = NumberSequence.new(transparency or 0)
    beam.FaceCamera = true
    beam.Parent = parent
    return beam
end

return BuildUtils
