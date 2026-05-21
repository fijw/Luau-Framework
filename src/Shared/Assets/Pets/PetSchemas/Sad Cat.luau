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
    petImageId = "rbxassetid://133541764178841",

    GameplayStats
    = {
        maxHealth = 30,
        attackDamage = 30,
        petHealth = nil :: any
    },

    PetStats
    = {
        rarity = "Rare",
        size = nil :: any,
        color = nil :: any
    }
}


table.freeze(PetSchema)
return PetSchema