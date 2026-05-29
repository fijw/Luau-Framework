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
    petImageId = "rbxassetid://94193290338597",

    GameplayStats
    = {
        maxHealth = 10,
        attackDamage = 10,
        petHealth = nil :: any
    },

    PetStats
    = {
        rarity = "Common",
        size = nil :: any,
        color = nil :: any
    }
}


table.freeze(PetSchema)
return PetSchema