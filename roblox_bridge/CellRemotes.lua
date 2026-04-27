local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CellRemotes = {}

local REMOTE_FOLDER_NAME = "CellBackendRemotes"
local REMOTE_EVENT_NAMES = {
    "CellStateDelta",
    "CellInputRequest",
    "OrganelleInspectResult",
    "CellBackendStatus",
}

local function ensureRemoteEvent(parent, name)
    local existing = parent:FindFirstChild(name)
    if existing and existing:IsA("RemoteEvent") then
        return existing
    end

    local remote = Instance.new("RemoteEvent")
    remote.Name = name
    remote.Parent = parent
    return remote
end

function CellRemotes.ensure()
    local folder = ReplicatedStorage:FindFirstChild(REMOTE_FOLDER_NAME)
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = REMOTE_FOLDER_NAME
        folder.Parent = ReplicatedStorage
    end

    local remotes = {}
    for _, name in ipairs(REMOTE_EVENT_NAMES) do
        remotes[name] = ensureRemoteEvent(folder, name)
    end
    return remotes
end

return CellRemotes

