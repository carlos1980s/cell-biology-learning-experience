-- Standalone clean nucleus mesh prototype.
-- This file is the readable source; tools/deploy_nucleus_mesh_experience.py inlines OBJ-derived mesh tables at deploy time.

local AssetService = game:GetService("AssetService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")
local Workspace = game:GetService("Workspace")

local function clearScene()
    for _, child in ipairs(Workspace:GetChildren()) do
        if child ~= Workspace.Terrain and child.ClassName ~= "Camera" then
            child:Destroy()
        end
    end

    Workspace.Terrain:Clear()
    Lighting.ClockTime = 13.5
    Lighting.Brightness = 2
    Lighting.EnvironmentDiffuseScale = 0.5
    Lighting.EnvironmentSpecularScale = 0.25
end

local function part(parent, name, size, cframe, color, material)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = cframe
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function createEditableMeshPart(parent, name, meshData, color, cframe, material, options)
    options = options or {}
    local editableMesh = AssetService:CreateEditableMesh()
    local vertexIds = table.create(#meshData.vertices)

    for index, vertex in ipairs(meshData.vertices) do
        vertexIds[index] = editableMesh:AddVertex(Vector3.new(vertex[1], vertex[2], vertex[3]))
    end

    for _, face in ipairs(meshData.faces) do
        editableMesh:AddTriangle(vertexIds[face[1]], vertexIds[face[2]], vertexIds[face[3]])
        if options.twoSidedTriangles then
            editableMesh:AddTriangle(vertexIds[face[1]], vertexIds[face[3]], vertexIds[face[2]])
        end
    end

    local meshPart = AssetService:CreateMeshPartAsync(Content.fromObject(editableMesh), {
        CollisionFidelity = Enum.CollisionFidelity.Box,
        RenderFidelity = Enum.RenderFidelity.Precise,
    })
    meshPart.Name = name
    meshPart.Anchored = true
    meshPart.CFrame = cframe
    meshPart.Color = color
    meshPart.Material = material or Enum.Material.SmoothPlastic
    meshPart.CanCollide = false
    meshPart.CastShadow = options.castShadow ~= false
    meshPart.Transparency = options.transparency or 0
    if options.scale then
        meshPart.Size = meshPart.Size * options.scale
    end
    pcall(function()
        meshPart.DoubleSided = options.doubleSided ~= false
    end)
    meshPart.Parent = parent
    return meshPart
end

local function cylinderBetween(parent, name, p0, p1, diameter, color, material)
    local midpoint = (p0 + p1) / 2
    local distance = (p1 - p0).Magnitude
    local segment = part(parent, name, Vector3.new(distance, diameter, diameter), CFrame.lookAt(midpoint, p1) * CFrame.Angles(0, math.rad(90), 0), color, material or Enum.Material.SmoothPlastic)
    segment.Shape = Enum.PartType.Cylinder
    segment.CanCollide = false
    return segment
end

local function ball(parent, name, position, size, color, material)
    local b = part(parent, name, size, CFrame.new(position), color, material or Enum.Material.SmoothPlastic)
    b.Shape = Enum.PartType.Ball
    b.CanCollide = false
    return b
end

local function buildWalkableArchitecture(model)
    local floorColor = Color3.fromRGB(31, 28, 40)

    local levels = {
        {name = "EntryFloor", y = 1, size = Vector3.new(96, 2, 62), rot = -8, pos = Vector3.new(0, 0, 0)},
        {name = "ChromatinGalleryTerrace", y = 24, size = Vector3.new(54, 2, 32), rot = 18, pos = Vector3.new(-26, 0, -16)},
        {name = "NucleolusCoreTerrace", y = 48, size = Vector3.new(46, 2, 28), rot = -22, pos = Vector3.new(28, 0, -12)},
        {name = "TransportOverlookTerrace", y = 72, size = Vector3.new(42, 2, 24), rot = 16, pos = Vector3.new(-18, 0, 18)},
    }

    for _, level in ipairs(levels) do
        local floor = part(model, level.name, level.size, CFrame.new(level.pos.X, level.y, level.pos.Z) * CFrame.Angles(0, math.rad(level.rot), 0), floorColor, Enum.Material.Concrete)
        floor.Transparency = 0.92
        floor.CanCollide = true
        floor.CastShadow = false
    end

    local ramps = {
        {Vector3.new(-38, 9, -25), Vector3.new(-18, 24, -15)},
        {Vector3.new(28, 32, -18), Vector3.new(10, 48, -7)},
        {Vector3.new(-22, 56, 15), Vector3.new(-2, 72, 9)},
    }

    for index, ramp in ipairs(ramps) do
        local p0, p1 = ramp[1], ramp[2]
        local midpoint = (p0 + p1) / 2
        local length = (p1 - p0).Magnitude
        local r = part(model, "OrganicRamp_" .. index, Vector3.new(length, 2, 14), CFrame.lookAt(midpoint, p1) * CFrame.Angles(0, math.rad(90), 0), floorColor, Enum.Material.Concrete)
        r.Transparency = 0.94
        r.CastShadow = false
    end
end

local function buildChromatinRoutes(model)
    local colors = {
        Color3.fromRGB(89, 36, 170),
        Color3.fromRGB(126, 42, 190),
        Color3.fromRGB(64, 44, 155),
        Color3.fromRGB(160, 64, 204),
    }

    for route = 1, 9 do
        local color = colors[((route - 1) % #colors) + 1]
        local points = {}
        local y = 39 + (route % 5) * 5
        local radiusX = 19 + (route % 4) * 7
        local radiusZ = 16 + (route % 3) * 7
        local phase = route * 0.7

        for i = 1, 13 do
            local t = (i - 1) / 12
            local angle = -0.4 + t * math.tau * 1.25 + phase * 0.35
            table.insert(points, Vector3.new(
                math.cos(angle) * radiusX + math.sin(t * 9 + phase) * 8,
                y + math.sin(t * math.pi * 4 + phase) * 8,
                8 + math.sin(angle) * radiusZ + math.cos(t * 7 + phase) * 6
            ))
        end

        for i = 1, #points - 1 do
            cylinderBetween(model, "ChromatinRoute_" .. route .. "_" .. i, points[i], points[i + 1], 3.4, color, Enum.Material.SmoothPlastic)
        end

        for i = 1, #points, 4 do
            ball(model, "GeneAccessNode_" .. route .. "_" .. i, points[i], Vector3.new(5.4, 5.4, 5.4), Color3.fromRGB(189, 92, 231), Enum.Material.Neon).Transparency = 0.14
        end
    end
end

local function buildNucleolusDetails(model)
    for i = 1, 44 do
        local angle = i * 2.399963
        local radius = 5 + math.sqrt(i) * 2.5
        local y = 49 + math.sin(angle * 1.7) * 8
        local size = 4.2 + (i % 5) * 0.9
        local color = i % 3 == 0 and Color3.fromRGB(72, 32, 158) or Color3.fromRGB(119, 42, 189)
        if i % 5 == 0 then
            color = Color3.fromRGB(176, 62, 204)
        end
        ball(model, "NucleolusGranule_" .. i, Vector3.new(math.cos(angle) * radius, y, 10 + math.sin(angle) * radius), Vector3.new(size, size, size), color, Enum.Material.SmoothPlastic)
    end
end

local function buildPoreFeatures(model, meshData)
    local porePositions = {
        {angle = math.rad(-52), y = 28, scale = 0.22},
        {angle = math.rad(-78), y = 54, scale = 0.18},
        {angle = math.rad(-112), y = 18, scale = 0.16},
        {angle = math.rad(122), y = 42, scale = 0.2},
        {angle = math.rad(154), y = 68, scale = 0.16},
        {angle = math.rad(198), y = 30, scale = 0.18},
        {angle = math.rad(238), y = 60, scale = 0.15},
        {angle = math.rad(282), y = 22, scale = 0.17},
        {angle = math.rad(18), y = 38, scale = 0.13},
        {angle = math.rad(44), y = 62, scale = 0.14},
        {angle = math.rad(82), y = 27, scale = 0.13},
        {angle = math.rad(330), y = 72, scale = 0.12},
    }

    for index, pore in ipairs(porePositions) do
        local x = math.cos(pore.angle) * 82
        local z = math.sin(pore.angle) * 64
        local cframe = CFrame.lookAt(Vector3.new(x, pore.y, z), Vector3.new(x * 1.3, pore.y, z * 1.3))
        createEditableMeshPart(model, "SmallNuclearPore_" .. index, meshData, Color3.fromRGB(255, 236, 196), cframe, Enum.Material.SmoothPlastic, {scale = pore.scale, doubleSided = true})
        ball(model, "SmallNuclearPoreDarkCenter_" .. index, Vector3.new(x * 1.01, pore.y, z * 1.01), Vector3.new(8, 8, 8), Color3.fromRGB(68, 28, 81), Enum.Material.SmoothPlastic)
    end
end

local function buildExportPaths(model)
    local pathColor = Color3.fromRGB(255, 221, 107)
    for stream = 1, 3 do
        local y = 70 - stream * 8
        local start = Vector3.new(18 - stream * 4, y, 2 + stream * 6)
        local finish = Vector3.new(72, 18 + stream * 5, -34)
        cylinderBetween(model, "ExportPath_" .. stream, start, finish, 2.2, pathColor, Enum.Material.Neon).Transparency = 0.22
        for i = 1, 3 do
            local t = i / 4
            local p = start:Lerp(finish, t)
            ball(model, "ExportCargo_" .. stream .. "_" .. i, p, Vector3.new(3.4, 3.4, 3.4), Color3.fromRGB(255, 242, 150), Enum.Material.Neon)
        end
    end
end

local function configurePlayStart(model)
    local starterScripts = StarterPlayer:FindFirstChild("StarterPlayerScripts")
    if starterScripts then
        local oldScript = starterScripts:FindFirstChild("NucleusStartupCamera")
        if oldScript then
            oldScript:Destroy()
        end
    end

    local defaultSpawn = Workspace:FindFirstChild("SpawnLocation")
    if defaultSpawn and defaultSpawn:IsA("SpawnLocation") then
        defaultSpawn.Enabled = false
        defaultSpawn.Transparency = 1
        defaultSpawn.CanCollide = false
        defaultSpawn.CastShadow = false
    end

    local startPlatform = part(model, "OutsideViewingPlatform", Vector3.new(56, 2, 34), CFrame.new(152, 1, 96) * CFrame.Angles(0, math.rad(-34), 0), Color3.fromRGB(64, 56, 72), Enum.Material.Concrete)
    startPlatform.CanCollide = true

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "NucleusOutsideSpawn"
    spawn.Anchored = true
    spawn.Neutral = true
    spawn.Enabled = true
    spawn.Duration = 0
    spawn.Size = Vector3.new(14, 2, 14)
    spawn.CFrame = CFrame.new(152, 4, 96) * CFrame.Angles(0, math.rad(-134), 0)
    spawn.Color = Color3.fromRGB(76, 172, 142)
    spawn.Material = Enum.Material.SmoothPlastic
    spawn.Transparency = 0.25
    spawn.Parent = model

    local path = part(model, "ApproachPathToPore", Vector3.new(108, 1.4, 16), CFrame.new(100, 1.2, 52) * CFrame.Angles(0, math.rad(-34), 0), Color3.fromRGB(115, 93, 77), Enum.Material.WoodPlanks)
    path.CanCollide = true

    if starterScripts then
        local cameraScript = Instance.new("LocalScript")
        cameraScript.Name = "NucleusStartupCamera"
        cameraScript.Source = [[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local function positionCharacter(character)
    local root = character:WaitForChild("HumanoidRootPart", 8)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if root then
        root.CFrame = CFrame.lookAt(Vector3.new(152, 7, 96), Vector3.new(0, 44, 0))
    end
    if humanoid then
        camera.CameraSubject = humanoid
    end
end

local character = player.Character or player.CharacterAdded:Wait()
positionCharacter(character)
player.CharacterAdded:Connect(positionCharacter)

camera.CameraType = Enum.CameraType.Scriptable
camera.FieldOfView = 45
camera.CFrame = CFrame.lookAt(Vector3.new(190, 72, 150), Vector3.new(0, 48, 0))

task.delay(5, function()
    local currentCharacter = player.Character
    local humanoid = currentCharacter and currentCharacter:FindFirstChildOfClass("Humanoid")
    if humanoid then
        camera.CameraSubject = humanoid
    end
    camera.CameraType = Enum.CameraType.Custom
    camera.FieldOfView = 70
end)
]]
        cameraScript.Parent = starterScripts
    end

    Players.CharacterAutoLoads = true
end

local function buildExperience(meshes, options)
    options = options or {}

    if options.clearScene then
        clearScene()
    else
        Lighting.ClockTime = 13.5
        Lighting.Brightness = 2
        Lighting.EnvironmentDiffuseScale = 0.5
        Lighting.EnvironmentSpecularScale = 0.25
    end

    for _, child in ipairs(Workspace:GetChildren()) do
        if child.Name == "NucleusMeshExperience" then
            child:Destroy()
        end
    end

    local model = Instance.new("Model")
    model.Name = "NucleusMeshExperience"
    model.Parent = Workspace

    buildWalkableArchitecture(model)

    local orangeInterior = ball(model, "OrangeNucleoplasmInterior", Vector3.new(0, 50, 4), Vector3.new(100, 76, 78), Color3.fromRGB(230, 99, 45), Enum.Material.SmoothPlastic)
    orangeInterior.Transparency = 0.66
    orangeInterior.CastShadow = false

    local purpleDepth = ball(model, "VioletInteriorDepth", Vector3.new(-9, 50, 5), Vector3.new(76, 62, 58), Color3.fromRGB(100, 48, 142), Enum.Material.SmoothPlastic)
    purpleDepth.Transparency = 0.72
    purpleDepth.CastShadow = false

    createEditableMeshPart(model, "OrganicNuclearEnvelopeMesh", meshes.shell, Color3.fromRGB(215, 82, 48), CFrame.new(0, 54, 0), Enum.Material.SmoothPlastic, {doubleSided = true})
    createEditableMeshPart(model, "PurpleInnerNuclearLiningMesh", meshes.inner, Color3.fromRGB(91, 34, 126), CFrame.new(0, 54, 0), Enum.Material.SmoothPlastic, {transparency = 0.1, doubleSided = true})
    createEditableMeshPart(model, "NucleolusProductionCoreMesh", meshes.nucleolus, Color3.fromRGB(96, 39, 176), CFrame.new(0, 50, 10), Enum.Material.SmoothPlastic, {scale = 1.2, doubleSided = true})
    ball(model, "NucleolusPurpleCoreGlow", Vector3.new(0, 50, 10), Vector3.new(34, 34, 34), Color3.fromRGB(143, 54, 218), Enum.Material.Neon).Transparency = 0.22

    buildPoreFeatures(model, meshes.pore)
    buildChromatinRoutes(model)
    buildNucleolusDetails(model)
    buildExportPaths(model)
    configurePlayStart(model)

    pcall(function()
        game:GetService("Selection"):Set({})
    end)

    Workspace.CurrentCamera.FieldOfView = 38
    Workspace.CurrentCamera.CFrame = CFrame.lookAt(Vector3.new(220, 122, 220), Vector3.new(0, 48, 0))
    Workspace.CurrentCamera.Focus = CFrame.new(0, 48, 0)

    print("NucleusMeshExperience refined mesh object created:", #meshes.shell.vertices, "shell vertices,", #meshes.shell.faces, "shell triangles")
end

return buildExperience
