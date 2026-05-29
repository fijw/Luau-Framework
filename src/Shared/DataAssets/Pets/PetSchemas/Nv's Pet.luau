--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.DataAssets.Pets.Data)
--[[ @end_section Imports ]]


type PetSchema = Data.PetSchema


local PetSchema: PetSchema
= {
    petName = script.Name,
    petImageId = "rbxassetid://133541764178841",

    GameplayStats
    = {
        maxHealth = 123_456_789_123_456,
        attackDamage = 123_456_789_123_456
    },

    PetStats
    = {
        rarity = "Unobtainable",
        size = nil :: any,
        color = nil :: any
    }
}


table.freeze(PetSchema)
return PetSchema