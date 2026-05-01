--[[
    @TODO: Add a way for players with stored pets to be added to actually have those pets get added
    once they join the game. Currently players in the game will get their spawned pets, but players
    that aren't in the game will just have the spawn data stored.
]]
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

local CrateMachineNamespace = require(ReplicatedStorage.Networking.Namespaces.Components.CrateMachine)
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
    CrateMachineNamespace.packets.ServerOpenCrate.listen(
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

    CrateMachineNamespace.queries.GetCrates.listen(
        function(request: { message: unknown }, player: Player?)
            local ReturningCrates = {}

            if request.message ~= nil then
                for i: string, Crate: CrateSchema in pairs(CrateSchemas) do
                    if not string.find(Crate.name:lower(), (request.message :: string):lower()) then continue end
                    table.insert(ReturningCrates, Crate)
                end

                 print(ReturningCrates, "ret 1")

                return ReturningCrates :: any
            end

            for i: string, Crate: CrateSchema in pairs(CrateSchemas) do
                table.insert(ReturningCrates, Crate)
            end

            print(ReturningCrates, "ret 2")

            return ReturningCrates :: any
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]