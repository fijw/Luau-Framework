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


--[[
    @usage Subscribe to the player's stats.

    @param player Player

    @return void
]]
local function subscribeToStats(player: Player, PlrDataClass: DataClass): ()
    PlrDataClass()().gems:subscribe(
        function(self, data, key, ...): ()
            StatsUpdatingGroup.UpdateStats:fireClient(player, { data = data, key = key })
        end,

        "gems_update_client_subscription"
    )

    PlrDataClass()().StatsData:subscribe(
        function(self, data, key, ...): ()
            if key == "xp" then
                data = { min = data, max = PlrDataClass()().StatsData().xpToNextLevel }
            elseif key == "xpToNextLevel" then
                data = { min = PlrDataClass()().StatsData().xp, max = data }
            elseif key == "levelsNeededToRebirth" then
                data = { min = PlrDataClass()().StatsData().level, max = data }
            end

            StatsUpdatingGroup.UpdateStats:fireClient(player, { data = data, key = key })
        end,

        "stats_data_update_client_subscription"
    )
end


--[[ @section Constructor ]]
--[[
    @usage Initialize the component.

    @return void
]]
local function constuctorCallback(): ()
    local function onPlayerAdded(player: Player): ()
        local PlrDataClass = Registry(player)
        if not PlrDataClass then return end

        StatsUpdatingGroup.ShowJoiningStats:fireClient(player,
            {
                gems = PlrDataClass()().gems(),
                xp = PlrDataClass()().StatsData().xp,
                xpToNextLevel = PlrDataClass()().StatsData().xpToNextLevel,
                levelsNeededToRebirth = PlrDataClass()().StatsData().levelsNeededToRebirth,
                level = PlrDataClass()().StatsData().level,
                rebirths = PlrDataClass()().StatsData().rebirths
            }
        )

        subscribeToStats(player, PlrDataClass)
    end

    for i: number, player: Player in ipairs(Players:GetPlayers()) do onPlayerAdded(player) end
    Players.PlayerAdded:Connect(onPlayerAdded)
end

return constuctorCallback
--[[ @end_section Constructor ]]