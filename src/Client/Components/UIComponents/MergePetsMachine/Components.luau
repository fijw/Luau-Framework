--!strict
--!native
--!optimize 2


--[[ @section Variables ]]
local MergePetsMachine = Instance.new("ScreenGui")
local Container = Instance.new("Frame")
local MainFrame = Instance.new("ImageLabel")
local DescImg = Instance.new("ImageLabel")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local TextButton = Instance.new("ImageLabel")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
local TextButton_2 = Instance.new("ImageLabel")
local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
local TextButton_3 = Instance.new("ImageLabel")
local UIAspectRatioConstraint_3 = Instance.new("UIAspectRatioConstraint")
local BackgroundImg = Instance.new("ImageLabel")
local TitleImg = Instance.new("ImageLabel")
local UIAspectRatioConstraint_4 = Instance.new("UIAspectRatioConstraint")
local SearchBox = Instance.new("Frame")
local FrameImage = Instance.new("ImageLabel")
local FrameBox = Instance.new("ImageLabel")
local TextBox = Instance.new("TextBox")
local CloseBtn = Instance.new("ImageButton")
local MergeBtn = Instance.new("ImageButton")
local UIAspectRatioConstraint_5 = Instance.new("UIAspectRatioConstraint")
local ExpandBtn = Instance.new("ImageButton")

local ComponentsMap = { MergePetsMachine = MergePetsMachine }
--[[ @end_section Variables ]]


