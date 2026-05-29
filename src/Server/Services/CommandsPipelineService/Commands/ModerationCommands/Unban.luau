--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreService = game:GetService("DataStoreService")

local CommandsGroup = require(ReplicatedStorage.Networking.PacketGroups.Services.Commands)

local Chronovisor = require(ReplicatedStorage.Libraries.Chronovisor)
local RNG = require(ReplicatedStorage.Libraries.NumberLibs.RNG)
local Compression = require(ReplicatedStorage.Libraries.DataLibs.Compression)
local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)

local DataSettings = require(ReplicatedStorage.FrameworkSettings.DataSettings)
--[[ @end_section Imports ]]


local DataStore = DataStoreService:GetDataStore(DataSettings.PLAYER_DATA_STORAGE_KEY)


--[[ @section Constructor ]]
--[[
    @usage Initialize the command.

    @param sender Player
    @param args { string }

    @return void
]]
local function constructorCallback(sender: Player, args: { string }): ()
    local targetId = tonumber(args[1]) :: number
    if not targetId then return end

    table.remove(args, 1)

    local reason = table.concat(args, " ")
    if #reason < 1 then reason = "No reason provided" end

    local AsyncData = Registry.forciblyFetchStoredPlayerData(targetId)

    if not AsyncData then
        CommandsGroup.DisplayConsoleMessage:fireClient(sender,
            {
                message = `Failed to unban [{targetId}]. Could not fetch stored player data.`,
                color = "red"
            }
        )
        
        return
    end

    if AsyncData.inUse == true then
        CommandsGroup.DisplayConsoleMessage:fireClient(sender,
            {
                message = `Failed to unban [{targetId}]. The player is currently in a server.`,
                color = "red"
            }
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

            if not ModifyingData.ModerationData.ModerationHistory.numOfUnbans then ModifyingData.ModerationData.ModerationHistory.numOfUnbans = 0 end
            ModifyingData.ModerationData.ModerationHistory.numOfUnbans += 1

            ModifyingData.ModerationData.ModerationHistory.Unbans[RNG.randomString(8)]
            = {
                unbanningUserId = sender.UserId,
                unbanReason = reason,
                index = ModifyingData.ModerationData.ModerationHistory.numOfUnbans
            }
        end

        local SavingData = {}

        for i: string, v: any in pairs(ModifyingData :: { [string]: any }) do
            SavingData[i] = Compression(v)
        end

        Chronovisor(
            function(): ()
                DataStore:SetAsync(`{targetId}`,
                    {
                        Data = Compression(SavingData),
                        inUse = AsyncData.inUse
                    }
                )
            end
        )
        :onError(function(err: string?): () print(`Failed to save moderation data changes. Error: {err}`) end)

        CommandsGroup.DisplayConsoleMessage:fireClient(sender,
            {
                message = `Set [{targetId}] as unbanned. Reason: "{reason}".`,
                color = "white"
            }
        )
    end
end

return constructorCallback
--[[ @end_section Constructor ]]