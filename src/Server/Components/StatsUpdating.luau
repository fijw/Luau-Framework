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
local function fireStatsToClient(player: Player, PlrDataClass: DataClass)
    StatsUpdatingGroup.UpdateStats:fireClient(player,
        {
            gems = PlrDataClass()().gems(),
            levels = PlrDataClass()().StatsData().level,
            xp = PlrDataClass()().StatsData().xp,
            xpToNextLevel = PlrDataClass()().StatsData().xpToNextLevel,
            levelsToRebirth = PlrDataClass()().StatsData().levelsNeededToRebirth,
            rebirths = PlrDataClass()().StatsData().rebirths
        }
    )
end

--[[
    @usage Subscribe to the player's stats.

    @param player Player
    @param PlrDataClass DataClass

    @return void
]]
local function subscribeToStats(player: Player, PlrDataClass: DataClass)
    PlrDataClass()().gems:subscribe(
        function(self, data, key, ...) fireStatsToClient(player, PlrDataClass) end,
        "gems_update_client_subscription"
    )

    PlrDataClass()().StatsData:subscribe(
        function(self, data, key, ...) fireStatsToClient(player, PlrDataClass) end,
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
        local PlrDataClass = Registry(player)
        if not PlrDataClass then return end

        fireStatsToClient(player, PlrDataClass)
        subscribeToStats(player, PlrDataClass)
    end

    for i: number, player: Player in ipairs(Players:GetPlayers()) do onPlayerAdded(player) end
    Players.PlayerAdded:Connect(onPlayerAdded)
end

return constuctorCallback
--[[ @end_section Constructor ]]