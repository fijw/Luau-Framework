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
    MergePets = NetworkLib("merge_pets", "Event",
        {
            clientType = true,
            serverType = { "pet_id" }
        }
    ),


    AddPetsToMergingSlots = NetworkLib("add_pets_to_merging_slots", "Event",
        {
            clientType = { ["" :: string] = {} :: PetSchema },  
            serverType = nil  
        }
    ),

    RemovePetsFromMergingSlots = NetworkLib("remove_pets_from_merging_slots", "Event",
        {
            clientType = { "pet_id" },
            serverType = nil
        }
    ),

    RemoveAllPetsFromMergingSlots = NetworkLib("remove_all_pets_from_merging_slots", "Event",
        {
            clientType = nil,
            serverType = nil
        }
    ),


    SearchForPetsByString = NetworkLib("merging_search_for_pets_by_string", "Event",
        {
            clientType = nil,
            serverType = "searching_string"
        }
    ),

    SearchForPetsByData = NetworkLib("merging_search_for_pets_by_data", "Event",
        {
            clientType = nil,
            serverType = {} :: PetSchema
        }
    ),


    RequestMergingData = NetworkLib("request_merging_data", "Event",
        {
            clientType = nil,
            serverType = nil
        }
    ),


    NotEnoughPetsToMerge = NetworkLib("not_enough_pets_to_merge", "Event",
        {
            clientType = 0,
            serverType = nil
        }
    ),

    NotEnoughGemsToMerge = NetworkLib("not_enough_gems_to_merge", "Event",
        {
            clientType = 0,
            serverType = nil
        }
    )
}


table.freeze(Packets)
return Packets