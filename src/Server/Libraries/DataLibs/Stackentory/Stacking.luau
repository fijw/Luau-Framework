--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reactor = require(ReplicatedStorage.Libraries.Reactor)
--[[ @end_section Imports ]]


--[[ @section Types ]]
--[[ @generic T State type. ]]
type StateEngine<T> = Reactor.StateEngine<T>


--[[ @generic D Data type. ]]
export type SavingStackSchema<D>
= {
    StackData: D,
    StackArray: { string }
}


--[[ @generic D Data type. ]]
export type StackClass<D> = setmetatable
<
    {
        StackData: D,
        StackArray: StateEngine<{ string }>
    },

    {
        __call: (self: StackClass<D>) -> (SavingStackSchema<D>),

        __add: (self: StackClass<D>, id: string) -> (StackClass<D>),
        __sub: (self: StackClass<D>, id: string) -> (StackClass<D>)
    }
>
--[[ @end_section Types ]]


--[[
    @usage Returns the requested data.

    @param self StackClass<any>
    @param request RequestType?

    @return ({ string } | any) | SavingStackSchema<any>
]]
local function stackCallback(self: StackClass<any>): SavingStackSchema<any>
    local SavingStack: SavingStackSchema<any>
    = {
        StackData = self.StackData,
        StackArray = self.StackArray()
    }

    return SavingStack
end


--[[ @section Arithmetic Callbacks ]]
--[[
    @usage Adds an id to the stack class.

    @param self StackClass<any>
    @param id string

    @return StackClass<any>
]]
local function addCallback(self: StackClass<any>, id: string): StackClass<any>
    self.StackArray(id, "insert_to_array")
    return self
end

--[[
    @usage Removes an id from the stack class.

    @param self StackClass<any>
    @param id string

    @return StackClass<any>
]]
local function subCallback(self: StackClass<any>, id: string): StackClass<any>
    self.StackArray(id, "remove_from_array")
    return self
end
--[[ @end_section Arithmetic Callbacks ]]


--[[ @section Constructor ]]
--[[
    @usage Initialize a stack class.

    @generic D Data type.

    @param stackData D
    @param IdsArray { string }

    @return StackClass<D>
]]
local function constructorCallback<D>(stackData: D, IdsArray: { string }): StackClass<D>
    local NewStack
    = {
        StackData = stackData,
        StackArray = Reactor(IdsArray)
    }

    setmetatable(NewStack,
        {
            __call = stackCallback,
            __add = addCallback,
            __sub = subCallback
        }
    )

    return NewStack :: StackClass<D>
end

return constructorCallback
--[[ @end_section Constructor ]]