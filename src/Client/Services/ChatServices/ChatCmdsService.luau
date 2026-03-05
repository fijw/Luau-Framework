--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local ChatCommandsNamespace = require(ReplicatedStorage.Networking.Namespaces.Services.ChatCommands)
--[[ @end_section Imports ]]


local PREFIX = "do/"


--[[ @section Constructor ]]
--[[
    @usage Initialize the service.

    @return void
]]
local function constructorCallback()
    local cmdDuplicatePreventionCount = 0

    TextChatService.OnIncomingMessage
    = function(message: TextChatMessage)
        if not message.TextSource then return end

        -- Prevent duplicate commands by not handling the duplicate signal.
        do
            cmdDuplicatePreventionCount += 1
            if cmdDuplicatePreventionCount == 2 then cmdDuplicatePreventionCount = 0; return end
        end

        local text = string.lower(message.Text)
        if text:sub(1, #PREFIX) ~= PREFIX then return end

        local Args = text:sub(#PREFIX + 1):split("/")
        ChatCommandsNamespace.packets.ServerHandleCommandMessage.send(Args)
    end
end

return constructorCallback
--[[ @end_section Constructor ]]