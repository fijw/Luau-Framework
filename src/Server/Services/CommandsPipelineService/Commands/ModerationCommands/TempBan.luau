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
local Store = require(ServerScriptService.Libraries.Store)
local Reactor = require(ReplicatedStorage.Libraries.Reactor)

local LogsHandler = require(ServerScriptService.Services.CommandsPipelineService.LogsHandler)

local Settings = require(ReplicatedStorage.Settings)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type StoredPlayerDataClassSchema = Store.StoredPlayerDataClassSchema

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
            local PlayerDataClass = Store(targetId)
            if not PlayerDataClass then return end

            (PlayerDataClass() :: { [string]: StateEngine<any> }).banDuration = Reactor(addTimeUp(timeInteger, timeFrame));
            (PlayerDataClass() :: { [string]: StateEngine<any> }).banReason = Reactor(reason);
            (PlayerDataClass() :: { [string]: StateEngine<any> }).isBanned(true)

            CommandsNamespace.packets.DisplayConsoleResponse
            .sendTo(
                {
                    response = `Temporarily banned [{targetId}] in this server. Duration: {timeInteger} {timeFrame}. Reason: "{reason}".`,
                    color = "white"
                },
                
                sender
            )

            LogsHandler("Ban", sender.UserId, targetId, reason)

            return
        end
    end

    Chronovisor(
        function()
            local FetchedPlayerDataClass: StoredPlayerDataClassSchema?

            FetchedPlayerDataClass = DataStore:GetAsync(`{targetId}`)
            if not FetchedPlayerDataClass then return end

            local DecompressedData = {}

            -- Decompressing the data and modifying it.
            do
                for i: string, v: buffer in pairs(Compression(FetchedPlayerDataClass.Data, "decompress") :: { [string]: buffer }) do
                    DecompressedData[i] = Compression(v, "decompress")
                end

                DecompressedData.banReason = reason
                DecompressedData.isBanned = true
            end

            -- Compressing the decompressed data and saving it.
            do
                local RecompressedData = DecompressedData

                for i: string, v: any in pairs(RecompressedData :: { [string]: any }) do
                    RecompressedData[i] = Compression(v)
                end

                DataStore:SetAsync(`{targetId}`,
                    {
                        Data = Compression(RecompressedData),
                        currentSessionId = FetchedPlayerDataClass.currentSessionId
                    }
                )
            end
        end
    )
    :onError(function(err: string?) print(`Error updating player data class moderation data. Error: {err}`) end)
    
    CommandsNamespace.packets.DisplayConsoleResponse
    .sendTo(
        {
            response = `Sending a global request to temporarily ban [{targetId}]. Duration: {timeInteger} {timeFrame}. Reason: "{reason}".`,
            color = "white"
        },
        
        sender
    )

    MessagingService:PublishAsync("commands",
        Compression(
            {
                targetId = targetId,
                commandType = "ban",
                reason = reason
            }
        )
    )

    LogsHandler("Ban", sender.UserId, targetId, reason)
end

return constructorCallback
--[[ @end_section Constructor ]]