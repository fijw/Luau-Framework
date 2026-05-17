--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreService = game:GetService("DataStoreService")
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")

local CommandsGroup = require(ReplicatedStorage.Networking.PacketGroups.Services.Commands)

local Chronovisor = require(ReplicatedStorage.Libraries.Chronovisor)
local RNG = require(ReplicatedStorage.Libraries.RNG)
local Reactor = require(ReplicatedStorage.Libraries.Reactor)
local Compression = require(ReplicatedStorage.Libraries.DataLibs.Compression)
local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)

local GlobalCommandsHandlerTypes = require(ServerScriptService.Services.CommandsPipelineService.GlobalCommandsHandler.Types)

local DataSettings = require(ReplicatedStorage.FrameworkSettings.DataSettings)
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

                local numOfDataResets = (PlayerDataClass()().ModerationData().ModerationHistory :: any).numOfDataResets

                if not numOfDataResets then
                    PlayerDataClass()().ModerationData(0, "numOfDataResets", "ModerationHistory")
                else
                    PlayerDataClass()().ModerationData(
                        numOfDataResets + 1,
                        "numOfDataResets",
                        "ModerationHistory"
                    )
                end

                PlayerDataClass()().ModerationData(
                    {
                        resettingUserId = sender.UserId,
                        resetReason = reason,
                        index = numOfDataResets + 1
                    },

                    RNG.randomString(8),

                    "ModerationHistory",
                    "DataResets"
                )
            end

            player:Kick(`\n\nYour data has been reset.\nReason: "{reason}".\n\n\n`)

            CommandsGroup.DisplayConsoleMessage:fireClient(sender,
                {
                    message = `Reset [{targetId}]'s player data. Reason: "{reason}".`,
                    color = "white"
                }
            )

            return
        end
    end

    local AsyncData = Registry.forciblyFetchStoredPlayerData(targetId)

    if not AsyncData then
        CommandsGroup.DisplayConsoleMessage:fireClient(sender,
            {
                message = `Failed to reset [{targetId}]'s player data. Could not fetch stored player data.`,
                color = "red"
            }
        )

        return
    end

    if AsyncData.inUse == true then
        MessagingService:PublishAsync("commands",
            Compression(
                {
                    targetId = targetId,
                    senderId = sender.UserId,
                    commandType = "reset_data",
                    reason = reason
                } :: DecompressedDataSchema
            )
        )

        CommandsGroup.DisplayConsoleMessage:fireClient(sender,
            {
                message = `Sent a request to reset [{targetId}]'s player data. Reason: "{reason}".`,
                color = "white"
            }
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
                resetReason = reason,
                index = ModifyingData.ModerationData.ModerationHistory.numOfDataResets
            }
            
            if not ModifyingData.ModerationData.ModerationHistory.numOfDataResets then ModifyingData.ModerationData.ModerationHistory.numOfDataResets = 0 end
            ModifyingData.ModerationData.ModerationHistory.numOfDataResets += 1
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

        CommandsGroup.DisplayConsoleMessage:fireClient(sender,
            {
                message = `Reset [{targetId}]'s stored player data. Reason: "{reason}".`,
                color = "white"
            }
        )
    end
end

return constructorCallback
--[[ @end_section Constructor ]]