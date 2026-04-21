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

local HatchCrateNamespace = require(ReplicatedStorage.Networking.Namespaces.Components.HatchCrate)
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
    HatchCrateNamespace.packets.ServerHatchPet.listen(
        function(data: string, player: Player?)
            if not player then return end

            local CrateSchema = CrateSchemas[data]
            if not CrateSchema then return end

            -- Attempt to perform the atomic transaction to hatch the pet and deduct the player's coins.
            Registry.atomicTransaction({ player },
                function(PlayerStates)
                    local PlayerState = PlayerStates[player]
                    if not PlayerState then return false end

                    if PlayerState.coins() < CrateSchema.price then return false end
                    PlayerState.coins(PlayerState.coins() - CrateSchema.price)

                    -- Attempt to give the player the hatched pet.
                    do
                        local Randomized
                        = {
                            size = PetsData.PHYSICAL_ATTRIBUTES.SIZES[RNG.randomFromTableOfChances(PetsData.ATTRIBUTE_CHANCES.SIZE)],
                            color = PetsData.PHYSICAL_ATTRIBUTES.COLORS[RNG.randomFromTableOfChances(PetsData.ATTRIBUTE_CHANCES.COLOR)],

                            id = RNG.randomString(16)
                        }

                        local PetSchema: PetSchema = TableUtils.deepClone(RNG.randomFromTableOfChances(CrateSchema.Chances))
                        PetSchema.PetStats.color = Randomized.color :: any
                        PetSchema.PetStats.size = Randomized.size :: any
                        PetSchema.GameplayStats.petHealth = PetSchema.GameplayStats.maxHealth

                        PlayerState.Inventory += { itemData = PetSchema, itemId = Randomized.id }
                        if not (PlayerState.Inventory :: InventoryClass):fetchStackFromItemId(Randomized.id) then return false end
                    end

                    return true
                end
            )
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]