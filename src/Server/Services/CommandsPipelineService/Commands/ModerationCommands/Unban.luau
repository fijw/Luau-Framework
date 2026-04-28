--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreService = game:GetService("DataStoreService")

local CommandsNamespace = require(ReplicatedStorage.Networking.Namespaces.Services.Commands)

local Chronovisor = require(ReplicatedStorage.Libraries.Chronovisor)
local RNG = require(ReplicatedStorage.Libraries.RNG)
local Compression = require(ServerScriptService.Libraries.DataLibs.Compression)
local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)

local Settings = require(ReplicatedStorage.Settings)
--[[ @end_section Imports ]]


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
    if #reason < 1 then reason = "No reason provided" end

    local AsyncData = Registry.forciblyFetchStoredPlayerData(targetId)

    if not AsyncData then
        CommandsNamespace.packets.ClientDisplayConsoleResponse
        .sendTo(
            {
                response = `Failed to unban [{targetId}]. Could not fetch stored player data.`,
                color = "red"
            },
            
            sender
        )
        
        return
    end

    if AsyncData.inUse == true then
        CommandsNamespace.packets.ClientDisplayConsoleResponse
        .sendTo(
            {
                response = `Failed to unban [{targetId}]. The player is currently in a server.`,
                color = "red"
            },
            
            sender
        )
        
        return
    end

    -- Change the player's stored data to be unbanned.
    do
        local ModifyingData = {}

        -- Decompressing the data and modifying it.
        do
            for i: string, v: any in pairs(Compression(AsyncData.Data, "decompress") :: { [string]: any }) do
                ModifyingData[i] = Compression(v, "decompress")
            end

            ModifyingData.ModerationData.BanData = nil

            if not ModifyingData.ModerationData.ModerationHistory then ModifyingData.ModerationData.ModerationHistory = {} end
            if not ModifyingData.ModerationData.ModerationHistory.Unbans then ModifyingData.ModerationData.ModerationHistory.Unbans = {} end

            ModifyingData.ModerationData.ModerationHistory.Unbans[RNG.randomString(8)]
            = {
                unbanningUserId = sender.UserId,
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
                response = `Set [{targetId}] as unbanned. Reason: "{reason}".`,
                color = "white"
            },
            
            sender
        )
    end
end

return constructorCallback
--[[ @end_section Constructor ]]