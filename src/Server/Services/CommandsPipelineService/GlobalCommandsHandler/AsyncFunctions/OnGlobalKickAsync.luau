--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")

local Types = require(script.Parent.Parent.Types)
--[[ @end_section Imports ]]


type DecompressedDataSchema = Types.DecompressedDataSchema


--[[ @section Constructor ]]
--[[
    @usage Initialize the global command.

    @param DecompressedData DecompressedDataSchema

    @return void
]]
local function constructorCallback(DecompressedData: DecompressedDataSchema)
    local reason, targetId = DecompressedData.reason, DecompressedData.targetId
    if not reason or not targetId then return end

    local FoundPlayer = Players:GetPlayerByUserId(targetId)
    if not FoundPlayer then return end

    FoundPlayer:Kick(`\n\nYou have been kicked.\nReason: "{reason}".\n\n\n`)
end

return constructorCallback
--[[ @end_section Constructor ]]