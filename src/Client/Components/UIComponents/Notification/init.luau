--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")

local UIComponents = require(script.Components)
--[[ @end_section Imports ]]


type ComponentsMap
= {
    notification: ScreenGui,
    container: Frame,
    mainFrame: ImageLabel,
    okayBtn: ImageButton,
    notificationText: TextLabel
}


local localPlayer = Players.LocalPlayer :: Player
local PlayerGui = (if localPlayer then localPlayer:WaitForChild("PlayerGui") else nil) :: PlayerGui


--[[ @section Constructor ]]
--[[
    @usage Initialize the component.
    
    @return void
]]
local function constructorCallback(): ComponentsMap
    local notification: ScreenGui

    -- Get the pet details screen gui.
    do
        local foundAreYouSure = PlayerGui:FindFirstChild(UIComponents.Notification.Name)

        if not foundAreYouSure then
            notification = UIComponents.Notification:Clone()
            notification.Parent = PlayerGui
        else notification = foundAreYouSure :: ScreenGui end
    end

    local container = notification:WaitForChild("Container") :: Frame
    local mainFrame = container:WaitForChild("MainFrame") :: ImageLabel
    local okayBtn = mainFrame:WaitForChild("OkayBtn") :: ImageButton
    local notificationText = mainFrame:WaitForChild("NotificationText") :: TextLabel

    local ComponentsMap: ComponentsMap
    = {
        notification = notification,
        container = container,
        mainFrame = mainFrame,
        okayBtn = okayBtn,
        notificationText = notificationText
    }

    return ComponentsMap
end

return constructorCallback
--[[ @end_section Constructor ]]