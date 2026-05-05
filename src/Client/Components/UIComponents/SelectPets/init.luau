--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")

local UIComponents = require(script.Components)
--[[ @end_section Imports ]]


type ComponentsMap
= {
    selectPets: ScreenGui,
    textBox: TextBox,
    closeBtn: ImageButton,
    continueBtn: ImageButton,
    scrollingFrame: ScrollingFrame,
    uiListLayout: UIListLayout,
    expandBtn: ImageButton,
    defaultPetButton: ImageLabel,
    hugePetButton: ImageLabel,
    giganticPetButton: ImageLabel
}


local localPlayer = Players.LocalPlayer :: Player
local PlayerGui = (if localPlayer then localPlayer:WaitForChild("PlayerGui") else nil) :: PlayerGui


--[[ @section Constructor ]]
local function constructorCallback()--: ComponentsMap
    local selectPets: ScreenGui

    -- Get the pet details screen gui.
    do
        local foundSelectPets = PlayerGui:FindFirstChild(UIComponents.SelectPets.Name)

        if not foundSelectPets then
            selectPets = UIComponents.SelectPets:Clone()
            selectPets.Parent = PlayerGui
        else selectPets = foundSelectPets :: ScreenGui end
    end

    local container = selectPets:WaitForChild("Container") :: Frame
    local searchBox = container:WaitForChild("SearchBox") :: Frame
    local frameBox = searchBox:WaitForChild("FrameBox") :: ImageLabel
    local textBox = frameBox:WaitForChild("TextBox") :: TextBox
    local closeBtn = container:WaitForChild("CloseBtn") :: ImageButton
    local continueBtn = container:WaitForChild("ContinueBtn") :: ImageButton
    local mainFrame = container:WaitForChild("MainFrame") :: ImageLabel
    local scrollingFrame = mainFrame:WaitForChild("ScrollingFrame") :: ScrollingFrame
    local defaultPetButton = scrollingFrame:WaitForChild("Default") :: ImageLabel
    local hugePetButton = scrollingFrame:WaitForChild("Huge") :: ImageLabel
    local giganticPetButton = scrollingFrame:WaitForChild("Gigantic") :: ImageLabel
    local uiListLayout = scrollingFrame:WaitForChild("UIListLayout") :: UIListLayout
    local expandBtn = container:WaitForChild("ExpandBtn") :: ImageButton

    local ComponentsMap: ComponentsMap
    = {
        selectPets = selectPets,
        textBox = textBox,
        closeBtn = closeBtn,
        continueBtn = continueBtn,
        scrollingFrame = scrollingFrame,
        uiListLayout = uiListLayout,
        expandBtn = expandBtn,
        defaultPetButton = defaultPetButton,
        hugePetButton = hugePetButton,
        giganticPetButton = giganticPetButton
    }

    return ComponentsMap
end

return constructorCallback
--[[ @end_section Constructor ]]