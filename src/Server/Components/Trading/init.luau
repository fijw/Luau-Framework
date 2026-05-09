--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local Stackentory = require(ServerScriptService.Libraries.DataLibs.Stackentory)
local StackingLib = require(ServerScriptService.Libraries.DataLibs.Stackentory.Stacking)

local ArithmeticPetActions = require(script.Connections.ArithmeticPetActions)
local Coins = require(script.Connections.Coins)
local Requests = require(script.Connections.Requests)
local EndingActions = require(script.Connections.EndingActions)

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
    TradingGroup.RequestOwnedPetsForTrade:onServerInvoke(
        function(sender, data)
            if not sender then return nil :: any end

            local PlrDataClass = Registry(sender)
            if not PlrDataClass then return nil :: any end

            local Inventory = PlrDataClass()().Inventory :: InventoryClass
            if not Inventory then return nil :: any end

            local ReturningPets: { [string]: PetSchema } = {}

            for i: string, Stack: SavingStackSchema<PetSchema> in pairs(Inventory().StacksArray) do
                for i: number, id: string in ipairs(Stack.StackArray) do ReturningPets[id] = Stack.StackData end
            end

            return ReturningPets
        end
    )

    local ConstructorArray = { ArithmeticPetActions, Coins, Requests, EndingActions }

    for i: number, constructorCallback: () -> () in ipairs(ConstructorArray) do
        constructorCallback()
    end
end

return constuctorCallback
--[[ @end_section Constructor ]]