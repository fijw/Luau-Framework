--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkLib = require(ReplicatedStorage.Networking.NetworkLib)
--[[ @end_section Imports ]]


local Packets
= {
    PlacePetOnMarketplace = NetworkLib("mp_place_pet_on_marketplace", "Event",
        {
            clientType = true,
            serverType = { petId = "", price = 0 }
        }
    ),

    RemovePetFromMarketplace = NetworkLib("mp_remove_pet_from_marketplace", "Event",
        {
            clientType = true,
            serverType = "pet_id"
        }
    ),

    BuyPetFromMarketplace = NetworkLib("mp_buy_pet_from_marketplace", "Event",
        {
            clientType = true,
            serverType = "pet_id"
        }
    )
}


table.freeze(Packets)
return Packets