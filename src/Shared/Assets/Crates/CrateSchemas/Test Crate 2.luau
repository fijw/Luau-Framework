--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Assets.Crates.Data)
local PetSchemas = require(ReplicatedStorage.Assets.Pets.PetSchemas)
--[[ @end_section Imports ]]


type CrateSchema = Data.CrateSchema


local CrateSchema
= {
    name = script.Name,

    Chances
    = {
        [PetSchemas["Justin's Pet"]] = 10,
        [PetSchemas["Nv's Pet"]] = 20,
        [PetSchemas["Cat"]] = 20,
        [PetSchemas["Dog"]] = 20,
        [PetSchemas["Rabbit"]] = 20,
        [PetSchemas["Sad Cat"]] = 10
    }
} :: CrateSchema


table.freeze(CrateSchema)
return CrateSchema