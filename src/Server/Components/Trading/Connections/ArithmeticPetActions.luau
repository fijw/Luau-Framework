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
    TradingNamespace.packets.ServerAddPetToTrade.listen(
        function(data: string, player: Player?)
            if not player then return end

            local TradeId = TradesMap.MappedTradingPlayers[player]
            if not TradeId then return end

            local Trade = TradesMap.ActiveTrades[TradeId]
            if not Trade then return end

            local isPlayer1 = Trade.player1 == player
            table.insert(if isPlayer1 then Trade.Player1Pets else Trade.Player2Pets, data)

            -- Send the added pet to the other player in the trade.
            TradingNamespace.packets.ClientAddPetToTrade.send(
                {
                    side = "other",
                    petId = data
                },

                if isPlayer1 then Trade.player2 else Trade.player1
            )
        end
    )

    TradingNamespace.packets.ServerRemovePetFromTrade.listen(
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

            -- Send the removed pet to the other player in the trade.
            TradingNamespace.packets.ClientRemovePetFromTrade.send(
                {
                    side = "other",
                    petId = data
                },

                if Trade.player1 == player then Trade.player2 else Trade.player1
            )
        end
    )
end

return constuctorCallback
--[[ @end_section Constructor ]]