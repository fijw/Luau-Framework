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
type Stack<D> = StackingLib.StackClass<D>

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
    @usage Initialize the component.

    @return void
]]
local function constuctorCallback()
    InventoryGroup.DeletePets:onServerEvent(
        function(sender, data)
            if not sender then return end

            local PlrDataClass = Registry(sender)
            if not PlrDataClass then return end

            local Inventory = PlrDataClass()().Inventory :: InventoryClass
            if not Inventory then return end

            for i: number, petId: string in ipairs(data) do Inventory -= petId end
            InventoryGroup.RemovePetsFromInventory:fireClient(sender, data)
        end
    )

    InventoryGroup.LockPet:onServerEvent(
        function(sender, data)
            if not sender then return end

            local PlrDataClass = Registry(sender)
            if not PlrDataClass then return end

            local Inventory = PlrDataClass()().Inventory :: InventoryClass
            if not Inventory then return end

            local FoundStack: Stack<PetSchema>? = Inventory:fetchStackFromItemId(data)
            if not FoundStack then return end

            local foundIdIndex = if FoundStack.StackData.locked then table.find(FoundStack.StackData.locked, data) else nil

            if foundIdIndex then
                if FoundStack.StackData.locked then table.remove(FoundStack.StackData.locked, foundIdIndex) end
            else
                if FoundStack.StackData.locked then table.insert(FoundStack.StackData.locked, data) end
            end
        end
    )

    InventoryGroup.RequestInventorySlots:onServerInvoke(
        function(sender, data)
            if not sender then return nil :: any end
            
            local PlrDataClass = Registry(sender)
            if not PlrDataClass then return nil :: any end

            local Inventory = PlrDataClass()().Inventory :: InventoryClass
            return `{Inventory.usedItemSlots}/{Inventory.maxItems}`
        end
    )

    InventoryGroup.SearchForPets:onServerEvent(
        function(sender, data)
            if not sender then return end
            
            local PlrDataClass = Registry(sender)
            if not PlrDataClass then return end

            InventoryGroup.RemoveAllPetsFromInventory:fireClient(sender)

            local Inventory = PlrDataClass()().Inventory :: InventoryClass

            -- Send valid search results to the player.
            do
                local PetsAddingToInventory: { [string]: PetSchema } = {}
                
                for i: string, Stack: Stack<PetSchema> in pairs(Inventory.StacksArray) do
                    if not string.find(Stack.StackData.petName:lower(), data:lower()) then continue end

                    for i: number, id: string in ipairs(Stack.StackArray()) do
                        if PlrDataClass()().HealingData().HealingPets[id] then continue end
                        PetsAddingToInventory[id] = Stack.StackData
                    end
                end

                InventoryGroup.AddPetsToInventory:fireClient(sender, PetsAddingToInventory)
            end
        end
    )
    
    -- Subscribe to the player's inventory.
    do
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
                        if PlrDataClass()().HealingData().HealingPets[id] then continue end
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
end

return constuctorCallback
--[[ @end_section Constructor ]]