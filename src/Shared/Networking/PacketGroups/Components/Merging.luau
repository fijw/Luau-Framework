--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkLib = require(ReplicatedStorage.Networking.NetworkLib)
--[[ @end_section Imports ]]


local Packets
= {
    MergePets = NetworkLib("merge_pets", "Event",
        {
            clientType = true,
            serverType = { "pet_id" }
        }
    )
}


table.freeze(Packets)
return Packets