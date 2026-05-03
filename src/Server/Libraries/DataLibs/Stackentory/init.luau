--!strict
--!native
--!optimize 2
local HttpService = game:GetService("HttpService")


local Stacking = require(script.Stacking)


--[[ @section Types ]]
--[[ @generic D Data type. ]]
type SavingStackSchema<D> = Stacking.SavingStackSchema<D>

--[[ @generic D Data type. ]]
type StackClass<D> = Stacking.StackClass<D>


type ItemAddedSubscriptionType = (itemData: any, itemId: string) -> ()
type ItemRemovedSubscriptionType = (itemId: string) -> ()


export type SavingInventoryClassSchema
= {
    maxStacks: number,
    usedStacks: number,

    StacksArray: { [string]: SavingStackSchema<any> }
}


--[[ @generic D Data type. ]]
export type InventoryClass = setmetatable
<
    {
        onItemAddedSubscription: ItemAddedSubscriptionType?,
        onItemRemovedSubscription: ItemRemovedSubscriptionType?,

        maxStacks: number,
        usedStacks: number,

        StacksArray: { [string]: StackClass<any> }
    },

    {
        __index
        : {
            fetchStackFromItemId: (self: InventoryClass, id: string) -> (StackClass<any>?),
            fetchStackFromItemData: <D>(self: InventoryClass, data: D) -> (StackClass<D>?),

            subscribeToItemsAdded: (self: InventoryClass, callback: ItemAddedSubscriptionType) -> (),
            subscribeToItemsRemoved: (self: InventoryClass, callback: ItemRemovedSubscriptionType) -> (),
        },

        __add: (self: InventoryClass, AddingSchema: { itemData: any, itemId: string }) -> (InventoryClass),
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

    for i: string, Stack: StackClass<any> in pairs(self.StacksArray) do
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

    @return StackClass<D>?
]]
local function fetchStackFromItemDataCallback<D>(self: InventoryClass, data: D): StackClass<D>?
    local FoundStack: StackClass<D>?

    for stackIndex: string, Stack: StackClass<D> in pairs(self.StacksArray) do
        if typeof(Stack.StackData) ~= "table" and typeof(data) ~= "table" then
            if Stack.StackData == data then FoundStack = Stack; break end
        elseif typeof(data) ~= "table" and typeof(Stack.StackData) == "table" then continue
        elseif typeof(Stack.StackData) ~= "table" and typeof(data) == "table" then continue end

        local success: false?

        for stackDataIndex: any, v: any in pairs(Stack.StackData :: { [any]: any }) do
            if not (data :: { [any]: any })[stackDataIndex] or (data :: { [any]: any })[stackDataIndex] ~= v then success = false end
        end

        if success ~= false then FoundStack = Stack; break end
    end

    return FoundStack
end
--[[ @end_section Fetching Functions ]]


--[[ @section Subscription Callbacks ]]
local function subscribeToItemsAddedCallback(self: InventoryClass, callback: ItemAddedSubscriptionType)
    self.onItemAddedSubscription = callback
end

local function subscribeToItemsRemovedCallback(self: InventoryClass, callback: ItemRemovedSubscriptionType)
    self.onItemRemovedSubscription = callback
end
--[[ @end_section Subscription Callbacks ]]


--[[ @section Arithmetic Callbacks ]]
--[[
    @usage Adds an item to the inventory class.

    @param self InventoryClass
    @param AddingSchema { itemData: any, itemId: string }

    @return InventoryClass
]]
local function addCallback(self: InventoryClass, AddingSchema: { itemData: any, itemId: string }): InventoryClass
    if self.usedStacks >= self.maxStacks then return self end
    self.usedStacks += 1

    local FetchedStack = self:fetchStackFromItemData(AddingSchema.itemData)

    if not FetchedStack then
        FetchedStack = Stacking(AddingSchema.itemData, { AddingSchema.itemId })

        self.StacksArray[HttpService:GenerateGUID(false)] = FetchedStack
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
    self.usedStacks -= 1

    local FetchedStack = self:fetchStackFromItemId(itemId)
    if not FetchedStack then return self end

    FetchedStack -= itemId
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
        maxStacks = self.maxStacks,
        usedStacks = self.usedStacks,

        StacksArray = {}
    }

    for i: string, Stack: StackClass<any> in pairs(self.StacksArray) do
        SavingInventoryClassSchema.StacksArray[i] = Stack()
    end

    return SavingInventoryClassSchema
end


--[[ @section Constructor ]]
--[[
    @usage Create an inventory class.

    @param PreviousInventory
    {
        maxStacks: number,
        usedStacks: number,

        StacksArray: { [string]: SavingStackSchema<any> }
    }?

    @return Inventory
]]
local function constructorCallback
(
    PreviousInventoryClass
    : {
        maxStacks: number,
        usedStacks: number,

        StacksArray: { [string]: SavingStackSchema<any> }
    }?
): InventoryClass
    local NewInventory
    = {
        maxStacks = if PreviousInventoryClass then PreviousInventoryClass.maxStacks else 500,
        usedStacks = if PreviousInventoryClass then PreviousInventoryClass.usedStacks else 0,

        StacksArray = {}
    }

    -- Initialize the stored stacks if they exist.
    do
        local StacksArray = if PreviousInventoryClass then PreviousInventoryClass.StacksArray else {}

        for i: string, SavingStackSchema: SavingStackSchema<any> in pairs(StacksArray) do
            NewInventory.StacksArray[i] = Stacking(SavingStackSchema.StackData, SavingStackSchema.StackArray)
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