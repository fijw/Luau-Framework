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
local function failedToExecute(targetId: number, sender: Player, inputText: string)
    CommandsGroup.DisplayConsoleMessage:fireClient(sender,
        {
            message = `Failed to freeze [{targetId}]. {inputText}.`,
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

        local CharacterDescendants = targetCharacter:GetDescendants()

        for i: number, child: Instance in ipairs(CharacterDescendants) do
            if not child:IsA("BasePart") or child.Anchored == true then continue end
            child.Anchored = true
        end
    end

    CommandsGroup.DisplayConsoleMessage:fireClient(sender,
        {
            message = `Froze [{targetId}].`,
            color = "white"
        }
    )
end

return constructorCallback
--[[ @end_section Constructor ]]