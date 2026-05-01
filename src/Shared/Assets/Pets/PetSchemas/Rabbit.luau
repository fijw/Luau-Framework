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
    petImageId = "rbxassetid://13424524253",

    GameplayStats
    = {
        maxHealth = 20,
        attackDamage = 20,
        petHealth = nil :: any
    },

    PetStats
    = {
        rarity = Data.RARITIES[2] :: any,
        size = nil :: any,
        color = nil :: any
    }
}


table.freeze(PetSchema)
return PetSchema