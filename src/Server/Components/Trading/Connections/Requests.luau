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
    TradingGroup.DeclineTradeRequest:onServerEvent(
        function(sender, data) TradesMap.MappedTradeRequests[sender] = nil :: any end
    )

    TradingGroup.AcceptTradeRequest:onServerEvent(
        function(sender: Player, data: nil)
            --if not sender or sender.Name == TradesMap.MappedTradeRequests[sender].Name then return end

            -- Create a new trade between the two players.
            do
                local tradeId = RNG.randomString(8)

                TradesMap.ActiveTrades[tradeId]
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

                TradesMap.MappedTradingPlayers[sender] = tradeId
                TradesMap.MappedTradingPlayers[TradesMap.MappedTradeRequests[sender]] = tradeId
            end

            TradingGroup.AcceptTradeRequest:fireClient(sender)
            TradingGroup.AcceptTradeRequest:fireClient(TradesMap.MappedTradeRequests[sender])

            TradesMap.MappedTradeRequests[sender] = nil :: any
        end
    )

    TradingGroup.SendTradeRequest:onServerEvent(
        function(sender: Player, data: number)
            if not sender then return end

            local targetPlayer = Players:GetPlayerByUserId(data)
            if not targetPlayer or TradesMap.MappedTradeRequests[targetPlayer] then return end

            TradesMap.MappedTradeRequests[targetPlayer] = sender
            TradingGroup.SendTradeRequest:fireClient(targetPlayer, sender.DisplayName)
        end
    )
end

return constuctorCallback
--[[ @end_section Constructor ]]