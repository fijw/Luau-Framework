--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RNG = require(ReplicatedStorage.Libraries.RNG)
local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)

local Types = require(script.Parent.Parent.Parent.Types)

local TimeLib = require(ReplicatedStorage.Libraries.TimeLib)
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

    local PlayerDataClass = Registry(FoundPlayer)
    if not PlayerDataClass then return end

    PlayerDataClass()().ModerationData(
        {
            banDuration = duration,
            banReason = reason
        },

        "BanData"
    )

    -- Update the moderation history.
    do
        if not PlayerDataClass()().ModerationData().ModerationHistory then PlayerDataClass()().ModerationData({}, "ModerationHistory") end
        if not (PlayerDataClass()().ModerationData().ModerationHistory :: any).Bans then PlayerDataClass()().ModerationData({}, "Bans", "ModerationHistory") end

        PlayerDataClass()().ModerationData(
            {
                banningUserId = FoundPlayer.UserId,
                banDuration = TimeLib.formatTime(duration),
                banReason = reason
            },

            RNG.randomString(8),

            "ModerationHistory",
            "Bans"
        )
    end
end

return constructorCallback
--[[ @end_section Constructor ]]