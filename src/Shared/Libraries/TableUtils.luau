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

    return setmetatable(Out, OutMetatable)
end

--[[
    @usage Deeply freezes a table, including all nested tables.

    @generic T Input table type.

    @param In T

    @return T
]]
function TableUtils.deepFreeze<T>(In: T): T
    if typeof(In) ~= "table" then return In end

    for i: any, v: any in pairs(In) do
        if typeof(v) == "table" then TableUtils.deepFreeze(v) end
    end

    return table.freeze(In)
end

--[[
    @usage Deeply compares two tables, including all nested tables.

    @param TablesToCompare { { [any]: any } }

    @return "match" | "mismatch"
]]

function TableUtils.deepCompare(TablesToCompare: { { [any]: any } }): "match" | "mismatch"
    if #TablesToCompare ~= 2 then return "mismatch" end
    local tableComparison1, tableComparison2 = TablesToCompare[1], TablesToCompare[2]
    
    for i: any, v: any in pairs(tableComparison1) do
        if typeof(v) == "table" and typeof(tableComparison2[i]) == "table" then
            if TableUtils.deepCompare(v, tableComparison2[i]) == "mismatch" then
                return "mismatch"
            else
                continue
            end
        end

        if tableComparison2[i] ~= v then return "mismatch" end
    end

    return "match"
end
--[[ @end_section Deep Table Functions ]]


table.freeze(TableUtils)
return TableUtils