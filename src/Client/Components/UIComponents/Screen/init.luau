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
local NumberFormatLib = require(ReplicatedStorage.Libraries.NumberLibs.NumberFormatLib)

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
local function setFocus(screen: ScreenGui, name: string, IconsMap: { [ImageButton]: { enabled: string, disabled: string, isEnabled: boolean } })
    local CachedClass = UIUtilitiesLibrary.CachedUIClasses[name]
    if not CachedClass then return end

    if CachedClass.ScreenGui.Enabled then CachedClass:removeFocus(); return end
    CachedClass:setFocus({ screen.Name, "Notification", "AreYouSure", "TradeRequest" })

    for i: ImageButton, ButtonImages: { enabled: string, disabled: string, isEnabled: boolean } in pairs(IconsMap) do
        i.Image = ButtonImages.disabled; ButtonImages.isEnabled = false
    end
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

    local oldInvBtnPos = inventoryBtn.Position
    inventoryBtn.Position = UDim2.new(0.5, 0, 0.5, 0)

    local HideAndShowBarButtons = { tradingBtn, rebirthBtn, shopBtn, marketplaceBtn, settingsBtn }
    for i: number, button: ImageButton in ipairs(HideAndShowBarButtons) do button.Visible = false end

    -- Opening animations.
    do
        local originalMenuSize, originalStatsSize, originalTeleportSize = menuContainer.Size, statsContainer.Size, teleportBtn.Size
        menuContainer.Size = UDim2.fromScale(0, 0)
        statsContainer.Size = UDim2.fromScale(0, 0)
        teleportBtn.Size = UDim2.fromScale(0, 0)

        tweenInst(menuContainer, 0.25, "size", originalMenuSize)
        tweenInst(statsContainer, 0.25, "size", originalStatsSize)
        tweenInst(teleportBtn, 0.25, "size", originalTeleportSize):waitForCompletion()
    end

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
            gemsText.Text = `{NumberFormatLib(data.gems, "millions")}`
            rebirthsText.Text = `{NumberFormatLib(data.rebirths, "millions")}`
            levelText.Text = `{NumberFormatLib(data.levels, "millions")}`
            xpToNextLevelText.Text = `{NumberFormatLib(data.xp, "thousands")}/{NumberFormatLib(data.xpToNextLevel, "thousands")} XP`
            levelsToRebirthText.Text = `{NumberFormatLib(data.levels, "thousands")}/{NumberFormatLib(data.levelsToRebirth, "thousands")} Levels`
        end
    )

    local HandledUi = UIUtilitiesLibrary("hud", clonedScreen)
    HandledUi:hoverAndToggleSizing(1.15)

    local IconsMap
    = {
        [inventoryBtn]
        = {
            enabled = "rbxassetid://100037931807896",
            disabled = "rbxassetid://119870862470846",

            isEnabled = false
        },

        [tradingBtn] 
        = {
            enabled = "rbxassetid://76990884660766",
            disabled = "rbxassetid://96262129570992",

            isEnabled = false
        },
        
        [rebirthBtn]
        = {
            enabled = "rbxassetid://110915461713426",
            disabled = "rbxassetid://133561204302109",

            isEnabled = false
        },

        [shopBtn]
        = {
            enabled = "rbxassetid://100341378788871",
            disabled = "rbxassetid://138187189416512",

            isEnabled = false
        },

        [marketplaceBtn]
        = {
            enabled = "rbxassetid://105974130730597",
            disabled = "rbxassetid://92171331943586",

            isEnabled = false
        },

        [settingsBtn]
        = {
            enabled = "rbxassetid://78676120329471",
            disabled = "rbxassetid://94060889590777",

            isEnabled = false
        }
    }

    -- HUD button presses.
    do
        HandledUi:handleButtonPress(inventoryBtn,
            function(pos1: number, pos2: number)
                setFocus(clonedScreen, "inventory", IconsMap); IconsMap[inventoryBtn].isEnabled = not IconsMap[inventoryBtn].isEnabled

                if IconsMap[inventoryBtn].isEnabled then
                    inventoryBtn.Image = IconsMap[inventoryBtn].enabled
                else
                    inventoryBtn.Image = IconsMap[inventoryBtn].disabled
                end
            end
        )

        HandledUi:handleButtonPress(tradingBtn,
            function(pos1: number, pos2: number)
                setFocus(clonedScreen, "send_trade", IconsMap); IconsMap[tradingBtn].isEnabled = not IconsMap[tradingBtn].isEnabled

                if IconsMap[tradingBtn].isEnabled then
                    tradingBtn.Image = IconsMap[tradingBtn].enabled
                else
                    tradingBtn.Image = IconsMap[tradingBtn].disabled
                end
            end
        )

        HandledUi:handleButtonPress(rebirthBtn,
            function(pos1: number, pos2: number)
                setFocus(clonedScreen, "rebirth", IconsMap); IconsMap[rebirthBtn].isEnabled = not IconsMap[rebirthBtn].isEnabled

                if IconsMap[rebirthBtn].isEnabled then
                    rebirthBtn.Image = IconsMap[rebirthBtn].enabled
                else
                    rebirthBtn.Image = IconsMap[rebirthBtn].disabled
                end
            end
        )

        HandledUi:handleButtonPress(shopBtn,
            function(pos1: number, pos2: number)
                setFocus(clonedScreen, "shop", IconsMap); IconsMap[shopBtn].isEnabled = not IconsMap[shopBtn].isEnabled

                if IconsMap[shopBtn].isEnabled then
                    shopBtn.Image = IconsMap[shopBtn].enabled
                else
                    shopBtn.Image = IconsMap[shopBtn].disabled
                end
            end
        )

        HandledUi:handleButtonPress(marketplaceBtn,
            function(pos1: number, pos2: number)
                setFocus(clonedScreen, "marketplace", IconsMap); IconsMap[marketplaceBtn].isEnabled = not IconsMap[marketplaceBtn].isEnabled

                if IconsMap[marketplaceBtn].isEnabled then
                    marketplaceBtn.Image = IconsMap[marketplaceBtn].enabled
                else
                    marketplaceBtn.Image = IconsMap[marketplaceBtn].disabled
                end
            end
        )

        HandledUi:handleButtonPress(settingsBtn,
            function(pos1: number, pos2: number)
                setFocus(clonedScreen, "settings", IconsMap); IconsMap[settingsBtn].isEnabled = not IconsMap[settingsBtn].isEnabled

                if IconsMap[settingsBtn].isEnabled then
                    settingsBtn.Image = IconsMap[settingsBtn].enabled
                else
                    settingsBtn.Image = IconsMap[settingsBtn].disabled
                end
            end
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

                for i: ImageButton, ButtonImages: { enabled: string, disabled: string, isEnabled: boolean } in pairs(IconsMap) do
                    i.Image = ButtonImages.disabled; ButtonImages.isEnabled = false
                end
            end
        )
    end
end

return constructorCallback
--[[ @end_section Constructor ]]