--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local MergingNamespace = require(ReplicatedStorage.Networking.Namespaces.Components.Merging)

local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local Stackentory = require(ServerScriptService.Libraries.DataLibs.Stackentory)
local RNG = require(ReplicatedStorage.Libraries.RNG)
local TableUtils = require(ReplicatedStorage.Libraries.TableUtils)

local PetsData = require(ReplicatedStorage.Assets.Pets.Data)
local CratesData = require(ReplicatedStorage.Assets.Crates.Data)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type InventoryClass = Stackentory.InventoryClass

type PetSchema = PetsData.PetSchema
type CrateSchema = CratesData.CrateSchema
--[[ @end_section Types ]]


local MERGING_PRICE = 5_000
local PETS_NEEDED_TO_MERGE = 9


--[[ @section Constructor ]]
--[[
    @usage Handles the merging pet packet.

    @return void
]]
local function constructorCallback()
    MergingNamespace.packets.ServerMergePets.listen(
        function(data: { string }, player: Player?)
            if not player or #data < PETS_NEEDED_TO_MERGE then return end

            -- Perform the atomic transaction to merge the pets.
            Registry.atomicTransaction({ player },
                function(PlayerStates)
                    local PlayerState = PlayerStates[player]
                    if not PlayerState then return false end

                    -- Deduct the player's coins.
                    do
                        local coinsState = PlayerState.coins()

                        if coinsState < MERGING_PRICE then return false end
                        PlayerState.coins(coinsState - MERGING_PRICE)

                        if PlayerState.coins() ~= coinsState - MERGING_PRICE then return false end
                    end

                    local IdentifyingPet = (PlayerState.Inventory :: InventoryClass):fetchStackFromItemId(data[1])
                    if not IdentifyingPet then return false end

                    local MergingPetSchema: PetSchema? = IdentifyingPet("data")
                    if not MergingPetSchema then return false end

                    -- Verify all the merging pets have the same schema.
                    for i: number, petId: string in ipairs(data) do
                        local PetStack = (PlayerState.Inventory :: InventoryClass):fetchStackFromItemId(petId)
                        if not PetStack then return false end

                        local PetSchema: PetSchema? = PetStack("data")
                        if not PetSchema then return false end

                        if TableUtils.deepCompare(PetSchema :: any, MergingPetSchema :: any) ~= "match" then return false end

                        PlayerState.Inventory -= { itemData = PetSchema, itemId = petId }
                        if (PlayerState.Inventory :: InventoryClass):fetchStackFromItemId(petId) then return false end
                    end

                    -- Upgrade the merged pet.
                    do
                        local doSizeUpgrade = RNG.randomFromTableOfChances({ [true] = 0.0004, [false] = 99.9996 })

                        if doSizeUpgrade then
                            for i: number, size: string in ipairs(PetsData.PHYSICAL_ATTRIBUTES.SIZES) do
                                if size ~= MergingPetSchema.size then continue end
                                MergingPetSchema.size = PetsData.PHYSICAL_ATTRIBUTES.SIZES[if i + 1 > #PetsData.PHYSICAL_ATTRIBUTES.SIZES then i else i + 1] :: any; break
                            end
                        end

                        for i: number, color: string in ipairs(PetsData.PHYSICAL_ATTRIBUTES.COLORS) do
                            if color ~= MergingPetSchema.color then continue end
                            MergingPetSchema.color = PetsData.PHYSICAL_ATTRIBUTES.COLORS[if i + 1 > #PetsData.PHYSICAL_ATTRIBUTES.COLORS then i else i + 1] :: any; break
                        end
                    end

                    -- Give the player the merged pet.
                    do
                        local randomizedPetId = RNG.randomString(16)

                        PlayerState.Inventory += { itemData = MergingPetSchema, itemId = randomizedPetId }
                        if not (PlayerState.Inventory :: InventoryClass):fetchStackFromItemId(randomizedPetId) then return false end
                    end

                    return true
                end
            )
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]