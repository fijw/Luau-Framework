--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommandsNamespace = require(ReplicatedStorage.Networking.Namespaces.Services.Commands)
--[[ @end_section Imports ]]


--[[ @section Constructor ]]
--[[
    @usage Handles the flying packets sent by the server.
    
    @return void
]]
local function constructorCallback()
    CommandsNamespace.packets.ClientSpectateTarget
    .listen(
        function(data: string)
            local targetPlayer = Players:GetPlayerByUserId(tonumber(data) :: number)
            if not targetPlayer then return end

            local targetCharacter = targetPlayer.Character
            if not targetCharacter then return end

            local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
            if not targetHumanoid then return end

            workspace.CurrentCamera.CameraSubject = targetHumanoid
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]