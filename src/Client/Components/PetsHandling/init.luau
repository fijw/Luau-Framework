--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local PetMoving = require(script.PetMoving)
local PetSpawning = require(script.PetSpawning)

local RNG = require(ReplicatedStorage.Libraries.NumberLibs.RNG)

local Data = require(ReplicatedStorage.DataAssets.Pets.Data)

local PetsHandlingGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.PetsHandling)
--[[ @end_section Imports ]]


type PetSchema = Data.PetSchema


--[[ @section Variables ]]
local GameFolder = workspace:WaitForChild("Game") :: Folder
local AssetsFolder = workspace:WaitForChild("Assets") :: Folder
local AssetsPetsFolder = AssetsFolder:WaitForChild("Pets") :: Folder
local GamePetsFolder = GameFolder:WaitForChild("Pets") :: Folder
local FieldsFolder = GameFolder:WaitForChild("Fields") :: Folder

local localPlayer = Players.LocalPlayer :: Player

local RADIUS_MAP
= {
    Worldbreaker = { min = 5 * 18, max = 20 * 5 },
    Gigantic = { min = 5 * 12, max = 20 * 3 },
    Huge = { min = 5 * 6, max = 20 * 2 },
    Default = { min = 5, max = 20 }
}

local EquippedPetsCache: { [string]: Model } = {}
local CurrentlyWalkingCache: { string } = {}

local CachedFieldPets: { [string]: { petModel: Model, field: BasePart } } = {}
local AttackingPetsCache: { string } = {}
--[[ @end_section Variables ]]


--[[ @section Util Functions ]]
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
local function constructorCallback()
    local localPlrChar = localPlayer.Character :: Model
    if not localPlrChar then repeat task.wait() until localPlayer.Character; localPlrChar = localPlayer.Character :: Model end

    UserInputService.InputEnded:Connect(
        function(input: InputObject, gameProcessed: boolean)
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
            function(data)
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

                    PetSpawning(
                        CachedFieldPets,
                        EquippedPetsCache,
                        GamePetsFolder,
                        AssetsPetsFolder,
                        { PetData = data.PetData, petId = data.petId },
                        plrRootPart
                    )
                elseif GamePetsFolder:FindFirstChild(data.petId) then return end

                -- Loop while the pet is equipped to move it around it's owner.
                task.spawn(
                    function()
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

                            PetMoving(
                                CurrentlyWalkingCache,
                                EquippedPetsCache,
                                GamePetsFolder,
                                CachedFieldPets,
                                petModel,
                                targetPosition,
                                plrRootPart,
                                petRootPart
                            )

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
            function(data)
                if EquippedPetsCache[data] then EquippedPetsCache[data]:Destroy(); EquippedPetsCache[data] = nil end
                if CachedFieldPets[data] then CachedFieldPets[data].petModel:Destroy(); CachedFieldPets[data] = nil end

                local foundWalkingCacheIndex = table.find(CurrentlyWalkingCache, data)
                if foundWalkingCacheIndex then table.remove(CurrentlyWalkingCache, foundWalkingCacheIndex) end

                local foundAttackingCacheIndex = table.find(AttackingPetsCache, data)
                if foundAttackingCacheIndex then table.remove(AttackingPetsCache, foundAttackingCacheIndex) end
            end
        )

        PetsHandlingGroup.AddPetToClientField:onClientEvent(
            function(data)
                if GamePetsFolder:FindFirstChild(data.generatedId) then return end
                local field = FieldsFolder:WaitForChild(data.fieldName) :: BasePart

                PetSpawning(
                    CachedFieldPets,
                    EquippedPetsCache,
                    GamePetsFolder,
                    AssetsPetsFolder,
                    { PetData = data.PetData, petId = data.generatedId },
                    field,
                    field
                )

                task.spawn(
                    function()
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

                            PetMoving(
                                CurrentlyWalkingCache,
                                EquippedPetsCache,
                                GamePetsFolder,
                                CachedFieldPets,
                                petModel,
                                targetPos,
                                petRootPart,
                                petRootPart
                            )

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
            function(data)
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

                    PetMoving(
                        CurrentlyWalkingCache,
                        EquippedPetsCache,
                        GamePetsFolder,
                        CachedFieldPets,
                        attackingPetModel,
                        midpoint + direction * (targetPetRootPart.Size.Z / 2),
                        targetPetRootPart,
                        attackingPetRootPart
                    )

                    PetMoving(
                        CurrentlyWalkingCache,
                        EquippedPetsCache,
                        GamePetsFolder,
                        CachedFieldPets,
                        targetPetModel,
                        midpoint - direction * (attackingPetRootPart.Size.Z / 2),
                        attackingPetRootPart,
                        targetPetRootPart
                    )
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
            function(data)
                local foundAttackingCacheIndex = table.find(AttackingPetsCache, data)
                if foundAttackingCacheIndex then table.remove(AttackingPetsCache, foundAttackingCacheIndex) end
            end
        )
    end
end

return constructorCallback
--[[ @end_section Constructor ]]