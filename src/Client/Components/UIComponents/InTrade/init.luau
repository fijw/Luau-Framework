--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local TradingGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.Trading)

local UIComponents = require(script.Components)
local PetDetailsComponents = require(StarterPlayer.StarterPlayerScripts.Components.UIComponents.PetDetails)

local UIUtilitiesLibrary = require(StarterPlayer.StarterPlayerScripts.Libraries.UILib)
local TweensLib = require(ReplicatedStorage.Libraries.TweensLib)

local Data = require(ReplicatedStorage.Assets.Pets.Data)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type PetSizeTypes = "Default" | "Huge" | "Gigantic"
type PetSchema = Data.PetSchema

type HandledTween = TweensLib.HandledTween
type HandledUI = UIUtilitiesLibrary.HandledUI
--[[ @end_section Types ]]


--[[ @section Variables ]]
local localPlayer = Players.LocalPlayer :: Player
local PlayerGui = (if localPlayer then localPlayer:WaitForChild("PlayerGui") else nil) :: PlayerGui
local PlrMouse = (if localPlayer then localPlayer:GetMouse() else nil) :: Mouse

local YourCachedPetButtons: { [string]: ImageLabel } = {}
local TheirCachedPetButtons: { [string]: ImageLabel } = {}

local SelectedPetsCache: { string } = {}
--[[ @end_section Variables ]]


--[[ @section Utility Functions ]]
--[[
    @usage Tweens an instance.

    @param inst GuiObject
    @param timeInput number
    @param type "pos" | "trans"
    @param input number | UDim2

    @return HandledTween
]]
local function tweenInst(inst: GuiObject, timeInput: number, type: "pos" | "trans" | "size", input: number | UDim2): HandledTween
    local HandledTween
    = TweensLib(
        inst,


        timeInput,

        Enum.EasingStyle.Sine,
        Enum.EasingDirection.Out,

        0,
        false,
        0,


        {
            Position = if type == "pos" then input else nil,
            ImageTransparency = if type == "trans" then input else nil,
            Size = if type == "size" then input else nil
        }
    )

    return HandledTween
end

--[[
    @usage Creates a tick for a pet.

    @param petLabel ImageLabel

    @return void
]]
local function createTick(petLabel: ImageLabel, type: "lock" | "delete" | "selected")
    local newTick = Instance.new("ImageLabel")
    newTick.Image = if type == "lock" then "rbxassetid://138368172974659" elseif type == "delete" then "rbxassetid://138335893507994" else "rbxassetid://120401071933338"
    newTick.BackgroundTransparency = 1
    newTick.BorderSizePixel = 0
    newTick.Position = UDim2.new(0, 0, 0, 0)
    newTick.Size = UDim2.new(0.35, 0, 0.35, 0)
    newTick.Name = if type == "lock" then "LockTick" elseif type == "delete" then "DeleteTick" else "SelectedTick"
    newTick.ZIndex = 3
    newTick.Parent = petLabel
end

