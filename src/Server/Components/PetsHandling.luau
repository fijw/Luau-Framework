--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local Data = require(ReplicatedStorage.Assets.Pets.Data)
local RNG = require(ReplicatedStorage.Libraries.RNG)

local TweensLib = require(ReplicatedStorage.Libraries.TweensLib)
local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local Stackentory = require(ServerScriptService.Libraries.DataLibs.Stackentory)
local StackingLib = require(ServerScriptService.Libraries.DataLibs.Stackentory.Stacking)

local PetsHandlingGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.PetsHandling)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type PetSchema = Data.PetSchema
type InventoryClass = Stackentory.InventoryClass
type HandledTween = TweensLib.HandledTween

--[[ @generic D Data type. ]]
type StackClass<D> = StackingLib.StackClass<D>
--[[ @end_section Types ]]


--[[ @section Variables ]]
local CachedEquippedPets: { [Player]: { [string]: { PetData: PetSchema, model: Model } } } = {}

local RADIUS_MAP
= {
    Gigantic = { min = 5 * 12, max = 20 * 3 },
    Huge = { min = 5 * 6, max = 20 * 2 },
    Default = { min = 5, max = 20 }
}

local PET_MUL_SPEED = 50
local TIME_MUL = 8
local WOBBLE_ANGLE = math.rad(1.25)
--[[ @end_section Variables ]]


--[[
    @TODO

    FIX THE WEIRD ASS AFTER-WADDLE CUZ OF
        if offset.Magnitude > 0.1 then return end
    (i think at least lol)
]]
--[[ @section Utility Functions ]]
--[[
    @usage Make the pet follow the player.

    @param petModel Model
    @param PetData PetSchema
    @param plr Player
    @param plrRootPart BasePart
    @param plrChar Model

    @return void
]]
local function followOwner(petModel: Model, PetData: PetSchema, plr: Player, plrRootPart: BasePart, plrChar: Model)
    local petRootPart = petModel.PrimaryPart
    if not petRootPart then return end

    petRootPart.CFrame = plrRootPart.CFrame

    local RadiusData = RADIUS_MAP[PetData.PetStats.size]
    if not RadiusData then return end

    while true do
        if not petModel or not petModel.Parent then break end

        local angle = math.rad(RNG.betterRandomNumber({ min = 0, max = 360 }))
        local distance = RNG.betterRandomNumber({ min = RadiusData.min, max = RadiusData.max })
        local targetPosition = plrRootPart.Position + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)

        -- Floor detection.
        do
            local rayOrigin = targetPosition + Vector3.new(0, 50, 0)
            local rayDirection = Vector3.new(0, -200, 0)

            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Exclude
            rayParams.FilterDescendantsInstances = { plrChar }

            for i: string, CacheData: { PetData: PetSchema, model: Model } in pairs(CachedEquippedPets[plr]) do
                local OldFilter = rayParams.FilterDescendantsInstances; table.insert(OldFilter, CacheData.model)
                rayParams.FilterDescendantsInstances = OldFilter
            end

            local result = workspace:Raycast(rayOrigin, rayDirection, rayParams)
            if not result then return end; targetPosition = result.Position + Vector3.new(0, petRootPart.Size.Y / 2, 0)
        end

        local isWaiting = true

        -- Walking connection handling.
        do
            local movementConnection: RBXScriptConnection
            
            movementConnection = RunService.Heartbeat:Connect(
                function(deltaTime: number)
                    if not petModel or not petModel.Parent then movementConnection:Disconnect(); return end

                    local offset = targetPosition - petRootPart.Position
                    local step = offset.Unit * deltaTime * PET_MUL_SPEED
                    local newPos = petRootPart.Position + step
                    local movingRotation = Vector3.new(offset.Unit.X, 0, offset.Unit.Z).Unit

                    local smoothRotation = petRootPart.CFrame.Rotation:Lerp(
                        CFrame.lookAt(Vector3.zero, movingRotation).Rotation,
                        deltaTime * 8
                    )

                    local wobbleRotation = CFrame.Angles(
                        math.sin(time() * TIME_MUL) * WOBBLE_ANGLE,
                        0,
                        0
                    )

                    petRootPart.CFrame = CFrame.new(newPos) * smoothRotation * wobbleRotation

                    -- Cleanup.
                    do
                        if offset.Magnitude > 0.1 then return end
                        movementConnection:Disconnect()

                        -- Face player after movement.
                        task.spawn(
                            function()
                                while true do
                                    if not petModel or not petModel.Parent then break end

                                    local dt = RunService.Heartbeat:Wait()
                                    local lookPos = plrRootPart.Position - petRootPart.Position

                                    local flatFeetVec = Vector3.new(lookPos.X, 0, lookPos.Z)
                                    if petRootPart.CFrame.LookVector:Dot(flatFeetVec.Unit) > 0.999 then break end

                                    local smoothRotation = petRootPart.CFrame.Rotation:Lerp(
                                        CFrame.lookAt(
                                            Vector3.zero,
                                            flatFeetVec.Unit
                                        ).Rotation,

                                        dt * TIME_MUL
                                    )

                                    petRootPart.CFrame = CFrame.new(petRootPart.Position) * smoothRotation
                                end

                                isWaiting = false
                            end
                        )
                    end
                end
            )
        end

        repeat task.wait() until not isWaiting

        local randomWaitTime = RNG.betterRandomNumber(
            {
                min = RNG.betterRandomNumber({ min = 1, max = 3 }),
                max = RNG.betterRandomNumber({ min = 3, max = 10 })
            }
        )

        task.wait(randomWaitTime)
    end
