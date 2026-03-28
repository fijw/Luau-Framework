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
    Settings.serverIsLocked = true

    -- Prevent new players from joining with a player added connection.
    do
        local connection: RBXScriptConnection

        local function onPlayerAdded(player: Player)
            if Settings.serverIsLocked == false then connection:Disconnect(); return end

            player:Kick("\n\nThis server is locked.\n\n\n")
        end

        connection = Players.PlayerAdded:Connect(onPlayerAdded)
    end

    CommandsNamespace.packets.ClientDisplayConsoleResponse
    .sendTo(
        {
            response = `Locked the server, stopping it from receiving new players.`,
            color = "white"
        },
        
        sender
    )
end

return constructorCallback
--[[ @end_section Constructor ]]