--[[
    @usage Adds a pet to the trade.

    @param side "yours" | "theirs"
    @param Pet PetSchema
    @param id string
    @param theirScrollingFrame ScrollingFrame
    @param yourScrollingFrame ScrollingFrame
    @param theirDefaultPet ImageLabel
    @param theirHugePet ImageLabel
    @param theirGiganticPet ImageLabel
    @param yourDefaultPet ImageLabel
    @param yourHugePet ImageLabel
    @param yourGiganticPet ImageLabel

    @return void
]]
local function addPetToTrade
(
    side: "yours" | "theirs",
    Pet: PetSchema,
    id: string,
    theirScrollingFrame: ScrollingFrame,
    yourScrollingFrame: ScrollingFrame,
    theirDefaultPet: ImageLabel,
    theirHugePet: ImageLabel,
    theirGiganticPet: ImageLabel,
    yourDefaultPet: ImageLabel,
    yourHugePet: ImageLabel,
    yourGiganticPet: ImageLabel,
    HandledUI: HandledUI
)
    local newPetLabel: ImageLabel

    if side == "yours" then
        if Pet.PetStats.size == "Gigantic" then
            newPetLabel = theirGiganticPet:Clone()
        elseif Pet.PetStats.size == "Huge" then
            newPetLabel = theirHugePet:Clone()
        else
            newPetLabel = theirDefaultPet:Clone()
        end
    else
        if Pet.PetStats.size == "Gigantic" then
            newPetLabel = yourGiganticPet:Clone()
        elseif Pet.PetStats.size == "Huge" then
            newPetLabel = yourHugePet:Clone()
        else
            newPetLabel = yourDefaultPet:Clone()
        end
    end

    newPetLabel.Name = id
    newPetLabel.Visible = true
    newPetLabel.ImageColor3 = Color3.fromRGB(0, 155, 202)

    if side == "yours" then newPetLabel.Parent = yourScrollingFrame else newPetLabel.Parent = theirScrollingFrame end
    if Pet.locked then if table.find(Pet.locked, id) then createTick(newPetLabel, "lock") end end

    local innerImgButton = Instance.new("ImageButton")
    innerImgButton.AnchorPoint = Vector2.new(0.5, 0.5)
    innerImgButton.Position = UDim2.fromScale(0.5, 0.5)
    innerImgButton.Parent = newPetLabel
    innerImgButton.BackgroundTransparency = 0
    innerImgButton.BackgroundColor3 = Color3.fromRGB(161, 0, 0)
    innerImgButton.BorderSizePixel = 0
    innerImgButton.ZIndex = 2
    innerImgButton.Size = UDim2.fromScale(0.85, 0.85)
    innerImgButton.Image = Pet.petImageId

    TheirCachedPetButtons[id] = newPetLabel

    -- Hovering.
    do
        local isHovering = false

        HandledUI:handleGuiObjectInput(innerImgButton.MouseEnter,
            function()
                isHovering = true

                PetDetailsComponents().mainFrame.Visible = true
                PetDetailsComponents().petName.Text = Pet.petName
                PetDetailsComponents().healthText.Text = `{Pet.GameplayStats.petHealth}/{Pet.GameplayStats.maxHealth}`
                PetDetailsComponents().dmgText.Text = `{Pet.GameplayStats.attackDamage}`
                PetDetailsComponents().colorText.Text = Pet.PetStats.color
                PetDetailsComponents().sizeText.Text = Pet.PetStats.size
                PetDetailsComponents().rarityText.Text = Pet.PetStats.rarity

                while true do
                    if not isHovering then break else task.wait() end
                    PetDetailsComponents().mainFrame.Position = UDim2.new(0, PlrMouse.X - PetDetailsComponents().mainFrame.AbsoluteSize.X, 0, PlrMouse.Y)
                end
            end
        )

        HandledUI:handleGuiObjectInput(innerImgButton.MouseLeave,
            function()
                isHovering = false
                PetDetailsComponents().mainFrame.Visible = false
            end
        )

        HandledUI:handleButtonPress(innerImgButton,
            function(pos1: number, pos2: number)
                if side == "theirs" then return end

                local foundIndex = table.find(SelectedPetsCache, id)
                
                if foundIndex then
                    table.remove(SelectedPetsCache, foundIndex)
                    TradingGroup.RemovePetFromTradeOffer:fireServer(id)

                    local foundSelectedTick = newPetLabel:FindFirstChild("SelectedTick")
                    if foundSelectedTick then foundSelectedTick:Destroy() end
                else
                    table.insert(SelectedPetsCache, id)
                    TradingGroup.AddPetToTradeOffer:fireServer(id)

                    createTick(newPetLabel, "selected")
                end
            end
        )
    end
end
--[[ @end_section Utility Functions ]]


