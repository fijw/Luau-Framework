--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ChatTagsGroup = require(ReplicatedStorage.Networking.PacketGroups.Services.ChatTags)
--[[ @end_section Imports ]]


--[[ @section Constructor ]]
--[[
    @usage Initialize the service and manage the networking connection.

    @return void
]]
local function constructorCallback()
    ChatTagsGroup.CheckIfUserOwnsGamepass:onServerInvoke(function(sender, data): boolean return MarketplaceService:UserOwnsGamePassAsync(sender.UserId, data) end)
end

return constructorCallback
--[[ @end_section Constructor ]]