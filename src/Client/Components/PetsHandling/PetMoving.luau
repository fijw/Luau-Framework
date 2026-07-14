--!strict
--!native
--!optimize 2


local RunService = game:GetService("RunService")
local Players = game:GetService("Players")


local PET_MUL_SPEED = 50
local WOBBLE_TIME_MUL = 8
local LOOK_AT_TIME_MUL = 10
local WOBBLE_ANGLE = math.rad(1.025)
local BOBBLE_HEIGHT = 2.5


--[[ @section Constructor Function ]]
--[[
    @usage Move the pet to the target position.

    @param CurrentlyWalkingCache { string }
    @param EquippedPetsCache { [string]: Model }
    @param GamePetsFolder Folder
    @param CachedFieldPets { [string]: { petModel: Model, field: BasePart } }
    @param petModel Model
    @param targetPosition Vector3
    @param lookAtPart BasePart
    @param petRootPart BasePart

    @return void
]]
local function movePetTo
(
    CurrentlyWalkingCache: { string },
    EquippedPetsCache: { [string]: Model },
    GamePetsFolder: Folder,
    CachedFieldPets: { [string]: { petModel: Model, field: BasePart } },
    petModel: Model,
    targetPosition: Vector3,
    lookAtPart: BasePart,
    petRootPart: BasePart
)
    local isDoneAnimatingWalking, timeSinceStartedWalking, direction = false, 0, 0

    -- Walking connection handling.
    do
        local lookAtDirectionRotation: CFrame
        local movementConnection: RBXScriptConnection
        
        movementConnection = RunService.Heartbeat:Connect(
            function(deltaTime: number)
                if not petModel or not petModel.Parent then movementConnection:Disconnect(); return end
                
                if direction == 0 then
                    if timeSinceStartedWalking >= 1 then direction = 1 end
                    timeSinceStartedWalking += deltaTime
                elseif direction == 1 then
                    if timeSinceStartedWalking <= -1 then direction = 0 end
                    timeSinceStartedWalking -= deltaTime
                end

                local copiedTargetPos = targetPosition

                -- Floor detection.
                do
                    local rayOrigin = CFrame.new(petRootPart.Position.X, 500, petRootPart.Position.Z).Position
                    local rayDirection = Vector3.new(0, -1_000, 0)

                    local rayParams = RaycastParams.new()
                    rayParams.FilterType = Enum.RaycastFilterType.Exclude
                    rayParams.FilterDescendantsInstances = {}

                    for i: string, cachedModel: Model in pairs(EquippedPetsCache) do
                        local cachedPetModel = GamePetsFolder:FindFirstChild(i) :: Model
                        if not cachedPetModel then continue end

                        local OldFilter = rayParams.FilterDescendantsInstances; table.insert(OldFilter, cachedPetModel)
                        rayParams.FilterDescendantsInstances = OldFilter
                    end

                    for i: string, CachedData: { petModel: Model, field: BasePart } in pairs(CachedFieldPets) do
                        local cachedPetModel = GamePetsFolder:FindFirstChild(i) :: Model
                        if not cachedPetModel then continue end

                        local OldFilter = rayParams.FilterDescendantsInstances; table.insert(OldFilter, cachedPetModel)
                        rayParams.FilterDescendantsInstances = OldFilter
                    end

                    for i: number, loopedPlr: Player in ipairs(Players:GetPlayers()) do
                        local loopedPlrChar = loopedPlr.Character
                        if not loopedPlrChar then continue end

                        local OldFilter = rayParams.FilterDescendantsInstances; table.insert(OldFilter, loopedPlrChar)
                        rayParams.FilterDescendantsInstances = OldFilter
                    end

                    local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
                    if not result then return end
                    
                    local resultPos = result.Position + Vector3.new(0, petRootPart.Size.Y / 2, 0)
                    copiedTargetPos = CFrame.new(copiedTargetPos.X, resultPos.Y, copiedTargetPos.Z).Position
                end

                local movingOffset = copiedTargetPos - petRootPart.Position
                local speedOffset = PET_MUL_SPEED * (movingOffset.Magnitude / math.max(Vector3.new(movingOffset.X, 0, movingOffset.Z).Magnitude, 0.001))
                local step = (movingOffset.Unit * deltaTime) * speedOffset

                lookAtDirectionRotation = CFrame.lookAt(Vector3.zero, Vector3.new(movingOffset.Unit.X, 0, movingOffset.Unit.Z).Unit).Rotation

                local smoothLookAtMoveDirRotation = petRootPart.CFrame.Rotation:Lerp(
                    lookAtDirectionRotation,
                    deltaTime * LOOK_AT_TIME_MUL
                )

                local wobbleRotation = CFrame.Angles(
                    math.sin(timeSinceStartedWalking * WOBBLE_TIME_MUL) * WOBBLE_ANGLE,
                    0,
                    0
                )

                local bobbleOffset = math.abs(math.sin(timeSinceStartedWalking * WOBBLE_TIME_MUL)) * BOBBLE_HEIGHT

                petRootPart.CFrame
                = CFrame.new(
                    petRootPart.Position.X + step.X,
                    copiedTargetPos.Y + bobbleOffset,
                    petRootPart.Position.Z + step.Z
                ) * smoothLookAtMoveDirRotation * wobbleRotation

                -- Cleanup.
                do
                    local readingOffset = CFrame.new(copiedTargetPos.X, 0, copiedTargetPos.Z).Position - CFrame.new(petRootPart.Position.X, 0, petRootPart.Position.Z).Position
                    if readingOffset.Magnitude > 0.5 then return end; movementConnection:Disconnect()
                    
                    local lookPos = lookAtPart.Position - copiedTargetPos
                    local flatFeetLookPosVec = Vector3.new(lookPos.X, 0, lookPos.Z)

                    local isDoneLookingAtLookAtPart = false
                    local isDoneGoingToFloor = false

                    -- Floor finishing movement.
                    do
                        local gotoFloorConnection: RBXScriptConnection

                        gotoFloorConnection = RunService.Heartbeat:Connect(
                            function(deltaTime: number)
                                local floorFeetOffset = CFrame.new(0, copiedTargetPos.Y, 0).Position - CFrame.new(0, petRootPart.Position.Y, 0).Position

                                if not petModel or not petModel.Parent then gotoFloorConnection:Disconnect(); isDoneGoingToFloor = true; return end
                                if floorFeetOffset.Magnitude < 0.15 then gotoFloorConnection:Disconnect(); isDoneGoingToFloor = true; return end

                                petRootPart.CFrame = CFrame.new(petRootPart.Position + floorFeetOffset.Unit * deltaTime * LOOK_AT_TIME_MUL) * smoothLookAtMoveDirRotation
                            end
                        )
                    end

                    -- Look at owner.
                    do
                        local lookAtConnection: RBXScriptConnection

                        lookAtConnection = RunService.Heartbeat:Connect(
                            function(deltaTime: number)
                                if not petModel or not petModel.Parent then lookAtConnection:Disconnect(); isDoneLookingAtLookAtPart = true; return end

                                if petRootPart.CFrame.LookVector:Dot(flatFeetLookPosVec.Unit) > 0.999 then
                                    lookAtConnection:Disconnect(); isDoneLookingAtLookAtPart = true; return
                                end

                                local smoothLookAtPlrDirRotation = petRootPart.CFrame.Rotation:Lerp(
                                    CFrame.lookAt(
                                        Vector3.zero,
                                        flatFeetLookPosVec.Unit
                                    ).Rotation,

                                    deltaTime * LOOK_AT_TIME_MUL
                                )

                                petRootPart.CFrame = CFrame.new(petRootPart.Position) * smoothLookAtPlrDirRotation
                            end
                        )
                    end

                    repeat task.wait() until (isDoneGoingToFloor and isDoneLookingAtLookAtPart) or not petModel or not petModel.Parent; isDoneAnimatingWalking = true
                end
            end
        )
    end

    repeat task.wait() until isDoneAnimatingWalking

    local foundWalkingIndex = table.find(CurrentlyWalkingCache, petModel.Name)
    if foundWalkingIndex then table.remove(CurrentlyWalkingCache, foundWalkingIndex) end
end

return movePetTo
--[[ @end_section Constructor Function ]]