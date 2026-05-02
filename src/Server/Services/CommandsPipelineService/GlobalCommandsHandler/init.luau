--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OnGlobalBanAsync = require(script.AsyncFunctions.Moderation.OnGlobalBanAsync)
local OnGlobalKickAsync = require(script.AsyncFunctions.Moderation.OnGlobalKickAsync)
local OnGlobalTempBanAsync = require(script.AsyncFunctions.Moderation.OnGlobalTempBanAsync)
local OnGlobalBringPlayerToServerAsync = require(script.AsyncFunctions.Joining.OnGlobalBringPlayerToServerAsync)
local OnGlobalResetDataAsync = require(script.AsyncFunctions.Moderation.OnGlobalResetDataAsync)

local Compression = require(ReplicatedStorage.Libraries.DataLibs.Compression)
--[[ @end_section Imports ]]


local AsyncFunctionsMap
= {
    ban = OnGlobalBanAsync,
    kick = OnGlobalKickAsync,
    bring_player_to_server = OnGlobalBringPlayerToServerAsync,
    temp_ban = OnGlobalTempBanAsync,
    reset_data = OnGlobalResetDataAsync
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