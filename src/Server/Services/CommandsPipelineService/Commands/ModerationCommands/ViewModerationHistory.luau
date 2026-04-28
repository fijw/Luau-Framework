--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Compression = require(ServerScriptService.Libraries.DataLibs.Compression)
local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)

local CommandsNamespace = require(ReplicatedStorage.Networking.Namespaces.Services.Commands)
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
        CommandsNamespace.packets.ClientDisplayConsoleResponse
        .sendTo(
            {
                response = `No moderation history found for [{targetId}].`,
                color = "yellow"
            },
            
            sender
        )
        
        return
    end

    CommandsNamespace.packets.ClientDisplayConsoleResponse
    .sendTo(
        {
            response = `Ban Logs for [{targetId}]:`,
            color = "blue"
        },
        
        sender
    )

    -- Display the moderation history.
    do
        if DecompressedData.ModerationData.ModerationHistory.Bans then
            for i: number, v: any in ipairs(DecompressedData.ModerationData.ModerationHistory.Bans) do
                CommandsNamespace.packets.ClientDisplayConsoleResponse
                .sendTo(
                    {
                        response = `Ban Reason: {v.banReason} | Ban Duration: {v.banDuration} | Banned By: {v.banningUserId}`,
                        color = "yellow"
                    },
                    
                    sender
                )
            end
        end

        if DecompressedData.ModerationData.ModerationHistory.DataResets then
            for i: number, v: any in ipairs(DecompressedData.ModerationData.ModerationHistory.DataResets) do
                CommandsNamespace.packets.ClientDisplayConsoleResponse
                .sendTo(
                    {
                        response = `Data Reset Reason: {v.reason} | Reset By: {v.resettingUserId}`,
                        color = "yellow"
                    },
                    
                    sender
                )
            end
        end

        if DecompressedData.ModerationData.ModerationHistory.Unbans then
            for i: number, v: any in ipairs(DecompressedData.ModerationData.ModerationHistory.Unbans) do
                CommandsNamespace.packets.ClientDisplayConsoleResponse
                .sendTo(
                    {
                        response = `Unban Reason: {v.reason} | Unbanned By: {v.unbanningUserId}`,
                        color = "yellow"
                    },
                    
                    sender
                )
            end
        end
    end
end

return constructorCallback
--[[ @end_section Constructor ]]