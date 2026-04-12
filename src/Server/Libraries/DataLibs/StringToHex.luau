--!strict
--!native
--!optimize 2


local StringToHex = {}


--[[ @section Converting Functions ]]
--[[
    @usage Convert string to hexadecimal.

    @param str string
    
    @return string
]]
function StringToHex.convert(str: string): string
    local hex = ""

    for i = 1, #str do
        local byte = string.byte(str, i)
        hex ..= string.format("%02x", byte)
    end

    return hex
end

--[[
    @usage Convert hexadecimal to string.

    @param hex string
    
    @return string
]]
function StringToHex.reverseConvert(hex: string): string
    local str = ""

    for i = 1, #hex, 2 do
        local byteHex = string.sub(hex, i, i + 1)
        local byte = tonumber(byteHex, 16)
        str ..= if byte then string.char(byte) else ""
    end

    return str
end
--[[ @end_section Converting Functions ]]


table.freeze(StringToHex)
return StringToHex