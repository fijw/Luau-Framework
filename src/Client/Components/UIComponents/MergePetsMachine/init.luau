--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local MergingGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.Merging)

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
--[[ @end_section Types ]]


--[[ @section Variables ]]
local localPlayer = Players.LocalPlayer :: Player
local PlayerGui = (if localPlayer then localPlayer:WaitForChild("PlayerGui") else nil) :: PlayerGui
local PlrMouse = (if localPlayer then localPlayer:GetMouse() else nil) :: Mouse

local CachedPetButtons: { [string]: ImageLabel } = {}
local SelectedMergingPets: { string } = {}

local NEEDED_PETS_TO_MERGE = 9
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
    @usage Creates a notification.

    @param data number
    @param type "not_enough_pets" | "not_enough_gems"

    @return void
]]
local function createNotification(data: number, type: "not_enough_pets" | "not_enough_gems")
    local HandledNotificationUI = UIUtilitiesLibrary("notification", NotificationComponents().notification)
    HandledNotificationUI:hoverAndToggleSizing(1.15)

    NotificationComponents().container.Visible = true

    if type == "not_enough_pets" then
        NotificationComponents().notificationText.Text = `Not enough pets to merge. <br /><br />You need to select {NEEDED_PETS_TO_MERGE - data} more pets.`
    elseif type == "not_enough_gems" then
        NotificationComponents().notificationText.Text = `Not enough gems to merge. You need {5_000 - data} more gems.`
    end

    HandledNotificationUI:handleButtonPress(NotificationComponents().okayBtn,
        function(pos1: number, pos2: number)
            NotificationComponents().container.Visible = false
            HandledNotificationUI:destroy()
        end
    )
end
--[[ @end_section Utility Functions ]]


--[[ @section Constructor ]]
local function constructorCallback()
    local clonedMachine = UIComponents.MergePetsMachine:Clone()
    clonedMachine.Parent = PlayerGui

    local containerFrame = clonedMachine:WaitForChild("Container") :: Frame
    local searchBox = containerFrame:WaitForChild("SearchBox") :: Frame
    local frameBox = searchBox:WaitForChild("FrameBox") :: ImageLabel
    local textBox = frameBox:WaitForChild("TextBox") :: TextBox
    local closeBtn = containerFrame:WaitForChild("CloseBtn") :: ImageButton
    local mergeBtn = containerFrame:WaitForChild("MergeBtn") :: ImageButton
    local mainFrame = containerFrame:WaitForChild("MainFrame") :: ImageLabel
    local scrollingFrame = mainFrame:WaitForChild("ScrollingFrame") :: ScrollingFrame
    local defaultPetButton = scrollingFrame:WaitForChild("Default") :: ImageLabel
    local hugePetButton = scrollingFrame:WaitForChild("Huge") :: ImageLabel
    local giganticPetButton = scrollingFrame:WaitForChild("Gigantic") :: ImageLabel
    local uiListLayout = scrollingFrame:WaitForChild("UIListLayout") :: UIListLayout

    textBox:GetPropertyChangedSignal("Text"):Connect(function() MergingGroup.SearchForPetsByString:fireServer(textBox.Text) end)

    local HandledUI = UIUtilitiesLibrary("merging_machine", clonedMachine)
    HandledUI:hoverAndToggleSizing(1.15)
    HandledUI:handleButtonPress(closeBtn, function(pos1: number, pos2: number) end, true)

    -- Networking connections.
    do
        local petsCount = 0

        MergingGroup.AddPetsToMergingSlots:onClientEvent(
            function(data)
                for i: string, PetSchema: PetSchema in pairs(data) do
                    petsCount += 1

                    local newPetLabel: ImageLabel

                    if PetSchema.PetStats.size == "Gigantic" then
                        newPetLabel = giganticPetButton:Clone()
                    elseif PetSchema.PetStats.size == "Huge" then
                        newPetLabel = hugePetButton:Clone()
                    else
                        newPetLabel = defaultPetButton:Clone()
                    end

                    newPetLabel.Name = i
                    newPetLabel.Visible = true
                    newPetLabel.Parent = scrollingFrame
                    
                    if table.find(SelectedMergingPets, i) then createSelectedTick(newPetLabel) end

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

                    HandledUI:handleButtonPress(innerImgButton,
                        function(pos1: number, pos2: number)
                            local foundPetIndex = table.find(SelectedMergingPets, i)

                            if foundPetIndex then
                                local foundTick = newPetLabel:FindFirstChild("SelectedTick")
                                if foundTick then foundTick:Destroy() end

                                table.remove(SelectedMergingPets, foundPetIndex)
                            else
                                createSelectedTick(newPetLabel)
                                if #SelectedMergingPets < NEEDED_PETS_TO_MERGE then table.insert(SelectedMergingPets, i) end
                            end

                            if #SelectedMergingPets > 0 then MergingGroup.SearchForPetsByData:fireServer(PetSchema) else MergingGroup.RequestMergingData:fireServer() end
                        end
                    )
                end
            end
        )

        MergingGroup.RemovePetsFromMergingSlots:onClientEvent(
            function(data)
                for i: number, petId: string in ipairs(data) do
                    local PetButton = CachedPetButtons[petId]
                    if not PetButton then continue end

                    PetButton:Destroy()
                    PetButton.Parent = nil
                end
            end
        )

        MergingGroup.RemoveAllPetsFromMergingSlots:onClientEvent(
            function(data)
                for i: string, PetButton: ImageLabel in pairs(CachedPetButtons) do
                    PetButton:Destroy()
                    PetButton.Parent = nil
                end
            end
        )

        MergingGroup.NotEnoughPetsToMerge:onClientEvent(function(data) createNotification(data, "not_enough_pets") end)
        MergingGroup.NotEnoughGemsToMerge:onClientEvent(function(data) createNotification(data, "not_enough_gems") end)
    end

    HandledUI:handleButtonPress(mergeBtn, function(pos1: number, pos2: number) MergingGroup.MergePets:fireServer(SelectedMergingPets) end)

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

                MergingGroup.RequestMergingData:fireServer()
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
                repeat task.wait() until clonedMachine.Enabled; task.wait()
                scrollingFrame.CanvasSize = UDim2.fromOffset(0, uiListLayout.AbsoluteContentSize.Y)
            end
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]