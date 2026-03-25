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
--[[
    @usage Handles player cache upon joining and leaving.
    
    @return void
]]
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

        if not Settings.ServerUsersGivenFunCommands[player.UserId] then return end
        Settings.ServerUsersGivenFunCommands[player.UserId] = nil
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
    Players.PlayerRemoving:Connect(onPlayerRemoving)
end

return constructorCallback
--[[ @end_section Constructor ]]