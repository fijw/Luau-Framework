--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ServerScriptService = game:GetService("ServerScriptService")
local MessagingService = game:GetService("MessagingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Compression = require(ServerScriptService.Libraries.Compression)

local CommandsNamespace = require(ReplicatedStorage.Networking.Namespaces.Services.Commands)
--[[ @end_section Imports ]]


--[[ @section Constructor ]]
--[[
    @usage Initialize the command.

    @param sender Player
    @param args { string }

    @return void
]]
local function constructorCallback(sender: Player, args: { string })
    local targetId = tonumber(args[1]) :: number
    if not targetId then return end

    table.remove(args, 1)

    MessagingService:PublishAsync("commands",
        Compression(
            {
                targetId = tonumber(targetId) :: number,
                commandType = "bring_player_to_server",
                senderId = sender.UserId
            }
        )
    )

    CommandsNamespace.packets.DisplayConsoleResponse
    .sendTo(
        {
            response = `Sent a global request to bring [{targetId}] to this server.`,
            color = "white"
        },
        
        sender
    )
end

return constructorCallback
--[[ @end_section Constructor ]]