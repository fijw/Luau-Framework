--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local UIComponents = require(script.Components)

local UIUtilitiesLibrary = require(StarterPlayer.StarterPlayerScripts.Libraries.UILib)
local TweensLib = require(ReplicatedStorage.Libraries.TweensLib)

local StatsUpdatingGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.StatsUpdating)
--[[ @end_section Imports ]]


type HandledTween = TweensLib.HandledTween
type HandledUI = UIUtilitiesLibrary.HandledUI


local localPlayer = Players.LocalPlayer :: Player
local PlayerGui = (if localPlayer then localPlayer:WaitForChild("PlayerGui") else nil) :: PlayerGui


--[[ @section Utility Functions ]]
--[[
    @usage Sets the focus of a HandledUI.

    @param screen ScreenGui
    @param name string

    @return void
]]
local function setFocus(screen: ScreenGui, name: string, keepHudFocus: boolean)
    local CachedClass = UIUtilitiesLibrary.CachedUIClasses[name]
    if not CachedClass then return end

    if CachedClass.ScreenGui.Enabled then CachedClass:removeFocus(); return end
    CachedClass:setFocus(if keepHudFocus then { screen.Name, "Notification", "AreYouSure", "TradeRequest" } else nil)
end

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
--[[ @end_section Utility Functions ]]


