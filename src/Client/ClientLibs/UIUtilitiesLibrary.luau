--[[
    @Banner
    ```
        ▀▀▀    ▀▀▀    ▀▀▀    ▀▀▀    ▀▀▀    ▀▀▀    ▀▀▀    ▀▀▀    ▀▀▀    ▀▀▀  
                                                                            
                                                                            
                                                                            
                                                                            
        █           ▄    ▄          ▀                                  █   
        █           █  ▄▀   ▄▄▄   ▄▄▄     ▄ ▄▄   ▄▄▄    ▄▄▄            █   
        █           █▄█    ▀   █    █     █▀  ▀ █▀ ▀█  █   ▀           █   
        █           █  █▄  ▄▀▀▀█    █     █     █   █   ▀▀▀▄           █   
        █           █   ▀▄ ▀▄▄▀█  ▄▄█▄▄   █     ▀█▄█▀  ▀▄▄▄▀           █   
        █                                                              █   
                                                                            
                                                                            
                                                                            
                                                                            
                                                                            
        ▀▀▀    ▀▀▀    ▀▀▀    ▀▀▀    ▀▀▀    ▀▀▀    ▀▀▀    ▀▀▀    ▀▀▀    ▀▀▀  

        @Author Kairos (Roblox @: roblox_user_5618502527)
        @Version 1.0.1
    ```
    
    @Description Quick handler for UI functionality.
    @Description Can handle button inputs, button presses, button sizing, etc.        

    @Example
    ```luau
        local TestUi = PLAYER_GUI:WaitForChild("TestUI") :: ScreenGui
        local testFrame = TestUi:WaitForChild("TestFrame") :: Frame
        local testButton = testFrame:WaitForChild("TestButton") :: TextButton
        local testDraggableTitleBar = testFrame:WaitForChild("TitleBar") :: TextLabel

        -- Setting up the UI Utilities.
        do
            local originalTestButtonSize = testButton.Size

            local HandledUi = UIUtilitiesLibrary(TestUi)
            HandledUi:hoverAndToggleSizing(1.15) -- 1.15? idk.

            HandledUi:handleButtonPress(testButton,
                function(pos1: number, pos2: number)
                    print("pressed")
                end,

                originalTestButtonSize
            )

            HandledUi:handleGuiObjectInput(testButton.MouseEnter,
                function()
                    print("hovered")
                end
            )

            HandledUi:makeGuiObjectDraggable(testFrame, "top")

            print(HandledUi)
        end
    ```
]]
--!strict
--!optimize 2


--[[ @section Imports ]]
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts

local TweensLibrary = require(StarterPlayerScripts.ClientLibs.TweensLibrary)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type SideType = "center" | "top" | "bottom" | "left" | "right"


type HandledUISchema
= {
    ScreenGui: ScreenGui,

    SizingConnections: { [any]: RBXScriptConnection },
    PressConnections: { RBXScriptConnection },
    OtherConnections: { RBXScriptConnection },

    DraggableObjects
    : {
        [string]
        : {
            draggingObject: GuiObject,

            isHovering: boolean,
            isHolding: boolean
        }
    }
}

export type HandledUI = setmetatable
<
    HandledUISchema,
    { __index: HandledUIInheritanceSchema }
>

type HandledUIInheritanceSchema
= {
    hoverAndToggleSizing: (self: HandledUI, sizeIncrease: number) -> (),

    handleButtonPress
    : (
        self: HandledUI,

        button: GuiButton,
        callback: (pos1: number, pos2: number) -> (),
        isClosingButton: true?
    ) -> (),

    handleGuiObjectInput
    : (
        self: HandledUI,
        
        action: RBXScriptSignal,
        callback: () -> ()
    ) -> (),

    makeGuiObjectDraggable: (self: HandledUI, guiObjectToDrag: GuiObject, side: SideType) -> (),

    wipeConnections: (self: HandledUI) -> ()
}
--[[ @end_section Types ]]


--[[ @section Variables ]]
local scaleTweenTime = 0.1
local offsetPositionDivision = 16


local Constructor = {}
local Inheritance = {} :: HandledUIInheritanceSchema

local UIUtilities = {}


UIUtilities.HandledUI = {} :: { HandledUI }
--[[ @end_section Variables ]]


