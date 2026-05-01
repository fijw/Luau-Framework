--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkLib = require(ReplicatedStorage.Networking.NetworkLib)
--[[ @end_section Imports ]]


local Packets
= {
    PlacePetOnMarketplace = NetworkLib("place_pet_on_marketplace", "Event",
        {
            clientType = true,
            serverType = { petId = "", price = 0 }
        }
    ),

    RemovePetFromMarketplace = NetworkLib("remove_pet_from_marketplace", "Event",
        {
            clientType = true,
            serverType = "pet_id"
        }
    ),

    BuyPetFromMarketplace = NetworkLib("buy_pet_from_marketplace", "Event",
        {
            clientType = true,
            serverType = "pet_id"
        }
    )
}


table.freeze(Packets)
return Packets