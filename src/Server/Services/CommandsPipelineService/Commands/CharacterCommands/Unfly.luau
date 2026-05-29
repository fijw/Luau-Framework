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
            message = `Failed to take away [{targetId}]'s flying abilities. {inputText}.`,
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

    -- Anchor the player's character.
    do
        local targetPlayer = Players:GetPlayerByUserId(targetId)
        if not targetPlayer then failedToExecute(targetId, sender, "Target player not found"); return end

        CommandsGroup.UnflyCharacter:fireClient(targetPlayer)
    end

    CommandsGroup.DisplayConsoleMessage:fireClient(sender,
        {
            message = `Stopped [{targetId}]'s flying abilities.`,
            color = "white"
        }
    )
end

return constructorCallback
--[[ @end_section Constructor ]]