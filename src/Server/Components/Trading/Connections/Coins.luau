--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local TradingGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.Trading)

local TradesMap = require(ServerScriptService.Components.Trading.TradesMap)
--[[ @end_section Imports ]]


--[[ @section Constructor ]]
--[[
    @usage Handles the setting of a player's coins in a trade.
    
    @return void
]]
local function constuctorCallback()
    TradingGroup.SetGemsInTradeOffer:onServerEvent(
        function(sender: Player, data: number): ()
            if not sender then return end

            local tradeId = TradesMap.MappedTradingPlayers[sender]
            if not tradeId then return end

            local Trade = TradesMap.ActiveTrades[tradeId]
            if not Trade then return end

            -- Update the trade offer data.
            do
                local isPlayer1 = Trade.player1 == sender
                if isPlayer1 then Trade.player1Coins = data or 0 else Trade.player2Coins = data or 0 end

                TradingGroup.SetGemsInTradeOffer:fireClient(if isPlayer1 then Trade.player2 else Trade.player1, data or 0)
            end

            TradingGroup.TradeOfferUpdated:fireClient(Trade.player1)
            TradingGroup.TradeOfferUpdated:fireClient(Trade.player2)
        end
    )
end

return constuctorCallback
--[[ @end_section Constructor ]]