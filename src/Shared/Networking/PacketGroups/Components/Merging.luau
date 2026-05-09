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
    MergePets = NetworkLib("mg_merge_pets", "Event",
        {
            clientType = true,
            serverType = { "pet_id" }
        }
    ),


    AddPetsToMergingSlots = NetworkLib("mg_add_pets_to_merging_slots", "Event",
        {
            clientType = { ["" :: string] = {} :: PetSchema },  
            serverType = nil  
        }
    ),

    RemovePetsFromMergingSlots = NetworkLib("mg_remove_pets_from_merging_slots", "Event",
        {
            clientType = { "pet_id" },
            serverType = nil
        }
    ),

    RemoveAllPetsFromMergingSlots = NetworkLib("mg_remove_all_pets_from_merging_slots", "Event",
        {
            clientType = nil,
            serverType = nil
        }
    ),


    SearchForPetsByString = NetworkLib("mg_merging_search_for_pets_by_string", "Event",
        {
            clientType = nil,
            serverType = "searching_string"
        }
    ),

    SearchForPetsByData = NetworkLib("mg_merging_search_for_pets_by_data", "Event",
        {
            clientType = nil,
            serverType = {} :: PetSchema
        }
    ),


    RequestMergingData = NetworkLib("mg_request_merging_data", "Event",
        {
            clientType = nil,
            serverType = nil
        }
    ),


    NotEnoughPetsToMerge = NetworkLib("mg_not_enough_pets_to_merge", "Event",
        {
            clientType = 0,
            serverType = nil
        }
    ),

    NotEnoughGemsToMerge = NetworkLib("mg_not_enough_gems_to_merge", "Event",
        {
            clientType = 0,
            serverType = nil
        }
    ),

    SuccessfullyMergedPets = NetworkLib("mg_successfully_merged_pets", "Event",
        {
            clientType = nil,
            serverType = nil
        }
    )
}


table.freeze(Packets)
return Packets