--!strict
--!native
--!optimize 2


--[[ @section Variables ]]
local PetDetails = Instance.new("ScreenGui")
local MainFrame = Instance.new("ImageLabel")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
local InnerContainer = Instance.new("Frame")
local PetName = Instance.new("TextLabel")
local UIListLayout = Instance.new("UIListLayout")
local StatsContainer = Instance.new("Frame")
local HealthContainer = Instance.new("Frame")
local ImageLabel = Instance.new("ImageLabel")
local TextLabel = Instance.new("TextLabel")
local UIListLayout_2 = Instance.new("UIListLayout")
local DmgContainer = Instance.new("Frame")
local ImageLabel_2 = Instance.new("ImageLabel")
local TextLabel_2 = Instance.new("TextLabel")
local ImageLabel_3 = Instance.new("ImageLabel")
local DetailsContainer = Instance.new("Frame")
local UIListLayout_3 = Instance.new("UIListLayout")
local Rarity = Instance.new("ImageLabel")
local TextLabel_3 = Instance.new("TextLabel")
local Size = Instance.new("ImageLabel")
local TextLabel_4 = Instance.new("TextLabel")
local Color = Instance.new("ImageLabel")
local TextLabel_5 = Instance.new("TextLabel")
local ImageLabel_4 = Instance.new("ImageLabel")
local TradeableContainer = Instance.new("Frame")
local ImageLabel_5 = Instance.new("ImageLabel")
local TextLabel_6 = Instance.new("TextLabel")

local ComponentsMap = { PetDetails = PetDetails }
--[[ @end_section Variables ]]


