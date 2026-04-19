--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local MarketplaceNamespace = require(ReplicatedStorage.Networking.Namespaces.Components.Marketplace)

local MarketplaceLib = require(ServerScriptService.Components.Marketplace.MarketplaceLib)

local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local Stackentory = require(ServerScriptService.Libraries.DataLibs.Stackentory)
--[[ @end_section Imports ]]


type InventoryClass = Stackentory.InventoryClass


--[[ @section Constructor ]]
--[[
    @usage Handles marketplace related packets.
    
    @return void
]]
local function constuctorCallback()
    MarketplaceNamespace.packets.ServerPlacePetOnMarketplace.listen(
        function(data: { petId: string, price: string }, player: Player?)
            if not player then return end

            MarketplaceLib.addPetToMarketplace(player, data.petId, tonumber(data.price) :: number)
            MarketplaceNamespace.packets.ClientPlacedPetOnMarketplace.send(data.petId, player)

            -- Send the added pet to all players.
            do
                local MarketplaceState = MarketplaceLib.fetchMarketplaceState()
                if not MarketplaceState then return end

                local PetMarketplaceData = MarketplaceState.Pets[data.petId]
                if not PetMarketplaceData then return end

                MarketplaceNamespace.packets.ClientInsertPetIntoMarketplace.sendToAll({ PetData = PetMarketplaceData.Data, petId = data.petId })
            end
        end
    )

    MarketplaceNamespace.packets.ServerRemoveOwnedPetFromMarketplace.listen(
        function(data: string, player: Player?)
            if not player then return end

            MarketplaceLib.removePetFromMarketplace(player, data)
            MarketplaceNamespace.packets.ClientRemovePetFromMarketplace.sendToAll(data)

            -- Send the removed pet packet to the player.
            do
                local PlrDataClass = Registry(player)
                if not PlrDataClass then return end

                local PetStack = (PlrDataClass()().Inventory :: InventoryClass):fetchStackFromItemId(data)
                if not PetStack then return end
            
                MarketplaceNamespace.packets.ClientRemovedPetFromMarketplace.send(PetStack.StackData.name, player)
            end
        end
    )

    MarketplaceNamespace.packets.ServerBuyPetFromMarketplace.listen(
        function(data: string, player: Player?)
            if not player then return end

            MarketplaceLib.purchasePetFromMarketplace(player, data)

            -- Send the bought pet packet to the player.
            do
                local PlrDataClass = Registry(player)
                if not PlrDataClass then return end

                local PetStack = (PlrDataClass()().Inventory :: InventoryClass):fetchStackFromItemId(data)
                if not PetStack then return end

                MarketplaceNamespace.packets.ClientBoughtPetFromMarketplace.send(PetStack.StackData.name, player)
            end
        end
    )
end

return constuctorCallback
--[[ @end_section Constructor ]]