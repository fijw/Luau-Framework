--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkLib = require(ReplicatedStorage.Networking.NetworkLib)
--[[ @end_section Imports ]]


local Packets
= {
    Rebirth = NetworkLib("rebirth", "Event",
        {
            clientType = true,
            serverType = nil
        }
    )
}


table.freeze(Packets)
return Packets