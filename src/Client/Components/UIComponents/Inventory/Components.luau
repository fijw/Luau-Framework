--!strict
--!native
--!optimize 2


--[[ @section Variables ]]
local Inventory = Instance.new("ScreenGui")
local ContainerFrame = Instance.new("Frame")
local SearchBox = Instance.new("Frame")
local FrameImage = Instance.new("ImageLabel")
local FrameBox = Instance.new("ImageLabel")
local TextBox = Instance.new("TextBox")
local CloseBtn = Instance.new("ImageButton")
local ButtonsFrame = Instance.new("ImageLabel")
local LockBtn = Instance.new("ImageButton")
local DeleteBtn = Instance.new("ImageButton")
local ExpandBtn = Instance.new("ImageButton")
local MainFrame = Instance.new("ImageLabel")
local ScrollingFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local TextButton = Instance.new("ImageLabel")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
local TextButton_2 = Instance.new("ImageLabel")
local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
local TextButton_3 = Instance.new("ImageLabel")
local UIAspectRatioConstraint_3 = Instance.new("UIAspectRatioConstraint")
local InventoryStatusContainer = Instance.new("Frame")
local EquippedText = Instance.new("TextLabel")
local SlotsText = Instance.new("TextLabel")
local Title = Instance.new("ImageLabel")
local BackgroundImg = Instance.new("ImageLabel")
local UIAspectRatioConstraint_4 = Instance.new("UIAspectRatioConstraint")

local ComponentsMap = { Inventory = Inventory }
--[[ @end_section Variables ]]


