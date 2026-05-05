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
local RNG = require(ReplicatedStorage.Libraries.RNG)
local Stackentory = require(ServerScriptService.Libraries.DataLibs.Stackentory)

local PetSchemas = require(ReplicatedStorage.Assets.Pets.PetSchemas)

local DeveloperSpawningGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.DeveloperSpawning)
--[[ @end_section Imports ]]


type InventoryClass = Stackentory.InventoryClass


--[[ @section Constructor ]]
--[[
    @usage Initialize the service.

    @return void
]]
local function constuctorCallback()
    DeveloperSpawningGroup.SpawnPet:onServerEvent(
        function(sender, data)
            if not sender then return end
            if not table.find(SpawningSettings, sender:GetRankInGroupAsync(game.CreatorId)) then return end

            local PetSchema = PetSchemas[data.petName]
            if not PetSchema then return else PetSchema = TableUtils.deepClone(PetSchema) end

            PetSchema.PetStats.color = data.petColor :: any
            PetSchema.PetStats.size = data.petSize :: any
            PetSchema.GameplayStats.petHealth = PetSchema.GameplayStats.maxHealth
            PetSchema.locked = {}

            local foundPlayer = Players:GetPlayerByUserId(data.receiverId)
            if not foundPlayer then return end

            -- Attempt to give the player the pet.
            Registry.atomicTransaction({ foundPlayer },
                function(PlayerStates)
                    local PlayerState = PlayerStates[foundPlayer]
                    if not PlayerState then return false end

                    -- Attempt to give the player the pet.
                    do
                        local randomId = `{RNG.randomString(16)}`
                        local Inventory = PlayerState.Inventory :: InventoryClass

                        Inventory += { itemData = PetSchema, itemId = randomId, forceAdd = true }
                        if not Inventory:fetchStackFromItemId(randomId) then return false end
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