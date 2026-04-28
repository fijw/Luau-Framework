--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreService = game:GetService("DataStoreService")
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")

local CommandsNamespace = require(ReplicatedStorage.Networking.Namespaces.Services.Commands)

local Chronovisor = require(ReplicatedStorage.Libraries.Chronovisor)
local RNG = require(ReplicatedStorage.Libraries.RNG)
local Reactor = require(ReplicatedStorage.Libraries.Reactor)
local Compression = require(ServerScriptService.Libraries.DataLibs.Compression)
local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)

local GlobalCommandsHandlerTypes = require(ServerScriptService.Services.CommandsPipelineService.GlobalCommandsHandler.Types)

local DataSettings = require(ReplicatedStorage.Settings.DataSettings)
--[[ @end_section Imports ]]


--[[ @section Types ]]
--[[ @generic T Source type. ]]
type StateEngine<T> = Reactor.StateEngine<T>

type DecompressedDataSchema = GlobalCommandsHandlerTypes.DecompressedDataSchema
--[[ @end_section Types ]]


local DataStore = DataStoreService:GetDataStore(DataSettings.PLAYER_DATA_STORAGE_KEY)


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
    if #reason < 1 then reason = "No reason provided" end

    -- If the player is in this server, update their player data class here.
    do
        local player = Players:GetPlayerByUserId(targetId)
        
        if player then
            local PlayerDataClass = Registry(player)
            if not PlayerDataClass then return end

            -- Update the player's moderation data.
            do
                for i: string, v: any in pairs(DataSettings.DataTemplate :: { [string]: any }) do
                    (PlayerDataClass() :: StateEngine<{ [string]: StateEngine<any> }>)(Reactor(v), i)
                end

                PlayerDataClass()().ModerationData(
                    {
                        resettingUserId = sender.UserId,
                        reason = reason
                    },

                    RNG.randomString(8),

                    "ModerationHistory",
                    "DataResets"
                )
            end

            player:Kick(`\n\nYour data has been reset.\nReason: "{reason}".\n\n\n`)

            CommandsNamespace.packets.ClientDisplayConsoleResponse
            .sendTo(
                {
                    response = `Reset [{targetId}]'s player data. Reason: "{reason}".`,
                    color = "white"
                },
                
                sender
            )

            return
        end
    end

    local AsyncData = Registry.forciblyFetchStoredPlayerData(targetId)

    if not AsyncData then
        CommandsNamespace.packets.ClientDisplayConsoleResponse
        .sendTo(
            {
                response = `Failed to reset [{targetId}]'s player data. Could not fetch stored player data.`,
                color = "red"
            },
            
            sender
        )

        return
    end

    if AsyncData.inUse == true then
        MessagingService:PublishAsync("commands",
            Compression(
                {
                    targetId = targetId,
                    commandType = "reset_data",
                    reason = reason
                } :: DecompressedDataSchema
            )
        )

        CommandsNamespace.packets.ClientDisplayConsoleResponse
        .sendTo(
            {
                response = `Sent a request to reset [{targetId}]'s player data. Reason: "{reason}".`,
                color = "white"
            },
            
            sender
        )
    else
        local ModifyingData = {} :: { [string]: any }

        -- Decompressing the data and modifying it.
        do
            for i: string, v: any in pairs(Compression(AsyncData.Data, "decompress") :: { [string]: any }) do
                ModifyingData[i] = Compression(v, "decompress")
            end

            for i: string, v: any in pairs(DataSettings.DataTemplate :: { [string]: any }) do ModifyingData[i] = v end

            if not ModifyingData.ModerationData.ModerationHistory then ModifyingData.ModerationData.ModerationHistory = {} end
            if not ModifyingData.ModerationData.ModerationHistory.DataResets then ModifyingData.ModerationData.ModerationHistory.DataResets = {} end

            ModifyingData.ModerationData.ModerationHistory.DataResets[RNG.randomString(8)]
            = {
                resettingUserId = sender.UserId,
                reason = reason
            }
            
        end

        local SavingData = {}
    
        for i: string, v: any in pairs(ModifyingData :: { [string]: any }) do
            SavingData[i] = Compression(v)
        end

        Chronovisor(
            function()
                DataStore:SetAsync(`{targetId}`,
                    {
                        Data = Compression(SavingData),
                        inUse = AsyncData.inUse
                    }
                )
            end
        )
        :onError(function(err: string?) print(`Failed to save moderation data changes. Error: {err}`) end)

        CommandsNamespace.packets.ClientDisplayConsoleResponse
        .sendTo(
            {
                response = `Reset [{targetId}]'s stored player data. Reason: "{reason}".`,
                color = "white"
            },
            
            sender
        )
    end
end

return constructorCallback
--[[ @end_section Constructor ]]