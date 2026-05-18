--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")

local UIComponents = require(script.Components)
--[[ @end_section Imports ]]


type ComponentsMap
= {
    mainFrame: ImageLabel,
    colorText: TextLabel,
    rarityFrame: ImageLabel,
    rarityText: TextLabel,
    sizeText: TextLabel,
    healthText: TextLabel,
    dmgText: TextLabel,
    tradeableText: TextLabel,
    petName: TextLabel
}


local localPlayer = Players.LocalPlayer :: Player
local PlayerGui = (if localPlayer then localPlayer:WaitForChild("PlayerGui") else nil) :: PlayerGui


--[[ @section Constructor ]]
--[[
    @usage Initialize the component.
    
    @return void
]]
local function constructorCallback(): ComponentsMap
    local petDetails: ScreenGui

    -- Get the pet details screen gui.
    do
        local foundPetDetails = PlayerGui:FindFirstChild(UIComponents.PetDetails.Name)

        if not foundPetDetails then
            petDetails = UIComponents.PetDetails:Clone()
            petDetails.Parent = PlayerGui
        else petDetails = foundPetDetails :: ScreenGui end
    end

    local mainFrame = petDetails:WaitForChild("MainFrame") :: ImageLabel
    local innerContainer = mainFrame:WaitForChild("InnerContainer") :: Frame
    local detailsContainer = innerContainer:WaitForChild("DetailsContainer") :: Frame
    local color = detailsContainer:WaitForChild("ColorContainer") :: ImageLabel
    local colorText = color:WaitForChild("TextLabel") :: TextLabel
    local rarity = innerContainer:WaitForChild("RarityFrame") :: ImageLabel
    local rarityText = rarity:WaitForChild("TextLabel") :: TextLabel
    local size = detailsContainer:WaitForChild("SizeContainer") :: ImageLabel
    local sizeText = size:WaitForChild("TextLabel") :: TextLabel
    local statsContainer = innerContainer:WaitForChild("StatsContainer") :: Frame
    local dmgContainer = statsContainer:WaitForChild("DmgContainer") :: Frame
    local healthContainer = statsContainer:WaitForChild("HealthContainer") :: Frame
    local tradeableContainer = innerContainer:WaitForChild("TradeableContainer") :: Frame
    local dmgText = dmgContainer:WaitForChild("TextLabel") :: TextLabel
    local healthText = healthContainer:WaitForChild("TextLabel") :: TextLabel
    local tradeableText = tradeableContainer:WaitForChild("TextLabel") :: TextLabel
    local petName = innerContainer:WaitForChild("PetName") :: TextLabel

    local ComponentsMap: ComponentsMap
    = {
        mainFrame = mainFrame,
        rarityFrame = rarity,
        colorText = colorText,
        rarityText = rarityText,
        sizeText = sizeText,
        dmgText = dmgText,
        healthText = healthText,
        tradeableText = tradeableText,
        petName = petName
    }

    return ComponentsMap
end

return constructorCallback
--[[ @end_section Constructor ]]