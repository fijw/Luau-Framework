--!strict
--!native
--!optimize 2


local TableUtils = {}


--[[ @section Deep Table Functions ]]
--[[
    @usage Deeply clones a table, including all nested tables.

    @generic T Input table type.

    @param In T

    @return T
]]
function TableUtils.deepClone<T>(In: T): T
    if typeof(In) ~= "table" then return In end

    local Out = {}
    local OutMetatable = {}

    for i: any, v: any in pairs((getmetatable(In) :: { [any]: any }) or {}) do
        if typeof(v) == "table" then OutMetatable[i] = TableUtils.deepClone(v) else OutMetatable[i] = v end
    end

    for i: any, v: any in pairs(In :: { [any]: any }) do
        if typeof(v) == "table" then Out[i] = TableUtils.deepClone(v) else Out[i] = v end
    end

    setmetatable(Out, OutMetatable)

    return Out
end

--[[
    @usage Deeply freezes a table, including all nested tables.

    @generic T Input table type.

    @param In T

    @return T
]]
function TableUtils.deepFreeze<T>(In: T): T
    if typeof(In) ~= "table" then return In end

    for i: any, v: any in pairs(In :: { [any]: any }) do
        if typeof(v) == "table" then TableUtils.deepFreeze(v) end
    end

    return table.freeze(In)
end

--[[
    @usage Deeply compares two tables, including all nested tables.

    @param TableComparison1 { [any]: any }
    @param TableComparison2 { [any]: any }

    @return "match" | "mismatch"
]]

function TableUtils.deepCompare
(
    TableComparison1: { [any]: any },
    TableComparison2: { [any]: any },

    ExclusionsKeys: { any }?
): "match" | "mismatch"
    for i: any, v: any in pairs(TableComparison1) do
        if table.find(ExclusionsKeys or {}, i) then continue end

        if typeof(v) == "table" and typeof(TableComparison2[i]) == "table" then
            if TableUtils.deepCompare(v, TableComparison2[i], ExclusionsKeys) == "mismatch" then
                return "mismatch"
            else
                continue
            end
        end

        if TableComparison2[i] ~= v then return "mismatch" end
    end

    return "match"
end
--[[ @end_section Deep Table Functions ]]


--[[ @section Combining Functions ]]
--[[
    @usage Combines multiple arrays into one.

    @param ... { any }

    @return { any }
]]
function TableUtils.combineArrays(...: { any }): { any }
    local CombinedArray = {}

    for i: number, v: { any } in ipairs({ ... }) do
        for i: number, arrayValue: any in ipairs(v) do table.insert(CombinedArray, arrayValue) end
    end

    return CombinedArray
end

--[[
    @usage Combines multiple dictionaries into one.

    @param ... { [any]: any }

    @return { [any]: any }
]]
function TableUtils.combineDictionaries(...: { [any]: any }): { [any]: any }
    local CombinedDictionary = {}

    for i: number, v: { [any]: any } in ipairs({ ... }) do
        for dictionaryIndex: any, dictionaryValue: any in pairs(v) do CombinedDictionary[dictionaryIndex] = dictionaryValue end
    end

    return CombinedDictionary
end
--[[ @end_section Combining Functions ]]


table.freeze(TableUtils)
return TableUtils