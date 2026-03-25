--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")

local CommandsNamespace = require(ReplicatedStorage.Networking.Namespaces.Services.Commands)

local Compression = require(ServerScriptService.Libraries.Compression)
local DataLib = require(ServerScriptService.Libraries.DataLib)

local GlobalCommandsHandlerTypes = require(ServerScriptService.Services.CommandsPipelineService.GlobalCommandsHandler.Types)

local LogsHandler = require(ServerScriptService.Services.CommandsPipelineService.LogsHandler)
--[[ @end_section Imports ]]


type StoredDataClassSchema = DataLib.StoredDataClassSchema
type DecompressedDataSchema = GlobalCommandsHandlerTypes.DecompressedDataSchema


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

    local reason = table.concat(args, " ")

    -- If the player is in this server, update their player data class here.
    do
        local player = Players:GetPlayerByUserId(targetId)
        
        if player then
            player:Kick(`\n\nYou have been kicked.\nReason: "{reason}".\n\n\n`)

            CommandsNamespace.packets.DisplayConsoleResponse
            .sendTo(
                {
                    response = `Kicked [{targetId}]. Reason: "{reason}".`,
                    color = "white"
                },
                
                sender
            )

            LogsHandler("Kick", sender.UserId, targetId, reason)

            CommandsNamespace.packets.DisplayConsoleResponse
            .sendTo(
                {
                    response = `Your moderation action for {targetId} has been logged.`,
                    color = "blue"
                },
                
                sender
            )

            return
        end
    end

    local AsyncData = DataLib.forciblyFetchStoredPlayerData(targetId)
    if not AsyncData or AsyncData.inUse == false then return end

    -- If the player is not in this server but has a player data class, send a global request to kick them.
    do
        MessagingService:PublishAsync("commands",
            Compression(
                {
                    targetId = targetId,
                    commandType = "kick",
                    reason = reason
                } :: DecompressedDataSchema
            )
        )

        CommandsNamespace.packets.DisplayConsoleResponse
        .sendTo(
            {
                response = `Sent a global request to kick [{targetId}]. Reason: "{reason}".`,
                color = "white"
            },
            
            sender
        )

        LogsHandler("Kick", sender.UserId, targetId, reason)

        CommandsNamespace.packets.DisplayConsoleResponse
        .sendTo(
            {
                response = `Your moderation action for {targetId} has been logged.`,
                color = "blue"
            },
            
            sender
        )
    end
end

return constructorCallback
--[[ @end_section Constructor ]]