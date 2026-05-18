--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RNG = require(ReplicatedStorage.Libraries.RNG)

local Data = require(ReplicatedStorage.Assets.Pets.Data)

local PetsHandlingGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.PetsHandling)
--[[ @end_section Imports ]]


type PetSchema = Data.PetSchema


--[[ @section Variables ]]
local AssetsFolder = workspace:WaitForChild("Assets") :: Folder
local AssetsPetsFolder = AssetsFolder:WaitForChild("Pets") :: Folder
local GameFolder = workspace:WaitForChild("Game") :: Folder
local GamePetsFolder = GameFolder:WaitForChild("Pets") :: Folder

local PET_MUL_SPEED = 50
local WOBBLE_TIME_MUL = 8
local LOOK_AT_TIME_MUL = 8
local WOBBLE_ANGLE = math.rad(1.025)
local BOBBLE_HEIGHT = 2.5

local RADIUS_MAP
= {
    Worldbreaker = { min = 5 * 18, max = 20 * 5 },
    Gigantic = { min = 5 * 12, max = 20 * 3 },
    Huge = { min = 5 * 6, max = 20 * 2 },
    Default = { min = 5, max = 20 }
}

local EquippedPetsCache: { [string]: Model } = {}
local CurrentlyWalkingCache: { string } = {}
--[[ @end_section Variables ]]


--[[ @section Util Functions ]]
--[[
    @usage Add pet to the game world.
    
    @param EquippingData { PetData: PetSchema, petId: string }
    @param plrRootPart BasePart

    @return void
]]
local function addPetToWorkspace(EquippingData: { PetData: PetSchema, petId: string }, plrRootPart: BasePart)
    if EquippedPetsCache[EquippingData.petId] then return end

    local petModel = AssetsPetsFolder:WaitForChild(EquippingData.PetData.petName) :: Model
    if not petModel.PrimaryPart then return end

    local clonedPetModel = petModel:Clone()
    clonedPetModel.Name = EquippingData.petId
    clonedPetModel.Parent = GamePetsFolder

    EquippedPetsCache[EquippingData.petId] = clonedPetModel

    if EquippingData.PetData.PetStats.size == "Worldbreaker" then
        if clonedPetModel.PrimaryPart then
            clonedPetModel.PrimaryPart.Size
            = Vector3.new(
                clonedPetModel.PrimaryPart.Size.X * 16,
                clonedPetModel.PrimaryPart.Size.Y * 16,
                clonedPetModel.PrimaryPart.Size.Z * 16
            )
        end
    elseif EquippingData.PetData.PetStats.size == "Gigantic" then
        if clonedPetModel.PrimaryPart then
            clonedPetModel.PrimaryPart.Size
            = Vector3.new(
                clonedPetModel.PrimaryPart.Size.X * 8,
                clonedPetModel.PrimaryPart.Size.Y * 8,
                clonedPetModel.PrimaryPart.Size.Z * 8
            )
        end
    elseif EquippingData.PetData.PetStats.size == "Huge" then
        if clonedPetModel.PrimaryPart then
            clonedPetModel.PrimaryPart.Size
            = Vector3.new(
                clonedPetModel.PrimaryPart.Size.X * 4,
                clonedPetModel.PrimaryPart.Size.Y * 4,
                clonedPetModel.PrimaryPart.Size.Z * 4
            )
        end
    end

    local primaryPart: BasePart = clonedPetModel.PrimaryPart :: BasePart
    if not primaryPart then repeat task.wait() until clonedPetModel.PrimaryPart; primaryPart = clonedPetModel.PrimaryPart :: BasePart end

    primaryPart.Position = plrRootPart.Position
end
--[[ @end_section Util Functions ]]


