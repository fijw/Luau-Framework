--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Store = require(ServerScriptService.Libraries.Store)
local Reactor = require(ReplicatedStorage.Libraries.Reactor)
--[[ @end_section Imports ]]


--[[ @section Types ]]
--[[ @generic T Source type. ]]
type StateEngine<T> = Reactor.AbstractedStateEngine<T>

--[[ @generic D Data template type. ]]
type PlayerDataClass<D> = Store.PlayerDataClass<D>
--[[ @end_section Types ]]


--[[
    @usage Kick the player and clear their moderation data.

    @param player Player
    @param PlayerDataClass PlayerDataClass<any>

    @return void
]]
local function kickPlayer(player: Player, PlayerDataClass: PlayerDataClass<any>)
    local kickReason = (PlayerDataClass() :: { [string]: StateEngine<any> }).kickReason();

    PlayerDataClass().isKicked(false);
    PlayerDataClass().kickReason = nil

    player:Kick(kickReason :: string)
end


--[[
    @usage Check for moderation data or moderation data changes.

    @param player Player

    @return void
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
end


--[[ @section Constructor ]]
--[[
    @usage Initialize the service.

    @return void
]]
local function constructorCallback()
    for i: number, player: Player in ipairs(Players:GetPlayers()) do
        onPlayerAdded(player)
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
end

return constructorCallback
--[[ @end_section Constructor ]]