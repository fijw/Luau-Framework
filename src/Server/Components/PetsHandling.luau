--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Data = require(ReplicatedStorage.DataAssets.Pets.Data)

local TweensLib = require(ReplicatedStorage.Libraries.TweensLib)
local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local Stackentory = require(ServerScriptService.Libraries.DataLibs.Stackentory)
local StackingLib = require(ServerScriptService.Libraries.DataLibs.Stackentory.Stacking)
local RNG = require(ReplicatedStorage.Libraries.NumberLibs.RNG)

local InventoryGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.Inventory)
local PetsHandlingGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.PetsHandling)

local PetSchemas = require(ReplicatedStorage.DataAssets.Pets.PetSchemas)
local TableUtils = require(ReplicatedStorage.Libraries.TableUtils)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type PetSchema = Data.PetSchema
type InventoryClass = Stackentory.InventoryClass
type HandledTween = TweensLib.HandledTween

--[[ @generic D Data type. ]]
type StackClass<D> = StackingLib.StackClass<D>
--[[ @end_section Types ]]


--[[ @section Variables ]]
local GameFolder = workspace:WaitForChild("Game") :: Folder
local FieldsFolder = GameFolder:WaitForChild("Fields") :: Folder

local CachedEquippedPets: { [Player]: { [string]: PetSchema } } = {}
local CachedFieldPets: { [BasePart]: { [string]: PetSchema } } = {}
local CachedAttackingPets: { string } = {}
--[[ @end_section Variables ]]


--[[ @section Utility Functions ]]
--[[
    @usage Equip a pet to a player.

    @param petId string
    @param owner Player
    @param onlySendToOneClient Player?
    @param swapEquipStatus boolean

    @return void
]]
local function equipPet(petId: string, owner: Player, onlySendToOneClient: Player?, swapEquipStatus: boolean): ()
    if CachedEquippedPets[owner][petId] and not onlySendToOneClient then return end

    local PlrDataClass = Registry(owner)
    if not PlrDataClass then return end

    local Inventory = PlrDataClass()().Inventory :: InventoryClass
    if not Inventory then return end

    local FoundStack: StackClass<PetSchema>? = Inventory:fetchStackFromItemId(petId)
    if not FoundStack then return end

    if swapEquipStatus then
        if table.find(FoundStack.StackData.Equipped or {}, petId) then return end
        table.insert(FoundStack.StackData.Equipped or {}, petId)

        local newEquippedNum = PlrDataClass()().currentNumOfPetsEquipped() + 1
        PlrDataClass()().currentNumOfPetsEquipped(newEquippedNum)

        InventoryGroup.UpdatePetsEquippedText:fireClient(owner, `{newEquippedNum}/{PlrDataClass()().maxPetsEquipped()}`)
    end

    if not onlySendToOneClient then CachedEquippedPets[owner][petId] = FoundStack.StackData end

    if not onlySendToOneClient then
        PetsHandlingGroup.PetStartFollowingOwner:fireAllClients(
            {
                PetData = FoundStack.StackData,
                ownerId = owner.UserId,
                petId = petId
            }
        )
    else
        PetsHandlingGroup.PetStartFollowingOwner:fireClient(
            onlySendToOneClient,

            {
                PetData = FoundStack.StackData,
                ownerId = owner.UserId,
                petId = petId
            }
        )
    end
end

--[[
    @usage Unequip a pet from a player.

    @param owner Player?
    @param PetData { PetData: PetSchema, petId: string }
    @param swapEquipStatus boolean
    @param field BasePart?

    @return void
]]
local function unequipPetFunction(owner: Player?, PetData: { PetData: PetSchema, petId: string }, swapEquipStatus: boolean, field: BasePart?): ()
    if owner then
        if not CachedEquippedPets[owner][PetData.petId] then return end
        CachedEquippedPets[owner][PetData.petId] = nil
    elseif field then
        if not CachedFieldPets[field][PetData.petId] then return end
        CachedFieldPets[field][PetData.petId] = nil
    end

    -- Remove the pet from the stack's equipped pets data if the player isn't leaving.
    if swapEquipStatus and owner then
        local PlrDataClass = Registry(owner)
        if not PlrDataClass then return end

        local Inventory = PlrDataClass()().Inventory :: InventoryClass
        if not Inventory then return end

        local FoundStack: StackClass<PetSchema>? = Inventory:fetchStackFromItemId(PetData.petId)
        if not FoundStack then FoundStack = Inventory:fetchStackFromItemData(PetData.PetData, { "Equipped", "HealthDictionary", "Locked" }) end

        if FoundStack then
            local foundEquippedIndex = table.find(FoundStack.StackData.Equipped or {}, PetData.petId)
            if not foundEquippedIndex then return end

            table.remove(FoundStack.StackData.Equipped or {}, foundEquippedIndex)
        end

        local newEquippedNum = PlrDataClass()().currentNumOfPetsEquipped() - 1
        PlrDataClass()().currentNumOfPetsEquipped(newEquippedNum)

        InventoryGroup.UpdatePetsEquippedText:fireClient(owner, `{newEquippedNum}/{PlrDataClass()().maxPetsEquipped()}`)
    end

    PetsHandlingGroup.RemovePetFromClient:fireAllClients(PetData.petId)
