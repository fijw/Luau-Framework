--!strict
--!native
--!optimize 2


--[[ @section Variables ]]
local CrateMachine = Instance.new("ScreenGui")
local Container = Instance.new("Frame")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
local BackgroundImg = Instance.new("ImageLabel")
local MainFrame = Instance.new("ImageLabel")
local InnerContainer = Instance.new("Frame")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local CrateFrame = Instance.new("ImageLabel")
local CrateContainer = Instance.new("Frame")
local CrateName = Instance.new("TextLabel")
local ChancesContainer = Instance.new("Frame")
local UIGridLayout = Instance.new("UIGridLayout")
local DetailsContainer = Instance.new("Frame")
local UIListLayout_2 = Instance.new("UIListLayout")
local ImageLabel = Instance.new("ImageLabel")
local TextLabel = Instance.new("TextLabel")
local PriceText = Instance.new("TextLabel")
local PurchaseButton = Instance.new("ImageButton")
local TitleImg = Instance.new("ImageLabel")
local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
local SearchBox = Instance.new("Frame")
local FrameImage = Instance.new("ImageLabel")
local FrameBox = Instance.new("ImageLabel")
local TextBox = Instance.new("TextBox")
local CloseBtn = Instance.new("ImageButton")

local Components = { CrateMachine = CrateMachine }
--[[ @end_section Variables ]]


