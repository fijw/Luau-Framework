--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Assets.Crates.Data)

local NetworkLib = require(ReplicatedStorage.Networking.NetworkLib)
--[[ @end_section Imports ]]


type CrateSchema = Data.CrateSchema


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
            clientType = { {} :: CrateSchema },
            serverType = "searching_string" :: string?
        }
    )
}


table.freeze(Packets)
return Packets