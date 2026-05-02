--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local TradingGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.Trading)

local TradesMap = require(ServerScriptService.Components.Trading.TradesMap)

local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local Stackentory = require(ServerScriptService.Libraries.DataLibs.Stackentory)
--[[ @end_section Imports ]]


type InventoryClass = Stackentory.InventoryClass


--[[
    @usage Commences a trade between two players using an atomic transaction.

    @param tradeIdentifyingPlayer The player that identifies the trade to commence.

    @return void
]]
local function commenceTrade(tradeIdentifyingPlayer: Player)
    local TradeId = TradesMap.MappedTradingPlayers[tradeIdentifyingPlayer]
    if not TradeId then return end

    local Trade = TradesMap.ActiveTrades[TradeId]
    if not Trade then return end

    Registry.atomicTransaction({ Trade.player1, Trade.player2 },
        function(PlayerStates)
            local Player1State, Player2State = PlayerStates[Trade.player1], PlayerStates[Trade.player2]
            if not Player1State or not Player2State then return false end

            -- Check if both players have the pets and coins they are trying to trade.
            do
                for i: number, id: string in ipairs(Trade.Player1Pets) do
                    if not (Player1State.Inventory :: InventoryClass):fetchStackFromItemId(id) then return false end
                end

                for i: number, id: string in ipairs(Trade.Player2Pets) do
                    if not (Player2State.Inventory :: InventoryClass):fetchStackFromItemId(id) then return false end
                end

                if Player1State.coins() < Trade.player1Coins then return false end
                if Player2State.coins() < Trade.player2Coins then return false end
            end

            local oldPlr1Coins = Player1State.coins()
            local oldPlr2Coins = Player2State.coins()

            -- Remove the pets and coins from both players.
            do
                for i: number, id: string in ipairs(Trade.Player1Pets) do Player1State.Inventory -= id end
                for i: number, id: string in ipairs(Trade.Player2Pets) do Player2State.Inventory -= id end

                Player1State.coins(Player1State.coins() - Trade.player1Coins)
                Player2State.coins(Player2State.coins() - Trade.player2Coins)
            end

            -- Add the pets and coins to both players.
            do
                for i: number, id: string in ipairs(Trade.Player2Pets) do Player1State.Inventory += id end
                for i: number, id: string in ipairs(Trade.Player1Pets) do Player2State.Inventory += id end

                Player1State.coins(Player1State.coins() + Trade.player2Coins)
                Player2State.coins(Player2State.coins() + Trade.player1Coins)
            end

            -- Verify that the pets and coins transferred correctly.
            do
                for i: number, id: string in ipairs(Trade.Player1Pets) do
                    if not (Player2State.Inventory :: InventoryClass):fetchStackFromItemId(id) then return false end
                end

                for i: number, id: string in ipairs(Trade.Player2Pets) do
                    if not (Player1State.Inventory :: InventoryClass):fetchStackFromItemId(id) then return false end
                end

                if Player1State.coins() ~= oldPlr1Coins + Trade.player2Coins - Trade.player1Coins then return false end
                if Player2State.coins() ~= oldPlr2Coins + Trade.player1Coins - Trade.player2Coins then return false end
            end

            return true
        end
    )

    TradesMap.ActiveTrades[TradeId] = nil
    TradesMap.MappedTradingPlayers[Trade.player1] = nil; TradesMap.MappedTradingPlayers[Trade.player2] = nil
end


--[[ @section Constructor ]]
--[[
    @usage Handles adding and removing pets from a trade.
    
    @return void
]]
local function constuctorCallback()
    TradingGroup.CancelTrade:onServerEvent(
        function(sender: Player, data: nil)
            if not sender then return end

            local TradeId = TradesMap.MappedTradingPlayers[sender]
            if not TradeId then return end

            local Trade = TradesMap.ActiveTrades[TradeId]
            if not Trade then return end

            -- Send a packet to both players to close the trade UI.
            do
                local OtherPlayer = if Trade.player1 == sender then Trade.player2 else Trade.player1

                TradingGroup.CancelTrade:fireClient(OtherPlayer, "they_cancelled")
                TradingGroup.CancelTrade:fireClient(sender, "you_cancelled")
            end

            TradesMap.ActiveTrades[TradeId] = nil
            TradesMap.MappedTradingPlayers[Trade.player1] = nil; TradesMap.MappedTradingPlayers[Trade.player2] = nil
        end
    )

    TradingGroup.AcceptTrade:onServerEvent(
        function(sender: Player, data: nil)
            if not sender then return end

            local TradeId = TradesMap.MappedTradingPlayers[sender]
            if not TradeId then return end

            local Trade = TradesMap.ActiveTrades[TradeId]
            if not Trade then return end

            local isPlayer1 = Trade.player1 == sender
            if isPlayer1 then Trade.player1Ready = not Trade.player1Ready else Trade.player2Ready = not Trade.player2Ready end

            TradingGroup.AcceptTrade:fireClient(if isPlayer1 then Trade.player2 else Trade.player1)

            if not Trade.player1Ready and Trade.player2Ready then return end
            commenceTrade(Trade.player1)
        end
    )
end

return constuctorCallback
--[[ @end_section Constructor ]]