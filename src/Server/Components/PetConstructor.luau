--[[
    @TODO: Add a way for players with stored pets to be added to actually have those pets get added
    once they join the game. Currently players in the game will get their spawned pets, but players
    that aren't in the game will just have the spawn data stored.
]]
--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local MessagingService = game:GetService("MessagingService")

local DataSettings = require(ReplicatedStorage.Settings.DataSettings)

local CrateSchemas = require(ReplicatedStorage.Assets.Crates.CrateSchemas)
local PetSchemas = require(ReplicatedStorage.Assets.Pets.PetSchemas)

local PetsData = require(ReplicatedStorage.Assets.Pets.Data)
local CratesData = require(ReplicatedStorage.Assets.Crates.Data)

local Chronovisor = require(ReplicatedStorage.Libraries.Chronovisor)
local RNG = require(ReplicatedStorage.Libraries.RNG)
local TableUtils = require(ReplicatedStorage.Libraries.TableUtils)
local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local Stackentory = require(ServerScriptService.Libraries.DataLibs.Stackentory)
local Compression = require(ServerScriptService.Libraries.DataLibs.Compression)

local PetConstructorNamespace = require(ReplicatedStorage.Networking.Namespaces.Components.PetConstructor)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type InventoryClass = Stackentory.InventoryClass

type CrateSchema = CratesData.CrateSchema
type PetSchema = PetsData.PetSchema

type DeveloperSpawningSchema
= {
    petName: string,
    petSize: string,
    petColor: string,
    receivingId: string?
}
--[[ @end_section Types ]]


local DataStore = DataStoreService:GetDataStore(DataSettings.PLAYER_DATA_STORAGE_KEY)


--[[ @section Constructor ]]
--[[
    @usage Handles the hatch pet packet.

    @return void
]]
local function constructorCallback()
    MessagingService:SubscribeAsync("developer_spawning",
        function(MessageData: { Data: buffer, Sent: number})
            local DecompressedData: DeveloperSpawningSchema = Compression(MessageData.Data, "decompress")
            
            local foundPlayer = Players:GetPlayerByUserId(tonumber(DecompressedData.receivingId) :: number)
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

    PetConstructorNamespace.packets.ServerHatchPet.listen(
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

    PetConstructorNamespace.packets.ServerDeveloperSpawnPet.listen(
        function(data: any, player: Player?)
            if not player then return end

            local TypedData: DeveloperSpawningSchema = data

            local PetSchema = PetSchemas[TypedData.petName]
            if not PetSchema then return else PetSchema = TableUtils.deepClone(PetSchema) end

            PetSchema.PetStats.color = TypedData.petColor :: any
            PetSchema.PetStats.size = TypedData.petSize :: any
            PetSchema.GameplayStats.petHealth = PetSchema.GameplayStats.maxHealth

            -- Locally attempt to give the player the pet.
            do
                local foundPlayer = Players:GetPlayerByUserId(tonumber(TypedData.receivingId) :: number)

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

            local AsyncData = Registry.forciblyFetchStoredPlayerData(tonumber(TypedData.receivingId) :: number)
            if not AsyncData then return end

            if AsyncData.inUse == true then
                MessagingService:PublishAsync("developer_spawning",
                    Compression(
                        {
                            petName = TypedData.petName,
                            petSize = TypedData.petSize,
                            petColor = TypedData.petColor,
                            receivingId = TypedData.receivingId
                        }
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
                        petName = TypedData.petName,
                        petSize = TypedData.petSize,
                        petColor = TypedData.petColor
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
                            DataStore:SetAsync(`{TypedData.receivingId}`,
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

return constructorCallback
--[[ @end_section Constructor ]]