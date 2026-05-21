--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local TradingGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.Trading)

local UIComponents = require(script.Components)
local PetDetailsComponents = require(StarterPlayer.StarterPlayerScripts.Components.UIComponents.PetDetails)
local NotificationComponents = require(StarterPlayer.StarterPlayerScripts.Components.UIComponents.Notification)

local NumberFormatLib = require(ReplicatedStorage.Libraries.NumberLibs.NumberFormatLib)
local UIUtilitiesLibrary = require(StarterPlayer.StarterPlayerScripts.Libraries.UILib)
local TweensLib = require(ReplicatedStorage.Libraries.TweensLib)

local UtilsComponent = require(StarterPlayer.StarterPlayerScripts.Components.UIComponents.UtilsComponent)

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

local CachedPetDatasForExpanding: { [string]: PetSchema } = {}

local YourCachedPetButtons: { [string]: ImageLabel } = {}
local TheirCachedPetButtons: { [string]: ImageLabel } = {}

local SelectedPetsCache: { string } = {}

local isReady = false
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
    newPetLabel.ImageColor3 = UtilsComponent.COLOR_RARITY_MAP[Pet.PetStats.rarity]

    if side == "yours" then newPetLabel.Parent = yourScrollingFrame else newPetLabel.Parent = theirScrollingFrame end

    if Pet.Locked then if table.find(Pet.Locked, id) then UtilsComponent.createTick(newPetLabel, "lock") end end
    if table.find(SelectedPetsCache, id) then UtilsComponent.createTick(newPetLabel, "selected") end

    CachedPetDatasForExpanding[id] = Pet

    local innerImgButton = Instance.new("ImageButton")
    innerImgButton.AnchorPoint = Vector2.new(0.5, 0.5)
    innerImgButton.Position = UDim2.fromScale(0.5, 0.5)
    innerImgButton.Parent = newPetLabel
    innerImgButton.BackgroundTransparency = 1
    innerImgButton.BorderSizePixel = 0
    innerImgButton.ZIndex = 2
    innerImgButton.Size = UDim2.fromScale(0.85, 0.85)
    innerImgButton.Image = Pet.petImageId

    if side == "yours" then YourCachedPetButtons[id] = newPetLabel else TheirCachedPetButtons[id] = newPetLabel end

    if Pet.PetStats.color == "Rainbow"
        or Pet.PetStats.color == "Radioactive"
        or Pet.PetStats.color == "Glitched"
    then
        local colorOffset = 0

        local gradient = Instance.new("UIGradient")
        gradient.Rotation = 40
        gradient.Parent = innerImgButton

        local colorConnection: RBXScriptConnection

        colorConnection = RunService.Heartbeat:Connect(
            function(dt: number)
                if side == "yours" then if not YourCachedPetButtons[id] then colorConnection:Disconnect(); return end end
                if side == "theirs" then if not TheirCachedPetButtons[id] then colorConnection:Disconnect(); return end end

                if Pet.PetStats.color == "Rainbow" then
                    colorOffset = colorOffset + (dt * 0.1) % 1; local ColorSeqArray = {}
                    
                    for i = 0, 17 do
                        local indexOffset = i * (1 / 17)
                        table.insert(ColorSeqArray, ColorSequenceKeypoint.new(if i == 0 then 0 else indexOffset, Color3.fromHSV((colorOffset + indexOffset) % 1, 0.75, 1)))
                    end

                    gradient.Color = ColorSequence.new(ColorSeqArray)
                elseif Pet.PetStats.color == "Radioactive" then
                    colorOffset = colorOffset + (dt * 0.1) % 1; local ColorSeqArray = {}
                    
                    for i = 0, 17 do
                        local indexOffset = i * (1 / 17)
                        table.insert(ColorSeqArray, ColorSequenceKeypoint.new(if i == 0 then 0 else indexOffset, UtilsComponent.radioactiveColor((colorOffset + indexOffset) % 1)))
                    end

                    gradient.Color = ColorSequence.new(ColorSeqArray)
                elseif Pet.PetStats.color == "Glitched" then
                    colorOffset = colorOffset + (dt * 0.25) % 1; local ColorSeqArray = {}
                    
                    for i = 0, 17 do
                        local indexOffset = i * (1 / 17)
                        table.insert(ColorSeqArray, ColorSequenceKeypoint.new(if i == 0 then 0 else indexOffset, UtilsComponent.glitchedColor((colorOffset + indexOffset) % 1)))
                    end

                    gradient.Color = ColorSequence.new(ColorSeqArray)
                end
            end
        )
    end

    -- Hovering.
    do
        local isHovering = false

        HandledUI:handleGuiObjectInput(innerImgButton.MouseEnter,
            function()
                isHovering = true

                local health = NumberFormatLib(Pet.GameplayStats.petHealth, "thousands")
                local maxHealth = NumberFormatLib(Pet.GameplayStats.maxHealth, "thousands")

                PetDetailsComponents().mainFrame.Visible = true
                PetDetailsComponents().petName.Text = Pet.petName
                PetDetailsComponents().healthText.Text = `{health}/{maxHealth}`
                PetDetailsComponents().dmgText.Text = `{NumberFormatLib(Pet.GameplayStats.attackDamage, "thousands")}`
                PetDetailsComponents().colorText.Text = Pet.PetStats.color
                PetDetailsComponents().sizeText.Text = Pet.PetStats.size
                PetDetailsComponents().rarityText.Text = Pet.PetStats.rarity

                if Pet.PetStats.rarity == "Common" then
                    PetDetailsComponents().rarityText.TextColor3 = Color3.fromRGB(0, 0, 0)
                else
                    PetDetailsComponents().rarityText.TextColor3 = UtilsComponent.COLOR_RARITY_MAP[Pet.PetStats.rarity]
                end

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
                if side == "theirs" or isReady or table.find(Pet.Locked :: { string }, id) then return end

                local foundIndex = table.find(SelectedPetsCache, id)
                
                if foundIndex then
                    table.remove(SelectedPetsCache, foundIndex)
                    TradingGroup.RemovePetFromTradeOffer:fireServer(id)

                    local foundSelectedTick = newPetLabel:FindFirstChild("SelectTick")
                    if foundSelectedTick then foundSelectedTick:Destroy() end
                else
                    table.insert(SelectedPetsCache, id)
                    TradingGroup.AddPetToTradeOffer:fireServer(id)

                    UtilsComponent.createTick(newPetLabel, "selected")
                end
            end
        )
    end
