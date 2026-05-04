--!strict
--!native
--!optimize 2


--[[ @section Variables ]]
local AreYouSure = Instance.new("ScreenGui")
local Container = Instance.new("Frame")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
local TitleImg = Instance.new("ImageLabel")
local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
local MainFrame = Instance.new("ImageLabel")
local NotificationText = Instance.new("TextLabel")
local ButtonsContainer = Instance.new("Frame")
local ContinueBtn = Instance.new("ImageButton")
local CancelBtn = Instance.new("ImageButton")
local BackgroundImg = Instance.new("ImageLabel")

local ComponentsMap = { AreYouSure = AreYouSure }
--[[ @end_section Variables ]]


-- Set all component properties.
do
    AreYouSure.Name = "AreYouSure"
    AreYouSure.Enabled = true
    AreYouSure.DisplayOrder = 999

    Container.Name = "Container"
    Container.Parent = AreYouSure
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Container.BackgroundTransparency = 1.000
    Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Container.BorderSizePixel = 0
    Container.Position = UDim2.new(0.5, 0, 0.45, 0)
    Container.Size = UDim2.new(0.315789461, 0, 0.4148148, 0)
    Container.Visible = false

    UIAspectRatioConstraint.Parent = Container
    UIAspectRatioConstraint.AspectRatio = 1.353

    TitleImg.Name = "TitleImg"
    TitleImg.Parent = Container
    TitleImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TitleImg.BackgroundTransparency = 1.000
    TitleImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TitleImg.BorderSizePixel = 0
    TitleImg.Position = UDim2.new(-0.0115511548, 0, -0.0133928582, 0)
    TitleImg.Size = UDim2.new(0.706270635, 0, 0.165769741, 0)
    TitleImg.ZIndex = 3
    TitleImg.Image = "rbxassetid://98591386074880"

    UIAspectRatioConstraint_2.Parent = TitleImg
    UIAspectRatioConstraint_2.AspectRatio = 5.763

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

    NotificationText.Name = "NotificationText"
    NotificationText.Parent = MainFrame
    NotificationText.AnchorPoint = Vector2.new(0.5, 0.5)
    NotificationText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    NotificationText.BackgroundTransparency = 1.000
    NotificationText.BorderColor3 = Color3.fromRGB(0, 0, 0)
    NotificationText.BorderSizePixel = 0
    NotificationText.Position = UDim2.new(0.5, 0, 0.344155848, 0)
    NotificationText.Size = UDim2.new(0.810104549, 0, 0.428571433, 0)
    NotificationText.ZIndex = 2
    NotificationText.Font = Enum.Font.FredokaOne
    NotificationText.TextColor3 = Color3.fromRGB(0, 0, 0)
    NotificationText.TextScaled = true
    NotificationText.TextSize = 14.000
    NotificationText.TextWrapped = true
    NotificationText.RichText = true

    ButtonsContainer.Name = "ButtonsContainer"
    ButtonsContainer.Parent = MainFrame
    ButtonsContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ButtonsContainer.BackgroundTransparency = 1.000
    ButtonsContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ButtonsContainer.BorderSizePixel = 0
    ButtonsContainer.Position = UDim2.new(0.062717773, 0, 0.620779216, 0)
    ButtonsContainer.Size = UDim2.new(0.872822285, 0, 0.246753246, 0)
    ButtonsContainer.ZIndex = 2

    ContinueBtn.Name = "ContinueBtn"
    ContinueBtn.Parent = ButtonsContainer
    ContinueBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    ContinueBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ContinueBtn.BackgroundTransparency = 1.000
    ContinueBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ContinueBtn.BorderSizePixel = 0
    ContinueBtn.Position = UDim2.new(0.261828154, 0, 0.494053245, 0)
    ContinueBtn.Size = UDim2.new(0.524950087, 0, 1, 0)
    ContinueBtn.ZIndex = 2
    ContinueBtn.Image = "rbxassetid://70961698069129"

    CancelBtn.Name = "CancelBtn"
    CancelBtn.Parent = ButtonsContainer
    CancelBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    CancelBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CancelBtn.BackgroundTransparency = 1.000
    CancelBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CancelBtn.BorderSizePixel = 0
    CancelBtn.Position = UDim2.new(0.776798189, 0, 0.494053245, 0)
    CancelBtn.Size = UDim2.new(0.445109785, 0, 1, 0)
    CancelBtn.ZIndex = 2
    CancelBtn.Image = "rbxassetid://95616282277701"

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