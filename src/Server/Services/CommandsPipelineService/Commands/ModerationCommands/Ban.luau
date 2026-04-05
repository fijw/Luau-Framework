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
local Compression = require(ServerScriptService.Libraries.DataLibs.Compression)
local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)

local LogsHandler = require(ServerScriptService.Services.CommandsPipelineService.LogsHandler)

local GlobalCommandsHandlerTypes = require(ServerScriptService.Services.CommandsPipelineService.GlobalCommandsHandler.Types)

local DataSettings = require(ReplicatedStorage.Settings.DataSettings)
--[[ @end_section Imports ]]


type DecompressedDataSchema = GlobalCommandsHandlerTypes.DecompressedDataSchema


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

            PlayerDataClass().ModerationData(
                {
                    permanent = true,
                    banReason = reason
                },
                
                "BanData"
            )

            CommandsNamespace.packets.ClientDisplayConsoleResponse
            .sendTo(
                {
                    response = `Perm-banned [{targetId}]. Reason: "{reason}".`,
                    color = "white"
                },
                
                sender
            )

            LogsHandler("Ban", sender.UserId, targetId, reason)

            CommandsNamespace.packets.ClientDisplayConsoleResponse
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

    local AsyncData = Registry.forciblyFetchStoredPlayerData(targetId)

    if not AsyncData then
        CommandsNamespace.packets.ClientDisplayConsoleResponse
        .sendTo(
            {
                response = `Failed to perm-ban [{targetId}]. Could not fetch stored player data.`,
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
                    commandType = "ban",
                    reason = reason
                } :: DecompressedDataSchema
            )
        )

        CommandsNamespace.packets.ClientDisplayConsoleResponse
        .sendTo(
            {
                response = `Sent a request to perm-ban [{targetId}]. Reason: "{reason}".`,
                color = "white"
            },
            
            sender
        )

        LogsHandler("Ban", sender.UserId, targetId, reason)

        CommandsNamespace.packets.ClientDisplayConsoleResponse
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

        CommandsNamespace.packets.ClientDisplayConsoleResponse
        .sendTo(
            {
                response = `Set [{targetId}] as perm-banned. Reason: "{reason}".`,
                color = "white"
            },
            
            sender
        )

        LogsHandler("Ban", sender.UserId, targetId, reason)

        CommandsNamespace.packets.ClientDisplayConsoleResponse
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