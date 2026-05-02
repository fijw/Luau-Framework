--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Compression = require(ReplicatedStorage.Libraries.Compression)
local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)

local CommandsGroup = require(ReplicatedStorage.Networking.PacketGroups.Services.Commands)
--[[ @end_section Imports ]]


--[[ @section Constructor ]]
--[[
    @usage Initialize the command.

    @param sender Player
    @param args { string }

    @return void
]]
local function constructorCallback(sender: Player, args: { string })
    local targetId = tonumber(args[1]) :: number
    if not targetId then return end

    table.remove(args, 1)

    local AsyncData = Registry.forciblyFetchStoredPlayerData(targetId)
    if not AsyncData then return end

    local DecompressedData = {} :: { [string]: any }

    for i: string, v: any in pairs(Compression(AsyncData.Data, "decompress") :: { [string]: any }) do
        DecompressedData[i] = Compression(v, "decompress")
    end

    if not DecompressedData.ModerationData.ModerationHistory then
        CommandsGroup.DisplayConsoleMessage:fireClient(sender,
            {
                message = `No moderation history found for [{targetId}].`,
                color = "yellow"
            }
        )
        
        return
    end

    CommandsGroup.DisplayConsoleMessage:fireClient(sender,
        {
            message = ``,
            color = "white"
        }
    )

    -- Display the moderation history.
    do
        if DecompressedData.ModerationData.ModerationHistory.Bans then
            CommandsGroup.DisplayConsoleMessage:fireClient(sender,
                {
                    message = `Ban Logs for [{targetId}]:`,
                    color = "blue"
                }
            )

            for i: string, v: any in pairs(DecompressedData.ModerationData.ModerationHistory.Bans :: { [string]: any }) do
                CommandsGroup.DisplayConsoleMessage:fireClient(sender,
                    {
                        message = `[{v.index}] Reason: "{v.banReason}" Duration: [{v.banDuration}] By: [{v.banningUserId}]`,
                        color = "yellow"
                    }
                )
            end
        end

        if DecompressedData.ModerationData.ModerationHistory.DataResets then
            CommandsGroup.DisplayConsoleMessage:fireClient(sender,
                {
                    message = `Data Reset Logs for [{targetId}]:`,
                    color = "blue"
                }
            )

            for i: string, v: any in pairs(DecompressedData.ModerationData.ModerationHistory.DataResets :: { [string]: any }) do
                CommandsGroup.DisplayConsoleMessage:fireClient(sender,
                    {
                        message = `[{v.index}] Reason: "{v.resetReason}" By: [{v.resettingUserId}]`,
                        color = "yellow"
                    }
                )
            end
        end

        if DecompressedData.ModerationData.ModerationHistory.Unbans then
            CommandsGroup.DisplayConsoleMessage:fireClient(sender,
                {
                    message = `Unban Logs for [{targetId}]:`,
                    color = "blue"
                }
            )

            for i: string, v: any in pairs(DecompressedData.ModerationData.ModerationHistory.Unbans :: { [string]: any }) do
                CommandsGroup.DisplayConsoleMessage:fireClient(sender,
                    {
                        message = `[{v.index}] Reason: "{v.unbanReason}" By: [{v.unbanningUserId}]`,
                        color = "yellow"
                    }
                )
            end
        end
    end

    CommandsGroup.DisplayConsoleMessage:fireClient(sender,
        {
            message = ``,
            color = "white"
        }
    )
end

return constructorCallback
--[[ @end_section Constructor ]]