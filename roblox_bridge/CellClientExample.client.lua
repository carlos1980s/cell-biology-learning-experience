local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder = ReplicatedStorage:WaitForChild("CellBackendRemotes")
local cellStateDelta = remotesFolder:WaitForChild("CellStateDelta")
local cellInputRequest = remotesFolder:WaitForChild("CellInputRequest")
local organelleInspectResult = remotesFolder:WaitForChild("OrganelleInspectResult")
local cellBackendStatus = remotesFolder:WaitForChild("CellBackendStatus")

local latestCellState = nil

cellBackendStatus.OnClientEvent:Connect(function(status)
    print("[CellBackendStatus]", status.status, status.detail)
end)

cellStateDelta.OnClientEvent:Connect(function(delta)
    latestCellState = delta
    print("[CellStateDelta]", delta.cell_mode, delta.cycle_phase, delta.tick)
end)

organelleInspectResult.OnClientEvent:Connect(function(result)
    print("[OrganelleInspectResult]", result.display_name, result.explanation)
end)

local function inspectNucleus()
    cellInputRequest:FireServer({
        input_type = "inspect_organelle",
        payload = {
            organelle_id = "nucleus-1",
        },
    })
end

task.delay(5, inspectNucleus)

