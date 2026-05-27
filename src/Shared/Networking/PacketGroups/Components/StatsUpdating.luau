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
                key = "" or nil,
                data = nil :: any
            },

            serverType = nil
        }
    ),

    ShowJoiningStats = NetworkLib("su_show_joining_stats", "Event",
        {
            clientType
            = {
                gems = 0,
                xp = 0,
                xpToNextLevel = 0,
                levelsNeededToRebirth = 0,
                level = 0,
                rebirths = 0
            },

            serverType = nil
        }
    )
}


table.freeze(Packets)
return Packets