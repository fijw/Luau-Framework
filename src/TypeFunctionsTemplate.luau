--!strict
--!optimize 2


--[[ @section Types ]]
type function CreateTestTypeFunction<X>(inputtedSelf: X): type
    local tGeneric = types.generic("T")
    local uGeneric = types.generic("U")

    local vGenericPack = types.generic("V", true)

    local newFunction = types.newfunction()
    newFunction:setgenerics({ tGeneric, uGeneric, vGenericPack })
    newFunction:setparameters({ inputtedSelf, tGeneric, uGeneric }, vGenericPack)
    newFunction:setreturns({ tGeneric, uGeneric }, vGenericPack)

    return newFunction
end

type Test<X> = setmetatable
<
    { source: { any } },
    { __call: CreateTestTypeFunction<X> }
>
--[[ @end_section Types ]]


--[[ @section Variables ]]
local Constructor = {}

local Test = {}
--[[ @end_section Variables ]]


--[[
    @usage Testing type functions.

    @generic T Inputted generic 1
    @generic U Inputted generic 2

    @generic_pack V Inputted generic pack

    @param t T?
    @param u U?
    @param ... V
    
    @return (T, U, V...)
]]
local function TestTypeCallback<T, U, V...>(self: Test<any>, t: T, u: U, ...: V...): (T, U, V...)
    self.source = { t, u, ... }
    return t, u, ...
end


--[[ @section Constructor ]]
--[[
    @usage Create a new test.
    
    @return Test<any>
]]
function Constructor:__call(): Test<any>
    local NewTest = { source = {} }
    setmetatable(NewTest, { __call = TestTypeCallback })

    return NewTest
end

setmetatable(Test, { __call = Constructor.__call })
--[[ @end_section Constructor ]]


Test()("generic 1", "generic 1", 1, 2, 3, 4 ,5, 6, 7)


table.freeze(Test)
return Test