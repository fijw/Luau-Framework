--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")

local UIComponents = require(script.Components)
--[[ @end_section Imports ]]


type ComponentsMap
= {
    areYouSure: ScreenGui,
    container: Frame,
    mainFrame: ImageLabel,
    continueBtn: ImageButton,
    cancelBtn: ImageButton,
    notificationText: TextLabel
}


local localPlayer = Players.LocalPlayer :: Player
local PlayerGui = (if localPlayer then localPlayer:WaitForChild("PlayerGui") else nil) :: PlayerGui


--[[ @section Constructor ]]
--[[
    @usage Initialize the component.
    
    @return ComponentsMap
]]
local function constructorCallback(): ComponentsMap
    local areYouSure: ScreenGui

    -- Get the pet details screen gui.
    do
        local foundAreYouSure = PlayerGui:FindFirstChild(UIComponents.AreYouSure.Name)

        if not foundAreYouSure then
            areYouSure = UIComponents.AreYouSure:Clone()
            areYouSure.Parent = PlayerGui
        else areYouSure = foundAreYouSure :: ScreenGui end
    end

    local container = areYouSure:WaitForChild("Container") :: Frame
    local mainFrame = container:WaitForChild("MainFrame") :: ImageLabel
    local buttonsContainer = mainFrame:WaitForChild("ButtonsContainer") :: Frame
    local continueBtn = buttonsContainer:WaitForChild("ContinueBtn") :: ImageButton
    local cancelBtn = buttonsContainer:WaitForChild("CancelBtn") :: ImageButton
    local notificationText = mainFrame:WaitForChild("NotificationText") :: TextLabel

    local ComponentsMap: ComponentsMap
    = {
        areYouSure = areYouSure,
        container = container,
        mainFrame = mainFrame,
        continueBtn = continueBtn,
        cancelBtn = cancelBtn,
        notificationText = notificationText
    }

    return ComponentsMap
end

return constructorCallback
--[[ @end_section Constructor ]]