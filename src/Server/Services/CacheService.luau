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
        local PlrDataClass = DataLib(player, true)
        if not PlrDataClass then return end

        print(PlrDataClass().coins(), `{player.UserId}'s coins.`)

        task.spawn(
            function()
                while true do
                    if not Players:GetPlayerByUserId(player.UserId) then break end

                    local oldCoins = PlrDataClass().coins() :: number
                    PlrDataClass().coins(oldCoins + 100_000)

                    task.wait(5)
                end
            end
        )
    end

    local function onPlayerRemoving(player: Player)
        local PlrDataClass = DataLib(player)
        if not PlrDataClass then return end

        PlrDataClass:saveClass()
        PlrDataClass:deleteClass()

        if not Settings.ServerUsersGivenFunCommands[player.UserId] then return end
        Settings.ServerUsersGivenFunCommands[player.UserId] = nil
    end

    -- Handle player joining and leaving connections.
    do
        for i: number, player: Player in ipairs(Players:GetPlayers()) do onPlayerAdded(player) end

        Players.PlayerAdded:Connect(onPlayerAdded)
        Players.PlayerRemoving:Connect(onPlayerRemoving)
    end
end

return constructorCallback
--[[ @end_section Constructor ]]