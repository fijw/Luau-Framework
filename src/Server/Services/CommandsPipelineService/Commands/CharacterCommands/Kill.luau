--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
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

    -- Kill the player's character.
    do
        local targetPlayer = Players:GetPlayerByUserId(targetId)
        if not targetPlayer then return end

        local targetCharacter = targetPlayer.Character
        if not targetCharacter then return end

        local charHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
        if not charHumanoid then return end

        charHumanoid.Health = 0
    end

    CommandsNamespace.packets.DisplayConsoleResponse
    .sendTo(
        {
            response = `Killed [{targetId}].`,
            color = "white"
        },
        
        sender
    )
end

return constructorCallback
--[[ @end_section Constructor ]]