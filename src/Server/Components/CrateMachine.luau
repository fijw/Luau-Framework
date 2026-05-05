--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local CrateSchemas = require(ReplicatedStorage.Assets.Crates.CrateSchemas)

local PetsData = require(ReplicatedStorage.Assets.Pets.Data)
local CratesData = require(ReplicatedStorage.Assets.Crates.Data)

local RNG = require(ReplicatedStorage.Libraries.RNG)
local TableUtils = require(ReplicatedStorage.Libraries.TableUtils)
local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local Stackentory = require(ServerScriptService.Libraries.DataLibs.Stackentory)

local CrateMachineGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.CrateMachine)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type InventoryClass = Stackentory.InventoryClass

type CrateSchema = CratesData.CrateSchema
type PetSchema = PetsData.PetSchema
--[[ @end_section Types ]]


--[[ @section Constructor ]]
--[[
    @usage Handles the hatch pet packet.

    @return void
]]
local function constructorCallback()
    CrateMachineGroup.OpenCrate:onServerEvent(
        function(sender, data)
            if not sender then return end

            local CrateSchema = CrateSchemas[data]
            if not CrateSchema then return end

            -- Attempt to perform the atomic transaction to hatch the pet and deduct the player's coins.
            Registry.atomicTransaction({ sender },
                function(PlayerStates)
                    local PlayerState = PlayerStates[sender]
                    if not PlayerState then return false end

                    local oldGems = PlayerState.gems()

                    -- Deduct the player's coins.
                    do
                        if CrateSchema.price > oldGems then
                            CrateMachineGroup.SendNotEnoughGemsNotification:fireClient(sender, CrateSchema.price - oldGems)
                            return false
                        end

                        PlayerState.gems(oldGems - CrateSchema.price)
                        if PlayerState.gems() ~= oldGems - CrateSchema.price then return false end
                    end

                    -- Attempt to give the player the hatched pet.
                    do
                        local RandomizedStats
                        = {
                            size = PetsData.PHYSICAL_ATTRIBUTES.SIZES[RNG.randomFromTableOfChances(PetsData.ATTRIBUTE_CHANCES.SIZE)],
                            color = PetsData.PHYSICAL_ATTRIBUTES.COLORS[RNG.randomFromTableOfChances(PetsData.ATTRIBUTE_CHANCES.COLOR)]
                        }

                        local randomId = RNG.randomString(16)

                        local PetSchema: PetSchema = TableUtils.deepClone(RNG.randomFromTableOfChances(CrateSchema.Chances))
                        PetSchema.PetStats.color = RandomizedStats.color :: any
                        PetSchema.PetStats.size = RandomizedStats.size :: any
                        PetSchema.GameplayStats.petHealth = PetSchema.GameplayStats.maxHealth
                        PetSchema.locked = {}

                        -- Attempt to give the player the pet.
                        do
                            local Inventory = PlayerState.Inventory :: InventoryClass

                            local maxItems = Inventory.maxItems
                            if Inventory.usedItemSlots >= maxItems then CrateMachineGroup.SendMaxPetsNotification:fireClient(sender, maxItems); return false end

                            Inventory += { itemData = PetSchema, itemId = randomId }
                            if not Inventory:fetchStackFromItemId(randomId) then return false end
                        end
                    end

                    return true
                end
            )
        end
    )

    CrateMachineGroup.GetCrates:onServerInvoke(
        function(sender, data)
            local ReturningCrates = {}

            for i: string, Crate: CrateSchema in pairs(CrateSchemas) do
                if data then if not string.find(Crate.name:lower(), data:lower()) then continue end end

                local CopiedChances = {}

                for Pet: PetSchema, chance: number in pairs(Crate.Chances) do
                    CopiedChances[Pet.petName] = chance
                end

                local CopiedCrate = TableUtils.deepClone(Crate)
                CopiedCrate.Chances = CopiedChances :: any

                table.insert(ReturningCrates, CopiedCrate)
            end

            return ReturningCrates :: any
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]