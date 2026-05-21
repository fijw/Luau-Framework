--!strict
--!native
--!optimize 2


--[[ @section Variables ]]
local Screen = Instance.new("ScreenGui")
local StatsContainer = Instance.new("Frame")
local GemsDisplay = Instance.new("ImageLabel")
local ImageLabel = Instance.new("ImageLabel")
local GemsText = Instance.new("TextLabel")
local RebirthsDisplay = Instance.new("ImageLabel")
local LevelsToRebirthText = Instance.new("TextLabel")
local ImageLabel_2 = Instance.new("ImageLabel")
local RebirthsText = Instance.new("TextLabel")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
local LevelsDisplay = Instance.new("ImageLabel")
local XPToNextLevelText = Instance.new("TextLabel")
local ImageLabel_3 = Instance.new("ImageLabel")
local LevelText = Instance.new("TextLabel")
local TeleportBtn = Instance.new("ImageButton")
local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
local MenuContainer = Instance.new("Frame")
local InventoryBtn = Instance.new("ImageButton")
local TradingBtn = Instance.new("ImageButton")
local RebirthBtn = Instance.new("ImageButton")
local ShopBtn = Instance.new("ImageButton")
local MarketplaceBtn = Instance.new("ImageButton")
local SettingsBtn = Instance.new("ImageButton")
local UIAspectRatioConstraint_3 = Instance.new("UIAspectRatioConstraint")

local Components = { Screen = Screen }
--[[ @end_section Variables ]]


