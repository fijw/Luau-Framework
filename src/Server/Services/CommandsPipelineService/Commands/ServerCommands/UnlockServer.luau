--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
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
    table.remove(CmdsSettings.serverIsLocked, table.find(CmdsSettings.serverIsLocked, true))
    table.insert(CmdsSettings.serverIsLocked, false)

    CommandsGroup.DisplayConsoleMessage:fireClient(sender,
        {
            message = `Unlocked the server, allowing for new players to join.`,
            color = "white"
        }
    )
end

return constructorCallback
--[[ @end_section Constructor ]]