--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommandsGroup = require(ReplicatedStorage.Networking.PacketGroups.Services.Commands)
--[[ @end_section Imports ]]


--[[ @section Constructor ]]
--[[
    @usage Initialize the command.

    @param sender Player
    @param args { string }

    @return void
]]
local function constructorCallback(sender: Player, args: { string })
    local code = TeleportService:ReserveServerAsync(game.PlaceId)
    TeleportService:TeleportToPrivateServer(game.PlaceId, code, { sender })

    CommandsGroup.DisplayConsoleMessage:fireClient(sender,
        {
            message = `Attempting to join reserved server [{code}].`,
            color = "white"
        }
    )
end

return constructorCallback
--[[ @end_section Constructor ]]