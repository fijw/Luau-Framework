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
    @usage Handles adding and removing pets from a trade.
    
    @return void
]]
local function constuctorCallback()
    TradingNamespace.packets.AddPetToTrade.listen(
        function(data: string, player: Player?)
            if not player then return end

            local TradeId = TradesMap.MappedTradingPlayers[player]
            if not TradeId then return end

            local Trade = TradesMap.ActiveTrades[TradeId]
            if not Trade then return end

            local isPlayer1 = Trade.player1 == player
            table.insert(if isPlayer1 then Trade.Player1Pets else Trade.Player2Pets, data)
        end
    )

    TradingNamespace.packets.RemovePetFromTrade.listen(
        function(data: string, player: Player?)
            if not player then return end

            local TradeId = TradesMap.MappedTradingPlayers[player]
            if not TradeId then return end

            local Trade = TradesMap.ActiveTrades[TradeId]
            if not Trade then return end

            -- Remove the pet from the trade.
            do
                local isPlayer1 = Trade.player1 == player

                local FoundPetId = table.find(if isPlayer1 then Trade.Player1Pets else Trade.Player2Pets, data)
                if not FoundPetId then return end
                
                table.remove(if isPlayer1 then Trade.Player1Pets else Trade.Player2Pets, FoundPetId)
            end
        end
    )
end

return constuctorCallback
--[[ @end_section Constructor ]]