end

--[[
    @usage Equip a pet to a player.

    @param sender Player
    @param data string
    @param PetsFolder Folder
    @param GamePetsFolder Folder
    @param isJoining boolean

    @return void
]]
local function equipPet(sender: Player, data: string, PetsFolder: Folder, GamePetsFolder: Folder, isJoining: boolean)
    local plrChar: Model = sender.Character :: Model
    if not plrChar then repeat task.wait() until sender.Character; plrChar = sender.Character :: Model end

    local plrRootPart = plrChar:WaitForChild("HumanoidRootPart") :: BasePart

    local PlrDataClass = Registry(sender)
    if not PlrDataClass then return end

    local Inventory = PlrDataClass()().Inventory :: InventoryClass
    if not Inventory then return end

    local FoundStack: StackClass<PetSchema>? = Inventory:fetchStackFromItemId(data)
    if not FoundStack then return end

    if table.find(FoundStack.StackData.Equipped or {}, data) and not isJoining then return end
    if not isJoining then table.insert(FoundStack.StackData.Equipped or {}, data) end

    -- Create the pet model and cache it.
    do
        local foundPetModel = PetsFolder:WaitForChild(FoundStack.StackData.petName) :: Model
        repeat task.wait() until foundPetModel.PrimaryPart

        local clonedPetModel = foundPetModel:Clone()
        clonedPetModel.Name = data
        clonedPetModel.Parent = GamePetsFolder

        local animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://105564049799467"

        if FoundStack.StackData.PetStats.size == "Gigantic" then
            if clonedPetModel.PrimaryPart then
                clonedPetModel.PrimaryPart.Size
                = Vector3.new(
                    clonedPetModel.PrimaryPart.Size.X * 8,
                    clonedPetModel.PrimaryPart.Size.Y * 8,
                    clonedPetModel.PrimaryPart.Size.Z * 8
                )
            end
        elseif FoundStack.StackData.PetStats.size == "Huge" then
            if clonedPetModel.PrimaryPart then
                clonedPetModel.PrimaryPart.Size
                = Vector3.new(
                    clonedPetModel.PrimaryPart.Size.X * 4,
                    clonedPetModel.PrimaryPart.Size.Y * 4,
                    clonedPetModel.PrimaryPart.Size.Z * 4
                )
            end
        end

        CachedEquippedPets[sender][data] = { model = clonedPetModel :: Model, PetData = FoundStack.StackData }
        task.spawn(function() followOwner(clonedPetModel, FoundStack.StackData, sender, plrRootPart, plrChar, animation) end)
    end
end

