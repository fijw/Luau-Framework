--!strict
--!native
--!optimize 2


--[[ @section Variables ]]
local LoadingScreen = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local LogoImg = Instance.new("ImageLabel")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
local StatusTxt = Instance.new("TextLabel")
local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
local SkipBtn = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")
local UIAspectRatioConstraint_3 = Instance.new("UIAspectRatioConstraint")

local ComponentsMap = { LoadingScreen = LoadingScreen }
--[[ @end_section Variables ]]


-- Set all component properties
do
    LoadingScreen.Name = "LoadingScreen"
    LoadingScreen.IgnoreGuiInset = true
    LoadingScreen.DisplayOrder = 999

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = LoadingScreen
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(1, 0, 1, 0)

    LogoImg.Name = "LogoImg"
    LogoImg.Parent = MainFrame
    LogoImg.AnchorPoint = Vector2.new(0.5, 0.5)
    LogoImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LogoImg.BackgroundTransparency = 1.000
    LogoImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    LogoImg.BorderSizePixel = 0
    LogoImg.Position = UDim2.new(0.5, 0, 0.5, 0)
    LogoImg.Size = UDim2.new(0.260552377, 0, 0.462962955, 0)
    LogoImg.Image = "rbxassetid://88162239678129"

    UIAspectRatioConstraint.Parent = LogoImg

    StatusTxt.Name = "StatusTxt"
    StatusTxt.Parent = MainFrame
    StatusTxt.AnchorPoint = Vector2.new(0.5, 0.5)
    StatusTxt.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    StatusTxt.BackgroundTransparency = 1.000
    StatusTxt.BorderColor3 = Color3.fromRGB(0, 0, 0)
    StatusTxt.BorderSizePixel = 0
    StatusTxt.Position = UDim2.new(0.5, 0, 0.872222245, 0)
    StatusTxt.Size = UDim2.new(0.474205315, 0, 0.0685185194, 0)
    StatusTxt.Font = Enum.Font.SourceSansBold
    StatusTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
    StatusTxt.TextScaled = true
    StatusTxt.TextSize = 14.000
    StatusTxt.TextWrapped = true
    StatusTxt.Visible = false

    UIAspectRatioConstraint_2.Parent = StatusTxt
    UIAspectRatioConstraint_2.AspectRatio = 12.297

    SkipBtn.Name = "SkipBtn"
    SkipBtn.Parent = MainFrame
    SkipBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    SkipBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    SkipBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SkipBtn.BorderSizePixel = 0
    SkipBtn.Position = UDim2.new(0.893209398, 0, 0.880224288, 0)
    SkipBtn.Size = UDim2.new(0.160500258, 0, 0.146296293, 0)
    SkipBtn.Font = Enum.Font.SourceSansBold
    SkipBtn.Text = "Skip"
    SkipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SkipBtn.TextScaled = true
    SkipBtn.TextSize = 14.000
    SkipBtn.TextWrapped = true
    SkipBtn.Visible = false

    UICorner.CornerRadius = UDim.new(0, 16)
    UICorner.Parent = SkipBtn

    UIAspectRatioConstraint_3.Parent = SkipBtn
    UIAspectRatioConstraint_3.AspectRatio = 1.949
end


table.freeze(ComponentsMap)
return ComponentsMap