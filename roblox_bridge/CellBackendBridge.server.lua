local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local CellRemotes = require(script.Parent:WaitForChild("CellRemotes"))
local remotes = CellRemotes.ensure()

local CONFIG = {
    BACKEND_BASE_URL = "http://127.0.0.1:8000",
    BACKEND_TOKEN = "change-me-local-dev-token",
    POLL_INTERVAL_SECONDS = 1.0,
    CELL_TYPE = "animal",
    FRONTEND_VERSION = "roblox-bridge-dev",
}

local bridgeState = {
    sessionId = nil,
    cellId = nil,
    lastSeenVersion = 0,
    pollLoopRunning = false,
    online = false,
}

local function fireBackendStatus(status, detail)
    remotes.CellBackendStatus:FireAllClients({
        status = status,
        detail = detail,
        cellId = bridgeState.cellId,
        sessionId = bridgeState.sessionId,
    })
end

local function requestBackend(path, method, bodyTable)
    local url = CONFIG.BACKEND_BASE_URL .. path
    local body = bodyTable and HttpService:JSONEncode(bodyTable) or ""

    local response = HttpService:RequestAsync({
        Url = url,
        Method = method,
        Headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = "Bearer " .. CONFIG.BACKEND_TOKEN,
        },
        Body = body,
    })

    if not response.Success then
        warn("Cell backend request failed", response.StatusCode, response.Body)
        fireBackendStatus("offline", "Backend request failed")
        return nil
    end

    local decoded = HttpService:JSONDecode(response.Body)
    bridgeState.online = true
    return decoded
end

local function ensureSession(player)
    if bridgeState.sessionId and bridgeState.cellId then
        return true
    end

    local payload = {
        roblox_server_id = game.JobId,
        universe_id = tostring(game.GameId),
        place_id = tostring(game.PlaceId),
        player_id_hash = tostring(player.UserId),
        cell_type = CONFIG.CELL_TYPE,
        frontend_version = CONFIG.FRONTEND_VERSION,
    }

    local response = requestBackend("/v1/sessions", "POST", payload)
    if not response then
        return false
    end

    bridgeState.sessionId = response.session_id
    bridgeState.cellId = response.cell_id
    bridgeState.lastSeenVersion = response.initial_state.version or 0

    remotes.CellStateDelta:FireAllClients(response.initial_delta)
    fireBackendStatus("online", "Connected to cell backend")
    return true
end

local function sendTick()
    if not bridgeState.sessionId or not bridgeState.cellId then
        return
    end

    local response = requestBackend(
        string.format("/v1/cells/%s/tick", bridgeState.cellId),
        "POST",
        {
            session_id = bridgeState.sessionId,
            dt = CONFIG.POLL_INTERVAL_SECONDS,
            last_seen_version = bridgeState.lastSeenVersion,
            max_events = 50,
        }
    )

    if not response or not response.delta then
        return
    end

    bridgeState.lastSeenVersion = response.delta.to_version or bridgeState.lastSeenVersion
    remotes.CellStateDelta:FireAllClients(response.delta)
end

local function startPollLoop()
    if bridgeState.pollLoopRunning then
        return
    end

    bridgeState.pollLoopRunning = true
    task.spawn(function()
        while bridgeState.pollLoopRunning do
            local hasPlayers = #Players:GetPlayers() > 0
            if hasPlayers then
                sendTick()
            end
            task.wait(CONFIG.POLL_INTERVAL_SECONDS)
        end
    end)
end

local function sanitizeClientInput(payload)
    if type(payload) ~= "table" then
        return nil
    end

    local inputType = payload.input_type
    if inputType ~= "add_resource"
        and inputType ~= "stress_event"
        and inputType ~= "inspect_organelle"
        and inputType ~= "player_command"
        and inputType ~= "environment_change"
    then
        return nil
    end

    return {
        input_type = inputType,
        payload = payload.payload or {},
    }
end

remotes.CellInputRequest.OnServerEvent:Connect(function(player, payload)
    if not ensureSession(player) then
        return
    end

    local sanitized = sanitizeClientInput(payload)
    if not sanitized then
        warn("Rejected invalid client cell input payload")
        return
    end

    if sanitized.input_type == "inspect_organelle" then
        local organelleId = sanitized.payload.organelle_id
        if type(organelleId) ~= "string" then
            return
        end

        local inspectPath = string.format(
            "/v1/cells/%s/organelles/%s/inspect?session_id=%s",
            bridgeState.cellId,
            organelleId,
            bridgeState.sessionId
        )
        local inspectResponse = requestBackend(inspectPath, "POST")
        if inspectResponse then
            remotes.OrganelleInspectResult:FireClient(player, inspectResponse)
        end
        return
    end

    local response = requestBackend(
        string.format("/v1/cells/%s/input", bridgeState.cellId),
        "POST",
        {
            session_id = bridgeState.sessionId,
            seq = tick(),
            input_type = sanitized.input_type,
            payload = sanitized.payload,
        }
    )

    if response then
        fireBackendStatus("online", response.message or "Input forwarded to backend")
    end
end)

Players.PlayerAdded:Connect(function(player)
    if ensureSession(player) then
        startPollLoop()
    end
end)

Players.PlayerRemoving:Connect(function()
    if #Players:GetPlayers() <= 1 then
        fireBackendStatus("idle", "No active players; poll loop remains available")
    end
end)

