--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkLib = require(ReplicatedStorage.Networking.NetworkLib)
--[[ @end_section Imports ]]


local Packets
= {
    UpdateStats = NetworkLib("su_update_stats", "Event",
        {
            clientType
            = {
                gems = 0,
                rebirths = 0,
                levelsToRebirth = 0,
                levels = 0,
                xpToNextLevel = 0,
                xp = 0
            },

            serverType = nil
        }
    )
}


table.freeze(Packets)
return Packets