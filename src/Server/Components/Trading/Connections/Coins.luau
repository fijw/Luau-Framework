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
        function(sender: Player, data: number)
            if not sender then return end

            local TradeId = TradesMap.MappedTradingPlayers[sender]
            if not TradeId then return end

            local Trade = TradesMap.ActiveTrades[TradeId]
            if not Trade then return end

            local isPlayer1 = Trade.player1 == sender
            if isPlayer1 then Trade.player1Coins = data else Trade.player2Coins = data end
        end
    )
end

return constuctorCallback
--[[ @end_section Constructor ]]