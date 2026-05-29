--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local RNG = require(ReplicatedStorage.Libraries.NumberLibs.RNG)

local Data = require(ReplicatedStorage.DataAssets.Pets.Data)

local PetsHandlingGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.PetsHandling)
--[[ @end_section Imports ]]


type PetSchema = Data.PetSchema


--[[ @section Variables ]]
local AssetsFolder = workspace:WaitForChild("Assets") :: Folder
local AssetsPetsFolder = AssetsFolder:WaitForChild("Pets") :: Folder
local GameFolder = workspace:WaitForChild("Game") :: Folder
local GamePetsFolder = GameFolder:WaitForChild("Pets") :: Folder
local FieldsFolder = GameFolder:WaitForChild("Fields") :: Folder

local localPlayer = Players.LocalPlayer :: Player

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

local ENUM_LIST
= {
    Enum.NormalId.Top,
    Enum.NormalId.Bottom,
    Enum.NormalId.Left,
    Enum.NormalId.Right,
    Enum.NormalId.Front,
    Enum.NormalId.Back
}

local EquippedPetsCache: { [string]: Model } = {}
local CurrentlyWalkingCache: { string } = {}

local CachedFieldPets: { [string]: { petModel: Model, field: BasePart } } = {}
local AttackingPetsCache: { string } = {}
--[[ @end_section Variables ]]


--[[ @section Color Functions ]]
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

--[[
    @usage Interpolate between colors.

    @param t number

    @return Color3
]]
local function mixedUnobtainableColor(t: number): Color3
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
--[[ @end_section Color Functions ]]


--[[ @section Util Functions ]]
--[[
    @usage Add pet to the game world.
    
    @param EquippingData { PetData: PetSchema, petId: string }
    @param spawnPoint BasePart
    @param field BasePart?

    @return void
]]
local function addPetToWorkspace(EquippingData: { PetData: PetSchema, petId: string }, spawnPoint: BasePart, field: BasePart?): ()
    if field then if CachedFieldPets[EquippingData.petId] then return end
    else if EquippedPetsCache[EquippingData.petId] then return end end

    local petModel = AssetsPetsFolder:WaitForChild(EquippingData.PetData.petName) :: Model
    if not petModel.PrimaryPart then repeat task.wait() until petModel.PrimaryPart end
    
    local clonedPetModel = petModel:Clone()
    clonedPetModel.Name = EquippingData.petId
    clonedPetModel.Parent = GamePetsFolder

    if field then CachedFieldPets[EquippingData.petId] = { petModel = clonedPetModel, field = field }
    else EquippedPetsCache[EquippingData.petId] = clonedPetModel end
    
    local petRootPart = clonedPetModel.PrimaryPart :: MeshPart
    petRootPart.CanCollide = false
    petRootPart.Anchored = true
    petRootPart.CastShadow = false

    if EquippingData.PetData.PetStats.size == "Worldbreaker" then
        clonedPetModel:ScaleTo(16)
    elseif EquippingData.PetData.PetStats.size == "Gigantic" then
        clonedPetModel:ScaleTo(8)
    elseif EquippingData.PetData.PetStats.size == "Huge" then
        clonedPetModel:ScaleTo(4)
    end

    if EquippingData.PetData.PetStats.color == "Diamond" then
        local petHighlight = Instance.new("Highlight")
        petHighlight.Parent = petRootPart
        petHighlight.OutlineTransparency = 1
        petHighlight.FillTransparency = 0.4
        petHighlight.FillColor = Color3.fromRGB(0, 225, 255)
        petHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
    elseif EquippingData.PetData.PetStats.color == "Gold" then
        local petHighlight = Instance.new("Highlight")
        petHighlight.Parent = petRootPart
        petHighlight.OutlineTransparency = 1
        petHighlight.FillTransparency = 0.4
        petHighlight.FillColor = Color3.fromRGB(255, 208, 0)
        petHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
    end

    -- Handle ra/gl textures and the rb/gl/ra colors.
    do
        local Textures: { Texture } = {}
        local petHighlight: Highlight?

        if EquippingData.PetData.PetStats.color == "Glitched" or EquippingData.PetData.PetStats.color == "Rainbow" then
            petHighlight = Instance.new("Highlight")
            petHighlight.Parent = petRootPart
            petHighlight.OutlineTransparency = 1
            petHighlight.FillTransparency = 0.4
            petHighlight.DepthMode = Enum.HighlightDepthMode.Occluded

            for i = 1, 6 do
                local newTexture = Instance.new("Texture")
                newTexture.Texture = "rbxasset://textures/water/normal_21.dds"
                newTexture.Color3 = Color3.fromRGB(0, 0, 0)
                newTexture.Parent = petRootPart
                newTexture.Face = ENUM_LIST[i]

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

        if EquippingData.PetData.PetStats.color == "Glitched" or EquippingData.PetData.PetStats.color == "Rainbow" then
            local textureOffset = 0
            local colorOffset = 0

            local whileEquippedConnection: RBXScriptConnection

            whileEquippedConnection = RunService.Heartbeat:Connect(
                function(deltaTime: number): ()
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
                        if petHighlight then petHighlight.FillColor = glitchedColor(colorOffset) end
                    elseif EquippingData.PetData.PetStats.color == "Rainbow" then
                        for i: number, texture: Texture in pairs(Textures) do texture.OffsetStudsU = textureOffset; texture.OffsetStudsV = textureOffset end
                        if petHighlight then petHighlight.FillColor = Color3.fromHSV(colorOffset, 0.75, 1) end
                    end
                end
            )
        end
    end

    petRootPart.Position = spawnPoint.Position
