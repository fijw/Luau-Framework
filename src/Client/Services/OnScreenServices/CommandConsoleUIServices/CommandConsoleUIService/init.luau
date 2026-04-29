--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Components = require(script.Components)

local CommandsNamespace = require(ReplicatedStorage.Networking.Namespaces.Services.Commands)

local CmdsSettings = require(ReplicatedStorage.Settings.CmdsSettings)

local InputMapper = require(StarterPlayer.StarterPlayerScripts.Libraries.InputMapper)
--[[ @end_section Imports ]]


--[[ @section Variables ]]
local MAX_DISPLAY_MESSAGES = 200

local localPlayer = Players.LocalPlayer :: Player
local PlayerGui = (if localPlayer then localPlayer:WaitForChild("PlayerGui") else nil) :: PlayerGui

local idPermissions = CmdsSettings.UserIdsWithCommandPermissions[localPlayer.UserId]
local rankPermissions = CmdsSettings.RanksWithCommandPermissions[localPlayer:GetRankInGroupAsync(game.CreatorId)]
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
                clonedPermissionsTitle.Text = `{rankPermissions or idPermissions}@cmcs`
            else
                clonedPermissionsTitle.Text = "player@cmcs"
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

                        if lowerText == "close" then
                            if currentInputBoxConnection then currentInputBoxConnection:Disconnect() end
                            if currentCommandsBar then currentCommandsBar:Destroy() end

                            CommandsNamespace.packets.ClientDisplayConsoleResponse.disconnectAll()
                        end

                        local splitText = string.split(if lowerText then lowerText else "", " ")
                        CommandsNamespace.packets.ServerHandleCommand.send(splitText)

                        if currentInputBox then currentInputBox:CaptureFocus() end

                        if currentInputBox then repeat task.wait() until currentInputBox:IsFocused() end
                        if currentInputBox then currentInputBox.Text = "" end
                    end
                )

                CommandsNamespace.packets.ClientDisplayConsoleResponse
                .listen(
                    function(
                        data
                        : {
                            response: string,
                            color: string
                        }
                    )
                        -- If the scrolling frame has too many responses, remove the oldest one.
                        do
                            local ScrollerChildrenArray = clonedScrollingFrame:GetChildren()

                            if #ScrollerChildrenArray >= (MAX_DISPLAY_MESSAGES + 2) then
                                for i: number, child: Instance in ipairs(ScrollerChildrenArray) do
                                    if child.Name ~= "ResponseTemplate" then continue end
                                    child:Destroy(); child.Parent = nil; break
                                end
                            end
                        end

                        local newResponse = clonedResponseTemplate:Clone()
                        newResponse.Visible = true
                        newResponse.Parent = clonedScrollingFrame

                        local newResponseText = newResponse:WaitForChild("TextLabel") :: TextLabel
                        newResponseText.Text = data.response

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

                        clonedScrollingFrame.CanvasSize = UDim2.fromOffset(0, clonedUIListLayout.AbsoluteContentSize.Y)
                        clonedScrollingFrame.CanvasPosition = Vector2.new(0, 999999)
                    end
                )

                CommandsNamespace.packets.ClientChangeCmdPermissionsTxt
                .listen(
                    function(data: string)
                        if rankPermissions or idPermissions then return end
                        
                        clonedPermissionsTitle.Text = `{data}@k4_fw_cmcs`
                    end
                )
            end
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]