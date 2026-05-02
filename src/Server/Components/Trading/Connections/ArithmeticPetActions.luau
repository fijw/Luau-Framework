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
    @usage Handles adding and removing pets from a trade.
    
    @return void
]]
local function constuctorCallback()
    TradingGroup.AddPetToTradeOffer:onServerEvent(
        function(sender: Player, data: string)
            if not sender then return end

            local TradeId = TradesMap.MappedTradingPlayers[sender]
            if not TradeId then return end

            local Trade = TradesMap.ActiveTrades[TradeId]
            if not Trade then return end

            local isPlayer1 = Trade.player1 == sender
            table.insert(if isPlayer1 then Trade.Player1Pets else Trade.Player2Pets, data)
        end
    )

    TradingGroup.RemovePetFromTradeOffer:onServerEvent(
        function(sender: Player, data: string)
            if not sender then return end

            local TradeId = TradesMap.MappedTradingPlayers[sender]
            if not TradeId then return end

            local Trade = TradesMap.ActiveTrades[TradeId]
            if not Trade then return end

            -- Remove the pet from the trade.
            do
                local isPlayer1 = Trade.player1 == sender

                local FoundPetId = table.find(if isPlayer1 then Trade.Player1Pets else Trade.Player2Pets, data)
                if not FoundPetId then return end
                
                table.remove(if isPlayer1 then Trade.Player1Pets else Trade.Player2Pets, FoundPetId)
            end
        end
    )
end

return constuctorCallback
--[[ @end_section Constructor ]]