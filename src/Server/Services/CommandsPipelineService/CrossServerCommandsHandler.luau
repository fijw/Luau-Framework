--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Store = require(ServerScriptService.Libraries.Store)
local Reactor = require(ReplicatedStorage.Libraries.Reactor)
local Compression = require(ServerScriptService.Libraries.Compression)
--[[ @end_section Imports ]]


--[[ @generic T Source type. ]]
type StateEngine<T> = Reactor.AbstractedStateEngine<T>


--[[ @section Constructor ]]
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
            local DecompressedData
            : {
                targetId: number,
                commandType: "ban" | "kick",
                reason: string
            }
            = Compression(MessageData.Data, "decompress")

            local player = Players:GetPlayerByUserId(DecompressedData.targetId)
            if not player then return end

            local PlayerDataClass = Store(player.UserId)
            if not PlayerDataClass then return end

            if DecompressedData.commandType == "ban" then
                (PlayerDataClass() :: { [string]: StateEngine<any> }).banReason = Reactor(DecompressedData.reason);
                (PlayerDataClass() :: { [string]: StateEngine<any> }).isBanned(true)
            elseif DecompressedData.commandType == "kick" then
                (PlayerDataClass() :: { [string]: StateEngine<any> }).kickReason = Reactor(DecompressedData.reason);
                (PlayerDataClass() :: { [string]: StateEngine<any> }).isKicked(true)
            end
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]