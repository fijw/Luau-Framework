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
    )
}


table.freeze(Packets)
return Packets