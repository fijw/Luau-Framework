--!strict
--!optimize 2


--[[ @section Types ]]
export type SideType = "center" | "top" | "bottom" | "left" | "right"


export type HandledUISchema
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

export type HandledUIInheritanceSchema
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


local ReturningValue = {}


table.freeze(ReturningValue)
return ReturningValue