-- Set all component properties.
do
    Inventory.Name = "Inventory"
    Inventory.Enabled = false
    Inventory.ResetOnSpawn = false

    ContainerFrame.Name = "ContainerFrame"
    ContainerFrame.Parent = Inventory
    ContainerFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    ContainerFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ContainerFrame.BackgroundTransparency = 1.000
    ContainerFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ContainerFrame.BorderSizePixel = 0
    ContainerFrame.Position = UDim2.new(0.5, 0, 0.45, 0)
    ContainerFrame.Size = UDim2.new(0.596664906, 0, 0.589814842, 0)

    SearchBox.Name = "SearchBox"
    SearchBox.Parent = ContainerFrame
    SearchBox.AnchorPoint = Vector2.new(0.5, 0.5)
    SearchBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.BackgroundTransparency = 1.000
    SearchBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SearchBox.BorderSizePixel = 0
    SearchBox.Position = UDim2.new(0.739322424, 0, 0.0778082758, 0)
    SearchBox.Size = UDim2.new(0.310499996, 0, 0.0920000002, 0)
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
    CloseBtn.Position = UDim2.new(0.955537915, 0, 0.0778082758, 0)
    CloseBtn.Size = UDim2.new(0.0934497789, 0, 0.167974889, 0)
    CloseBtn.ZIndex = 3
    CloseBtn.Image = "rbxassetid://82177231415737"

    ButtonsFrame.Name = "ButtonsFrame"
    ButtonsFrame.Parent = ContainerFrame
    ButtonsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    ButtonsFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ButtonsFrame.BackgroundTransparency = 1.000
    ButtonsFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ButtonsFrame.BorderSizePixel = 0
    ButtonsFrame.Position = UDim2.new(0.0601567514, 0, 0.462416083, 0)
    ButtonsFrame.Size = UDim2.new(0.120524019, 0, 0.541601241, 0)
    ButtonsFrame.ZIndex = 3
    ButtonsFrame.Image = "rbxassetid://79131636683995"

    LockBtn.Name = "LockBtn"
    LockBtn.Parent = ButtonsFrame
    LockBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    LockBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LockBtn.BackgroundTransparency = 1.000
    LockBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    LockBtn.BorderSizePixel = 0
    LockBtn.Position = UDim2.new(0.5, 0, 0.200000003, 0)
    LockBtn.Size = UDim2.new(0.642857194, 0, 0.257142872, 0)
    LockBtn.Image = "rbxassetid://140011010850814"
    LockBtn.ZIndex = 3

    DeleteBtn.Name = "DeleteBtn"
    DeleteBtn.Parent = ButtonsFrame
    DeleteBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    DeleteBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DeleteBtn.BackgroundTransparency = 1.000
    DeleteBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DeleteBtn.BorderSizePixel = 0
    DeleteBtn.Position = UDim2.new(0.5, 0, 0.797101378, 0)
    DeleteBtn.Size = UDim2.new(0.642857194, 0, 0.257142872, 0)
    DeleteBtn.Image = "rbxassetid://98776091371051"
    DeleteBtn.ZIndex = 3

    ExpandBtn.Name = "ExpandBtn"
    ExpandBtn.Parent = ButtonsFrame
    ExpandBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    ExpandBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ExpandBtn.BackgroundTransparency = 1.000
    ExpandBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ExpandBtn.BorderSizePixel = 0
    ExpandBtn.Position = UDim2.new(0.5, 0, 0.498550713, 0)
    ExpandBtn.Size = UDim2.new(0.642857194, 0, 0.257142872, 0)
    ExpandBtn.Image = "rbxassetid://87459423933578"
    ExpandBtn.ZIndex = 3

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ContainerFrame
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainFrame.BackgroundTransparency = 1.000
    MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.554488301, 0, 0.502626181, 0)
    MainFrame.Size = UDim2.new(0.799126625, 0, 0.854003131, 0)
    MainFrame.ZIndex = 2
    MainFrame.Image = "rbxassetid://73756019950269"

    ScrollingFrame.Parent = MainFrame
    ScrollingFrame.Active = true
    ScrollingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    ScrollingFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    ScrollingFrame.BackgroundTransparency = 1.000
    ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.Position = UDim2.new(0.5, 0, 0.540000021, 0)
    ScrollingFrame.Size = UDim2.new(0.890710354, 0, 0.735294104, 0)
    ScrollingFrame.ZIndex = 2
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollingFrame.ScrollBarThickness = 0

    UIListLayout.Parent = ScrollingFrame
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 7)
    UIListLayout.Wraps = true

    TextButton.Parent = ScrollingFrame
    TextButton.Name = "Gigantic"
    TextButton.BackgroundColor3 = Color3.fromRGB(255, 82, 85)
    TextButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextButton.BorderSizePixel = 0
    TextButton.LayoutOrder = 1
    TextButton.Position = UDim2.new(0, 0, 0.584536374, 0)
    TextButton.Size = UDim2.new(0.495000005, 0, 1, 0)
    TextButton.ZIndex = 2
    TextButton.BackgroundTransparency = 1
    TextButton.Visible = false
    TextButton.Image = "rbxassetid://111833470989816"

    UIAspectRatioConstraint.Parent = TextButton
    UIAspectRatioConstraint.AspectRatio = 1.009

    TextButton_2.Parent = ScrollingFrame
    TextButton_2.Name = "Huge"
    TextButton_2.BackgroundColor3 = Color3.fromRGB(255, 82, 85)
    TextButton_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextButton_2.BorderSizePixel = 0
    TextButton_2.LayoutOrder = 2
    TextButton_2.Position = UDim2.new(0, 0, 0.584536374, 0)
    TextButton_2.Size = UDim2.new(0.243000001, 0, 0.5, 0)
    TextButton_2.ZIndex = 2
    TextButton_2.BackgroundTransparency = 1
    TextButton_2.Visible = false
    TextButton_2.Image = "rbxassetid://111833470989816"

    UIAspectRatioConstraint_2.Parent = TextButton_2
    UIAspectRatioConstraint_2.AspectRatio = 1.009

    TextButton_3.Parent = ScrollingFrame
    TextButton_3.Name = "Default"
    TextButton_3.BackgroundColor3 = Color3.fromRGB(255, 82, 85)
    TextButton_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextButton_3.BorderSizePixel = 0
    TextButton_3.LayoutOrder = 3
    TextButton_3.Position = UDim2.new(0, 0, 0.584536374, 0)
    TextButton_3.Size = UDim2.new(0.116999999, 0, 0.25, 0)
    TextButton_3.ZIndex = 2
    TextButton_3.BackgroundTransparency = 1
    TextButton_3.Visible = false
    TextButton_3.Image = "rbxassetid://111833470989816"

    UIAspectRatioConstraint_3.Parent = TextButton_3
    UIAspectRatioConstraint_3.AspectRatio = 1.009

    InventoryStatusContainer.Name = "InventoryStatusContainer"
    InventoryStatusContainer.Parent = MainFrame
    InventoryStatusContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    InventoryStatusContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    InventoryStatusContainer.BackgroundTransparency = 1.000
    InventoryStatusContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    InventoryStatusContainer.BorderSizePixel = 0
    InventoryStatusContainer.Position = UDim2.new(0.5, 0, 0.119000003, 0)
    InventoryStatusContainer.Size = UDim2.new(0.890710354, 0, 0.0533088222, 0)
    InventoryStatusContainer.ZIndex = 2

    EquippedText.Name = "EquippedText"
    EquippedText.Parent = InventoryStatusContainer
    EquippedText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    EquippedText.BackgroundTransparency = 1.000
    EquippedText.BorderColor3 = Color3.fromRGB(0, 0, 0)
    EquippedText.BorderSizePixel = 0
    EquippedText.Size = UDim2.new(0.5, 0, 1, 0)
    EquippedText.ZIndex = 2
    EquippedText.Font = Enum.Font.FredokaOne
    EquippedText.Text = "10/20 Pets Equipped"
    EquippedText.TextColor3 = Color3.fromRGB(0, 0, 0)
    EquippedText.TextScaled = true
    EquippedText.TextSize = 14.000
    EquippedText.TextWrapped = true
    EquippedText.TextXAlignment = Enum.TextXAlignment.Left

    SlotsText.Name = "SlotsText"
    SlotsText.Parent = InventoryStatusContainer
    SlotsText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SlotsText.BackgroundTransparency = 1.000
    SlotsText.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SlotsText.BorderSizePixel = 0
    SlotsText.Position = UDim2.new(0.5, 0, 0, 0)
    SlotsText.Size = UDim2.new(0.5, 0, 1, 0)
    SlotsText.ZIndex = 2
    SlotsText.Font = Enum.Font.FredokaOne
    SlotsText.Text = "30/250 Pets"
    SlotsText.TextColor3 = Color3.fromRGB(0, 0, 0)
    SlotsText.TextScaled = true
    SlotsText.TextSize = 14.000
    SlotsText.TextWrapped = true
    SlotsText.TextXAlignment = Enum.TextXAlignment.Right

    Title.Name = "Title"
    Title.Parent = ContainerFrame
    Title.AnchorPoint = Vector2.new(0.5, 0.5)
    Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1.000
    Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Title.BorderSizePixel = 0
    Title.Position = UDim2.new(0.278120577, 0, 0.0778082758, 0)
    Title.Size = UDim2.new(0.271615714, 0, 0.117739402, 0)
    Title.ZIndex = 3
    Title.Image = "rbxassetid://91791007192441"

    BackgroundImg.Name = "BackgroundImg"
    BackgroundImg.Parent = ContainerFrame
    BackgroundImg.AnchorPoint = Vector2.new(0.5, 0.5)
    BackgroundImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BackgroundImg.BackgroundTransparency = 1.000
    BackgroundImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    BackgroundImg.BorderSizePixel = 0
    BackgroundImg.Position = UDim2.new(0.554488301, 0, 0.502626181, 0)
    BackgroundImg.Rotation = -5.000
    BackgroundImg.Size = UDim2.new(0.799126625, 0, 0.854003131, 0)
    BackgroundImg.ZIndex = 0
    BackgroundImg.Image = "rbxassetid://114571910923938"

    UIAspectRatioConstraint_4.Parent = ContainerFrame
    UIAspectRatioConstraint_4.AspectRatio = 1.797
end


table.freeze(ComponentsMap)
return ComponentsMap