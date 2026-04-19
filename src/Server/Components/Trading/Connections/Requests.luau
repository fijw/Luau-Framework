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
    TradingNamespace.packets.TradeRequestAccepted.listen(
        function(data: string, player: Player?)
            if not player then return end

            local OtherPlayer = Players:GetPlayerByUserId(tonumber(data) :: number)
            if not OtherPlayer then return end

            TradingNamespace.packets.TradeRequestAccepted.send(player.DisplayName, OtherPlayer)
            TradingNamespace.packets.TradeRequestAccepted.send(OtherPlayer.DisplayName, player)

            -- Create a new trade between the two players.
            do
                local TradeId = RNG.randomString(8)

                TradesMap.ActiveTrades[TradeId]
                = {
                    player1 = player,
                    player2 = OtherPlayer,

                    Player1Pets = {},
                    Player2Pets = {},

                    player1Coins = 0,
                    player2Coins = 0,

                    player1Ready = false,
                    player2Ready = false
                }

                TradesMap.MappedTradingPlayers[player] = TradeId
                TradesMap.MappedTradingPlayers[OtherPlayer] = TradeId
            end
        end
    )

    TradingNamespace.packets.SendTradeRequest.listen(
        function(data: string, player: Player?)
            if not player then return end

            local TargetPlayer = Players:GetPlayerByUserId(tonumber(data) :: number)
            if not TargetPlayer then return end

            TradingNamespace.packets.ClientReceivedTradeRequest
            .send(
                {
                    senderIdString = `{player.UserId}`,
                    senderName = player.Name
                },
                
                TargetPlayer
            )
        end
    )
end

return constuctorCallback
--[[ @end_section Constructor ]]