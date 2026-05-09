--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkLib = require(ReplicatedStorage.Networking.NetworkLib)
--[[ @end_section Imports ]]


local Packets
= {
    SpawnPet = NetworkLib("ds_spawn_pet", "Event",
        {
            clientType = nil,

            serverType
            = {
                petName = "",
                petSize = "",
                petColor = "",
                receiverId = 0
            }
        }
    ),

    SendResults = NetworkLib("ds_send_spawning_results", "Event",
        {
            clientType = "results_string",
            serverType = nil
        }
    )
}


table.freeze(Packets)
return Packets