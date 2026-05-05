--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RebirthingGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.Rebirthing)

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
    RebirthingGroup.GetRebirthStats:onServerInvoke(
        function(sender, data)
            if not sender then return nil :: any end

            local PlrDataClass = Registry(sender)
            if not PlrDataClass then return nil :: any end

            local coinsMultiplier = 1.25 * PlrDataClass()().StatsData().rebirths
            local price = BASE_REBIRTHING_PRICE * (PlrDataClass()().StatsData().rebirths * REBIRTH_PRICE_MULTIPLIER_PER_REBIRTH)

            local ReturningStats
            = {
                coinsMultiplier = if coinsMultiplier == 0 then 1 else coinsMultiplier,
                price = if price == 0 then BASE_REBIRTHING_PRICE else price,
                neededLevels = PlrDataClass()().StatsData().levelsNeededToRebirth * NEEDED_LEVELS_MULTIPLER_PER_REBIRTH
            }

            return ReturningStats
        end
    )

    RebirthingGroup.Rebirth:onServerEvent(
        function(sender, data)
            if not sender or data ~= nil then return end

            -- Atomic transaction to update the player's rebirths.
            Registry.atomicTransaction({ sender },
                function(PlayerStates)
                    local PlayerState = PlayerStates[sender]
                    if not PlayerState then return false end

                    if PlayerState.StatsData().rebirths >= MAX_REBIRTHS then
                        RebirthingGroup.MaxRebirthsReached:fireClient(sender)
                        return false
                    end

                    local neededLevels = PlayerState.StatsData().levelsNeededToRebirth * NEEDED_LEVELS_MULTIPLER_PER_REBIRTH

                    if neededLevels > PlayerState.StatsData().level then
                        RebirthingGroup.NotEnoughLevelsToRebirth:fireClient(sender, neededLevels - PlayerState.StatsData().level)
                        return false
                    end

                    -- Update the player's coins.
                    do
                        local rebirthsPrice = BASE_REBIRTHING_PRICE * (PlayerState.StatsData().rebirths * REBIRTH_PRICE_MULTIPLIER_PER_REBIRTH)
                        if rebirthsPrice == 0 then rebirthsPrice = BASE_REBIRTHING_PRICE end

                        local oldPlrCoins = PlayerState.gems()
                        if oldPlrCoins < rebirthsPrice then RebirthingGroup.NotEnoughGemsToRebirth:fireClient(sender, (oldPlrCoins - rebirthsPrice) * -1); return false end

                        PlayerState.gems(PlayerState.gems() - rebirthsPrice)
                        if PlayerState.gems() ~= oldPlrCoins - rebirthsPrice then return false end
                    end

                    -- Update the player's rebirths.
                    do
                        local oldRebirths = PlayerState.StatsData().rebirths
                        PlayerState.StatsData(oldRebirths + 1, "rebirths")

                        if PlayerState.StatsData().rebirths ~= oldRebirths + 1 then return false end
                    end

                    -- Update the player's gameplay data.
                    do
                        local newLevelsNeededToRebirth = PlayerState.StatsData().levelsNeededToRebirth * (NEEDED_LEVELS_MULTIPLER_PER_REBIRTH * PlayerState.StatsData().rebirths);

                        (
                            PlayerState.StatsData(1, "level") :: StateEngine<StateEngine<any>>
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

                        if PlayerState.StatsData().level ~= 1
                            or PlayerState.StatsData().xp ~= 0
                            or PlayerState.StatsData().xpToNextLevel ~= 1_000
                            or PlayerState.StatsData().levelsNeededToRebirth ~= newLevelsNeededToRebirth
                        then return false end
                        
                        RebirthingGroup.SuccessfullyRebirthed:fireClient(sender, PlayerState.StatsData().rebirths)
                    end

                    return true
                end
            )
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]