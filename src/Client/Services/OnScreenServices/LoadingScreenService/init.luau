--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local StarterPlayer = game:GetService("StarterPlayer")
local TeleportService = game:GetService("TeleportService")

local Components = require(script.Components)

local UILib = require(StarterPlayer.StarterPlayerScripts.Libraries.UILib)
local TweensLib = require(ReplicatedStorage.Libraries.TweensLib)
--[[ @end_section Imports ]]


type HandledTween = TweensLib.HandledTween


--[[ @section Variables ]]
local localPlayer = Players.LocalPlayer :: Player
local PlayerGui = (if localPlayer then localPlayer:WaitForChild("PlayerGui") else nil) :: PlayerGui

local spinTime = 2.5
local fadeTime = 0.5
--[[ @end_section Variables ]]


--[[ @section Tween Functions ]]
--[[
    @usage Spins the inputted instance.

    @param inst GuiObject
    @param orientation number
    @param timeInput number

    @return HandledTween
]]
local function spinInst(inst: GuiObject, orientation: number, timeInput: number): HandledTween
    local spinningTween
    = TweensLib(
        inst,


        timeInput,

        Enum.EasingStyle.Sine,
        Enum.EasingDirection.Out,

        0,
        false,
        0,


        { Rotation = orientation }
    )

    return spinningTween
end

--[[
    @usage Hides the inputted instance.

    @param inst GuiObject
    @param timeInput number

    @return HandledTween
]]
local function hideInst(inst: GuiObject, timeInput: number): HandledTween
    local spinningTween
    = TweensLib(
        inst,


        timeInput,

        Enum.EasingStyle.Sine,
        Enum.EasingDirection.Out,

        0,
        false,
        0,


        {
            Transparency
            = if
                not inst:IsA("ImageLabel")
                and not inst:IsA("TextLabel")
                and not inst:IsA("TextButton")
            then 1 else nil,

            ImageTransparency = if inst:IsA("ImageLabel") then 1 else nil,
            TextTransparency = if inst:IsA("TextLabel") or inst:IsA("TextButton") then 1 else nil,

            BackgroundTransparency
            = if
                inst:IsA("Frame")
                or inst:IsA("TextLabel")
                or inst:IsA("TextButton")
                or inst:IsA("ImageLabel")
                or inst:IsA("ImageButton")
            then 1 else nil
        }
    )

    return spinningTween
end
--[[ @end_section Tween Functions ]]


--[[ @section Constructor ]]
--[[
    @usage Handles displaying the commands list UI.
    
    @return void
]]
local function constructorCallback()
    local isLoading = true

    -- Hide the default loading screen, set all core guis to disabled, and set the teleport gui.
    do
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

        ReplicatedFirst:RemoveDefaultLoadingScreen()
        TeleportService:SetTeleportGui((Components.LoadingScreen:Clone() :: any) :: GuiObject)
    end

    local newScreenClone = Components.LoadingScreen:Clone()
    newScreenClone.Parent = PlayerGui

    local newMainFrame = newScreenClone:WaitForChild("MainFrame") :: Frame
    local newLogoImg = newMainFrame:WaitForChild("LogoImg") :: ImageLabel
    local newStatusTxt = newMainFrame:WaitForChild("StatusTxt") :: TextLabel
    local newSkipBtn = newMainFrame:WaitForChild("SkipBtn") :: TextButton

    local newUILib = UILib("loading_screen", newScreenClone)

    newUILib:hoverAndToggleSizing(1.15)
    newUILib:handleButtonPress(newSkipBtn, function(pos1: number, pos2: number) isLoading = false end)

    newSkipBtn.Visible = true

    task.spawn(
        function()
            local lastSpinStatus = 1

            while true do
                if not isLoading then break end

                if lastSpinStatus == 1 then lastSpinStatus = 2 elseif lastSpinStatus == 2 then lastSpinStatus = 1 end
                spinInst(newLogoImg, if lastSpinStatus == 1 then 0 else 360, spinTime):waitForCompletion()
            end

            -- Hide the loading screen.
            do
                local HidingObjects
                = {
                    newLogoImg,
                    newMainFrame,
                    newStatusTxt,
                    newSkipBtn
                }

                for i: number, child: Instance in ipairs(HidingObjects) do
                    if child ~= newLogoImg then hideInst(child :: GuiObject, fadeTime) else hideInst(child :: GuiObject, fadeTime * 2) end
                end
            end

            spinInst(newLogoImg, if lastSpinStatus == 1 then 360 else 0, fadeTime * 2):waitForCompletion()

            -- Destroy the loading screen.
            do
                newScreenClone:Destroy()
                newUILib:destroy()

                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
            end
        end
    )

    newStatusTxt.Visible = true

    -- Preload all existing experience assets.
    do
        local experienceDescendants = workspace:GetDescendants()
        local numOfDescendants = #experienceDescendants

        for i: number, child: Instance in ipairs(experienceDescendants) do
            if not isLoading then break end

            newStatusTxt.Text = `Loading asset {child.Name}. ({i}/{numOfDescendants})`
            ContentProvider:PreloadAsync({ child })

            task.wait()
        end
    end

    newStatusTxt.Text = "Loading assets complete."; isLoading = false
end

return constructorCallback
--[[ @end_section Constructor ]]