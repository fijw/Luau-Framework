--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RNG = require(ReplicatedStorage.Libraries.NumberLibs.RNG)

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
local LOOK_AT_TIME_MUL = 10
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


--[[ @section Color Functions ]]
--[[
    @usage Interpolate between colors.

    @param t number

    @return Color3
]]
local function radioactiveColor(t: number): Color3
	if t < 0.25 then
		return Color3.new(0, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), t / 0.25)
	elseif t < 0.5 then
		return Color3.fromRGB(0, 255, 0):Lerp(Color3.new(0, 0, 0), (t - 0.25) / 0.25)
	elseif t < 0.75 then
		return Color3.new(0, 0, 0):Lerp(Color3.fromRGB(255, 255, 0), (t - 0.5) / 0.25)
	else
		return Color3.fromRGB(255, 255, 0):Lerp(Color3.new(0, 0, 0), (t - 0.75) / 0.25)
	end
end

--[[
    @usage Interpolate between colors.

    @param t number

    @return Color3
]]
local function glitchedColor(t: number): Color3
	if t < 0.5 then
		return Color3.new(0, 0, 0):Lerp(Color3.fromRGB(170, 0, 255), t / 0.5)
	else
		return Color3.fromRGB(170, 0, 255):Lerp(Color3.new(0, 0, 0), (t - 0.5) / 0.5)
	end
