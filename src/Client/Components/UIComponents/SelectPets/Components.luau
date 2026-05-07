--!strict
--!native
--!optimize 2


--[[ @section Variables ]]
local SelectPets = Instance.new("ScreenGui")
local ContainerFrame = Instance.new("Frame")
local SearchBox = Instance.new("Frame")
local FrameImage = Instance.new("ImageLabel")
local FrameBox = Instance.new("ImageLabel")
local TextBox = Instance.new("TextBox")
local CloseBtn = Instance.new("ImageButton")
local MainFrame = Instance.new("ImageLabel")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local TextButton = Instance.new("ImageLabel")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
local TextButton_2 = Instance.new("ImageLabel")
local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
local TextButton_3 = Instance.new("ImageLabel")
local UIAspectRatioConstraint_3 = Instance.new("UIAspectRatioConstraint")
local Title = Instance.new("ImageLabel")
local UIAspectRatioConstraint_4 = Instance.new("UIAspectRatioConstraint")
local BackgroundImg = Instance.new("ImageLabel")
local UIAspectRatioConstraint_5 = Instance.new("UIAspectRatioConstraint")
local ContinueBtn = Instance.new("ImageButton")
local ExpandBtn = Instance.new("ImageButton")

local ComponentsMap = { SelectPets = SelectPets }
--[[ @end_section Variables ]]


