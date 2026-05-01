--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkLib = require(ReplicatedStorage.Networking.NetworkLib)
--[[ @end_section Imports ]]


local Packets
= {
    SpawnPet = NetworkLib("spawn_pet", "Event",
        {
            clientType = nil,

            serverType
            = {
                petName = "",
                petSize = "",
                petColor = "",
                receiverId = ""
            }
        }
    )
}


table.freeze(Packets)
return Packets