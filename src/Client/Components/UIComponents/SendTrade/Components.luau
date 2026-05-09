--!strict
--!native
--!optimize 2


--[[ @section Variables ]]
local SendTrade = Instance.new("ScreenGui")
local Container = Instance.new("Frame")
local MainFrame = Instance.new("ImageLabel")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local PlayerTradingContainer = Instance.new("Frame")
local PlrIcon = Instance.new("ImageLabel")
local PlayerNamesContainer = Instance.new("Frame")
local PlrDisplayText = Instance.new("TextLabel")
local PlrNameText = Instance.new("TextLabel")
local SendTradeBtn = Instance.new("ImageButton")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
local SearchBox = Instance.new("Frame")
local FrameImage = Instance.new("ImageLabel")
local FrameBox = Instance.new("ImageLabel")
local TextBox = Instance.new("TextBox")
local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
local CloseBtn = Instance.new("ImageButton")
local Title = Instance.new("ImageLabel")
local UIAspectRatioConstraint_3 = Instance.new("UIAspectRatioConstraint")
local UIAspectRatioConstraint_4 = Instance.new("UIAspectRatioConstraint")
local BackgroundImg = Instance.new("ImageLabel")

local ComponentsMap = { SendTrade = SendTrade }
--[[ @end_section Variables ]]


