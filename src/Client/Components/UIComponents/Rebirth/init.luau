--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local Components = require(script.Components)
local NotificationComponents = require(StarterPlayer.StarterPlayerScripts.Components.UIComponents.Notification)

local RebirthingGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.Rebirthing)

local UIUtilitiesLibrary = require(StarterPlayer.StarterPlayerScripts.Libraries.UILib)
local TweensLib = require(ReplicatedStorage.Libraries.TweensLib)
local NumberFormatLib = require(ReplicatedStorage.Libraries.NumberLibs.NumberFormatLib)

local Data = require(ReplicatedStorage.DataAssets.Pets.Data)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type PetSizeTypes = "Default" | "Huge" | "Gigantic"

type PetSchema = Data.PetSchema
type HandledTween = TweensLib.HandledTween
--[[ @end_section Types ]]


local localPlayer = Players.LocalPlayer :: Player
local PlayerGui = (if localPlayer then localPlayer:WaitForChild("PlayerGui") else nil) :: PlayerGui


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
    @usage Updates the rebirth stats texts.

    @param priceText TextLabel
    @param levelsTxt TextLabel
    @param multiplierText TextLabel

    @return void
]]
local function updateRebirthStats(priceText: TextLabel, levelsTxt: TextLabel, multiplierText: TextLabel): ()
    local RebirthStats = RebirthingGroup.GetRebirthStats:invokeServer()
    if not RebirthStats then return end

    priceText.Text = `Rebirth Price: {NumberFormatLib(RebirthStats.price, "quintillions")} Gems`
    levelsTxt.Text = `Levels Needed: {NumberFormatLib(RebirthStats.neededLevels, "quintillions")}`
    multiplierText.Text = `Current Gems Multiplier: {if RebirthStats.coinsMultiplier == 0 then 1 else RebirthStats.coinsMultiplier}x`
end
--[[ @end_section Utility Functions ]]


--[[ @section Constructor ]]
--[[
    @usage Initialize the component.
    
    @return void
]]
local function constructorCallback(): ()
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
    HandledUI:handleButtonPress(closeBtn, function(pos1: number, pos2: number): () end, true)
    HandledUI:handleButtonPress(rebirthBtn, function(pos1: number, pos2: number): () RebirthingGroup.Rebirth:fireServer() end)

    -- Networking connections.
    do
        RebirthingGroup.NotEnoughGemsToRebirth:onClientEvent(
            function(data): ()
                local HandledNotificationUI = UIUtilitiesLibrary("notification", NotificationComponents().notification)
                HandledNotificationUI:hoverAndToggleSizing(1.15)
                HandledNotificationUI:setFocus({ "Screen", "Notification", "AreYouSure", "TradeRequest" })
                
                NotificationComponents().notificationText.Text = `Not enough gems to rebirth.<br /><br />You need {NumberFormatLib(data, "quintillions")} more gems to be able to rebirth.`
                
                HandledNotificationUI:handleButtonPress(NotificationComponents().okayBtn,
                    function(pos1: number, pos2: number): ()
                        HandledNotificationUI:removeFocus({ clonedRebirth.Name })
                        HandledNotificationUI:destroy()
                    end
                )
            end
        )

        RebirthingGroup.NotEnoughLevelsToRebirth:onClientEvent(
            function(data): ()
                local HandledNotificationUI = UIUtilitiesLibrary("notification", NotificationComponents().notification)
                HandledNotificationUI:hoverAndToggleSizing(1.15)
                HandledNotificationUI:setFocus({ "Screen", "Notification", "AreYouSure", "TradeRequest" })

                NotificationComponents().notificationText.Text = `Not enough levels to rebirth.<br /><br />You need {NumberFormatLib(data, "quintillions")} more levels to be able to rebirth.`
                
                HandledNotificationUI:handleButtonPress(NotificationComponents().okayBtn,
                    function(pos1: number, pos2: number): ()
                        HandledNotificationUI:removeFocus({ clonedRebirth.Name })
                        HandledNotificationUI:destroy()
                    end
                )
            end
        )

        RebirthingGroup.MaxRebirthsReached:onClientEvent(
            function(data): ()
                local HandledNotificationUI = UIUtilitiesLibrary("notification", NotificationComponents().notification)
                HandledNotificationUI:hoverAndToggleSizing(1.15)
                HandledNotificationUI:setFocus({ "Screen", "Notification", "AreYouSure", "TradeRequest" })

                NotificationComponents().notificationText.Text = `You have reached the maximum amount of rebirths.`
                
                HandledNotificationUI:handleButtonPress(NotificationComponents().okayBtn,
                    function(pos1: number, pos2: number): ()
                        HandledNotificationUI:removeFocus({ clonedRebirth.Name })
                        HandledNotificationUI:destroy()
                    end
                )
            end
        )

        RebirthingGroup.SuccessfullyRebirthed:onClientEvent(
            function(data): ()
                local HandledNotificationUI = UIUtilitiesLibrary("notification", NotificationComponents().notification)
                HandledNotificationUI:hoverAndToggleSizing(1.15)
                HandledNotificationUI:setFocus({ "Screen", "Notification", "AreYouSure", "TradeRequest" })

                NotificationComponents().notificationText.Text = `You have successfully rebirthed.<br /><br />You now have {data} rebirths.`
                
                HandledNotificationUI:handleButtonPress(NotificationComponents().okayBtn,
                    function(pos1: number, pos2: number): ()
                        HandledNotificationUI:removeFocus({ clonedRebirth.Name })
                        HandledNotificationUI:destroy()
                    end
                )

                updateRebirthStats(priceText, levelsTxt, multiplierText)
            end
        )
    end

    -- Animations for closing and opening.
    do
        local originalContainerSize = containerFrame.Size

        HandledUI:subscribeToSetFocus("opening_subscription",
            function(self, NamesKeepingFocus): ()
                containerFrame.Size = UDim2.new(0, 0, 0, 0)

                tweenInst(
                    containerFrame,
                    
                    0.25,
                    "size",

                    originalContainerSize
                )

                updateRebirthStats(priceText, levelsTxt, multiplierText)
            end
        )

        HandledUI:subscribeToRemoveFocus("closing_subscription",
            function(self, NamesToBringBackToFocus): ()
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