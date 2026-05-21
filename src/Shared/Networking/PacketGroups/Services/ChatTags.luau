--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkLib = require(ReplicatedStorage.Networking.NetworkLib)
--[[ @end_section Imports ]]


local Packets
= {
    CheckIfUserOwnsGamepass = NetworkLib("ct_check_if_user_owns_gamepass", "Function",
        {
            clientType = true or false,
            serverType = 0
        }
    )
}


table.freeze(Packets)
return Packets