--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.DataAssets.Pets.Data)

local NetworkLib = require(ReplicatedStorage.Networking.NetworkLib)
--[[ @end_section Imports ]]


type PetSchema = Data.PetSchema


local Packets
= {
    EquipPet = NetworkLib("ph_equip_pet", "Function",
        {
            clientType = (true or false) :: boolean,
            serverType = "pet_id"
        }
    ),

    UnequipPet = NetworkLib("ph_unequip_pet", "Function",
        {
            clientType = (true or false) :: boolean,
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
    ),

    AddPetToClientField = NetworkLib("ph_add_pet_to_client_field", "Event",
        {
            clientType
            = {
                generatedId = "",
                PetData = {} :: PetSchema,
                fieldName = ""
            },

            serverType = nil
        }
    ),


    StartAttackingPet = NetworkLib("ph_start_attacking_pet", "Event",
        {
            clientType = { attackingPetId = "", targetPetId = "", fieldName = "" },
            serverType = { petIdToAttack = "", fieldName = "" }
        }
    ),

    ServerStartDealingDamage = NetworkLib("ph_server_start_dealing_damage", "Event",
        {
            clientType = nil,
            serverType = { targetPetId = "", attackingPetId = "", fieldName = "" }
        }
    ),

    RemovePetFromClientAttackingCache = NetworkLib("ph_remove_pet_from_client_attacking_cache", "Event",
        {
            clientType = "pet_id",
            serverType = nil
        }
    )
}


table.freeze(Packets)
return Packets