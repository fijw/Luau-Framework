--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommandsNamespace = require(ReplicatedStorage.Networking.Namespaces.Services.Commands)
local Settings = require(ReplicatedStorage.Settings)
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
    table.insert(Settings.ServerUsersWithFunCommands, targetId)

    CommandsNamespace.packets.DisplayConsoleResponse
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

        CommandsNamespace.packets.DisplayNewPermissions.sendTo(nil, targetPlayer)
        CommandsNamespace.packets.ChangeCmdPermissionsTxt.sendTo("fun_perms", targetPlayer)
    end
end

return constructorCallback
--[[ @end_section Constructor ]]