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
local localPlr = Players.LocalPlayer

local GameFolder = workspace:WaitForChild("Game") :: Folder
local PetsFolder = GameFolder:WaitForChild("Pets") :: Folder

local PET_MUL_SPEED = 50
local WOBBLE_TIME_MUL = 10
local LOOK_AT_TIME_MUL = 6
local WOBBLE_ANGLE = math.rad(1.025)

local RADIUS_MAP
= {
    Gigantic = { min = 5 * 12, max = 20 * 3 },
    Huge = { min = 5 * 6, max = 20 * 2 },
    Default = { min = 5, max = 20 }
}

local CurrentlyMovingPets: { string } = {}
--[[ @end_section Variables ]]


--[[ @section Constructor ]]
--[[
    @usage Handle pet following on the client.
    
    @return void
]]
local function constructorCallback()
    local plrChar: Model = localPlr.Character :: Model
    if not plrChar then repeat task.wait() until localPlr.Character; plrChar = localPlr.Character :: Model end
    
    local plrRootPart = plrChar:WaitForChild("HumanoidRootPart") :: BasePart

    PetsHandlingGroup.UpdatePetFollowingPosition:onClientEvent(
        function(data)
            if table.find(CurrentlyMovingPets, data.petId) then return end
            if not data.instaTravel then table.insert(CurrentlyMovingPets, data.petId) end

            local petModel = PetsFolder:FindFirstChild(data.petId) :: Model
            if not petModel then return end

            local petRootPart = petModel.PrimaryPart
            if not petRootPart then return end

            if data.instaTravel then petRootPart.Position = plrRootPart.Position; return end

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

                for i: string, CacheData: PetSchema in pairs(data.CachedEquippedPets) do
                    local cachedPetModel = PetsFolder:FindFirstChild(i) :: Model
                    if not cachedPetModel then continue end

                    local OldFilter = rayParams.FilterDescendantsInstances; table.insert(OldFilter, cachedPetModel)
                    rayParams.FilterDescendantsInstances = OldFilter
                end

                local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
                if not result then return end; targetPosition = result.Position + Vector3.new(0, petRootPart.Size.Y / 2, 0)
            end

            -- Walking connection handling.
            do
                local movementConnection: RBXScriptConnection
                
                movementConnection = RunService.Heartbeat:Connect(
                    function(deltaTime: number)
                        if not petModel or not petModel.Parent then movementConnection:Disconnect(); return end

                        local offset = targetPosition - petRootPart.Position
                        local speedOffset = PET_MUL_SPEED * (offset.Magnitude / math.max(Vector3.new(offset.X, 0, offset.Z).Magnitude, 0.001))
                        local step = (offset.Unit * deltaTime) * speedOffset

                        local smoothLookAtMoveDirRotation = petRootPart.CFrame.Rotation:Lerp(
                            CFrame.lookAt(Vector3.zero, Vector3.new(offset.Unit.X, 0, offset.Unit.Z).Unit).Rotation,
                            deltaTime * LOOK_AT_TIME_MUL
                        )

                        local wobbleRotation = CFrame.Angles(
                            math.sin(time() * WOBBLE_TIME_MUL) * WOBBLE_ANGLE,
                            0,
                            0
                        )

                        petRootPart.CFrame = CFrame.new(petRootPart.Position + step) * smoothLookAtMoveDirRotation * wobbleRotation

                        -- Cleanup.
                        do
                            if offset.Magnitude > 1 then return end; movementConnection:Disconnect()
                            
                            local lookPos = plrRootPart.Position - petRootPart.Position
                            local flatFeetVec = Vector3.new(lookPos.X, 0, lookPos.Z)

                            local lookAtConnection: RBXScriptConnection

                            lookAtConnection = RunService.Heartbeat:Connect(
                                function(deltaTime: number)
                                    if not petModel or not petModel.Parent then lookAtConnection:Disconnect(); return end

                                    if petRootPart.CFrame.LookVector:Dot(flatFeetVec.Unit) > 0.999 then
                                        local foundPetIndex = table.find(CurrentlyMovingPets, data.petId)
                                        if foundPetIndex then table.remove(CurrentlyMovingPets, foundPetIndex) end

                                        lookAtConnection:Disconnect()

                                        return
                                    end

                                    local smoothLookAtPlrDirRotation = petRootPart.CFrame.Rotation:Lerp(
                                        CFrame.lookAt(
                                            Vector3.zero,
                                            flatFeetVec.Unit
                                        ).Rotation,

                                        deltaTime * LOOK_AT_TIME_MUL
                                    )

                                    petRootPart.CFrame = CFrame.new(petRootPart.Position) * smoothLookAtPlrDirRotation
                                end
                            )
                        end
                    end
                )
            end
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]