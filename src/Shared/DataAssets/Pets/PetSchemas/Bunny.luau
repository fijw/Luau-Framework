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
    petImageId = "rbxassetid://107851803184096",

    GameplayStats
    = {
        maxHealth = 20,
        attackDamage = 20
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