-- Set all component properties.
do
    SendTrade.Name = "SendTrade"
    SendTrade.Enabled = false
    SendTrade.ResetOnSpawn = false

    Container.Name = "Container"
    Container.Parent = SendTrade
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Container.BackgroundTransparency = 1.000
    Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Container.BorderSizePixel = 0
    Container.Position = UDim2.new(0.5, 0, 0.45, 0)
    Container.Size = UDim2.new(0.481500775, 0, 0.693518519, 0)

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = Container
    MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainFrame.BackgroundTransparency = 1.000
    MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.0432900451, 0, 0.0587449931, 0)
    MainFrame.Size = UDim2.new(0.912337661, 0, 0.881174922, 0)
    MainFrame.ZIndex = 2
    MainFrame.Image = "rbxassetid://132218599883466"

    ScrollingFrame.Name = "ScrollingFrame"
    ScrollingFrame.Parent = MainFrame
    ScrollingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 4)
    ScrollingFrame.BackgroundTransparency = 1.000
    ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    ScrollingFrame.Size = UDim2.new(0.881376028, 0, 0.848484874, 0)
    ScrollingFrame.ZIndex = 2
    ScrollingFrame.ClipsDescendants = false

    UIListLayout.Parent = ScrollingFrame
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 15)

    PlayerTradingContainer.Name = "PlayerTradingContainer"
    PlayerTradingContainer.Parent = ScrollingFrame
    PlayerTradingContainer.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    PlayerTradingContainer.BackgroundTransparency = 1.000
    PlayerTradingContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    PlayerTradingContainer.BorderSizePixel = 0
    PlayerTradingContainer.Size = UDim2.new(1, 0, 0.178571433, 0)
    PlayerTradingContainer.ZIndex = 2
    PlayerTradingContainer.Visible = false

    UIAspectRatioConstraint_4.Parent = PlayerTradingContainer
    UIAspectRatioConstraint_4.AspectRatio = 7.431

    PlrIcon.Name = "PlrIcon"
    PlrIcon.Parent = PlayerTradingContainer
    PlrIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PlrIcon.BackgroundTransparency = 1.000
    PlrIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
    PlrIcon.BorderSizePixel = 0
    PlrIcon.Size = UDim2.new(0.134589508, 0, 1, 0)
    PlrIcon.ZIndex = 2
    PlrIcon.Image = "rbxassetid://126833786235525"

    PlayerNamesContainer.Name = "PlayerNamesContainer"
    PlayerNamesContainer.Parent = PlayerTradingContainer
    PlayerNamesContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PlayerNamesContainer.BackgroundTransparency = 1.000
    PlayerNamesContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    PlayerNamesContainer.BorderSizePixel = 0
    PlayerNamesContainer.Position = UDim2.new(0.168236881, 0, 0.209999993, 0)
    PlayerNamesContainer.Size = UDim2.new(0.393001348, 0, 0.579999983, 0)
    PlayerNamesContainer.ZIndex = 2

    PlrDisplayText.Name = "PlrDisplayText"
    PlrDisplayText.Parent = PlayerNamesContainer
    PlrDisplayText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PlrDisplayText.BackgroundTransparency = 1.000
    PlrDisplayText.BorderColor3 = Color3.fromRGB(0, 0, 0)
    PlrDisplayText.BorderSizePixel = 0
    PlrDisplayText.Size = UDim2.new(1, 0, 0.5, 0)
    PlrDisplayText.ZIndex = 2
    PlrDisplayText.Font = Enum.Font.FredokaOne
    PlrDisplayText.Text = "12345678901234567890"
    PlrDisplayText.TextColor3 = Color3.fromRGB(0, 0, 0)
    PlrDisplayText.TextScaled = true
    PlrDisplayText.TextSize = 14.000
    PlrDisplayText.TextWrapped = true
    PlrDisplayText.TextXAlignment = Enum.TextXAlignment.Left

    PlrNameText.Name = "PlrNameText"
    PlrNameText.Parent = PlayerNamesContainer
    PlrNameText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PlrNameText.BackgroundTransparency = 1.000
    PlrNameText.BorderColor3 = Color3.fromRGB(0, 0, 0)
    PlrNameText.BorderSizePixel = 0
    PlrNameText.Position = UDim2.new(0, 0, 0.5, 0)
    PlrNameText.Size = UDim2.new(1, 0, 0.5, 0)
    PlrNameText.ZIndex = 2
    PlrNameText.Font = Enum.Font.FredokaOne
    PlrNameText.Text = "@12345678901234567890"
    PlrNameText.TextColor3 = Color3.fromRGB(0, 0, 0)
    PlrNameText.TextScaled = true
    PlrNameText.TextSize = 14.000
    PlrNameText.TextWrapped = true
    PlrNameText.TextXAlignment = Enum.TextXAlignment.Left

    SendTradeBtn.Name = "SendTradeBtn"
    SendTradeBtn.Parent = PlayerTradingContainer
    SendTradeBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    SendTradeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SendTradeBtn.BackgroundTransparency = 1.000
    SendTradeBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SendTradeBtn.BorderSizePixel = 0
    SendTradeBtn.Position = UDim2.new(0.796769857, 0, 0.5, 0)
    SendTradeBtn.Size = UDim2.new(0.405114412, 0, 0.949999988, 0)
    SendTradeBtn.ZIndex = 2
    SendTradeBtn.Image = "rbxassetid://90887613950188"

    UIAspectRatioConstraint.Parent = ScrollingFrame
    UIAspectRatioConstraint.AspectRatio = 1.327

    SearchBox.Name = "SearchBox"
    SearchBox.Parent = Container
    SearchBox.AnchorPoint = Vector2.new(0.5, 0.5)
    SearchBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.BackgroundTransparency = 1.000
    SearchBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SearchBox.BorderSizePixel = 0
    SearchBox.Position = UDim2.new(0.692329943, 0, 0.058089681, 0)
    SearchBox.Size = UDim2.new(0.384199142, 0, 0.0787716955, 0)
    SearchBox.ZIndex = 3

    FrameImage.Name = "FrameImage"
    FrameImage.Parent = SearchBox
    FrameImage.AnchorPoint = Vector2.new(0.5, 0.5)
    FrameImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FrameImage.BackgroundTransparency = 1.000
    FrameImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
    FrameImage.BorderSizePixel = 0
    FrameImage.Position = UDim2.new(0.0619718246, 0, 0.491525382, 0)
    FrameImage.Size = UDim2.new(0.123943664, 0, 0.745762706, 0)
    FrameImage.ZIndex = 3
    FrameImage.Image = "rbxassetid://99267799355827"

    FrameBox.Name = "FrameBox"
    FrameBox.Parent = SearchBox
    FrameBox.AnchorPoint = Vector2.new(0.5, 0.5)
    FrameBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FrameBox.BackgroundTransparency = 1.000
    FrameBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    FrameBox.BorderSizePixel = 0
    FrameBox.Position = UDim2.new(0.576056361, 0, 0.5, 0)
    FrameBox.Size = UDim2.new(0.845070422, 0, 1, 0)
    FrameBox.ZIndex = 3
    FrameBox.Image = "rbxassetid://96198739376505"

    TextBox.Parent = FrameBox
    TextBox.AnchorPoint = Vector2.new(0.5, 0.5)
    TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.BackgroundTransparency = 1.000
    TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextBox.BorderSizePixel = 0
    TextBox.Position = UDim2.new(0.5, 0, 0.5, 0)
    TextBox.Size = UDim2.new(0.916666687, 0, 0.576271176, 0)
    TextBox.ZIndex = 3
    TextBox.Font = Enum.Font.FredokaOne
    TextBox.PlaceholderColor3 = Color3.fromRGB(0, 0, 0)
    TextBox.PlaceholderText = "Search for players here..."
    TextBox.Text = ""
    TextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextBox.TextScaled = true
    TextBox.TextSize = 14.000
    TextBox.TextWrapped = true

    UIAspectRatioConstraint_2.Parent = Container
    UIAspectRatioConstraint_2.AspectRatio = 1.234

    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = Container
    CloseBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.BackgroundTransparency = 1.000
    CloseBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Position = UDim2.new(0.95724684, 0, 0.0567545705, 0)
    CloseBtn.Size = UDim2.new(0.115800865, 0, 0.142857149, 0)
    CloseBtn.ZIndex = 3
    CloseBtn.Image = "rbxassetid://82177231415737"

    Title.Name = "Title"
    Title.Parent = Container
    Title.AnchorPoint = Vector2.new(0.5, 0.5)
    Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1.000
    Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Title.BorderSizePixel = 0
    Title.Position = UDim2.new(0.241950691, 0, 0.0567545779, 0)
    Title.Size = UDim2.new(0.435064942, 0, 0.082470946, 0)
    Title.ZIndex = 3
    Title.Image = "rbxassetid://139317670821725"

    UIAspectRatioConstraint_3.Parent = Title
    UIAspectRatioConstraint_3.AspectRatio = 6.508

    BackgroundImg.Name = "BackgroundImg"
    BackgroundImg.Parent = Container
    BackgroundImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BackgroundImg.BackgroundTransparency = 1.000
    BackgroundImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    BackgroundImg.BorderSizePixel = 0
    BackgroundImg.Position = UDim2.new(0.0432900451, 0, 0.0587449931, 0)
    BackgroundImg.Rotation = -5.000
    BackgroundImg.Size = UDim2.new(0.912337661, 0, 0.881174922, 0)
    BackgroundImg.Image = "rbxassetid://79241139813903"
end


table.freeze(ComponentsMap)
return ComponentsMap