end
--[[ @end_section Color Functions ]]


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
    if not petModel.PrimaryPart then repeat task.wait() until petModel.PrimaryPart end
    
    local clonedPetModel = petModel:Clone()
    clonedPetModel.Name = EquippingData.petId
    clonedPetModel.Parent = GamePetsFolder

    EquippedPetsCache[EquippingData.petId] = clonedPetModel; local petRootPart = clonedPetModel.PrimaryPart :: BasePart

    if EquippingData.PetData.PetStats.size == "Worldbreaker" then
        petRootPart.Size
        = Vector3.new(
            petRootPart.Size.X * 16,
            petRootPart.Size.Y * 16,
            petRootPart.Size.Z * 16
        )
    elseif EquippingData.PetData.PetStats.size == "Gigantic" then
        petRootPart.Size
        = Vector3.new(
            petRootPart.Size.X * 8,
            petRootPart.Size.Y * 8,
            petRootPart.Size.Z * 8
        )
    elseif EquippingData.PetData.PetStats.size == "Huge" then
        petRootPart.Size
        = Vector3.new(
            petRootPart.Size.X * 4,
            petRootPart.Size.Y * 4,
            petRootPart.Size.Z * 4
        )
    end
    
    if EquippingData.PetData.PetStats.color == "Glitched" then
        for i = 1, 6 do
            local newEffect = Instance.new("ParticleEmitter")
            newEffect.Parent = petRootPart
            newEffect.Color = ColorSequence.new(Color3.fromRGB(170, 0, 255), Color3.fromRGB(170, 0, 255))
            newEffect.Lifetime = NumberRange.new(0.25, 0.5)
            newEffect.Rate = 5
            newEffect.Size = NumberSequence.new(0.25, 0.25)
            newEffect.Brightness = 3
            newEffect.Texture = "http://www.roblox.com/asset/?id=6347925"

            if EquippingData.PetData.PetStats.size == "Worldbreaker" then
                newEffect.Size = NumberSequence.new(0.25 * 16, 0.25 * 16)
                newEffect.Speed = NumberRange.new(newEffect.Speed.Min * 16, newEffect.Speed.Max * 16)
            elseif EquippingData.PetData.PetStats.size == "Gigantic" then
                newEffect.Size = NumberSequence.new(0.25 * 8, 0.25 * 8)
                newEffect.Speed = NumberRange.new(newEffect.Speed.Min * 8, newEffect.Speed.Max * 8)
            elseif EquippingData.PetData.PetStats.size == "Huge" then
                newEffect.Size = NumberSequence.new(0.25 * 4, 0.25 * 4)
                newEffect.Speed = NumberRange.new(newEffect.Speed.Min * 4, newEffect.Speed.Max * 4)
            end

            if i == 1 then newEffect.EmissionDirection = Enum.NormalId.Top
            elseif i == 2 then newEffect.EmissionDirection = Enum.NormalId.Bottom
            elseif i == 3 then newEffect.EmissionDirection = Enum.NormalId.Left
            elseif i == 4 then newEffect.EmissionDirection = Enum.NormalId.Right
            elseif i == 5 then newEffect.EmissionDirection = Enum.NormalId.Front
            elseif i == 6 then newEffect.EmissionDirection = Enum.NormalId.Back end

            local clonedNewEffect = newEffect:Clone()
            clonedNewEffect.Parent = petRootPart
            clonedNewEffect.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0))
        end
    elseif EquippingData.PetData.PetStats.color == "Radioactive" then
        for i = 1, 6 do
            local newEffect = Instance.new("ParticleEmitter")
            newEffect.Parent = petRootPart
            newEffect.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0))
            newEffect.Lifetime = NumberRange.new(0.25, 0.5)
            newEffect.Rate = 5
            newEffect.Size = NumberSequence.new(0.25, 0.25)
            newEffect.Brightness = 3
            newEffect.Texture = "http://www.roblox.com/asset/?id=6347925"

            if EquippingData.PetData.PetStats.size == "Worldbreaker" then
                newEffect.Size = NumberSequence.new(0.25 * 16, 0.25 * 16)
                newEffect.Speed = NumberRange.new(newEffect.Speed.Min * 16, newEffect.Speed.Max * 16)
            elseif EquippingData.PetData.PetStats.size == "Gigantic" then
                newEffect.Size = NumberSequence.new(0.25 * 8, 0.25 * 8)
                newEffect.Speed = NumberRange.new(newEffect.Speed.Min * 8, newEffect.Speed.Max * 8)
            elseif EquippingData.PetData.PetStats.size == "Huge" then
                newEffect.Size = NumberSequence.new(0.25 * 4, 0.25 * 4)
                newEffect.Speed = NumberRange.new(newEffect.Speed.Min * 4, newEffect.Speed.Max * 4)
            end

            if i == 1 then newEffect.EmissionDirection = Enum.NormalId.Top
            elseif i == 2 then newEffect.EmissionDirection = Enum.NormalId.Bottom
            elseif i == 3 then newEffect.EmissionDirection = Enum.NormalId.Left
            elseif i == 4 then newEffect.EmissionDirection = Enum.NormalId.Right
            elseif i == 5 then newEffect.EmissionDirection = Enum.NormalId.Front
            elseif i == 6 then newEffect.EmissionDirection = Enum.NormalId.Back end

            local clonedNewEffectOne = newEffect:Clone()
            clonedNewEffectOne.Parent = petRootPart
            clonedNewEffectOne.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 255, 0))

            local clonedNewEffectTwo = newEffect:Clone()
            clonedNewEffectTwo.Parent = petRootPart
            clonedNewEffectTwo.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 255, 0))
        end
    elseif EquippingData.PetData.PetStats.color == "broken_mix" then
        for i = 1, 6 do
            local newEffect = Instance.new("ParticleEmitter")
            newEffect.Parent = petRootPart
            newEffect.Color = ColorSequence.new(Color3.fromRGB(0, 0, 0), Color3.fromRGB(0, 0, 0))
            newEffect.Lifetime = NumberRange.new(0.25, 0.5)
            newEffect.Rate = 5
            newEffect.Size = NumberSequence.new(0.25, 0.25)
            newEffect.Brightness = 3
            newEffect.Texture = "http://www.roblox.com/asset/?id=6347925"

            if EquippingData.PetData.PetStats.size == "Worldbreaker" then
                newEffect.Size = NumberSequence.new(0.25 * 16, 0.25 * 16)
                newEffect.Speed = NumberRange.new(newEffect.Speed.Min * 16, newEffect.Speed.Max * 16)
            elseif EquippingData.PetData.PetStats.size == "Gigantic" then
                newEffect.Size = NumberSequence.new(0.25 * 8, 0.25 * 8)
                newEffect.Speed = NumberRange.new(newEffect.Speed.Min * 8, newEffect.Speed.Max * 8)
            elseif EquippingData.PetData.PetStats.size == "Huge" then
                newEffect.Size = NumberSequence.new(0.25 * 4, 0.25 * 4)
                newEffect.Speed = NumberRange.new(newEffect.Speed.Min * 4, newEffect.Speed.Max * 4)
            end

            if i == 1 then newEffect.EmissionDirection = Enum.NormalId.Top
            elseif i == 2 then newEffect.EmissionDirection = Enum.NormalId.Bottom
            elseif i == 3 then newEffect.EmissionDirection = Enum.NormalId.Left
            elseif i == 4 then newEffect.EmissionDirection = Enum.NormalId.Right
            elseif i == 5 then newEffect.EmissionDirection = Enum.NormalId.Front
            elseif i == 6 then newEffect.EmissionDirection = Enum.NormalId.Back end

            local clonedNewEffectOne = newEffect:Clone()
            clonedNewEffectOne.Parent = petRootPart
            clonedNewEffectOne.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 255, 0))

            local clonedNewEffectTwo = newEffect:Clone()
            clonedNewEffectTwo.Parent = petRootPart
            clonedNewEffectTwo.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 255, 0))

            local clonedNewEffect = newEffect:Clone()
            clonedNewEffect.Parent = petRootPart
            clonedNewEffect.Color = ColorSequence.new(Color3.fromRGB(170, 0, 255), Color3.fromRGB(170, 0, 255))
        end
    end

    -- Handle ra/gl textures and the rb/gl/ra colors.
    do
        local Textures: { Texture } = {}

        if EquippingData.PetData.PetStats.color == "Glitched"
            or EquippingData.PetData.PetStats.color == "Radioactive"
            or EquippingData.PetData.PetStats.color == "broken_mix"
        then
            for i = 1, 6 do
                local newTexture = Instance.new("Texture")
                newTexture.Texture = "rbxasset://textures/water/normal_21.dds"
                newTexture.Color3 = Color3.fromRGB(0, 0, 0)
                newTexture.Parent = petRootPart

                if i == 1 then newTexture.Face = Enum.NormalId.Top end
                if i == 2 then newTexture.Face = Enum.NormalId.Bottom end
                if i == 3 then newTexture.Face = Enum.NormalId.Left end
                if i == 4 then newTexture.Face = Enum.NormalId.Right end
                if i == 5 then newTexture.Face = Enum.NormalId.Front end
                if i == 6 then newTexture.Face = Enum.NormalId.Back end

                if EquippingData.PetData.PetStats.size == "Worldbreaker" then
                    newTexture.StudsPerTileU *= 16; newTexture.StudsPerTileV *= 16
                elseif EquippingData.PetData.PetStats.size == "Gigantic" then
                    newTexture.StudsPerTileU *= 8; newTexture.StudsPerTileV *= 8
                elseif EquippingData.PetData.PetStats.size == "Huge" then
                    newTexture.StudsPerTileU *= 4; newTexture.StudsPerTileV *= 4
                end

                table.insert(Textures, newTexture)
            end
        end

        if EquippingData.PetData.PetStats.color == "Glitched"
            or EquippingData.PetData.PetStats.color == "Radioactive"
            or EquippingData.PetData.PetStats.color == "Rainbow"
            or EquippingData.PetData.PetStats.color == "broken_mix"
        then
            local textureOffset = 0
            local colorOffset = 0

            local whileEquippedConnection: RBXScriptConnection

            whileEquippedConnection = RunService.Heartbeat:Connect(
                function(deltaTime: number)
                    if not EquippedPetsCache[EquippingData.petId] then whileEquippedConnection:Disconnect(); return end

                    if EquippingData.PetData.PetStats.size == "Worldbreaker" then textureOffset += deltaTime * 16
                    elseif EquippingData.PetData.PetStats.size == "Gigantic" then textureOffset += deltaTime * 8
                    elseif EquippingData.PetData.PetStats.size == "Huge" then textureOffset += deltaTime * 4
                    else textureOffset += deltaTime end
                    
                    colorOffset += deltaTime * 0.15; colorOffset %= 1

                    if EquippingData.PetData.PetStats.size == "Worldbreaker" then textureOffset %= 2 * 16
                    elseif EquippingData.PetData.PetStats.size == "Gigantic" then textureOffset %= 2 * 8
                    elseif EquippingData.PetData.PetStats.size == "Huge" then textureOffset %= 2 * 4
                    else textureOffset %= 2 end

                    if EquippingData.PetData.PetStats.color == "Glitched" then
                        for i: number, texture: Texture in pairs(Textures) do texture.OffsetStudsU = textureOffset; texture.OffsetStudsV = textureOffset end
                        petRootPart.Color = glitchedColor(colorOffset)
                    elseif EquippingData.PetData.PetStats.color == "broken_mix" then
                        for i: number, texture: Texture in pairs(Textures) do texture.OffsetStudsU = textureOffset; texture.OffsetStudsV = textureOffset end
                        petRootPart.Color = radioactiveColor(colorOffset):Lerp(glitchedColor(colorOffset), 0.5)
                    elseif EquippingData.PetData.PetStats.color == "Radioactive" then
                        for i: number, texture: Texture in pairs(Textures) do texture.OffsetStudsU = textureOffset; texture.OffsetStudsV = textureOffset end
                        petRootPart.Color = radioactiveColor(colorOffset)
                    elseif EquippingData.PetData.PetStats.color == "Rainbow" then petRootPart.Color = Color3.fromHSV(colorOffset, 0.75, 1) end
                end
            )
        end
    end

    petRootPart.Position = plrRootPart.Position
