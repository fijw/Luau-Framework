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
    RequestHealingPets = NetworkLib("request_healing_pets", "Function",
        {
            clientType = { ["pet_id" :: string] = {} :: PetSchema },
            serverType = nil
        }
    ),

    SuccessfullyStartedHealing = NetworkLib("successfully_started_healing", "Event",
        {
            clientType = nil,
            serverType = nil
        }
    ),

    RequestPetsForHealingSelection = NetworkLib("request_pets_for_healing_selection", "Function",
        {
            clientType = { ["pet_id" :: string] = {} :: PetSchema },
            serverType = nil
        }
    ),


    RemovePetsFromHealingMachine = NetworkLib("remove_pet_from_healing_machine", "Event",
        {
            clientType = { "pet_id" },
            serverType = nil
        }
    ),

    HealPets = NetworkLib("heal_pet", "Event",
        {
            clientType = nil,
            serverType = { "pet_id" }
        }
    )
}


table.freeze(Packets)
return Packets