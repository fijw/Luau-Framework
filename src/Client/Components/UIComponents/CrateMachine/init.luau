--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local UIUtilitiesLibrary = require(StarterPlayer.StarterPlayerScripts.Libraries.UILib)
local TweensLib = require(ReplicatedStorage.Libraries.TweensLib)

local Components = require(script.Components)
local NotificationComponents = require(StarterPlayer.StarterPlayerScripts.Components.UIComponents.Notification)

local UtilsComponent = require(StarterPlayer.StarterPlayerScripts.Components.UIComponents.UtilsComponent)

local CratesData = require(ReplicatedStorage.DataAssets.Crates.Data)
local PetsData = require(ReplicatedStorage.DataAssets.Pets.Data)

local PetSchemas = require(ReplicatedStorage.DataAssets.Pets.PetSchemas)

local CrateMachineGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.CrateMachine)
--[[ @end_section Imports ]]


type CrateSchema = CratesData.CrateSchema
type PetSchema = PetsData.PetSchema
type HandledTween = TweensLib.HandledTween
type HandledUI = UIUtilitiesLibrary.HandledUI


--[[ @section Variables ]]
local localPlayer = Players.LocalPlayer :: Player
local PlayerGui = (if localPlayer then localPlayer:WaitForChild("PlayerGui") else nil) :: PlayerGui

local CachedCrateFrames: { Frame } = {}
--[[ @end_section Variables ]]


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
    @usage Add crates to the machine.

    @param Crates { CrateSchema }

    @return void
]]
local function addCratesToMachine(crateFrame: Frame, Crates: { CrateSchema }, HandledUI: HandledUI)
    for i: number, Crate: CrateSchema in ipairs(Crates :: { CrateSchema }) do
        local clonedCrateFrame = crateFrame:Clone()
        clonedCrateFrame.Parent = crateFrame.Parent
        clonedCrateFrame.Name = Crate.name
        clonedCrateFrame.Visible = true

        local crateContainer = clonedCrateFrame:WaitForChild("CrateContainer") :: Frame

        local chancesContainer = crateContainer:WaitForChild("ChancesContainer") :: Frame
        local purchaseBtn = crateContainer:WaitForChild("PurchaseButton") :: ImageButton

        local crateName = crateContainer:WaitForChild("CrateName") :: TextLabel
        crateName.Text = Crate.name

        local priceText = crateContainer:WaitForChild("PriceText") :: TextLabel
        priceText.Text = `{Crate.price} Gems`

        local detailsContainer = chancesContainer:WaitForChild("DetailsContainer") :: Frame
        detailsContainer.Visible = false

        for petName: string, chance: number in pairs(Crate.Chances :: { [string]: number }) do
            local PetData = PetSchemas[petName]
            if not PetData then continue end

            local clonedDetailsContainer = detailsContainer:Clone()
            clonedDetailsContainer.Parent = chancesContainer
            clonedDetailsContainer.Name = petName
            clonedDetailsContainer.Visible = true
            
            local ImageLabel = clonedDetailsContainer:WaitForChild("ImageLabel") :: ImageLabel
            ImageLabel.ImageColor3 = UtilsComponent.COLOR_RARITY_MAP[PetData.PetStats.rarity]

            local petInnerImage = Instance.new("ImageLabel")
            petInnerImage.AnchorPoint = Vector2.new(0.5, 0.5)
            petInnerImage.Position = UDim2.fromScale(0.5, 0.5)
            petInnerImage.Parent = ImageLabel
            petInnerImage.BackgroundTransparency = 1
            petInnerImage.BorderSizePixel = 0
            petInnerImage.ZIndex = 2
            petInnerImage.Size = UDim2.fromScale(0.85, 0.85)
            petInnerImage.Image = PetData.petImageId
            
            local TextLabel = clonedDetailsContainer:WaitForChild("TextLabel") :: TextLabel
            TextLabel.Text = `{chance}%`
        end

        HandledUI:handleButtonPress(purchaseBtn,
            function(pos1: number, pos2: number) CrateMachineGroup.OpenCrate:fireServer(Crate.name) end
        )

        table.insert(CachedCrateFrames, clonedCrateFrame)
    end
end