--[[
    @usage Changes the size of a GuiObject.

    @param inst GuiObject
    @param scaledInstanceSize UDim2

    @return
]]
local function scaleInstance(inst: GuiObject, scaledInstanceSize: UDim2)
    TweensLibrary(
        inst,


        scaleTweenTime,

        Enum.EasingStyle.Sine,
        Enum.EasingDirection.Out,

        0,
        false,
        0,


        { Size = scaledInstanceSize }
    ):waitForCompletion()
end


--[[ @end_section UserInputService Functions ]]
--[[
    @usage Handles input began for draggable gui objects.

    @param input InputObject
    @param gameProcessed boolean

    @param guiObject GuiObject
    @param side SideType

    @param HandledUICalledFrom HandledUI

    @return
]]
local function onInputBegan
(
    input: InputObject,
    gameProcessed: boolean,

    draggingObject: GuiObject,
    side: SideType,

    HandledUICalledFrom: HandledUI
)
    local DraggableData = HandledUICalledFrom.DraggableObjects[draggingObject.Name]

    if gameProcessed or not DraggableData.isHovering then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end

    DraggableData.isHolding = true

    local GuiInset = GuiService:GetGuiInset()

    if draggingObject.AnchorPoint == Vector2.new(0, 0) then draggingObject.AnchorPoint = Vector2.new(0, 0) end

    -- While the draggable object is hovering and is being held, update its position.
    while DraggableData.isHovering and DraggableData.isHolding do
        local playerMousePosition = UserInputService:GetMouseLocation()
        local mousePos = playerMousePosition - GuiInset

        local xPos: number, yPos: number

        if side == "center" then
            xPos = draggingObject.AbsoluteSize.X / 2
            yPos = draggingObject.AbsoluteSize.Y / 2
        elseif side == "top" then
            xPos = draggingObject.AbsoluteSize.X / 2
            yPos = draggingObject.AbsoluteSize.Y / offsetPositionDivision
        elseif side == "bottom" then
            xPos = draggingObject.AbsoluteSize.X / 2
            yPos = draggingObject.AbsoluteSize.Y - (draggingObject.AbsoluteSize.Y / offsetPositionDivision)
        elseif side == "left" then
            xPos = draggingObject.AbsoluteSize.X / offsetPositionDivision
            yPos = draggingObject.AbsoluteSize.Y / 2
        elseif side == "right" then
            xPos = draggingObject.AbsoluteSize.X - (draggingObject.AbsoluteSize.X / offsetPositionDivision)
            yPos = draggingObject.AbsoluteSize.Y / 2
        end
        
        local newPos = mousePos - Vector2.new(xPos, yPos)

        TweensLibrary(
            draggingObject,


            0.01,

            Enum.EasingStyle.Sine,
            Enum.EasingDirection.Out,

            0,
            false,
            0,


            { Position = UDim2.fromOffset(newPos.X, newPos.Y) }
        ):waitForCompletion()
    end
end

--[[
    @usage Handles input ended for draggable gui objects.

    @param input InputObject
    @param gameProcessed boolean

    @param HandledUICalledFrom HandledUI

    @return
]]
local function onInputEnded
(
    input: InputObject,
    gameProcessed: boolean,

    draggingObjectName: string,

    HandledUICalledFrom: HandledUI
)
    if gameProcessed or not HandledUICalledFrom.DraggableObjects[draggingObjectName].isHovering then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end

    HandledUICalledFrom.DraggableObjects[draggingObjectName].isHolding = false
end
--[[ @end_section UserInputService Functions ]]


--[[ @section Constructor ]]
--[[
    @usage Handles the addition of a new handled UI.

    @param ui ScreenGui

    @return HandledUI
]]
function Constructor:__call(ui: ScreenGui): HandledUI
    local NewHandledUI: HandledUISchema
    = {
        ScreenGui = ui,

        SizingConnections = {},
        PressConnections = {},
        OtherConnections = {},

        DraggableObjects = {}
    }

    setmetatable(NewHandledUI, { __index = Inheritance })

    table.insert(UIUtilities.HandledUI, NewHandledUI)

    return NewHandledUI :: HandledUI
end

setmetatable(UIUtilities, { __call = Constructor.__call })
--[[ @end_section Constructor ]]


