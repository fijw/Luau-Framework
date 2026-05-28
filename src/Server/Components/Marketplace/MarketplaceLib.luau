--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Data = require(ReplicatedStorage.DataAssets.Pets.Data)

local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local Chronovisor = require(ReplicatedStorage.Libraries.Chronovisor)
local Stackentory = require(ServerScriptService.Libraries.DataLibs.Stackentory)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type InventoryClass = Stackentory.InventoryClass
type PetSchema = Data.PetSchema

type MarketplaceSchema
= {
    lastRefreshed: number,
    numberOfPetsInMarketplace: number,

    Pets
    : {
        [string]
        : {
            PetData: PetSchema,

            price: number,
            sellerName: string,
            sellerId: number
        }
    },

    PurchasesToProcess: { [string]: { number } },
    ReturnsToProcess: { [string]: { [string]: { PetData: PetSchema, petId: string } } },

    PlayersWithPetsOnMarketplace: { [string]: { string } }
}
--[[ @end_section Types ]]


--[[ @section Variables ]]
local MAX_PETS_IN_MARKETPLACE_PER_PLAYER = 10
local MARKETPLACE_DATA_KEY = "marketplace_state_test"
local MARKETPLACE_KEY = "marketplace_key_test"
local MAX_PETS_IN_MARKETPLACE_AT_ONCE = 500

local MarketplaceDataStore = DataStoreService:GetDataStore(MARKETPLACE_KEY)

local Marketplace = {}
--[[ @end_section Variables ]]


--[[
    @usage Fetches the current state of the marketplace.

    @return MarketplaceSchema?
]]
function Marketplace.fetchMarketplaceState(): MarketplaceSchema?
    local State: MarketplaceSchema?

    Chronovisor(
        function()
            State = MarketplaceDataStore:GetAsync(MARKETPLACE_DATA_KEY) :: MarketplaceSchema?
            if not State or State.lastRefreshed + 60 * 60 * 24 > os.time() then return end

            for i: string, PetIdsArray: { string } in pairs(State.PlayersWithPetsOnMarketplace) do
                if not State.ReturnsToProcess[i] then State.ReturnsToProcess[i] = {} end

                for idsArrayIndex: number, petId: string in pairs(PetIdsArray) do
                    table.insert(State.ReturnsToProcess[i] :: any, { PetData = State.Pets[petId].PetData, petId = petId })
                end
            end

            State.Pets = {}
            State.PlayersWithPetsOnMarketplace = {}
            State.numberOfPetsInMarketplace = 0
            State.lastRefreshed = os.time()
        end
    )
    :onError(function(err: string?) print(`Error fetching marketplace state. Error: {err}`) end)

    return State
end


--[[ @section Seller Functions ]]
--[[
    @usage Adds a pet to the marketplace.

    @param player Player
    @param petId string
    @param price number

    @return void
]]
function Marketplace.addPetToMarketplace(player: Player, petId: string, price: number)
    -- Validate the request before performing any operations.
    do
        local MarketplaceState = Marketplace.fetchMarketplaceState()

        if not MarketplaceState
            or MarketplaceState.Pets[petId]
            or #MarketplaceState.PlayersWithPetsOnMarketplace[`{player.UserId}`] >= MAX_PETS_IN_MARKETPLACE_PER_PLAYER
            or MarketplaceState.numberOfPetsInMarketplace >= MAX_PETS_IN_MARKETPLACE_AT_ONCE
        then return end
    end

    local PlrDataClass = Registry(player)
    if not PlrDataClass then return end

    local PetStack = (PlrDataClass()().Inventory :: InventoryClass):fetchStackFromItemId(petId)
    if not PetStack then return end

    -- Perform the atomic transaction to add the pet to the marketplace and remove it from the player's inventory.
    Registry.atomicTransaction({ player },
        function(PlayerStates)
            PlrDataClass()().Inventory -= petId
            if (PlrDataClass()().Inventory :: InventoryClass):fetchStackFromItemId(petId) then return false end

            -- Add the pet to the marketplace.
            Chronovisor(
                function()
                    MarketplaceDataStore:UpdateAsync(MARKETPLACE_DATA_KEY,
                        function(State: MarketplaceSchema)
                            if not State then
                                State
                                = {
                                    Pets = {},
                                    PurchasesToProcess = {},
                                    PlayersWithPetsOnMarketplace = {},
                                    numberOfPetsInMarketplace = 0,
                                    lastRefreshed = os.time(),
                                    ReturnsToProcess = {}
                                }
                            end

                            State.Pets[petId]
                            = {
                                Data = PetStack.StackData,

                                price = price,
                                sellerId = player.UserId,
                                sellerName = player.Name
                            }

                            State.numberOfPetsInMarketplace += 1
                            table.insert(State.PlayersWithPetsOnMarketplace[`{player.UserId}`], petId)

                            return State
                        end
                    )
                end
            )
            :onError(function(err: string?) print(`Error adding pet to marketplace. Error: {err}`) end)

            -- Verify the pet was added to the marketplace.
            do
                local MarketplaceState = Marketplace.fetchMarketplaceState()
                if not MarketplaceState then return false end

                local PetMarketplaceData = MarketplaceState.Pets[petId]
                if not PetMarketplaceData then return false end
            end

            return true
        end
    )
end

