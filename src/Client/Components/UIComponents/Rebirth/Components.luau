--!strict
--!native
--!optimize 2


--[[ @section Variables ]]
local Rebirth = Instance.new("ScreenGui")
local Container = Instance.new("Frame")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
local MainFrame = Instance.new("ImageLabel")
local RebirthStatsContainer = Instance.new("Frame")
local PriceText = Instance.new("TextLabel")
local LevelsTxt = Instance.new("TextLabel")
local MultiplierText = Instance.new("TextLabel")
local DescriptionTxt = Instance.new("TextLabel")
local RebirthBtn = Instance.new("ImageButton")
local BackgroundImg = Instance.new("ImageLabel")
local CloseBtn = Instance.new("ImageButton")
local TitleImg = Instance.new("ImageLabel")
local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")

local Components = { Rebirth = Rebirth }
--[[ @end_section Variables ]]


-- Set all component properties.
do
    Rebirth.Name = "Rebirth"
    Rebirth.Enabled = false
    Rebirth.ResetOnSpawn = false

    Container.Name = "Container"
    Container.Parent = Rebirth
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Container.BackgroundTransparency = 1.000
    Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Container.BorderSizePixel = 0
    Container.Position = UDim2.new(0.5, 0, 0.45, 0)
    Container.Size = UDim2.new(0.480979681, 0, 0.523148119, 0)

    UIAspectRatioConstraint.Parent = Container
    UIAspectRatioConstraint.AspectRatio = 1.634

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = Container
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainFrame.BackgroundTransparency = 1.000
    MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0.92091006, 0, 0.840708077, 0)
    MainFrame.ZIndex = 2
    MainFrame.Image = "rbxassetid://95572063670133"

    RebirthStatsContainer.Name = "RebirthStatsContainer"
    RebirthStatsContainer.Parent = MainFrame
    RebirthStatsContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    RebirthStatsContainer.BackgroundTransparency = 1.000
    RebirthStatsContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    RebirthStatsContainer.BorderSizePixel = 0
    RebirthStatsContainer.Position = UDim2.new(0.0590000004, 0, 0.1065, 0)
    RebirthStatsContainer.Size = UDim2.new(0.882352948, 0, 0.122105263, 0)
    RebirthStatsContainer.ZIndex = 2

    PriceText.Name = "PriceText"
    PriceText.Parent = RebirthStatsContainer
    PriceText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PriceText.BackgroundTransparency = 1.000
    PriceText.BorderColor3 = Color3.fromRGB(0, 0, 0)
    PriceText.BorderSizePixel = 0
    PriceText.Position = UDim2.new(-0.00133333332, 0, 0, 0)
    PriceText.Size = UDim2.new(0.432999998, 0, 0.5, 0)
    PriceText.ZIndex = 2
    PriceText.Font = Enum.Font.FredokaOne
    PriceText.Text = "Rebirth Price: 50,000 Gems"
    PriceText.TextColor3 = Color3.fromRGB(0, 0, 0)
    PriceText.TextScaled = true
    PriceText.TextSize = 14.000
    PriceText.TextWrapped = true
    PriceText.TextXAlignment = Enum.TextXAlignment.Left

    LevelsTxt.Name = "LevelsTxt"
    LevelsTxt.Parent = RebirthStatsContainer
    LevelsTxt.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LevelsTxt.BackgroundTransparency = 1.000
    LevelsTxt.BorderColor3 = Color3.fromRGB(0, 0, 0)
    LevelsTxt.BorderSizePixel = 0
    LevelsTxt.Position = UDim2.new(-0.00133333332, 0, 0.5, 0)
    LevelsTxt.Size = UDim2.new(0.432999998, 0, 0.5, 0)
    LevelsTxt.ZIndex = 2
    LevelsTxt.Font = Enum.Font.FredokaOne
    LevelsTxt.Text = "Needed Levels: 25"
    LevelsTxt.TextColor3 = Color3.fromRGB(0, 0, 0)
    LevelsTxt.TextScaled = true
    LevelsTxt.TextSize = 14.000
    LevelsTxt.TextWrapped = true
    LevelsTxt.TextXAlignment = Enum.TextXAlignment.Left

    MultiplierText.Name = "MultiplierText"
    MultiplierText.Parent = RebirthStatsContainer
    MultiplierText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MultiplierText.BackgroundTransparency = 1.000
    MultiplierText.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MultiplierText.BorderSizePixel = 0
    MultiplierText.Position = UDim2.new(0.566666663, 0, 0, 0)
    MultiplierText.Size = UDim2.new(0.432999998, 0, 0.5, 0)
    MultiplierText.ZIndex = 2
    MultiplierText.Font = Enum.Font.FredokaOne
    MultiplierText.Text = "Current Coins Multiplier: 37.5x"
    MultiplierText.TextColor3 = Color3.fromRGB(0, 0, 0)
    MultiplierText.TextScaled = true
    MultiplierText.TextSize = 14.000
    MultiplierText.TextWrapped = true
    MultiplierText.TextXAlignment = Enum.TextXAlignment.Right

    DescriptionTxt.Name = "DescriptionTxt"
    DescriptionTxt.Parent = MainFrame
    DescriptionTxt.AnchorPoint = Vector2.new(0.5, 0.5)
    DescriptionTxt.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DescriptionTxt.BackgroundTransparency = 1.000
    DescriptionTxt.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DescriptionTxt.BorderSizePixel = 0
    DescriptionTxt.Position = UDim2.new(0.5, 0, 0.460000008, 0)
    DescriptionTxt.Size = UDim2.new(0.770825326, 0, 0.404000044, 0)
    DescriptionTxt.ZIndex = 2
    DescriptionTxt.Font = Enum.Font.FredokaOne
    DescriptionTxt.Text = "Each time you rebirth you gain a +1.25x coins multiplier.<br /><br />Rebirthing resets your Levels, XP, and all Dungeon<br />progress.<br /><br />You can rebirth up to 100 times."
    DescriptionTxt.TextColor3 = Color3.fromRGB(0, 0, 0)
    DescriptionTxt.TextScaled = true
    DescriptionTxt.TextSize = 14.000
    DescriptionTxt.RichText = true
    DescriptionTxt.TextWrapped = true
    DescriptionTxt.TextXAlignment = Enum.TextXAlignment.Left

    RebirthBtn.Name = "RebirthBtn"
    RebirthBtn.Parent = MainFrame
    RebirthBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    RebirthBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    RebirthBtn.BackgroundTransparency = 1.000
    RebirthBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    RebirthBtn.BorderSizePixel = 0
    RebirthBtn.Position = UDim2.new(0.5, 0, 0.794736862, 0)
    RebirthBtn.Size = UDim2.new(0.274117649, 0, 0.200000003, 0)
    RebirthBtn.ZIndex = 2
    RebirthBtn.Image = "rbxassetid://123820106626170"

    BackgroundImg.Name = "BackgroundImg"
    BackgroundImg.Parent = Container
    BackgroundImg.AnchorPoint = Vector2.new(0.5, 0.5)
    BackgroundImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BackgroundImg.BackgroundTransparency = 1.000
    BackgroundImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    BackgroundImg.BorderSizePixel = 0
    BackgroundImg.Position = UDim2.new(0.5, 0, 0.5, 0)
    BackgroundImg.Rotation = -5.000
    BackgroundImg.Size = UDim2.new(0.92091006, 0, 0.840708077, 0)
    BackgroundImg.Image = "rbxassetid://80765441944631"

    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = Container
    CloseBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.BackgroundTransparency = 1.000
    CloseBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Position = UDim2.new(0.959418416, 0, 0.0817176551, 0)
    CloseBtn.Size = UDim2.new(0.115926325, 0, 0.189380556, 0)
    CloseBtn.ZIndex = 3
    CloseBtn.Image = "rbxassetid://82177231415737"

    TitleImg.Name = "TitleImg"
    TitleImg.Parent = Container
    TitleImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TitleImg.BackgroundTransparency = 1.000
    TitleImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TitleImg.BorderSizePixel = 0
    TitleImg.Position = UDim2.new(0.0219743755, 0, 0.0271076597, 0)
    TitleImg.Size = UDim2.new(0.245937169, 0, 0.10816884, 0)
    TitleImg.ZIndex = 3
    TitleImg.Image = "rbxassetid://119745189928088"

    UIAspectRatioConstraint_2.Parent = TitleImg
    UIAspectRatioConstraint_2.AspectRatio = 3.714
end


table.freeze(Components)
return Components