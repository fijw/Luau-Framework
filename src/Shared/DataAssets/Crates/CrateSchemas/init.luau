--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Assets.Crates.Data)
--[[ @end_section Imports ]]


type CrateSchema = Data.CrateSchema


local CrateSchemas: { [string]: CrateSchema } = {}


-- Get all the schemas.
for i: number, v: Instance in ipairs(script:GetChildren()) do
    CrateSchemas[v.Name] = require(v) :: CrateSchema
end


table.freeze(CrateSchemas)
return CrateSchemas