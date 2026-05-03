--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Components = require(script.Components)
local RebirthingGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.Rebirthing)

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
    local clonedRebirth = Components.Rebirth
    clonedRebirth.Parent = PlayerGui

    local containerFrame = clonedRebirth:WaitForChild("Container") :: Frame
    local closeBtn = containerFrame:WaitForChild("CloseBtn") :: ImageButton
    local mainFrame = containerFrame:WaitForChild("MainFrame") :: ImageLabel
    local rebirthBtn = mainFrame:WaitForChild("RebirthBtn") :: ImageButton
    local rebirthStatsContainer = mainFrame:WaitForChild("RebirthStatsContainer") :: Frame
    local priceText = rebirthStatsContainer:WaitForChild("PriceText") :: TextLabel
    local levelsTxt = rebirthStatsContainer:WaitForChild("LevelsTxt") :: TextLabel
    local multiplierText = rebirthStatsContainer:WaitForChild("MultiplierText") :: TextLabel

    local HandledUI = UIUtilitiesLibrary("rebirth", clonedRebirth)
    HandledUI:hoverAndToggleSizing(1.15)
    HandledUI:handleButtonPress(closeBtn, function(pos1: number, pos2: number) end, true)
    HandledUI:handleButtonPress(rebirthBtn, function(pos1: number, pos2: number) RebirthingGroup.Rebirth:fireServer() end)

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

                local RebirthStats = RebirthingGroup.GetRebirthStats:invokeServer()
                if not RebirthStats then return end

                priceText.Text = `Rebirth Price: {RebirthStats.price} Gems`
                levelsTxt.Text = `Levels Needed: {RebirthStats.neededLevels}`
                multiplierText.Text = `Current Gems Multiplier: {if RebirthStats.coinsMultiplier == 0 then 1 else RebirthStats.coinsMultiplier}x`
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