--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommandsNamespace = require(ReplicatedStorage.Networking.Namespaces.Services.Commands)
local CmdsSettings = require(ReplicatedStorage.Settings.CmdsSettings)
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

    CommandsNamespace.packets.ClientDisplayConsoleResponse
    .sendTo(
        {
            response = `Gave [{targetId}] access to fun commands.`,
            color = "white"
        },
        
        sender
    )

    -- Send a notification to the target player.
    do
        local targetPlayer = Players:GetPlayerByUserId(targetId)
        if not targetPlayer then return end

        CommandsNamespace.packets.ClientDisplayNewPermissions.sendTo(nil, targetPlayer)
        CommandsNamespace.packets.ClientChangeCmdPermissionsTxt.sendTo(CmdsSettings.ServerUsersGivenFunCommands[targetId], targetPlayer)
    end
end

return constructorCallback
--[[ @end_section Constructor ]]