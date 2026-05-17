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


    UpdatePetFollowingPosition = NetworkLib("ph_update_pet_position", "Event",
        {
            clientType
            = {
                petId = "",
                PetData = {} :: PetSchema,
                ownerId = 0,
                instaTravel = nil :: true?,
                CachedEquippedPets = {} :: { [string]: PetSchema },
            },

            serverType = nil
        }
    )
}


table.freeze(Packets)
return Packets