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
local Store = require(ServerScriptService.Libraries.Store)
local Reactor = require(ReplicatedStorage.Libraries.Reactor)

local LogsHandler = require(ServerScriptService.Services.CommandsPipelineService.LogsHandler)
--[[ @end_section Imports ]]


--[[ @generic T Source type. ]]
type StateEngine<T> = Reactor.AbstractedStateEngine<T>


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
            local PlayerDataClass = Store(targetId)
            if not PlayerDataClass then return end

            (PlayerDataClass() :: { [string]: StateEngine<any> }).kickReason = Reactor(reason);
            (PlayerDataClass() :: { [string]: StateEngine<any> }).isKicked(true)

            CommandsNamespace.packets.DisplayConsoleResponse
            .sendTo(
                {
                    response = `Kicked [{targetId}] in this server. Reason: "{reason}".`,
                    color = "white"
                },
                
                sender
            )

            LogsHandler("Kick", sender.UserId, targetId, reason)

            return
        end
    end

    CommandsNamespace.packets.DisplayConsoleResponse
    .sendTo(
        {
            response = `Sending a global request to kick [{targetId}]. Reason: "{reason}".`,
            color = "white"
        },
        
        sender
    )

    MessagingService:PublishAsync("commands",
        Compression(
            {
                targetId = targetId,
                commandType = "kick",
                reason = reason
            }
        )
    )

    LogsHandler("Kick", sender.UserId, targetId, reason)
end

return constructorCallback
--[[ @end_section Constructor ]]