--[[
    -------------------------------------------------------------------------
    |                                                                       |
    |    @author                                                            |
    |    ```                                                                |
    |        Roblox: @roblox_user_5618502527                                |
    |        GitHub: @fijw (k4)                                             |
    |        Twitter: @Xjwfi (k4)                                           |
    |        Discord: @vfjx (k4)                                            |
    |    ```                                                                |
    |                                                                       |
    |    @version 1.0.1                                                     |
    |                                                                       |
    |    @description                                                       |
    |    ```                                                                |
    |        Library for storing and managing player items. Includes        |
    |        features such as duplicate-item-stacking for data              |
    |        efficiency, subscription functions for items added and         |
    |        removed, advanced stack fetching functions, and advanced       |
    |        item addition and removal methods.                             |
    |    ```                                                                |
    |                                                                       |
    -------------------------------------------------------------------------

    @usage
    ```luau
        local function onPlayerAdded(player: Player)
            local PlrDataClass = Registry(player)
            if not PlrDataClass then return end

            -- Initialize the player's inventory.
            local oldInventoryState = if PlrDataClass()().Inventory then PlrDataClass()().Inventory() :: SavingInventoryClassSchema else nil
            PlrDataClass()(Stackentory(oldInventoryState, 250), "Inventory")

            local Inventory = PlrDataClass()().Inventory :: InventoryClass

            -- Testing inventory functionality.
            do
                local ItemData = { name = "test", data = 123_456 }

                Inventory += { itemId = "test_id_1", itemData = ItemData }
                Inventory += { itemId = "test_id_2", itemData = ItemData }
                Inventory -= "test_id_1"

                if Inventory:fetchStackFromItemData(ItemData) then print(ItemData, "should only be 1") end
                if Inventory:fetchStackFromItemId("test_id_1") then print("found, that's bad!") end
            end

            -- Add existing pets to the player's client inventory.
            do
                local PetsAddingToInventory = {}
                
                for stackIndex: string, SavingStackSchema: SavingStackSchema<PetSchema> in pairs(Inventory().StacksDictionary) do
                    for idIndex: number, id: string in ipairs(SavingStackSchema.StackArray) do
                        if PlrDataClass()().HealingData().HealingPets[id] then continue end
                        PetsAddingToInventory[id] = SavingStackSchema.StackData
                    end
                end
                
                InventoryGroup.AddPetsToInventory:fireClient(player, PetsAddingToInventory)
            end

            -- Subscribe to the player's inventory.
            do
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
        end

        for i: number, player: Player in ipairs(Players:GetPlayers()) do onPlayerAdded(player) end
        Players.PlayerAdded:Connect(onPlayerAdded)
    ```
]]
--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableUtils = require(ReplicatedStorage.Libraries.TableUtils)
local Stacking = require(script.Stacking)
--[[ @end_section Imports ]]


--[[ @section Types ]]
--[[ @generic D Data type. ]]
type SavingStackSchema<D> = Stacking.SavingStackSchema<D>

--[[ @generic D Data type. ]]
type StackClass<D> = Stacking.StackClass<D>


type ItemAddedSubscriptionType = (itemData: any, itemId: string) -> ()
type ItemRemovedSubscriptionType = (itemId: string) -> ()


export type SavingInventoryClassSchema
= {
    maxItems: number,
    usedItemSlots: number,

    StacksDictionary: { [string]: SavingStackSchema<any> }
}


--[[ @generic D Data type. ]]
export type InventoryClass = setmetatable
<
    {
        onItemAddedSubscription: ItemAddedSubscriptionType?,
        onItemRemovedSubscription: ItemRemovedSubscriptionType?,

        maxItems: number,
        usedItemSlots: number,

        StacksDictionary: { [string]: StackClass<any> }
    },

    {
        __index
        : {
            fetchStackFromItemId: (self: InventoryClass, id: string) -> (StackClass<any>?),
            fetchStackFromItemData: <D>(self: InventoryClass, data: D, ExclusionKeys: { any }?) -> (StackClass<D>?),

            subscribeToItemsAdded: (self: InventoryClass, callback: ItemAddedSubscriptionType) -> (),
            subscribeToItemsRemoved: (self: InventoryClass, callback: ItemRemovedSubscriptionType) -> (),
        },

        __add: (self: InventoryClass, AddingSchema: { itemData: any, itemId: string, forceAdd: true?, ExclusionKeys: { any }? }) -> (InventoryClass),
        __sub: (self: InventoryClass, itemId: string) -> (InventoryClass),

        __call: (self: InventoryClass) -> (SavingInventoryClassSchema)
    }
>
--[[ @end_section Types ]]


--[[ @section Fetching Functions ]]
--[[
    @usage Fetches a stack class from the inventory class via an item id.

    @param self InventoryClass
    @param id string

    @return Stack<any>?
]]
local function fetchStackFromItemIdCallback(self: InventoryClass, id: string): StackClass<any>?
    local FoundStack: StackClass<any>?

    for i: string, Stack: StackClass<any> in pairs(self.StacksDictionary) do
        for idIndex: number, loopedStackId: string in ipairs(Stack.StackArray()) do
            if loopedStackId == id then FoundStack = Stack; break end
        end

        if FoundStack ~= nil then break end
    end

    return FoundStack
end

