--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CmdsSettings = require(ReplicatedStorage.Settings.CmdsSettings)

local Chronovisor = require(ReplicatedStorage.Libraries.Chronovisor)
--[[ @end_section Imports ]]


--[[ @section Constructor ]]
--[[
    @usage Log a command to Discord.

    @param actionType string
    @param senderId number
    @param targetId number
    @param reason string
    @param duration string?

    @return void
]]
local function constructorCallback(actionType: string, senderId: number, targetId: number, reason: string, duration: string?)
    local currentTime = DateTime.now():ToIsoDate()

    local senderHeadshotUrl: string
    local targetHeadshotUrl: string

    -- Try to get the sender and target headshot images.
    Chronovisor(
        function()
            local targetHeadshotResponse
            = HttpService:GetAsync(
                "https://thumbnails.roproxy.com/v1/users/avatar-headshot?userIds="
                ..targetId
                .."&size=180x180&format=Png"
            )

            local senderHeadshotResponse
            = HttpService:GetAsync(
                "https://thumbnails.roproxy.com/v1/users/avatar-headshot?userIds="
                ..senderId
                .."&size=180x180&format=Png"
            )

            local decodedSenderResponse = HttpService:JSONDecode(senderHeadshotResponse)
            senderHeadshotUrl = decodedSenderResponse.data[1].imageUrl

            local decodedTargetResponse = HttpService:JSONDecode(targetHeadshotResponse)
            targetHeadshotUrl = decodedTargetResponse.data[1].imageUrl
        end
    )
    :onError(function(err: string?) print(`Failed to get headshot for webhook logging. Error: {err}`) end)

    local EmbeddedData
    = {
        content = "",

        --username = "Command Logging",

        embeds
        = {
            {
                title = "Command Log",
                description = "A command has been executed.",

                --color = DISCORD_BLURPLE_COLOR,
                type = "rich",

                fields
                = {
                    {
                        name = "Action Type",
                        value = actionType,
                        inline = true
                    },

                    {
                        name = "Sender UserId",
                        value = senderId,
                        inline = true
                    },
                    
                    {
                        name = "Target UserId",
                        value = targetId,
                        inline = true
                    },

                    if duration then
                        {
                            name = "Duration",
                            value = duration,
                            inline = true
                        }
                    else nil,

                    {
                        name = "Reason",
                        value = reason,
                        inline = true
                    }
                },

                thumbnail = if senderHeadshotUrl then { url = senderHeadshotUrl } else nil,
                image = if targetHeadshotUrl then { url = targetHeadshotUrl } else nil,

                footer = { text = "Automated command logging." },

                timestamp = currentTime,
            }
        }
    }

    Chronovisor(
        function()
            local encodedData = HttpService:JSONEncode(EmbeddedData)
            HttpService:PostAsync(CmdsSettings.loggingDiscordWebhookUrl, encodedData)
        end
    )
    :onError(function(err: string?) print(`Failed to log command of type: {actionType}. Error: {err}`) end)
end

return constructorCallback
--[[ @end_section Constructor ]]