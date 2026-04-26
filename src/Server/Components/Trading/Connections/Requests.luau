--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RNG = require(ReplicatedStorage.Libraries.RNG)

local TradesMap = require(ServerScriptService.Components.Trading.TradesMap)

local TradingNamespace = require(ReplicatedStorage.Networking.Namespaces.Components.Trading)
--[[ @end_section Imports ]]


--[[ @section Constructor ]]
--[[
    @usage Handles the trade request packets.

    @return void
]]
local function constuctorCallback()
    TradingNamespace.packets.ServerTradeRequestAccepted.listen(
        function(data: string, player: Player?)
            if not player then return end

            local RequestingPlayer = Players:GetPlayerByUserId(tonumber(data) :: number)
            if not RequestingPlayer then return end

            -- Create a new trade between the two players.
            do
                local TradeId = RNG.randomString(8)

                TradesMap.ActiveTrades[TradeId]
                = {
                    player1 = player,
                    player2 = RequestingPlayer,

                    Player1Pets = {},
                    Player2Pets = {},

                    player1Coins = 0,
                    player2Coins = 0,

                    player1Ready = false,
                    player2Ready = false
                }

                TradesMap.MappedTradingPlayers[player] = TradeId
                TradesMap.MappedTradingPlayers[RequestingPlayer] = TradeId
            end
        end
    )

    TradingNamespace.packets.ServerSendTradeRequest.listen(
        function(data: string, player: Player?)
            if not player then return end

            local TargetPlayer = Players:GetPlayerByUserId(tonumber(data) :: number)
            if not TargetPlayer then return end
            
            TradesMap.MappedTradeRequests[TargetPlayer] = player
        end
    )
end

return constuctorCallback
--[[ @end_section Constructor ]]