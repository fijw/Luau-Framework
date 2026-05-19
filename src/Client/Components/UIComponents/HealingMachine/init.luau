--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local HealingMachineGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.HealingMachine)

local UIComponents = require(script.Components)
local NotificationComponents = require(StarterPlayer.StarterPlayerScripts.Components.UIComponents.Notification)
local PetDetailsComponents = require(StarterPlayer.StarterPlayerScripts.Components.UIComponents.PetDetails)
local SelectPetsComponents = require(StarterPlayer.StarterPlayerScripts.Components.UIComponents.SelectPets)

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

local CachedSelectPetsPetButtons: { [string]: ImageLabel } = {}
local CachedHealingMachinePetButtons: { [string]: ImageLabel } = {}
local CachedPetDatasForExpanding: { [string]: PetSchema } = {}

local SelectingPets: { string } = {}

local COLOR_RARITY_MAP
= {
    Common = Color3.fromRGB(150, 150, 150),
    Uncommon = Color3.fromRGB(50, 50, 150),
    Rare = Color3.fromRGB(50, 150, 50),
    Epic = Color3.fromRGB(150, 150, 50),
    Legendary = Color3.fromRGB(162, 0, 150),
    Secret = Color3.fromRGB(0, 0, 0),
    ["???"] = Color3.fromRGB(99, 0, 0)
}
--[[ @end_section Variables ]]


--[[ @usage Color Functions ]]
--[[
    @usage Get radioactive color.

    @param x number

    @return Color3
]]
local function radioactiveColor(x: number): Color3
    x = x % 1

    if x < 0.25 then
        return Color3.fromRGB(0, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), x / 0.25)
    elseif x < 0.5 then
        return Color3.fromRGB(0, 255, 0):Lerp(Color3.fromRGB(0, 0, 0), (x - 0.25) / 0.25)
    elseif x < 0.75 then
        return Color3.fromRGB(0, 0, 0):Lerp(Color3.fromRGB(255, 255, 0), (x - 0.5) / 0.25)
    else
        return Color3.fromRGB(255, 255, 0):Lerp(Color3.fromRGB(0, 0, 0), (x - 0.75) / 0.25)
    end
end

--[[
    @usage Get glitched color.

    @param x number

    @return Color3
]]
local function glitchedColor(x: number): Color3
    return Color3.fromRGB(0, 0, 0):Lerp(Color3.fromRGB(128, 0, 255), math.sin(x * math.pi * 2) * 0.5 + 0.5)
end
--[[ @end_section Color Functions ]]


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
    @usage Creates a color connection.

    @param PetSchema PetSchema
    @param i string
    @param colorOffset number
    @param gradient UIGradient
    @param side "select" | "display"

    @return RBXScriptConnection
]]
local function newColorConnection(PetSchema: PetSchema, i: string, colorOffset: number, gradient: UIGradient, side: "select" | "display"): RBXScriptConnection
    local colorConnection: RBXScriptConnection

    colorConnection = RunService.Heartbeat:Connect(
        function(dt: number)
            if side == "select" and not CachedSelectPetsPetButtons[i] then colorConnection:Disconnect(); return end
            if side == "display" and not CachedHealingMachinePetButtons[i] then colorConnection:Disconnect(); return end

            if PetSchema.PetStats.color == "Rainbow" then
                colorOffset = colorOffset + (dt * 0.1) % 1; local ColorSeqArray = {}
                
                for i = 0, 17 do
                    local indexOffset = i * (1 / 17)
                    table.insert(ColorSeqArray, ColorSequenceKeypoint.new(if i == 0 then 0 else indexOffset, Color3.fromHSV((colorOffset + indexOffset) % 1, 1, 1)))
                end

                gradient.Color = ColorSequence.new(ColorSeqArray)
            elseif PetSchema.PetStats.color == "Radioactive" then
                colorOffset = colorOffset + (dt * 0.1) % 1; local ColorSeqArray = {}
                
                for i = 0, 17 do
                    local indexOffset = i * (1 / 17)
                    table.insert(ColorSeqArray, ColorSequenceKeypoint.new(if i == 0 then 0 else indexOffset, radioactiveColor((colorOffset + indexOffset) % 1)))
                end

                gradient.Color = ColorSequence.new(ColorSeqArray)
            elseif PetSchema.PetStats.color == "Glitched" then
                colorOffset = colorOffset + (dt * 0.25) % 1; local ColorSeqArray = {}
                
                for i = 0, 17 do
                    local indexOffset = i * (1 / 17)
                    table.insert(ColorSeqArray, ColorSequenceKeypoint.new(if i == 0 then 0 else indexOffset, glitchedColor((colorOffset + indexOffset) % 1)))
                end

                gradient.Color = ColorSequence.new(ColorSeqArray)
            end
        end
    )

    return colorConnection