-- Set all component properties.
do
    Screen.Name = "Screen"
    Screen.Enabled = false
    Screen.ResetOnSpawn = false

    StatsContainer.Name = "StatsContainer"
    StatsContainer.Parent = Screen
    StatsContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    StatsContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    StatsContainer.BackgroundTransparency = 1.000
    StatsContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    StatsContainer.BorderSizePixel = 0
    StatsContainer.Position = UDim2.new(0.918707669, 0, 0.854629636, 0)
    StatsContainer.Size = UDim2.new(0.135487229, 0, 0.24166666, 0)

    GemsDisplay.Name = "GemsDisplay"
    GemsDisplay.Parent = StatsContainer
    GemsDisplay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    GemsDisplay.BackgroundTransparency = 1.000
    GemsDisplay.BorderColor3 = Color3.fromRGB(0, 0, 0)
    GemsDisplay.BorderSizePixel = 0
    GemsDisplay.Size = UDim2.new(1, 0, 0.287356317, 0)
    GemsDisplay.Image = "rbxassetid://78012224251432"

    ImageLabel.Parent = GemsDisplay
    ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel.BackgroundTransparency = 1.000
    ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel.BorderSizePixel = 0
    ImageLabel.Position = UDim2.new(0.0658841655, 0, 0.200000003, 0)
    ImageLabel.Size = UDim2.new(0.169230774, 0, 0.600000024, 0)
    ImageLabel.Image = "rbxassetid://74859616905155"

    GemsText.Name = "GemsText"
    GemsText.Parent = GemsDisplay
    GemsText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    GemsText.BorderColor3 = Color3.fromRGB(0, 0, 0)
    GemsText.BorderSizePixel = 0
    GemsText.Position = UDim2.new(0.236093372, 0, 0.306666672, 0)
    GemsText.Size = UDim2.new(0.673076928, 0, 0.386666656, 0)
    GemsText.Font = Enum.Font.FredokaOne
    GemsText.Text = "???"
    GemsText.TextColor3 = Color3.fromRGB(0, 0, 0)
    GemsText.TextScaled = true
    GemsText.TextSize = 14.000
    GemsText.TextWrapped = true

    RebirthsDisplay.Name = "RebirthsDisplay"
    RebirthsDisplay.Parent = StatsContainer
    RebirthsDisplay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    RebirthsDisplay.BackgroundTransparency = 1.000
    RebirthsDisplay.BorderColor3 = Color3.fromRGB(0, 0, 0)
    RebirthsDisplay.BorderSizePixel = 0
    RebirthsDisplay.Position = UDim2.new(0, 0, 0.356321841, 0)
    RebirthsDisplay.Size = UDim2.new(1, 0, 0.287356317, 0)
    RebirthsDisplay.Image = "rbxassetid://78012224251432"

    LevelsToRebirthText.Name = "LevelsToRebirthText"
    LevelsToRebirthText.Parent = RebirthsDisplay
    LevelsToRebirthText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LevelsToRebirthText.BorderColor3 = Color3.fromRGB(0, 0, 0)
    LevelsToRebirthText.BorderSizePixel = 0
    LevelsToRebirthText.Position = UDim2.new(0.236093372, 0, 0.586666644, 0)
    LevelsToRebirthText.Size = UDim2.new(0.669230759, 0, 0.213333338, 0)
    LevelsToRebirthText.Font = Enum.Font.FredokaOne
    LevelsToRebirthText.Text = "???/??? Levels"
    LevelsToRebirthText.TextColor3 = Color3.fromRGB(0, 0, 0)
    LevelsToRebirthText.TextScaled = true
    LevelsToRebirthText.TextSize = 14.000
    LevelsToRebirthText.TextWrapped = true

    ImageLabel_2.Parent = RebirthsDisplay
    ImageLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel_2.BackgroundTransparency = 1.000
    ImageLabel_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel_2.BorderSizePixel = 0
    ImageLabel_2.Position = UDim2.new(0.0658841655, 0, 0.200000003, 0)
    ImageLabel_2.Size = UDim2.new(0.169230774, 0, 0.600000024, 0)
    ImageLabel_2.Image = "rbxassetid://112344372507508"

    RebirthsText.Name = "RebirthsText"
    RebirthsText.Parent = RebirthsDisplay
    RebirthsText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    RebirthsText.BorderColor3 = Color3.fromRGB(0, 0, 0)
    RebirthsText.BorderSizePixel = 0
    RebirthsText.Position = UDim2.new(0.236093372, 0, 0.200000003, 0)
    RebirthsText.Size = UDim2.new(0.669230759, 0, 0.386666656, 0)
    RebirthsText.Font = Enum.Font.FredokaOne
    RebirthsText.Text = "???"
    RebirthsText.TextColor3 = Color3.fromRGB(0, 0, 0)
    RebirthsText.TextScaled = true
    RebirthsText.TextSize = 14.000
    RebirthsText.TextWrapped = true

    UIAspectRatioConstraint.Parent = StatsContainer
    UIAspectRatioConstraint.AspectRatio = 0.996

    LevelsDisplay.Name = "LevelsDisplay"
    LevelsDisplay.Parent = StatsContainer
    LevelsDisplay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LevelsDisplay.BackgroundTransparency = 1.000
    LevelsDisplay.BorderColor3 = Color3.fromRGB(0, 0, 0)
    LevelsDisplay.BorderSizePixel = 0
    LevelsDisplay.Position = UDim2.new(0, 0, 0.712643683, 0)
    LevelsDisplay.Size = UDim2.new(1, 0, 0.287356317, 0)
    LevelsDisplay.Image = "rbxassetid://78012224251432"

    XPToNextLevelText.Name = "XPToNextLevelText"
    XPToNextLevelText.Parent = LevelsDisplay
    XPToNextLevelText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    XPToNextLevelText.BorderColor3 = Color3.fromRGB(0, 0, 0)
    XPToNextLevelText.BorderSizePixel = 0
    XPToNextLevelText.Position = UDim2.new(0.236093372, 0, 0.586666644, 0)
    XPToNextLevelText.Size = UDim2.new(0.673076928, 0, 0.213333338, 0)
    XPToNextLevelText.Font = Enum.Font.FredokaOne
    XPToNextLevelText.Text = "???/??? XP"
    XPToNextLevelText.TextColor3 = Color3.fromRGB(0, 0, 0)
    XPToNextLevelText.TextScaled = true
    XPToNextLevelText.TextSize = 14.000
    XPToNextLevelText.TextWrapped = true

    ImageLabel_3.Parent = LevelsDisplay
    ImageLabel_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel_3.BackgroundTransparency = 1.000
    ImageLabel_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel_3.BorderSizePixel = 0
    ImageLabel_3.Position = UDim2.new(0.0658841655, 0, 0.200000003, 0)
    ImageLabel_3.Size = UDim2.new(0.169230774, 0, 0.600000024, 0)
    ImageLabel_3.Image = "rbxassetid://107963009773893"

    LevelText.Name = "LevelText"
    LevelText.Parent = LevelsDisplay
    LevelText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LevelText.BorderColor3 = Color3.fromRGB(0, 0, 0)
    LevelText.BorderSizePixel = 0
    LevelText.Position = UDim2.new(0.236093372, 0, 0.200000003, 0)
    LevelText.Size = UDim2.new(0.673076928, 0, 0.386666656, 0)
    LevelText.Font = Enum.Font.FredokaOne
    LevelText.Text = "???"
    LevelText.TextColor3 = Color3.fromRGB(0, 0, 0)
    LevelText.TextScaled = true
    LevelText.TextSize = 14.000
    LevelText.TextWrapped = true

    TeleportBtn.Name = "TeleportBtn"
    TeleportBtn.Parent = Screen
    TeleportBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    TeleportBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TeleportBtn.BackgroundTransparency = 1.000
    TeleportBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TeleportBtn.BorderSizePixel = 0
    TeleportBtn.Position = UDim2.new(0.0729546621, 0, 0.922222197, 0)
    TeleportBtn.Size = UDim2.new(0.119854093, 0, 0.106481485, 0)
    TeleportBtn.Image = "rbxassetid://91603925446953"

    UIAspectRatioConstraint_2.Parent = TeleportBtn
    UIAspectRatioConstraint_2.AspectRatio = 2.000

    MenuContainer.Name = "MenuContainer"
    MenuContainer.Parent = Screen
    MenuContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    MenuContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MenuContainer.BackgroundTransparency = 1.000
    MenuContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MenuContainer.BorderSizePixel = 0
    MenuContainer.Position = UDim2.new(0.499739438, 0, 0.907407403, 0)
    MenuContainer.Size = UDim2.new(0.416883796, 0, 0.138888896, 0)

    InventoryBtn.Name = "InventoryBtn"
    InventoryBtn.Parent = MenuContainer
    InventoryBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    InventoryBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    InventoryBtn.BackgroundTransparency = 1.000
    InventoryBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    InventoryBtn.BorderSizePixel = 0
    InventoryBtn.Position = UDim2.new(0.0960000157, 0, 0.5, 0)
    InventoryBtn.Size = UDim2.new(0.1875, 0, 1, 0)
    InventoryBtn.Image = "rbxassetid://119870862470846"

    TradingBtn.Name = "TradingBtn"
    TradingBtn.Parent = MenuContainer
    TradingBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    TradingBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TradingBtn.BackgroundTransparency = 1.000
    TradingBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TradingBtn.BorderSizePixel = 0
    TradingBtn.Position = UDim2.new(0.279000014, 0, 0.486999989, 0)
    TradingBtn.Size = UDim2.new(0.143749997, 0, 0.766666651, 0)
    TradingBtn.Image = "rbxassetid://96262129570992"

    RebirthBtn.Name = "RebirthBtn"
    RebirthBtn.Parent = MenuContainer
    RebirthBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    RebirthBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    RebirthBtn.BackgroundTransparency = 1.000
    RebirthBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    RebirthBtn.BorderSizePixel = 0
    RebirthBtn.Position = UDim2.new(0.763000011, 0, 0.486999989, 0)
    RebirthBtn.Size = UDim2.new(0.143749997, 0, 0.766666651, 0)
    RebirthBtn.Image = "rbxassetid://133561204302109"

    ShopBtn.Name = "ShopBtn"
    ShopBtn.Parent = MenuContainer
    ShopBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    ShopBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ShopBtn.BackgroundTransparency = 1.000
    ShopBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ShopBtn.BorderSizePixel = 0
    ShopBtn.Position = UDim2.new(0.601999998, 0, 0.486999989, 0)
    ShopBtn.Size = UDim2.new(0.143749997, 0, 0.766666651, 0)
    ShopBtn.Image = "rbxassetid://138187189416512"

    MarketplaceBtn.Name = "MarketplaceBtn"
    MarketplaceBtn.Parent = MenuContainer
    MarketplaceBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    MarketplaceBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MarketplaceBtn.BackgroundTransparency = 1.000
    MarketplaceBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MarketplaceBtn.BorderSizePixel = 0
    MarketplaceBtn.Position = UDim2.new(0.439999998, 0, 0.486999989, 0)
    MarketplaceBtn.Size = UDim2.new(0.143749997, 0, 0.766666651, 0)
    MarketplaceBtn.Image = "rbxassetid://92171331943586"

    SettingsBtn.Name = "SettingsBtn"
    SettingsBtn.Parent = MenuContainer
    SettingsBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    SettingsBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SettingsBtn.BackgroundTransparency = 1.000
    SettingsBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SettingsBtn.BorderSizePixel = 0
    SettingsBtn.Position = UDim2.new(0.925000012, 0, 0.486999989, 0)
    SettingsBtn.Size = UDim2.new(0.143749997, 0, 0.766666651, 0)
    SettingsBtn.Image = "rbxassetid://94060889590777"

    UIAspectRatioConstraint_3.Parent = MenuContainer
    UIAspectRatioConstraint_3.AspectRatio = 5.333
end


table.freeze(Components)
return Components