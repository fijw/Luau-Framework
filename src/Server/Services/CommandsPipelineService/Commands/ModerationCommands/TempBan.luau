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
local Compression = require(ServerScriptService.Libraries.DataLibs.Compression)
local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local TimeLib = require(ReplicatedStorage.Libraries.TimeLib)

local GlobalCommandsHandlerTypes = require(ServerScriptService.Services.CommandsPipelineService.GlobalCommandsHandler.Types)

local Settings = require(ReplicatedStorage.Settings)
--[[ @end_section Imports ]]


type DecompressedDataSchema = GlobalCommandsHandlerTypes.DecompressedDataSchema
type TimeFrameTypes = TimeLib.TimeFrameTypes


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

    local timeInteger = tonumber(args[1]) :: number
    if not timeInteger then return end

    table.remove(args, 1)

    local timeFrame = args[1] :: TimeFrameTypes
    if not timeFrame then return end

    table.remove(args, 1)

    local reason = table.concat(args, " ")
    if #reason < 1 then reason = "No reason provided" end

    local banDuration = TimeLib.addTimeUp(timeInteger, timeFrame)

    -- If the player is in this server, update their player data class here.
    do
        local player = Players:GetPlayerByUserId(targetId)
        
        if player then
            local PlayerDataClass = Registry(player)
            if not PlayerDataClass then return end

            -- Update the moderation data.
            do
                local numOfBans = (PlayerDataClass()().ModerationData().ModerationHistory :: any).numOfBans

                if not numOfBans then
                    PlayerDataClass()().ModerationData(0, "numOfBans", "ModerationHistory")
                else
                    PlayerDataClass()().ModerationData(
                        numOfBans + 1,
                        "numOfBans",
                        "ModerationHistory"
                    )
                end

                PlayerDataClass()().ModerationData(
                    {
                        banningUserId = sender.UserId,
                        banReason = reason,
                        banDuration = `{timeInteger} {timeFrame}`,
                        index = numOfBans + 1
                    },
                    
                    RNG.randomString(8),

                    "ModerationHistory",
                    "Bans"
                )

                PlayerDataClass()().ModerationData(
                    {
                        banDuration = banDuration,
                        banReason = reason
                    },

                    "BanData"
                )
            end

            CommandsNamespace.packets.ClientDisplayConsoleResponse
            .sendTo(
                {
                    response = `Temp-banned [{targetId}]. Duration: [{timeInteger} {timeFrame}]. Reason: "{reason}".`,
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
                response = `Failed to temp-ban [{targetId}]. Could not fetch stored player data.`,
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
                    senderId = sender.UserId,
                    commandType = "temp_ban",
                    reason = reason,
                    duration = banDuration,

                    timeFrame = timeFrame,
                    timeInteger = timeInteger
                } :: DecompressedDataSchema
            )
        )

        CommandsNamespace.packets.ClientDisplayConsoleResponse
        .sendTo(
            {
                response = `Sent a request to temp-ban [{targetId}]. Duration: [{timeInteger} {timeFrame}]. Reason: "{reason}".`,
                color = "white"
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
                banDuration = banDuration,
                banReason = reason
            }

            if not ModifyingData.ModerationData.ModerationHistory then ModifyingData.ModerationData.ModerationHistory = {} end
            if not ModifyingData.ModerationData.ModerationHistory.Bans then ModifyingData.ModerationData.ModerationHistory.Bans = {} end

            if not ModifyingData.ModerationData.ModerationHistory.numOfBans then ModifyingData.ModerationData.ModerationHistory.numOfBans = 0 end
            ModifyingData.ModerationData.ModerationHistory.numOfBans += 1

            ModifyingData.ModerationData.ModerationHistory.Bans[RNG.randomString(8)]
            = {
                banDuration = `{timeInteger} {timeFrame}`,
                banReason = reason,
                banningUserId = sender.UserId,
                index = ModifyingData.ModerationData.ModerationHistory.numOfBans
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
                response = `Set [{targetId}] as temp-banned. Duration: [{timeInteger} {timeFrame}]. Reason: "{reason}".`,
                color = "white"
            },
            
            sender
        )
    end
end

return constructorCallback
--[[ @end_section Constructor ]]