--[[
    @usage Removes a pet from the marketplace.

    @param player Player
    @param petId string

    @return void
]]
function Marketplace.removePetFromMarketplace(player: Player, petId: string)
    local PlrDataClass = Registry(player)
    if not PlrDataClass then return end

    local PetStack = (PlrDataClass()().Inventory :: InventoryClass):fetchStackFromItemId(petId)
    if PetStack then return end

    -- Perform the atomic transaction to remove the pet from the marketplace and add it back to the seller's inventory.
    Registry.atomicTransaction({ player },
        function(PlayerStates)
            local MarketplaceState = Marketplace.fetchMarketplaceState()
            if not MarketplaceState then return false end

            local PetMarketplaceData = MarketplaceState.Pets[petId]
            if not PetMarketplaceData or PetMarketplaceData.sellerId ~= player.UserId then return false end

            -- Add the pet back to the player's inventory and verify it was added successfully.
            PlrDataClass()().Inventory += { itemData = PetMarketplaceData, itemId = petId }
            if not (PlrDataClass()().Inventory :: InventoryClass):fetchStackFromItemId(petId) then return false end

            -- Attempt to remove the pet from the marketplace.
            Chronovisor(
                function()
                    MarketplaceDataStore:UpdateAsync(MARKETPLACE_DATA_KEY,
                        function(State: MarketplaceSchema)
                            if not State then
                                State
                                = {
                                    Pets = {},
                                    PurchasesToProcess = {},
                                    PlayersWithPetsOnMarketplace = {},
                                    numberOfPetsInMarketplace = 0,
                                    lastRefreshed = os.time(),
                                    ReturnsToProcess = {}
                                }
                            else State.Pets[petId] = nil end

                            return State
                        end
                    )
                end
            )
            :onError(function(err: string?) print(`Error removing pet from marketplace. Error: {err}`) end)

            MarketplaceState.numberOfPetsInMarketplace -= 1

            -- Handle the player's marketplace player cache.
            do
                local FoundPetInMarketplacePlayerCache = table.find(MarketplaceState.PlayersWithPetsOnMarketplace[`{player.UserId}`], petId)

                if FoundPetInMarketplacePlayerCache then
                    MarketplaceState.PlayersWithPetsOnMarketplace[`{player.UserId}`][FoundPetInMarketplacePlayerCache] = nil

                    if #MarketplaceState.PlayersWithPetsOnMarketplace[`{player.UserId}`] == 0 then
                        MarketplaceState.PlayersWithPetsOnMarketplace[`{player.UserId}`] = nil
                    end
                end
            end

            -- Verify the pet was removed from the marketplace.
            do
                MarketplaceState = Marketplace.fetchMarketplaceState()
                if not MarketplaceState then return false end

                PetMarketplaceData = MarketplaceState.Pets[petId]
                if PetMarketplaceData then return false end
            end

            return true
        end
    )
end
--[[ @end_section Seller Functions ]]


--[[
    @usage Purchases a pet from the marketplace.

    @param buyer Player
    @param petId string

    @return void
]]
function Marketplace.purchasePetFromMarketplace(buyer: Player, petId: string)
    local MarketplaceState = Marketplace.fetchMarketplaceState()
    if not MarketplaceState then return end

    local PetMarketplaceData = MarketplaceState.Pets[petId]
    if not PetMarketplaceData then return end

    -- Attempt to perform the atomic transaction to purchase the pet.
    Registry.atomicTransaction({ buyer },
        function(PlayerStates)
            local PlayerState = PlayerStates[buyer]
            if not PlayerState then return false end

            local PetStack = (PlayerState.Inventory :: InventoryClass):fetchStackFromItemId(petId)
            if PetStack then return false end

            -- Add the pet to the buyer's inventory and deduct the coins from the buyer. Then verify the transaction succeeded.
            do
                local oldGems = PlayerState.gems()

                if oldGems < PetMarketplaceData.price then return false end
                PlayerState.gems(oldGems - PetMarketplaceData.price)

                PlayerState.Inventory += { itemData = PetMarketplaceData.PetData, itemId = petId }

                if not (PlayerState.Inventory :: InventoryClass):fetchStackFromItemId(petId) then return false end
                if PlayerState.gems() ~= oldGems - PetMarketplaceData.price then return false end
            end

            -- Attempt to remove the pet from the marketplace.
            Chronovisor(
                function()
                    MarketplaceDataStore:UpdateAsync(MARKETPLACE_DATA_KEY,
                        function(State: MarketplaceSchema)
                            if not State then
                                State
                                = {
                                    Pets = {},
                                    PurchasesToProcess = {},
                                    PlayersWithPetsOnMarketplace = {},
                                    numberOfPetsInMarketplace = 0,
                                    lastRefreshed = os.time(),
                                    ReturnsToProcess = {}
                                }
                            end

                            table.insert(State.PurchasesToProcess[PetMarketplaceData.sellerId], PetMarketplaceData.price)
                            State.Pets[petId] = nil

                            return State
                        end
                    )
                end
            )
            :onError(function(err: string?) print(`Error removing pet from marketplace while purchasing. Error: {err}`) end)

            -- Verify the pet was removed from the marketplace and the pending purchase was added.
            do
                local sellerId = PetMarketplaceData.sellerId

                MarketplaceState = Marketplace.fetchMarketplaceState()
                if not MarketplaceState then return false end

                PetMarketplaceData = MarketplaceState.Pets[petId]
                if PetMarketplaceData then return false end

                local PendingPurchaseData = MarketplaceState.PurchasesToProcess[`{sellerId}`]
                if not PendingPurchaseData then return false end
            end

            return true
        end
    )
end


table.freeze(Marketplace)
return Marketplace