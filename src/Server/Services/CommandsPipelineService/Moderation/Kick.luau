--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local DataStoreService = game:GetService("DataStoreService")

local Chronovisor = require(ReplicatedStorage.Libraries.Chronovisor)
local Compression = require(ServerScriptService.Libraries.Compression)
local Store = require(ServerScriptService.Libraries.Store)

local Settings = require(ReplicatedStorage.Settings)
--[[ @end_section Imports ]]


type StoredPlayerDataClass = Store.StoredPlayerDataClass


local DataStore = DataStoreService:GetDataStore(Settings.PLAYER_DATA_STORAGE_KEY)


--[[ @section Constructor ]]
--[[
    @usage Initialize the command.

    @param sender Player
    @param args { string }

    @return
]]
local function constructorCallback(sender: Player, args: { string })
    local targetId = args[1]
    if not targetId then return end

    table.remove(args, 1)

    local reason = table.concat(args, " ")

    Chronovisor(
        function()
            local FetchedPlayerDataClass: StoredPlayerDataClass?

            FetchedPlayerDataClass = DataStore:GetAsync(targetId)
            if not FetchedPlayerDataClass then return end

            local DecompressedData = {}

            -- Decompressing the data and modifying it.
            do
                for i: string, v: buffer in pairs(Compression(FetchedPlayerDataClass.Data, "decompress") :: { [string]: buffer }) do
                    DecompressedData[i] = Compression(v, "decompress")
                end

                DecompressedData.isKicked = true
                DecompressedData.kickReason = reason
            end

            -- Compressing the decompressed data and saving it.
            do
                local RecompressedData = DecompressedData

                for i: string, v: any in pairs(RecompressedData :: { [string]: any }) do
                    RecompressedData[i] = Compression(v)
                end

                DataStore:SetAsync(targetId,
                    {
                        Data = Compression(RecompressedData),
                        currentSessionId = FetchedPlayerDataClass.currentSessionId
                    }
                )
            end
        end
    )
    :onError(function(err: string?) print(`Error updating player data class moderation data. Error: {err}`) end)
end

return constructorCallback
--[[ @end_section Constructor ]]