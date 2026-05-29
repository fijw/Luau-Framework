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
local function constructorCallback(sender: Player, args: { string }): ()
    table.remove(CmdsSettings.serverIsLocked, table.find(CmdsSettings.serverIsLocked, false))
    table.insert(CmdsSettings.serverIsLocked, true)

    -- Prevent new players from joining with a player added connection.
    do
        local connection: RBXScriptConnection

        local function onPlayerAdded(player: Player): ()
            if not table.find(CmdsSettings.serverIsLocked, true) then connection:Disconnect(); return end

            player:Kick("\n\nThis server is locked.\n\n\n")
        end

        connection = Players.PlayerAdded:Connect(onPlayerAdded)
    end

    CommandsGroup.DisplayConsoleMessage:fireClient(sender,
        {
            message = `Locked the server, stopping it from receiving new players.`,
            color = "white"
        }
    )
end

return constructorCallback
--[[ @end_section Constructor ]]