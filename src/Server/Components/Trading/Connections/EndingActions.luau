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
local StackingLib = require(ServerScriptService.Libraries.DataLibs.Stackentory.Stacking)

local Data = require(ReplicatedStorage.Assets.Pets.Data)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type InventoryClass = Stackentory.InventoryClass
type PetSchema = Data.PetSchema

--[[ @generic D Data type. ]]
type StackClass<D> = StackingLib.StackClass<D>
--[[ @end_section Types ]]


--[[
    @usage Commences a trade between two players using an atomic transaction.

    @param tradeIdentifyingPlayer The player that identifies the trade to commence.

    @return void
]]
local function commenceTrade(tradeIdentifyingPlayer: Player)
    local tradeId = TradesMap.MappedTradingPlayers[tradeIdentifyingPlayer]
    if not tradeId then return end

    local Trade = TradesMap.ActiveTrades[tradeId]
    if not Trade then return end

    Registry.atomicTransaction({ Trade.player1, Trade.player2 },
        function(PlayerStates)
            local Player1State, Player2State = PlayerStates[Trade.player1], PlayerStates[Trade.player2]
            if not Player1State or not Player2State then return false end

            local Plr1Inventory, Plr2Inventory = Player1State.Inventory :: InventoryClass, Player2State.Inventory :: InventoryClass

            local Plr1Pets: { [string]: PetSchema } = {}
            local Plr2Pets: { [string]: PetSchema } = {}

            -- Check if both players have the pets and coins they are trying to trade and remove all of the pets' equipped status.
            do
                for i: number, id: string in ipairs(Trade.Player1Pets) do
                    local FoundPetStack: StackClass<PetSchema>? = Plr1Inventory:fetchStackFromItemId(id)
                    if not FoundPetStack then return false end

                    Plr1Pets[id] = FoundPetStack.StackData
                    
                    local foundIndex = table.find(FoundPetStack.StackData.Equipped or {}, id)
                    if not foundIndex then continue end

                    table.remove(FoundPetStack.StackData.Equipped or {}, foundIndex)
                end

                for i: number, id: string in ipairs(Trade.Player2Pets) do
                    local FoundPetStack = Plr2Inventory:fetchStackFromItemId(id)
                    if not FoundPetStack then return false end

                    Plr2Pets[id] = FoundPetStack.StackData

                    local foundIndex = table.find(FoundPetStack.StackData.Equipped or {}, id)
                    if not foundIndex then continue end

                    table.remove(FoundPetStack.StackData.Equipped or {}, foundIndex)
                end

                if Player1State.gems() < Trade.player1Coins then return false end
                if Player2State.gems() < Trade.player2Coins then return false end
            end

            local oldPlr1Coins = Player1State.gems()
            local oldPlr2Coins = Player2State.gems()

            -- Remove the pets and coins from both players.
            do
                for i: number, id: string in ipairs(Trade.Player1Pets) do Player1State.Inventory -= id end
                for i: number, id: string in ipairs(Trade.Player2Pets) do Player2State.Inventory -= id end

                Player1State.gems(Player1State.gems() - Trade.player1Coins)
                Player2State.gems(Player2State.gems() - Trade.player2Coins)
            end

            -- Add the pets and coins to both players.
            do
                for i: string, Pet: PetSchema in pairs(Plr2Pets) do Plr1Inventory += { itemData = Pet, itemId = i } end
                for i: string, Pet: PetSchema in pairs(Plr1Pets) do Plr2Inventory += { itemData = Pet, itemId = i } end

                Player1State.gems(Player1State.gems() + Trade.player2Coins)
                Player2State.gems(Player2State.gems() + Trade.player1Coins)
            end

            -- Verify that the pets and coins transferred correctly.
            do
                for i: number, id: string in ipairs(Trade.Player1Pets) do
                    if not (Player2State.Inventory :: InventoryClass):fetchStackFromItemId(id) then return false end
                end

                for i: number, id: string in ipairs(Trade.Player2Pets) do
                    if not (Player1State.Inventory :: InventoryClass):fetchStackFromItemId(id) then return false end
                end

                if Player1State.gems() ~= oldPlr1Coins + Trade.player2Coins - Trade.player1Coins then return false end
                if Player2State.gems() ~= oldPlr2Coins + Trade.player1Coins - Trade.player2Coins then return false end
            end

            return true
        end
    )

    TradesMap.ActiveTrades[tradeId] = nil
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

            local tradeId = TradesMap.MappedTradingPlayers[sender]
            if not tradeId then return end

            local Trade = TradesMap.ActiveTrades[tradeId]
            if not Trade then return end

            -- Send a packet to both players to close the trade UI.
            do
                local OtherPlayer = if Trade.player1 == sender then Trade.player2 else Trade.player1

                TradingGroup.CancelTrade:fireClient(OtherPlayer, sender.DisplayName)
                TradingGroup.CancelTrade:fireClient(sender, OtherPlayer.DisplayName)
            end

            TradesMap.ActiveTrades[tradeId] = nil
            TradesMap.MappedTradingPlayers[Trade.player1] = nil; TradesMap.MappedTradingPlayers[Trade.player2] = nil
        end
    )

    TradingGroup.AcceptTrade:onServerEvent(
        function(sender: Player, data: nil)
            if not sender then return end

            local tradeId = TradesMap.MappedTradingPlayers[sender]
            if not tradeId then return end

            local Trade = TradesMap.ActiveTrades[tradeId]
            if not Trade then return end

            local isPlayer1 = Trade.player1 == sender
            if isPlayer1 then Trade.player1Ready = not Trade.player1Ready else Trade.player2Ready = not Trade.player2Ready end

            TradingGroup.AcceptTrade:fireClient(if isPlayer1 then Trade.player2 else Trade.player1)

            if not Trade.player1Ready or not Trade.player2Ready then return end
            task.wait(3); if not Trade.player1Ready or not Trade.player2Ready then return end

            commenceTrade(Trade.player1)

            TradingGroup.TradeCompleted:fireClient(if isPlayer1 then Trade.player1 else Trade.player2, if isPlayer1 then Trade.player2.DisplayName else Trade.player1.DisplayName)
            TradingGroup.TradeCompleted:fireClient(if isPlayer1 then Trade.player2 else Trade.player1, if isPlayer1 then Trade.player1.DisplayName else Trade.player2.DisplayName)
        end
    )
end

return constuctorCallback
--[[ @end_section Constructor ]]