--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

    -- If the player the sender's trying to join is joinable, teleport the sender.
    do
        local isHere, _currentInstance, placeId, jobId = TeleportService:GetPlayerPlaceInstanceAsync(targetId)
        if isHere then return end

        TeleportService:TeleportToPlaceInstance(placeId, jobId, sender)
    end

    CommandsNamespace.packets.DisplayConsoleResponse
    .sendTo(
        {
            response = `Attempting to join [{targetId}]'s server.`,
            color = "white"
        },
        
        sender
    )
end

return constructorCallback
--[[ @end_section Constructor ]]