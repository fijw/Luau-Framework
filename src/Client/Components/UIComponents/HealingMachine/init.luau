--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local HealingMachineGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.HealingMachine)

local UIComponents = require(script.Components)
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

local CachedPetButtons: { [string]: ImageLabel } = {}
local SelectingPets: { string } = {}
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
        newPetLabel.Parent = scrollingFrame
        newPetLabel.ImageColor3 = Color3.fromRGB(0, 155, 202)

        local innerImgButton = Instance.new("ImageButton")
        innerImgButton.AnchorPoint = Vector2.new(0.5, 0.5)
        innerImgButton.Position = UDim2.fromScale(0.5, 0.5)
        innerImgButton.Parent = newPetLabel
        innerImgButton.BackgroundTransparency = 0
        innerImgButton.BackgroundColor3 = Color3.fromRGB(161, 0, 0)
        innerImgButton.BorderSizePixel = 0
        innerImgButton.ZIndex = 2
        innerImgButton.Size = UDim2.fromScale(0.85, 0.85)
        innerImgButton.Image = PetSchema.petImageId

        CachedPetButtons[i] = newPetLabel

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

    slotsText.Text = `Using {numOfPets}/nil healing slots.`
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
--[[ @end_section Utility Functions ]]


--[[ @section Constructor ]]
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

    local MapFolder = workspace:WaitForChild("Map") :: Folder
    local MachinesFolder = MapFolder:WaitForChild("Machines") :: Folder
    local healingMachine = MachinesFolder:WaitForChild("HealingMachine") :: Part
    local proximityPrompt = healingMachine:WaitForChild("ProximityPrompt") :: ProximityPrompt
    proximityPrompt.Triggered:Connect(function() HandledUI:setFocus({ "Screen", "Notification", "AreYouSure" }) end)

    HandledUI:handleButtonPress(healPetBtn,
        function(pos1: number, pos2: number)
            local HandledSelectPetsUI = UIUtilitiesLibrary("select_pets", SelectPetsComponents().selectPets)
            HandledSelectPetsUI:hoverAndToggleSizing(1.15)
            HandledSelectPetsUI:setFocus({ "Screen", "Notification", "AreYouSure" })

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
                newPetLabel.Parent = SelectPetsComponents().scrollingFrame
                newPetLabel.ImageColor3 = Color3.fromRGB(0, 155, 202)

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

                CachedPetButtons[i] = newPetLabel

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

                    HandledSelectPetsUI:removeFocus({ clonedHealingMachine.Name })
                    HandledSelectPetsUI:destroy()
                end
            )

            HandledSelectPetsUI:handleButtonPress(SelectPetsComponents().closeBtn,
                function(pos1: number, pos2: number)
                    HandledSelectPetsUI:removeFocus({ clonedHealingMachine.Name })
                    HandledSelectPetsUI:destroy()
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
                    local PetButton = CachedPetButtons[petId]
                    if not PetButton then return end

                    PetButton:Destroy()
                    PetButton.Parent = nil

                    numOfPets -= 1
                end

                usedSlotsText.Text = `Using {numOfPets}/nil healing slots.`
            end
        )

        HealingMachineGroup.SuccessfullyStartedHealing:onClientEvent(
            function(data)
                for i: string, PetButton: Instance in pairs(CachedPetButtons) do
                    PetButton:Destroy()
                    PetButton.Parent = nil
                end

                numOfPets = setHealingMachineData(scrollingFrame, HealingMachineGroup.RequestHealingPets:invokeServer(), imageLabel, HandledUI, usedSlotsText)
                usedSlotsText.Text = `Using {numOfPets}/nil healing slots.`
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