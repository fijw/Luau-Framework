--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkLib = require(ReplicatedStorage.Networking.NetworkLib)
--[[ @end_section Imports ]]


local Packets
= {
    LoadClientModules = NetworkLib("load_client", "Event",
        {
            clientType = nil,
            serverType = nil
        }
    )
}


table.freeze(Packets)
return Packets