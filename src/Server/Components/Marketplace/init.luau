--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local MarketplaceGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.Marketplace)

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
    MarketplaceGroup.PlacePetOnMarketplace:onServerEvent(
        function(sender: Player, data: { petId: string, price: number })
            if not sender then return end
            MarketplaceLib.addPetToMarketplace(sender, data.petId, tonumber(data.price) :: number)
        end
    )

    MarketplaceGroup.RemovePetFromMarketplace:onServerEvent(
        function(sender: Player, data: string)
            if not sender then return end
            MarketplaceLib.removePetFromMarketplace(sender, data)

            -- Send the removed pet packet to the player.
            do
                local PlrDataClass = Registry(sender)
                if not PlrDataClass then return end

                local PetStack = (PlrDataClass()().Inventory :: InventoryClass):fetchStackFromItemId(data)
                if not PetStack then return end
            end
        end
    )

    MarketplaceGroup.BuyPetFromMarketplace:onServerEvent(
        function(sender: Player, data: string)
            if not sender then return end
            MarketplaceLib.purchasePetFromMarketplace(sender, data)
        end
    )
end

return constuctorCallback
--[[ @end_section Constructor ]]