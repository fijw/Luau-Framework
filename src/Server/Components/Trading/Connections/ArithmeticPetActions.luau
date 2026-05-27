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
--[[ @generic D Data type. ]]
type Stack<D> = StackingLib.StackClass<D>

type InventoryClass = Stackentory.InventoryClass
type PetSchema = Data.PetSchema
--[[ @end_section Types ]]


--[[ @section Constructor ]]
--[[
    @usage Handles adding and removing pets from a trade.
    
    @return void
]]
local function constuctorCallback()
    TradingGroup.AddPetToTradeOffer:onServerEvent(
        function(sender: Player, data: string)
            if not sender then return end

            local tradeId = TradesMap.MappedTradingPlayers[sender]
            if not tradeId then return end

            local Trade = TradesMap.ActiveTrades[tradeId]
            if not Trade then return end

            local isPlayer1 = Trade.player1 == sender
            table.insert(if isPlayer1 then Trade.Player1Pets else Trade.Player2Pets, data)

            -- Send the pet to the other player.
            do
                local PlrDataClass = Registry(sender)
                if not PlrDataClass then return end

                if PlrDataClass()().HealingData().HealingPets[data] then return end

                local Inventory = PlrDataClass()().Inventory :: InventoryClass
                if not Inventory then return end

                local FoundStack: Stack<PetSchema>? = Inventory:fetchStackFromItemId(data)
                if not FoundStack then return end

                TradingGroup.AddPetToTradeOffer:fireClient(if isPlayer1 then Trade.player2 else Trade.player1, { petId = data, PetData = FoundStack.StackData })
            end

            TradingGroup.TradeOfferUpdated:fireClient(Trade.player1)
            TradingGroup.TradeOfferUpdated:fireClient(Trade.player2)
        end
    )

    TradingGroup.RemovePetFromTradeOffer:onServerEvent(
        function(sender: Player, data: string)
            if not sender then return end

            local tradeId = TradesMap.MappedTradingPlayers[sender]
            if not tradeId then return end

            local Trade = TradesMap.ActiveTrades[tradeId]
            if not Trade then return end

            -- Remove the pet from the trade.
            do
                local isPlayer1 = Trade.player1 == sender

                local FoundPetId = table.find(if isPlayer1 then Trade.Player1Pets else Trade.Player2Pets, data)
                if not FoundPetId then return end
                
                table.remove(if isPlayer1 then Trade.Player1Pets else Trade.Player2Pets, FoundPetId)
                TradingGroup.RemovePetFromTradeOffer:fireClient(if isPlayer1 then Trade.player2 else Trade.player1, data)
            end

            TradingGroup.TradeOfferUpdated:fireClient(Trade.player1)
            TradingGroup.TradeOfferUpdated:fireClient(Trade.player2)
        end
    )
end

return constuctorCallback
--[[ @end_section Constructor ]]