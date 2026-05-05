--!strict
--!native
--!optimize 2


--[[ @section Variables ]]
local HealingPetsMachine = Instance.new("ScreenGui")
local Container = Instance.new("Frame")
local MainFrame = Instance.new("ImageLabel")
local InnerContainer = Instance.new("Frame")
local DescText = Instance.new("TextLabel")
local UsedSlotsText = Instance.new("TextLabel")
local ScrollingFrame = Instance.new("ScrollingFrame")
local ImageButton = Instance.new("ImageLabel")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
local UIListLayout = Instance.new("UIListLayout")
local BackgroundImg = Instance.new("ImageLabel")
local TitleImg = Instance.new("ImageLabel")
local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
local CloseBtn = Instance.new("ImageButton")
local UIAspectRatioConstraint_3 = Instance.new("UIAspectRatioConstraint")
local HealPetBtn = Instance.new("ImageButton")

local ComponentsMap = { HealingPetsMachine = HealingPetsMachine }
--[[ @end_section Variables ]]


-- Set all component properties.
do
    HealingPetsMachine.Name = "HealingPetsMachine"
    HealingPetsMachine.Enabled = false
    HealingPetsMachine.ResetOnSpawn = false

    Container.Name = "Container"
    Container.Parent = HealingPetsMachine
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Container.BackgroundTransparency = 1.000
    Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Container.BorderSizePixel = 0
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container.Size = UDim2.new(0.58259511, 0, 0.663888872, 0)

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = Container
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainFrame.BackgroundTransparency = 1.000
    MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.484271973, 0, 0.503200054, 0)
    MainFrame.Size = UDim2.new(0.925760269, 0, 0.852161765, 0)
    MainFrame.ZIndex = 2
    MainFrame.Image = "rbxassetid://140426768940753"

    InnerContainer.Name = "InnerContainer"
    InnerContainer.Parent = MainFrame
    InnerContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    InnerContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    InnerContainer.BackgroundTransparency = 1.000
    InnerContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    InnerContainer.BorderSizePixel = 0
    InnerContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    InnerContainer.Size = UDim2.new(0.903381646, 0, 0.809160292, 0)
    InnerContainer.ZIndex = 2

    DescText.Name = "DescText"
    DescText.Parent = InnerContainer
    DescText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DescText.BackgroundTransparency = 1.000
    DescText.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DescText.BorderSizePixel = 0
    DescText.Size = UDim2.new(1.01900005, 0, 0.175971955, 0)
    DescText.ZIndex = 2
    DescText.Font = Enum.Font.FredokaOne
    DescText.RichText = true
    DescText.Text = "Healing a pet takes 5 minutes. Once placed in the Healing Machine, it cannot be<br />removed. When healing is complete, it is automatically returned to your inventory.<br />"
    DescText.TextColor3 = Color3.fromRGB(0, 0, 0)
    DescText.TextScaled = true
    DescText.TextSize = 14.000
    DescText.TextWrapped = true
    DescText.TextXAlignment = Enum.TextXAlignment.Left

    UsedSlotsText.Name = "UsedSlotsText"
    UsedSlotsText.Parent = InnerContainer
    UsedSlotsText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    UsedSlotsText.BackgroundTransparency = 1.000
    UsedSlotsText.BorderColor3 = Color3.fromRGB(0, 0, 0)
    UsedSlotsText.BorderSizePixel = 0
    UsedSlotsText.Position = UDim2.new(-0.00106955133, 0, 0.163835958, 0)
    UsedSlotsText.Size = UDim2.new(1.01900005, 0, 0.0586573221, 0)
    UsedSlotsText.ZIndex = 2
    UsedSlotsText.Font = Enum.Font.FredokaOne
    UsedSlotsText.Text = "Currently using 10/10 available healing slots."
    UsedSlotsText.TextColor3 = Color3.fromRGB(0, 0, 0)
    UsedSlotsText.TextScaled = true
    UsedSlotsText.TextSize = 14.000
    UsedSlotsText.TextWrapped = true
    UsedSlotsText.TextXAlignment = Enum.TextXAlignment.Left

    ScrollingFrame.Parent = InnerContainer
    ScrollingFrame.Active = true
    ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ScrollingFrame.BackgroundTransparency = 1.000
    ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.Position = UDim2.new(-0.00100000005, 0, 0.250999987, 0)
    ScrollingFrame.Size = UDim2.new(1, 0, 0.74000001, 0)
    ScrollingFrame.ZIndex = 2
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

    ImageButton.Parent = ScrollingFrame
    ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageButton.BorderSizePixel = 0
    ImageButton.Size = UDim2.new(0.187165782, 0, 0.45555833, 0)
    ImageButton.ZIndex = 2
    ImageButton.BackgroundTransparency = 1
    ImageButton.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    ImageButton.Visible = false
    ImageButton.Image = "rbxassetid://119610995981036"

    UIAspectRatioConstraint.Parent = ImageButton
    UIAspectRatioConstraint.AspectRatio = 1.050

    UIListLayout.Parent = ScrollingFrame
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 15)

    BackgroundImg.Name = "BackgroundImg"
    BackgroundImg.Parent = Container
    BackgroundImg.AnchorPoint = Vector2.new(0.5, 0.5)
    BackgroundImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BackgroundImg.BackgroundTransparency = 1.000
    BackgroundImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    BackgroundImg.BorderSizePixel = 0
    BackgroundImg.Position = UDim2.new(0.484271973, 0, 0.503200054, 0)
    BackgroundImg.Rotation = -5.000
    BackgroundImg.Size = UDim2.new(0.925999999, 0, 0.851999998, 0)
    BackgroundImg.Image = "rbxassetid://79472568573253"

    TitleImg.Name = "TitleImg"
    TitleImg.Parent = Container
    TitleImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TitleImg.BackgroundTransparency = 1.000
    TitleImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TitleImg.BorderSizePixel = 0
    TitleImg.Position = UDim2.new(0.00166973192, 0, 0.029373467, 0)
    TitleImg.Size = UDim2.new(0.442754924, 0, 0.105683893, 0)
    TitleImg.ZIndex = 3
    TitleImg.Image = "rbxassetid://103527871812246"

    UIAspectRatioConstraint_2.Parent = TitleImg
    UIAspectRatioConstraint_2.AspectRatio = 6.532

    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = Container
    CloseBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.BackgroundTransparency = 1.000
    CloseBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Position = UDim2.new(0.949794173, 0, 0.0826026052, 0)
    CloseBtn.Size = UDim2.new(0.0957066193, 0, 0.149232909, 0)
    CloseBtn.ZIndex = 3
    CloseBtn.Image = "rbxassetid://82177231415737"

    UIAspectRatioConstraint_3.Parent = Container
    UIAspectRatioConstraint_3.AspectRatio = 1.559

    HealPetBtn.Name = "HealPetBtn"
    HealPetBtn.Parent = Container
    HealPetBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    HealPetBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    HealPetBtn.BackgroundTransparency = 1.000
    HealPetBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    HealPetBtn.BorderSizePixel = 0
    HealPetBtn.Position = UDim2.new(0.5, 0, 0.92887032, 0)
    HealPetBtn.Size = UDim2.new(0.252236128, 0, 0.132496506, 0)
    HealPetBtn.ZIndex = 3
    HealPetBtn.Image = "rbxassetid://133617861766406"
end


table.freeze(ComponentsMap)
return ComponentsMap