-- Set all component properties.
do
    PetDetails.Name = "PetDetails"
    PetDetails.Enabled = true
    PetDetails.DisplayOrder = 99
    PetDetails.ResetOnSpawn = false

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = PetDetails
    MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainFrame.BackgroundTransparency = 1.000
    MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.528400183, 0, 0.541666687, 0)
    MainFrame.Size = UDim2.new(0.139134973, 0, 0.389814824, 0)
    MainFrame.Image = "rbxassetid://76165303610256"
    MainFrame.Visible = false

    UIAspectRatioConstraint.Parent = MainFrame
    UIAspectRatioConstraint.AspectRatio = 0.634

    InnerContainer.Name = "InnerContainer"
    InnerContainer.Parent = MainFrame
    InnerContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    InnerContainer.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    InnerContainer.BackgroundTransparency = 1.000
    InnerContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    InnerContainer.BorderSizePixel = 0
    InnerContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    InnerContainer.Size = UDim2.new(0.812734067, 0, 0.881235182, 0)

    PetName.Name = "PetName"
    PetName.Parent = InnerContainer
    PetName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PetName.BackgroundTransparency = 1.000
    PetName.BorderColor3 = Color3.fromRGB(0, 0, 0)
    PetName.BorderSizePixel = 0
    PetName.Size = UDim2.new(1, 0, 0.105121292, 0)
    PetName.Font = Enum.Font.FredokaOne
    PetName.Text = "Cat"
    PetName.TextColor3 = Color3.fromRGB(0, 0, 0)
    PetName.TextScaled = true
    PetName.TextSize = 14.000
    PetName.TextWrapped = true

    UIListLayout.Parent = InnerContainer
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0.0410000011, 0)

    StatsContainer.Name = "StatsContainer"
    StatsContainer.Parent = InnerContainer
    StatsContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    StatsContainer.BackgroundTransparency = 1.000
    StatsContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    StatsContainer.BorderSizePixel = 0
    StatsContainer.LayoutOrder = 1
    StatsContainer.Size = UDim2.new(1, 0, 0.202156335, 0)

    HealthContainer.Name = "HealthContainer"
    HealthContainer.Parent = StatsContainer
    HealthContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    HealthContainer.BackgroundTransparency = 1.000
    HealthContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    HealthContainer.BorderSizePixel = 0
    HealthContainer.Size = UDim2.new(1, 0, 0.466666669, 0)

    ImageLabel.Parent = HealthContainer
    ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel.BackgroundTransparency = 1.000
    ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel.BorderSizePixel = 0
    ImageLabel.Size = UDim2.new(0.161290318, 0, 1, 0)
    ImageLabel.Image = "rbxassetid://117697265894866"

    TextLabel.Parent = HealthContainer
    TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.BackgroundTransparency = 1.000
    TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BorderSizePixel = 0
    TextLabel.Position = UDim2.new(0.230414748, 0, 0.0857142881, 0)
    TextLabel.Size = UDim2.new(0.769585252, 0, 0.828571439, 0)
    TextLabel.Font = Enum.Font.FredokaOne
    TextLabel.Text = "100/100"
    TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.TextScaled = true
    TextLabel.TextSize = 14.000
    TextLabel.TextWrapped = true
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left

    UIListLayout_2.Parent = StatsContainer
    UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_2.Padding = UDim.new(0.0599999987, 0)

    DmgContainer.Name = "DmgContainer"
    DmgContainer.Parent = StatsContainer
    DmgContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DmgContainer.BackgroundTransparency = 1.000
    DmgContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DmgContainer.BorderSizePixel = 0
    DmgContainer.Size = UDim2.new(1, 0, 0.466666669, 0)

    ImageLabel_2.Parent = DmgContainer
    ImageLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel_2.BackgroundTransparency = 1.000
    ImageLabel_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel_2.BorderSizePixel = 0
    ImageLabel_2.Size = UDim2.new(0.161290318, 0, 1, 0)
    ImageLabel_2.Image = "rbxassetid://74910420697037"

    TextLabel_2.Parent = DmgContainer
    TextLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel_2.BackgroundTransparency = 1.000
    TextLabel_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel_2.BorderSizePixel = 0
    TextLabel_2.Position = UDim2.new(0.230414748, 0, 0.0857142881, 0)
    TextLabel_2.Size = UDim2.new(0.769585252, 0, 0.828571439, 0)
    TextLabel_2.Font = Enum.Font.FredokaOne
    TextLabel_2.Text = "150"
    TextLabel_2.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel_2.TextScaled = true
    TextLabel_2.TextSize = 14.000
    TextLabel_2.TextWrapped = true
    TextLabel_2.TextXAlignment = Enum.TextXAlignment.Left

    ImageLabel_3.Parent = InnerContainer
    ImageLabel_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel_3.BackgroundTransparency = 1.000
    ImageLabel_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel_3.BorderSizePixel = 0
    ImageLabel_3.LayoutOrder = 2
    ImageLabel_3.Size = UDim2.new(1, 0, 0.0134770889, 0)
    ImageLabel_3.Image = "rbxassetid://107763108400322"

    DetailsContainer.Name = "DetailsContainer"
    DetailsContainer.Parent = InnerContainer
    DetailsContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DetailsContainer.BackgroundTransparency = 1.000
    DetailsContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DetailsContainer.BorderSizePixel = 0
    DetailsContainer.LayoutOrder = 3
    DetailsContainer.Size = UDim2.new(1, 0, 0.369272232, 0)

    UIListLayout_3.Parent = DetailsContainer
    UIListLayout_3.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_3.Padding = UDim.new(0.0700000003, 0)

    Rarity.Name = "Rarity"
    Rarity.Parent = DetailsContainer
    Rarity.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Rarity.BackgroundTransparency = 1.000
    Rarity.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Rarity.BorderSizePixel = 0
    Rarity.Size = UDim2.new(1, 0, 0.284671545, 0)
    Rarity.Image = "rbxassetid://74350886926927"

    TextLabel_3.Parent = Rarity
    TextLabel_3.AnchorPoint = Vector2.new(0.5, 0.5)
    TextLabel_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel_3.BackgroundTransparency = 1.000
    TextLabel_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel_3.BorderSizePixel = 0
    TextLabel_3.Position = UDim2.new(0.5, 0, 0.5, 0)
    TextLabel_3.Size = UDim2.new(0.861751139, 0, 0.743589759, 0)
    TextLabel_3.Font = Enum.Font.FredokaOne
    TextLabel_3.Text = "Secret"
    TextLabel_3.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel_3.TextScaled = true
    TextLabel_3.TextSize = 14.000
    TextLabel_3.TextWrapped = true

    Size.Name = "Size"
    Size.Parent = DetailsContainer
    Size.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Size.BackgroundTransparency = 1.000
    Size.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Size.BorderSizePixel = 0
    Size.Size = UDim2.new(1, 0, 0.284671545, 0)
    Size.Image = "rbxassetid://74350886926927"

    TextLabel_4.Parent = Size
    TextLabel_4.AnchorPoint = Vector2.new(0.5, 0.5)
    TextLabel_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel_4.BackgroundTransparency = 1.000
    TextLabel_4.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel_4.BorderSizePixel = 0
    TextLabel_4.Position = UDim2.new(0.5, 0, 0.5, 0)
    TextLabel_4.Size = UDim2.new(0.861751139, 0, 0.743589759, 0)
    TextLabel_4.Font = Enum.Font.FredokaOne
    TextLabel_4.Text = "Gigantic"
    TextLabel_4.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel_4.TextScaled = true
    TextLabel_4.TextSize = 14.000
    TextLabel_4.TextWrapped = true

    Color.Name = "Color"
    Color.Parent = DetailsContainer
    Color.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Color.BackgroundTransparency = 1.000
    Color.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Color.BorderSizePixel = 0
    Color.Size = UDim2.new(1, 0, 0.284671545, 0)
    Color.Image = "rbxassetid://74350886926927"

    TextLabel_5.Parent = Color
    TextLabel_5.AnchorPoint = Vector2.new(0.5, 0.5)
    TextLabel_5.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel_5.BackgroundTransparency = 1.000
    TextLabel_5.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel_5.BorderSizePixel = 0
    TextLabel_5.Position = UDim2.new(0.5, 0, 0.5, 0)
    TextLabel_5.Size = UDim2.new(0.861751139, 0, 0.743589759, 0)
    TextLabel_5.Font = Enum.Font.FredokaOne
    TextLabel_5.Text = "Glitched"
    TextLabel_5.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel_5.TextScaled = true
    TextLabel_5.TextSize = 14.000
    TextLabel_5.TextWrapped = true

    ImageLabel_4.Parent = InnerContainer
    ImageLabel_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel_4.BackgroundTransparency = 1.000
    ImageLabel_4.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel_4.BorderSizePixel = 0
    ImageLabel_4.LayoutOrder = 4
    ImageLabel_4.Size = UDim2.new(1, 0, 0.0134770889, 0)
    ImageLabel_4.Image = "rbxassetid://107763108400322"

    TradeableContainer.Name = "TradeableContainer"
    TradeableContainer.Parent = InnerContainer
    TradeableContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TradeableContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TradeableContainer.BorderSizePixel = 0
    TradeableContainer.LayoutOrder = 5
    TradeableContainer.Size = UDim2.new(1, 0, 0.094339624, 0)

    ImageLabel_5.Parent = TradeableContainer
    ImageLabel_5.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel_5.BackgroundTransparency = 1.000
    ImageLabel_5.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel_5.BorderSizePixel = 0
    ImageLabel_5.Size = UDim2.new(0.161290318, 0, 1, 0)
    ImageLabel_5.Image = "rbxassetid://129263572391188"

    TextLabel_6.Parent = TradeableContainer
    TextLabel_6.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel_6.BackgroundTransparency = 1.000
    TextLabel_6.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel_6.BorderSizePixel = 0
    TextLabel_6.Position = UDim2.new(0.230414748, 0, 0.0857142881, 0)
    TextLabel_6.Size = UDim2.new(0.769585252, 0, 0.828571439, 0)
    TextLabel_6.Font = Enum.Font.FredokaOne
    TextLabel_6.Text = "Tradeable"
    TextLabel_6.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel_6.TextScaled = true
    TextLabel_6.TextSize = 14.000
    TextLabel_6.TextWrapped = true
    TextLabel_6.TextXAlignment = Enum.TextXAlignment.Left
end


table.freeze(ComponentsMap)
return ComponentsMap