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


local localPlayer = Players.LocalPlayer :: Player
local PlayerGui = (if localPlayer then localPlayer:WaitForChild("PlayerGui") else nil) :: PlayerGui


--[[ @section Utility Functions ]]
--[[
    @usage Sets the focus of a HandledUI.

    @param HUD ScreenGui
    @param name string

    @return void
]]
local function setFocus(HUD: ScreenGui, name: string, keepHudFocus: boolean)
    local CachedClass = UIUtilitiesLibrary.CachedUIClasses[name]
    if not CachedClass then return end

    if CachedClass.ScreenGui.Enabled then CachedClass:removeFocus(); return end
    CachedClass:setFocus(if keepHudFocus then { HUD.Name } else nil)
end

--[[
    @usage Tweens an instance.

    @param inst GuiObject
    @param timeInput number
    @param type "pos" | "trans"
    @param input number | UDim2

    @return HandledTween
]]
local function tweenInst(inst: GuiObject, timeInput: number, type: "pos" | "trans", input: number | UDim2): HandledTween
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
            ImageTransparency = if type == "trans" then input else nil
        }
    )

    return HandledTween
end
--[[ @end_section Utility Functions ]]


--[[ @section Constructor ]]
local function constructorCallback()
    local clonedHUD = UIComponents.HUD:Clone()
    clonedHUD.Enabled = true
    clonedHUD.Parent = PlayerGui

    local menuContainer = clonedHUD:WaitForChild("MenuContainer") :: Frame
    local inventoryBtn = menuContainer:WaitForChild("InventoryBtn") :: ImageButton
    local tradingBtn = menuContainer:WaitForChild("TradingBtn") :: ImageButton
    local rebirthBtn = menuContainer:WaitForChild("RebirthBtn") :: ImageButton
    local shopBtn = menuContainer:WaitForChild("ShopBtn") :: ImageButton
    local marketplaceBtn = menuContainer:WaitForChild("MarketplaceBtn") :: ImageButton
    local settingsBtn = menuContainer:WaitForChild("SettingsBtn") :: ImageButton
    local statsContainer = clonedHUD:WaitForChild("StatsContainer") :: Frame
    local gemsDisplay = statsContainer:WaitForChild("GemsDisplay") :: ImageLabel
    local gemsText = gemsDisplay:WaitForChild("GemsText") :: TextLabel
    local rebirthsDisplay = statsContainer:WaitForChild("RebirthsDisplay") :: ImageLabel
    local rebirthsText = rebirthsDisplay:WaitForChild("RebirthsText") :: TextLabel
    local levelsDisplay = statsContainer:WaitForChild("LevelsDisplay") :: ImageLabel
    local levelText = levelsDisplay:WaitForChild("LevelText") :: TextLabel
    local xpToNextLevelText = levelsDisplay:WaitForChild("XPToNextLevelText") :: TextLabel
    local levelsToRebirthText = rebirthsDisplay:WaitForChild("LevelsToRebirthText") :: TextLabel

    local HideAndShowButtons = { tradingBtn, rebirthBtn, shopBtn, marketplaceBtn, settingsBtn }
    for i: number, button: ImageButton in ipairs(HideAndShowButtons) do button.Visible = false end

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

    local HandledUi = UIUtilitiesLibrary("hud", clonedHUD)
    HandledUi:hoverAndToggleSizing(1.15)

    local oldInvBtnPos = inventoryBtn.Position
    tweenInst(inventoryBtn, 0.25, "pos", UDim2.new(0.5, 0, 0.5, 0))

    -- HUD button presses.
    do
        HandledUi:handleButtonPress(inventoryBtn,
            function(pos1: number, pos2: number) setFocus(clonedHUD, "inventory", true) end
        )

        HandledUi:handleButtonPress(tradingBtn,
            function(pos1: number, pos2: number) setFocus(clonedHUD, "send_trade", true) end
        )

        HandledUi:handleButtonPress(rebirthBtn,
            function(pos1: number, pos2: number) setFocus(clonedHUD, "rebirth", true) end
        )

        HandledUi:handleButtonPress(shopBtn,
            function(pos1: number, pos2: number) setFocus(clonedHUD, "shop", true) end
        )

        HandledUi:handleButtonPress(marketplaceBtn,
            function(pos1: number, pos2: number) setFocus(clonedHUD, "marketplace", true) end
        )

        HandledUi:handleButtonPress(settingsBtn,
            function(pos1: number, pos2: number) setFocus(clonedHUD, "crate_machine", true) end
        )
    end

    for i: number, str: string in ipairs({ "inventory", "send_trade", "rebirth", "shop", "marketplace", "settings" }) do
        local CachedClass = UIUtilitiesLibrary.CachedUIClasses[str]
        if not CachedClass then continue end

        CachedClass:subscribeToRemoveFocus("hud_subscription",
            function(self, NamesToBringBackToFocus)
                if NamesToBringBackToFocus then return end
                tweenInst(inventoryBtn, 0.25, "pos", UDim2.new(0.5, 0, 0.5, 0))

                for i: number, button: ImageButton in ipairs(HideAndShowButtons) do
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

        CachedClass:subscribeToSetFocus("hud_subscription",
            function(self, NamesKeepingFocus)
                tweenInst(inventoryBtn, 0.25, "pos", oldInvBtnPos)
                
                for i: number, button: ImageButton in ipairs(HideAndShowButtons) do
                    button.Visible = true

                    tweenInst(button, 0.25, "pos", HideAndShowButtonPositions[button])
                    tweenInst(button, 0.25, "trans", 0)
                end
            end
        )
    end
end

return constructorCallback
--[[ @end_section Constructor ]]