--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.DataAssets.Crates.Data)
local PetSchemas = require(ReplicatedStorage.DataAssets.Pets.PetSchemas)
--[[ @end_section Imports ]]


type CrateSchema = Data.CrateSchema


local CrateSchema: CrateSchema
= {
    name = script.Name,

    Chances
    = {
        [PetSchemas["Justin's Pet"]] = 10,
        [PetSchemas["Nv's Pet"]] = 20,
        [PetSchemas["Cat"]] = 20,
        [PetSchemas["Dog"]] = 20,
        [PetSchemas["Bunny"]] = 10,
        [PetSchemas["Sad Cat"]] = 10,
        [PetSchemas["Test Pet"]] = 10
    },

    price = 100
}


table.freeze(CrateSchema)
return CrateSchema