--[[ @section Constructor ]]
--[[
    @usage Initialize the component.
    
    @return void
]]
local function constructorCallback()
    local clonedInTrade = UIComponents.InTrade:Clone()
    clonedInTrade.Parent = PlayerGui

    local containerFrame = clonedInTrade:WaitForChild("Container") :: Frame
    local mainFrame = containerFrame:WaitForChild("MainFrame") :: ImageLabel
    local expandBtn = containerFrame:WaitForChild("ExpandBtn") :: ImageButton
    local innerContainer = mainFrame:WaitForChild("InnerContainer") :: Frame
    local mainOfferContainer = innerContainer:WaitForChild("MainOfferContainer") :: Frame
    local mainOfferInnerContainer = mainOfferContainer:WaitForChild("InnerContainer") :: Frame
    local gemsOfferContainer = innerContainer:WaitForChild("GemsOfferContainer") :: Frame
    local yourGemsOffer = gemsOfferContainer:WaitForChild("YourGemsOffer") :: Frame
    local yourAmountBox = yourGemsOffer:WaitForChild("AmountBox") :: ImageLabel
    local yourTextBox = yourAmountBox:WaitForChild("TextBox") :: TextBox
    local theirGemsOffer = gemsOfferContainer:WaitForChild("TheirGemsOffer") :: Frame
    local theirGemsFrame = theirGemsOffer:WaitForChild("Frame") :: Frame
    local theirGemsText = theirGemsFrame:WaitForChild("TextLabel") :: TextLabel
    local theirSide = mainOfferInnerContainer:WaitForChild("TheirSide") :: ImageLabel
    local yourSide = mainOfferInnerContainer:WaitForChild("YourSide") :: ImageLabel
    local theirScrollingFrame = theirSide:WaitForChild("ScrollingFrame") :: ScrollingFrame
    local yourScrollingFrame = yourSide:WaitForChild("ScrollingFrame") :: ScrollingFrame
    local yourDefaultPet = yourScrollingFrame:WaitForChild("Default") :: ImageLabel
    local yourHugePet = yourScrollingFrame:WaitForChild("Huge") :: ImageLabel
    local yourGiganticPet = yourScrollingFrame:WaitForChild("Gigantic") :: ImageLabel
    local theirDefaultPet = theirScrollingFrame:WaitForChild("Default") :: ImageLabel
    local theirHugePet = theirScrollingFrame:WaitForChild("Huge") :: ImageLabel
    local theirGiganticPet = theirScrollingFrame:WaitForChild("Gigantic") :: ImageLabel
    local searchBoxesContainer = mainOfferContainer:WaitForChild("SearchBoxesContainer") :: Frame
    local theirSearchBox = searchBoxesContainer:WaitForChild("TheirSearchBox") :: Frame
    local yourSearchBox = searchBoxesContainer:WaitForChild("YourSearchBox") :: Frame
    local theirSearchBoxFrame = theirSearchBox:WaitForChild("SearchBoxFrame") :: Frame
    local yourSearchBoxFrame = yourSearchBox:WaitForChild("SearchBoxFrame") :: Frame
    local theirSearchTextBox = theirSearchBoxFrame:WaitForChild("TextBox") :: TextBox
    local yourSearchTextBox = yourSearchBoxFrame:WaitForChild("TextBox") :: TextBox
    local yourUiListLayout = yourScrollingFrame:WaitForChild("UIListLayout") :: UIListLayout
    local theirUiListLayout = theirScrollingFrame:WaitForChild("UIListLayout") :: UIListLayout

    local HandledUI = UIUtilitiesLibrary("in_trade", clonedInTrade)
    HandledUI:hoverAndToggleSizing(1.15)

    -- Networking connections.
    do
        TradingGroup.AcceptTradeRequest:onClientEvent(
            function(data)
                HandledUI:setFocus({ "AreYouSure", "Notification", "TradeRequest" })
            end
        )

        TradingGroup.AddPetToTradeOffer:onClientEvent(
            function(data)
                addPetToTrade(
                    "theirs",
                    data.PetData,
                    data.petId,
                    theirScrollingFrame,
                    yourScrollingFrame,
                    theirDefaultPet,
                    theirHugePet,
                    theirGiganticPet,
                    yourDefaultPet,
                    yourHugePet,
                    yourGiganticPet,
                    HandledUI
                )
            end
        )

        TradingGroup.RemovePetFromTradeOffer:onClientEvent(
            function(data)
                TheirCachedPetButtons[data]:Destroy()
                TheirCachedPetButtons[data] = nil
            end
        )

        TradingGroup.SetGemsInTradeOffer:onClientEvent(function(data) theirGemsText.Text = `{data}` end)
    end

    -- Animations for closing and opening.
    do
        local originalContainerSize = containerFrame.Size

        HandledUI:subscribeToSetFocus("opening_subscription",
            function(self, NamesKeepingFocus)
                containerFrame.Size = UDim2.new(0, 0, 0, 0)

                tweenInst(
                    containerFrame,
                    
                    0.25,
                    "size",

                    originalContainerSize
                )

                for i: string, Pet: PetSchema in pairs(TradingGroup.RequestOwnedPetsForTrade:invokeServer()) do
                    addPetToTrade(
                        "yours",
                        Pet,
                        i,
                        theirScrollingFrame,
                        yourScrollingFrame,
                        theirDefaultPet,
                        theirHugePet,
                        theirGiganticPet,
                        yourDefaultPet,
                        yourHugePet,
                        yourGiganticPet,
                        HandledUI
                    )
                end
            end
        )

        HandledUI:subscribeToRemoveFocus("closing_subscription",
            function(self, NamesToBringBackToFocus)
                tweenInst(
                    containerFrame,
                    
                    0.25,
                    "size",

                    UDim2.new(0, 0, 0, 0)
                ):waitForCompletion()

                yourSearchTextBox.Text = ""
                theirSearchTextBox.Text = ""

                -- Destroy pet buttons.
                do
                    for i: string, petBtn: ImageLabel in pairs(YourCachedPetButtons) do
                        petBtn:Destroy()
                        petBtn.Parent = nil
                    end

                    for i: string, petBtn: ImageLabel in pairs(TheirCachedPetButtons) do
                        petBtn:Destroy()
                        petBtn.Parent = nil
                    end
                end
            end
        )
    end
end

return constructorCallback
--[[ @end_section Constructor ]]