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
    |        Quick and easy number formatting library for converting        |
    |        large numbers into readable formats with K/M/B/T/Qa/Qi         |
    |        suffixes. Also supports adding commas to numbers for           |
    |        improved readability. You must specify at which point the      |
    |        number shortening formatting should start.                     |
    |    ```                                                                |
    |                                                                       |
    -------------------------------------------------------------------------

    @usage
    ```luau
        local convertingInt = 9999999999
        print(convertingInt)

        local convertedInt = NumberFormatLib(convertingInt, "thousands")
        print(convertedInt) -- "9B"
    ```
]]
--!strict
--!native
--!optimize 2


local SHORTENING_NUMBERS_MAP
= {
    thousands = 1_000,
    millions = 1_000_000,
    billions = 1_000_000_000,
    trillions = 1_000_000_000_000,
    quadrillions = 1_000_000_000_000_000,
    quintillions = 1_000_000_000_000_000_000,
    sextillions = 1_000_000_000_000_000_000_000
}


--[[
    @usage Add commas to a string of integers.

    @param str string

    @return string
]]
local function addCommas(str: string): string
    local formatted = str
    local k: number
    
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then break end
    end
    
    return formatted
end


--[[ @section Constructor ]]
--[[
    @usage Format a number into a string with K/M/B/T/Qa/Qi suffixes.


    @param num number

    @param startFormattingAt
    "thousands"
    | "millions"
    | "billions"
    | "trillions"
    | "quadrillions"
    | "quintillions"


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
): string
    if num > SHORTENING_NUMBERS_MAP.sextillions then return "Number too large to format." end

    if startFormattingAt == "thousands" then
        if num < SHORTENING_NUMBERS_MAP.thousands then return addCommas(`{num}`) end
    elseif startFormattingAt == "millions" then
        if num < SHORTENING_NUMBERS_MAP.millions then return addCommas(`{num}`) end
    elseif startFormattingAt == "billions" then
        if num < SHORTENING_NUMBERS_MAP.billions then return addCommas(`{num}`) end
    elseif startFormattingAt == "trillions" then
        if num < SHORTENING_NUMBERS_MAP.trillions then return addCommas(`{num}`) end
    elseif startFormattingAt == "quadrillions" then
        if num < SHORTENING_NUMBERS_MAP.quadrillions then return addCommas(`{num}`) end
    elseif startFormattingAt == "quintillions" then
        if num < SHORTENING_NUMBERS_MAP.quintillions then return addCommas(`{num}`) end
    end
    
    if num >= SHORTENING_NUMBERS_MAP.thousands and num < SHORTENING_NUMBERS_MAP.millions then
        return `{math.floor(num / SHORTENING_NUMBERS_MAP.thousands)}K`
    elseif num >= SHORTENING_NUMBERS_MAP.millions and num < SHORTENING_NUMBERS_MAP.billions then
        return `{math.floor(num / SHORTENING_NUMBERS_MAP.millions)}M`
    elseif num >= SHORTENING_NUMBERS_MAP.billions and num < SHORTENING_NUMBERS_MAP.trillions then
        return `{math.floor(num / SHORTENING_NUMBERS_MAP.billions)}B`
    elseif num >= SHORTENING_NUMBERS_MAP.trillions and num < SHORTENING_NUMBERS_MAP.quadrillions then
        return `{math.floor(num / SHORTENING_NUMBERS_MAP.trillions)}T`
    elseif num >= SHORTENING_NUMBERS_MAP.quadrillions and num < SHORTENING_NUMBERS_MAP.quintillions then
        return `{math.floor(num / SHORTENING_NUMBERS_MAP.quadrillions)}Qa`
    elseif num >= SHORTENING_NUMBERS_MAP.quintillions and num < SHORTENING_NUMBERS_MAP.sextillions then
        return `{math.floor(num / SHORTENING_NUMBERS_MAP.quintillions)}Qi`
    end

    return addCommas(`{num}`)
end

return constructorCallback
--[[ @end_section Constructor ]]