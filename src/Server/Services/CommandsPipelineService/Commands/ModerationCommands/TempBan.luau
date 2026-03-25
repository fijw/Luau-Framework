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
type DecompressedDataSchema = GlobalCommandsHandlerTypes.DecompressedDataSchema
type StoredDataClassSchema = DataLib.StoredDataClassSchema

--[[ @generic T Source type. ]]
type StateEngine<T> = Reactor.AbstractedStateEngine<T>

type TimeFrameTypes = "minutes" | "hours" | "days" | "years" | "minute" | "hour" | "day" | "year"
--[[ @end_section Types ]]


local DataStore = DataStoreService:GetDataStore(Settings.DataSettings.PLAYER_DATA_STORAGE_KEY)


--[[
    @usage Add time to the current time.

    @param timeInteger number
    @param timeFrame TimeFrameTypes

    @return number
]]
local function addTimeUp(timeInteger: number, timeFrame: TimeFrameTypes): number
    local SecondsPerUnit
    = {
        minutes = 60,
        hours = 60 * 60,
        days = 60 * 60 * 24,
        years = 60 * 60 * 24 * 365,

        minute = 60,
        hour = 60 * 60,
        day = 60 * 60 * 24,
        year = 60 * 60 * 24 * 365
    }

    local multiplier = SecondsPerUnit[timeFrame] :: number

    return os.time() + (timeInteger * multiplier)
end


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

    local timeInteger = tonumber(args[1]) :: number
    if not timeInteger then return end

    table.remove(args, 1)

    local timeFrame = args[1] :: TimeFrameTypes
    if not timeFrame then return end

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
                    banDuration = addTimeUp(timeInteger, timeFrame),
                    banReason = reason
                },

                "BanData"
            )

            CommandsNamespace.packets.DisplayConsoleResponse
            .sendTo(
                {
                    response = `Temporarily banned [{targetId}]. Duration: {timeInteger} {timeFrame}. Reason: "{reason}".`,
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
                    commandType = "temp_ban",
                    reason = reason,
                    duration = addTimeUp(timeInteger, timeFrame)
                } :: DecompressedDataSchema
            )
        )

        CommandsNamespace.packets.DisplayConsoleResponse
        .sendTo(
            {
                response = `Sent a global request to temporarily ban [{targetId}]. Duration: {timeInteger} {timeFrame}. Reason: "{reason}".`,
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
                banDuration = addTimeUp(timeInteger, timeFrame),
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
                response = `Changed [{targetId}]'s stored data to be temporarily banned. Reason: "{reason}".`,
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