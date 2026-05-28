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
    RequestHealingPets = NetworkLib("hm_request_healing_pets", "Function",
        {
            clientType = { ["pet_id" :: string] = {} :: PetSchema },
            serverType = nil
        }
    ),

    RequestPetsForHealingSelection = NetworkLib("hm_request_pets_for_healing_selection", "Function",
        {
            clientType = { ["pet_id" :: string] = {} :: PetSchema },
            serverType = nil
        }
    ),

    RequestHealingSlots = NetworkLib("hm_request_healing_slots", "Function",
        {
            clientType = 0,
            serverType = nil
        }
    ),


    SuccessfullyStartedHealing = NetworkLib("hm_successfully_started_healing", "Event",
        {
            clientType = 0,
            serverType = nil
        }
    ),

    PetFinishedHealing = NetworkLib("hm_pet_finished_healing", "Event",
        {
            clientType = "pet_name",
            serverType = nil
        }
    ),


    RemovePetsFromHealingMachine = NetworkLib("hm_remove_pet_from_healing_machine", "Event",
        {
            clientType = { "pet_id" },
            serverType = nil
        }
    ),

    HealPets = NetworkLib("hm_heal_pet", "Event",
        {
            clientType = nil,
            serverType = { "pet_id" }
        }
    )
}


table.freeze(Packets)
return Packets