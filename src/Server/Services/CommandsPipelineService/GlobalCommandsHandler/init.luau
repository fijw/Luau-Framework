--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local OnGlobalBanAsync = require(script.AsyncFunctions.OnGlobalBanAsync)
local OnGlobalKickAsync = require(script.AsyncFunctions.OnGlobalKickAsync)
local OnGlobalBringPlayerToServerAsync = require(script.AsyncFunctions.OnGlobalBringPlayerToServerAsync)

local Reactor = require(ReplicatedStorage.Libraries.Reactor)
local Compression = require(ServerScriptService.Libraries.Compression)
--[[ @end_section Imports ]]


--[[ @generic T Source type. ]]
type StateEngine<T> = Reactor.AbstractedStateEngine<T>


local AsyncFunctionsMap
= {
    ban = OnGlobalBanAsync,
    kick = OnGlobalKickAsync,
    bring_player_to_server = OnGlobalBringPlayerToServerAsync
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