--[[
    @usage Fetches a stack class from the inventory class via item data.

    @generic D Data type.

    @param self InventoryClass
    @param data D
    @param ExclusionKeys { any }?

    @return StackClass<D>?
]]
local function fetchStackFromItemDataCallback<D>(self: InventoryClass, data: D, ExclusionKeys: { any }?): StackClass<D>?
    local FoundStack: StackClass<D>?

    for stackIndex: string, Stack: StackClass<D> in pairs(self.StacksDictionary) do
        if typeof(Stack.StackData) ~= "table" and typeof(data) ~= "table" then
            if Stack.StackData == data then FoundStack = Stack; break end
        elseif typeof(data) ~= "table" and typeof(Stack.StackData) == "table" then continue
        elseif typeof(Stack.StackData) ~= "table" and typeof(data) == "table" then continue end

        local isMatch = TableUtils.deepCompare(data, Stack.StackData, ExclusionKeys)
        if isMatch ~= "mismatch" then FoundStack = Stack; break end
    end

    return FoundStack
end
--[[ @end_section Fetching Functions ]]


--[[ @section Subscription Callbacks ]]
local function subscribeToItemsAddedCallback(self: InventoryClass, callback: ItemAddedSubscriptionType): ()
    self.onItemAddedSubscription = callback
end

local function subscribeToItemsRemovedCallback(self: InventoryClass, callback: ItemRemovedSubscriptionType): ()
    self.onItemRemovedSubscription = callback
end
--[[ @end_section Subscription Callbacks ]]


--[[ @section Arithmetic Callbacks ]]
--[[
    @usage Adds an item to the inventory class.

    @param self InventoryClass
    @param AddingSchema { itemData: any, itemId: string }
    @param forceAdd true?

    @return InventoryClass
]]
local function addCallback(self: InventoryClass, AddingSchema: { itemData: any, itemId: string, forceAdd: true?, ExclusionKeys: { any }? }): InventoryClass
    if self.usedItemSlots >= self.maxItems and not AddingSchema.forceAdd then return self end
    self.usedItemSlots += 1

    local FetchedStack = self:fetchStackFromItemData(AddingSchema.itemData, AddingSchema.ExclusionKeys)

    if not FetchedStack then
        local stackId = HttpService:GenerateGUID(false)
        FetchedStack = Stacking(AddingSchema.itemData, { AddingSchema.itemId }, stackId)

        self.StacksDictionary[stackId] = FetchedStack

        if self.onItemAddedSubscription then self.onItemAddedSubscription(AddingSchema.itemData, AddingSchema.itemId) end
        return self
    end

    FetchedStack += AddingSchema.itemId
    if self.onItemAddedSubscription then self.onItemAddedSubscription(AddingSchema.itemData, AddingSchema.itemId) end

    return self
end

--[[
    @usage Removes an item from the inventory class.

    @param self InventoryClass   
    @param itemId string

    @return InventoryClass
]]
local function removeCallback(self: InventoryClass, itemId: string): InventoryClass
    self.usedItemSlots -= 1

    local FetchedStack = self:fetchStackFromItemId(itemId)
    if not FetchedStack then return self end

    FetchedStack -= itemId
    if #FetchedStack.StackArray() <= 0 then self.StacksDictionary[FetchedStack.stackId] = nil end

    if self.onItemRemovedSubscription then self.onItemRemovedSubscription(itemId) end
    return self
end
--[[ @end_section Arithmetic Callbacks ]]


--[[
    @usage Return the saving schema of the inventory class.

    @param self InventoryClass

    @return SavingInventoryClassSchema
]]
local function inventoryClassCallback(self: InventoryClass): SavingInventoryClassSchema
    local SavingInventoryClassSchema: SavingInventoryClassSchema
    = {
        maxItems = self.maxItems,
        usedItemSlots = self.usedItemSlots,

        StacksDictionary = {}
    }

    for i: string, Stack: StackClass<any> in pairs(self.StacksDictionary) do
        SavingInventoryClassSchema.StacksDictionary[i] = Stack()
    end

    return SavingInventoryClassSchema
end


--[[ @section Constructor ]]
--[[
    @usage Create an inventory class.

    @param PreviousInventory SavingInventoryClassSchema?
    @param maxItems number?

    @return Inventory
]]
local function constructorCallback(PreviousInventoryClass: SavingInventoryClassSchema?, maxItems: number?): InventoryClass
    local NewInventory
    = {
        maxItems = if PreviousInventoryClass then PreviousInventoryClass.maxItems elseif maxItems then maxItems else math.huge,
        usedItemSlots = if PreviousInventoryClass then PreviousInventoryClass.usedItemSlots else 0,

        StacksDictionary = {}
    }

    -- Initialize the stored stacks if they exist.
    do
        local StacksArray = if PreviousInventoryClass then PreviousInventoryClass.StacksDictionary else {}

        for i: string, SavingStackSchema: SavingStackSchema<any> in pairs(StacksArray) do
            NewInventory.StacksDictionary[i] = Stacking(SavingStackSchema.StackData, SavingStackSchema.StackArray, i)
        end
    end

    setmetatable(NewInventory,
        {
            __index
            = {
                fetchStackFromItemId = fetchStackFromItemIdCallback,
                fetchStackFromItemData = fetchStackFromItemDataCallback,

                subscribeToItemsAdded = subscribeToItemsAddedCallback,
                subscribeToItemsRemoved = subscribeToItemsRemovedCallback
            },

            __add = addCallback,
            __sub = removeCallback,

            __call = inventoryClassCallback
        }
    )

    return NewInventory :: InventoryClass
end

return constructorCallback
--[[ @end_section Constructor ]]