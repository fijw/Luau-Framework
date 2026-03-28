--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

local Settings = require(ReplicatedStorage.Settings)

local CommandsNamespace = require(ReplicatedStorage.Networking.Namespaces.Services.Commands)
--[[ @end_section Imports ]]


--[[ @section Variables ]]
local CREATOR_ID = game.CreatorId

local localPlayer = Players.LocalPlayer :: Player
--[[ @end_section Variables ]]


--[[ @section Constructor ]]
--[[
    @usage Displays a message to players with permissions.
    
    @return void
]]
local function constructorCallback()
    local playerRank = localPlayer:GetRankInGroupAsync(CREATOR_ID)

    local rankPermissions = Settings.ChatSettings.ChatCommandSettings.RanksWithCommandPermissions[playerRank]
    local idPermissions = Settings.ChatSettings.ChatCommandSettings.UserIdsWithCommandPermissions[localPlayer.UserId]

    if not rankPermissions and not idPermissions then
        CommandsNamespace.packets.ClientDisplayNewPermissions
        .listenOnce(
            function(data: nil)
                StarterGui:SetCore("SendNotification",
                    {
                        Title = "You have permissions for commands.",
                        Text = 'Press "F2" to use commands.\nEnter "help" for a list of commands.',

                        Duration = 10
                    }
                )
            end
        )

        return
    end

    -- Send permissions notification once the experience is loaded.
    do
        repeat task.wait() until not localPlayer.PlayerGui:FindFirstChild("LoadingGui")

        StarterGui:SetCore("SendNotification",
            {
                Title = "You have permissions for commands.",
                Text = 'Press "F2" to use commands.\nEnter "help" for a list of commands.',

                Duration = 10
            }
        )
    end
end

return constructorCallback
--[[ @end_section Constructor ]]