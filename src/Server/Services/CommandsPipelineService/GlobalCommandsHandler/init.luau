--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local MessagingService = game:GetService("MessagingService")
local ServerScriptService = game:GetService("ServerScriptService")

local OnGlobalBanAsync = require(script.AsyncFunctions.OnGlobalBanAsync)
local OnGlobalKickAsync = require(script.AsyncFunctions.OnGlobalKickAsync)
local OnGlobalTempBanAsync = require(script.AsyncFunctions.OnGlobalTempBanAsync)
local OnGlobalBringPlayerToServerAsync = require(script.AsyncFunctions.OnGlobalBringPlayerToServerAsync)

local Compression = require(ServerScriptService.Libraries.Compression)
--[[ @end_section Imports ]]


local AsyncFunctionsMap
= {
    ban = OnGlobalBanAsync,
    kick = OnGlobalKickAsync,
    bring_player_to_server = OnGlobalBringPlayerToServerAsync,
    temp_ban = OnGlobalTempBanAsync
}


--[[ @section Constructor ]]
--[[
    @usage Initialize the cross-server commands handling.

    @return void
]]
local function constructorCallback()
    MessagingService:SubscribeAsync("commands",
        function
        (
            MessageData
            : {
                Data: buffer,
                Sent: number
            }
        )
            local DecompressedData = Compression(MessageData.Data, "decompress")

            local AsyncFunction = AsyncFunctionsMap[DecompressedData.commandType]
            if not AsyncFunction then return end

            AsyncFunction(DecompressedData)
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]