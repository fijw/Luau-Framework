--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local Types = require(script.Parent.Parent.Parent.Types)
--[[ @end_section Imports ]]


type DecompressedDataSchema = Types.DecompressedDataSchema


--[[ @section Constructor ]]
--[[
    @usage Initialize the global command.

    @param DecompressedData DecompressedDataSchema

    @return void
]]
local function constructorCallback(DecompressedData: DecompressedDataSchema): ()
    local targetId, senderId = DecompressedData.targetId, DecompressedData.senderId
    if not targetId or not senderId then return end

    local player = Players:GetPlayerByUserId(targetId)
    if not player then return end

    local isHere, _currentInstance, placeId, jobId = TeleportService:GetPlayerPlaceInstanceAsync(senderId)
    if isHere then return end

    TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
end

return constructorCallback
--[[ @end_section Constructor ]]