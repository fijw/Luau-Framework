--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Assets.Pets.Data)
--[[ @end_section Imports ]]


type PetSchema = Data.PetSchema


local PetSchema
= {
    name = "Sad Cat",

    rarity = Data.RARITIES[6],

    stats
    = {
        health = 5_000_000,
        attack = 5_000_000
    }
} :: PetSchema


table.freeze(PetSchema)
return PetSchema