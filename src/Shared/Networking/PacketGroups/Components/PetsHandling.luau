--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Assets.Pets.Data)

local NetworkLib = require(ReplicatedStorage.Networking.NetworkLib)
--[[ @end_section Imports ]]


type PetSchema = Data.PetSchema


local Packets
= {
    EquipPet = NetworkLib("ph_equip_pet", "Function",
        {
            clientType = true or false,
            serverType = "pet_id"
        }
    ),

    UnequipPet = NetworkLib("ph_unequip_pet", "Function",
        {
            clientType = true or false,
            serverType = "pet_id"
        }
    ),


    PetStartFollowingOwner = NetworkLib("ph_pet_start_following_owner", "Event",
        {
            clientType
            = {
                petId = "",
                PetData = {} :: PetSchema,
                ownerId = 0
            },

            serverType = nil
        }
    ),

    RemovePetFromClient = NetworkLib("ph_remove_pet_from_client", "Event",
        {
            clientType = "pet_id",
            serverType = nil
        }
    )
}


table.freeze(Packets)
return Packets