end

--[[
    @usage Sets the data for the healing machine.

    @param scrollingFrame ScrollingFrame
    @param Pets { [string]: PetSchema }
    @param imageLabel ImageLabel
    @param HandledUI HandledUI
    @param slotsText TextLabel

    @return number
]]
local function setHealingMachineData
(
    scrollingFrame: ScrollingFrame,
    Pets: { [string]: PetSchema },
    imageLabel: ImageLabel,
    HandledUI: HandledUI,
    slotsText: TextLabel
): number
    local numOfPets = 0

    for i: string, PetSchema: PetSchema in pairs(Pets) do
        numOfPets += 1

        local newPetLabel = imageLabel:Clone()
        newPetLabel.Name = i
        newPetLabel.Visible = true
        newPetLabel.ImageColor3 = COLOR_RARITY_MAP[PetSchema.PetStats.rarity]
        newPetLabel.Parent = scrollingFrame

        local innerImgButton = Instance.new("ImageButton")
        innerImgButton.AnchorPoint = Vector2.new(0.5, 0.5)
        innerImgButton.Position = UDim2.fromScale(0.5, 0.5)
        innerImgButton.Parent = newPetLabel
        innerImgButton.BackgroundTransparency = 1
        innerImgButton.BorderSizePixel = 0
        innerImgButton.ZIndex = 2
        innerImgButton.Size = UDim2.fromScale(0.85, 0.85)
        innerImgButton.Image = PetSchema.petImageId

        CachedHealingMachinePetButtons[i] = newPetLabel

        if PetSchema.PetStats.color == "Rainbow"
            or PetSchema.PetStats.color == "Radioactive"
            or PetSchema.PetStats.color == "Glitched"
        then
            local t = 0

            local gradient = Instance.new("UIGradient")
            gradient.Parent = innerImgButton

            newColorConnection(PetSchema, i, t, gradient, "display")
        end

        local isHovering = false

        HandledUI:handleGuiObjectInput(innerImgButton.MouseEnter,
            function()
                isHovering = true

                PetDetailsComponents().mainFrame.Visible = true
                PetDetailsComponents().petName.Text = PetSchema.petName
                PetDetailsComponents().healthText.Text = `{PetSchema.GameplayStats.petHealth}/{PetSchema.GameplayStats.maxHealth}`
                PetDetailsComponents().dmgText.Text = `{PetSchema.GameplayStats.attackDamage}`
                PetDetailsComponents().colorText.Text = PetSchema.PetStats.color
                PetDetailsComponents().sizeText.Text = PetSchema.PetStats.size
                PetDetailsComponents().rarityText.Text = PetSchema.PetStats.rarity

                if PetSchema.PetStats.rarity == "Common" then
                    PetDetailsComponents().rarityFrame.ImageColor3 = Color3.fromRGB(255, 255, 255)
                    PetDetailsComponents().rarityText.TextColor3 = Color3.fromRGB(0, 0, 0)
                elseif PetSchema.PetStats.rarity == "Epic" then
                    PetDetailsComponents().rarityText.TextColor3 = Color3.fromRGB(0, 0, 0)
                else
                    PetDetailsComponents().rarityFrame.ImageColor3 = COLOR_RARITY_MAP[PetSchema.PetStats.rarity]
                    PetDetailsComponents().rarityText.TextColor3 = Color3.fromRGB(255, 255, 255)
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
    end

    slotsText.Text = `Using {numOfPets}/{HealingMachineGroup.RequestHealingSlots:invokeServer()} healing slots.`
    return numOfPets
end

--[[
    @usage Creates the selected tick for a pet.

    @param petLabel ImageLabel

    @return void
]]
local function createSelectedTick(petLabel: ImageLabel)
    local newTick = Instance.new("ImageLabel")
    newTick.Image = "rbxassetid://120401071933338"
    newTick.BackgroundTransparency = 1
    newTick.BorderSizePixel = 0
    newTick.Position = UDim2.new(0.65, 0, 0, 0)
    newTick.Size = UDim2.new(0.35, 0, 0.35, 0)
    newTick.Name = "SelectedTick"
    newTick.ZIndex = 3
    newTick.Parent = petLabel
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
    else
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
    local clonedHealingMachine = UIComponents.HealingPetsMachine:Clone()
    clonedHealingMachine.Parent = PlayerGui

    local containerFrame = clonedHealingMachine:WaitForChild("Container") :: Frame
    local closeBtn = containerFrame:WaitForChild("CloseBtn") :: TextButton
    local healPetBtn = containerFrame:WaitForChild("HealPetBtn") :: TextButton
    local mainFrame = containerFrame:WaitForChild("MainFrame") :: ImageLabel
    local innerContainer = mainFrame:WaitForChild("InnerContainer") :: ImageLabel
    local scrollingFrame = innerContainer:WaitForChild("ScrollingFrame") :: ScrollingFrame
    local uiListLayout = scrollingFrame:WaitForChild("UIListLayout") :: UIListLayout
    local imageLabel = scrollingFrame:WaitForChild("ImageLabel") :: ImageLabel
    local usedSlotsText = innerContainer:WaitForChild("UsedSlotsText") :: TextLabel

    local HandledUI = UIUtilitiesLibrary("healing_machine", clonedHealingMachine)
    HandledUI:hoverAndToggleSizing(1.15)
    HandledUI:handleButtonPress(closeBtn, function(pos1: number, pos2: number) end, true)

    local GameFolder = workspace:WaitForChild("Game") :: Folder
    local MachinesFolder = GameFolder:WaitForChild("Machines") :: Folder
    local healingMachine = MachinesFolder:WaitForChild("HealingMachine") :: Part
    local proximityPrompt = healingMachine:WaitForChild("ProximityPrompt") :: ProximityPrompt
    proximityPrompt.Triggered:Connect(function() HandledUI:setFocus({ "Screen", "Notification", "AreYouSure", "TradeRequest" }) end)

    local currentSelectPetsScreenGui: ScreenGui

    HandledUI:handleButtonPress(healPetBtn,
        function(pos1: number, pos2: number)
            currentSelectPetsScreenGui = SelectPetsComponents().selectPets

            for i: string, petButton: ImageLabel in pairs(CachedSelectPetsPetButtons) do
                petButton:Destroy()
                petButton.Parent = nil

                CachedSelectPetsPetButtons[i] = nil
                CachedPetDatasForExpanding[i] = nil
            end

            local isExpanded = false

            local HandledSelectPetsUI = UIUtilitiesLibrary("select_pets", SelectPetsComponents().selectPets)
            HandledSelectPetsUI:hoverAndToggleSizing(1.15)
            HandledSelectPetsUI:handleButtonPress(SelectPetsComponents().closeBtn, function(pos1: number, pos2: number) end, true)
            HandledSelectPetsUI:setFocus({ "Screen", "Notification", "AreYouSure", "TradeRequest" })

            HandledSelectPetsUI:handleButtonPress(SelectPetsComponents().expandBtn,
                function(pos1: number, pos2: number)
                    isExpanded = not isExpanded

                    local ExpandingNums
                    = {
                        gigantic = 2.04,
                        huge = 2.08,
                        default = 2.17
                    }

                    if isExpanded then
                        for i: number, inst: Instance in ipairs(SelectPetsComponents().scrollingFrame:GetChildren()) do
                            if not inst:IsA("ImageLabel") then continue end
                            expandItems(inst, ExpandingNums, true)
                        end
                    else
                        for i: number, inst: Instance in ipairs(SelectPetsComponents().scrollingFrame:GetChildren()) do
                            if not inst:IsA("ImageLabel") then continue end
                            expandItems(inst, ExpandingNums, false)
                        end
                    end
                end
            )

            task.spawn(
                function()
                    while true do
                        if not currentSelectPetsScreenGui then break else task.wait() end

                        repeat task.wait(); if not currentSelectPetsScreenGui then break end until if currentSelectPetsScreenGui then currentSelectPetsScreenGui.Enabled else false
                        SelectPetsComponents().scrollingFrame.CanvasSize = UDim2.fromOffset(0, SelectPetsComponents().uiListLayout.AbsoluteContentSize.Y)
                    end
                end
            )

            for i: string, Pet: PetSchema in pairs(HealingMachineGroup.RequestPetsForHealingSelection:invokeServer()) do
                local newPetLabel: ImageLabel

                if Pet.PetStats.size == "Gigantic" then
                    newPetLabel = SelectPetsComponents().giganticPetButton:Clone()
                elseif Pet.PetStats.size == "Huge" then
                    newPetLabel = SelectPetsComponents().hugePetButton:Clone()
                else
                    newPetLabel = SelectPetsComponents().defaultPetButton:Clone()
                end

                newPetLabel.Name = i
                newPetLabel.Visible = true
                newPetLabel.ImageColor3 = COLOR_RARITY_MAP[Pet.PetStats.rarity]
                newPetLabel.Parent = SelectPetsComponents().scrollingFrame

                local innerImgButton = Instance.new("ImageButton")
                innerImgButton.AnchorPoint = Vector2.new(0.5, 0.5)
                innerImgButton.Position = UDim2.fromScale(0.5, 0.5)
                innerImgButton.Parent = newPetLabel
                innerImgButton.BackgroundTransparency = 1
                innerImgButton.BorderSizePixel = 0
                innerImgButton.ZIndex = 2
                innerImgButton.Size = UDim2.fromScale(0.85, 0.85)
                innerImgButton.Image = Pet.petImageId

                CachedSelectPetsPetButtons[i] = newPetLabel
                CachedPetDatasForExpanding[i] = Pet

                if Pet.PetStats.color == "Rainbow"
                    or Pet.PetStats.color == "Radioactive"
                    or Pet.PetStats.color == "Glitched"
                then
                    local t = 0
                    
                    local gradient = Instance.new("UIGradient")
                    gradient.Parent = innerImgButton

                    newColorConnection(Pet, i, t, gradient, "select")
                end

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

                        if Pet.PetStats.rarity == "Common" then
                            PetDetailsComponents().rarityFrame.ImageColor3 = Color3.fromRGB(255, 255, 255)
                            PetDetailsComponents().rarityText.TextColor3 = Color3.fromRGB(0, 0, 0)
                        elseif Pet.PetStats.rarity == "Epic" then
                            PetDetailsComponents().rarityText.TextColor3 = Color3.fromRGB(0, 0, 0)
                        else
                            PetDetailsComponents().rarityFrame.ImageColor3 = COLOR_RARITY_MAP[Pet.PetStats.rarity]
                            PetDetailsComponents().rarityText.TextColor3 = Color3.fromRGB(255, 255, 255)
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
                        local foundIdIndex = table.find(SelectingPets, i)

                        if foundIdIndex then
                            table.remove(SelectingPets, foundIdIndex)

                            local foundTick = newPetLabel:FindFirstChild("SelectedTick")
                            if foundTick then foundTick:Destroy() end
                        else
                            table.insert(SelectingPets, i)
                            createSelectedTick(newPetLabel)
                        end
                    end
                )
            end

            HandledSelectPetsUI:handleButtonPress(SelectPetsComponents().continueBtn,
                function(pos1: number, pos2: number)
                    if #SelectingPets > 0 then HealingMachineGroup.HealPets:fireServer(SelectingPets) end
                    SelectingPets = {}

                    HandledSelectPetsUI:removeFocus({ clonedHealingMachine.Name })
                    HandledSelectPetsUI:destroy()

                    currentSelectPetsScreenGui = nil :: any
                end
            )

            HandledSelectPetsUI:handleButtonPress(SelectPetsComponents().closeBtn,
                function(pos1: number, pos2: number)
                    SelectingPets = {}

                    HandledSelectPetsUI:removeFocus({ clonedHealingMachine.Name })
                    HandledSelectPetsUI:destroy()

                    currentSelectPetsScreenGui = nil :: any
                end
            )
        end
    )

    -- Networking connections.
    do
        local numOfPets = setHealingMachineData(scrollingFrame, HealingMachineGroup.RequestHealingPets:invokeServer(), imageLabel, HandledUI, usedSlotsText)

        HealingMachineGroup.RemovePetsFromHealingMachine:onClientEvent(
            function(data)
                for i: number, petId: string in ipairs(data) do
                    local petButton = CachedHealingMachinePetButtons[petId]
                    if not petButton then return end

                    petButton:Destroy()
                    petButton.Parent = nil

                    CachedHealingMachinePetButtons[petId] = nil

                    numOfPets -= 1
                end

                usedSlotsText.Text = `Using {numOfPets}/{HealingMachineGroup.RequestHealingSlots:invokeServer()} healing slots.`
            end
        )

        HealingMachineGroup.PetFinishedHealing:onClientEvent(
            function(data)
                local HandledNotificationUI = UIUtilitiesLibrary("notification", NotificationComponents().notification)
                HandledNotificationUI:hoverAndToggleSizing(1.15)
                HandledNotificationUI:setFocus({ "Screen", "Notification", "AreYouSure", "TradeRequest" })

                local healingSlots = HealingMachineGroup.RequestHealingSlots:invokeServer()
                NotificationComponents().notificationText.Text = `Your {data} has finished healing.<br /><br />You now have {healingSlots} healing slots.`

                HandledNotificationUI:handleButtonPress(NotificationComponents().okayBtn,
                    function(pos1: number, pos2: number)
                        HandledNotificationUI:removeFocus({ clonedHealingMachine.Name })
                        HandledNotificationUI:destroy()
                    end
                )
            end
        )

        HealingMachineGroup.SuccessfullyStartedHealing:onClientEvent(
            function(data)
                -- Create a notification UI.
                do
                    local HandledNotificationUI = UIUtilitiesLibrary("notification", NotificationComponents().notification)
                    HandledNotificationUI:hoverAndToggleSizing(1.15)
                    HandledNotificationUI:setFocus({ "Screen", "Notification", "AreYouSure", "TradeRequest" })

                    NotificationComponents().notificationText.Text = `You have started healing {data} pets.<br /><br />Please wait 5 minutes for healing to complete.`

                    HandledNotificationUI:handleButtonPress(NotificationComponents().okayBtn,
                        function(pos1: number, pos2: number)
                            HandledNotificationUI:removeFocus({ clonedHealingMachine.Name })
                            HandledNotificationUI:destroy()
                        end
                    )
                end

                for i: string, petButton: Instance in pairs(CachedHealingMachinePetButtons) do
                    petButton:Destroy()
                    petButton.Parent = nil

                    CachedHealingMachinePetButtons[i] = nil
                end

                numOfPets = setHealingMachineData(scrollingFrame, HealingMachineGroup.RequestHealingPets:invokeServer(), imageLabel, HandledUI, usedSlotsText)
                usedSlotsText.Text = `Using {numOfPets}/{HealingMachineGroup.RequestHealingSlots:invokeServer()} healing slots.`
            end
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

                -- Update the UI.
                do
                    for i: string, petButton: Instance in pairs(CachedHealingMachinePetButtons) do
                        petButton:Destroy()
                        petButton.Parent = nil

                        CachedHealingMachinePetButtons[i] = nil
                    end

                    local numOfPets = setHealingMachineData(scrollingFrame, HealingMachineGroup.RequestHealingPets:invokeServer(), imageLabel, HandledUI, usedSlotsText)
                    usedSlotsText.Text = `Using {numOfPets}/{HealingMachineGroup.RequestHealingSlots:invokeServer()} healing slots.`
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

    task.spawn(
        function()
            while true do
                repeat task.wait() until clonedHealingMachine.Enabled; task.wait()
                scrollingFrame.CanvasSize = UDim2.fromOffset(0, uiListLayout.AbsoluteContentSize.Y)
            end
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]