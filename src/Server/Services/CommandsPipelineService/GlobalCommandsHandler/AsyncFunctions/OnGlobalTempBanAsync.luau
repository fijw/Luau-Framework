--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local DataLib = require(ServerScriptService.Libraries.DataLib)

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
    local reason, targetId, duration = DecompressedData.reason, DecompressedData.targetId, DecompressedData.duration
    if not reason or not targetId or not duration then return end

    local FoundPlayer = Players:GetPlayerByUserId(targetId)
    if not FoundPlayer then return end

    local PlayerDataClass = DataLib(FoundPlayer)
    if not PlayerDataClass then return end

    PlayerDataClass().ModerationData(
        {
            banDuration = duration,
            banReason = reason
        },

        "BanData"
    )
end

return constructorCallback
--[[ @end_section Constructor ]]