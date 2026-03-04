--[[
    ----------------------------------------------------
    | @author Kairos (Roblox: @roblox_user_5618502527) |
    | @version 1.0.0                                   |
    | @description Library for compressing or          |
    | decompressing data into buffers. This library    |
    | currently only works with data that can be       |
    | converted to a string format via JSONEncode.     |
    ----------------------------------------------------

    @usage
    ```luau
        local TestCompressionData
        = {
            value1 = 123_456,
            value2 = "random string",
            value3 = true
        }

        -- Compression and Decompression.
        do
            local CompressedData = {}

            -- Compression.
            do
                for i: string, v: any in pairs(TestCompressionData) do
                    CompressedData[i] = Compression(v)
                end

                print(CompressedData, "Compressed data.")

                CompressedData = Compression(CompressedData)
            end

            -- Decompression.
            do
                local DecompressedData = Compression(CompressedData, "decompress") :: { [string]: buffer }

                for i: string, v: buffer in pairs(DecompressedData) do
                    DecompressedData[i] = Compression(v, "decompress")
                end

                print(DecompressedData, "Decompressed data.")
            end
        end
    ```
]]
--!strict
--!native
--!optimize 2


local HttpService = game:GetService("HttpService")


--[[ @section Buffer Functions ]]
--[[
    @usage Convert string to buffer.

    @param str string
    
    @return buffer
]]
local function stringToBuffer(str: string): buffer
    local buf = buffer.create(#str)

    for i = 1, #str do
        local byte = string.byte(str, i)
        buffer.writeu8(buf, i - 1, byte)
    end

    return buf
end

--[[
    @usage Convert buffer to string.

    @param buf buffer

    @return string
]]
local function bufferToString(buf: buffer): string
    local size = buffer.len(buf)
    local OutputTable = table.create(size)

    for i = 0, size - 1 do
        local bufChar = buffer.readu8(buf, i)
        OutputTable[i + 1] = string.char(bufChar)
    end

    local concat = table.concat(OutputTable)
    return concat
end
--[[ @end_section Buffer Functions ]]


--[[ @section Compression Constructor ]]
--[[
    @usage Compress / Decompress data. If compressionMode is true,
    @usage data will be decompressed.

    @param data any | buffer
    @param compressionMode "decompress"?

    @return any | buffer
]]
local function constructorCallback(data: any | buffer, compressionMode: "decompress"?): any | buffer
    if not compressionMode or compressionMode ~= "decompress" then
        local TemporaryWrappedTable = {} :: { any }
        local EncodedData: string

        -- If data is a table, wrap it in a table
        if typeof(data) == "table" then
            for i: unknown, v: unknown in pairs(data :: { [any]: any }) do
                local WrappedValues = { i, v }
                table.insert(TemporaryWrappedTable, WrappedValues)
            end

            EncodedData = HttpService:JSONEncode(TemporaryWrappedTable)
        else EncodedData = HttpService:JSONEncode(data) end

        local strToBuffer = stringToBuffer(EncodedData)
        return strToBuffer
    else
        local bufToString = bufferToString(data)
        local DecodedData = HttpService:JSONDecode(bufToString)

        -- If decoded data is a table, unwrap it
        if typeof(DecodedData) == "table" then
            local UnwrappedTable = {}

            for i: unknown, v: unknown in pairs(DecodedData :: { any }) do
                local key, value = v[1], v[2]
                UnwrappedTable[key] = value
            end

            return UnwrappedTable
        end

        return DecodedData
    end
end

return constructorCallback
--[[ @end_section Compression Constructor ]]