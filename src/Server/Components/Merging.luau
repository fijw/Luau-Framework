--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local MergingGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.Merging)

local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local Stackentory = require(ServerScriptService.Libraries.DataLibs.Stackentory)
local StackingLib = require(ServerScriptService.Libraries.DataLibs.Stackentory.Stacking)
local RNG = require(ReplicatedStorage.Libraries.RNG)
local TableUtils = require(ReplicatedStorage.Libraries.TableUtils)

local PetsData = require(ReplicatedStorage.Assets.Pets.Data)
local CratesData = require(ReplicatedStorage.Assets.Crates.Data)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type InventoryClass = Stackentory.InventoryClass

--[[ @generic D Data type. ]]
type SavingStackSchema<D> = StackingLib.SavingStackSchema<D>

type PetSchema = PetsData.PetSchema
type CrateSchema = CratesData.CrateSchema
--[[ @end_section Types ]]


local MERGING_PRICE = 5_000
local PETS_NEEDED_TO_MERGE = 9


--[[ @section Constructor ]]
--[[
    @usage Handles the merging pet packet group.

    @return void
]]
local function constructorCallback()
    MergingGroup.SearchForPetsByData:onServerEvent(
        function(sender, data)
            if not sender then return end

            local PlrDataClass = Registry(sender)
            if not PlrDataClass then return end

            MergingGroup.RemoveAllPetsFromMergingSlots:fireClient(sender)

            local Inventory = (PlrDataClass()() :: any).Inventory :: InventoryClass
            if not Inventory then return end

            -- Send valid search results to the player.
            do
                local PetsAddingToMergingSlots: { [string]: PetSchema } = {}
                
                local FoundStack = Inventory:fetchStackFromItemData(data)
                if not FoundStack then return end

                for i: number, id: string in ipairs(FoundStack.StackArray()) do
                    --if FoundStack.StackData.locked then if table.find(FoundStack.StackData.locked, id) then continue end end
                    PetsAddingToMergingSlots[id] = FoundStack.StackData
                end

                MergingGroup.AddPetsToMergingSlots:fireClient(sender, PetsAddingToMergingSlots)
            end
        end
    )

    MergingGroup.SearchForPetsByString:onServerEvent(
        function(sender, data)
            if not sender then return end

            local PlrDataClass = Registry(sender)
            if not PlrDataClass then return end

            MergingGroup.RemoveAllPetsFromMergingSlots:fireClient(sender)

            local Inventory = (PlrDataClass()() :: any).Inventory :: InventoryClass
            if not Inventory then return end

            -- Send valid search results to the player.
            do
                local PetsAddingToMergingSlots: { [string]: PetSchema } = {}
                
                for i: string, SavingStackSchema: SavingStackSchema<PetSchema> in pairs(Inventory().StacksDictionary) do
                    if not string.find(SavingStackSchema.StackData.petName:lower(), data:lower()) then continue end

                    for i: number, id: string in ipairs(SavingStackSchema.StackArray) do
                        --if SavingStackSchema.StackData.locked then if table.find(SavingStackSchema.StackData.locked, id) then continue end end
                        PetsAddingToMergingSlots[id] = SavingStackSchema.StackData
                    end
                end

                MergingGroup.AddPetsToMergingSlots:fireClient(sender, PetsAddingToMergingSlots)
            end
        end
    )

    MergingGroup.RequestMergingData:onServerEvent(
        function(sender)
            if not sender then return end

            local PlrDataClass = Registry(sender)
            if not PlrDataClass then return end

            local Inventory = (PlrDataClass()() :: any).Inventory :: InventoryClass
            if not Inventory then return end

            MergingGroup.RemoveAllPetsFromMergingSlots:fireClient(sender)

            -- Add existing pets to the player's client inventory.
            do
                local PetsAddingToMergingSlots = {}
                
                for stackIndex: string, SavingStackSchema: SavingStackSchema<PetSchema> in pairs(Inventory().StacksDictionary) do
                    for idIndex: number, id: string in ipairs(SavingStackSchema.StackArray) do
                        --if SavingStackSchema.StackData.Locked then if table.find(SavingStackSchema.StackData.Locked, id) then continue end end
                        PetsAddingToMergingSlots[id] = SavingStackSchema.StackData
                    end
                end
                
                MergingGroup.AddPetsToMergingSlots:fireClient(sender, PetsAddingToMergingSlots)
            end
        end
    )

    MergingGroup.MergePets:onServerEvent(
        function(sender, data)
            if not sender then return end
            if #data < PETS_NEEDED_TO_MERGE then MergingGroup.NotEnoughPetsToMerge:fireClient(sender, #data); return end

            -- Perform the atomic transaction to merge the pets.
            Registry.atomicTransaction({ sender },
                function(PlayerStates)
                    local PlayerState = PlayerStates[sender]
                    if not PlayerState then return false end

                    -- Deduct the player's coins.
                    do
                        local coinsState = PlayerState.gems()

                        if coinsState < MERGING_PRICE then MergingGroup.NotEnoughGemsToMerge:fireClient(sender, coinsState); return false end
                        PlayerState.gems(coinsState - MERGING_PRICE)

                        if PlayerState.gems() ~= coinsState - MERGING_PRICE then return false end
                    end

                    local IdentifyingPet = (PlayerState.Inventory :: InventoryClass):fetchStackFromItemId((data :: { string })[1])
                    if not IdentifyingPet then return false end

                    local MergingPetSchema: PetSchema? = IdentifyingPet.StackData
                    if not MergingPetSchema then return false end

                    -- Verify all the merging pets have the same schema.
                    for i: number, petId: string in ipairs(data :: { string }) do
                        local PetStack = (PlayerState.Inventory :: InventoryClass):fetchStackFromItemId(petId)
                        if not PetStack then return false end

                        local PetSchema: PetSchema? = PetStack.StackData
                        if not PetSchema then return false end

                        if TableUtils.deepCompare(PetSchema :: any, MergingPetSchema :: any) ~= "match" then return false end

                        PlayerState.Inventory -= petId
                        if (PlayerState.Inventory :: InventoryClass):fetchStackFromItemId(petId) then return false end
                    end

                    -- Upgrade the merged pet.
                    do
                        local doSizeUpgrade = RNG.randomFromTableOfChances({ [true] = 0.0004, [false] = 99.9996 })

                        if doSizeUpgrade then
                            for i: number, size: string in ipairs(PetsData.PHYSICAL_ATTRIBUTES.SIZES) do
                                if size ~= MergingPetSchema.PetStats.size then continue end

                                local newSize = PetsData.PHYSICAL_ATTRIBUTES.SIZES[if i + 1 > #PetsData.PHYSICAL_ATTRIBUTES.SIZES then i else i + 1]
                                MergingPetSchema.PetStats.size = newSize :: any

                                break
                            end
                        end

                        for i: number, color: string in ipairs(PetsData.PHYSICAL_ATTRIBUTES.COLORS) do
                            if color ~= MergingPetSchema.PetStats.color then continue end

                            local newColor = PetsData.PHYSICAL_ATTRIBUTES.COLORS[if i + 1 > #PetsData.PHYSICAL_ATTRIBUTES.COLORS then i else i + 1]
                            MergingPetSchema.PetStats.color = newColor :: any
                            
                            break
                        end
                    end

                    -- Give the player the merged pet.
                    do
                        local randomizedPetId = RNG.randomString(16)

                        PlayerState.Inventory += { itemData = MergingPetSchema, itemId = randomizedPetId }
                        if not (PlayerState.Inventory :: InventoryClass):fetchStackFromItemId(randomizedPetId) then return false end
                    end

                    MergingGroup.SuccessfullyMergedPets:fireClient(sender)

                    return true
                end
            )
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]