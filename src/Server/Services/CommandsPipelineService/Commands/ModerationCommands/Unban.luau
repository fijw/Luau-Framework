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

local Settings = require(ReplicatedStorage.Settings)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type StoredDataClassSchema = DataLib.StoredDataClassSchema

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

    local AsyncData = DataLib.forciblyFetchStoredPlayerData(targetId)
    if not AsyncData then return end

    -- Change the player's stored data to be unbanned.
    do
        local ModifyingData = {}

        -- Decompressing the data and modifying it.
        do
            for i: string, v: any in pairs(Compression(AsyncData.Data, "decompress") :: { [string]: any }) do
                ModifyingData[i] = Compression(v, "decompress")
            end

            ModifyingData.ModerationData.BanData = nil
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
                response = `Changed [{targetId}]'s stored data to be unbanned. Reason: "{reason}".`,
                color = "white"
            },
            
            sender
        )

        LogsHandler("Unban", sender.UserId, targetId, reason)

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