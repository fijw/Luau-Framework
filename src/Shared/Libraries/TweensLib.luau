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
    |        Tween any inputted instance to change any given properties     |
    |        with inputted parameters. Will work with all instances that    |
    |        can be tweened (eg. Part, Mesh, Frame, GuiButton etc).         |
    |    ```                                                                |
    |                                                                       |
    -------------------------------------------------------------------------

    @usage
    ```luau
        local partInst = Instance.new("Part")
        partInst.Parent = workspace
        partInst.Size = Vector3.new(10, 10, 10)
        partInst.Position = Vector3.new(0, 15, 0)

        TweensLibrary(
            partInst,


            5,

            Enum.EasingStyle.Sine,
            Enum.EasingDirection.Out,

            0,
            false,
            0,


            {
                Color = Color3.fromRGB(255, 0, 0),
                Transparency = 0.5,
                Size = Vector3.new(5, 5, 5)
            }
        )
    ```
]]
--!strict
--!native
--!optimize 2


local TweenService = game:GetService("TweenService")


--[[ @section Types ]]
export type HandledTween = setmetatable
<
    { storedTween: Tween },

    {
        __index: { waitForCompletion: (self: HandledTween) -> () },
        __call: (self: HandledTween) -> (Tween)
    }
>
--[[ @end_section Types ]]


--[[
    @usage Wait for the tween to complete.

    @param self HandledTween

    @return
]]
local function waitForCompletionCallback(self: HandledTween): ()
    if self.storedTween.PlaybackState ~= Enum.PlaybackState.Playing then return end
    self.storedTween.Completed:Wait()
end


--[[ @section Constructor ]]
--[[
    @usage Create a new tween with the given parameters.


    @param instance Instance


    @param time number?

    @param easingStyle Enum.EasingStyle
    @param easingDirection Enum.EasingDirection

    @param repeatCount number
    @param isReversed boolean
    @param repeatDelay number


    @param GoalTable{ [string]: any }
    
    
    @return Tween
]]
local function constructorCallback
(
    instance: Instance,


    time: number?,

    easingStyle: Enum.EasingStyle,
    easingDirection: Enum.EasingDirection,

    repeatCount: number,
    isReversed: boolean,
    repeatDelay: number,


    GoalTable: { [string]: any }
): HandledTween
    local TweenInfo = TweenInfo.new(time, easingStyle, easingDirection, repeatCount, isReversed, repeatDelay)
    local Tween = TweenService:Create(instance, TweenInfo, GoalTable)

    Tween:Play()

    local HandledTween
    = setmetatable(
        { storedTween = Tween },
        { __index = { waitForCompletion = waitForCompletionCallback } }
    ) :: HandledTween

    return HandledTween
end

return constructorCallback
--[[ @end_section Constructor ]]