end

--[[
    @usage Add searching pets to the trade.

    @param side "yours" | "theirs"
    @param Pets { [string]: PetSchema }
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
local function handleSearch
(
    side: "yours" | "theirs",
    Pets: { [string]: PetSchema },
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
    if side == "yours" then
        for i: string, petImageLabel: ImageLabel in pairs(YourCachedPetButtons) do
            petImageLabel:Destroy()
            petImageLabel.Parent = nil

            CachedPetDatasForExpanding[i] = nil
        end
    else
        for i: string, petImageLabel: ImageLabel in pairs(TheirCachedPetButtons) do
            petImageLabel:Destroy()
            petImageLabel.Parent = nil

            CachedPetDatasForExpanding[i] = nil
        end
    end

    for i: string, Pet: PetSchema in pairs(Pets) do
        addPetToTrade(
            side,
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
    local yourGemsTextBox = yourAmountBox:WaitForChild("TextBox") :: TextBox
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
    local actionsContainer = containerFrame:WaitForChild("ActionsContainer") :: Frame
    local readyUpBtn = actionsContainer:WaitForChild("ReadyUpBtn") :: ImageButton
    local cancelBtn = actionsContainer:WaitForChild("CancelBtn") :: ImageButton
    local timeContainer = mainFrame:WaitForChild("TimeContainer") :: Frame
    local timeText = timeContainer:WaitForChild("TextLabel") :: TextLabel

    yourGemsTextBox.FocusLost:Connect(
        function(enterPressed: boolean, Input: InputObject)
            if not enterPressed then return end

            TradingGroup.SetGemsInTradeOffer:fireServer(tonumber(yourGemsTextBox.Text) :: number)
            yourGemsTextBox.Text = NumberFormatLib(tonumber(yourGemsTextBox.Text) :: number, "quintillions")
        end
    )

    local HandledUI = UIUtilitiesLibrary("in_trade", clonedInTrade)
    HandledUI:hoverAndToggleSizing(1.15)

    -- Search box connections.
    do
        yourSearchTextBox:GetPropertyChangedSignal("Text"):Connect(
            function()
                local Pets = TradingGroup.SearchForTradingPets:invokeServer({ side = "yours", text = yourSearchTextBox.Text })

                handleSearch(
                    "yours",
                    Pets,
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

        theirSearchTextBox:GetPropertyChangedSignal("Text"):Connect(
            function()
                local Pets = TradingGroup.SearchForTradingPets:invokeServer({ side = "theirs", text = theirSearchTextBox.Text })

                handleSearch(
                    "theirs",
                    Pets,
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
    end

    local theyAreAccepting = false
    local countdownDisplayed = false

    -- Networking connections.
    do
        TradingGroup.DisplayCountdown:onClientEvent(
            function(data)
                timeContainer.Visible = true; innerContainer.Visible = false; countdownDisplayed = true

                task.spawn(
                    function()
                        local timeLeft = 3

                        while true do
                            if timeLeft <= 0 or not countdownDisplayed then break end
                            timeText.Text = `{timeLeft}`; timeLeft -= 1; task.wait(1)
                        end

                        timeText.Text = "Completing Trade..."
                    end
                )
            end
        )

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

        TradingGroup.HideCountdown:onClientEvent(function() timeContainer.Visible = false; innerContainer.Visible = true; countdownDisplayed = false end)
        TradingGroup.SetGemsInTradeOffer:onClientEvent(function(data) theirGemsText.Text = `{NumberFormatLib(data, "quintillions")}` end)
        TradingGroup.TradeOfferUpdated:onClientEvent(function(data) if isReady then TradingGroup.AcceptTrade:fireServer() end end)

        TradingGroup.TradeCompleted:onClientEvent(
            function(data)
                local HandledNotificationUI = UIUtilitiesLibrary("notification", NotificationComponents().notification)
                HandledNotificationUI:hoverAndToggleSizing(1.15)
                HandledNotificationUI:setFocus({ "Screen", "Notification", "AreYouSure", "TradeRequest" })

                NotificationComponents().notificationText.Text = `Your trade with {data} has been completed.`

                HandledNotificationUI:handleButtonPress(NotificationComponents().okayBtn,
                    function(pos1: number, pos2: number)
                        HandledNotificationUI:removeFocus({ "Screen" })
                        HandledNotificationUI:destroy()
                    end
                )
            end
        )

        TradingGroup.CancelTrade:onClientEvent(
            function(data)
                local HandledNotificationUI = UIUtilitiesLibrary("notification", NotificationComponents().notification)
                HandledNotificationUI:hoverAndToggleSizing(1.15)
                HandledNotificationUI:setFocus({ "Screen", "Notification", "AreYouSure", "TradeRequest" })

                NotificationComponents().notificationText.Text = `Your trade with {data} has been cancelled.`

                HandledNotificationUI:handleButtonPress(NotificationComponents().okayBtn,
                    function(pos1: number, pos2: number)
                        HandledNotificationUI:removeFocus({ "Screen" })
                        HandledNotificationUI:destroy()
                    end
                )
            end
        )

        TradingGroup.AcceptTrade:onClientEvent(
            function(data)
                if data == "yours" then
                    isReady = not isReady
                    if isReady then yourSide.ImageColor3 = Color3.fromHex("#64FF64") else yourSide.ImageColor3 = Color3.fromHex("#FFFFFF") end

                    return
                end

                if not theyAreAccepting then theirSide.ImageColor3 = Color3.fromHex("#64FF64"); theyAreAccepting = true; return end
                theirSide.ImageColor3 = Color3.fromHex("#FFFFFF"); theyAreAccepting = false
            end
        )
    end

    local isExpanded = false

    -- Buttons handling.
    do
        HandledUI:handleButtonPress(expandBtn,
            function(pos1: number, pos2: number)
                isExpanded = not isExpanded
                if isExpanded then expandBtn.Image = "rbxassetid://78262684079325" else expandBtn.Image = "rbxassetid://130599991371204" end

                local ExpandingNums
                = {
                    gigantic = 2.04,
                    huge = 2.07,
                    default = 2.16
                }

                if isExpanded then
                    for i: number, inst: Instance in ipairs(yourScrollingFrame:GetChildren()) do
                        if not inst:IsA("ImageLabel") then continue end
                        UtilsComponent.expandItems(inst, ExpandingNums, true, CachedPetDatasForExpanding)
                    end

                    for i: number, inst: Instance in ipairs(theirScrollingFrame:GetChildren()) do
                        if not inst:IsA("ImageLabel") then continue end
                        UtilsComponent.expandItems(inst, ExpandingNums, true, CachedPetDatasForExpanding)
                    end
                else
                    for i: number, inst: Instance in ipairs(yourScrollingFrame:GetChildren()) do
                        if not inst:IsA("ImageLabel") then continue end
                        UtilsComponent.expandItems(inst, ExpandingNums, false, CachedPetDatasForExpanding)
                    end

                    for i: number, inst: Instance in ipairs(theirScrollingFrame:GetChildren()) do
                        if not inst:IsA("ImageLabel") then continue end
                        UtilsComponent.expandItems(inst, ExpandingNums, false, CachedPetDatasForExpanding)
                    end
                end
            end
        )

        HandledUI:handleButtonPress(readyUpBtn, function(pos1: number, pos2: number) TradingGroup.AcceptTrade:fireServer() end)

        HandledUI:handleButtonPress(cancelBtn,
            function(pos1: number, pos2: number)
                TradingGroup.CancelTrade:fireServer()
            end,

            true
        )
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

                -- Clear old data.
                do
                    SelectedPetsCache = {}
                    CachedPetDatasForExpanding = {}

                    yourSide.ImageColor3 = Color3.fromHex("#FFFFFF")
                    theirSide.ImageColor3 = Color3.fromHex("#FFFFFF")

                    yourSearchTextBox.Text = ""
                    theirSearchTextBox.Text = ""

                    -- Destroy pet buttons.
                    do
                        for i: string, petBtn: ImageLabel in pairs(YourCachedPetButtons) do
                            petBtn:Destroy()
                            petBtn.Parent = nil

                            YourCachedPetButtons[i] = nil
                        end

                        for i: string, petBtn: ImageLabel in pairs(TheirCachedPetButtons) do
                            petBtn:Destroy()
                            petBtn.Parent = nil

                            TheirCachedPetButtons[i] = nil
                        end
                    end

                    yourGemsTextBox.Text = ""
                    theirGemsText.Text = "0"

                    isReady = false
                end

                -- Add new data.
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
            end
        )
    end
end

return constructorCallback
--[[ @end_section Constructor ]]