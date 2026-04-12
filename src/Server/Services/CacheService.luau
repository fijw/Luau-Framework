--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)

local CmdsSettings = require(ReplicatedStorage.Settings.CmdsSettings)
--[[ @end_section Imports ]]


--[[ @section Constructor ]]
--[[
    @usage Handles player cache upon joining and leaving.
    
    @return void
]]
local function constructorCallback()
    local function onPlayerAdded(player: Player)
        local PlrDataClass = Registry(player, true)
        if not PlrDataClass then return end

        print(PlrDataClass().coins(), `{player.UserId}'s coins.`)

        -- Make the coins divisible using a custom callback.
        do
            PlrDataClass().coins:addOperator(
                "__div",
                
                function(self, data)
                    print(data, "__div callback")
                    return self
                end
            )

            PlrDataClass().coins /= 5
        end

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
        local PlrDataClass = Registry(player)
        if not PlrDataClass then return end

        PlrDataClass:saveClass()
        PlrDataClass:deleteClass()

        if not CmdsSettings.ServerUsersGivenFunCommands[player.UserId] then return end
        CmdsSettings.ServerUsersGivenFunCommands[player.UserId] = nil
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