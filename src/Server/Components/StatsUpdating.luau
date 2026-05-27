--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)

local StatsUpdatingGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.StatsUpdating)
--[[ @end_section Imports ]]


type DataClass = Registry.DataClass


--[[ @section Utility Functions ]]
--[[
    @usage Send the player's stats to the client.

    @param player Player
    @param PlrDataClass DataClass

    @return void
]]
local function fireStatsToClient(player: Player, data: any, key: string?)
    local PlrDataClass = Registry(player)
    if not PlrDataClass then return end

    StatsUpdatingGroup.UpdateStats:fireClient(player, { data = data, key = key })
end

--[[
    @usage Subscribe to the player's stats.

    @param player Player

    @return void
]]
local function subscribeToStats(player: Player)
    local PlrDataClass = Registry(player)
    if not PlrDataClass then return end

    PlrDataClass()().gems:subscribe(
        function(self, data, key, ...)
            print(PlrDataClass()().gems())
            fireStatsToClient(player, data)
        end,

        "gems_update_client_subscription"
    )

    PlrDataClass()().StatsData:subscribe(
        function(self, data, key, ...)
            fireStatsToClient(player, data, key)
        end,

        "stats_data_update_client_subscription"
    )
end
--[[ @end_section Utility Functions ]]


--[[ @section Constructor ]]
--[[
    @usage Initialize the component.

    @return void
]]
local function constuctorCallback()
    local function onPlayerAdded(player: Player)
        fireStatsToClient(player, nil, nil)
        subscribeToStats(player)
    end

    for i: number, player: Player in ipairs(Players:GetPlayers()) do onPlayerAdded(player) end
    Players.PlayerAdded:Connect(onPlayerAdded)
end

return constuctorCallback
--[[ @end_section Constructor ]]