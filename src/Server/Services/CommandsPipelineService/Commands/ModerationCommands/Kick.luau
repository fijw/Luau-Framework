--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")

local CommandsGroup = require(ReplicatedStorage.Networking.PacketGroups.Services.Commands)

local Compression = require(ReplicatedStorage.Libraries.DataLibs.Compression)
local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)

local GlobalCommandsHandlerTypes = require(ServerScriptService.Services.CommandsPipelineService.GlobalCommandsHandler.Types)
--[[ @end_section Imports ]]


type DecompressedDataSchema = GlobalCommandsHandlerTypes.DecompressedDataSchema


--[[ @section Constructor ]]
--[[
    @usage Initialize the command.

    @param sender Player
    @param args { string }

    @return void
]]
local function constructorCallback(sender: Player, args: { string }): ()
    local targetId = tonumber(args[1]) :: number
    if not targetId then return end

    table.remove(args, 1)

    local reason = table.concat(args, " ")
    if #reason < 1 then reason = "No reason provided" end

    -- If the player is in this server, update their player data class here.
    do
        local player = Players:GetPlayerByUserId(targetId)
        
        if player then
            player:Kick(`\n\nYou have been kicked.\nReason: "{reason}".\n\n\n`)

            CommandsGroup.DisplayConsoleMessage:fireClient(sender,
                {
                    message = `Kicked [{targetId}]. Reason: "{reason}".`,
                    color = "white"
                }
            )

            return
        end
    end

    local AsyncData = Registry.forciblyFetchStoredPlayerData(targetId)

    if not AsyncData or AsyncData.inUse == false then
        CommandsGroup.DisplayConsoleMessage:fireClient(sender,
            {
                message = `Failed to kick [{targetId}]. Could not fetch stored player data.`,
                color = "red"
            }
        )

        return
    end

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

        CommandsGroup.DisplayConsoleMessage:fireClient(sender,
            {
                message = `Sent a request to kick [{targetId}]. Reason: "{reason}".`,
                color = "white"
            }
        )
    end
end

return constructorCallback
--[[ @end_section Constructor ]]