end

--[[
    @usage Move the pet to the target position.

    @param petModel Model
    @param targetPosition Vector3
    @param plrRootPart BasePart
    @param petRootPart BasePart

    @return void
]]
local function movePetTo(petModel: Model, targetPosition: Vector3, plrRootPart: BasePart, petRootPart: BasePart)
    local isDoneAnimatingWalking = false
    local timeSinceStartedWalking = 0

    -- Walking connection handling.
    do
        local lookAtDirectionRotation: CFrame
        local movementConnection: RBXScriptConnection
        
        movementConnection = RunService.Heartbeat:Connect(
            function(deltaTime: number)
                if not petModel or not petModel.Parent then movementConnection:Disconnect(); return end
                timeSinceStartedWalking += 0.005

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

                if not lookAtDirectionRotation then
                    lookAtDirectionRotation = CFrame.lookAt(Vector3.zero, Vector3.new(movingOffset.Unit.X, 0, movingOffset.Unit.Z).Unit).Rotation
                end

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
                    if readingOffset.Magnitude > 1 then return end; movementConnection:Disconnect()
                    
                    local lookPos = plrRootPart.Position - copiedTargetPos
                    local flatFeetLookPosVec = Vector3.new(lookPos.X, 0, lookPos.Z)

                    local isDoneGoingToFloor = false

                    -- Floor finishing movement.
                    do
                        local gotoFloorConnection: RBXScriptConnection

                        gotoFloorConnection = RunService.Heartbeat:Connect(
                            function(deltaTime: number)
                                local floorFeetOffset = CFrame.new(0, copiedTargetPos.Y, 0).Position - CFrame.new(0, petRootPart.Position.Y, 0).Position

                                if not petModel or not petModel.Parent then gotoFloorConnection:Disconnect(); return end
                                if floorFeetOffset.Magnitude < 0.25 then gotoFloorConnection:Disconnect(); isDoneGoingToFloor = true; return end

                                petRootPart.CFrame = CFrame.new(petRootPart.Position + floorFeetOffset.Unit * deltaTime * LOOK_AT_TIME_MUL) * smoothLookAtMoveDirRotation
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

    local foundWalkingIndex = table.find(CurrentlyWalkingCache, petModel.Name)
    if foundWalkingIndex then table.remove(CurrentlyWalkingCache, foundWalkingIndex) end
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
            if not GamePetsFolder:FindFirstChild(data.petId) then
                local plr = Players:GetPlayerByUserId(data.ownerId)
                if not plr then return end

                local plrChar: Model = plr.Character :: Model
                if not plrChar then repeat task.wait() until plr.Character; plrChar = plr.Character :: Model end
                
                local plrRootPart = plrChar:WaitForChild("HumanoidRootPart") :: BasePart

                if GamePetsFolder:FindFirstChild(data.petId) then return end
                addPetToWorkspace({ PetData = data.PetData, petId = data.petId }, plrRootPart)
            elseif GamePetsFolder:FindFirstChild(data.petId) then return end

            -- Heartbeat loop while the pet is equipped.
            do
                task.spawn(
                    function()
                        while true do
                            table.insert(CurrentlyWalkingCache, data.petId)

                            local plr = Players:GetPlayerByUserId(data.ownerId)
                            if not plr then return end

                            local plrChar: Model = plr.Character :: Model
                            if not plrChar then repeat task.wait() until plr.Character; plrChar = plr.Character :: Model end
                            
                            local plrRootPart = plrChar:WaitForChild("HumanoidRootPart") :: BasePart

                            local petModel = GamePetsFolder:FindFirstChild(data.petId) :: Model
                            if not petModel then break end

                            local petRootPart = petModel.PrimaryPart
                            if not petRootPart then return end

                            local RadiusData = RADIUS_MAP[data.PetData.PetStats.size]
                            if not RadiusData then return end

                            local angle = math.rad(RNG.betterRandomNumber({ min = 0, max = 360 }))
                            local distance = RNG.betterRandomNumber({ min = RadiusData.min, max = RadiusData.max })
                            local targetPosition = plrRootPart.Position + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)

                            movePetTo(petModel, targetPosition, plrRootPart, petRootPart)

                            local randomWaitTime = RNG.betterRandomNumber(
                                {
                                    min = RNG.betterRandomNumber({ min = 1, max = 3 }),
                                    max = RNG.betterRandomNumber({ min = 3, max = 10 })
                                }
                            )

                            repeat task.wait() until not table.find(CurrentlyWalkingCache, data.petId); task.wait(randomWaitTime)
                        end
                    end
                )
            end
        end
    )

    PetsHandlingGroup.RemovePetFromClient:onClientEvent(
        function(data)
            -- Remove from equipped pets cache.
            do
                if not EquippedPetsCache[data] then return end

                EquippedPetsCache[data]:Destroy()
                EquippedPetsCache[data].Parent = nil
                EquippedPetsCache[data] = nil
            end

            local foundWalkingCacheIndex = table.find(CurrentlyWalkingCache, data)
            if foundWalkingCacheIndex then table.remove(CurrentlyWalkingCache, foundWalkingCacheIndex) end
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]