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

local UIUtilitiesLibrary = require(StarterPlayer.StarterPlayerScripts.Libraries.UILib)
local TweensLib = require(ReplicatedStorage.Libraries.TweensLib)

local Data = require(ReplicatedStorage.Assets.Pets.Data)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type PetSizeTypes = "Default" | "Huge" | "Gigantic"

type PetSchema = Data.PetSchema
type HandledTween = TweensLib.HandledTween
--[[ @end_section Types ]]


local localPlayer = Players.LocalPlayer :: Player
local PlayerGui = (if localPlayer then localPlayer:WaitForChild("PlayerGui") else nil) :: PlayerGui
local PlrMouse = (if localPlayer then localPlayer:GetMouse() else nil) :: Mouse


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


--[[ @section Constructor ]]
local function constructorCallback()
    local clonedInventory = UIComponents.Inventory:Clone()
    clonedInventory.Parent = PlayerGui

    local containerFrame = clonedInventory:WaitForChild("ContainerFrame") :: Frame
    local searchBox = containerFrame:WaitForChild("SearchBox") :: Frame
    local closeBtn = containerFrame:WaitForChild("CloseBtn") :: ImageButton
    local buttonsFrame = containerFrame:WaitForChild("ButtonsFrame") :: ImageLabel
    local mainFrame = containerFrame:WaitForChild("MainFrame") :: ImageLabel
    local inventoryStatusContainer = mainFrame:WaitForChild("InventoryStatusContainer") :: Frame
    local equippedText = inventoryStatusContainer:WaitForChild("EquippedText") :: TextLabel
    local slotsText = inventoryStatusContainer:WaitForChild("SlotsText") :: TextLabel
    local scrollingFrame = mainFrame:WaitForChild("ScrollingFrame") :: ScrollingFrame
    local uiListLayout = scrollingFrame:WaitForChild("UIListLayout") :: UIListLayout
    local defaultPetButton = scrollingFrame:WaitForChild("Default") :: ImageLabel
    local hugePetButton = scrollingFrame:WaitForChild("Huge") :: ImageLabel
    local giganticPetButton = scrollingFrame:WaitForChild("Gigantic") :: ImageLabel

    local HandledUI = UIUtilitiesLibrary("inventory", clonedInventory)
    HandledUI:hoverAndToggleSizing(1.15)
    HandledUI:handleButtonPress(closeBtn, function(pos1: number, pos2: number) end, true)

    local petsCount = 0

    InventoryGroup.AddPetsToInventory:onClientEvent(
        function(data: { [string]: PetSchema })
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
                            PetDetailsComponents().mainFrame.Position = UDim2.fromOffset(PlrMouse.X, PlrMouse.Y)
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

            slotsText.Text = `{petsCount}/{InventoryGroup.RequestInventorySlots:invokeServer()} Pets`
            scrollingFrame.CanvasSize = UDim2.fromOffset(0, uiListLayout.AbsoluteContentSize.Y)
        end
    )

    InventoryGroup.RemovePetsFromInventory:onClientEvent(
        function(data: { string })
            for i: number, petId: string in ipairs(data :: { string }) do
                local PetButton = scrollingFrame:FindFirstChild(petId)
                if not PetButton then continue end

                PetButton:Destroy()
                PetButton.Parent = nil
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