--[[ @section Constructor ]]
--[[
    @usage Initialize the component.
    
    @return void
]]
local function constructorCallback()
    repeat task.wait() until not UIUtilitiesLibrary.CachedUIClasses.loading_screen

    local clonedScreen = UIComponents.Screen:Clone()
    clonedScreen.Enabled = true
    clonedScreen.Parent = PlayerGui

    local menuContainer = clonedScreen:WaitForChild("MenuContainer") :: Frame
    local teleportBtn = clonedScreen:WaitForChild("TeleportBtn") :: ImageButton
    local inventoryBtn = menuContainer:WaitForChild("InventoryBtn") :: ImageButton
    local tradingBtn = menuContainer:WaitForChild("TradingBtn") :: ImageButton
    local rebirthBtn = menuContainer:WaitForChild("RebirthBtn") :: ImageButton
    local shopBtn = menuContainer:WaitForChild("ShopBtn") :: ImageButton
    local marketplaceBtn = menuContainer:WaitForChild("MarketplaceBtn") :: ImageButton
    local settingsBtn = menuContainer:WaitForChild("SettingsBtn") :: ImageButton
    local statsContainer = clonedScreen:WaitForChild("StatsContainer") :: Frame
    local gemsDisplay = statsContainer:WaitForChild("GemsDisplay") :: ImageLabel
    local gemsText = gemsDisplay:WaitForChild("GemsText") :: TextLabel
    local rebirthsDisplay = statsContainer:WaitForChild("RebirthsDisplay") :: ImageLabel
    local rebirthsText = rebirthsDisplay:WaitForChild("RebirthsText") :: TextLabel
    local levelsDisplay = statsContainer:WaitForChild("LevelsDisplay") :: ImageLabel
    local levelText = levelsDisplay:WaitForChild("LevelText") :: TextLabel
    local xpToNextLevelText = levelsDisplay:WaitForChild("XPToNextLevelText") :: TextLabel
    local levelsToRebirthText = rebirthsDisplay:WaitForChild("LevelsToRebirthText") :: TextLabel

    -- Opening animations.
    do
        local originalMenuSize, originalStatsSize, originalTeleportSize = menuContainer.Size, statsContainer.Size, teleportBtn.Size
        menuContainer.Size = UDim2.fromScale(0, 0)
        statsContainer.Size = UDim2.fromScale(0, 0)
        teleportBtn.Size = UDim2.fromScale(0, 0)

        tweenInst(menuContainer, 0.25, "size", originalMenuSize)
        tweenInst(statsContainer, 0.25, "size", originalStatsSize)
        tweenInst(teleportBtn, 0.25, "size", originalTeleportSize)
    end

    local HideAndShowBarButtons = { tradingBtn, rebirthBtn, shopBtn, marketplaceBtn, settingsBtn }
    for i: number, button: ImageButton in ipairs(HideAndShowBarButtons) do button.Visible = false end

    local HideAndShowButtonPositions
    = {
        [tradingBtn] = tradingBtn.Position,
        [rebirthBtn] = rebirthBtn.Position,
        [shopBtn] = shopBtn.Position,
        [marketplaceBtn] = marketplaceBtn.Position,
        [settingsBtn] = settingsBtn.Position
    }

    StatsUpdatingGroup.UpdateStats:onClientEvent(
        function(data)
            gemsText.Text = `{data.gems}`
            rebirthsText.Text = `{data.rebirths}`
            levelText.Text = `{data.levels}`
            xpToNextLevelText.Text = `{data.xp}/{data.xpToNextLevel} XP`
            levelsToRebirthText.Text = `{data.levels}/{data.levelsToRebirth} Levels`
        end
    )

    local HandledUi = UIUtilitiesLibrary("hud", clonedScreen)
    HandledUi:hoverAndToggleSizing(1.15)

    local oldInvBtnPos = inventoryBtn.Position
    inventoryBtn.Position = UDim2.new(0.5, 0, 0.5, 0)

    -- HUD button presses.
    do
        HandledUi:handleButtonPress(inventoryBtn,
            function(pos1: number, pos2: number) setFocus(clonedScreen, "inventory", true) end
        )

        HandledUi:handleButtonPress(tradingBtn,
            function(pos1: number, pos2: number) setFocus(clonedScreen, "send_trade", true) end
        )

        HandledUi:handleButtonPress(rebirthBtn,
            function(pos1: number, pos2: number) setFocus(clonedScreen, "rebirth", true) end
        )

        HandledUi:handleButtonPress(shopBtn,
            function(pos1: number, pos2: number) setFocus(clonedScreen, "shop", true) end
        )

        HandledUi:handleButtonPress(marketplaceBtn,
            function(pos1: number, pos2: number) setFocus(clonedScreen, "marketplace", true) end
        )

        HandledUi:handleButtonPress(settingsBtn,
            function(pos1: number, pos2: number) setFocus(clonedScreen, "settings", true) end
        )
    end

    local SubscribingUINames = { "inventory", "send_trade", "rebirth" }

    for i: number, str: string in ipairs(SubscribingUINames) do
        local CachedClass = UIUtilitiesLibrary.CachedUIClasses[str]

        if not CachedClass then
            repeat task.wait() until UIUtilitiesLibrary.CachedUIClasses[str]
            CachedClass = UIUtilitiesLibrary.CachedUIClasses[str]
        end

        CachedClass:subscribeToRemoveFocus("screen_subscription",
            function(self, NamesToBringBackToFocus)
                if NamesToBringBackToFocus then return end
                tweenInst(inventoryBtn, 0.25, "pos", UDim2.new(0.5, 0, 0.5, 0))

                for i: number, button: ImageButton in ipairs(HideAndShowBarButtons) do
                    task.spawn(
                        function()
                            tweenInst(button, 0.25, "trans", 1)
                            tweenInst(button, 0.25, "pos", UDim2.new(0.5, 0, 0.5, 0)):waitForCompletion()

                            button.Visible = false
                        end
                    )
                end
            end
        )

        CachedClass:subscribeToSetFocus("screen_subscription",
            function(self, NamesKeepingFocus)
                tweenInst(inventoryBtn, 0.25, "pos", oldInvBtnPos)
                
                for i: number, button: ImageButton in ipairs(HideAndShowBarButtons) do
                    button.Visible = true

                    tweenInst(button, 0.25, "pos", HideAndShowButtonPositions[button])
                    tweenInst(button, 0.25, "trans", 0)
                end
            end
        )
    end

    -- Waiting for the waiting classes to exist.
    do
        local WaitingClasses = { "healing_machine", "merging_machine", "crate_machine", "in_trade" }

        for i: number, str: string in ipairs(WaitingClasses) do
            repeat task.wait() until UIUtilitiesLibrary.CachedUIClasses[str]
        end
    end

    for i: string, CachedClass: HandledUI in pairs(UIUtilitiesLibrary.CachedUIClasses) do
        if table.find(SubscribingUINames, i) then continue end

        CachedClass:subscribeToSetFocus("screen_subscription",
            function(self, NamesKeepingFocus)
                tweenInst(inventoryBtn, 0.25, "pos", UDim2.new(0.5, 0, 0.5, 0))

                for i: number, button: ImageButton in ipairs(HideAndShowBarButtons) do
                    task.spawn(
                        function()
                            tweenInst(button, 0.25, "trans", 1)
                            tweenInst(button, 0.25, "pos", UDim2.new(0.5, 0, 0.5, 0)):waitForCompletion()

                            button.Visible = false
                        end
                    )
                end
            end
        )
    end
end

return constructorCallback
--[[ @end_section Constructor ]]