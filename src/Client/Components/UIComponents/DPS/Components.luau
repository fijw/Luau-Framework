--!strict
--!native
--!optimize 2


--[[ @section Variables ]]
local DevPetSpawning = Instance.new("ScreenGui")
local Container = Instance.new("Frame")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
local MainFrame = Instance.new("ImageLabel")
local DescImg = Instance.new("ImageLabel")
local TargetBox = Instance.new("Frame")
local FrameImage = Instance.new("ImageLabel")
local FrameBox = Instance.new("ImageLabel")
local TextBox = Instance.new("TextBox")
local PetNameBox = Instance.new("Frame")
local FrameImage_2 = Instance.new("ImageLabel")
local FrameBox_2 = Instance.new("ImageLabel")
local TextBox_2 = Instance.new("TextBox")
local PetColorBoxContainer = Instance.new("Frame")
local PetColorBox = Instance.new("Frame")
local FrameImage_3 = Instance.new("ImageLabel")
local FrameBox_3 = Instance.new("ImageLabel")
local TextBox_3 = Instance.new("TextBox")
local ImageLabel = Instance.new("ImageLabel")
local PetSizeBoxContainer = Instance.new("Frame")
local ImageLabel_2 = Instance.new("ImageLabel")
local PetSizeBox = Instance.new("Frame")
local FrameImage_4 = Instance.new("ImageLabel")
local FrameBox_4 = Instance.new("ImageLabel")
local TextBox_4 = Instance.new("TextBox")
local BackgroundImg = Instance.new("ImageLabel")
local TitleImg = Instance.new("ImageLabel")
local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
local GivePetButton = Instance.new("ImageButton")
local CloseBtn = Instance.new("ImageButton")

local Components = { DevPetSpawning = DevPetSpawning }
--[[ @end_section Variables ]]