--[[ @section Constructor ]]
--[[
    @usage Initialize the component.
    
    @return void
]]
local function constructorCallback()
    local clonedCrateMachine = Components.CrateMachine:Clone()
    clonedCrateMachine.Parent = PlayerGui

    local machineContainer = clonedCrateMachine:WaitForChild("Container") :: Frame
    local searchBox = machineContainer:WaitForChild("SearchBox") :: Frame
    local frameBox = searchBox:WaitForChild("FrameBox") :: ImageLabel
    local textBox = frameBox:WaitForChild("TextBox") :: TextBox
    local closeBtn = machineContainer:WaitForChild("CloseBtn") :: ImageButton
    local mainFrame = machineContainer:WaitForChild("MainFrame") :: Frame
    local innerContainer = mainFrame:WaitForChild("InnerContainer") :: Frame
    local scrollingFrame = innerContainer:WaitForChild("ScrollingFrame") :: ScrollingFrame
    local crateFrame = scrollingFrame:WaitForChild("CrateFrame") :: Frame

    textBox:GetPropertyChangedSignal("Text"):Connect(
        function()
            for i: number, crateFrame: Frame in ipairs(CachedCrateFrames) do crateFrame:Destroy() end

            addCratesToMachine(
                crateFrame,
                CrateMachineGroup.GetCrates:invokeServer(textBox.Text) :: { CrateSchema },
                UIUtilitiesLibrary("crate_machine", clonedCrateMachine)
            )
        end
    )

    local HandledUI = UIUtilitiesLibrary("crate_machine", clonedCrateMachine)
    HandledUI:hoverAndToggleSizing(1.15)
    HandledUI:handleButtonPress(closeBtn, function(pos1: number, pos2: number) end, true)

    local GameFolder = workspace:WaitForChild("Game") :: Folder
    local MachinesFolder = GameFolder:WaitForChild("Machines") :: Folder
    local crateMachine = MachinesFolder:WaitForChild("CrateMachine") :: Part
    local proximityPrompt = crateMachine:WaitForChild("ProximityPrompt") :: ProximityPrompt
    proximityPrompt.Triggered:Connect(function() HandledUI:setFocus({ "Screen", "Notification", "AreYouSure", "TradeRequest" }) end)

    local Crates = CrateMachineGroup.GetCrates:invokeServer()
    addCratesToMachine(crateFrame, Crates :: { CrateSchema }, HandledUI)

    -- Networking connections.
    do
        CrateMachineGroup.SendMaxPetsNotification:onClientEvent(
            function(data)
                local HandledNotificationUI = UIUtilitiesLibrary("notification", NotificationComponents().notification)
                HandledNotificationUI:hoverAndToggleSizing(1.15)
                HandledNotificationUI:setFocus({ "Screen", "Notification", "AreYouSure", "TradeRequest" })

                NotificationComponents().notificationText.Text = `You have used up all of your available pet slots.<br /><br />Please delete or trade pets to obtain more pet slots.`
                
                HandledNotificationUI:handleButtonPress(NotificationComponents().okayBtn,
                    function(pos1: number, pos2: number)
                        HandledNotificationUI:removeFocus({ clonedCrateMachine.Name })
                        HandledNotificationUI:destroy()
                    end
                )
            end
        )

        CrateMachineGroup.SendNotEnoughGemsNotification:onClientEvent(
            function(data)
                local HandledNotificationUI = UIUtilitiesLibrary("notification", NotificationComponents().notification)
                HandledNotificationUI:hoverAndToggleSizing(1.15)
                HandledNotificationUI:setFocus({ "Screen", "Notification", "AreYouSure", "TradeRequest" })
                
                NotificationComponents().notificationText.Text = `You don't have enough gems to open this crate.<br /><br />You need {data} more gems to be able to open this crate.`
                
                HandledNotificationUI:handleButtonPress(NotificationComponents().okayBtn,
                    function(pos1: number, pos2: number)
                        HandledNotificationUI:removeFocus({ clonedCrateMachine.Name })
                        HandledNotificationUI:destroy()
                    end
                )
            end
        )
    end

    -- Animations for closing and opening.
    do
        local originalContainerSize = machineContainer.Size

        HandledUI:subscribeToSetFocus("opening_subscription",
            function(self, NamesKeepingFocus)
                machineContainer.Size = UDim2.new(0, 0, 0, 0)

                tweenInst(
                    machineContainer,
                    
                    0.25,
                    "size",

                    originalContainerSize
                )
            end
        )

        HandledUI:subscribeToRemoveFocus("closing_subscription",
            function(self, NamesToBringBackToFocus)
                tweenInst(
                    machineContainer,
                    
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