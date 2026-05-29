--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommandsGroup = require(ReplicatedStorage.Networking.PacketGroups.Services.Commands)
--[[ @end_section Imports ]]


--[[ @section Constructor ]]
--[[
    @usage Initialize the command.

    @param sender Player
    @param args { string }

    @return void
]]
local function constructorCallback(sender: Player, args: { string }): ()
    local reason = table.concat(args, " ")

    CommandsGroup.DisplayConsoleMessage:fireClient(sender,
        {
            message = `Shutting down the server.`,
            color = "white"
        }
    )

    for i: number, player: Player in ipairs(Players:GetPlayers()) do
        player:Kick(`\n\nThe server has been shut down.\n\nReason: "{reason}".\n\n\n`)
    end
end

return constructorCallback
--[[ @end_section Constructor ]]