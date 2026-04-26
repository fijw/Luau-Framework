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
    |    @version 1.0.2                                                     |
    |                                                                       |
    |    @description                                                       |
    |    ```                                                                |
    |        Library for managing reactive states. Includes features        |
    |        such as a callback to change the state data or return the      |
    |        state data, the ability to subscribe to state changes, the     |
    |        ability to subscribe to peeks at the state data, the           |
    |        ability to lock or unlock the state, and the ability to add    |
    |        more metamethods to the state.                                 |
    |    ```                                                                |
    |                                                                       |
    -------------------------------------------------------------------------

    @usage
    ```luau
        local StateEngineTest = Reactor({ bob = 41 });
        
        -- Test state changes.
        do
            (
                StateEngineTest(51, "bob") :: StateEngine<StateEngine<any>>
            )(
                123,
                "test name 1",
                "creature directories",
                "humans directory"
            )(
                456,
                "test name 2",
                "creature directories",
                "humans directory"
            )(
                789,
                "cat",
                "creature directories",
                "pets directory"
            )(
                1_011,
                "dog",
                "creature directories",
                "pets directory"
            );

            (
                StateEngineTest("inserted value 1", "insert_to_array", "testing array") :: StateEngine<StateEngine<any>>
            )(
                12_345,
                "insert_to_array",
                "testing array"
            )(
                "inserted value 2",
                "insert_to_array",
                "testing array"
            )(
                12_345,
                "remove_from_array",
                "testing array"
            )
        end

        -- Test signals.
        do
            StateEngineTest:subscribe(
                function(self, data, key, ...)
                    print(data, key, ..., "subscription callback")
                end,

                "subscription_test_1"
            )
            :wrapToPeek(
                function(self, data)
                    print(self, data, "peek callback")
                end,

                "peek_test_1"
            );

            (StateEngineTest(100_000, "bobs_bank_balance", "bank_state", "bank_balances") :: StateEngine<StateEngine<any>>)()

            StateEngineTest:unsubscribe("subscription_test_1"):unwrapToPeek("peek_test_1");

            (StateEngineTest(123_456) :: StateEngine<StateEngine<any>>)()

            StateEngineTest:subscribe(
                function(self, data, key, ...)
                    print(data, key, ..., "subscription callback (once)")
                end,

                "subscription_test_2",

                true
            )
            :wrapToPeek(
                function(self, data)
                    print(self, data, "peek callback (once)")
                end,

                "peek_test_2",

                true
            );

            (StateEngineTest(7_891_011) :: StateEngine<StateEngine<any>>)(121_314)()
        end

        -- Test locking.
        do
            StateEngineTest:lock()
            StateEngineTest("should be number type 121_314 still since it's locked, not this")

            StateEngineTest:unlock()
            StateEngineTest("should be this now since it's unlocked")
        end

        -- Test adding operators.
        do
            StateEngineTest:addOperator(
                "__div",
                
                function(self, data)
                    print(data, "__div callback")
                    return self
                end
            )

            StateEngineTest /= 5
        end

        -- Printing the state engine.
        do
            print(StateEngineTest, "State Engine")
            print(StateEngineTest(), "State Engine Source")
            print(getmetatable(StateEngineTest), "State Engine Metatable")
        end
    ```
]]
--!strict
--!native
--!optimize 2


--[[ @section Types ]]
--[[
    @generic M Self type.
    @generic S State type.
]]
type SubscriptionCallbackType<M, S> = (self: M, data: any | S, key: any?, ...any) -> ()

--[[
    @generic M Self type.
    @generic S State type.
]]
type WrappedPeekCallbackType<M, S> = (self: M, data: S) -> ()

--[[ @generic M Self type. ]]
type UnmappedMethodCallbackType<M> = (self: M, data: any) -> (M)


type StateDetailsSchema
= {
    isSubscribed: boolean,
    isLocked: boolean,
    isPeekWrapped: boolean
}

