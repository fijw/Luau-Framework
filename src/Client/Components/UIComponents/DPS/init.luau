--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local SpawningSettings = require(ReplicatedStorage.SpawningSettings)

local InputMapper = require(StarterPlayer.StarterPlayerScripts.Libraries.InputMapper)
local UIUtilitiesLibrary = require(StarterPlayer.StarterPlayerScripts.Libraries.UILib)
local TweensLib = require(ReplicatedStorage.Libraries.TweensLib)

local Components = require(script.Components)
local NotificationComponents = require(StarterPlayer.StarterPlayerScripts.Components.UIComponents.Notification)

local DeveloperSpawningGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.DeveloperSpawning)
--[[ @end_section Imports ]]


type HandledTween = TweensLib.HandledTween


local localPlayer = Players.LocalPlayer :: Player
local PlayerGui = (if localPlayer then localPlayer:WaitForChild("PlayerGui") else nil) :: PlayerGui


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
--[[
    @usage Initialize the service.
    
    @return void
]]
local function constructorCallback()
    if not table.find(SpawningSettings, localPlayer:GetRankInGroupAsync(game.CreatorId)) then return end

    local clonedDevPetSpawning = Components.DevPetSpawning:Clone()
    clonedDevPetSpawning.Parent = PlayerGui

    local container = clonedDevPetSpawning:WaitForChild("Container") :: Frame
    local closeBtn = container:WaitForChild("CloseBtn") :: ImageButton
    local givePetBtn = container:WaitForChild("GivePetButton") :: ImageButton
    local mainFrame = container:WaitForChild("MainFrame") :: Frame
    local targetBox = mainFrame:WaitForChild("TargetBox") :: Frame
    local targetFrameBox = targetBox:WaitForChild("FrameBox") :: ImageLabel
    local targetTextBox = targetFrameBox:WaitForChild("TextBox") :: TextBox
    local petSizeBoxContainer = mainFrame:WaitForChild("PetSizeBoxContainer") :: Frame
    local petSizeBox = petSizeBoxContainer:WaitForChild("PetSizeBox") :: Frame
    local petSizeFrameBox = petSizeBox:WaitForChild("FrameBox") :: ImageLabel
    local petSizeTextBox = petSizeFrameBox:WaitForChild("TextBox") :: TextBox
    local petColorBoxContainer = mainFrame:WaitForChild("PetColorBoxContainer") :: Frame
    local petColorBox = petColorBoxContainer:WaitForChild("PetColorBox") :: Frame
    local petColorFrameBox = petColorBox:WaitForChild("FrameBox") :: ImageLabel
    local petColorTextBox = petColorFrameBox:WaitForChild("TextBox") :: TextBox
    local petNameBox = mainFrame:WaitForChild("PetNameBox") :: Frame
    local petNameFrameBox = petNameBox:WaitForChild("FrameBox") :: ImageLabel
    local petNameTextBox = petNameFrameBox:WaitForChild("TextBox") :: TextBox

    local HandledUI = UIUtilitiesLibrary("dev_pet_spawning", clonedDevPetSpawning)
    HandledUI:hoverAndToggleSizing(1.15)
    HandledUI:handleButtonPress(closeBtn, function(pos1: number, pos2: number) end, true)

    HandledUI:handleButtonPress(givePetBtn,
        function(pos1: number, pos2: number)
            DeveloperSpawningGroup.SpawnPet:fireServer(
                {
                    receiverId = tonumber(targetTextBox.Text) :: number,
                    petSize = petSizeTextBox.Text,
                    petColor = petColorTextBox.Text,
                    petName = petNameTextBox.Text
                }   
            )
        end
    )

    InputMapper(false, Enum.KeyCode.F4,
        function() if clonedDevPetSpawning.Enabled then HandledUI:removeFocus() else HandledUI:setFocus({ "Screen", "Notification", "AreYouSure" }) end end
    )

    DeveloperSpawningGroup.SendResults:onClientEvent(
        function(data)
            local HandledNotificationUI = UIUtilitiesLibrary("notification", NotificationComponents().notification)
            HandledNotificationUI:hoverAndToggleSizing(1.15)

            NotificationComponents().notificationText.Text = data
            NotificationComponents().container.Visible = true

            HandledNotificationUI:handleButtonPress(NotificationComponents().okayBtn,
                function(pos1: number, pos2: number)
                    NotificationComponents().container.Visible = false
                    HandledNotificationUI:destroy()
                end
            )
        end
    )

    -- Animations for closing and opening.
    do
        local originalContainerSize = container.Size

        HandledUI:subscribeToSetFocus("opening_subscription",
            function(self, NamesKeepingFocus)
                container.Size = UDim2.new(0, 0, 0, 0)

                tweenInst(
                    container,
                    
                    0.25,
                    "size",

                    originalContainerSize
                )
            end
        )

        HandledUI:subscribeToRemoveFocus("closing_subscription",
            function(self, NamesToBringBackToFocus)
                tweenInst(
                    container,
                    
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