--[[ @section Constructor ]]
--[[
    @usage Handle pet following on the client.
    
    @return void
]]
local function constructorCallback()
    PetsHandlingGroup.PetStartFollowingOwner:onClientEvent(
        function(data)
            if not EquippedPetsCache[data.petId] then
                local plr = Players:GetPlayerByUserId(data.ownerId)
                if not plr then return end

                local plrChar: Model = plr.Character :: Model
                if not plrChar then repeat task.wait() until plr.Character; plrChar = plr.Character :: Model end
                
                local plrRootPart = plrChar:WaitForChild("HumanoidRootPart") :: BasePart

                addPetToWorkspace({ PetData = data.PetData, petId = data.petId }, plrRootPart)
            elseif EquippedPetsCache[data.petId] then return end

            -- Heartbeat loop while the pet is equipped.
            do
                local heartbeatConnection: RBXScriptConnection

                heartbeatConnection = RunService.Heartbeat:Connect(
                    function(deltaTime: number)
                        if not EquippedPetsCache[data.petId] then heartbeatConnection:Disconnect(); return end
                        if table.find(CurrentlyWalkingCache, data.petId) then return else table.insert(CurrentlyWalkingCache, data.petId) end

                        local plr = Players:GetPlayerByUserId(data.ownerId)
                        if not plr then return end

                        local plrChar: Model = plr.Character :: Model
                        if not plrChar then repeat task.wait() until plr.Character; plrChar = plr.Character :: Model end
                        
                        local plrRootPart = plrChar:WaitForChild("HumanoidRootPart") :: BasePart

                        local petModel = GamePetsFolder:FindFirstChild(data.petId) :: Model
                        if not petModel then heartbeatConnection:Disconnect(); return end

                        local petRootPart = petModel.PrimaryPart
                        if not petRootPart then return end

                        local RadiusData = RADIUS_MAP[data.PetData.PetStats.size]
                        if not RadiusData then return end

                        local angle = math.rad(RNG.betterRandomNumber({ min = 0, max = 360 }))
                        local distance = RNG.betterRandomNumber({ min = RadiusData.min, max = RadiusData.max })
                        local targetPosition = plrRootPart.Position + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)

                        -- Floor detection.
                        do
                            local rayOrigin = targetPosition
                            local rayDirection = Vector3.new(0, -1_000, 0)

                            local rayParams = RaycastParams.new()
                            rayParams.FilterType = Enum.RaycastFilterType.Exclude
                            rayParams.FilterDescendantsInstances = { plrChar }

                            for i: string, cachedModel: Model in pairs(EquippedPetsCache) do
                                local cachedPetModel = GamePetsFolder:FindFirstChild(i) :: Model
                                if not cachedPetModel then continue end

                                local OldFilter = rayParams.FilterDescendantsInstances; table.insert(OldFilter, cachedPetModel)
                                rayParams.FilterDescendantsInstances = OldFilter
                            end

                            local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
                            if not result then return end; targetPosition = result.Position + Vector3.new(0, petRootPart.Size.Y / 2, 0)
                        end

                        local isDoneAnimatingWalking = false

                        -- Walking connection handling.
                        do
                            local lookAtDirectionRotation: CFrame
                            local movementConnection: RBXScriptConnection
                            
                            movementConnection = RunService.Heartbeat:Connect(
                                function(deltaTime: number)
                                    if not petModel or not petModel.Parent then movementConnection:Disconnect(); return end

                                    local movingOffset = targetPosition - petRootPart.Position
                                    local speedOffset = PET_MUL_SPEED * (movingOffset.Magnitude / math.max(Vector3.new(movingOffset.X, 0, movingOffset.Z).Magnitude, 0.001))
                                    local step = (movingOffset.Unit * deltaTime) * speedOffset

                                    if not lookAtDirectionRotation then
                                        lookAtDirectionRotation = CFrame.lookAt(Vector3.zero, Vector3.new(movingOffset.Unit.X, 0, movingOffset.Unit.Z).Unit).Rotation
                                    end

                                    local smoothLookAtMoveDirRotation = petRootPart.CFrame.Rotation:Lerp(
                                        lookAtDirectionRotation,
                                        deltaTime * LOOK_AT_TIME_MUL
                                    )

                                    local wobbleRotation = CFrame.Angles(
                                        math.sin(time() * WOBBLE_TIME_MUL) * WOBBLE_ANGLE,
                                        0,
                                        0
                                    )

                                    local bobbleOffset = math.abs(math.sin(time() * WOBBLE_TIME_MUL)) * BOBBLE_HEIGHT

                                    petRootPart.CFrame = CFrame.new(
                                        petRootPart.Position.X + step.X,
                                        targetPosition.Y + bobbleOffset,
                                        petRootPart.Position.Z + step.Z
                                    ) * smoothLookAtMoveDirRotation * wobbleRotation

                                    -- Cleanup.
                                    do
                                        local readingOffset = CFrame.new(targetPosition.X, 0, targetPosition.Z).Position - CFrame.new(petRootPart.Position.X, 0, petRootPart.Position.Z).Position
                                        if readingOffset.Magnitude > 1 then return end; movementConnection:Disconnect()
                                        
                                        local lookPos = plrRootPart.Position - targetPosition
                                        local flatFeetLookPosVec = Vector3.new(lookPos.X, 0, lookPos.Z)

                                        local isDoneGoingToFloor = false

                                        -- Floor finishing movement.
                                        do
                                            local gotoFloorConnection: RBXScriptConnection

                                            gotoFloorConnection = RunService.Heartbeat:Connect(
                                                function(deltaTime: number)
                                                    local offset = targetPosition - petRootPart.Position

                                                    if not petModel or not petModel.Parent then gotoFloorConnection:Disconnect(); return end
                                                    if offset.Magnitude < 0.25 then gotoFloorConnection:Disconnect(); isDoneGoingToFloor = true; return end

                                                    petRootPart.CFrame = CFrame.new(petRootPart.Position + offset.Unit * deltaTime * LOOK_AT_TIME_MUL) * smoothLookAtMoveDirRotation
                                                end
                                            )
                                        end

                                        -- Look at owner.
                                        do
                                            local lookAtConnection: RBXScriptConnection

                                            lookAtConnection = RunService.Heartbeat:Connect(
                                                function(deltaTime: number)
                                                    if not petModel or not petModel.Parent then lookAtConnection:Disconnect(); return end

                                                    if petRootPart.CFrame.LookVector:Dot(flatFeetLookPosVec.Unit) > 0.999 then
                                                        repeat task.wait() until isDoneGoingToFloor
                                                        lookAtConnection:Disconnect(); isDoneAnimatingWalking = true
                                                        
                                                        return
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
                                    end
                                end
                            )
                        end

                        repeat task.wait() until isDoneAnimatingWalking

                        local randomWaitTime = RNG.betterRandomNumber(
                            {
                                min = RNG.betterRandomNumber({ min = 1, max = 3 }),
                                max = RNG.betterRandomNumber({ min = 3, max = 10 })
                            }
                        )

                        task.wait(randomWaitTime)

                        local foundPetIndex = table.find(CurrentlyWalkingCache, data.petId)
                        if foundPetIndex then table.remove(CurrentlyWalkingCache, foundPetIndex) end
                    end
                )
            end
        end
    )

    PetsHandlingGroup.RemovePetFromClient:onClientEvent(
        function(data)
            if not EquippedPetsCache[data] then return end

            EquippedPetsCache[data]:Destroy()
            EquippedPetsCache[data].Parent = nil
            EquippedPetsCache[data] = nil

            local foundWalkingCacheIndex = table.find(CurrentlyWalkingCache, data)
            if foundWalkingCacheIndex then table.remove(CurrentlyWalkingCache, foundWalkingCacheIndex) end
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]