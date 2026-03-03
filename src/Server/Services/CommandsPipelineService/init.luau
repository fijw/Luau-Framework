--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local KickModule = require(script.Moderation.Kick)
local BanModule = require(script.Moderation.Ban)
local UnbanModule = require(script.Moderation.Unban)

local ChatCommandsNamespace = require(ReplicatedStorage.Networking.Namespaces.Services.ChatCommands)
--[[ @end_section Imports ]]


local CommandCallbackMap: { [string]: (sender: Player, Args: { string }) -> () }
= {
    ban = BanModule,
    kick = KickModule,
    unban = UnbanModule
}


--[[ @section Constructor ]]
--[[
    @usage Initialize the service.

    @return
]]
local function constructorCallback()
    ChatCommandsNamespace.packets.ServerHandleCommandMessage
    .listen(
        function(data: { string }, player: Player?)
            if not player then return end

            local commandCallback = CommandCallbackMap[data[1]]
            if not commandCallback then return end

            table.remove(data, 1)

            commandCallback(player, data)
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]