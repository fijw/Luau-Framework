--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local TweenService = game:GetService("TweenService")

local InventoryGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.Inventory)
local PetsHandlingGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.PetsHandling)

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
local CachedPetDatasForExpanding: { [string]: PetSchema } = {}

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
    newTick.Image = if type == "lock" then "rbxassetid://138368172974659" elseif type == "selected" then "rbxassetid://120401071933338" else "rbxassetid://138335893507994"
    newTick.BackgroundTransparency = 1
    newTick.BorderSizePixel = 0
    newTick.Position = if type == "lock" or type == "delete" then UDim2.new(0, 0, 0, 0) else UDim2.new(0.65, 0, 0, 0)
    newTick.Size = UDim2.new(0.35, 0, 0.35, 0)
    newTick.Name = if type == "lock" then "LockTick" elseif type == "selected" then "SelectTick" else "DeleteTick"
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


--[[ @section Constructor ]]
--[[
    @usage Initialize the component.
    
    @return void
]]
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
        InventoryGroup.UpdatePetsEquippedText:onClientEvent(function(data) equippedText.Text = `{data} Pets Equipped` end)

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
                    newPetLabel.ImageColor3 = COLOR_RARITY_MAP[PetSchema.PetStats.rarity]

                    if PetSchema.Locked then if table.find(PetSchema.Locked, i) then createTick(newPetLabel, "lock") end end
                    if PetSchema.Equipped then if table.find(PetSchema.Equipped, i) then createTick(newPetLabel, "selected") end end

                    local innerImgButton = Instance.new("ImageButton")
                    innerImgButton.AnchorPoint = Vector2.new(0.5, 0.5)
                    innerImgButton.Position = UDim2.fromScale(0.5, 0.5)
                    innerImgButton.Parent = newPetLabel
                    innerImgButton.BackgroundTransparency = 1
                    innerImgButton.BorderSizePixel = 0
                    innerImgButton.ZIndex = 2
                    innerImgButton.Size = UDim2.fromScale(0.85, 0.85)
                    innerImgButton.Image = PetSchema.petImageId

                    CachedPetButtons[i] = newPetLabel
                    CachedPetDatasForExpanding[i] = PetSchema

                    if PetSchema.PetStats.color == "Rainbow"
                        or PetSchema.PetStats.color == "Radioactive"
                        or PetSchema.PetStats.color == "Glitched"
                    then
                        local colorOffset = 0

                        local gradient = Instance.new("UIGradient")
                        gradient.Rotation = 40
                        gradient.Parent = innerImgButton

                        local colorConnection: RBXScriptConnection

                        colorConnection = RunService.Heartbeat:Connect(
                            function(dt: number)
                                if not CachedPetButtons[i] then colorConnection:Disconnect(); return end

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

                    HandledUI:handleButtonPress(innerImgButton,
                        function(pos1: number, pos2: number)
                            if isLocking then
                                local foundIdIndex = if PetSchema.Locked then table.find(PetSchema.Locked, i) else nil

                                if not foundIdIndex then
                                    if PetSchema.Locked then table.insert(PetSchema.Locked, i) end

                                    InventoryGroup.LockPet:fireServer(i)
                                    createTick(newPetLabel, "lock")
                                else
                                    if PetSchema.Locked then table.remove(PetSchema.Locked, foundIdIndex) end
                                    InventoryGroup.LockPet:fireServer(i)
                                    
                                    local foundTick = newPetLabel:FindFirstChild("LockTick")
                                    if foundTick then foundTick:Destroy() end
                                end

                                return
                            elseif isDeleting then
                                if PetSchema.Locked then if table.find(PetSchema.Locked, i) then return end end

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

                                return
                            end

                            -- Add or remove the pet from the equipped list.
                            do
                                local foundEquipIndex = table.find(PetSchema.Equipped or {}, i)

                                if foundEquipIndex then
                                    local status = PetsHandlingGroup.UnequipPet:invokeServer(i)
                                    if status then table.remove(PetSchema.Equipped or {}, foundEquipIndex) end

                                    local foundTick = newPetLabel:FindFirstChild("SelectTick")
                                    if status and foundTick then foundTick:Destroy() end
                                else
                                    local status = PetsHandlingGroup.EquipPet:invokeServer(i)

                                    if status then
                                        table.insert(PetSchema.Equipped or {}, i)
                                        createTick(newPetLabel, "selected")
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

                    CachedPetButtons[petId] = nil
                    CachedPetDatasForExpanding[petId] = nil
                end

                slotsText.Text = `{InventoryGroup.RequestInventorySlots:invokeServer()} Pets`
            end
        )

        InventoryGroup.RemoveAllPetsFromInventory:onClientEvent(
            function(data)
                for i: string, PetButton: ImageLabel in pairs(CachedPetButtons) do
                    PetButton:Destroy()
                    PetButton.Parent = nil

                    CachedPetButtons[i] = nil
                    CachedPetDatasForExpanding[i] = nil
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
                AreYouSureHandledUI:setFocus( { "Screen", "Notification", "AreYouSure", "TradeRequest" } )
                
                AreYouSureComponents().notificationText.Text = "Are you sure you want to delete the selected pets?<br /><br />This action cannot be undone."

                AreYouSureHandledUI:handleButtonPress(AreYouSureComponents().continueBtn,
                    function(pos1: number, pos2: number)
                        InventoryGroup.DeletePets:fireServer(SelectedDeletingPets)

                        AreYouSureHandledUI:removeFocus({ clonedInventory.Name })
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

                        AreYouSureHandledUI:removeFocus({ clonedInventory.Name })
                        AreYouSureHandledUI:destroy()

                        SelectedDeletingPets = {}
                    end
                )
            end
        )

        HandledUI:handleButtonPress(expandBtn,
            function(pos1: number, pos2: number)
                isExpanded = not isExpanded

                local ExpandingNums
                = {
                    gigantic = 2.04,
                    huge = 2.08,
                    default = 2.17
                }

                if isExpanded then
                    for i: number, inst: Instance in ipairs(scrollingFrame:GetChildren()) do
                        if not inst:IsA("ImageLabel") then continue end
                        expandItems(inst, ExpandingNums, true)
                    end
                else
                    for i: number, inst: Instance in ipairs(scrollingFrame:GetChildren()) do
                        if not inst:IsA("ImageLabel") then continue end
                        expandItems(inst, ExpandingNums, false)
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

                SelectedDeletingPets = {}
                InventoryGroup.SearchForPets:fireServer("")
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

                textBox.Text = ""
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