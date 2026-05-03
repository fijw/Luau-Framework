--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkLib = require(ReplicatedStorage.Networking.NetworkLib)
--[[ @end_section Imports ]]


local Packets
= {
    OpenCrate = NetworkLib("open_crate", "Event",
        {
            clientType = nil,
            serverType = "crate_id"
        }
    ),

    GetCrates = NetworkLib("get_crates", "Function",
        {
            clientType = { {} :: { name: string, price: number, Chances: { [string]: number } } },
            serverType = "searching_string" :: string?
        }
    )
}


table.freeze(Packets)
return Packets