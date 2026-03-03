--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local ChatCommandsNamespace = require(ReplicatedStorage.Networking.Namespaces.Services.ChatCommands)
--[[ @end_section Imports ]]


--[[ @section Variables ]]
local PREFIX = "do/"

local ChatCmdsService = {}
--[[ @end_section Variables ]]


--[[ @section Constructor ]]
--[[
    @usage Initialize the service.

    @return
]]
local function constructorCallback()
    TextChatService.OnChatWindowAdded
    = function(message: TextChatMessage)
        if not message.TextSource then return end

        local text = string.lower(message.Text)
        if text:sub(1, #PREFIX) ~= PREFIX then return end

        local args = text:sub(#PREFIX + 1):split("/")
        ChatCommandsNamespace.packets.ServerHandleCommandMessage.send(args)
    end
end

setmetatable(ChatCmdsService, { __call = constructorCallback })
--[[ @end_section Constructor ]]


table.freeze(ChatCmdsService)
return ChatCmdsService