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
    name = "Dog",

    rarity = Data.RARITIES[1],

    stats
    = {
        health = 10,
        attack = 10
    }
} :: PetSchema


table.freeze(PetSchema)
return PetSchema