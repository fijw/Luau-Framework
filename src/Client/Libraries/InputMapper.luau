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
    |    @version 1.0.0                                                     |
    |                                                                       |
    |    @description                                                       |
    |    ```                                                                |
    |        Quick handler for keybind mapping and grouping together        |
    |        input events. Also makes it easier to stop groups of input     |
    |        events and manage them all at the same time.                   |
    |    ```                                                                |
    |                                                                       |
    -------------------------------------------------------------------------

    @usage
    ```luau
        local TestInputMapper
        = InputMapper(
            Enum.KeyCode.Space,

            function(thing: string)
                print(thing)
            end,

            "Testing String for Space"
        )

        TestInputMapper(
            Enum.KeyCode.F,

            function(thing: string)
                print(thing)
            end,

            "Testing String for F"
        )

        task.wait(10)

        TestInputMapper:wipeConnections()
    ```
]]
--!strict
--!native
--!optimize 2


local UserInputService = game:GetService("UserInputService")


export type InputMapper = setmetatable
<
    { Connections: { RBXScriptConnection } },

    {
        __index: { wipeConnections: (self: InputMapper) -> () },

        __call
        : <A...>(
            self: InputMapper,
            useEvenIfProcessed: boolean?,
            keybind: Enum.KeyCode,
            func: (A...) -> (...any),
            A...
        ) -> (InputMapper)
    }
>


--[[ @section Utility Functions ]]
--[[
    @usage Maps an input to a function.

    @generic_pack T... Inputted parameters for the binded function.

    @param useEvenIfProcessed boolean?
    @param input InputObject
    @param gameProcessed boolean
    @param keybind Enum.KeyCode
    @param func (T...) -> (...any)
    @param ... T...

    @return void
]]
local function onInputBegan
<T...>(
    useEvenIfProcessed: boolean?,
    input: InputObject,
    gameProcessed: boolean,
    keybind: Enum.KeyCode,
    func: (T...) -> (...any),
    ...: T...
)
    if (gameProcessed and not useEvenIfProcessed) or input.KeyCode ~= keybind then return end

    func(...)
end

--[[
    @usage Maps an input to a function within an existing InputMapper.

    @generic_pack F... Inputted parameters for the binded function.

    @param self InputMapper
    @param useEvenIfProcessed boolean?
    @param keybind Enum.KeyCode
    @param func (F...) -> (...any)
    @param ... F...
    
    @return InputMapper
]]
local function inputMapperCallback
<F...>(
    self: InputMapper,
    useEvenIfProcessed: boolean?,
    keybind: Enum.KeyCode,
    func: (F...) -> (...any),
    ...: F...
): InputMapper
    local Args = { ... }
    local UnpackedArgs = table.unpack(Args :: any)

    local Connection = UserInputService.InputBegan
    :Connect(
        function(input: InputObject, gameProcessed: boolean) onInputBegan(useEvenIfProcessed, input, gameProcessed, keybind, func, UnpackedArgs) end
    )

    table.insert(self.Connections, Connection)

    return self
end
--[[ @end_section Utility Functions ]]


--[[
    @usage Wipes all connections from the InputMapper.

    @param self InputMapper

    @return void
]]
local function wipeConnectionsCallback(self: InputMapper): ()
    for i: number, Connection: RBXScriptConnection in ipairs(self.Connections) do Connection:Disconnect() end
end


--[[ @section Constructor ]]
--[[
    @usage Creates a new InputMapper.

    @generic_pack P... Inputted parameters for the binded function.

    @param useEvenIfProcessed boolean?
    @param keybind Enum.KeyCode
    @param func (P...) -> (...any)
    @param ... P...

    @return InputMapper
]]
local function constructorCallback
<P...>(
    useEvenIfProcessed: boolean?,
    keybind: Enum.KeyCode,
    func: (P...) -> (...any),
    ...: P...
): InputMapper
    local NewInputMapper = { Connections = {} }

    setmetatable(NewInputMapper,
        {
            __index = { wipeConnections = wipeConnectionsCallback },
            __call = inputMapperCallback
        }
    )

    inputMapperCallback(NewInputMapper :: InputMapper, useEvenIfProcessed, keybind, func, ...)

    return NewInputMapper :: InputMapper
end

return constructorCallback
--[[ @end_section Constructor ]]