--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkLib = require(ReplicatedStorage.Networking.NetworkLib)
--[[ @end_section Imports ]]


local Packets
= {
    OpenCrate = NetworkLib("cm_open_crate", "Event",
        {
            clientType = nil,
            serverType = "crate_id"
        }
    ),

    GetCrates = NetworkLib("cm_get_crates", "Function",
        {
            clientType = { {} :: { name: string, price: number, Chances: { [string]: number } } },
            serverType = "searching_string" :: string?
        }
    ),


    SendMaxPetsNotification = NetworkLib("cm_crate_machine_send_max_pets_notification", "Event",
        {
            clientType = 0,
            serverType = nil
        }
    ),

    SendNotEnoughGemsNotification = NetworkLib("cm_crate_machine_not_enough_gems_noti", "Event",
        {
            clientType = 0,
            serverType = nil       
        }
    )
}


table.freeze(Packets)
return Packets