--[[
    @usage Unequip a pet from a player.

    @param sender Player
    @param data string

    @return void
]]
local function unequipPetFunction(sender: Player, data: { PetData: PetSchema, petId: string })
    if not sender or not CachedEquippedPets[sender][data.petId] then return end

    -- Remove the pet from the stack's equipped pets data.
    do
        local PlrDataClass = Registry(sender)
        if not PlrDataClass then return end

        local Inventory = PlrDataClass()().Inventory :: InventoryClass
        if not Inventory then return end

        local FoundStack: StackClass<PetSchema>? = Inventory:fetchStackFromItemId(data.petId)
        if not FoundStack then FoundStack = Inventory:fetchStackFromItemData(data.PetData) end

        if FoundStack then
            local foundEquippedIndex = table.find(FoundStack.StackData.Equipped or {}, data.petId)
            if not foundEquippedIndex then return end

            table.remove(FoundStack.StackData.Equipped or {}, foundEquippedIndex)
        end
    end

    local FoundCachedPet = CachedEquippedPets[sender][data.petId]
    if not FoundCachedPet then return end

    FoundCachedPet.model:Destroy()
    FoundCachedPet.model.Parent = nil

    CachedEquippedPets[sender][data.petId] = nil
end
--[[ @end_section Utility Functions ]]


--[[ @section Constructor ]]
--[[
    @usage Initialize the component.
    
    @return void
]]
local function constructorCallback()
    local AssetsFolder = workspace:WaitForChild("Assets") :: Folder
    local PetsFolder = AssetsFolder:WaitForChild("Pets") :: Folder
    local GameFolder = workspace:WaitForChild("Game") :: Folder
    local GamePetsFolder = GameFolder:WaitForChild("Pets") :: Folder

    local function onPlrAdded(plr: Player)
        CachedEquippedPets[plr] = {}

        local PlrDataClass = Registry(plr)
        if not PlrDataClass then return end

        repeat task.wait() until (PlrDataClass()().Inventory :: InventoryClass).fetchStackFromItemId

        local Inventory = PlrDataClass()().Inventory :: InventoryClass
        if not Inventory then return end

        for stackId: string, PetStack: StackClass<PetSchema> in pairs(Inventory.StacksDictionary) do
            for idIndex: number, id: string in ipairs(PetStack.StackArray()) do
                if PlrDataClass()().HealingData().HealingPets[id] then continue end
                if not table.find(PetStack.StackData.Equipped or {}, id) then continue end

                equipPet(plr, id, PetsFolder, GamePetsFolder, true)
            end
        end

        task.spawn(
            function()
                while true do
                    if not Players:GetPlayerByUserId(plr.UserId) or not CachedEquippedPets[plr] then break end; task.wait()

                    local FreshPlrDataClass = Registry(plr)
                    if not FreshPlrDataClass then break end

                    local FreshInventory = FreshPlrDataClass()().Inventory :: InventoryClass
                    if not FreshInventory then break end

                    for i: string, data: { PetData: PetSchema, model: Model } in pairs(if CachedEquippedPets[plr] then CachedEquippedPets[plr] else {}) do
                        local FoundStack: StackClass<PetSchema>? = FreshInventory:fetchStackFromItemId(i)
                        if FoundStack then continue end

                        unequipPetFunction(plr, { petId = i, PetData = data.PetData })
                    end
                end
            end
        )
    end

    for i: number, plr: Player in ipairs(Players:GetPlayers()) do onPlrAdded(plr) end
    Players.PlayerAdded:Connect(onPlrAdded)

    Players.PlayerRemoving:Connect(
        function(plr: Player)
            for i: string, data: { PetData: PetSchema, model: Model } in pairs(CachedEquippedPets[plr]) do
                data.model:Destroy()
                data.model.Parent = nil
            end

            CachedEquippedPets[plr] = nil
        end
    )

    PetsHandlingGroup.EquipPet:onServerEvent(
        function(sender, data)
            if not sender then return end
            equipPet(sender, data, PetsFolder, GamePetsFolder, false)
        end
    )

    PetsHandlingGroup.UnequipPet:onServerEvent(
        function(sender, data)
            if not sender or not CachedEquippedPets[sender][data] then return end
            unequipPetFunction(sender, { petId = data, PetData = CachedEquippedPets[sender][data].PetData })
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]