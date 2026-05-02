--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local DataStoreService = game:GetService("DataStoreService")
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Compression = require(ReplicatedStorage.Libraries.DataLibs.Compression)
local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local TableUtils = require(ReplicatedStorage.Libraries.TableUtils)
local RNG = require(ReplicatedStorage.Libraries.RNG)
local Stackentory = require(ServerScriptService.Libraries.DataLibs.Stackentory)
local Chronovisor = require(ReplicatedStorage.Libraries.Chronovisor)

local PetSchemas = require(ReplicatedStorage.Assets.Pets.PetSchemas)
local Data = require(ReplicatedStorage.Assets.Pets.Data)

local DataSettings = require(ReplicatedStorage.Settings.DataSettings)

local DeveloperSpawningGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.DeveloperSpawning)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type InventoryClass = Stackentory.InventoryClass
type PetSchema = Data.PetSchema

type DeveloperSpawningSchema
= {
    petName: string,
    petSize: string,
    petColor: string,
    receiverId: number
}
--[[ @end_section Types ]]


local DataStore = DataStoreService:GetDataStore(DataSettings.PLAYER_DATA_STORAGE_KEY)


--[[ @section Constructor ]]
local function constuctorCallback()
    MessagingService:SubscribeAsync("developer_spawning",
        function(MessageData: { Data: buffer, Sent: number})
            local DecompressedData: DeveloperSpawningSchema = Compression(MessageData.Data, "decompress")
            
            local foundPlayer = Players:GetPlayerByUserId(DecompressedData.receiverId)
            if not foundPlayer then return end

            local PetSchema: PetSchema? = PetSchemas[DecompressedData.petName]
            if not PetSchema then return else PetSchema = TableUtils.deepClone(PetSchema) end

            PetSchema.PetStats.color = DecompressedData.petColor :: any
            PetSchema.PetStats.size = DecompressedData.petSize :: any
            PetSchema.GameplayStats.petHealth = PetSchema.GameplayStats.maxHealth

            -- Attempt to perform the atomic transaction to give the player the pet.
            Registry.atomicTransaction({ foundPlayer },
                function(PlayerStates)
                    local PlayerState = PlayerStates[foundPlayer]
                    if not PlayerState then return false end

                    -- Attempt to give the player the pet.
                    do
                        local randomPetId = RNG.randomString(16)

                        PlayerState.Inventory += { itemData = PetSchema, itemId = randomPetId }
                        if not (PlayerState.Inventory :: InventoryClass):fetchStackFromItemId(randomPetId) then return false end
                    end

                    return true
                end
            )
        end
    )

    DeveloperSpawningGroup.SpawnPet:onServerEvent(
        function
        (
            sender: Player,
            data: DeveloperSpawningSchema
        )
            if not sender then return end

            local PetSchema = PetSchemas[data.petName]
            if not PetSchema then return else PetSchema = TableUtils.deepClone(PetSchema) end

            PetSchema.PetStats.color = data.petColor :: any
            PetSchema.PetStats.size = data.petSize :: any
            PetSchema.GameplayStats.petHealth = PetSchema.GameplayStats.maxHealth

            -- Locally attempt to give the player the pet.
            do
                local foundPlayer = Players:GetPlayerByUserId(data.receiverId)

                if foundPlayer then
                    Registry.atomicTransaction({ foundPlayer },
                        function(PlayerStates)
                            local PlayerState = PlayerStates[foundPlayer]
                            if not PlayerState then return false end

                            -- Attempt to give the player the pet.
                            do
                                local randomPetId = RNG.randomString(16)
                                
                                PlayerState.Inventory += { itemData = PetSchema, itemId = randomPetId }
                                if not (PlayerState.Inventory :: InventoryClass):fetchStackFromItemId(randomPetId) then return false end
                            end

                            return true
                        end
                    )

                    return
                end
            end

            local AsyncData = Registry.forciblyFetchStoredPlayerData(data.receiverId)
            if not AsyncData then return end

            if AsyncData.inUse == true then
                MessagingService:PublishAsync("developer_spawning",
                    Compression(
                        {
                            petName = data.petName,
                            petSize = data.petSize,
                            petColor = data.petColor,
                            receiverId = data.receiverId
                        } :: DeveloperSpawningSchema
                    )
                )
            else
                local DecompressedData = {} :: { [string]: any }

                -- Decompress the player's data and insert the pet into it.
                do
                    for i: string, v: buffer in pairs(Compression(AsyncData.Data, "decompress") :: { [string]: buffer }) do
                        DecompressedData[i] = Compression(v, "decompress")
                    end

                    local InsertingData
                    = {
                        petName = data.petName,
                        petSize = data.petSize,
                        petColor = data.petColor
                    }
                    
                    if DecompressedData.DeveloperSpawnedPets == nil then
                        DecompressedData.DeveloperSpawnedPets = { InsertingData }
                    else
                        table.insert(DecompressedData.DeveloperSpawnedPets, InsertingData)
                    end
                end

                -- Compress the player's data and save it.
                do
                    local SavingData = {}

                    for i: string, v: any in pairs(DecompressedData) do
                        SavingData[i] = Compression(v)
                    end

                    Chronovisor(
                        function()
                            DataStore:SetAsync(`{data.receiverId}`,
                                {
                                    Data = Compression(SavingData),
                                    inUse = AsyncData.inUse
                                }
                            )
                        end
                    )
                    :onError(function(err: string?) print(`Failed to save pet spawning data changes. Error: {err}`) end)
                end
            end
        end
    )
end

return constuctorCallback
--[[ @end_section Constructor ]]