--!strict
--!native
--!optimize 2


--[[ @section Constructor ]]
--[[
    @usage Format a number into a string with K/M/B/T suffixes.


    @param num number

    @param startFormattingAt
    "thousands"
    | "millions"
    | "billions"
    | "trillions"
    | "quadrillions"
    | "quintillions"
    | "sextillions"


    @return string
]]
local function constructorCallback
(
    num: number,
    
    startFormattingAt
    : "thousands"
    | "millions"
    | "billions"
    | "trillions"
    | "quadrillions"
    | "quintillions"
    | "sextillions"
): string
    if num >= 1_000 and num < 1_000_000 then
        return `{math.clamp(num / 1_000, 0, 999)}K`
    elseif num >= 1_000_000 and num < 1_000_000_000 then
        return `{math.clamp(num / 1_000_000, 0, 999)}M`
    elseif num >= 1_000_000_000 and num < 1_000_000_000_000 then
        return `{math.clamp(num / 1_000_000_000, 0, 999)}B`
    elseif num >= 1_000_000_000_000 and num < 1_000_000_000_000_000 then
        return `{math.clamp(num / 1_000_000_000_000, 0, 999)}T`
    elseif num >= 1_000_000_000_000_000 and num < 1_000_000_000_000_000_000 then
        return `{math.clamp(num / 1_000_000_000_000_000, 0, 999)}Qa`
    elseif num >= 1_000_000_000_000_000_000 and num < 1_000_000_000_000_000_000_000 then
        return `{math.clamp(num / 1_000_000_000_000_000_000, 0, 999)}Qi`
    elseif num >= 1_000_000_000_000_000_000_000 then
        return `{math.clamp(num / 1_000_000_000_000_000_000_000, 0, 999)}Sx`
    else return tostring(num) end
end

return constructorCallback
--[[ @end_section Constructor ]]