-- Set all component properties.
do
    DevPetSpawning.Name = "DevPetSpawning"
    DevPetSpawning.Enabled = false
    DevPetSpawning.ResetOnSpawn = false

    Container.Name = "Container"
    Container.Parent = DevPetSpawning
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Container.BackgroundTransparency = 1.000
    Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Container.BorderSizePixel = 0
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container.Size = UDim2.new(0.467952073, 0, 0.553703725, 0)

    UIAspectRatioConstraint.Parent = Container
    UIAspectRatioConstraint.AspectRatio = 1.502

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = Container
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainFrame.BackgroundTransparency = 1.000
    MainFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0.917594671, 0, 0.831103683, 0)
    MainFrame.ZIndex = 2
    MainFrame.Image = "rbxassetid://85274754387778"

    DescImg.Name = "DescImg"
    DescImg.Parent = MainFrame
    DescImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DescImg.BackgroundTransparency = 1.000
    DescImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    DescImg.BorderSizePixel = 0
    DescImg.Position = UDim2.new(0.0606796108, 0, 0.100603625, 0)
    DescImg.Size = UDim2.new(0.436893195, 0, 0.116700202, 0)
    DescImg.ZIndex = 2
    DescImg.Image = "rbxassetid://84503641791060"

    TargetBox.Name = "TargetBox"
    TargetBox.Parent = MainFrame
    TargetBox.AnchorPoint = Vector2.new(0.5, 0.5)
    TargetBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TargetBox.BackgroundTransparency = 1.000
    TargetBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TargetBox.BorderSizePixel = 0
    TargetBox.Position = UDim2.new(0.276699036, 0, 0.305835009, 0)
    TargetBox.Size = UDim2.new(0.430825233, 0, 0.118712276, 0)
    TargetBox.ZIndex = 2

    FrameImage.Name = "FrameImage"
    FrameImage.Parent = TargetBox
    FrameImage.AnchorPoint = Vector2.new(0.5, 0.5)
    FrameImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FrameImage.BackgroundTransparency = 1.000
    FrameImage.BorderColor3 = Color3.fromRGB(0, 0, 0)
    FrameImage.BorderSizePixel = 0
    FrameImage.Position = UDim2.new(0.0619718246, 0, 0.491525382, 0)
    FrameImage.Size = UDim2.new(0.123943664, 0, 0.745762706, 0)
    FrameImage.ZIndex = 2
    FrameImage.Image = "rbxassetid://131489418397199"

    FrameBox.Name = "FrameBox"
    FrameBox.Parent = TargetBox
    FrameBox.AnchorPoint = Vector2.new(0.5, 0.5)
    FrameBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FrameBox.BackgroundTransparency = 1.000
    FrameBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    FrameBox.BorderSizePixel = 0
    FrameBox.Position = UDim2.new(0.576056361, 0, 0.5, 0)
    FrameBox.Size = UDim2.new(0.845070422, 0, 1, 0)
    FrameBox.ZIndex = 2
    FrameBox.Image = "rbxassetid://96198739376505"

    TextBox.Parent = FrameBox
    TextBox.AnchorPoint = Vector2.new(0.5, 0.5)
    TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.BackgroundTransparency = 1.000
    TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextBox.BorderSizePixel = 0
    TextBox.Position = UDim2.new(0.5, 0, 0.5, 0)
    TextBox.Size = UDim2.new(0.916666687, 0, 0.576271176, 0)
    TextBox.ZIndex = 2
    TextBox.Font = Enum.Font.FredokaOne
    TextBox.PlaceholderColor3 = Color3.fromRGB(0, 0, 0)
    TextBox.PlaceholderText = "Player ID here..."
    TextBox.Text = ""
    TextBox.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextBox.TextScaled = true
    TextBox.TextSize = 14.000
    TextBox.TextWrapped = true

    PetNameBox.Name = "PetNameBox"
    PetNameBox.Parent = MainFrame
    PetNameBox.AnchorPoint = Vector2.new(0.5, 0.5)
    PetNameBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PetNameBox.BackgroundTransparency = 1.000
    PetNameBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    PetNameBox.BorderSizePixel = 0
    PetNameBox.Position = UDim2.new(0.276699036, 0, 0.454728365, 0)
    PetNameBox.Size = UDim2.new(0.430825233, 0, 0.118712276, 0)
    PetNameBox.ZIndex = 2

    FrameImage_2.Name = "FrameImage"
    FrameImage_2.Parent = PetNameBox
    FrameImage_2.AnchorPoint = Vector2.new(0.5, 0.5)
    FrameImage_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FrameImage_2.BackgroundTransparency = 1.000
    FrameImage_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    FrameImage_2.BorderSizePixel = 0
    FrameImage_2.Position = UDim2.new(0.0619718246, 0, 0.491525382, 0)
    FrameImage_2.Size = UDim2.new(0.123943664, 0, 0.745762706, 0)
    FrameImage_2.ZIndex = 2
    FrameImage_2.Image = "rbxassetid://71960047291225"

    FrameBox_2.Name = "FrameBox"
    FrameBox_2.Parent = PetNameBox
    FrameBox_2.AnchorPoint = Vector2.new(0.5, 0.5)
    FrameBox_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FrameBox_2.BackgroundTransparency = 1.000
    FrameBox_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    FrameBox_2.BorderSizePixel = 0
    FrameBox_2.Position = UDim2.new(0.576056361, 0, 0.5, 0)
    FrameBox_2.Size = UDim2.new(0.845070422, 0, 1, 0)
    FrameBox_2.ZIndex = 2
    FrameBox_2.Image = "rbxassetid://96198739376505"

    TextBox_2.Parent = FrameBox_2
    TextBox_2.AnchorPoint = Vector2.new(0.5, 0.5)
    TextBox_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextBox_2.BackgroundTransparency = 1.000
    TextBox_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextBox_2.BorderSizePixel = 0
    TextBox_2.Position = UDim2.new(0.5, 0, 0.5, 0)
    TextBox_2.Size = UDim2.new(0.916666687, 0, 0.576271176, 0)
    TextBox_2.ZIndex = 2
    TextBox_2.Font = Enum.Font.FredokaOne
    TextBox_2.PlaceholderColor3 = Color3.fromRGB(0, 0, 0)
    TextBox_2.PlaceholderText = "Pet name here..."
    TextBox_2.Text = ""
    TextBox_2.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextBox_2.TextScaled = true
    TextBox_2.TextSize = 14.000
    TextBox_2.TextWrapped = true

    PetColorBoxContainer.Name = "PetColorBoxContainer"
    PetColorBoxContainer.Parent = MainFrame
    PetColorBoxContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PetColorBoxContainer.BackgroundTransparency = 1.000
    PetColorBoxContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    PetColorBoxContainer.BorderSizePixel = 0
    PetColorBoxContainer.Position = UDim2.new(0.0606796108, 0, 0.543259561, 0)
    PetColorBoxContainer.Size = UDim2.new(0.878640771, 0, 0.175050303, 0)
    PetColorBoxContainer.ZIndex = 2

    PetColorBox.Name = "PetColorBox"
    PetColorBox.Parent = PetColorBoxContainer
    PetColorBox.AnchorPoint = Vector2.new(0.5, 0.5)
    PetColorBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PetColorBox.BackgroundTransparency = 1.000
    PetColorBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    PetColorBox.BorderSizePixel = 0
    PetColorBox.Position = UDim2.new(0.244475141, 0, 0.5, 0)
    PetColorBox.Size = UDim2.new(0.490331501, 0, 0.678160906, 0)
    PetColorBox.ZIndex = 2

    FrameImage_3.Name = "FrameImage"
    FrameImage_3.Parent = PetColorBox
    FrameImage_3.AnchorPoint = Vector2.new(0.5, 0.5)
    FrameImage_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FrameImage_3.BackgroundTransparency = 1.000
    FrameImage_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
    FrameImage_3.BorderSizePixel = 0
    FrameImage_3.Position = UDim2.new(0.0619718246, 0, 0.491525382, 0)
    FrameImage_3.Size = UDim2.new(0.123943664, 0, 0.745762706, 0)
    FrameImage_3.ZIndex = 2
    FrameImage_3.Image = "rbxassetid://112210934397486"

    FrameBox_3.Name = "FrameBox"
    FrameBox_3.Parent = PetColorBox
    FrameBox_3.AnchorPoint = Vector2.new(0.5, 0.5)
    FrameBox_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FrameBox_3.BackgroundTransparency = 1.000
    FrameBox_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
    FrameBox_3.BorderSizePixel = 0
    FrameBox_3.Position = UDim2.new(0.576056361, 0, 0.5, 0)
    FrameBox_3.Size = UDim2.new(0.845070422, 0, 1, 0)
    FrameBox_3.ZIndex = 2
    FrameBox_3.Image = "rbxassetid://96198739376505"

    TextBox_3.Parent = FrameBox_3
    TextBox_3.AnchorPoint = Vector2.new(0.5, 0.5)
    TextBox_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextBox_3.BackgroundTransparency = 1.000
    TextBox_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextBox_3.BorderSizePixel = 0
    TextBox_3.Position = UDim2.new(0.5, 0, 0.5, 0)
    TextBox_3.Size = UDim2.new(0.916666687, 0, 0.576271176, 0)
    TextBox_3.ZIndex = 2
    TextBox_3.Font = Enum.Font.FredokaOne
    TextBox_3.PlaceholderColor3 = Color3.fromRGB(0, 0, 0)
    TextBox_3.PlaceholderText = "Pet color here..."
    TextBox_3.Text = ""
    TextBox_3.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextBox_3.TextScaled = true
    TextBox_3.TextSize = 14.000
    TextBox_3.TextWrapped = true

    ImageLabel.Parent = PetColorBoxContainer
    ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel.BackgroundTransparency = 1.000
    ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel.BorderSizePixel = 0
    ImageLabel.Position = UDim2.new(0.511049747, 0, 0, 0)
    ImageLabel.Size = UDim2.new(0.488950282, 0, 1, 0)
    ImageLabel.ZIndex = 2
    ImageLabel.Image = "rbxassetid://102191604414985"

    PetSizeBoxContainer.Name = "PetSizeBoxContainer"
    PetSizeBoxContainer.Parent = MainFrame
    PetSizeBoxContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PetSizeBoxContainer.BackgroundTransparency = 1.000
    PetSizeBoxContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    PetSizeBoxContainer.BorderSizePixel = 0
    PetSizeBoxContainer.Position = UDim2.new(0.0606796108, 0, 0.74849093, 0)
    PetSizeBoxContainer.Size = UDim2.new(0.878640771, 0, 0.118712276, 0)
    PetSizeBoxContainer.ZIndex = 2

    ImageLabel_2.Parent = PetSizeBoxContainer
    ImageLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageLabel_2.BackgroundTransparency = 1.000
    ImageLabel_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageLabel_2.BorderSizePixel = 0
    ImageLabel_2.Position = UDim2.new(0.511049747, 0, 0, 0)
    ImageLabel_2.Size = UDim2.new(0.488950282, 0, 0.983050823, 0)
    ImageLabel_2.ZIndex = 2
    ImageLabel_2.Image = "rbxassetid://114506942823886"

    PetSizeBox.Name = "PetSizeBox"
    PetSizeBox.Parent = PetSizeBoxContainer
    PetSizeBox.AnchorPoint = Vector2.new(0.5, 0.5)
    PetSizeBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PetSizeBox.BackgroundTransparency = 1.000
    PetSizeBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    PetSizeBox.BorderSizePixel = 0
    PetSizeBox.Position = UDim2.new(0.244475141, 0, 0.5, 0)
    PetSizeBox.Size = UDim2.new(0.490331501, 0, 0.678160906, 0)
    PetSizeBox.ZIndex = 2

    FrameImage_4.Name = "FrameImage"
    FrameImage_4.Parent = PetSizeBox
    FrameImage_4.AnchorPoint = Vector2.new(0.5, 0.5)
    FrameImage_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FrameImage_4.BackgroundTransparency = 1.000
    FrameImage_4.BorderColor3 = Color3.fromRGB(0, 0, 0)
    FrameImage_4.BorderSizePixel = 0
    FrameImage_4.Position = UDim2.new(0.0619718246, 0, 0.491525382, 0)
    FrameImage_4.Size = UDim2.new(0.123943664, 0, 1.099684, 0)
    FrameImage_4.ZIndex = 2
    FrameImage_4.Image = "rbxassetid://124927556251942"

    FrameBox_4.Name = "FrameBox"
    FrameBox_4.Parent = PetSizeBox
    FrameBox_4.AnchorPoint = Vector2.new(0.5, 0.5)
    FrameBox_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    FrameBox_4.BackgroundTransparency = 1.000
    FrameBox_4.BorderColor3 = Color3.fromRGB(0, 0, 0)
    FrameBox_4.BorderSizePixel = 0
    FrameBox_4.Position = UDim2.new(0.576056361, 0, 0.5, 0)
    FrameBox_4.Size = UDim2.new(0.845070422, 0, 1.47457623, 0)
    FrameBox_4.ZIndex = 2
    FrameBox_4.Image = "rbxassetid://96198739376505"

    TextBox_4.Parent = FrameBox_4
    TextBox_4.AnchorPoint = Vector2.new(0.5, 0.5)
    TextBox_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextBox_4.BackgroundTransparency = 1.000
    TextBox_4.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextBox_4.BorderSizePixel = 0
    TextBox_4.Position = UDim2.new(0.5, 0, 0.5, 0)
    TextBox_4.Size = UDim2.new(0.916666687, 0, 0.576271176, 0)
    TextBox_4.ZIndex = 2
    TextBox_4.Font = Enum.Font.FredokaOne
    TextBox_4.PlaceholderColor3 = Color3.fromRGB(0, 0, 0)
    TextBox_4.PlaceholderText = "Pet size here..."
    TextBox_4.Text = ""
    TextBox_4.TextColor3 = Color3.fromRGB(0, 0, 0)
    TextBox_4.TextScaled = true
    TextBox_4.TextSize = 14.000
    TextBox_4.TextWrapped = true

    BackgroundImg.Name = "BackgroundImg"
    BackgroundImg.Parent = Container
    BackgroundImg.AnchorPoint = Vector2.new(0.5, 0.5)
    BackgroundImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BackgroundImg.BackgroundTransparency = 1.000
    BackgroundImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    BackgroundImg.BorderSizePixel = 0
    BackgroundImg.Position = UDim2.new(0.5, 0, 0.5, 0)
    BackgroundImg.Rotation = -5.000
    BackgroundImg.Size = UDim2.new(0.917594671, 0, 0.831103683, 0)
    BackgroundImg.Image = "rbxassetid://127044390796859"

    TitleImg.Name = "TitleImg"
    TitleImg.Parent = Container
    TitleImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TitleImg.BackgroundTransparency = 1.000
    TitleImg.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TitleImg.BorderSizePixel = 0
    TitleImg.Position = UDim2.new(0.0178173725, 0, 0.0234113969, 0)
    TitleImg.Size = UDim2.new(0.462138087, 0, 0.12662667, 0)
    TitleImg.ZIndex = 3
    TitleImg.Image = "rbxassetid://109685951276674"

    UIAspectRatioConstraint_2.Parent = TitleImg
    UIAspectRatioConstraint_2.AspectRatio = 5.481

    GivePetButton.Name = "GivePetButton"
    GivePetButton.Parent = Container
    GivePetButton.AnchorPoint = Vector2.new(0.5, 0.5)
    GivePetButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    GivePetButton.BackgroundTransparency = 1.000
    GivePetButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    GivePetButton.BorderSizePixel = 0
    GivePetButton.Position = UDim2.new(0.5, 0, 0.919732451, 0)
    GivePetButton.Size = UDim2.new(0.278396428, 0, 0.158862874, 0)
    GivePetButton.ZIndex = 3
    GivePetButton.Image = "rbxassetid://134668615256338"

    CloseBtn.Name = "CloseBtn"
    CloseBtn.Parent = Container
    CloseBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.BackgroundTransparency = 1.000
    CloseBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Position = UDim2.new(0.955456555, 0, 0.0852842778, 0)
    CloseBtn.Size = UDim2.new(0.119153678, 0, 0.178929761, 0)
    CloseBtn.ZIndex = 3
    CloseBtn.Image = "rbxassetid://82177231415737"
end


table.freeze(Components)
return Components