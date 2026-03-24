--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommandsNamespace = require(ReplicatedStorage.Networking.Namespaces.Services.Commands)
--[[ @end_section Imports ]]


local PLACE_ID = game.PlaceId


--[[ @section Constructor ]]
--[[
    @usage Initialize the command.

    @param sender Player
    @param args { string }

    @return void
]]
local function constructorCallback(sender: Player, args: { string })
    local reservedCode = TeleportService:ReserveServerAsync(PLACE_ID)
    TeleportService:TeleportToPrivateServer(PLACE_ID, reservedCode, { sender })

    CommandsNamespace.packets.DisplayConsoleResponse
    .sendTo(
        {
            response = `Attempting to join reserved server [{reservedCode}].`,
            color = "white"
        },
        
        sender
    )
end

return constructorCallback
--[[ @end_section Constructor ]]