--[[
    @generic M Self type.
    @generic S State type.
]]
type StateEngineStartingSchema<M, S>
= {
    subscriptionCallback: SubscriptionCallbackType<M, S>?,
    subscriptionOnce: true?,

    peekCallback: WrappedPeekCallbackType<M, S>?,
    peekObserveOnce: true?,

    locked: true?
}

--[[
    @generic M Self type.
    @generic S State type.
]]
type SubscriptionSchema<M, S>
= {
    callback: SubscriptionCallbackType<M, S>,
    once: true?
}

--[[
    @generic M Self type.
    @generic S State type.
]]
type PeekSchema<M, S>
= {
    callback: WrappedPeekCallbackType<M, S>,
    once: true?
}


type InsertToArrayLiteral = "insert_to_array"
type RemoveFromArrayLiteral = "remove_from_array"
type AvailableOperatorLiterals = "__div" | "__idiv" | "__sub" | "__mul" | "__mod" | "__pow" | "__eq" | "__add"


--[[ @generic S State type. ]]
export type StateEngine<S> = setmetatable
<
    {
        SubscriptionCallbacks: { [string]: SubscriptionSchema<StateEngine<S>, S> },
        PeekCallbacks: { [string]: PeekSchema<StateEngine<S>, S> },

        locked: true?
    },

    {
        __call: (self: StateEngine<S>, freshData: any?, freshKey: (any | InsertToArrayLiteral | RemoveFromArrayLiteral)?, ...any) -> (S),

        __index
        : {
            addOperator
            : (
                self: StateEngine<S>,
                methodName: AvailableOperatorLiterals,
                methodCallback: UnmappedMethodCallbackType<StateEngine<S>>
            ) -> (StateEngine<S>),

            subscribe: (self: StateEngine<S>, callback: SubscriptionCallbackType<StateEngine<S>, S>, subscriptionId: string, once: true?) -> (StateEngine<S>),
            unsubscribe: (self: StateEngine<S>, subscriptionId: string) -> (StateEngine<S>),

            lock: (self: StateEngine<S>) -> (StateEngine<S>),
            unlock: (self: StateEngine<S>) -> (StateEngine<S>),

            wrapToPeek: (self: StateEngine<S>, callback: WrappedPeekCallbackType<StateEngine<S>, S>, peekId: string, once: true?) -> (StateEngine<S>),
            unwrapToPeek: (self: StateEngine<S>, peekId: string) -> (StateEngine<S>)
        },

        -- Available operators to override
        __div: UnmappedMethodCallbackType<StateEngine<S>>,
        __idiv: UnmappedMethodCallbackType<StateEngine<S>>,
        __sub: UnmappedMethodCallbackType<StateEngine<S>>,
        __mul: UnmappedMethodCallbackType<StateEngine<S>>,
        __mod: UnmappedMethodCallbackType<StateEngine<S>>,
        __pow: UnmappedMethodCallbackType<StateEngine<S>>,
        __eq: UnmappedMethodCallbackType<StateEngine<S>>,
        __add: UnmappedMethodCallbackType<StateEngine<S>>,

        state: S
    }
>
--[[ @end_section Types ]]


--[[ @section Subscription Methods ]]
--[[
    @usage Subscribes a callback to the class.

    @param self StateEngine<any>
    @param callback SubscriptionCallbackType<StateEngine<any>, any>
    @param subscriptionId string
    @param once true?

    @return StateEngine<any>
]]
local function subscribeCallback
(
    self: StateEngine<any>,
    callback: SubscriptionCallbackType<StateEngine<any>, any>,
    subscriptionId: string,
    once: true?
): StateEngine<any>
    self.SubscriptionCallbacks[subscriptionId] = { callback = callback, once = once }
    return self
end

