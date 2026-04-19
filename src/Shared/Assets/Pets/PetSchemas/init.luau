--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Assets.Pets.Data)
--[[ @end_section Imports ]]


type PetSchema = Data.PetSchema


local PetSchemas: { [string]: PetSchema } = {}


-- Get all the schemas.
for i: number, v: Instance in ipairs(script:GetChildren()) do
    PetSchemas[v.Name] = require(v) :: PetSchema
end


table.freeze(PetSchemas)
return PetSchemas