-- Set all component properties.
do
    MergePetsMachine.Name = "MergePetsMachine"
    MergePetsMachine.Enabled = false
    MergePetsMachine.ResetOnSpawn = false

    Container.Name = "Container"
    Container.Parent = MergePetsMachine
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Container.BackgroundTransparency = 1.000
    Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Container.BorderSizePixel = 0
    Container.Position = UDim2.new(0.5, 0, 0.45, 0)
    Container.Size = UDim2.new(0.518499196, 0, 0.691666663, 0)

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = Container
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainFrame.BackgroundTransparency = 1.000
    MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0.919598043, 0, 0.864792585, 0)
    MainFrame.ZIndex = 2
    MainFrame.Image = "rbxassetid://130064258970847"

    DescImg.Name = "DescImg"
    DescImg.Parent = MainFrame
    DescImg.AnchorPoint = Vector2.new(0.5, 0.5)
    DescImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DescImg.BackgroundTransparency = 1.000
    DescImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DescImg.BorderSizePixel = 0
    DescImg.Position = UDim2.new(0.5, 0, 0.167500004, 0)
    DescImg.Size = UDim2.new(0.890710354, 0, 0.179566562, 0)
    DescImg.ZIndex = 2
    DescImg.Image = "rbxassetid://122438584439489"

    ScrollingFrame.Parent = MainFrame
    ScrollingFrame.Active = true
    ScrollingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    ScrollingFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    ScrollingFrame.BackgroundTransparency = 1.000
    ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.Position = UDim2.new(0.50000006, 0, 0.59006983, 0)
    ScrollingFrame.Size = UDim2.new(0.888483584, 0, 0.617860258, 0)
    ScrollingFrame.ZIndex = 2
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

    UIListLayout.Parent = ScrollingFrame
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 7)
    UIListLayout.Wraps = true

    ExpandBtn.Name = "ExpandBtn"
    ExpandBtn.Parent = Container
    ExpandBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    ExpandBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ExpandBtn.BorderSizePixel = 0
    ExpandBtn.Position = UDim2.new(0.425, 0, 0.068, 0)
    ExpandBtn.Size = UDim2.new(0.09, 0, 0.12, 0)
    ExpandBtn.Image = "rbxassetid://130599991371204"
    ExpandBtn.BackgroundTransparency = 1
    ExpandBtn.ZIndex = 3

    TextButton.Parent = ScrollingFrame
    TextButton.BackgroundColor3 = Color3.fromRGB(255, 82, 85)
    TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextButton.BorderSizePixel = 0
    TextButton.LayoutOrder = 1
    TextButton.Position = UDim2.new(0, 0, 0.584536374, 0)
    TextButton.Size = UDim2.new(0.487, 0, 1, 0)
    TextButton.ZIndex = 2
    TextButton.BackgroundTransparency = 1
    TextButton.Visible = false
    TextButton.Image = "rbxassetid://111833470989816"
    TextButton.Name = "Gigantic"

    UIAspectRatioConstraint.Parent = TextButton
    UIAspectRatioConstraint.AspectRatio = 1.009

    TextButton_2.Parent = ScrollingFrame
    TextButton_2.BackgroundColor3 = Color3.fromRGB(255, 82, 85)
    TextButton_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextButton_2.BorderSizePixel = 0
    TextButton_2.LayoutOrder = 2
    TextButton_2.Position = UDim2.new(0, 0, 0.584536374, 0)
    TextButton_2.Size = UDim2.new(0.239, 0, 0.5, 0)
    TextButton_2.ZIndex = 2
    TextButton_2.BackgroundTransparency = 1
    TextButton_2.Visible = false
    TextButton_2.Image = "rbxassetid://111833470989816"
    TextButton_2.Name = "Huge"

    UIAspectRatioConstraint_2.Parent = TextButton_2
    UIAspectRatioConstraint_2.AspectRatio = 1.009

    TextButton_3.Parent = ScrollingFrame
    TextButton_3.BackgroundColor3 = Color3.fromRGB(255, 82, 85)
    TextButton_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextButton_3.BorderSizePixel = 0
    TextButton_3.LayoutOrder = 3
    TextButton_3.Position = UDim2.new(0, 0, 0.584536374, 0)
    TextButton_3.Size = UDim2.new(0.114, 0, 0.25, 0)
    TextButton_3.ZIndex = 2
    TextButton_3.BackgroundTransparency = 1
    TextButton_3.Visible = false
    TextButton_3.Image = "rbxassetid://111833470989816"
    TextButton_3.Name = "Default"

    UIAspectRatioConstraint_3.Parent = TextButton_3
    UIAspectRatioConstraint_3.AspectRatio = 1.009

    BackgroundImg.Name = "BackgroundImg"
    BackgroundImg.Parent = Container
    BackgroundImg.AnchorPoint = Vector2.new(0.5, 0.5)
    BackgroundImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BackgroundImg.BackgroundTransparency = 1.000
    BackgroundImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    BackgroundImg.BorderSizePixel = 0
    BackgroundImg.Position = UDim2.new(0.5, 0, 0.5, 0)
    BackgroundImg.Rotation = -5.000
    BackgroundImg.Size = UDim2.new(0.919598043, 0, 0.864792585, 0)
    BackgroundImg.Image = "rbxassetid://107324753983397"

    TitleImg.Name = "TitleImg"
    TitleImg.Parent = Container
    TitleImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TitleImg.BackgroundTransparency = 1.000
    TitleImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TitleImg.BorderSizePixel = 0
    TitleImg.Position = UDim2.new(0.0201005023, 0, 0.0200803205, 0)
    TitleImg.Size = UDim2.new(0.34673366, 0, 0.096817866, 0)
    TitleImg.ZIndex = 3
    TitleImg.Image = "rbxassetid://76481118221124"

    UIAspectRatioConstraint_4.Parent = TitleImg
    UIAspectRatioConstraint_4.AspectRatio = 4.770

    SearchBox.Name = "SearchBox"
    SearchBox.Parent = Container
    SearchBox.AnchorPoint = Vector2.new(0.5, 0.5)
    SearchBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.BackgroundTransparency = 1.000
    SearchBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SearchBox.BorderSizePixel = 0
    SearchBox.Position = UDim2.new(0.713586748, 0, 0.0673782751, 0)
    SearchBox.Size = UDim2.new(0.356783926, 0, 0.0789825991, 0)
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
    CloseBtn.Parent = Container
    CloseBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.BackgroundTransparency = 1.000
    CloseBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Position = UDim2.new(0.95995295, 0, 0.0673782825, 0)
    CloseBtn.Size = UDim2.new(0.107537687, 0, 0.143239632, 0)
    CloseBtn.ZIndex = 3
    CloseBtn.Image = "rbxassetid://82177231415737"

    MergeBtn.Name = "MergeBtn"
    MergeBtn.Parent = Container
    MergeBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    MergeBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MergeBtn.BackgroundTransparency = 1.000
    MergeBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MergeBtn.BorderSizePixel = 0
    MergeBtn.Position = UDim2.new(0.499497443, 0, 0.935743034, 0)
    MergeBtn.Size = UDim2.new(0.460301518, 0, 0.127175361, 0)
    MergeBtn.ZIndex = 3
    MergeBtn.Image = "rbxassetid://102357654478579"

    UIAspectRatioConstraint_5.Parent = Container
    UIAspectRatioConstraint_5.AspectRatio = 1.332
end


table.freeze(ComponentsMap)
return ComponentsMap