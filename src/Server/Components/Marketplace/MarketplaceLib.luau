--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Data = require(ReplicatedStorage.Assets.Pets.Data)

local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local Chronovisor = require(ReplicatedStorage.Libraries.Chronovisor)
local Stackentory = require(ServerScriptService.Libraries.DataLibs.Stackentory)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type InventoryClass = Stackentory.InventoryClass
type PetSchema = Data.PetSchema

type MarketplaceSchema
= {
    Pets
    : {
        [string]
        : {
            Data: PetSchema,

            price: number,
            sellerName: string,
            sellerId: number
        }
    },

    PendingPurchases
    : {
        {
            buyerName: string,
            price: number,
            sellerId: number
        }
    }
}
--[[ @end_section Types ]]


--[[ @section Variables ]]
local MarketplaceDataStore = DataStoreService:GetDataStore("MarketplaceDataTest123")

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
            State = MarketplaceDataStore:GetAsync("MarketplaceState")
            if not State then return end
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
    local PlrDataClass = Registry(player)
    if not PlrDataClass then return end

    local PetStack = (PlrDataClass().Inventory :: InventoryClass):fetchStackFromItemId(petId)
    if not PetStack then return end

    Chronovisor(
        function()
            MarketplaceDataStore:UpdateAsync("MarketplaceState",
                function(State: MarketplaceSchema)
                    if not State then State = { Pets = {}, PendingPurchases = {} } end

                    State.Pets[petId]
                    = {
                        Data = PetStack("data"),

                        price = price,
                        sellerId = player.UserId,
                        sellerName = player.Name
                    }

                    return State
                end
            )
        end
    )
    :onError(function(err: string?) print(`Error adding pet to marketplace. Error: {err}`) end)
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

    local PetStack = (PlrDataClass().Inventory :: InventoryClass):fetchStackFromItemId(petId)
    if PetStack then return end

    Chronovisor(
        function()
            MarketplaceDataStore:UpdateAsync("MarketplaceState",
                function(State: MarketplaceSchema)
                    if not State then State = { Pets = {}, PendingPurchases = {} } else State.Pets[petId] = nil end
                    return State
                end
            )
        end
    )
    :onError(function(err: string?) print(`Error removing pet from marketplace. Error: {err}`) end)
end
--[[ @end_section Seller Functions ]]


--[[
    @usage Purchases a pet from the marketplace.

    @param buyer Player
    @param petId string

    @return void
]]
function Marketplace.purchasePetFromMarketplace(buyer: Player, petId: string)
    local PlrDataClass = Registry(buyer)
    if not PlrDataClass then return end

    local PetStack = (PlrDataClass().Inventory :: InventoryClass):fetchStackFromItemId(petId)
    if PetStack then return end
    
    local FetchedState = Marketplace.fetchMarketplaceState()
    if not FetchedState then return end

    local PetMarketplaceData = FetchedState.Pets[petId]
    if not PetMarketplaceData then return end

    -- Attempt to perform the atomic transaction to purchase the pet.
    Registry.atomicTransaction({ buyer },
        function(PlayerStates)
            local PlayerState = PlayerStates[buyer]
            if not PlayerState then return false end

            -- Add the pet to the buyer's inventory and deduct the coins from the buyer. Then verify the transaction succeeded.
            do
                if PlayerState.coins() < PetMarketplaceData.price then return false end
                PlayerState.coins(PlayerState.coins() - PetMarketplaceData.price)

                PlayerState.Inventory += { itemData = PetMarketplaceData.Data, itemId = petId }

                if not (PlayerState.Inventory :: InventoryClass):fetchStackFromItemId(petId) then return false end
                if PlayerState.coins() ~= PlayerState.coins() - PetMarketplaceData.price then return false end
            end

            local marketplaceStatusSuccess = true

            -- Attempt to remove the pet from the marketplace.
            Chronovisor(
                function()
                    MarketplaceDataStore:UpdateAsync("MarketplaceState",
                        function(State: MarketplaceSchema)
                            if not State then State = { Pets = {}, PendingPurchases = {} } end

                            table.insert(State.PendingPurchases,
                                {
                                    buyerName = buyer.Name,
                                    price = PetMarketplaceData.price,
                                    sellerId = PetMarketplaceData.sellerId
                                }
                            )

                            State.Pets[petId] = nil

                            return State
                        end
                    )
                end
            )
            :onError(
                function(err: string?)
                    print(`Error removing pet from marketplace while purchasing. Error: {err}`)
                    marketplaceStatusSuccess = false
                end
            )

            return marketplaceStatusSuccess
        end
    )
end


table.freeze(Marketplace)
return Marketplace