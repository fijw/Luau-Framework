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
            response = ``,
            color = "white"
        },
        
        sender
    )

    -- Display the moderation history.
    do
        if DecompressedData.ModerationData.ModerationHistory.Bans then
            CommandsNamespace.packets.ClientDisplayConsoleResponse
            .sendTo(
                {
                    response = `Ban Logs for [{targetId}]:`,
                    color = "blue"
                },
                
                sender
            )

            for i: string, v: any in pairs(DecompressedData.ModerationData.ModerationHistory.Bans :: { [string]: any }) do
                CommandsNamespace.packets.ClientDisplayConsoleResponse
                .sendTo(
                    {
                        response = `[{v.index}] Reason: "{v.banReason}" Duration: [{v.banDuration}] By: [{v.banningUserId}]`,
                        color = "yellow"
                    },
                    
                    sender
                )
            end
        end

        if DecompressedData.ModerationData.ModerationHistory.DataResets then
            CommandsNamespace.packets.ClientDisplayConsoleResponse
            .sendTo(
                {
                    response = `Data Reset Logs for [{targetId}]:`,
                    color = "blue"
                },
                
                sender
            )

            for i: string, v: any in pairs(DecompressedData.ModerationData.ModerationHistory.DataResets :: { [string]: any }) do
                CommandsNamespace.packets.ClientDisplayConsoleResponse
                .sendTo(
                    {
                        response = `[{v.index}] Reason: "{v.resetReason}" By: [{v.resettingUserId}]`,
                        color = "yellow"
                    },
                    
                    sender
                )
            end
        end

        if DecompressedData.ModerationData.ModerationHistory.Unbans then
            CommandsNamespace.packets.ClientDisplayConsoleResponse
            .sendTo(
                {
                    response = `Unban Logs for [{targetId}]:`,
                    color = "blue"
                },
                
                sender
            )

            for i: string, v: any in pairs(DecompressedData.ModerationData.ModerationHistory.Unbans :: { [string]: any }) do
                CommandsNamespace.packets.ClientDisplayConsoleResponse
                .sendTo(
                    {
                        response = `[{v.index}] Reason: "{v.unbanReason}" By: [{v.unbanningUserId}]`,
                        color = "yellow"
                    },
                    
                    sender
                )
            end
        end
    end

    CommandsNamespace.packets.ClientDisplayConsoleResponse
    .sendTo(
        {
            response = ``,
            color = "white"
        },
        
        sender
    )
end

return constructorCallback
--[[ @end_section Constructor ]]