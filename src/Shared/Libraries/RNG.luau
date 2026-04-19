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
    |        Quick and easy RNG library for selecting random values from    |
    |        dictionaries where { [value] = chance }. Also has support      |
    |        for generating random strings of an inputted length.           |
    |    ```                                                                |
    |                                                                       |
    -------------------------------------------------------------------------

    @usage
    ```luau
        local randomString = RNG.randomString(10)
        print(randomString)

        for i = 1, 10 do
            print(
                RNG.randomFromTableOfChances(
                    {
                        ["pet 1"] = 2,
                        ["pet 2"] = 47.9,
                        ["pet 3"] = 0.1,
                        ["pet 4"] = 50
                    }
                )
            )
        end
    ```
]]
--!strict
--!native
--!optimize 2


--[[ @section Variables ]]
local CharactersWithoutSymbols
= {
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n",
    "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",

    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N",
    "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",

    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
}

local CharactersWithSymbols
= {
    "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n",
    "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",

    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N",
    "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",

    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",

    "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "_", "+", "=",
    "[", "]", "{", "}", "|", ";", ":", "\"", "'", "<", ">", ",", ".", "?",
    "/", "~", "`"
}

local RNGLibrary = {}
--[[ @end_section Variables ]]


--[[ @section RNG Functions ]]
--[[
    @usage Returns a random value from a table of chances.

    @param Chances { [any]: number } | any

    @return any
]]
function RNGLibrary.randomFromTableOfChances(Chances: { [any]: number } | any): any
    if typeof(Chances) ~= "table" then return nil end

    local totalWeight = 0

    for i: any, weight: number in pairs(Chances) do
        totalWeight += weight
    end

    local BetterRandomizedPicks = {}

    for i = 1, 3 do
        local randomPoint = math.random() * totalWeight

        -- Select an index from the Chances table.
        do
            local cumulative = 0

            for index: any, weight: number in pairs(Chances) do
                cumulative += weight

                if randomPoint <= cumulative then
                    table.insert(BetterRandomizedPicks, index)

                    break
                end
            end
        end
    end

    if #BetterRandomizedPicks <= 1 then print("Failed to get random value from a table of chances."); return end

    return BetterRandomizedPicks[math.random(1, #BetterRandomizedPicks)]
end

--[[
    @usage Returns a random string.

    @param length number
    @param symbols true?

    @return string
]]
function RNGLibrary.randomString(length: number, symbols: true?): string
    local characters = if symbols then CharactersWithSymbols else CharactersWithoutSymbols

    local result = ""
    for i = 1, length do result ..= characters[math.random(1, #characters)] end

    return result
end
--[[ @end_section RNG Functions ]]


table.freeze(RNGLibrary)
return RNGLibrary