--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local CommandsNamespace = require(ReplicatedStorage.Networking.Namespaces.Services.Commands)

local TweensLibrary = require(ReplicatedStorage.Libraries.TweensLib)
--[[ @end_section Imports ]]


type CharacterSchema
= {
    character: Model,
    Humanoid: Humanoid,
    rootPart: BasePart
}


--[[ @section Variables ]]
local LOCAL_PLAYER = Players.LocalPlayer :: Player

local SPEED = 50


local bodyGyro: BodyGyro
local bodyVelocity: BodyVelocity

local _renderSteppedConnection: RBXScriptConnection


local isFlying = false
local isAllowedToFly = false
--[[ @end_section Variables ]]


--[[
    @usage Handles the movement of the player.

    @param deltaTime number
    @param rootPart BasePart

    @return void
]]
local function onRenderStepped(deltaTime: number, rootPart: BasePart)
    if not bodyGyro or not bodyVelocity then return end

    local cam = workspace.CurrentCamera
    local move = Vector3.zero

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
    
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.yAxis end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.yAxis end

    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then SPEED = 100 else SPEED = 50 end

    TweensLibrary(
        bodyGyro,


        0.15,

        Enum.EasingStyle.Sine,
        Enum.EasingDirection.Out,

        0,
        false,
        0,


        { CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + cam.CFrame.LookVector) }
    )

    if move.Magnitude > 0 then bodyVelocity.Velocity = move.Unit * SPEED
    else bodyVelocity.Velocity = Vector3.zero end
end


--[[ @section Fly & Unfly Functions ]]
--[[
    @usage Enables the player to fly.

    @param humanoid Humanoid
    @param rootPart BasePart

    @return void
]]
local function enableFlying(humanoid: Humanoid, rootPart: BasePart)
    isFlying = true

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = rootPart

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.CFrame = rootPart.CFrame
    bodyGyro.P = 9e4
    bodyGyro.Parent = rootPart

    humanoid.PlatformStand = true

    _renderSteppedConnection = RunService.RenderStepped
    :Connect(function(deltaTime: number) onRenderStepped(deltaTime, rootPart) end)
end

--[[
    @usage Disables the player from flying.

    @param humanoid Humanoid

    @return void
]]
local function disableFlying(humanoid: Humanoid)
    isFlying = false

    bodyVelocity:Destroy()
    bodyGyro:Destroy()

    humanoid.PlatformStand = false
    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

    _renderSteppedConnection:Disconnect()
end
--[[ @end_section Fly & Unfly Functions ]]


--[[ @section Utility Functions ]]
--[[
    @usage Handles the input of the player.

    @param input InputObject
    @param gameProcessed boolean

    @param humanoid Humanoid
    @param rootPart BasePart

    @return void
]]
local function onInputBegan
(
    input: InputObject,
    gameProcessed: boolean,

    humanoid: Humanoid,
    rootPart: BasePart
)
    if gameProcessed or input.KeyCode ~= Enum.KeyCode.F or isAllowedToFly == false then return end

    if isFlying == true then disableFlying(humanoid)
    elseif isFlying == false then enableFlying(humanoid, rootPart) end
end

--[[
    @usage Fetch the player's character stuff.
    
    @return CharacterSchema
]]
local function getCharacterSchema(): CharacterSchema
    local character = LOCAL_PLAYER.Character :: Model
    if not character then character = LOCAL_PLAYER.CharacterAdded:Wait() end

    local humanoid = character:WaitForChild("Humanoid") :: Humanoid
    local rootPart = character:WaitForChild("HumanoidRootPart") :: BasePart

    local CharacterSchema: CharacterSchema
    = {
        character = character,
        Humanoid = humanoid,
        rootPart = rootPart
    }

    return CharacterSchema
end
--[[ @end_section Utility Functions ]]


--[[ @section Constructor ]]
--[[
    @usage Handles the flying packets sent by the server.
    
    @return void
]]
local function constructorCallback()
    CommandsNamespace.packets.ClientFlyCharacter
    .listen(
        function(data: nil, player: Player?)
            isAllowedToFly = true

            local CharacterStuff = getCharacterSchema()
            enableFlying(CharacterStuff.Humanoid, CharacterStuff.rootPart)

            StarterGui:SetCore("SendNotification",
                {
                    Title = "You are now flying.",
                    Text = `Press "F" to stop/start flying.\nPress "Shift" for faster flying.\nPress "Space" to ascend.\nPress "LeftControl" to descend.`,
                    
                    Duration = 10
                }
            )
        end
    )

    CommandsNamespace.packets.ClientUnflyCharacter
    .listen(
        function(data: nil, player: Player?)
            isAllowedToFly = false

            local CharacterStuff = getCharacterSchema()
            disableFlying(CharacterStuff.Humanoid)
        end
    )

    UserInputService.InputBegan
    :Connect(
        function(input: InputObject, gameProcessed: boolean)
            local CharacterStuff = getCharacterSchema()
            onInputBegan(input, gameProcessed, CharacterStuff.Humanoid, CharacterStuff.rootPart)
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]