--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Chronovisor = require(ReplicatedStorage.Libraries.Chronovisor)
local Compression = require(ServerScriptService.Libraries.Compression)
local Store = require(ServerScriptService.Libraries.Store)
local Reactor = require(ReplicatedStorage.Libraries.Reactor)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type StoredPlayerDataClass = Store.StoredPlayerDataClass

--[[ @generic T Source type. ]]
type StateEngine<T> = Reactor.AbstractedStateEngine<T>

--[[ @generic D Data template type. ]]
type PlayerDataClass<D> = Store.PlayerDataClass<D>
--[[ @end_section Types ]]


local ModerationDataKeys = { "banReason", "kickReason", "isBanned", "isKicked" }


--[[ @section Utility Functions ]]
--[[
    @usage Compare the player's moderation data to the stored data.

    @param PlayerDataClass PlayerDataClass<any>

    @return
]]
local function moderationDataCheck(PlayerDataClass: PlayerDataClass<any>)
    Chronovisor(
        function()
            local FetchedPlayerDataClass: StoredPlayerDataClass?

            FetchedPlayerDataClass = PlayerDataClass.classDataStore:GetAsync(`{PlayerDataClass.classIdentifier}`)
            if not FetchedPlayerDataClass then return end

            -- Decompress the data and compare it.
            do
                local DecompressedData = {} :: { [string]: any }

                for i: string, v: buffer in pairs(Compression(FetchedPlayerDataClass.Data, "decompress") :: { [string]: buffer }) do
                    DecompressedData[i] = Compression(v, "decompress")
                end

                for i: number, key: string in ipairs(ModerationDataKeys) do
                    if DecompressedData[key] == nil then continue end

                    if not PlayerDataClass()[key] then
                        PlayerDataClass()[key] = Reactor(DecompressedData[key])

                        continue
                    end

                    if DecompressedData[key] ~= PlayerDataClass()[key]() then
                        PlayerDataClass()[key](DecompressedData[key])
                    end
                end
            end
        end
    )
    :onError(function(err: string?) print(`Error checking player data class moderation data. Error: {err}`) end)
end

--[[
    @usage Kick the player and clear their moderation data.

    @param player Player
    @param PlayerDataClass PlayerDataClass<any>

    @return
]]
local function kickPlayer(player: Player, PlayerDataClass: PlayerDataClass<any>)
    local kickReason = (PlayerDataClass() :: { [string]: StateEngine<any> }).kickReason();

    (PlayerDataClass() :: { [string]: StateEngine<any> }).isKicked(false);
    (PlayerDataClass() :: { [string]: StateEngine<any> }).kickReason = nil

    player:Kick(kickReason :: string)
end
--[[ @end_section Utility Functions ]]


--[[
    @usage Check for moderation data or moderation data changes.

    @param player Player

    @return
]]
local function onPlayerAdded(player: Player)
    repeat task.wait() until Store(player.UserId)

    local PlayerDataClass = Store(player.UserId)
    if not PlayerDataClass then return end

    -- Check for existing moderation data.
    do
        if (PlayerDataClass() :: { [string]: StateEngine<any> }).isBanned() then
            player:Kick((PlayerDataClass() :: { [string]: any }).banReason())
        end

        if (PlayerDataClass() :: { [string]: StateEngine<any> }).isKicked() then
            kickPlayer(player, PlayerDataClass)
        end
    end

    -- Subscribe to moderation data changes.
    do
        (PlayerDataClass() :: { [string]: StateEngine<any> }).isBanned
        :subscribe(
            function(self, data, key, ...)
                if data ~= true then return end

                player:Kick((PlayerDataClass() :: { [string]: any }).banReason())
            end
        );

        (PlayerDataClass() :: { [string]: StateEngine<any> }).isKicked
        :subscribe(
            function(self, data, key, ...)
                if data ~= true then return end

                kickPlayer(player, PlayerDataClass)
            end
        )
    end

    task.spawn(
        function()
            while true do
                task.wait(10)

                if (Store(player.UserId) :: any) == nil then break end

                moderationDataCheck(PlayerDataClass)
            end
        end
    )
end


--[[ @section Constructor ]]
--[[
    @usage Initialize the service.

    @return
]]
local function constructorCallback()
    for i: number, player: Player in ipairs(Players:GetPlayers()) do
        onPlayerAdded(player)
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
end

return constructorCallback
--[[ @end_section Constructor ]]