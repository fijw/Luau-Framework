--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Data = require(ReplicatedStorage.Assets.Pets.Data)

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


local CachedEquippedPets: { [Player]: { [string]: PetSchema } } = {}


--[[ @section Utility Functions ]]
--[[
    @usage Make the pet follow the player.

    @param petId string
    @param PetData PetSchema
    @param sender Player

    @return void
]]
local function followOwner(petId: string, PetData: PetSchema, sender: Player)
    PetsHandlingGroup.PetStartFollowingOwner:fireAllClients(
        {
            petId = petId,
            PetData = PetData,
            ownerId = sender.UserId
        }
    )
end

--[[
    @usage Equip a pet to a player.

    @param sender Player
    @param data string
    @param isJoining boolean

    @return void
]]
local function equipPet(sender: Player, data: string, isJoining: boolean)
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

    PetsHandlingGroup.PetStartFollowingOwner:fireAllClients(
        {
            petId = data,
            PetData = FoundStack.StackData,
            ownerId = sender.UserId
        }
    )

    CachedEquippedPets[sender][data] = FoundStack.StackData
    followOwner(data, FoundStack.StackData, sender)
end

--[[
    @usage Unequip a pet from a player.

    @param sender Player
    @param data { PetData: PetSchema, petId: string }

    @return void
]]
local function unequipPetFunction(sender: Player, data: { PetData: PetSchema, petId: string }, isLeaving: boolean)
    if not sender or not CachedEquippedPets[sender][data.petId] then return end
    CachedEquippedPets[sender][data.petId] = nil

    -- Remove the pet from the stack's equipped pets data if the player isn't leaving.
    if not isLeaving then
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

    PetsHandlingGroup.RemovePetFromClient:fireAllClients(data.petId)
end
--[[ @end_section Utility Functions ]]


--[[ @section Constructor ]]
--[[
    @usage Initialize the component.
    
    @return void
]]
local function constructorCallback()
    local function onPlrAdded(plr: Player)
        CachedEquippedPets[plr] = {}

        local PlrDataClass = Registry(plr)
        if not PlrDataClass then return end

        repeat task.wait() until (PlrDataClass()().Inventory :: InventoryClass).fetchStackFromItemId

        local Inventory = PlrDataClass()().Inventory :: InventoryClass
        if not Inventory then return end

        for i: Player, PlrEquipData: { [string]: PetSchema } in pairs(CachedEquippedPets) do
            for petId: string, PetData: PetSchema in pairs(PlrEquipData) do equipPet(i, petId, true) end
        end

        for stackId: string, PetStack: StackClass<PetSchema> in pairs(Inventory.StacksDictionary) do
            for idIndex: number, id: string in ipairs(PetStack.StackArray()) do
                if PlrDataClass()().HealingData().HealingPets[id] then continue end
                if not table.find(PetStack.StackData.Equipped or {}, id) then continue end

                equipPet(plr, id, true)
            end
        end

        InventoryGroup.UpdatePetsEquippedText:fireClient(plr, `{PlrDataClass()().currentNumOfPetsEquipped()}/{PlrDataClass()().maxPetsEquipped()}`)

        task.spawn(
            function()
                while true do
                    if not Players:GetPlayerByUserId(plr.UserId) or not CachedEquippedPets[plr] then break end

                    local FreshPlrDataClass = Registry(plr)
                    if not FreshPlrDataClass then break end

                    local FreshInventory = FreshPlrDataClass()().Inventory :: InventoryClass
                    if not FreshInventory then break end

                    for i: string, PetData: PetSchema in pairs(CachedEquippedPets[plr]) do
                        local FoundStack: StackClass<PetSchema>? = FreshInventory:fetchStackFromItemId(i)
                        if FoundStack then continue end

                        unequipPetFunction(plr, { petId = i, PetData = PetData }, false)
                        InventoryGroup.UpdatePetsEquippedText:fireClient(plr, `{FreshPlrDataClass()().currentNumOfPetsEquipped()}/{FreshPlrDataClass()().maxPetsEquipped()}`)
                    end

                    task.wait()
                end
            end
        )
    end

    -- Initialize the component's connections.
    do
        for i: number, plr: Player in ipairs(Players:GetPlayers()) do onPlrAdded(plr) end
        Players.PlayerAdded:Connect(onPlrAdded)

        Players.PlayerRemoving:Connect(
            function(plr: Player)
                for i: string, PetData: PetSchema in pairs(CachedEquippedPets[plr]) do unequipPetFunction(plr, { petId = i, PetData = PetData }, true) end
                CachedEquippedPets[plr] = nil
            end
        )
    end

    PetsHandlingGroup.EquipPet:onServerInvoke(
        function(sender, data)
            if not sender then return false end

            local PlrDataClass = Registry(sender)
            if not PlrDataClass then return false end

            if PlrDataClass()().currentNumOfPetsEquipped() >= PlrDataClass()().maxPetsEquipped() then return false end
            equipPet(sender, data, false)

            return true
        end
    )

    PetsHandlingGroup.UnequipPet:onServerInvoke(
        function(sender, data)
            if not sender or not CachedEquippedPets[sender][data] then return false end
            unequipPetFunction(sender, { petId = data, PetData = CachedEquippedPets[sender][data] }, false)

            return true
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]