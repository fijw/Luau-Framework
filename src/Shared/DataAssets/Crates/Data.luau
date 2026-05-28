--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.DataAssets.Pets.Data)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type PetSchema = Data.PetSchema

export type CrateSchema
= {
    name: string,
    Chances: { [PetSchema]: number },
    price: number
}
--[[ @end_section Types ]]


return table.freeze({})