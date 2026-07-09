--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommandsGroup = require(ReplicatedStorage.Networking.PacketGroups.Services.Commands)

local CmdsSettings = require(ReplicatedStorage.FrameworkSettings.CmdsSettings)
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

    -- Add the user to the server users with fun commands table.
    CmdsSettings.ServerUsersGivenFunCommands[targetId] = "fun_perms"

    CommandsGroup.DisplayConsoleMessage:fireClient(sender,
        {
            message = `Gave [{targetId}] access to fun commands.`,
            color = "white"
        }
    )

    -- Send a notification to the target player.
    do
        local targetPlayer = Players:GetPlayerByUserId(targetId)
        if not targetPlayer then return end

        CommandsGroup.DisplayNewPermissions:fireClient(targetPlayer)
        CommandsGroup.ChangeConsolePermissionsText:fireClient(targetPlayer, CmdsSettings.ServerUsersGivenFunCommands[targetId])
    end
end

return constructorCallback
--[[ @end_section Constructor ]]