--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
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
local CachedPetDatasForExpanding: { [string]: PetSchema } = {}

local CurrentPetSchema: PetSchema?

local NEEDED_PETS_TO_MERGE = 9

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
    @usage Creates a notification.

    @param data number
    @param type "not_enough_pets" | "not_enough_gems"

    @return void
]]
local function createNotification(data: number?, type: "not_enough_pets" | "not_enough_gems" | "success", machineName: string)
    local HandledNotificationUI = UIUtilitiesLibrary("notification", NotificationComponents().notification)
    HandledNotificationUI:hoverAndToggleSizing(1.15)
    HandledNotificationUI:setFocus({ "Screen", "Notification", "AreYouSure", "TradeRequest" })

    if type == "not_enough_pets" then
        NotificationComponents().notificationText.Text = `Not enough pets to merge. <br /><br />You need to select {NEEDED_PETS_TO_MERGE - data :: number} more pets.`
    elseif type == "not_enough_gems" then
        NotificationComponents().notificationText.Text = `Not enough gems to merge. You need {5_000 - data :: number} more gems.`
    else
        NotificationComponents().notificationText.Text = `Successfully merged pets.`
    end

    HandledNotificationUI:handleButtonPress(NotificationComponents().okayBtn,
        function(pos1: number, pos2: number)
            HandledNotificationUI:removeFocus({ machineName })
            HandledNotificationUI:destroy()
        end
    )
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
    local expandBtn = containerFrame:WaitForChild("ExpandBtn") :: ImageButton

    textBox:GetPropertyChangedSignal("Text"):Connect(
        function()
            if CurrentPetSchema then
                MergingGroup.SearchForPetsByData:fireServer(CurrentPetSchema)
                return
            end

            MergingGroup.SearchForPetsByString:fireServer(textBox.Text)
        end
    )

    local HandledUI = UIUtilitiesLibrary("merging_machine", clonedMachine)
    HandledUI:hoverAndToggleSizing(1.15)
    HandledUI:handleButtonPress(closeBtn, function(pos1: number, pos2: number) end, true)

    local GameFolder = workspace:WaitForChild("Game") :: Folder
    local MachinesFolder = GameFolder:WaitForChild("Machines") :: Folder
    local mergingMachine = MachinesFolder:WaitForChild("MergingMachine") :: Part
    local proximityPrompt = mergingMachine:WaitForChild("ProximityPrompt") :: ProximityPrompt
    proximityPrompt.Triggered:Connect(function() HandledUI:setFocus({ "Screen", "Notification", "AreYouSure", "TradeRequest" }) end)

    -- Networking connections.
    do
        MergingGroup.AddPetsToMergingSlots:onClientEvent(
            function(data)
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
                    newPetLabel.ImageColor3 = COLOR_RARITY_MAP[PetSchema.PetStats.rarity]
                    newPetLabel.Parent = scrollingFrame
                    
                    if table.find(PetSchema.Locked or {}, i) then createTick(newPetLabel, "lock") end
                    if table.find(SelectedMergingPets, i) then createTick(newPetLabel, "selected") end

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
                        local t = 0
                        local gradient = Instance.new("UIGradient")
                        gradient.Parent = innerImgButton

                        local colorConnection: RBXScriptConnection

                        colorConnection = RunService.Heartbeat:Connect(
                            function(dt: number)
                                if not CachedPetButtons[i] then
                                    colorConnection:Disconnect()
                                    return
                                end

                                t = (t + dt * 0.25) % 1

                                if PetSchema.PetStats.color == "Rainbow" then
                                    gradient.Color = ColorSequence.new(
                                        {
                                            ColorSequenceKeypoint.new(0, Color3.fromHSV((t + 0) % 1, 1, 1)),
                                            ColorSequenceKeypoint.new(0.1, Color3.fromHSV((t + 0.1) % 1, 1, 1)),
                                            ColorSequenceKeypoint.new(0.2, Color3.fromHSV((t + 0.2) % 1, 1, 1)),
                                            ColorSequenceKeypoint.new(0.3, Color3.fromHSV((t + 0.3) % 1, 1, 1)),
                                            ColorSequenceKeypoint.new(0.4, Color3.fromHSV((t + 0.4) % 1, 1, 1)),
                                            ColorSequenceKeypoint.new(0.5, Color3.fromHSV((t + 0.5) % 1, 1, 1)),
                                            ColorSequenceKeypoint.new(0.6, Color3.fromHSV((t + 0.6) % 1, 1, 1)),
                                            ColorSequenceKeypoint.new(0.7, Color3.fromHSV((t + 0.7) % 1, 1, 1)),
                                            ColorSequenceKeypoint.new(0.8, Color3.fromHSV((t + 0.8) % 1, 1, 1)),
                                            ColorSequenceKeypoint.new(0.9, Color3.fromHSV((t + 0.9) % 1, 1, 1)),
                                            ColorSequenceKeypoint.new(1, Color3.fromHSV((t + 1) % 1, 1, 1))
                                        }
                                    )
                                elseif PetSchema.PetStats.color == "Radioactive" then
                                    gradient.Color = ColorSequence.new(
                                        {
                                            ColorSequenceKeypoint.new(0, radioactiveColor((t + 0) % 1)),
                                            ColorSequenceKeypoint.new(0.1, radioactiveColor((t + 0.1) % 1)),
                                            ColorSequenceKeypoint.new(0.2, radioactiveColor((t + 0.2) % 1)),
                                            ColorSequenceKeypoint.new(0.3, radioactiveColor((t + 0.3) % 1)),
                                            ColorSequenceKeypoint.new(0.4, radioactiveColor((t + 0.4) % 1)),
                                            ColorSequenceKeypoint.new(0.5, radioactiveColor((t + 0.5) % 1)),
                                            ColorSequenceKeypoint.new(0.6, radioactiveColor((t + 0.6) % 1)),
                                            ColorSequenceKeypoint.new(0.7, radioactiveColor((t + 0.7) % 1)),
                                            ColorSequenceKeypoint.new(0.8, radioactiveColor((t + 0.8) % 1)),
                                            ColorSequenceKeypoint.new(0.9, radioactiveColor((t + 0.9) % 1)),
                                            ColorSequenceKeypoint.new(1, radioactiveColor((t + 1) % 1))
                                        }
                                    )
                                elseif PetSchema.PetStats.color == "Glitched" then
                                    gradient.Color = ColorSequence.new(
                                        {
                                            ColorSequenceKeypoint.new(0, glitchedColor((t + 0) % 1)),
                                            ColorSequenceKeypoint.new(0.25, glitchedColor((t + 0.25) % 1)),
                                            ColorSequenceKeypoint.new(0.50, glitchedColor((t + 0.5) % 1)),
                                            ColorSequenceKeypoint.new(0.75, glitchedColor((t + 0.75) % 1)),
                                            ColorSequenceKeypoint.new(1, glitchedColor((t + 1) % 1))
                                        }
                                    )
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
                            if table.find(PetSchema.Locked or {}, i) then return end

                            -- Handle selection logic.
                            do
                                local foundPetIndex = table.find(SelectedMergingPets, i)

                                if foundPetIndex then
                                    local foundTick = newPetLabel:FindFirstChild("SelectedTick")
                                    if foundTick then foundTick:Destroy() end

                                    table.remove(SelectedMergingPets, foundPetIndex)
                                else
                                    if #SelectedMergingPets < NEEDED_PETS_TO_MERGE then
                                        table.insert(SelectedMergingPets, i)
                                        createTick(newPetLabel, "selected")
                                    end
                                end
                            end

                            if #SelectedMergingPets > 0 then
                                MergingGroup.SearchForPetsByData:fireServer(PetSchema)
                                CurrentPetSchema = PetSchema
                            else
                                MergingGroup.SearchForPetsByString:fireServer("")
                                CurrentPetSchema = nil
                            end
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

                    CachedPetButtons[petId] = nil
                    CachedPetDatasForExpanding[petId] = nil
                end
            end
        )

        MergingGroup.RemoveAllPetsFromMergingSlots:onClientEvent(
            function(data)
                for i: string, PetButton: ImageLabel in pairs(CachedPetButtons) do
                    PetButton:Destroy()
                    PetButton.Parent = nil

                    CachedPetButtons[i] = nil
                    CachedPetDatasForExpanding[i] = nil
                end
            end
        )

        MergingGroup.NotEnoughPetsToMerge:onClientEvent(function(data) createNotification(data, "not_enough_pets", clonedMachine.Name) end)
        MergingGroup.NotEnoughGemsToMerge:onClientEvent(function(data) createNotification(data, "not_enough_gems", clonedMachine.Name) end)
        MergingGroup.SuccessfullyMergedPets:onClientEvent(function(data) createNotification(data, "success", clonedMachine.Name) end)
    end

    local isExpanded = false

    HandledUI:handleButtonPress(mergeBtn,
        function(pos1: number, pos2: number)
            MergingGroup.MergePets:fireServer(SelectedMergingPets)
            MergingGroup.RequestMergingData:fireServer()

            SelectedMergingPets = {}
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

                SelectedMergingPets = {}
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