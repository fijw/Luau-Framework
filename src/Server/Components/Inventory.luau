--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local InventoryGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.Inventory)

local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local Stackentory = require(ServerScriptService.Libraries.DataLibs.Stackentory)
local StackingLib = require(ServerScriptService.Libraries.DataLibs.Stackentory.Stacking)

local Data = require(ReplicatedStorage.Assets.Pets.Data)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type InventoryClass = Stackentory.InventoryClass
type SavingInventoryClassSchema = Stackentory.SavingInventoryClassSchema
type PetSchema = Data.PetSchema

--[[ @generic D Data type. ]]
type SavingStackSchema<D> = StackingLib.SavingStackSchema<D>
--[[ @end_section Types ]]


--[[
    @usage Subscribe to the player's inventory.

    @param player Player
    @param Inventory InventoryClass

    @return void
]]
local function subscribeToInventory(player: Player, Inventory: InventoryClass)
    Inventory:subscribeToItemsAdded(
        function(ItemData: PetSchema, itemId: string)
            InventoryGroup.AddPetsToInventory:fireClient(player, { [itemId] = ItemData })
        end
    )

    Inventory:subscribeToItemsRemoved(
        function(itemId: string)
            InventoryGroup.RemovePetsFromInventory:fireClient(player, { itemId })
        end
    )
end


--[[ @section Constructor ]]
--[[
    @usage Initialize the service.

    @return void
]]
local function constuctorCallback()
    InventoryGroup.RequestInventorySlots:onServerInvoke(
        function(sender, data)
            if not sender then return nil :: any end
            
            local PlrDataClass = Registry(sender)
            if not PlrDataClass then return nil :: any end

            return (PlrDataClass()().Inventory :: InventoryClass).maxStacks
        end
    )

    local function onPlayerAdded(player: Player)
        local PlrDataClass = Registry(player)
        if not PlrDataClass then return end

        -- Initialize the player's inventory.
        local oldInventoryState = if PlrDataClass()().Inventory then PlrDataClass()().Inventory() :: SavingInventoryClassSchema else nil
        PlrDataClass()(Stackentory(oldInventoryState), "Inventory")

        local Inventory = PlrDataClass()().Inventory :: InventoryClass

        -- Add existing pets to the player's client inventory.
        do
            local PetsAddingToInventory = {}
            
            for stackIndex: string, SavingStackSchema: SavingStackSchema<PetSchema> in pairs(Inventory().StacksArray) do
                for idIndex: number, id: string in ipairs(SavingStackSchema.StackArray) do
                    PetsAddingToInventory[id] = SavingStackSchema.StackData
                end
            end
            
            InventoryGroup.AddPetsToInventory:fireClient(player, PetsAddingToInventory)
        end

        subscribeToInventory(player, Inventory)
    end

    for i: number, player: Player in ipairs(Players:GetPlayers()) do onPlayerAdded(player) end
    Players.PlayerAdded:Connect(onPlayerAdded)
end

return constuctorCallback
--[[ @end_section Constructor ]]