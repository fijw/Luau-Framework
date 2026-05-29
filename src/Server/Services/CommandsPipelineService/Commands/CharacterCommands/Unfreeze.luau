--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommandsGroup = require(ReplicatedStorage.Networking.PacketGroups.Services.Commands)
--[[ @end_section Imports ]]


--[[
    @usage Display a failed message to the console.

    @param targetId number
    @param sender Player
    @param inputText string

    @return void
]]
local function failedToExecute(targetId: number, sender: Player, inputText: string): ()
    CommandsGroup.DisplayConsoleMessage:fireClient(sender,
        {
            message = `Failed to unfreeze [{targetId}]. {inputText}.`,
            color = "red"
        }
    )
end


--[[ @section Constructor ]]
--[[
    @usage Initialize the command.

    @param sender Player
    @param args { string }

    @return void
]]
local function constructorCallback(sender: Player, args: { string }): ()
    local targetId = tonumber(args[1]) :: number
    if not targetId then return end

    table.remove(args, 1)

    -- Unanchor the player's character.
    do
        local targetPlayer = Players:GetPlayerByUserId(targetId)
        if not targetPlayer then failedToExecute(targetId, sender, "Target player not found"); return end

        local targetCharacter = targetPlayer.Character
        if not targetCharacter then failedToExecute(targetId, sender, "Target character not found"); return end

        local CharacterDescendants = targetCharacter:GetDescendants()

        for i: number, child: Instance in ipairs(CharacterDescendants) do
            if not child:IsA("BasePart") or child.Anchored == false then continue end
            child.Anchored = false
        end
    end

    CommandsGroup.DisplayConsoleMessage:fireClient(sender,
        {
            message = `Unfroze [{targetId}].`,
            color = "white"
        }
    )
end

return constructorCallback
--[[ @end_section Constructor ]]