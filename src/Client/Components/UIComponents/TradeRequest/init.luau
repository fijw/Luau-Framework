--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")

local UIComponents = require(script.Components)
--[[ @end_section Imports ]]


type ComponentsMap
= {
    tradeRequest: ScreenGui,
    container: Frame,
    mainFrame: ImageLabel,
    acceptBtn: ImageButton,
    declineBtn: ImageButton,
    tradeRequestText: TextLabel
}


local localPlayer = Players.LocalPlayer :: Player
local PlayerGui = (if localPlayer then localPlayer:WaitForChild("PlayerGui") else nil) :: PlayerGui


--[[ @section Constructor ]]
--[[
    @usage Initialize the component.
    
    @return void
]]
local function constructorCallback(): ComponentsMap
    local tradeRequest: ScreenGui

    -- Get the pet details screen gui.
    do
        local foundTradeRequest = PlayerGui:FindFirstChild(UIComponents.TradeRequest.Name)

        if not foundTradeRequest then
            tradeRequest = UIComponents.TradeRequest:Clone()
            tradeRequest.Parent = PlayerGui
        else tradeRequest = foundTradeRequest :: ScreenGui end
    end

    local container = tradeRequest:WaitForChild("Container") :: Frame
    local mainFrame = container:WaitForChild("MainFrame") :: ImageLabel
    local buttonsContainer = mainFrame:WaitForChild("ButtonsContainer") :: Frame
    local declineBtn = buttonsContainer:WaitForChild("DeclineBtn") :: ImageButton
    local acceptBtn = buttonsContainer:WaitForChild("AcceptBtn") :: ImageButton
    local tradeRequestText = mainFrame:WaitForChild("TradeRequestText") :: TextLabel

    local ComponentsMap: ComponentsMap
    = {
        tradeRequest = tradeRequest,
        container = container,
        mainFrame = mainFrame,
        acceptBtn = acceptBtn,
        declineBtn = declineBtn,
        tradeRequestText = tradeRequestText
    }

    return ComponentsMap
end

return constructorCallback
--[[ @end_section Constructor ]]