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
    name = "Rabbit",

    rarity = Data.RARITIES[2],

    stats
    = {
        health = 20,
        attack = 20
    }
} :: PetSchema


table.freeze(PetSchema)
return PetSchema