end
--[[ @end_section Utility Functions ]]


--[[ @section Constructor ]]
--[[
    @usage Initialize the component.
    
    @return void
]]
local function constructorCallback(): ()
    task.spawn(
        function(): ()
            while true do
                for i: number, plr: Player in ipairs(Players:GetPlayers()) do
                    if not CachedEquippedPets[plr] then continue end

                    local PlrDataClass = Registry(plr)
                    if not PlrDataClass then continue end

                    local Inventory = PlrDataClass()().Inventory :: InventoryClass
                    if not Inventory then continue end

                    for petId: string, PetData: PetSchema in pairs(CachedEquippedPets[plr]) do
                        local FoundStack: StackClass<PetSchema>? = Inventory:fetchStackFromItemId(petId)
                        
                        if FoundStack
                            and not PlrDataClass()().HealingData().HealingPets[petId]
                            and table.find(FoundStack.StackData.Equipped or {}, petId)
                        then continue end

                        unequipPetFunction(plr, { petId = petId, PetData = PetData }, true)
                    end
                end

                task.wait()
            end
        end
    )

    -- Equip and unequip pets on join & leave.
    do
        local function onPlayerAdded(plr: Player): ()
            repeat task.wait() until plr.Character

            CachedEquippedPets[plr] = {}

            local PlrDataClass = Registry(plr)
            if not PlrDataClass then return end

            for field: BasePart, FieldPetData: { [string]: PetSchema } in pairs(CachedFieldPets) do
                for fieldPetId: string, PetData: PetSchema in pairs(FieldPetData) do
                    PetsHandlingGroup.AddPetToClientField:fireClient(
                        plr,

                        {
                            PetData = PetData,
                            generatedId = fieldPetId,
                            fieldName = field.Name
                        }
                    )
                end
            end

            for owner: Player, EquipData: { [string]: PetSchema } in pairs(CachedEquippedPets) do
                for petId: string, PetData: PetSchema in pairs(EquipData) do equipPet(petId, owner, plr, false) end
            end

            repeat task.wait() until (PlrDataClass()().Inventory :: InventoryClass).fetchStackFromItemId

            local Inventory = PlrDataClass()().Inventory :: InventoryClass
            if not Inventory then return end

            for i: string, Stack: StackClass<PetSchema> in pairs(Inventory.StacksDictionary) do
                for petIndex: number, petId: string in ipairs(Stack.StackArray()) do
                    if not table.find(Stack.StackData.Equipped or {}, petId) then continue end
                    if PlrDataClass()().HealingData().HealingPets[petId] then continue end

                    equipPet(petId, plr, nil, false)
                end
            end

            InventoryGroup.UpdatePetsEquippedText:fireClient(plr, `{PlrDataClass()().currentNumOfPetsEquipped()}/{PlrDataClass()().maxPetsEquipped()}`)
        end

        for i: number, plr: Player in ipairs(Players:GetPlayers()) do onPlayerAdded(plr) end
        Players.PlayerAdded:Connect(onPlayerAdded)

        Players.PlayerRemoving:Connect(
            function(plr: Player): ()
                for petId: string, PetData: PetSchema in pairs(CachedEquippedPets[plr]) do
                    unequipPetFunction(plr, { PetData = PetData, petId = petId }, false)
                end

                CachedEquippedPets[plr] = nil
            end
        )
    end

    -- Networking connections.
    do
        PetsHandlingGroup.EquipPet:onServerInvoke(
            function(sender, data)
                if not sender then return false end

                local PlrDataClass = Registry(sender)
                if not PlrDataClass then return false end

                local Inventory = PlrDataClass()().Inventory :: InventoryClass
                if not Inventory then return false end

                local FoundStack: StackClass<PetSchema>? = Inventory:fetchStackFromItemId(data)
                if not FoundStack then return false end

                if not FoundStack.StackData.HealthDictionary then return false end
                if FoundStack.StackData.HealthDictionary[data] <= 0 then return false end

                if PlrDataClass()().currentNumOfPetsEquipped() >= PlrDataClass()().maxPetsEquipped() then return false end
                if PlrDataClass()().HealingData().HealingPets[data] then return false end

                equipPet(data, sender, nil, true); return true
            end
        )

        PetsHandlingGroup.UnequipPet:onServerInvoke(
            function(sender, data)
                if not sender or not CachedEquippedPets[sender][data] then return false end
                unequipPetFunction(sender, { petId = data, PetData = CachedEquippedPets[sender][data] }, true)

                return true
            end
        )

        PetsHandlingGroup.StartAttackingPet:onServerEvent(
            function(sender, data)
                if not sender or table.find(CachedAttackingPets, data.petIdToAttack) then return end

                local field = FieldsFolder:WaitForChild(data.fieldName) :: BasePart
                if not CachedFieldPets[field][data.petIdToAttack] then return end

                local PlrDataClass = Registry(sender)
                if not PlrDataClass then return end

                local Inventory = PlrDataClass()().Inventory :: InventoryClass
                if not Inventory then return end

                local EquippedPets: { { petId: string, PetData: PetSchema } } = {}

                for i: string, PetData: PetSchema in pairs(CachedEquippedPets[sender]) do
                    if table.find(CachedAttackingPets, i) then continue end
                    table.insert(EquippedPets, { petId = i, PetData = PetData })
                end

                if #EquippedPets <= 0 then return end; local randomIndex = RNG.betterRandomNumber({ max = #EquippedPets, min = 1 })

                local PetToAttackWith = EquippedPets[randomIndex]
                if not PetToAttackWith then return end

                local TargetPet = CachedFieldPets[field][data.petIdToAttack]
                if not TargetPet then return end

                table.insert(CachedAttackingPets, data.petIdToAttack); table.insert(CachedAttackingPets, PetToAttackWith.petId)

                PetsHandlingGroup.StartAttackingPet:fireAllClients(
                    {
                        attackingPetId = PetToAttackWith.petId,
                        targetPetId = data.petIdToAttack,
                        fieldName = data.fieldName
                    }
                )
            end
        )

        PetsHandlingGroup.ServerStartDealingDamage:onServerEvent(
            function(sender, data): ()
                local PetToAttackWith = CachedEquippedPets[sender][data.attackingPetId]
                if not PetToAttackWith then return end

                local field = FieldsFolder:WaitForChild(data.fieldName) :: BasePart

                local TargetPet = CachedFieldPets[field][data.targetPetId]
                if not TargetPet then return end

                if not TargetPet.HealthDictionary then return end; if not PetToAttackWith.HealthDictionary then return end

                while true do
                    task.wait(1)

                    TargetPet.HealthDictionary[data.targetPetId] -= PetToAttackWith.GameplayStats.attackDamage
                    PetToAttackWith.HealthDictionary[data.attackingPetId] -= TargetPet.GameplayStats.attackDamage

                    if TargetPet.HealthDictionary[data.targetPetId] <= 0 or PetToAttackWith.HealthDictionary[data.attackingPetId] <= 0 then break end
                end

                -- Check if pets are dead.
                do
                    if PetToAttackWith.HealthDictionary[data.attackingPetId] <= 0 then
                        PetToAttackWith.HealthDictionary[data.attackingPetId] = 0
                        unequipPetFunction(sender, { petId = data.attackingPetId, PetData = PetToAttackWith }, true)
                    end

                    if TargetPet.HealthDictionary[data.targetPetId] <= 0 then
                        unequipPetFunction(nil, { petId = data.targetPetId, PetData = TargetPet }, true, field)
                    end
                end

                -- Clear attacking cache.
                do
                    local foundAttackPetIndex = table.find(CachedAttackingPets, data.attackingPetId)
                    local foundTargetPetIndex = table.find(CachedAttackingPets, data.targetPetId)

                    if foundAttackPetIndex then table.remove(CachedAttackingPets, foundAttackPetIndex) end
                    if foundTargetPetIndex then table.remove(CachedAttackingPets, foundTargetPetIndex) end

                    PetsHandlingGroup.RemovePetFromClientAttackingCache:fireAllClients(data.attackingPetId)
                    PetsHandlingGroup.RemovePetFromClientAttackingCache:fireAllClients(data.targetPetId)
                end
            end
        )
    end

    -- Pet fields.
    do
        local GameFolder = workspace:WaitForChild("Game") :: Folder
        local FieldsFolder = GameFolder:WaitForChild("Fields") :: Folder

        local PetArray: { PetSchema } = {}
        for i: string, Pet: PetSchema in pairs(PetSchemas) do table.insert(PetArray, Pet) end

        for i: number, fieldPart: BasePart in ipairs(FieldsFolder:GetChildren() :: { BasePart }) do
            CachedFieldPets[fieldPart] = {}

            task.spawn(
                function(): ()
                    while true do
                        if not CachedFieldPets[fieldPart] then break end; task.wait()

                        local Pet = TableUtils.deepClone(PetArray[RNG.betterRandomNumber({ max = #PetArray, min = 1 })])
                        if not Pet then continue end

                        local generatedId = RNG.randomString(8)

                        Pet.HealthDictionary = { [generatedId] = Pet.GameplayStats.maxHealth }
                        Pet.PetStats.size = "Default"
                        Pet.PetStats.color = "Default"

                        PetsHandlingGroup.AddPetToClientField:fireAllClients(
                            {
                                PetData = Pet,
                                generatedId = generatedId,
                                fieldName = fieldPart.Name
                            }
                        )

                        CachedFieldPets[fieldPart][generatedId] = Pet

                        local amtOfPetsInField = 0

                        repeat
                            if not CachedFieldPets[fieldPart] then break end; task.wait()

                            for i: string, Pet: PetSchema in pairs(CachedFieldPets[fieldPart]) do
                                amtOfPetsInField += 1
                            end

                            if amtOfPetsInField < 2 then break end; amtOfPetsInField = 0
                        until true ~= true
                    end
                end
            )
        end
    end
end

return constructorCallback
--[[ @end_section Constructor ]]