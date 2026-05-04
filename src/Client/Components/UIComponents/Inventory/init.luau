--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local InventoryGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.Inventory)

local UIComponents = require(script.Components)
local PetDetailsComponents = require(StarterPlayer.StarterPlayerScripts.Components.UIComponents.PetDetails)
local AreYouSureComponents = require(StarterPlayer.StarterPlayerScripts.Components.UIComponents.AreYouSure)

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
local SelectedDeletingPets: { string } = {}
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
local function createTick(petLabel: ImageLabel, type: "lock" | "delete")
    local newTick = Instance.new("ImageLabel")
    newTick.Image = if type == "lock" then "rbxassetid://138368172974659" else "rbxassetid://138335893507994"
    newTick.BackgroundTransparency = 1
    newTick.BorderSizePixel = 0
    newTick.Position = UDim2.new(0, 0, 0, 0)
    newTick.Size = UDim2.new(0.35, 0, 0.35, 0)
    newTick.Name = if type == "lock" then "LockTick" else "DeleteTick"
    newTick.ZIndex = 3
    newTick.Parent = petLabel
end
--[[ @end_section Utility Functions ]]


--[[ @section Constructor ]]
local function constructorCallback()
    local clonedInventory = UIComponents.Inventory:Clone()
    clonedInventory.Parent = PlayerGui

    local containerFrame = clonedInventory:WaitForChild("ContainerFrame") :: Frame
    local searchBox = containerFrame:WaitForChild("SearchBox") :: Frame
    local frameBox = searchBox:WaitForChild("FrameBox") :: ImageLabel
    local textBox = frameBox:WaitForChild("TextBox") :: TextBox
    local closeBtn = containerFrame:WaitForChild("CloseBtn") :: ImageButton
    local buttonsFrame = containerFrame:WaitForChild("ButtonsFrame") :: ImageLabel
    local lockBtn = buttonsFrame:WaitForChild("LockBtn") :: ImageButton
    local deleteBtn = buttonsFrame:WaitForChild("DeleteBtn") :: ImageButton
    local expandBtn = buttonsFrame:WaitForChild("ExpandBtn") :: ImageButton
    local mainFrame = containerFrame:WaitForChild("MainFrame") :: ImageLabel
    local inventoryStatusContainer = mainFrame:WaitForChild("InventoryStatusContainer") :: Frame
    local equippedText = inventoryStatusContainer:WaitForChild("EquippedText") :: TextLabel
    local slotsText = inventoryStatusContainer:WaitForChild("SlotsText") :: TextLabel
    local scrollingFrame = mainFrame:WaitForChild("ScrollingFrame") :: ScrollingFrame
    local uiListLayout = scrollingFrame:WaitForChild("UIListLayout") :: UIListLayout
    local defaultPetButton = scrollingFrame:WaitForChild("Default") :: ImageLabel
    local hugePetButton = scrollingFrame:WaitForChild("Huge") :: ImageLabel
    local giganticPetButton = scrollingFrame:WaitForChild("Gigantic") :: ImageLabel

    textBox:GetPropertyChangedSignal("Text"):Connect(function() InventoryGroup.SearchForPets:fireServer(textBox.Text) end)

    local HandledUI = UIUtilitiesLibrary("inventory", clonedInventory)
    HandledUI:hoverAndToggleSizing(1.15)
    HandledUI:handleButtonPress(closeBtn, function(pos1: number, pos2: number) end, true)

    local isLocking = false
    local isDeleting = false
    local isExpanded = false

    -- Networking connections.
    do
        InventoryGroup.AddPetsToInventory:onClientEvent(
            function(data: { [string]: PetSchema })
                for i: string, PetSchema: PetSchema in pairs(data) do
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

                    if table.find(PetSchema.locked, i) then createTick(newPetLabel, "lock") end

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
                            if isLocking then
                                local foundIdIndex = table.find(PetSchema.locked, i)

                                if not foundIdIndex then
                                    table.insert(PetSchema.locked, i)

                                    InventoryGroup.LockPet:fireServer(i)
                                    createTick(newPetLabel, "lock")
                                else
                                    table.remove(PetSchema.locked, foundIdIndex)
                                    InventoryGroup.LockPet:fireServer(i)
                                    
                                    local foundTick = newPetLabel:FindFirstChild("LockTick")
                                    if foundTick then foundTick:Destroy() end
                                end
                            end

                            if isDeleting then
                                if table.find(PetSchema.locked, i) then return end

                                -- Add or remove the pet from the deletion list.
                                do
                                    local foundIdIndex = table.find(SelectedDeletingPets, i)

                                    if foundIdIndex then
                                        table.remove(SelectedDeletingPets, foundIdIndex)

                                        local foundTick = newPetLabel:FindFirstChild("DeleteTick")
                                        if foundTick then foundTick:Destroy() end
                                    else
                                        createTick(newPetLabel, "delete")
                                        table.insert(SelectedDeletingPets, i)
                                    end
                                end
                            end
                        end
                    )
                end

                slotsText.Text = `{InventoryGroup.RequestInventorySlots:invokeServer()} Pets`
            end
        )

        InventoryGroup.RemovePetsFromInventory:onClientEvent(
            function(data: { string })
                for i: number, petId: string in ipairs(data :: { string }) do
                    local PetButton = CachedPetButtons[petId]
                    if not PetButton then continue end

                    PetButton:Destroy()
                    PetButton.Parent = nil
                end

                slotsText.Text = `{InventoryGroup.RequestInventorySlots:invokeServer()} Pets`
            end
        )

        InventoryGroup.RemoveAllPetsFromInventory:onClientEvent(
            function(data)
                for i: string, PetButton: ImageLabel in pairs(CachedPetButtons) do
                    PetButton:Destroy()
                    PetButton.Parent = nil
                end

                slotsText.Text = `{InventoryGroup.RequestInventorySlots:invokeServer()} Pets`
            end
        )
    end

    -- Toggle buttons.
    do
        HandledUI:handleButtonPress(lockBtn,
            function(pos1: number, pos2: number) if not isDeleting then isLocking = not isLocking end end
        )

        HandledUI:handleButtonPress(deleteBtn,
            function(pos1: number, pos2: number)
                if not isLocking then isDeleting = not isDeleting else return end
                if isDeleting or #SelectedDeletingPets <= 0 then return end

                local AreYouSureHandledUI = UIUtilitiesLibrary("are_you_sure", AreYouSureComponents().areYouSure)
                AreYouSureHandledUI:hoverAndToggleSizing(1.05)

                AreYouSureComponents().container.Visible = true
                AreYouSureComponents().notificationText.Text = "Are you sure you want to delete the selected pets?<br /><br />This action cannot be undone."

                AreYouSureHandledUI:handleButtonPress(AreYouSureComponents().continueBtn,
                    function(pos1: number, pos2: number)
                        InventoryGroup.DeletePets:fireServer(SelectedDeletingPets)

                        AreYouSureComponents().container.Visible = false
                        AreYouSureHandledUI:destroy()

                        SelectedDeletingPets = {}
                    end
                )

                AreYouSureHandledUI:handleButtonPress(AreYouSureComponents().cancelBtn,
                    function(pos1: number, pos2: number)
                        for i: number, petId: string in ipairs(SelectedDeletingPets) do
                            local PetButton = CachedPetButtons[petId]
                            if not PetButton then continue end

                            local foundTick = PetButton:FindFirstChild("DeleteTick")
                            if foundTick then foundTick:Destroy() end
                        end

                        AreYouSureComponents().container.Visible = false
                        AreYouSureHandledUI:destroy()

                        SelectedDeletingPets = {}
                    end
                )
            end
        )

        HandledUI:handleButtonPress(expandBtn,
            function(pos1: number, pos2: number)
                isExpanded = not isExpanded

                if isExpanded then
                    for i: number, inst: Instance in ipairs(scrollingFrame:GetChildren()) do
                        if not inst:IsA("ImageLabel") then continue end
                        inst.Size = UDim2.fromScale(inst.Size.X.Scale / 2.04, inst.Size.Y.Scale / 2.025)
                    end
                else
                    for i: number, inst: Instance in ipairs(scrollingFrame:GetChildren()) do
                        if not inst:IsA("ImageLabel") then continue end
                        inst.Size = UDim2.fromScale(inst.Size.X.Scale * 2.04, inst.Size.Y.Scale * 2.025)
                    end
                end
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
                repeat task.wait() until clonedInventory.Enabled; task.wait()
                scrollingFrame.CanvasSize = UDim2.fromOffset(0, uiListLayout.AbsoluteContentSize.Y)
            end
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]