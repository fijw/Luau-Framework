--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local SpawningSettings = require(ReplicatedStorage.SpawningSettings)

local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local TableUtils = require(ReplicatedStorage.Libraries.TableUtils)
local RNG = require(ReplicatedStorage.Libraries.NumberLibs.RNG)
local Stackentory = require(ServerScriptService.Libraries.DataLibs.Stackentory)
local StackingLib = require(ServerScriptService.Libraries.DataLibs.Stackentory.Stacking)

local PetSchemas = require(ReplicatedStorage.DataAssets.Pets.PetSchemas)
local Data = require(ReplicatedStorage.DataAssets.Pets.Data)

local DeveloperSpawningGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.DeveloperSpawning)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type InventoryClass = Stackentory.InventoryClass

--[[ @generic D Data type. ]]
type StackClass<D> = StackingLib.StackClass<D>

type PetSchema = Data.PetSchema
--[[ @end_section Types ]]


--[[ @section Constructor ]]
--[[
    @usage Initialize the component.

    @return void
]]
local function constuctorCallback(): ()
    DeveloperSpawningGroup.SpawnPet:onServerEvent(
        function(sender, data): ()
            if not sender then return end
            if not table.find(SpawningSettings, sender:GetRankInGroupAsync(game.CreatorId)) then return end

            local foundSize: string?
            local foundColor: string?
            local FoundPetSchema: PetSchema?

            -- Fetch applicable pet data.
            do
                for i: number, petSize: string in ipairs(Data.PHYSICAL_ATTRIBUTES.SIZES) do
                    if petSize:lower() ~= data.petSize:lower() then continue end
                    foundSize = petSize
                end

                for i: number, petColor: string in ipairs(Data.PHYSICAL_ATTRIBUTES.COLORS) do
                    if petColor:lower() ~= data.petColor:lower() then continue end
                    foundColor = petColor
                end

                for i: string, PetSchema: PetSchema in pairs(PetSchemas) do
                    if PetSchema.petName:lower() ~= data.petName:lower() then continue end
                    FoundPetSchema = PetSchema
                end

                if not foundColor then return end; if not foundSize then return end
                if not FoundPetSchema then return else FoundPetSchema = TableUtils.deepClone(FoundPetSchema) end
            end

            FoundPetSchema.PetStats.color = foundColor :: any
            FoundPetSchema.PetStats.size = foundSize :: any
            FoundPetSchema.Locked = {}
            FoundPetSchema.Equipped = {}

            local randomId = `{RNG.randomString(16)}`

            -- Size and color stat modifications.
            do
                if FoundPetSchema.PetStats.size == "Worldbreaker" then
                    FoundPetSchema.GameplayStats.attackDamage *= 16
                    FoundPetSchema.GameplayStats.maxHealth *= 16
                elseif FoundPetSchema.PetStats.size == "Gigantic" then
                    FoundPetSchema.GameplayStats.attackDamage *= 8
                    FoundPetSchema.GameplayStats.maxHealth *= 8
                elseif FoundPetSchema.PetStats.size == "Huge" then
                    FoundPetSchema.GameplayStats.attackDamage *= 4
                    FoundPetSchema.GameplayStats.maxHealth *= 4
                end

                if FoundPetSchema.PetStats.color == "Glitched" then
                    FoundPetSchema.GameplayStats.attackDamage *= 4
                    FoundPetSchema.GameplayStats.maxHealth *= 4
                elseif FoundPetSchema.PetStats.color == "Radioactive" then
                    FoundPetSchema.GameplayStats.attackDamage *= 3
                    FoundPetSchema.GameplayStats.maxHealth *= 3
                elseif FoundPetSchema.PetStats.color == "Rainbow" then
                    FoundPetSchema.GameplayStats.attackDamage *= 2
                    FoundPetSchema.GameplayStats.maxHealth *= 2
                end
            end

            local foundPlayer = Players:GetPlayerByUserId(data.receiverId)
            if not foundPlayer then return end

            -- Attempt to give the player the pet.
            Registry.atomicTransaction({ foundPlayer },
                function(PlayerStates)
                    local PlayerState = PlayerStates[foundPlayer]
                    if not PlayerState then return false end

                    -- Attempt to give the player the pet.
                    do
                        local Inventory = PlayerState.Inventory :: InventoryClass

                        Inventory
                        += {
                            itemData = FoundPetSchema,
                            itemId = randomId,
                            forceAdd = true,
                            ExclusionKeys = { "Locked", "Equipped", "HealthDictionary" }
                        }
                        
                        local FoundStack: StackClass<PetSchema>? = Inventory:fetchStackFromItemId(randomId)
                        if not FoundStack then return false end

                        if not FoundPetSchema then return false end
                        if FoundStack.StackData.HealthDictionary then FoundStack.StackData.HealthDictionary[randomId] = FoundPetSchema.GameplayStats.maxHealth end
                    end

                    DeveloperSpawningGroup.SendResults:fireClient(sender, `Successfully gave {data.petName} to {foundPlayer.Name}.`)

                    return true
                end
            )

            return
        end
    )
end

return constuctorCallback
--[[ @end_section Constructor ]]