--[[
    @usage Unsubscribes a callback from the class.

    @param self StateEngine<any>
    @param subscriptionId string

    @return StateEngine<any>
]]
local function unsubscribeCallback(self: StateEngine<any>, subscriptionId: string): StateEngine<any>
    self.SubscriptionCallbacks[subscriptionId] = nil
    return self
end
--[[ @end_section Subscription Methods ]]


--[[ @section Peek Methods ]]
--[[
    @usage Wraps a peek callback to the class.

    @param self StateEngine<any>
    @param callback WrappedPeekCallbackType<StateEngine<any>, any>
    @param peekId string
    @param once true?

    @return StateEngine<any>
]]
local function wrapToPeekCallback
(
    self: StateEngine<any>,
    callback: WrappedPeekCallbackType<StateEngine<any>, any>,
    peekId: string,
    once: true?
): StateEngine<any>
    self.PeekCallbacks[peekId] = { callback = callback, once = once }
    return self
end

--[[
    @usage Unwraps a peek callback from the class.

    @param self StateEngine<any>
    @param peekId string

    @return StateEngine<any>
]]
local function unwrapToPeekCallback(self: StateEngine<any>, peekId: string): StateEngine<any>
    self.PeekCallbacks[peekId] = nil
    return self
end
--[[ @end_section Peek Methods ]]


--[[ @section Lock Methods ]]
--[[
    @usage Locks the class, preventing further modifications.

    @param self StateEngine<any>

    @return StateEngine<any>
]]
local function lockCallback(self: StateEngine<any>): StateEngine<any>
    self.locked = true
    return self
end

--[[
    @usage Unlocks the class, allowing further modifications.

    @param self StateEngine<any>

    @return StateEngine<any>
]]
local function unlockCallback(self: StateEngine<any>): StateEngine<any>
    self.locked = nil
    return self
end
--[[ @end_section Lock Methods ]]


--[[ @section Operator Methods ]]
--[[
    @usage Returns the current state of the class or edits it.

    @param self StateEngine<any>
    @param freshData any?
    @param freshKey (any | InsertToArrayLiteral | RemoveFromArrayLiteral)?
    @param ... any

    @return any
]]
local function stateEngineCallback
(
    self: StateEngine<any>,
    freshData: any?,
    freshKey: (any | InsertToArrayLiteral | RemoveFromArrayLiteral)?,
    ...: any
): any
    local CurrentState = getmetatable(self).state

    -- Checks for nil data or locked state to just return the state.
    if freshData == nil or self.locked then
        local StateClone: { [any]: any } = {}

        if typeof(CurrentState) == "table" then
            for i: any, v: any in pairs(CurrentState :: { [any]: any }) do
                StateClone[i] = v
            end
        else table.insert(StateClone, CurrentState); StateClone = table.unpack(StateClone) end

        -- Call the peek callbacks.
        for i: string, PeekData: PeekSchema<StateEngine<any>, any> in pairs(self.PeekCallbacks) do
            PeekData.callback(self, StateClone)
            if PeekData.once then self.PeekCallbacks[i] = nil end
        end

        return StateClone
    end

    local Args = { ... }
    local numOfArgs = #Args

    --[[
        Data modification handling. Supports overwriting state, overwriting [key] = data in state,
        overwriting [key] = data inside of [path] in state, inserting array data inside of [path] in state,
        inserting array data in state, removing array data inside of [path] in state,
        and removing array data in state.
    ]]
    if not freshKey and numOfArgs == 0 then getmetatable(self).state = freshData
    elseif freshKey == "remove_from_array" and numOfArgs == 0 and typeof(CurrentState) == "table" then
        local FoundIndex = table.find(CurrentState, freshData)
        if FoundIndex then table.remove(CurrentState, FoundIndex) end
    elseif freshKey == "insert_to_array" and numOfArgs == 0 and typeof(CurrentState) == "table" then
        table.insert(CurrentState, freshData)
    elseif numOfArgs == 0 and typeof(CurrentState) == "table" then CurrentState[freshKey] = freshData
    elseif freshKey == "insert_to_array" and numOfArgs > 0 and typeof(CurrentState) == "table" then
        local CurrentPath = CurrentState

        for i: number, arg: any in ipairs(Args) do
            if not CurrentPath[arg] then CurrentPath[arg] = {} end
            CurrentPath = CurrentPath[arg]

            if i == numOfArgs and typeof(CurrentPath) == "table" then table.insert(CurrentPath, freshData) end
        end
    elseif freshKey == "remove_from_array" and numOfArgs > 0 and typeof(CurrentState) == "table" then
        local CurrentPath = CurrentState

        for i: number, arg: any in ipairs(Args) do
            if not CurrentPath[arg] then CurrentPath[arg] = {} end
            CurrentPath = CurrentPath[arg]

            if i == numOfArgs and typeof(CurrentPath) == "table" then
                local FoundIndex = table.find(CurrentPath, freshData)
                if FoundIndex then table.remove(CurrentPath, FoundIndex) end
            end
        end
    elseif numOfArgs > 0 and typeof(CurrentState) == "table" and freshKey ~= "insert_to_array" and freshKey ~= "remove_from_array" then
        local CurrentPath = CurrentState

        for i: number, arg: any in ipairs(Args) do
            if not CurrentPath[arg] then CurrentPath[arg] = {} end
            CurrentPath = CurrentPath[arg]

            if i == numOfArgs and typeof(CurrentPath) == "table" then CurrentPath[freshKey] = freshData end
        end
    end

    -- Call the subscription callbacks.
    for i: string, SubscriptionData: SubscriptionSchema<StateEngine<any>, any> in pairs(self.SubscriptionCallbacks) do
        SubscriptionData.callback(self, freshData, freshKey, ...)
        if SubscriptionData.once then self.SubscriptionCallbacks[i] = nil end
    end

    return self
