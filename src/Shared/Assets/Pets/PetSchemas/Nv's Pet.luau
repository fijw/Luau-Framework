--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Assets.Pets.Data)
--[[ @end_section Imports ]]


type PetSchema = Data.PetSchema


local PetSchema: PetSchema
= {
    petName = script.Name,
    petImageId = "rbxassetid://84072249207090",

    GameplayStats
    = {
        maxHealth = 123_456_789_123_456,
        attackDamage = 123_456_789_123_456,
        petHealth = nil :: any
    },

    PetStats
    = {
        rarity = Data.RARITIES[7] :: any,
        size = nil :: any,
        color = nil :: any
    }
}


table.freeze(PetSchema)
return PetSchema