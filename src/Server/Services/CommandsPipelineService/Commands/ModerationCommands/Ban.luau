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
local Compression = require(ServerScriptService.Libraries.Compression)
local DataLib = require(ServerScriptService.Libraries.DataLib)
local Reactor = require(ReplicatedStorage.Libraries.Reactor)

local LogsHandler = require(ServerScriptService.Services.CommandsPipelineService.LogsHandler)

local GlobalCommandsHandlerTypes = require(ServerScriptService.Services.CommandsPipelineService.GlobalCommandsHandler.Types)

local Settings = require(ReplicatedStorage.Settings)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type StoredDataClassSchema = DataLib.StoredDataClassSchema
type DecompressedDataSchema = GlobalCommandsHandlerTypes.DecompressedDataSchema

--[[ @generic T Source type. ]]
type StateEngine<T> = Reactor.AbstractedStateEngine<T>
--[[ @end_section Types ]]


local DataStore = DataStoreService:GetDataStore(Settings.DataSettings.PLAYER_DATA_STORAGE_KEY)


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
            local PlayerDataClass = DataLib(player)
            if not PlayerDataClass then return end

            PlayerDataClass().ModerationData(
                {
                    permanent = true,
                    banReason = reason
                },
                
                "BanData"
            )

            CommandsNamespace.packets.DisplayConsoleResponse
            .sendTo(
                {
                    response = `Banned [{targetId}]. Reason: "{reason}".`,
                    color = "white"
                },
                
                sender
            )

            LogsHandler("Ban", sender.UserId, targetId, reason)

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
    if not AsyncData then return end

    if AsyncData.inUse == true then
        MessagingService:PublishAsync("commands",
            Compression(
                {
                    targetId = targetId,
                    commandType = "ban",
                    reason = reason
                } :: DecompressedDataSchema
            )
        )

        CommandsNamespace.packets.DisplayConsoleResponse
        .sendTo(
            {
                response = `Sent a global request to ban [{targetId}]. Reason: "{reason}".`,
                color = "white"
            },
            
            sender
        )

        LogsHandler("Ban", sender.UserId, targetId, reason)

        CommandsNamespace.packets.DisplayConsoleResponse
        .sendTo(
            {
                response = `Your moderation action for {targetId} has been logged.`,
                color = "blue"
            },
            
            sender
        )
    else
        local ModifyingData = {}

        -- Decompressing the data and modifying it.
        do
            for i: string, v: any in pairs(Compression(AsyncData.Data, "decompress") :: { [string]: any }) do
                ModifyingData[i] = Compression(v, "decompress")
            end

            ModifyingData.ModerationData.BanData
            = {
                permanent = true,
                banReason = reason
            }
        end

        local SavingData = {}
    
        for i: string, v: any in pairs(ModifyingData) do
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

        CommandsNamespace.packets.DisplayConsoleResponse
        .sendTo(
            {
                response = `Changed [{targetId}]'s stored data to be banned. Reason: "{reason}".`,
                color = "white"
            },
            
            sender
        )

        LogsHandler("Ban", sender.UserId, targetId, reason)

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