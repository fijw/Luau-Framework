--[[
    -------------------------------------------------------------------------
    |                                                                       |
    |    @author                                                            |
    |    ```                                                                |
    |        Roblox: @roblox_user_5618502527                                |
    |        GitHub: @fijw (k4)                                             |
    |        Twitter: @Xjwfi (k4)                                           |
    |        Discord: @vfjx (k4)                                            |
    |    ```                                                                |
    |                                                                       |
    |    @version 1.0.0                                                     |
    |                                                                       |
    |    @description                                                       |
    |    ```                                                                |
    |        Quick handler for UI functionality. Can handle button inputs,  |
    |        button presses, button sizing, etc.                            |
    |    ```                                                                |
    |                                                                       |
    -------------------------------------------------------------------------

    @usage
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

            HandledUi:destroy()
        end
    ```
]]
--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local GuiService = game:GetService("GuiService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local TweensLibrary = require(ReplicatedStorage.Libraries.TweensLib)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type SideType = "center" | "top" | "bottom" | "left" | "right"

type SetFocusCallbackType = (self: HandledUI, NamesKeepingFocus: { string }?) -> ()
type RemoveFocusCallbackType = (self: HandledUI, NamesToBringBackToFocus: { string }?) -> ()

export type HandledUI = setmetatable
<
    {
        ScreenGui: ScreenGui,

        SetFocusSubscriptionCallbacks: { [string]: SetFocusCallbackType },
        RemoveFocusSubscriptionCallbacks: { [string]: RemoveFocusCallbackType },

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
        },

        id: string
    },

    {
        __index
        : {
            hoverAndToggleSizing: (self: HandledUI, sizeIncrease: number) -> (),


            handleButtonPress
            : (
                self: HandledUI,

                button: GuiButton,
                callback: (pos1: number, pos2: number) -> (),
                isClosingButton: true?,
                keepingFocusNames: { string }?
            ) -> (),

            handleGuiObjectInput
            : (
                self: HandledUI,
                
                action: RBXScriptSignal,
                callback: (...any) -> ()
            ) -> (),


            makeGuiObjectDraggable: (self: HandledUI, guiObjectToDrag: GuiObject, side: SideType) -> (),

            
            setFocus: SetFocusCallbackType,
            removeFocus: RemoveFocusCallbackType,


            subscribeToSetFocus: (self: HandledUI, id: string, callback: SetFocusCallbackType) -> (),
            subscribeToRemoveFocus: (self: HandledUI, id: string, callback: RemoveFocusCallbackType) -> (),

            unsubscribeFromSetFocus: (self: HandledUI, id: string) -> (),
            unsubscribeFromRemoveFocus: (self: HandledUI, id: string) -> (),


            destroy: (self: HandledUI) -> ()
        }
    }
>
--[[ @end_section Types ]]


--[[ @section Variables ]]
local scaleTweenTime = 0.1
local offsetPositionDivision = 16

local UILibrary = { CachedUIClasses = {} :: { [string]: HandledUI } }
--[[ @end_section Variables ]]


--[[
    @usage Changes the size of a GuiObject.

    @param inst GuiObject
    @param scaledInstanceSize UDim2

    @return void
]]
local function scaleInstance(inst: GuiObject, scaledInstanceSize: UDim2): ()
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

    @return void
]]
local function onInputBegan
(
    input: InputObject,
    gameProcessed: boolean,
    draggingObject: GuiObject,
    side: SideType,
    HandledUICalledFrom: HandledUI
): ()
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

        -- Set the dragging position based on the side argument.
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

    @return void
]]
local function onInputEnded
(
    input: InputObject,
    gameProcessed: boolean,
    draggingObjectName: string,
    HandledUICalledFrom: HandledUI
): ()
    if gameProcessed or not HandledUICalledFrom.DraggableObjects[draggingObjectName].isHovering then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end

    HandledUICalledFrom.DraggableObjects[draggingObjectName].isHolding = false
end
--[[ @end_section UserInputService Functions ]]


--[[ @section Focus Functions ]]
--[[
    @usage Sets the focus of a HandledUI.

    @param self HandledUI
    @param NamesKeepingFocus { string }

    @return void
]]
local function setFocusCallback(self: HandledUI, NamesKeepingFocus: { string }?): ()
    for i: string, callback: SetFocusCallbackType in pairs(self.SetFocusSubscriptionCallbacks) do
        callback(self, NamesKeepingFocus)
    end

    for i: string, HandledUI: HandledUI in pairs(UILibrary.CachedUIClasses :: any) do
        if NamesKeepingFocus then if table.find(NamesKeepingFocus, HandledUI.ScreenGui.Name) then continue end end
        HandledUI.ScreenGui.Enabled = false
    end

    self.ScreenGui.Enabled = true
end

--[[
    @usage Removes the focus of a HandledUI.

    @param self HandledUI
    @param NamesToBringBackToFocus { string }

    @return void
]]
local function removeFocusCallback(self: HandledUI, NamesToBringBackToFocus: { string }?): ()
    for i: string, callback: RemoveFocusCallbackType in pairs(self.RemoveFocusSubscriptionCallbacks) do
        callback(self, NamesToBringBackToFocus)
    end

    if NamesToBringBackToFocus then
        for i: string, HandledUI: HandledUI in pairs(UILibrary.CachedUIClasses :: any) do
            if not table.find(NamesToBringBackToFocus, HandledUI.ScreenGui.Name) then continue end
            HandledUI.ScreenGui.Enabled = true
        end
    end

    self.ScreenGui.Enabled = false
end
--[[ @end_section Focus Functions ]]


--[[ @section Subscribing Functions ]]
--[[
    @usage Subscribes a callback to the set focus callback.

    @param self HandledUI
    @param callback SetFocusCallbackType

    @return void
]]
local function subscribeToSetFocusCallback(self: HandledUI, id: string, callback: SetFocusCallbackType): ()
    self.SetFocusSubscriptionCallbacks[id] = callback
end

--[[
    @usage Subscribes a callback to the remove focus callback.

    @param self HandledUI
    @param callback RemoveFocusCallbackType

    @return void
]]
local function subscribeToRemoveFocusCallback(self: HandledUI, id: string, callback: RemoveFocusCallbackType): ()
    self.RemoveFocusSubscriptionCallbacks[id] = callback
end
--[[ @end_section Subscribing Functions ]]


--[[ @section Unsubscribing Functions ]]
--[[
    @usage Unsubscribes a callback from the set focus subscription callbacks dictionary.

    @param self HandledUI
    @param id string

    @return void
]]
local function unsubscribeFromSetFocusCallback(self: HandledUI, id: string): ()
    self.SetFocusSubscriptionCallbacks[id] = nil
end

--[[
    @usage Unsubscribes a callback from the remove focus subscription callbacks dictionary.

    @param self HandledUI
    @param id string

    @return void
]]
local function unsubscribeFromRemoveFocusCallback(self: HandledUI, id: string): ()
    self.RemoveFocusSubscriptionCallbacks[id] = nil
end
--[[ @end_section Unsubscribing Functions ]]


--[[ @section Connection Inheritance ]]
--[[
    @usage Sizes buttons on hovers and clicks.

    @param self HandledUI
    @param sizeIncrease number

    @return void
]]
local function hoverAndToggleSizingCallback(self: HandledUI, sizeIncrease: number): ()
    local Descendants = self.ScreenGui:GetDescendants()

    local function setUpConnections(inst: GuiButton): ()
        local defaultInstanceSize = inst.Size

        local newX, newY = defaultInstanceSize.X.Scale * sizeIncrease, defaultInstanceSize.Y.Scale * sizeIncrease
        local upscaledInstanceSize = UDim2.new(newX, 0, newY, 0)

        local UpsizeConnection = inst.MouseEnter:Connect(function(): () scaleInstance(inst, upscaledInstanceSize) end)
        local DownsizeConnection = inst.MouseLeave:Connect(function(): () scaleInstance(inst, defaultInstanceSize) end)

        local UpsizeClickConnection = inst.MouseButton1Up:Connect(function(): () scaleInstance(inst, upscaledInstanceSize) end)
        local DownsizeClickConnection = inst.MouseButton1Down:Connect(function(): () scaleInstance(inst, defaultInstanceSize) end)

        -- Store sizing Connections.
        do
            table.insert(self.SizingConnections, UpsizeConnection)
            table.insert(self.SizingConnections, DownsizeConnection)

            table.insert(self.SizingConnections, UpsizeClickConnection)
            table.insert(self.SizingConnections, DownsizeClickConnection)
        end
    end

    for i: number, inst: Instance in ipairs(Descendants) do
        if not inst:IsA("GuiButton") then continue end
        setUpConnections(inst)
    end

    self.ScreenGui.DescendantAdded:Connect(
        function(child: Instance): ()
            if not child:IsA("GuiButton") then return end
            setUpConnections(child)
        end
    )
end

--[[
    @usage Handles GuiObject inputs.

    @param self HandledUI
    @param action RBXScriptConnection
    @param callback (...any) -> ()

    @return void
]]
local function handleGuiObjectInputCallback
(
    self: HandledUI,
    action: RBXScriptSignal,
    callback: (...any) -> ()
): ()
    local InputConnection = action:Connect(callback)
    table.insert(self.OtherConnections, InputConnection)
end

--[[
    @usage Handles button presses.

    @param self HandledUI
    @param button GuiButton
    @param callback (pos1: number, pos2: number) -> ()
    @param isClosingButton true?
    
    @return void
]]
local function handleButtonPressCallback
(
    self: HandledUI,
    button: GuiButton,
    callback: (pos1: number, pos2: number) -> (),
    isClosingButton: true?,
    keepingFocusNames: { string }?
): ()
    local originalSize = button.Size

    local PressConnection = button.MouseButton1Up
    :Connect(
        function(pos1: number, pos2: number): ()
            callback(pos1, pos2)

            if not isClosingButton then return end
            self:removeFocus()

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

    @return void
]]
local function makeGuiObjectDraggableCallback(self: HandledUI, guiObjectToDrag: GuiObject, side: SideType): ()
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
            function(input: InputObject, gameProcessed: boolean): ()
                onInputBegan(input, gameProcessed, guiObjectToDrag, side, self)
            end
        )

        local InputEndedConnection = UserInputService.InputEnded
        :Connect(
            function(input: InputObject, gameProcessed: boolean): ()
                onInputEnded(input, gameProcessed, guiObjectToDrag.Name, self)
            end
        )

        table.insert(self.OtherConnections, InputBeganConnection)
        table.insert(self.OtherConnections, InputEndedConnection)
    end

    self:handleGuiObjectInput(guiObjectToDrag.MouseEnter, function(): () self.DraggableObjects[draggingObjectName].isHovering = true end)
    self:handleGuiObjectInput(guiObjectToDrag.MouseLeave, function(): () self.DraggableObjects[draggingObjectName].isHovering = false end)
end
--[[ @section Connection Inheritance ]]


--[[
    @usage Destroys all connections.
    
    @param self HandledUI

    @return void
]]
local function destroyCallback(self: HandledUI): ()
    UILibrary.CachedUIClasses[self.id] = nil

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


--[[ @section Constructor ]]
--[[
    @usage Handles the addition of a new handled UI.

    @param ui ScreenGui

    @return HandledUI
]]
local function constructorCallback(self: unknown, id: string, ui: ScreenGui): HandledUI
    if UILibrary.CachedUIClasses[id] then return UILibrary.CachedUIClasses[id] end

    local NewHandledUI
    = {
        ScreenGui = ui,

        SetFocusSubscriptionCallbacks = {},
        RemoveFocusSubscriptionCallbacks = {},

        SizingConnections = {},
        PressConnections = {},
        OtherConnections = {},

        DraggableObjects = {},

        id = id
    } :: HandledUI

    setmetatable(NewHandledUI,
        {
            __index
            = {
                handleGuiObjectInput = handleGuiObjectInputCallback,
                handleButtonPress = handleButtonPressCallback,


                makeGuiObjectDraggable = makeGuiObjectDraggableCallback,


                destroy = destroyCallback,


                setFocus = setFocusCallback,
                removeFocus = removeFocusCallback,


                subscribeToSetFocus = subscribeToSetFocusCallback,
                subscribeToRemoveFocus = subscribeToRemoveFocusCallback,

                unsubscribeFromSetFocus = unsubscribeFromSetFocusCallback,
                unsubscribeFromRemoveFocus = unsubscribeFromRemoveFocusCallback,


                hoverAndToggleSizing = hoverAndToggleSizingCallback
            }
        }
    )

    UILibrary.CachedUIClasses[id] = (NewHandledUI :: any) :: HandledUI

    return (NewHandledUI :: any) :: HandledUI
end

setmetatable(UILibrary, { __call = constructorCallback })
--[[ @end_section Constructor ]]


table.freeze(UILibrary)
return UILibrary