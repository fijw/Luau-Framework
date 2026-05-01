--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Components = require(script.Components)

local CommandsGroup = require(ReplicatedStorage.Networking.PacketGroups.Services.Commands)

local CmdsSettings = require(ReplicatedStorage.Settings.CmdsSettings)

local InputMapper = require(StarterPlayer.StarterPlayerScripts.Libraries.InputMapper)
--[[ @end_section Imports ]]


--[[ @section Variables ]]
local CONSOLE_TAG = "k4_fw_cmcs"
local MAX_DISPLAY_MESSAGES = 200

local localPlayer = Players.LocalPlayer :: Player
local PlayerGui = (if localPlayer then localPlayer:WaitForChild("PlayerGui") else nil) :: PlayerGui

local idPermissions = CmdsSettings.UserIdsWithCommandPermissions[localPlayer.UserId]
local rankPermissions = CmdsSettings.RanksWithCommandPermissions[localPlayer:GetRankInGroupAsync(game.CreatorId)]

local CachedResponses = {}
--[[ @end_section Variables ]]


--[[ @section Constructor ]]
--[[
    @usage Handles displaying the commands list UI.
    
    @return void
]]
local function constructorCallback()
    local currentInputBoxConnection: RBXScriptConnection?
    local currentCommandsBar: ScreenGui?
    local currentInputBox: TextBox?

    InputMapper(true, Enum.KeyCode.F2,
        function()
            if PlayerGui:FindFirstChild(Components.CommandsBar.Name) then
                if currentCommandsBar then
                    currentCommandsBar.Enabled = not currentCommandsBar.Enabled

                    if not currentCommandsBar.Enabled then
                        if currentInputBox then currentInputBox:ReleaseFocus() end
                    else
                        if currentInputBox then currentInputBox:CaptureFocus() end
                    end
                end

                return
            end

            currentCommandsBar = Components.CommandsBar:Clone()
            currentCommandsBar.Parent = PlayerGui

            local clonedMainFrame = currentCommandsBar:WaitForChild("MainFrame") :: Frame
            local clonedScrollingFrame = clonedMainFrame:WaitForChild("ScrollingFrame") :: ScrollingFrame
            local clonedInputFrame = clonedScrollingFrame:WaitForChild("InputFrame") :: Frame
            local clonedResponseTemplate = clonedScrollingFrame:WaitForChild("ResponseTemplate") :: Frame
            local clonedPermissionsTitle = clonedInputFrame:WaitForChild("PermissionsTitle") :: TextLabel
            local clonedUIListLayout = clonedScrollingFrame:WaitForChild("UIListLayout") :: UIListLayout

            if idPermissions or rankPermissions then
                clonedPermissionsTitle.Text = `{rankPermissions or idPermissions}@{CONSOLE_TAG}`
            else
                clonedPermissionsTitle.Text = `player@{CONSOLE_TAG}`
            end

            currentInputBox = clonedInputFrame:WaitForChild("InputBox") :: TextBox
            currentInputBox:CaptureFocus()

            clonedResponseTemplate.Visible = false

            -- Set up the input box and response connections.
            do
                currentInputBoxConnection = currentInputBox.FocusLost
                :Connect(
                    function(enterPressed: boolean, Input: InputObject)
                        if not enterPressed then
                            if currentCommandsBar then currentCommandsBar.Enabled = false end

                            return
                        end

                        local lowerText = if currentInputBox then currentInputBox.Text:lower() else nil

                        --[[if lowerText == "close" then
                            if currentInputBoxConnection then currentInputBoxConnection:Disconnect() end
                            if currentCommandsBar then currentCommandsBar:Destroy() end

                            --CommandsNamespace.packets.ClientDisplayConsoleResponse.disconnectAll()
                        end]]

                        local splitText = string.split(if lowerText then lowerText else "", " ")
                        CommandsGroup.HandleCommand:fireServer(splitText)

                        if currentInputBox then currentInputBox:CaptureFocus() end

                        if currentInputBox then repeat task.wait() until currentInputBox:IsFocused() end
                        if currentInputBox then currentInputBox.Text = "" end
                    end
                )

                CommandsGroup.DisplayConsoleMessage:onClientEvent(
                    function(
                        data
                        : {
                            message: string,
                            color: string
                        }
                    )
                        if #CachedResponses >= MAX_DISPLAY_MESSAGES then
                            CachedResponses[1]:Destroy()
                            table.remove(CachedResponses, 1)
                        end

                        local newResponse = clonedResponseTemplate:Clone()
                        newResponse.Visible = true
                        newResponse.Parent = clonedScrollingFrame

                        local newResponseText = newResponse:WaitForChild("TextLabel") :: TextLabel
                        newResponseText.Text = data.message

                        --[[
                            Red for errors (e.g. invalid commands or insufficient permissions),
                            yellow for tips (eg. help list), white for basic command responses,
                            and blue for important or informational responses / messages.
                        ]]
                        if data.color == "red" then
                            newResponseText.TextColor3 = Color3.fromRGB(255, 100, 100)
                        elseif data.color == "yellow" then
                            newResponseText.TextColor3 = Color3.fromRGB(255, 255, 100)
                        elseif data.color == "blue" then
                            newResponseText.TextColor3 = Color3.fromRGB(100, 100, 255)
                        elseif data.color == "white" then
                            newResponseText.TextColor3 = Color3.fromRGB(255, 255, 255)
                        end

                        table.insert(CachedResponses, newResponse)

                        clonedScrollingFrame.CanvasSize = UDim2.fromOffset(0, clonedUIListLayout.AbsoluteContentSize.Y)
                        clonedScrollingFrame.CanvasPosition = Vector2.new(0, 999999)
                    end
                )

                CommandsGroup.ChangeConsolePermissionsText:onClientEvent(
                    function(data: string)
                        if rankPermissions or idPermissions then return end
                        clonedPermissionsTitle.Text = `{data}@{CONSOLE_TAG}`
                    end
                )
            end
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]