end

--[[
    @usage Move the pet to the target position.

    @param petModel Model
    @param targetPosition Vector3
    @param lookAtPart BasePart
    @param petRootPart BasePart

    @return void
]]
local function movePetTo(petModel: Model, targetPosition: Vector3, lookAtPart: BasePart, petRootPart: BasePart): ()
    local isDoneAnimatingWalking = false
    local timeSinceStartedWalking = 0
    local direction = 0

    -- Walking connection handling.
    do
        local lookAtDirectionRotation: CFrame
        local movementConnection: RBXScriptConnection
        
        movementConnection = RunService.Heartbeat:Connect(
            function(deltaTime: number): ()
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
                    if readingOffset.Magnitude > 0.5 then return end; movementConnection:Disconnect()
                    
                    local lookPos = lookAtPart.Position - copiedTargetPos
                    local flatFeetLookPosVec = Vector3.new(lookPos.X, 0, lookPos.Z)

                    local isDoneLookingAtLookAtPart = false
                    local isDoneGoingToFloor = false

                    -- Floor finishing movement.
                    do
                        local gotoFloorConnection: RBXScriptConnection

                        gotoFloorConnection = RunService.Heartbeat:Connect(
                            function(deltaTime: number): ()
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
                            function(deltaTime: number): ()
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

--[[
    @usage Raycast from the mouse position.
    
    @param plrChar Model

    @return (Instance?, RaycastResult<BasePart>?)
]]
local function raycastFromMouse(plrChar: Model): (Instance?, RaycastResult<BasePart>?)
    local mouseLoc = UserInputService:GetMouseLocation()
    local ray = workspace.CurrentCamera:ViewportPointToRay(mouseLoc.X, mouseLoc.Y)

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = { plrChar }

    local result = workspace:Raycast(
        ray.Origin,
        ray.Direction * 1000,
        raycastParams
    )

    if result then return result.Instance, result else return nil :: any end
end
--[[ @end_section Util Functions ]]


--[[ @section Constructor ]]
--[[
    @usage Handle pet following on the client.
    
    @return void
]]
local function constructorCallback(): ()
    local localPlrChar = localPlayer.Character :: Model
    if not localPlrChar then repeat task.wait() until localPlayer.Character; localPlrChar = localPlayer.Character :: Model end

    UserInputService.InputEnded:Connect(
        function(input: InputObject, gameProcessed: boolean): ()
            if gameProcessed then return end; if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

            local targetInst, raycastResult = raycastFromMouse(localPlrChar)
            if not targetInst or not raycastResult then return end

            for i: string, CachedData: { petModel: Model, field: BasePart } in pairs(CachedFieldPets) do
                if targetInst.Name ~= i and (targetInst.Parent :: Instance).Name ~= i then continue end
                PetsHandlingGroup.StartAttackingPet:fireServer({ fieldName = CachedData.field.Name, petIdToAttack = i }); break
            end
        end
    )

    -- Networking connections.
    do
        PetsHandlingGroup.PetStartFollowingOwner:onClientEvent(
            function(data): ()
                if not GamePetsFolder:FindFirstChild(data.petId) then
                    local foundWalkingCacheIndex = table.find(CurrentlyWalkingCache, data.petId)
                    if foundWalkingCacheIndex then table.remove(CurrentlyWalkingCache, foundWalkingCacheIndex) end

                    local foundAttackingCacheIndex = table.find(AttackingPetsCache, data.petId)
                    if foundAttackingCacheIndex then table.remove(AttackingPetsCache, foundAttackingCacheIndex) end

                    local plr = Players:GetPlayerByUserId(data.ownerId)
                    if not plr then return end

                    local plrChar: Model = plr.Character :: Model
                    if not plrChar then repeat task.wait() until plr.Character; plrChar = plr.Character :: Model end
                    
                    local plrRootPart = plrChar:WaitForChild("HumanoidRootPart") :: BasePart

                    if GamePetsFolder:FindFirstChild(data.petId) then return end
                    addPetToWorkspace({ PetData = data.PetData, petId = data.petId }, plrRootPart)
                elseif GamePetsFolder:FindFirstChild(data.petId) then return end

                -- Loop while the pet is equipped to move it around it's owner.
                task.spawn(
                    function(): ()
                        while true do
                            if table.find(AttackingPetsCache, data.petId) then repeat task.wait() until not table.find(AttackingPetsCache, data.petId) end

                            if table.find(CurrentlyWalkingCache, data.petId) then repeat task.wait() until not table.find(CurrentlyWalkingCache, data.petId) end
                            table.insert(CurrentlyWalkingCache, data.petId)

                            local plr = Players:GetPlayerByUserId(data.ownerId)
                            if not plr then return end

                            local plrChar: Model = plr.Character :: Model
                            if not plrChar then repeat task.wait() until plr.Character; plrChar = plr.Character :: Model end
                            
                            local plrRootPart = plrChar:WaitForChild("HumanoidRootPart") :: BasePart

                            local petModel = GamePetsFolder:FindFirstChild(data.petId) :: Model
                            if not petModel then break end

                            local petRootPart = petModel.PrimaryPart :: BasePart
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

                            repeat task.wait() until not table.find(CurrentlyWalkingCache, data.petId) or not petModel; task.wait(randomWaitTime)
                        end
                    end
                )
            end
        )

        PetsHandlingGroup.RemovePetFromClient:onClientEvent(
            function(data): ()
                if EquippedPetsCache[data] then EquippedPetsCache[data]:Destroy(); EquippedPetsCache[data] = nil end
                if CachedFieldPets[data] then CachedFieldPets[data].petModel:Destroy(); CachedFieldPets[data] = nil end

                local foundWalkingCacheIndex = table.find(CurrentlyWalkingCache, data)
                if foundWalkingCacheIndex then table.remove(CurrentlyWalkingCache, foundWalkingCacheIndex) end

                local foundAttackingCacheIndex = table.find(AttackingPetsCache, data)
                if foundAttackingCacheIndex then table.remove(AttackingPetsCache, foundAttackingCacheIndex) end
            end
        )

        PetsHandlingGroup.AddPetToClientField:onClientEvent(
            function(data): ()
                if GamePetsFolder:FindFirstChild(data.generatedId) then return end
                local field = FieldsFolder:WaitForChild(data.fieldName) :: BasePart

                addPetToWorkspace({ PetData = data.PetData, petId = data.generatedId }, field, field)

                task.spawn(
                    function(): ()
                        while true do
                            if table.find(AttackingPetsCache, data.generatedId) then repeat task.wait() until not table.find(AttackingPetsCache, data.generatedId) end

                            if table.find(CurrentlyWalkingCache, data.generatedId) then repeat task.wait() until not table.find(CurrentlyWalkingCache, data.generatedId) end
                            table.insert(CurrentlyWalkingCache, data.generatedId)

                            local petModel = GamePetsFolder:FindFirstChild(data.generatedId) :: Model
                            if not petModel then break end

                            local petRootPart = petModel.PrimaryPart :: BasePart
                            if not petRootPart then return end

                            local randomX = RNG.betterRandomNumber({ min = -field.Size.X / 2, max = field.Size.X / 2 })
                            local randomZ = RNG.betterRandomNumber({ min = -field.Size.Z / 2, max = field.Size.Z / 2 })

                            local targetPos = field.CFrame * CFrame.new(randomX, 0, randomZ).Position
                            movePetTo(petModel, targetPos, petRootPart, petRootPart)

                            local randomWaitTime = RNG.betterRandomNumber(
                                {
                                    min = RNG.betterRandomNumber({ min = 1, max = 3 }),
                                    max = RNG.betterRandomNumber({ min = 3, max = 10 })
                                }
                            )

                            repeat task.wait() until not table.find(CurrentlyWalkingCache, data.generatedId) or not petModel; task.wait(randomWaitTime)
                        end
                    end
                )
            end
        )

        PetsHandlingGroup.StartAttackingPet:onClientEvent(
            function(data): ()
                if table.find(AttackingPetsCache, data.attackingPetId) or table.find(AttackingPetsCache, data.targetPetId) then return end

                local attackingPetModel = GamePetsFolder:WaitForChild(data.attackingPetId) :: Model
                local targetPetModel = GamePetsFolder:WaitForChild(data.targetPetId) :: Model

                local attackingPetRootPart = attackingPetModel.PrimaryPart :: BasePart
                local targetPetRootPart = targetPetModel.PrimaryPart :: BasePart

                table.insert(AttackingPetsCache, data.attackingPetId)
                table.insert(AttackingPetsCache, data.targetPetId)

                repeat task.wait() until not table.find(CurrentlyWalkingCache, data.attackingPetId) or not attackingPetModel
                repeat task.wait() until not table.find(CurrentlyWalkingCache, data.targetPetId) or not targetPetModel

                -- Move the attacking pets to each other.
                do
                    local direction = (attackingPetRootPart.Position - targetPetRootPart.Position).Unit
                    local midpoint = (targetPetRootPart.Position + attackingPetRootPart.Position) / 2

                    movePetTo(attackingPetModel, midpoint + direction * (targetPetRootPart.Size.Z / 2 + 1), targetPetRootPart, attackingPetRootPart)
                    movePetTo(targetPetModel, midpoint - direction * (attackingPetRootPart.Size.Z / 2 + 1), attackingPetRootPart, targetPetRootPart)
                end

                PetsHandlingGroup.ServerStartDealingDamage:fireServer(
                    {
                        attackingPetId = data.attackingPetId,
                        targetPetId = data.targetPetId,
                        fieldName = data.fieldName
                    }
                )
            end
        )

        PetsHandlingGroup.RemovePetFromClientAttackingCache:onClientEvent(
            function(data): ()
                local foundAttackingCacheIndex = table.find(AttackingPetsCache, data)
                if foundAttackingCacheIndex then table.remove(AttackingPetsCache, foundAttackingCacheIndex) end
            end
        )
    end
end

return constructorCallback
--[[ @end_section Constructor ]]