-- Set all component properties.
do
    CrateMachine.Name = "CrateMachine"
    CrateMachine.Enabled = false

    Container.Name = "Container"
    Container.Parent = CrateMachine
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Container.BackgroundTransparency = 1.000
    Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Container.BorderSizePixel = 0
    Container.Position = UDim2.new(0.5, 0, 0.45, 0)
    Container.Size = UDim2.new(0.497655034, 0, 0.667592585, 0)

    UIAspectRatioConstraint.Parent = Container
    UIAspectRatioConstraint.AspectRatio = 1.325

    BackgroundImg.Name = "BackgroundImg"
    BackgroundImg.Parent = Container
    BackgroundImg.AnchorPoint = Vector2.new(0.5, 0.5)
    BackgroundImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BackgroundImg.BackgroundTransparency = 1.000
    BackgroundImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    BackgroundImg.BorderSizePixel = 0
    BackgroundImg.Position = UDim2.new(0.5, 0, 0.5, 0)
    BackgroundImg.Rotation = 5.000
    BackgroundImg.Size = UDim2.new(0.916230381, 0, 0.87517339, 0)
    BackgroundImg.Image = "rbxassetid://137401894038895"

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = Container
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainFrame.BackgroundTransparency = 1.000
    MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0.916230381, 0, 0.87517339, 0)
    MainFrame.ZIndex = 2
    MainFrame.Image = "rbxassetid://114512183737406"

    InnerContainer.Name = "InnerContainer"
    InnerContainer.Parent = MainFrame
    InnerContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    InnerContainer.BackgroundColor3 = Color3.fromRGB(112, 112, 112)
    InnerContainer.BackgroundTransparency = 1.000
    InnerContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    InnerContainer.BorderSizePixel = 0
    InnerContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    InnerContainer.Size = UDim2.new(0.885714293, 0, 0.841521382, 0)
    InnerContainer.ZIndex = 2

    ScrollingFrame.Parent = InnerContainer
    ScrollingFrame.Active = true
    ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 4)
    ScrollingFrame.BackgroundTransparency = 1.000
    ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    ScrollingFrame.ZIndex = 2
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.X
    ScrollingFrame.ScrollBarThickness = 0

    UIListLayout.Parent = ScrollingFrame
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0.0189999994, 0)

    CrateFrame.Name = "CrateFrame"
    CrateFrame.Parent = ScrollingFrame
    CrateFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CrateFrame.BackgroundTransparency = 1.000
    CrateFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CrateFrame.BorderSizePixel = 0
    CrateFrame.Size = UDim2.new(0.49032259, 0, 1, 0)
    CrateFrame.ZIndex = 2
    CrateFrame.Image = "rbxassetid://135166300698782"
    CrateFrame.Visible = false

    CrateContainer.Name = "CrateContainer"
    CrateContainer.Parent = CrateFrame
    CrateContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    CrateContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CrateContainer.BackgroundTransparency = 1.000
    CrateContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CrateContainer.BorderSizePixel = 0
    CrateContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    CrateContainer.Size = UDim2.new(0.868421078, 0, 0.905838013, 0)
    CrateContainer.ZIndex = 2

    CrateName.Name = "CrateName"
    CrateName.Parent = CrateContainer
    CrateName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CrateName.BackgroundTransparency = 1.000
    CrateName.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CrateName.BorderSizePixel = 0
    CrateName.LayoutOrder = 1
    CrateName.Position = UDim2.new(-0.00255182432, 0, -0.000465948222, 0)
    CrateName.Size = UDim2.new(1, 0, 0.0810810775, 0)
    CrateName.ZIndex = 2
    CrateName.Font = Enum.Font.FredokaOne
    CrateName.Text = "Testing Crate"
    CrateName.TextColor3 = Color3.fromRGB(0, 0, 0)
    CrateName.TextScaled = true
    CrateName.TextSize = 14.000
    CrateName.TextWrapped = true

    ChancesContainer.Name = "ChancesContainer"
    ChancesContainer.Parent = CrateContainer
    ChancesContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ChancesContainer.BackgroundTransparency = 1.000
    ChancesContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ChancesContainer.BorderSizePixel = 0
    ChancesContainer.LayoutOrder = 2
    ChancesContainer.Position = UDim2.new(0, 0, 0.110187113, 0)
    ChancesContainer.Size = UDim2.new(1, 0, 0.567567587, 0)
    ChancesContainer.ZIndex = 2

    UIGridLayout.Parent = ChancesContainer
    UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIGridLayout.CellPadding = UDim2.new(0.0450000018, 0, 0.0450000018, 0)
    UIGridLayout.CellSize = UDim2.new(0.303000003, 0, 0.47299999, 0)

    DetailsContainer.Name = "DetailsContainer"
    DetailsContainer.Parent = ChancesContainer
    DetailsContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DetailsContainer.BackgroundTransparency = 1.000
    DetailsContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DetailsContainer.BorderSizePixel = 0
    DetailsContainer.Size = UDim2.new(0, 100, 0, 100)
    DetailsContainer.ZIndex = 2

    UIListLayout_2.Parent = DetailsContainer
    UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder

    ImageLabel.Parent = DetailsContainer
    ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel.BackgroundTransparency = 1.000
    ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel.BorderSizePixel = 0
    ImageLabel.Size = UDim2.new(1, 0, 0.774, 0)
    ImageLabel.ZIndex = 2
    ImageLabel.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"

    TextLabel.Parent = DetailsContainer
    TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.BackgroundTransparency = 1.000
    TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BorderSizePixel = 0
    TextLabel.Size = UDim2.new(1, 0, 0.224581629, 0)
    TextLabel.ZIndex = 2
    TextLabel.Font = Enum.Font.FredokaOne
    TextLabel.Text = "0.01%"
    TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.TextScaled = true
    TextLabel.TextSize = 14.000
    TextLabel.TextWrapped = true

    PriceText.Name = "PriceText"
    PriceText.Parent = CrateContainer
    PriceText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PriceText.BackgroundTransparency = 1.000
    PriceText.BorderColor3 = Color3.fromRGB(0, 0, 0)
    PriceText.BorderSizePixel = 0
    PriceText.LayoutOrder = 3
    PriceText.Position = UDim2.new(0, 0, 0.708939731, 0)
    PriceText.Size = UDim2.new(1, 0, 0.0602910593, 0)
    PriceText.ZIndex = 2
    PriceText.Font = Enum.Font.FredokaOne
    PriceText.Text = "Price: 1,000 Gems"
    PriceText.TextColor3 = Color3.fromRGB(0, 0, 0)
    PriceText.TextScaled = true
    PriceText.TextSize = 14.000
    PriceText.TextWrapped = true

    PurchaseButton.Name = "PurchaseButton"
    PurchaseButton.Parent = CrateContainer
    PurchaseButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PurchaseButton.BackgroundTransparency = 1.000
    PurchaseButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    PurchaseButton.BorderSizePixel = 0
    PurchaseButton.LayoutOrder = 4
    PurchaseButton.Position = UDim2.new(0.494, 0, 0.897, 0)
    PurchaseButton.Size = UDim2.new(0.803030312, 0, 0.197505191, 0)
    PurchaseButton.ZIndex = 2
    PurchaseButton.AnchorPoint = Vector2.new(0.5, 0.5)
    PurchaseButton.Image = "rbxassetid://71671826570659"

    TitleImg.Name = "TitleImg"
    TitleImg.Parent = Container
    TitleImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TitleImg.BackgroundTransparency = 1.000
    TitleImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TitleImg.BorderSizePixel = 0
    TitleImg.Position = UDim2.new(0.0198952872, 0, 0.0235783625, 0)
    TitleImg.Size = UDim2.new(0.468062818, 0, 0.0856540725, 0)
    TitleImg.ZIndex = 3
    TitleImg.Image = "rbxassetid://137182167329396"

    UIAspectRatioConstraint_2.Parent = TitleImg
    UIAspectRatioConstraint_2.AspectRatio = 7.238

    SearchBox.Name = "SearchBox"
    SearchBox.Parent = Container
    SearchBox.AnchorPoint = Vector2.new(0.5, 0.5)
    SearchBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.BackgroundTransparency = 1.000
    SearchBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SearchBox.BorderSizePixel = 0
    SearchBox.Position = UDim2.new(0.70157069, 0, 0.0651872382, 0)
    SearchBox.Size = UDim2.new(0.371727735, 0, 0.0804438293, 0)
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
    FrameImage.Image = "rbxassetid://99267799355827"
    FrameImage.ZIndex = 3

    FrameBox.Name = "FrameBox"
    FrameBox.Parent = SearchBox
    FrameBox.AnchorPoint = Vector2.new(0.5, 0.5)
    FrameBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FrameBox.BackgroundTransparency = 1.000
    FrameBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    FrameBox.BorderSizePixel = 0
    FrameBox.Position = UDim2.new(0.576056361, 0, 0.5, 0)
    FrameBox.Size = UDim2.new(0.845070422, 0, 1, 0)
    FrameBox.Image = "rbxassetid://96198739376505"
    FrameBox.ZIndex = 3

    TextBox.Parent = FrameBox
    TextBox.AnchorPoint = Vector2.new(0.5, 0.5)
    TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.BackgroundTransparency = 1.000
    TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextBox.BorderSizePixel = 0
    TextBox.Position = UDim2.new(0.5, 0, 0.5, 0)
    TextBox.Size = UDim2.new(0.916666687, 0, 0.576271176, 0)
    TextBox.Font = Enum.Font.FredokaOne
    TextBox.PlaceholderColor3 = Color3.fromRGB(0, 0, 0)
    TextBox.PlaceholderText = "Search for crates here..."
    TextBox.Text = ""
    TextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextBox.TextScaled = true
    TextBox.TextSize = 14.000
    TextBox.TextWrapped = true
    TextBox.ZIndex = 3

    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = Container
    CloseBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.BackgroundTransparency = 1.000
    CloseBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Position = UDim2.new(0.959726393, 0, 0.0653256029, 0)
    CloseBtn.Size = UDim2.new(0.112041883, 0, 0.148404986, 0)
    CloseBtn.ZIndex = 3
    CloseBtn.Image = "rbxassetid://82177231415737"
end


table.freeze(Components)
return Components