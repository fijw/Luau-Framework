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

            PlayerDataClass()().ModerationData(
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

            -- Update the moderation history.
            do
                if not PlayerDataClass()().ModerationData().ModerationHistory then PlayerDataClass()().ModerationData({}, "ModerationHistory") end
                if not (PlayerDataClass()().ModerationData().ModerationHistory :: any).Bans then PlayerDataClass()().ModerationData({}, "Bans", "ModerationHistory") end

                PlayerDataClass()().ModerationData(
                    {
                        banningUserId = sender.UserId,
                        banReason = reason,
                        banDuration = "Permanent"
                    },
                    
                    "insert_to_array",
                    "Bans",
                    "ModerationHistory"
                )
            end

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

            if not ModifyingData.ModerationData.ModerationHistory then ModifyingData.ModerationData.ModerationHistory = {} end
            if not ModifyingData.ModerationData.ModerationHistory.Bans then ModifyingData.ModerationData.ModerationHistory.Bans = {} end

            table.insert(ModifyingData.ModerationData.ModerationHistory.Bans,
                {
                    banDuration = "Permanent",
                    banReason = reason,
                    banningUserId = sender.UserId
                }
            )
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
                response = `Set [{targetId}] as perm-banned. Reason: "{reason}".`,
                color = "white"
            },
            
            sender
        )

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