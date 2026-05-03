--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkLib = require(ReplicatedStorage.Networking.NetworkLib)

local Data = require(ReplicatedStorage.Assets.Pets.Data)
--[[ @end_section Imports ]]


type PetSchema = Data.PetSchema


local Packets
= {
    AddPetsToInventory = NetworkLib("add_pets_to_inventory", "Event",
        {
            clientType = { ["" :: string] = {} :: PetSchema },
            serverType = nil
        }
    ),

    RemovePetsFromInventory = NetworkLib("remove_pets_from_inventory", "Event",
        {
            clientType = { "pet_id" },
            serverType = nil
        }
    ),

    RemoveAllPetsFromInventory = NetworkLib("remove_all_pets_from_inventory", "Event",
        {
            clientType = nil,
            serverType = nil
        }
    ),
    

    RequestInventorySlots = NetworkLib("request_inventory_slots", "Function",
        {
            clientType = 0,
            serverType = nil
        }
    ),

    SearchForPets = NetworkLib("search_for_pets", "Event",
        {
            clientType = nil,
            serverType = "searching_string"
        }
    )
}


table.freeze(Packets)
return Packets