--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
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
    table.remove(CmdsSettings.serverIsLocked, table.find(CmdsSettings.serverIsLocked, true))
    table.insert(CmdsSettings.serverIsLocked, false)

    CommandsNamespace.packets.ClientDisplayConsoleResponse
    .sendTo(
        {
            response = `Unlocked the server, allowing for new players to join.`,
            color = "white"
        },
        
        sender
    )
end

return constructorCallback
--[[ @end_section Constructor ]]