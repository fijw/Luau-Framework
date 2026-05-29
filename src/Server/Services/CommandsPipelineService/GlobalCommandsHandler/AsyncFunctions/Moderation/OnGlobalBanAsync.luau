--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RNG = require(ReplicatedStorage.Libraries.NumberLibs.RNG)
local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)

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
    local reason, targetId = DecompressedData.reason, DecompressedData.targetId
    if not reason or not targetId then return end

    local FoundPlayer = Players:GetPlayerByUserId(targetId)
    if not FoundPlayer then return end

    local PlayerDataClass = Registry(FoundPlayer)
    if not PlayerDataClass then return end

    -- Update the moderation history.
    do
        if not PlayerDataClass()().ModerationData().ModerationHistory then PlayerDataClass()().ModerationData({}, "ModerationHistory") end
        if not (PlayerDataClass()().ModerationData().ModerationHistory :: any).Bans then PlayerDataClass()().ModerationData({}, "Bans", "ModerationHistory") end
        if not (PlayerDataClass()().ModerationData().ModerationHistory :: any).numOfBans then PlayerDataClass()().ModerationData(0, "numOfBans", "ModerationHistory") end

        local numOfBans = (PlayerDataClass()().ModerationData().ModerationHistory :: any).numOfBans + 1

        PlayerDataClass()().ModerationData(
            numOfBans,
            "numOfBans",
            "ModerationHistory"
        )

        PlayerDataClass()().ModerationData(
            {
                banDuration = `Permanent`,
                banReason = reason,
                banningUserId = DecompressedData.senderId,
                index = numOfBans
            },

            RNG.randomString(8),

            "ModerationHistory",
            "Bans"
        )
    end

    PlayerDataClass()().ModerationData(
        {
            permanent = true,
            banReason = reason
        },
        
        "BanData"
    )
end

return constructorCallback
--[[ @end_section Constructor ]]