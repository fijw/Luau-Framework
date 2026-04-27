--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RebirthingNamespace = require(ReplicatedStorage.Networking.Namespaces.Components.Rebirthing)

local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local Reactor = require(ReplicatedStorage.Libraries.Reactor)
--[[ @end_section Imports ]]


--[[ @generic T State type. ]]
type StateEngine<T> = Reactor.StateEngine<T>


local BASE_REBIRTHING_PRICE = 50_000
local REBIRTH_PRICE_MULTIPLIER_PER_REBIRTH = 1.25
local MAX_REBIRTHS = 50
local NEEDED_LEVELS_MULTIPLER_PER_REBIRTH = 2


--[[ @section Constructor ]]
--[[
    @usage Handles the rebirthing packet.

    @return void
]]
local function constructorCallback()
    RebirthingNamespace.packets.ServerRebirthPlayer.listen(
        function(data: unknown, player: Player?)
            if not player or data ~= nil then return end

            -- Atomic transaction to update the player's rebirths.
            Registry.atomicTransaction({ player },
                function(PlayerStates)
                    local PlayerState = PlayerStates[player]
                    if not PlayerState then return false end

                    if PlayerState.GameplayData().rebirths >= MAX_REBIRTHS then return false end

                    -- Update the player's coins.
                    do
                        local rebirthsPrice = BASE_REBIRTHING_PRICE * (PlayerState.GameplayData().rebirths * REBIRTH_PRICE_MULTIPLIER_PER_REBIRTH)

                        local oldPlrCoins = PlayerState.coins()
                        if oldPlrCoins < rebirthsPrice then return false end

                        PlayerState.coins(PlayerState.coins() - rebirthsPrice)
                        if PlayerState.coins() ~= oldPlrCoins - rebirthsPrice then return false end
                    end

                    -- Update the player's rebirths.
                    do
                        local oldRebirths = PlayerState.GameplayData().rebirths
                        PlayerState.GameplayData(oldRebirths + 1, "rebirths")

                        if PlayerState.GameplayData().rebirths ~= oldRebirths + 1 then return false end
                    end

                    -- Update the player's gameplay data.
                    do
                        local newLevelsNeededToRebirth = PlayerState.GameplayData().levelsNeededToRebirth * NEEDED_LEVELS_MULTIPLER_PER_REBIRTH;

                        (
                            PlayerState.GameplayData() :: StateEngine<StateEngine<any>>
                        )(
                            1,
                            "level"
                        )(
                            0,
                            "xp"
                        )(
                            1_000,
                            "xpToNextLevel"
                        )(
                            newLevelsNeededToRebirth,
                            "levelsNeededToRebirth"
                        )

                        PlayerState.DungeonsData(1, "currentMaxDungeonLevelReached")
                        if PlayerState.DungeonsData().currentMaxDungeonLevelReached ~= 1 then return false end

                        if PlayerState.GameplayData().level ~= 1
                            or PlayerState.GameplayData().xp ~= 0
                            or PlayerState.GameplayData().xpToNextLevel ~= 1_000
                            or PlayerState.GameplayData().levelsNeededToRebirth ~= newLevelsNeededToRebirth
                        then return false end
                    end

                    return true
                end
            )
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]