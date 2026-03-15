--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")

local Compression = require(ServerScriptService.Libraries.Compression)
local Store = require(ServerScriptService.Libraries.Store)
local Reactor = require(ReplicatedStorage.Libraries.Reactor)
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
    local targetId = args[1]
    if not targetId then return end

    table.remove(args, 1)

    local reason = table.concat(args, " ")

    -- If the player is in this server, update their player data class here.
    do
        local player = Players:GetPlayerByUserId(tonumber(targetId) :: number)
        
        if player then
            local PlayerDataClass = Store(tonumber(targetId) :: number)
            if not PlayerDataClass then return end

            (PlayerDataClass() :: { [string]: StateEngine<any> }).kickReason = Reactor(reason);
            (PlayerDataClass() :: { [string]: StateEngine<any> }).isKicked(true)

            return
        end
    end

    MessagingService:PublishAsync("commands",
        Compression(
            {
                targetId = tonumber(targetId) :: number,
                commandType = "kick",
                reason = reason
            }
        )
    )
end

return constructorCallback
--[[ @end_section Constructor ]]