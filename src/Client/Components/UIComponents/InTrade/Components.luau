--!strict
--!native
--!optimize 2


--[[ @section Variables ]]
local InTrade = Instance.new("ScreenGui")
local Container = Instance.new("Frame")
local MainFrame = Instance.new("ImageLabel")
local Container_2 = Instance.new("Frame")
local UIListLayout = Instance.new("UIListLayout")
local TitleBar = Instance.new("Frame")
local ImageLabel = Instance.new("ImageLabel")
local ImageLabel_2 = Instance.new("ImageLabel")
local GemsOfferContainer = Instance.new("Frame")
local YourGemsOffer = Instance.new("Frame")
local ImageLabel_3 = Instance.new("ImageLabel")
local AmountBox = Instance.new("ImageLabel")
local TextBox = Instance.new("TextBox")
local TheirGemsOffer = Instance.new("Frame")
local ImageLabel_4 = Instance.new("ImageLabel")
local Frame = Instance.new("Frame")
local TextLabel = Instance.new("TextLabel")
local Separator = Instance.new("Frame")
local ImageLabel_5 = Instance.new("ImageLabel")
local ImageLabel_6 = Instance.new("ImageLabel")
local Separator_2 = Instance.new("Frame")
local ImageLabel_7 = Instance.new("ImageLabel")
local ImageLabel_8 = Instance.new("ImageLabel")
local MainOfferContainer = Instance.new("Frame")
local InnerContainer = Instance.new("Frame")
local YourSide = Instance.new("ImageLabel")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIListLayout_2 = Instance.new("UIListLayout")
local Default = Instance.new("ImageLabel")
local UIAspectRatioConstraint_1 = Instance.new("UIAspectRatioConstraint")
local Gigantic = Instance.new("ImageLabel")
local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
local Huge = Instance.new("ImageLabel")
local UIAspectRatioConstraint_3 = Instance.new("UIAspectRatioConstraint")
local Default_2 = Instance.new("ImageLabel")
local UIAspectRatioConstraint_4 = Instance.new("UIAspectRatioConstraint")
local Gigantic_2 = Instance.new("ImageLabel")
local UIAspectRatioConstraint_5 = Instance.new("UIAspectRatioConstraint")
local Huge_2 = Instance.new("ImageLabel")
local UIAspectRatioConstraint_6 = Instance.new("UIAspectRatioConstraint")
local TheirSide = Instance.new("ImageLabel")
local ScrollingFrame_2 = Instance.new("ScrollingFrame")
local UIListLayout_3 = Instance.new("UIListLayout")
local TextLabel_2 = Instance.new("TextLabel")
local SearchBoxesContainer = Instance.new("Frame")
local YourSearchBox = Instance.new("Frame")
local ImageLabel_9 = Instance.new("ImageLabel")
local SearchBoxFrame = Instance.new("ImageLabel")
local TextBox_2 = Instance.new("TextBox")
local TheirSearchBox = Instance.new("Frame")
local ImageLabel_10 = Instance.new("ImageLabel")
local SearchBoxFrame_2 = Instance.new("ImageLabel")
local TextBox_3 = Instance.new("TextBox")
local TitleImg = Instance.new("ImageLabel")
local BackgroundImg = Instance.new("ImageLabel")
local ExpandBtn = Instance.new("ImageButton")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
local ActionsContainer = Instance.new("Frame")
local ReadyUpBtn = Instance.new("ImageButton")
local CancelBtn = Instance.new("ImageButton")
local UIAspectRatioConstraint_7 = Instance.new("UIAspectRatioConstraint")
local UIAspectRatioConstraint_8 = Instance.new("UIAspectRatioConstraint")

local ComponentsMap = { InTrade = InTrade }
--[[ @end_section Variables ]]