--[[ @section Connection Inheritance ]]
--[[
    @usage Sizes buttons on hovers and clicks.

    @param self HandledUI
    @param sizeIncrease number

    @return
]]
function Inheritance:hoverAndToggleSizing(sizeIncrease: number)
    local Descendants = self.ScreenGui:GetDescendants()

    for i: number, inst: Instance in ipairs(Descendants) do
        if not inst:IsA("GuiButton") then continue end

        local defaultInstanceSize = inst.Size

        local newX, newY = defaultInstanceSize.X.Scale * sizeIncrease, defaultInstanceSize.Y.Scale * sizeIncrease
        local upscaledInstanceSize = UDim2.new(newX, 0, newY, 0)

        local UpsizeConnection = inst.MouseEnter:Connect(function() scaleInstance(inst, upscaledInstanceSize) end)
        local DownsizeConnection = inst.MouseLeave:Connect(function() scaleInstance(inst, defaultInstanceSize) end)

        local UpsizeClickConnection = inst.MouseButton1Up:Connect(function() scaleInstance(inst, upscaledInstanceSize) end)
        local DownsizeClickConnection = inst.MouseButton1Down:Connect(function() scaleInstance(inst, defaultInstanceSize) end)

        -- Store sizing Connections.
        do
            table.insert(self.SizingConnections, UpsizeConnection)
            table.insert(self.SizingConnections, DownsizeConnection)

            table.insert(self.SizingConnections, UpsizeClickConnection)
            table.insert(self.SizingConnections, DownsizeClickConnection)
        end
    end
end

--[[
    @usage Handles GuiObject inputs.

    @param self HandledUI

    @param action RBXScriptConnection
    @param callback (pos1: number, pos2: number) -> ()

    @return
]]
function Inheritance:handleGuiObjectInput
(
    action: RBXScriptSignal,
    callback: (pos1: number, pos2: number) -> ()
)
    local InputConnection = action:Connect(callback)
    table.insert(self.OtherConnections, InputConnection)
end

--[[
    @usage Handles button presses.

    @param self HandledUI

    @param button GuiButton
    @param callback (pos1: number, pos2: number) -> ()
    @param isClosingButton true?

    @return
]]
function Inheritance:handleButtonPress
(
    button: GuiButton,
    callback: (pos1: number, pos2: number) -> (),
    isClosingButton: true?
)
    local originalSize = button.Size

    local PressConnection = button.MouseButton1Up
    :Connect(
        function(pos1: number, pos2: number)
            callback(pos1, pos2)

            if not isClosingButton then return end
            self.ScreenGui.Enabled = false

            task.wait(scaleTweenTime)

            scaleInstance(button, originalSize)
        end
    )

    table.insert(self.PressConnections, PressConnection)
end

--[[
    @usage Makes a GuiObject draggable.

    @param self HandledUI

    @param guiObject GuiObject
    @param side SideType

    @return
]]
function Inheritance:makeGuiObjectDraggable(guiObjectToDrag: GuiObject, side: SideType)
    local draggingObjectName = guiObjectToDrag.Name

    self.DraggableObjects[draggingObjectName]
    = {
        draggingObject = guiObjectToDrag,

        isHovering = false,
        isHolding = false
    }

    -- Handle and store connections.
    do
        local InputBeganConnection = UserInputService.InputBegan
        :Connect(
            function(input: InputObject, gameProcessed: boolean)
                onInputBegan(input, gameProcessed, guiObjectToDrag, side, self)
            end
        )

        local InputEndedConnection = UserInputService.InputEnded
        :Connect(
            function(input: InputObject, gameProcessed: boolean)
                onInputEnded(input, gameProcessed, guiObjectToDrag.Name, self)
            end
        )

        table.insert(self.OtherConnections, InputBeganConnection)
        table.insert(self.OtherConnections, InputEndedConnection)
    end

    self:handleGuiObjectInput(guiObjectToDrag.MouseEnter, function() self.DraggableObjects[draggingObjectName].isHovering = true end)
    self:handleGuiObjectInput(guiObjectToDrag.MouseLeave, function() self.DraggableObjects[draggingObjectName].isHovering = false end)
end
--[[ @section Connection Inheritance ]]


--[[
    @usage Destroys all connections.
    
    @param self HandledUI

    @return
]]
function Inheritance:wipeConnections()
    for i: number, Connection: RBXScriptConnection in ipairs(self.SizingConnections) do
        Connection:Disconnect()
    end

    for i: number, Connection: RBXScriptConnection in ipairs(self.PressConnections) do
        Connection:Disconnect()
    end

    for i: number, Connection: RBXScriptConnection in ipairs(self.OtherConnections) do
        Connection:Disconnect()
    end
end


table.freeze(UIUtilities)
return UIUtilities