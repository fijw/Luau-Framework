--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local TradingNamespace = require(ReplicatedStorage.Networking.Namespaces.Components.Trading)

local TradesMap = require(ServerScriptService.Components.Trading.TradesMap)
--[[ @end_section Imports ]]


--[[ @section Constructor ]]
--[[
    @usage Handles the setting of a player's coins in a trade.
    
    @return void
]]
local function constuctorCallback()
    TradingNamespace.packets.SetCoinsInTrade.listen(
        function(data: string, player: Player?)
            if not player then return end

            local TradeId = TradesMap.MappedTradingPlayers[player]
            if not TradeId then return end

            local Trade = TradesMap.ActiveTrades[TradeId]
            if not Trade then return end

            local isPlayer1 = Trade.player1 == player
            if isPlayer1 then Trade.player1Coins = tonumber(data) :: number else Trade.player2Coins = tonumber(data) :: number end
        end
    )
end

return constuctorCallback
--[[ @end_section Constructor ]]