-- Set all component properties.
do
    InTrade.Name = "InTrade"
    InTrade.Enabled = false
    InTrade.ResetOnSpawn = false

    Container.Name = "Container"
    Container.Parent = InTrade
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Container.BackgroundTransparency = 1.000
    Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Container.BorderSizePixel = 0
    Container.Position = UDim2.new(0.5, 0, 0.45, 0)
    Container.Size = UDim2.new(0.601354897, 0, 0.824999988, 0)

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = Container
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainFrame.BackgroundTransparency = 1.000
    MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0.942807615, 0, 0.893378198, 0)
    MainFrame.ZIndex = 2
    MainFrame.Image = "rbxassetid://76257393204558"

    Default.Name = "Default"
    Default.BackgroundTransparency = 1
    Default.Parent = ScrollingFrame
    Default.BackgroundColor3 = Color3.fromRGB(255, 82, 85)
    Default.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Default.BorderSizePixel = 0
    Default.LayoutOrder = 3
    Default.Position = UDim2.new(7.64851578e-08, 0, 0.582110822, 0)
    Default.Size = UDim2.new(0.233999997, 0, 0.233999997, 0)
    Default.ZIndex = 2
    Default.Visible = false
    Default.Image = "rbxassetid://111833470989816"

    UIAspectRatioConstraint_1.Parent = Default
    UIAspectRatioConstraint_1.AspectRatio = 0.997

    Gigantic.Name = "Gigantic"
    Gigantic.BackgroundTransparency = 1
    Gigantic.Parent = ScrollingFrame
    Gigantic.BackgroundColor3 = Color3.fromRGB(255, 82, 85)
    Gigantic.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Gigantic.BorderSizePixel = 0
    Gigantic.LayoutOrder = 1
    Gigantic.Position = UDim2.new(-7.64851578e-08, 0, 0.528385162, 0)
    Gigantic.Size = UDim2.new(0.998000026, 0, 1, 0)
    Gigantic.ZIndex = 2
    Gigantic.Visible = false
    Gigantic.Image = "rbxassetid://111833470989816"

    UIAspectRatioConstraint_2.Parent = Gigantic
    UIAspectRatioConstraint_2.AspectRatio = 0.995

    Huge.Name = "Huge"
    Huge.BackgroundTransparency = 1
    Huge.Parent = ScrollingFrame
    Huge.BackgroundColor3 = Color3.fromRGB(255, 82, 85)
    Huge.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Huge.BorderSizePixel = 0
    Huge.LayoutOrder = 2
    Huge.Position = UDim2.new(-7.64851578e-08, 0, -0.103777729, 0)
    Huge.Size = UDim2.new(0.486000001, 0, 0.486000001, 0)
    Huge.ZIndex = 2
    Huge.Visible = false
    Huge.Image = "rbxassetid://111833470989816"

    UIAspectRatioConstraint_3.Parent = Huge
    UIAspectRatioConstraint_3.AspectRatio = 0.997

    Default_2.Name = "Default"
    Default_2.BackgroundTransparency = 1
    Default_2.Parent = ScrollingFrame_2
    Default_2.BackgroundColor3 = Color3.fromRGB(255, 82, 85)
    Default_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Default_2.BorderSizePixel = 0
    Default_2.LayoutOrder = 3
    Default_2.Position = UDim2.new(7.64851578e-08, 0, 0.582110822, 0)
    Default_2.Size = UDim2.new(0.233999997, 0, 0.233999997, 0)
    Default_2.ZIndex = 2
    Default_2.Visible = false
    Default_2.Image = "rbxassetid://111833470989816"

    UIAspectRatioConstraint_4.Parent = Default_2
    UIAspectRatioConstraint_4.AspectRatio = 0.997

    Gigantic_2.Name = "Gigantic"
    Gigantic_2.BackgroundTransparency = 1
    Gigantic_2.Parent = ScrollingFrame_2
    Gigantic_2.BackgroundColor3 = Color3.fromRGB(255, 82, 85)
    Gigantic_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Gigantic_2.BorderSizePixel = 0
    Gigantic_2.LayoutOrder = 1
    Gigantic_2.Position = UDim2.new(-7.64851578e-08, 0, 0.528385162, 0)
    Gigantic_2.Size = UDim2.new(0.998000026, 0, 1, 0)
    Gigantic_2.ZIndex = 2
    Gigantic_2.Visible = false
    Gigantic_2.Image = "rbxassetid://111833470989816"

    UIAspectRatioConstraint_5.Parent = Gigantic_2
    UIAspectRatioConstraint_5.AspectRatio = 0.995

    Huge_2.Name = "Huge"
    Huge_2.BackgroundTransparency = 1
    Huge_2.Parent = ScrollingFrame_2
    Huge_2.BackgroundColor3 = Color3.fromRGB(255, 82, 85)
    Huge_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Huge_2.BorderSizePixel = 0
    Huge_2.LayoutOrder = 2
    Huge_2.Position = UDim2.new(-7.64851578e-08, 0, -0.103777729, 0)
    Huge_2.Size = UDim2.new(0.486000001, 0, 0.486000001, 0)
    Huge_2.ZIndex = 2
    Huge_2.Visible = false
    Huge_2.Image = "rbxassetid://111833470989816"

    UIAspectRatioConstraint_6.Parent = Huge_2
    UIAspectRatioConstraint_6.AspectRatio = 0.997

    Container_2.Name = "InnerContainer"
    Container_2.Parent = MainFrame
    Container_2.AnchorPoint = Vector2.new(0.5, 0.5)
    Container_2.BackgroundColor3 = Color3.fromRGB(255, 30, 34)
    Container_2.BackgroundTransparency = 1.000
    Container_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Container_2.BorderSizePixel = 0
    Container_2.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container_2.Size = UDim2.new(0.908088207, 0, 0.874371886, 0)
    Container_2.ZIndex = 2

    UIListLayout.Parent = Container_2
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0.0199999996, 0)

    TitleBar.Name = "TitleBar"
    TitleBar.Parent = Container_2
    TitleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TitleBar.BackgroundTransparency = 1.000
    TitleBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TitleBar.BorderSizePixel = 0
    TitleBar.LayoutOrder = 1
    TitleBar.Position = UDim2.new(0.0875506103, 0, 0.258620679, 0)
    TitleBar.Size = UDim2.new(0.822874486, 0, 0.0833333358, 0)
    TitleBar.ZIndex = 2

    ImageLabel.Parent = TitleBar
    ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel.BackgroundTransparency = 1.000
    ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel.BorderSizePixel = 0
    ImageLabel.Position = UDim2.new(0.675276756, 0, 0.172413796, 0)
    ImageLabel.Size = UDim2.new(0.324723244, 0, 0.672413766, 0)
    ImageLabel.ZIndex = 2
    ImageLabel.Image = "rbxassetid://89600083889940"

    ImageLabel_2.Parent = TitleBar
    ImageLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel_2.BackgroundTransparency = 1.000
    ImageLabel_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel_2.BorderSizePixel = 0
    ImageLabel_2.Position = UDim2.new(0, 0, 0.172413796, 0)
    ImageLabel_2.Size = UDim2.new(0.301353008, 0, 0.66056484, 0)
    ImageLabel_2.ZIndex = 2
    ImageLabel_2.Image = "rbxassetid://107801043865265"

    GemsOfferContainer.Name = "GemsOfferContainer"
    GemsOfferContainer.Parent = Container_2
    GemsOfferContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    GemsOfferContainer.BackgroundTransparency = 1.000
    GemsOfferContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    GemsOfferContainer.BorderSizePixel = 0
    GemsOfferContainer.LayoutOrder = 5
    GemsOfferContainer.Size = UDim2.new(0.898785412, 0, 0.0847701132, 0)
    GemsOfferContainer.ZIndex = 2

    YourGemsOffer.Name = "YourGemsOffer"
    YourGemsOffer.Parent = GemsOfferContainer
    YourGemsOffer.BackgroundColor3 = Color3.fromRGB(140, 140, 140)
    YourGemsOffer.BackgroundTransparency = 1.000
    YourGemsOffer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    YourGemsOffer.BorderSizePixel = 0
    YourGemsOffer.Size = UDim2.new(0.39977476, 0, 1, 0)
    YourGemsOffer.ZIndex = 2

    ImageLabel_3.Parent = YourGemsOffer
    ImageLabel_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel_3.BackgroundTransparency = 1.000
    ImageLabel_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel_3.BorderSizePixel = 0
    ImageLabel_3.Position = UDim2.new(0, 0, 0.118644066, 0)
    ImageLabel_3.Size = UDim2.new(0.126760557, 0, 0.762711883, 0)
    ImageLabel_3.ZIndex = 2
    ImageLabel_3.Image = "rbxassetid://90285827047834"

    AmountBox.Name = "AmountBox"
    AmountBox.Parent = YourGemsOffer
    AmountBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    AmountBox.BackgroundTransparency = 1.000
    AmountBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    AmountBox.BorderSizePixel = 0
    AmountBox.Position = UDim2.new(0.154929578, 0, 0, 0)
    AmountBox.Size = UDim2.new(0.845070422, 0, 1, 0)
    AmountBox.ZIndex = 2
    AmountBox.Image = "rbxassetid://117773988622655"

    TextBox.Parent = AmountBox
    TextBox.AnchorPoint = Vector2.new(0.5, 0.5)
    TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.BackgroundTransparency = 1.000
    TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextBox.BorderSizePixel = 0
    TextBox.Position = UDim2.new(0.5, 0, 0.5, 0)
    TextBox.Size = UDim2.new(0.916999996, 0, 0.575999975, 0)
    TextBox.Font = Enum.Font.FredokaOne
    TextBox.PlaceholderColor3 = Color3.fromRGB(0, 0, 0)
    TextBox.PlaceholderText = "Your gems offer here..."
    TextBox.Text = ""
    TextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextBox.TextScaled = true
    TextBox.TextSize = 14.000
    TextBox.TextWrapped = true
    TextBox.ZIndex = 2

    TheirGemsOffer.Name = "TheirGemsOffer"
    TheirGemsOffer.Parent = GemsOfferContainer
    TheirGemsOffer.BackgroundColor3 = Color3.fromRGB(140, 140, 140)
    TheirGemsOffer.BackgroundTransparency = 1.000
    TheirGemsOffer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TheirGemsOffer.BorderSizePixel = 0
    TheirGemsOffer.Position = UDim2.new(0.60022521, 0, 0, 0)
    TheirGemsOffer.Size = UDim2.new(0.39977476, 0, 1, 0)
    TheirGemsOffer.ZIndex = 2

    ImageLabel_4.Parent = TheirGemsOffer
    ImageLabel_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel_4.BackgroundTransparency = 1.000
    ImageLabel_4.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel_4.BorderSizePixel = 0
    ImageLabel_4.Position = UDim2.new(0, 0, 0.118644066, 0)
    ImageLabel_4.Size = UDim2.new(0.126760557, 0, 0.762711883, 0)
    ImageLabel_4.ZIndex = 2
    ImageLabel_4.Image = "rbxassetid://90285827047834"

    Frame.Parent = TheirGemsOffer
    Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Frame.BackgroundTransparency = 1.000
    Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Frame.BorderSizePixel = 0
    Frame.Position = UDim2.new(0.154929578, 0, 0, 0)
    Frame.Size = UDim2.new(0.845070422, 0, 1, 0)
    Frame.ZIndex = 2

    TextLabel.Parent = Frame
    TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.BackgroundTransparency = 1.000
    TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BorderSizePixel = 0
    TextLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    TextLabel.Size = UDim2.new(0.916999996, 0, 0.575999975, 0)
    TextLabel.ZIndex = 2
    TextLabel.Font = Enum.Font.FredokaOne
    TextLabel.Text = "123,456,789,101,112"
    TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.TextScaled = true
    TextLabel.TextSize = 14.000
    TextLabel.TextWrapped = true

    Separator.Name = "Separator"
    Separator.Parent = Container_2
    Separator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Separator.BackgroundTransparency = 1.000
    Separator.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Separator.BorderSizePixel = 0
    Separator.LayoutOrder = 2
    Separator.Size = UDim2.new(1, 0, 0.00718390802, 0)
    Separator.ZIndex = 2

    ImageLabel_5.Parent = Separator
    ImageLabel_5.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel_5.BackgroundTransparency = 1.000
    ImageLabel_5.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel_5.BorderSizePixel = 0
    ImageLabel_5.Size = UDim2.new(0.459514171, 0, 1, 0)
    ImageLabel_5.ZIndex = 2
    ImageLabel_5.Image = "rbxassetid://103398483303506"

    ImageLabel_6.Parent = Separator
    ImageLabel_6.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel_6.BackgroundTransparency = 1.000
    ImageLabel_6.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel_6.BorderSizePixel = 0
    ImageLabel_6.Position = UDim2.new(0.540485859, 0, 0, 0)
    ImageLabel_6.Size = UDim2.new(0.459514171, 0, 1, 0)
    ImageLabel_6.ZIndex = 2
    ImageLabel_6.Image = "rbxassetid://103398483303506"

    Separator_2.Name = "Separator"
    Separator_2.Parent = Container_2
    Separator_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Separator_2.BackgroundTransparency = 1.000
    Separator_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Separator_2.BorderSizePixel = 0
    Separator_2.LayoutOrder = 4
    Separator_2.Size = UDim2.new(1, 0, 0.00718390802, 0)
    Separator_2.ZIndex = 2

    ImageLabel_7.Parent = Separator_2
    ImageLabel_7.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel_7.BackgroundTransparency = 1.000
    ImageLabel_7.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel_7.BorderSizePixel = 0
    ImageLabel_7.Size = UDim2.new(0.459514171, 0, 1, 0)
    ImageLabel_7.ZIndex = 2
    ImageLabel_7.Image = "rbxassetid://103398483303506"

    ImageLabel_8.Parent = Separator_2
    ImageLabel_8.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel_8.BackgroundTransparency = 1.000
    ImageLabel_8.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel_8.BorderSizePixel = 0
    ImageLabel_8.Position = UDim2.new(0.540485859, 0, 0, 0)
    ImageLabel_8.Size = UDim2.new(0.459514171, 0, 1, 0)
    ImageLabel_8.ZIndex = 2
    ImageLabel_8.Image = "rbxassetid://103398483303506"

    MainOfferContainer.Name = "MainOfferContainer"
    MainOfferContainer.Parent = Container_2
    MainOfferContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainOfferContainer.BackgroundTransparency = 1.000
    MainOfferContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MainOfferContainer.BorderSizePixel = 0
    MainOfferContainer.LayoutOrder = 3
    MainOfferContainer.Position = UDim2.new(0.0506072864, 0, 0.160201147, 0)
    MainOfferContainer.Size = UDim2.new(0.998987854, 0, 0.709770143, 0)
    MainOfferContainer.ZIndex = 2

    InnerContainer.Name = "InnerContainer"
    InnerContainer.Parent = MainOfferContainer
    InnerContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    InnerContainer.BackgroundTransparency = 1.000
    InnerContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    InnerContainer.BorderSizePixel = 0
    InnerContainer.Size = UDim2.new(1, 0, 0.91093111, 0)
    InnerContainer.ZIndex = 2

    YourSide.Name = "YourSide"
    YourSide.Parent = InnerContainer
    YourSide.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    YourSide.BackgroundTransparency = 1.000
    YourSide.BorderColor3 = Color3.fromRGB(0, 0, 0)
    YourSide.BorderSizePixel = 0
    YourSide.Size = UDim2.new(0.455465585, 0, 1, 0)
    YourSide.ZIndex = 2
    YourSide.Image = "rbxassetid://78706372818141"

    ScrollingFrame.Parent = YourSide
    ScrollingFrame.Active = true
    ScrollingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    ScrollingFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    ScrollingFrame.BackgroundTransparency = 1.000
    ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    ScrollingFrame.Size = UDim2.new(0.887565017, 0, 0.888888896, 0)
    ScrollingFrame.ZIndex = 2
    ScrollingFrame.ScrollBarThickness = 0
    ScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
    ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

    UIListLayout_2.Parent = ScrollingFrame
    UIListLayout_2.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_2.Padding = UDim.new(0, 7)
    UIListLayout_2.Wraps = true

    TheirSide.Name = "TheirSide"
    TheirSide.Parent = InnerContainer
    TheirSide.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TheirSide.BackgroundTransparency = 1.000
    TheirSide.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TheirSide.BorderSizePixel = 0
    TheirSide.Position = UDim2.new(0.545000017, 0, 0, 0)
    TheirSide.Size = UDim2.new(0.455465585, 0, 1, 0)
    TheirSide.ZIndex = 2
    TheirSide.Image = "rbxassetid://78706372818141"

    ScrollingFrame_2.Parent = TheirSide
    ScrollingFrame_2.Active = true
    ScrollingFrame_2.AnchorPoint = Vector2.new(0.5, 0.5)
    ScrollingFrame_2.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    ScrollingFrame_2.BackgroundTransparency = 1.000
    ScrollingFrame_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ScrollingFrame_2.BorderSizePixel = 0
    ScrollingFrame_2.Position = UDim2.new(0.5, 0, 0.5, 0)
    ScrollingFrame_2.Size = UDim2.new(0.887565017, 0, 0.888888896, 0)
    ScrollingFrame_2.ZIndex = 2
    ScrollingFrame_2.ScrollBarThickness = 0
    ScrollingFrame_2.CanvasSize = UDim2.fromOffset(0, 0)
    ScrollingFrame_2.AutomaticCanvasSize = Enum.AutomaticSize.Y

    UIListLayout_3.Parent = ScrollingFrame_2
    UIListLayout_3.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_3.Padding = UDim.new(0, 7)
    UIListLayout_3.Wraps = true

    TextLabel_2.Parent = InnerContainer
    TextLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel_2.BackgroundTransparency = 1.000
    TextLabel_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel_2.BorderSizePixel = 0
    TextLabel_2.Position = UDim2.new(0.470647782, 0, 0.451111108, 0)
    TextLabel_2.Size = UDim2.new(0.0587044582, 0, 0.0977777764, 0)
    TextLabel_2.ZIndex = 2
    TextLabel_2.Font = Enum.Font.FredokaOne
    TextLabel_2.Text = "For"
    TextLabel_2.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel_2.TextScaled = true
    TextLabel_2.TextSize = 14.000
    TextLabel_2.TextWrapped = true

    SearchBoxesContainer.Name = "SearchBoxesContainer"
    SearchBoxesContainer.Parent = MainOfferContainer
    SearchBoxesContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SearchBoxesContainer.BackgroundTransparency = 1.000
    SearchBoxesContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SearchBoxesContainer.BorderSizePixel = 0
    SearchBoxesContainer.Position = UDim2.new(0.0506585613, 0, 0.880566776, 0)
    SearchBoxesContainer.Size = UDim2.new(0.897669733, 0, 0.119433194, 0)
    SearchBoxesContainer.ZIndex = 2

    YourSearchBox.Name = "YourSearchBox"
    YourSearchBox.Parent = SearchBoxesContainer
    YourSearchBox.BackgroundColor3 = Color3.fromRGB(140, 140, 140)
    YourSearchBox.BackgroundTransparency = 1.000
    YourSearchBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    YourSearchBox.BorderSizePixel = 0
    YourSearchBox.Size = UDim2.new(0.400677204, 0, 1, 0)
    YourSearchBox.ZIndex = 2

    ImageLabel_9.Parent = YourSearchBox
    ImageLabel_9.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel_9.BackgroundTransparency = 1.000
    ImageLabel_9.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel_9.BorderSizePixel = 0
    ImageLabel_9.Position = UDim2.new(0, 0, 0.118644066, 0)
    ImageLabel_9.Size = UDim2.new(0.126760557, 0, 0.762711883, 0)
    ImageLabel_9.ZIndex = 2
    ImageLabel_9.Image = "rbxassetid://111185157994065"

    SearchBoxFrame.Name = "SearchBoxFrame"
    SearchBoxFrame.Parent = YourSearchBox
    SearchBoxFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SearchBoxFrame.BackgroundTransparency = 1.000
    SearchBoxFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SearchBoxFrame.BorderSizePixel = 0
    SearchBoxFrame.Position = UDim2.new(0.154929578, 0, 0, 0)
    SearchBoxFrame.Size = UDim2.new(0.845070422, 0, 1, 0)
    SearchBoxFrame.ZIndex = 2
    SearchBoxFrame.Image = "rbxassetid://103963410173665"

    TextBox_2.Parent = SearchBoxFrame
    TextBox_2.AnchorPoint = Vector2.new(0.5, 0.5)
    TextBox_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextBox_2.BackgroundTransparency = 1.000
    TextBox_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextBox_2.BorderSizePixel = 0
    TextBox_2.Position = UDim2.new(0.5, 0, 0.5, 0)
    TextBox_2.Size = UDim2.new(0.916999996, 0, 0.575999975, 0)
    TextBox_2.ZIndex = 2
    TextBox_2.Font = Enum.Font.FredokaOne
    TextBox_2.PlaceholderColor3 = Color3.fromRGB(0, 0, 0)
    TextBox_2.PlaceholderText = "Search for pets here..."
    TextBox_2.Text = ""
    TextBox_2.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextBox_2.TextScaled = true
    TextBox_2.TextSize = 14.000
    TextBox_2.TextWrapped = true

    TheirSearchBox.Name = "TheirSearchBox"
    TheirSearchBox.Parent = SearchBoxesContainer
    TheirSearchBox.BackgroundColor3 = Color3.fromRGB(140, 140, 140)
    TheirSearchBox.BackgroundTransparency = 1.000
    TheirSearchBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TheirSearchBox.BorderSizePixel = 0
    TheirSearchBox.Position = UDim2.new(0.599322796, 0, 0, 0)
    TheirSearchBox.Size = UDim2.new(0.400677204, 0, 1, 0)
    TheirSearchBox.ZIndex = 2

    ImageLabel_10.Parent = TheirSearchBox
    ImageLabel_10.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel_10.BackgroundTransparency = 1.000
    ImageLabel_10.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel_10.BorderSizePixel = 0
    ImageLabel_10.Position = UDim2.new(0, 0, 0.118644066, 0)
    ImageLabel_10.Size = UDim2.new(0.126760557, 0, 0.762711883, 0)
    ImageLabel_10.ZIndex = 2
    ImageLabel_10.Image = "rbxassetid://111185157994065"

    SearchBoxFrame_2.Name = "SearchBoxFrame"
    SearchBoxFrame_2.Parent = TheirSearchBox
    SearchBoxFrame_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SearchBoxFrame_2.BackgroundTransparency = 1.000
    SearchBoxFrame_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SearchBoxFrame_2.BorderSizePixel = 0
    SearchBoxFrame_2.Position = UDim2.new(0.154929578, 0, 0, 0)
    SearchBoxFrame_2.Size = UDim2.new(0.845070422, 0, 1, 0)
    SearchBoxFrame_2.ZIndex = 2
    SearchBoxFrame_2.Image = "rbxassetid://103963410173665"

    TextBox_3.Parent = SearchBoxFrame_2
    TextBox_3.AnchorPoint = Vector2.new(0.5, 0.5)
    TextBox_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextBox_3.BackgroundTransparency = 1.000
    TextBox_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextBox_3.BorderSizePixel = 0
    TextBox_3.Position = UDim2.new(0.5, 0, 0.5, 0)
    TextBox_3.Size = UDim2.new(0.916999996, 0, 0.575999975, 0)
    TextBox_3.ZIndex = 2
    TextBox_3.Font = Enum.Font.FredokaOne
    TextBox_3.PlaceholderColor3 = Color3.fromRGB(0, 0, 0)
    TextBox_3.PlaceholderText = "Search for pets here..."
    TextBox_3.Text = ""
    TextBox_3.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextBox_3.TextScaled = true
    TextBox_3.TextSize = 14.000
    TextBox_3.TextWrapped = true

    TitleImg.Name = "TitleImg"
    TitleImg.Parent = Container
    TitleImg.AnchorPoint = Vector2.new(0.5, 0.5)
    TitleImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TitleImg.BackgroundTransparency = 1.000
    TitleImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TitleImg.BorderSizePixel = 0
    TitleImg.Position = UDim2.new(0.10745234, 0, 0.0549943894, 0)
    TitleImg.Size = UDim2.new(0.204506069, 0, 0.0864197537, 0)
    TitleImg.ZIndex = 3
    TitleImg.Image = "rbxassetid://140570877388767"

    BackgroundImg.Name = "BackgroundImg"
    BackgroundImg.Parent = Container
    BackgroundImg.AnchorPoint = Vector2.new(0.5, 0.5)
    BackgroundImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BackgroundImg.BackgroundTransparency = 1.000
    BackgroundImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    BackgroundImg.BorderSizePixel = 0
    BackgroundImg.Position = UDim2.new(0.5, 0, 0.5, 0)
    BackgroundImg.Rotation = -5.000
    BackgroundImg.Size = UDim2.new(0.942807615, 0, 0.893378198, 0)
    BackgroundImg.Image = "rbxassetid://132043958750769"

    ExpandBtn.Name = "ExpandBtn"
    ExpandBtn.Parent = Container
    ExpandBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    ExpandBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ExpandBtn.BackgroundTransparency = 1.000
    ExpandBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ExpandBtn.BorderSizePixel = 0
    ExpandBtn.Position = UDim2.new(0.261698455, 0, 0.0549943894, 0)
    ExpandBtn.Size = UDim2.new(0.0779896006, 0, 0.101010099, 0)
    ExpandBtn.ZIndex = 3
    ExpandBtn.Image = "rbxassetid://83228680858063"

    UIAspectRatioConstraint.Parent = Container
    UIAspectRatioConstraint.AspectRatio = 1.295

    ActionsContainer.Name = "ActionsContainer"
    ActionsContainer.Parent = Container
    ActionsContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ActionsContainer.BackgroundTransparency = 1.000
    ActionsContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ActionsContainer.BorderSizePixel = 0
    ActionsContainer.Position = UDim2.new(0.279896021, 0, 0.884399533, 0)
    ActionsContainer.Size = UDim2.new(0.439341426, 0, 0.106621772, 0)
    ActionsContainer.ZIndex = 3
    ActionsContainer.ClipsDescendants = false

    ReadyUpBtn.Name = "ReadyUpBtn"
    ReadyUpBtn.Parent = ActionsContainer
    ReadyUpBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    ReadyUpBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ReadyUpBtn.BackgroundTransparency = 1.000
    ReadyUpBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ReadyUpBtn.BorderSizePixel = 0
    ReadyUpBtn.Position = UDim2.new(0.255285999, 0, 0.5, 0)
    ReadyUpBtn.Size = UDim2.new(0.530571997, 0, 1, 0)
    ReadyUpBtn.Image = "rbxassetid://114341575596821"
    ReadyUpBtn.ZIndex = 3

    CancelBtn.Name = "CancelBtn"
    CancelBtn.Parent = ActionsContainer
    CancelBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    CancelBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CancelBtn.BackgroundTransparency = 1.000
    CancelBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CancelBtn.BorderSizePixel = 0
    CancelBtn.Position = UDim2.new(0.790078888, 0, 0.5, 0)
    CancelBtn.Size = UDim2.new(0.439842194, 0, 1, 0)
    CancelBtn.Image = "rbxassetid://110571593143299"
    CancelBtn.ZIndex = 3

    UIAspectRatioConstraint_7.Parent = Separator
    UIAspectRatioConstraint_7.AspectRatio = 197.573

    UIAspectRatioConstraint_8.Parent = Separator_2
    UIAspectRatioConstraint_8.AspectRatio = 1.295
end


table.freeze(ComponentsMap)
return ComponentsMap