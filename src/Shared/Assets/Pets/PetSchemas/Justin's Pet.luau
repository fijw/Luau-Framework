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
    name = "Justin's Pet",

    rarity = Data.RARITIES[7],

    stats
    = {
        health = 123_456_789,
        attack = 123_456_789
    }
} :: PetSchema


table.freeze(PetSchema)
return PetSchema