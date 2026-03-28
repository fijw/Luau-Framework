--!strict
--!native
--!optimize 2


--[[ @section Variables ]]
local CommandsBar = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
local ScrollingFrame = Instance.new("ScrollingFrame")
local InputFrame = Instance.new("Frame")
local InputBox = Instance.new("TextBox")
local UIListLayout = Instance.new("UIListLayout")
local PermissionsTitle = Instance.new("TextLabel")
local UIPadding = Instance.new("UIPadding")
local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
local ResponseTemplate = Instance.new("Frame")
local UIPadding_2 = Instance.new("UIPadding")
local UIListLayout_2 = Instance.new("UIListLayout")
local TextLabel = Instance.new("TextLabel")
local UIAspectRatioConstraint_3 = Instance.new("UIAspectRatioConstraint")
local UIListLayout_3 = Instance.new("UIListLayout")

local ComponentsMap = { CommandsBar = CommandsBar }
--[[ @end_section Variables ]]


-- Set all component properties
do
    CommandsBar.Name = "CommandsBar"
    CommandsBar.ResetOnSpawn = false
    CommandsBar.DisplayOrder = 1000

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = CommandsBar
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainFrame.BackgroundTransparency = 1.000
    MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0.442939043, 0, 0.509259284, 0)
    MainFrame.Active = false

    UIAspectRatioConstraint.Parent = MainFrame
    UIAspectRatioConstraint.AspectRatio = 1.545

    ScrollingFrame.Parent = MainFrame
    ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ScrollingFrame.BackgroundTransparency = 1.000
    ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollingFrame.ScrollBarThickness = 6
    ScrollingFrame.Active = false

    InputFrame.Name = "InputFrame"
    InputFrame.Parent = ScrollingFrame
    InputFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    InputFrame.BackgroundTransparency = 0.250
    InputFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    InputFrame.BorderSizePixel = 0
    InputFrame.LayoutOrder = 1
    InputFrame.Size = UDim2.new(1, 0, 0.0769999996, 0)

    InputBox.Name = "InputBox"
    InputBox.Parent = InputFrame
    InputBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.BackgroundTransparency = 1.000
    InputBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    InputBox.BorderSizePixel = 0
    InputBox.LayoutOrder = 1
    InputBox.Position = UDim2.new(0.195618585, 0, 0.171898648, 0)
    InputBox.Size = UDim2.new(0.80438143, 0, 0.563402951, 0)
    InputBox.Font = Enum.Font.SourceSansBold
    InputBox.PlaceholderColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.Text = ""
    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.TextScaled = true
    InputBox.TextSize = 14.000
    InputBox.TextWrapped = true
    InputBox.TextXAlignment = Enum.TextXAlignment.Left
    InputBox.ClearTextOnFocus = false

    UIListLayout.Parent = InputFrame
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    UIListLayout.Padding = UDim.new(0.00499999989, 0)

    PermissionsTitle.Name = "PermissionsTitle"
    PermissionsTitle.Parent = InputFrame
    PermissionsTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PermissionsTitle.BackgroundTransparency = 1.000
    PermissionsTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
    PermissionsTitle.BorderSizePixel = 0
    PermissionsTitle.Size = UDim2.new(0.190618545, 0, 1, 0)
    PermissionsTitle.Font = Enum.Font.SourceSansBold
    PermissionsTitle.Text = "permissions@cmcs"
    PermissionsTitle.TextColor3 = Color3.fromRGB(255, 170, 0)
    PermissionsTitle.TextScaled = true
    PermissionsTitle.TextSize = 14.000
    PermissionsTitle.TextWrapped = true

    UIPadding.Parent = InputFrame
    UIPadding.PaddingLeft = UDim.new(0.0250000004, 0)
    UIPadding.PaddingRight = UDim.new(0.0250000004, 0)

    UIAspectRatioConstraint_2.Parent = InputFrame
    UIAspectRatioConstraint_2.AspectRatio = 20.071

    ResponseTemplate.Name = "ResponseTemplate"
    ResponseTemplate.Parent = ScrollingFrame
    ResponseTemplate.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ResponseTemplate.BackgroundTransparency = 0.250
    ResponseTemplate.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ResponseTemplate.BorderSizePixel = 0
    ResponseTemplate.Size = UDim2.new(1, 0, 0.0769999996, 0)

    UIPadding_2.Parent = ResponseTemplate
    UIPadding_2.PaddingLeft = UDim.new(0.0250000004, 0)
    UIPadding_2.PaddingRight = UDim.new(0.0250000004, 0)

    UIListLayout_2.Parent = ResponseTemplate
    UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

    TextLabel.Parent = ResponseTemplate
    TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.BackgroundTransparency = 1.000
    TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BorderSizePixel = 0
    TextLabel.Size = UDim2.new(1, 0, 0.734660685, 0)
    TextLabel.Font = Enum.Font.SourceSansBold
    TextLabel.Text = "> Kicked [User Id] for [Reason]."
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextScaled = true
    TextLabel.TextSize = 14.000
    TextLabel.TextWrapped = true
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left

    UIAspectRatioConstraint_3.Parent = ResponseTemplate
    UIAspectRatioConstraint_3.AspectRatio = 20.071

    UIListLayout_3.Parent = ScrollingFrame
    UIListLayout_3.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_3.VerticalAlignment = Enum.VerticalAlignment.Center
end


table.freeze(ComponentsMap)
return ComponentsMap