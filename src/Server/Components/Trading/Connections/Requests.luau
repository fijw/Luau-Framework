--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local RNG = require(ReplicatedStorage.Libraries.RNG)

local TradesMap = require(ServerScriptService.Components.Trading.TradesMap)

local TradingGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.Trading)
--[[ @end_section Imports ]]


--[[ @section Constructor ]]
--[[
    @usage Handles the trade request packets.

    @return void
]]
local function constuctorCallback()
    TradingGroup.AcceptTradeRequest:onServerEvent(
        function(sender: Player, data: nil)
            --if not sender or sender.Name == TradesMap.MappedTradeRequests[sender].Name then return end

            -- Create a new trade between the two players.
            do
                local TradeId = RNG.randomString(8)

                TradesMap.ActiveTrades[TradeId]
                = {
                    player1 = sender,
                    player2 = TradesMap.MappedTradeRequests[sender],

                    Player1Pets = {},
                    Player2Pets = {},

                    player1Coins = 0,
                    player2Coins = 0,

                    player1Ready = false,
                    player2Ready = false
                }

                TradesMap.MappedTradingPlayers[sender] = TradeId
                TradesMap.MappedTradingPlayers[TradesMap.MappedTradeRequests[sender]] = TradeId
            end

            TradingGroup.AcceptTradeRequest:fireClient(sender)
            TradingGroup.AcceptTradeRequest:fireClient(TradesMap.MappedTradeRequests[sender])

            TradesMap.MappedTradeRequests[sender] = nil :: any
        end
    )

    TradingGroup.SendTradeRequest:onServerEvent(
        function(sender: Player, data: number)
            if not sender then return end

            local TargetPlayer = Players:GetPlayerByUserId(data)
            if not TargetPlayer then return end

            TradingGroup.SendTradeRequest:fireClient(TargetPlayer, sender.DisplayName)
            TradesMap.MappedTradeRequests[TargetPlayer] = sender
        end
    )
end

return constuctorCallback
--[[ @end_section Constructor ]]