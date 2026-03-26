--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommandsNamespace = require(ReplicatedStorage.Networking.Namespaces.Services.Commands)
--[[ @end_section Imports ]]


--[[
    @usage Display a failed message to the console.

    @param targetId number
    @param sender Player
    @param inputText string

    @return void
]]
local function failedToExecute(targetId: number, sender: Player, inputText: string)
    CommandsNamespace.packets.DisplayConsoleResponse
    .sendTo(
        {
            response = `Failed to change [{targetId}]'s speed. {inputText}.`,
            color = "red"
        },
        
        sender
    )
end


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

    -- Anchor the player's character.
    do
        local targetPlayer = Players:GetPlayerByUserId(targetId)
        if not targetPlayer then failedToExecute(targetId, sender, "Target player not found"); return end

        local targetCharacter = targetPlayer.Character
        if not targetCharacter then failedToExecute(targetId, sender, "Target character not found"); return end

        local humanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
        if not humanoid then failedToExecute(targetId, sender, "Target humanoid not found"); return end

        humanoid.WalkSpeed = tonumber(args[1]) :: number
    end

    CommandsNamespace.packets.DisplayConsoleResponse
    .sendTo(
        {
            response = `Changed [{targetId}]'s speed to {args[1]}.`,
            color = "white"
        },
        
        sender
    )
end

return constructorCallback
--[[ @end_section Constructor ]]