-- Set all component properties.
do
    SelectPets.Name = "SelectPets"
    SelectPets.Enabled = false
    SelectPets.ResetOnSpawn = false

    ContainerFrame.Name = "ContainerFrame"
    ContainerFrame.Parent = SelectPets
    ContainerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    ContainerFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ContainerFrame.BackgroundTransparency = 1.000
    ContainerFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ContainerFrame.BorderSizePixel = 0
    ContainerFrame.Position = UDim2.new(0.5, 0, 0.45, 0)
    ContainerFrame.Size = UDim2.new(0.515893698, 0, 0.584259272, 0)

    SearchBox.Name = "SearchBox"
    SearchBox.Parent = ContainerFrame
    SearchBox.AnchorPoint = Vector2.new(0.5, 0.5)
    SearchBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.BackgroundTransparency = 1.000
    SearchBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SearchBox.BorderSizePixel = 0
    SearchBox.Position = UDim2.new(0.715468645, 0, 0.0832321942, 0)
    SearchBox.Size = UDim2.new(0.358585864, 0, 0.09350238, 0)
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
    TextBox.PlaceholderText = "Search for pets here..."
    TextBox.Text = ""
    TextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextBox.TextScaled = true
    TextBox.TextSize = 14.000
    TextBox.TextWrapped = true

    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = ContainerFrame
    CloseBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.BackgroundTransparency = 1.000
    CloseBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Position = UDim2.new(0.965051353, 0, 0.0832321942, 0)
    CloseBtn.Size = UDim2.new(0.108080812, 0, 0.169572115, 0)
    CloseBtn.ZIndex = 3
    CloseBtn.Image = "rbxassetid://82177231415737"

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ContainerFrame
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainFrame.BackgroundTransparency = 1.000
    MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0.924242437, 0, 0.839936614, 0)
    MainFrame.ZIndex = 2
    MainFrame.Image = "rbxassetid://133757436459656"

    ScrollingFrame.Parent = MainFrame
    ScrollingFrame.Active = true
    ScrollingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    ScrollingFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    ScrollingFrame.BackgroundTransparency = 1.000
    ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    ScrollingFrame.Size = UDim2.new(0.890710354, 0, 0.754716992, 0)
    ScrollingFrame.ZIndex = 2
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

    UIListLayout.Parent = ScrollingFrame
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 7)
    UIListLayout.Wraps = true

    TextButton.Parent = ScrollingFrame
    TextButton.BackgroundColor3 = Color3.fromRGB(255, 82, 85)
    TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextButton.BorderSizePixel = 0
    TextButton.LayoutOrder = 1
    TextButton.Position = UDim2.new(0, 0, 0.584536374, 0)
    TextButton.Size = UDim2.new(0.495000005, 0, 1, 0)
    TextButton.ZIndex = 2
    TextButton.BackgroundTransparency = 1
    TextButton.Visible = false
    TextButton.Image = "rbxassetid://119610995981036"
    TextButton.Name = "Gigantic"

    UIAspectRatioConstraint.Parent = TextButton
    UIAspectRatioConstraint.AspectRatio = 1.009

    TextButton_2.Parent = ScrollingFrame
    TextButton_2.BackgroundColor3 = Color3.fromRGB(255, 82, 85)
    TextButton_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextButton_2.BorderSizePixel = 0
    TextButton_2.LayoutOrder = 2
    TextButton_2.Position = UDim2.new(0, 0, 0.584536374, 0)
    TextButton_2.Size = UDim2.new(0.243000001, 0, 0.5, 0)
    TextButton_2.ZIndex = 2
    TextButton_2.BackgroundTransparency = 1
    TextButton_2.Visible = false
    TextButton_2.Image = "rbxassetid://119610995981036"
    TextButton_2.Name = "Huge"

    UIAspectRatioConstraint_2.Parent = TextButton_2
    UIAspectRatioConstraint_2.AspectRatio = 1.009

    TextButton_3.Parent = ScrollingFrame
    TextButton_3.BackgroundColor3 = Color3.fromRGB(255, 82, 85)
    TextButton_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextButton_3.BorderSizePixel = 0
    TextButton_3.LayoutOrder = 3
    TextButton_3.Position = UDim2.new(0, 0, 0.584536374, 0)
    TextButton_3.Size = UDim2.new(0.116999999, 0, 0.25, 0)
    TextButton_3.ZIndex = 2
    TextButton_3.BackgroundTransparency = 1
    TextButton_3.Visible = false
    TextButton_3.Image = "rbxassetid://119610995981036"
    TextButton_3.Name = "Default"

    UIAspectRatioConstraint_3.Parent = TextButton_3
    UIAspectRatioConstraint_3.AspectRatio = 1.009

    Title.Name = "Title"
    Title.Parent = ContainerFrame
    Title.AnchorPoint = Vector2.new(0.5, 0.5)
    Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1.000
    Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Title.BorderSizePixel = 0
    Title.Position = UDim2.new(0.1967877, 0, 0.0830370858, 0)
    Title.Size = UDim2.new(0.346464634, 0, 0.0972887501, 0)
    Title.ZIndex = 3
    Title.Image = "rbxassetid://122394323802918"

    UIAspectRatioConstraint_4.Parent = Title
    UIAspectRatioConstraint_4.AspectRatio = 5.587

    BackgroundImg.Name = "BackgroundImg"
    BackgroundImg.Parent = ContainerFrame
    BackgroundImg.AnchorPoint = Vector2.new(0.5, 0.5)
    BackgroundImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BackgroundImg.BackgroundTransparency = 1.000
    BackgroundImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    BackgroundImg.BorderSizePixel = 0
    BackgroundImg.Position = UDim2.new(0.5, 0, 0.5, 0)
    BackgroundImg.Rotation = -5.000
    BackgroundImg.Size = UDim2.new(0.924242437, 0, 0.839936614, 0)
    BackgroundImg.Image = "rbxassetid://114571910923938"

    ExpandBtn.Name = "ExpandBtn"
    ExpandBtn.Parent = ContainerFrame
    ExpandBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ExpandBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    ExpandBtn.BackgroundTransparency = 1.000
    ExpandBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ExpandBtn.BorderSizePixel = 0
    ExpandBtn.Position = UDim2.new(0.429, 0, 0.082, 0)
    ExpandBtn.Size = UDim2.new(0.0909090936, 0, 0.142630741, 0)
    ExpandBtn.ZIndex = 3
    ExpandBtn.Image = "rbxassetid://124678946983065"

    UIAspectRatioConstraint_5.Parent = ContainerFrame
    UIAspectRatioConstraint_5.AspectRatio = 1.569

    ContinueBtn.Name = "ContinueBtn"
    ContinueBtn.Parent = ContainerFrame
    ContinueBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ContinueBtn.BackgroundTransparency = 1.000
    ContinueBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ContinueBtn.BorderSizePixel = 0
    ContinueBtn.Position = UDim2.new(0.5, 0, 0.916, 0)
    ContinueBtn.Size = UDim2.new(0.265656561, 0, 0.150554672, 0)
    ContinueBtn.ZIndex = 3
    ContinueBtn.Image = "rbxassetid://87907459450827"
    ContinueBtn.AnchorPoint = Vector2.new(0.5, 0.5)
end


table.freeze(ComponentsMap)
return ComponentsMap