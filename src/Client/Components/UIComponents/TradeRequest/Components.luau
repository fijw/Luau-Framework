--!strict
--!native
--!optimize 2


--[[ @section Variables ]]
local TradeRequest = Instance.new("ScreenGui")
local Container = Instance.new("Frame")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
local TitleImg = Instance.new("ImageLabel")
local MainFrame = Instance.new("ImageLabel")
local TradeRequestText = Instance.new("TextLabel")
local ButtonsContainer = Instance.new("Frame")
local AcceptBtn = Instance.new("ImageButton")
local DeclineBtn = Instance.new("ImageButton")
local BackgroundImg = Instance.new("ImageLabel")

local ComponentsMap = { TradeRequest = TradeRequest }
--[[ @end_section Variables ]]


-- Set all component properties.
do
    TradeRequest.Name = "TradeRequest"
    TradeRequest.Enabled = false
    TradeRequest.DisplayOrder = -1
    TradeRequest.ResetOnSpawn = false

    Container.Name = "Container"
    Container.Parent = TradeRequest
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Container.BackgroundTransparency = 1.000
    Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Container.BorderSizePixel = 0
    Container.Position = UDim2.new(0.5, 0, 0.45, 0)
    Container.Size = UDim2.new(0.315789461, 0, 0.4148148, 0)

    UIAspectRatioConstraint.Parent = Container
    UIAspectRatioConstraint.AspectRatio = 1.353

    TitleImg.Name = "TitleImg"
    TitleImg.Parent = Container
    TitleImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TitleImg.BackgroundTransparency = 1.000
    TitleImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TitleImg.BorderSizePixel = 0
    TitleImg.Position = UDim2.new(-0.0165016502, 0, -0.0156250019, 0)
    TitleImg.Size = UDim2.new(0.732673287, 0, 0.171875015, 0)
    TitleImg.ZIndex = 3
    TitleImg.Image = "rbxassetid://95710299858321"

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = Container
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainFrame.BackgroundTransparency = 1.000
    MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0.947194695, 0, 0.85937506, 0)
    MainFrame.ZIndex = 2
    MainFrame.Image = "rbxassetid://127966096347491"

    TradeRequestText.Name = "TradeRequestText"
    TradeRequestText.Parent = MainFrame
    TradeRequestText.AnchorPoint = Vector2.new(0.5, 0.5)
    TradeRequestText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TradeRequestText.BackgroundTransparency = 1.000
    TradeRequestText.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TradeRequestText.BorderSizePixel = 0
    TradeRequestText.Position = UDim2.new(0.5, 0, 0.344155848, 0)
    TradeRequestText.Size = UDim2.new(0.810104549, 0, 0.428571433, 0)
    TradeRequestText.ZIndex = 2
    TradeRequestText.Font = Enum.Font.FredokaOne
    TradeRequestText.TextColor3 = Color3.fromRGB(0, 0, 0)
    TradeRequestText.TextScaled = true
    TradeRequestText.TextSize = 14.000
    TradeRequestText.TextWrapped = true
    TradeRequestText.RichText = true

    ButtonsContainer.Name = "ButtonsContainer"
    ButtonsContainer.Parent = MainFrame
    ButtonsContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ButtonsContainer.BackgroundTransparency = 1.000
    ButtonsContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ButtonsContainer.BorderSizePixel = 0
    ButtonsContainer.Position = UDim2.new(0.087108016, 0, 0.623376608, 0)
    ButtonsContainer.Size = UDim2.new(0.825783968, 0, 0.246753246, 0)
    ButtonsContainer.ZIndex = 2

    AcceptBtn.Name = "AcceptBtn"
    AcceptBtn.Parent = ButtonsContainer
    AcceptBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    AcceptBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    AcceptBtn.BackgroundTransparency = 1.000
    AcceptBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    AcceptBtn.BorderSizePixel = 0
    AcceptBtn.Position = UDim2.new(0.226286923, 0, 0.49473685, 0)
    AcceptBtn.Size = UDim2.new(0.474683553, 0, 1, 0)
    AcceptBtn.ZIndex = 2
    AcceptBtn.Image = "rbxassetid://97115211730032"

    DeclineBtn.Name = "DeclineBtn"
    DeclineBtn.Parent = ButtonsContainer
    DeclineBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    DeclineBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DeclineBtn.BackgroundTransparency = 1.000
    DeclineBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DeclineBtn.BorderSizePixel = 0
    DeclineBtn.Position = UDim2.new(0.76316453, 0, 0.49473685, 0)
    DeclineBtn.Size = UDim2.new(0.493670881, 0, 1, 0)
    DeclineBtn.ZIndex = 2
    DeclineBtn.Image = "rbxassetid://84700849818274"

    BackgroundImg.Name = "BackgroundImg"
    BackgroundImg.Parent = Container
    BackgroundImg.AnchorPoint = Vector2.new(0.5, 0.5)
    BackgroundImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BackgroundImg.BackgroundTransparency = 1.000
    BackgroundImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    BackgroundImg.BorderSizePixel = 0
    BackgroundImg.Position = UDim2.new(0.5, 0, 0.5, 0)
    BackgroundImg.Rotation = -5.000
    BackgroundImg.Size = UDim2.new(0.947194695, 0, 0.85937506, 0)
    BackgroundImg.Image = "rbxassetid://122248309062991"
end


table.freeze(ComponentsMap)
return ComponentsMap