end

--[[
    @usage Adds a method to the class.

    @param self StateEngine<any>
    @param methodName string
    @param methodCallback UnmappedMethodCallbackType<StateEngine<any>>

    @return StateEngine<any>
]]
local function addOperatorCallback
(
    self: StateEngine<any>,
    methodName: AvailableOperatorLiterals,
    methodCallback: UnmappedMethodCallbackType<StateEngine<any>>
): StateEngine<any>
    if table.isfrozen(self :: any)
        or methodName == "__call"
        or methodName == "__index"
    then return self end

    local TempMetatable = getmetatable(self) :: { [string]: any }
    TempMetatable[methodName] = methodCallback
    setmetatable(self, TempMetatable)

    return self
end
--[[ @end_section Operator Methods ]]


--[[ @section State Engine Constructor ]]
--[[
    @usage Creates a new state engine.

    @generic S State type.

    @param state S
    @param StartingSchema StateEngineStartingSchema<StateEngine<S>, S>?

    @return StateEngine<S>
]]
local function stateEngineConstructor
<S>(
    state: S,
    StartingSchema: StateEngineStartingSchema<StateEngine<S>, S>?
): StateEngine<S>
    local NewStateEngine
    = setmetatable(
        {
            PeekCallbacks = {},
            SubscriptionCallbacks = {}
        },

        {
            __index
            = {
                addOperator = addOperatorCallback,

                subscribe = subscribeCallback,
                unsubscribe = unsubscribeCallback,

                lock = lockCallback,
                unlock = unlockCallback,

                wrapToPeek = wrapToPeekCallback,
                unwrapToPeek = unwrapToPeekCallback
            },

            __call = stateEngineCallback,

            state = state
        }
    ) :: StateEngine<S>

    if not StartingSchema then return NewStateEngine end
    if StartingSchema.locked then NewStateEngine:lock() end

    return NewStateEngine
end

return stateEngineConstructor
--[[ @end_section State Engine Constructor ]]