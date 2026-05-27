--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local Stackentory = require(ServerScriptService.Libraries.DataLibs.Stackentory)
local StackingLib = require(ServerScriptService.Libraries.DataLibs.Stackentory.Stacking)

local ArithmeticPetActions = require(script.Connections.ArithmeticPetActions)
local Coins = require(script.Connections.Coins)
local Requests = require(script.Connections.Requests)
local EndingActions = require(script.Connections.EndingActions)

local TradesMap = require(script.TradesMap)

local Data = require(ReplicatedStorage.Assets.Pets.Data)

local TradingGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.Trading)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type PetSchema = Data.PetSchema
type InventoryClass = Stackentory.InventoryClass

--[[ @generic D Data type. ]]
type SavingStackSchema<D> = StackingLib.SavingStackSchema<D>
--[[ @end_section Types ]]


--[[ @section Constructor ]]
--[[
    @usage Initialize the component.

    @return void
]]
local function constuctorCallback()
    Players.PlayerRemoving:Connect(
        function(player: Player)
            local tradeId = TradesMap.MappedTradingPlayers[player]
            if not tradeId then return end

            local Trade = TradesMap.ActiveTrades[tradeId]
            if not Trade then return end

            TradesMap.ActiveTrades[tradeId] = nil
            TradesMap.MappedTradingPlayers[Trade.player1] = nil; TradesMap.MappedTradingPlayers[Trade.player2] = nil

            TradingGroup.CancelTrade:fireClient(Trade.player1, Trade.player2.DisplayName)
            TradingGroup.CancelTrade:fireClient(Trade.player2, Trade.player1.DisplayName)

            TradingGroup.HideCountdown:fireClient(Trade.player1); TradingGroup.HideCountdown:fireClient(Trade.player2)
        end
    )

    TradingGroup.SearchForTradingPets:onServerInvoke(
        function(sender, data)
            if not sender then return nil :: any end

            local tradeId = TradesMap.MappedTradingPlayers[sender]
            if not tradeId then return nil :: any end

            local Trade = TradesMap.ActiveTrades[tradeId]
            if not Trade then return nil :: any end

            if data.side == "yours" then
                local PlrDataClass = Registry(sender)
                if not PlrDataClass then return nil :: any end

                local Inventory = PlrDataClass()().Inventory :: InventoryClass

                -- Send valid search results to the player.
                do
                    local PetsAddingToTrade: { [string]: PetSchema } = {}
                    
                    for i: string, Stack: SavingStackSchema<PetSchema> in pairs(Inventory().StacksDictionary) do
                        if not string.find(Stack.StackData.petName:lower(), data.text:lower()) then continue end

                        for i: number, id: string in ipairs(Stack.StackArray) do
                            if PlrDataClass()().HealingData().HealingPets[id] then continue end
                            PetsAddingToTrade[id] = Stack.StackData
                        end
                    end

                    return PetsAddingToTrade
                end
            else
                local isPlr1 = if Trade.player1 == sender then true else false

                local otherPlrDataClass = Registry(if isPlr1 then Trade.player2 else Trade.player1)
                if not otherPlrDataClass then return nil :: any end

                local otherPlrInventory = otherPlrDataClass()().Inventory :: InventoryClass

                -- Send valid search results to the player.
                do
                    local PetsAddingToTrade: { [string]: PetSchema } = {}

                    for i: string, Stack: SavingStackSchema<PetSchema> in pairs(otherPlrInventory().StacksDictionary) do
                        if not string.find(Stack.StackData.petName:lower(), data.text:lower()) then continue end

                        for i: number, id: string in ipairs(Stack.StackArray) do
                            if otherPlrDataClass()().HealingData().HealingPets[id] then continue end
                            PetsAddingToTrade[id] = Stack.StackData
                        end
                    end

                    return PetsAddingToTrade
                end
            end
        end
    )

    local ConstructorArray = { ArithmeticPetActions, Coins, Requests, EndingActions }

    for i: number, constructorCallback: () -> () in ipairs(ConstructorArray) do
        constructorCallback()
    end
end

return constuctorCallback
--[[ @end_section Constructor ]]