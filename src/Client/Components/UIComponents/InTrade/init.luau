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
local NotificationComponents = require(StarterPlayer.StarterPlayerScripts.Components.UIComponents.Notification)

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
    @usage Creates a tick for a pet.

    @param petLabel ImageLabel

    @return void
]]
local function createTick(petLabel: ImageLabel, type: "lock" | "selected")
    local newTick = Instance.new("ImageLabel")
    newTick.Image = if type == "lock" then "rbxassetid://138368172974659" else "rbxassetid://120401071933338"
    newTick.BackgroundTransparency = 1
    newTick.BorderSizePixel = 0
    newTick.Position = if type == "lock" then UDim2.new(0, 0, 0, 0) else UDim2.new(0.65, 0, 0, 0)
    newTick.Size = UDim2.new(0.35, 0, 0.35, 0)
    newTick.Name = if type == "lock" then "LockTick" else "SelectedTick"
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

    if Pet.Locked then if table.find(Pet.Locked, id) then createTick(newPetLabel, "lock") end end
    if table.find(SelectedPetsCache, id) then createTick(newPetLabel, "selected") end

    CachedPetDatasForExpanding[id] = Pet

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

    if side == "yours" then YourCachedPetButtons[id] = newPetLabel else TheirCachedPetButtons[id] = newPetLabel end

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
                if side == "theirs" or isReady or table.find(Pet.Locked :: { string }, id) then return end

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

--[[
    @usage Expand items.

    @param inst ImageLabel
    @param ExpandingNums { [string]: number }

    @return void
]]
local function expandItems(inst: ImageLabel, ExpandingNums: { [string]: number }, expanding: boolean)
    if inst.Name == "Gigantic" then
        if not expanding then
            inst.Size = UDim2.fromScale(inst.Size.X.Scale * ExpandingNums.gigantic, inst.Size.Y.Scale * ExpandingNums.gigantic)
            return
        end

        inst.Size = UDim2.fromScale(inst.Size.X.Scale / ExpandingNums.gigantic, inst.Size.Y.Scale / ExpandingNums.gigantic)
        return
    elseif inst.Name == "Huge" then
        if not expanding then
            inst.Size = UDim2.fromScale(inst.Size.X.Scale * ExpandingNums.huge, inst.Size.Y.Scale * ExpandingNums.huge)
            return
        end

        inst.Size = UDim2.fromScale(inst.Size.X.Scale / ExpandingNums.huge, inst.Size.Y.Scale / ExpandingNums.huge)
        return
    elseif inst.Name == "Default" then
        if not expanding then
            inst.Size = UDim2.fromScale(inst.Size.X.Scale * ExpandingNums.default, inst.Size.Y.Scale * ExpandingNums.default)
            return
        end

        inst.Size = UDim2.fromScale(inst.Size.X.Scale / ExpandingNums.default, inst.Size.Y.Scale / ExpandingNums.default)
        return
    end

    local InstPetData = CachedPetDatasForExpanding[inst.Name]
    if not InstPetData then return end

    if InstPetData.PetStats.size == "Gigantic" then
        if not expanding then
            inst.Size = UDim2.fromScale(inst.Size.X.Scale * ExpandingNums.gigantic, inst.Size.Y.Scale * ExpandingNums.gigantic)
            return
        end

        inst.Size = UDim2.fromScale(inst.Size.X.Scale / ExpandingNums.gigantic, inst.Size.Y.Scale / ExpandingNums.gigantic)
    elseif InstPetData.PetStats.size == "Huge" then
        if not expanding then
            inst.Size = UDim2.fromScale(inst.Size.X.Scale * ExpandingNums.huge, inst.Size.Y.Scale * ExpandingNums.huge)
            return
        end

        inst.Size = UDim2.fromScale(inst.Size.X.Scale / ExpandingNums.huge, inst.Size.Y.Scale / ExpandingNums.huge)
    elseif InstPetData.PetStats.size == "Default" then
        if not expanding then
            inst.Size = UDim2.fromScale(inst.Size.X.Scale * ExpandingNums.default, inst.Size.Y.Scale * ExpandingNums.default)
            return
        end

        inst.Size = UDim2.fromScale(inst.Size.X.Scale / ExpandingNums.default, inst.Size.Y.Scale / ExpandingNums.default)
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

    yourGemsTextBox.FocusLost:Connect(
        function(enterPressed: boolean, Input: InputObject) TradingGroup.SetGemsInTradeOffer:fireServer(tonumber(yourGemsTextBox.Text) :: number) end
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

        TradingGroup.TradeOfferUpdated:onClientEvent(
            function(data)
                if isReady then TradingGroup.AcceptTrade:fireServer() end
                
                isReady = false
                yourSide.ImageColor3 = Color3.fromHex("#FFFFFF")
            end
        )

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

                local ExpandingNums
                = {
                    gigantic = 2.04,
                    huge = 2.07,
                    default = 2.16
                }

                if isExpanded then
                    for i: number, inst: Instance in ipairs(yourScrollingFrame:GetChildren()) do
                        if not inst:IsA("ImageLabel") then continue end
                        expandItems(inst, ExpandingNums, true)
                    end

                    for i: number, inst: Instance in ipairs(theirScrollingFrame:GetChildren()) do
                        if not inst:IsA("ImageLabel") then continue end
                        expandItems(inst, ExpandingNums, true)
                    end
                else
                    for i: number, inst: Instance in ipairs(yourScrollingFrame:GetChildren()) do
                        if not inst:IsA("ImageLabel") then continue end
                        expandItems(inst, ExpandingNums, false)
                    end

                    for i: number, inst: Instance in ipairs(theirScrollingFrame:GetChildren()) do
                        if not inst:IsA("ImageLabel") then continue end
                        expandItems(inst, ExpandingNums, false)
                    end
                end
            end
        )

        HandledUI:handleButtonPress(readyUpBtn,
            function(pos1: number, pos2: number)
                isReady = not isReady

                if isReady then
                    yourSide.ImageColor3 = Color3.fromHex("#64FF64")
                else
                    yourSide.ImageColor3 = Color3.fromHex("#FFFFFF")
                end

                TradingGroup.AcceptTrade:fireServer()
            end
        )

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
                    isExpanded = false

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