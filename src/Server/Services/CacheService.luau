--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataLib = require(ServerScriptService.Libraries.DataLib)

local Settings = require(ReplicatedStorage.Settings)
--[[ @end_section Imports ]]


--[[ @section Constructor ]]
local function constructorCallback()
    local function onPlayerAdded(player: Player)
        local PlrDataClass = DataLib(player)
        if not PlrDataClass then return end

        print(PlrDataClass(), "start data")
    end

    local function onPlayerRemoving(player: Player)
        local PlrDataClass = DataLib(player)
        if not PlrDataClass then return end

        PlrDataClass:saveClass()
        PlrDataClass:deleteClass()

        local foundFunPermissionsIndex = table.find(Settings.ServerUsersWithFunCommands, player.UserId)
        if not foundFunPermissionsIndex then return end

        table.remove(Settings.ServerUsersWithFunCommands, foundFunPermissionsIndex)
    end

    -- Handle player data on join and leave.
    do
        for i: number, player: Player in pairs(Players:GetPlayers()) do onPlayerAdded(player) end

        Players.PlayerAdded:Connect(onPlayerAdded)
        Players.PlayerRemoving:Connect(onPlayerRemoving)
    end
end

return constructorCallback
--[[ @end_section Constructor ]]