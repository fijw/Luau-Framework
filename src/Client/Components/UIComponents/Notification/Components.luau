--!strict
--!native
--!optimize 2


--[[ @section Variables ]]
local Notification = Instance.new("ScreenGui")
local Container = Instance.new("Frame")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
local TitleImg = Instance.new("ImageLabel")
local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
local MainFrame = Instance.new("ImageLabel")
local NotificationText = Instance.new("TextLabel")
local OkayBtn = Instance.new("ImageButton")
local BackgroundImg = Instance.new("ImageLabel")

local ComponentsMap = { Notification = Notification }
--[[ @end_section Variables ]]


-- Set all component properties.
do
    Notification.Name = "Notification"
    Notification.Enabled = false
    Notification.DisplayOrder = 999
    Notification.ResetOnSpawn = false

    Container.Name = "Container"
    Container.Parent = Notification
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Container.BackgroundTransparency = 1.000
    Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Container.BorderSizePixel = 0
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container.Size = UDim2.new(0.315789461, 0, 0.4148148, 0)

    UIAspectRatioConstraint.Parent = Container
    UIAspectRatioConstraint.AspectRatio = 1.353

    TitleImg.Name = "TitleImg"
    TitleImg.Parent = Container
    TitleImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TitleImg.BackgroundTransparency = 1.000
    TitleImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TitleImg.BorderSizePixel = 0
    TitleImg.Position = UDim2.new(-0.00165016507, 0, 0.0066964291, 0)
    TitleImg.Size = UDim2.new(0.607260704, 0, 0.137999997, 0)
    TitleImg.ZIndex = 3
    TitleImg.Image = "rbxassetid://122913755420633"

    UIAspectRatioConstraint_2.Parent = TitleImg
    UIAspectRatioConstraint_2.AspectRatio = 5.952

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

    OkayBtn.Name = "OkayBtn"
    OkayBtn.Parent = MainFrame
    OkayBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    OkayBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    OkayBtn.BackgroundTransparency = 1.000
    OkayBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    OkayBtn.BorderSizePixel = 0
    OkayBtn.Position = UDim2.new(0.499353081, 0, 0.746684909, 0)
    OkayBtn.Size = UDim2.new(0.337979108, 0, 0.246753246, 0)
    OkayBtn.ZIndex = 2
    OkayBtn.Image = "rbxassetid://99381918443866"

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