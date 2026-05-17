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

local InventoryGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.Inventory)
local PetsHandlingGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.PetsHandling)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type PetSchema = Data.PetSchema
type InventoryClass = Stackentory.InventoryClass
type HandledTween = TweensLib.HandledTween

--[[ @generic D Data type. ]]
type StackClass<D> = StackingLib.StackClass<D>
--[[ @end_section Types ]]


local CachedEquippedPets: { [Player]: { [string]: { PetData: PetSchema, model: Model } } } = {}


--[[ @section Utility Functions ]]
--[[
    @usage Make the pet follow the player.

    @param petModel Model
    @param petId string
    @param PetData PetSchema
    @param plr Player

    @return void
]]
local function followOwner(petModel: Model, petId: string, PetData: PetSchema, plr: Player)
    local petRootPart = petModel.PrimaryPart
    if not petRootPart then return end

    local NewCachedEquippedPets: { [string]: PetSchema } = {}

    for i: string, CachedData: { PetData: PetSchema, model: Model } in pairs(CachedEquippedPets[plr]) do
        NewCachedEquippedPets[i] = CachedData.PetData
    end

    PetsHandlingGroup.UpdatePetFollowingPosition:fireAllClients(
        {
            petId = petId,
            PetData = PetData,
            ownerId = plr.UserId,
            instaTravel = true,
            CachedEquippedPets = NewCachedEquippedPets
        }
    )

    local isWaiting = false

    -- Heartbeat loop while the pet is equipped.
    do
        local heartbeatConnection: RBXScriptConnection

        heartbeatConnection = RunService.Heartbeat:Connect(
            function(deltaTime: number)
                if not petModel or not petModel.Parent then heartbeatConnection:Disconnect(); return end; if isWaiting then return end
                isWaiting = true

                local HeartbeatEquippedPets: { [string]: PetSchema } = {}

                for i: string, CachedData: { PetData: PetSchema, model: Model } in pairs(CachedEquippedPets[plr]) do
                    HeartbeatEquippedPets[i] = CachedData.PetData
                end

                PetsHandlingGroup.UpdatePetFollowingPosition:fireAllClients(
                    {
                        petId = petId,
                        PetData = PetData,
                        ownerId = plr.UserId,
                        CachedEquippedPets = HeartbeatEquippedPets
                    }
                )

                local randomWaitTime = RNG.betterRandomNumber(
                    {
                        min = RNG.betterRandomNumber({ min = 1, max = 3 }),
                        max = RNG.betterRandomNumber({ min = 3, max = 10 })
                    }
                )

                task.wait(randomWaitTime); isWaiting = false
            end
        )
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
    local PlrDataClass = Registry(sender)
    if not PlrDataClass then return end

    local Inventory = PlrDataClass()().Inventory :: InventoryClass
    if not Inventory then return end

    local FoundStack: StackClass<PetSchema>? = Inventory:fetchStackFromItemId(data)
    if not FoundStack then return end

    if table.find(FoundStack.StackData.Equipped or {}, data) and not isJoining then return end

    if not isJoining then
        table.insert(FoundStack.StackData.Equipped or {}, data)

        local newEquippedNum = PlrDataClass()().currentNumOfPetsEquipped() + 1
        PlrDataClass()().currentNumOfPetsEquipped(newEquippedNum)

        InventoryGroup.UpdatePetsEquippedText:fireClient(sender, `{newEquippedNum}/{PlrDataClass()().maxPetsEquipped()}`)
    end

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
        followOwner(clonedPetModel, data, FoundStack.StackData, sender)
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

        local newEquippedNum = PlrDataClass()().currentNumOfPetsEquipped() - 1
        PlrDataClass()().currentNumOfPetsEquipped(newEquippedNum)

        InventoryGroup.UpdatePetsEquippedText:fireClient(sender, `{newEquippedNum}/{PlrDataClass()().maxPetsEquipped()}`)
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

        InventoryGroup.UpdatePetsEquippedText:fireClient(plr, `{PlrDataClass()().currentNumOfPetsEquipped()}/{PlrDataClass()().maxPetsEquipped()}`)

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
                        InventoryGroup.UpdatePetsEquippedText:fireClient(plr, `{FreshPlrDataClass()().currentNumOfPetsEquipped()}/{FreshPlrDataClass()().maxPetsEquipped()}`)
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

    PetsHandlingGroup.EquipPet:onServerInvoke(
        function(sender, data)
            if not sender then return false end

            local PlrDataClass = Registry(sender)
            if not PlrDataClass then return false end

            if PlrDataClass()().currentNumOfPetsEquipped() >= PlrDataClass()().maxPetsEquipped() then return false end
            equipPet(sender, data, PetsFolder, GamePetsFolder, false)

            return true
        end
    )

    PetsHandlingGroup.UnequipPet:onServerInvoke(
        function(sender, data)
            if not sender or not CachedEquippedPets[sender][data] then return false end
            unequipPetFunction(sender, { petId = data, PetData = CachedEquippedPets[sender][data].PetData })

            return true
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]