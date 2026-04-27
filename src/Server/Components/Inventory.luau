--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local InventoryNamespace = require(ReplicatedStorage.Networking.Namespaces.Components.Inventory)

local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local Stackentory = require(ServerScriptService.Libraries.DataLibs.Stackentory)
local StackingLib = require(ServerScriptService.Libraries.DataLibs.Stackentory.Stacking)

local Data = require(ReplicatedStorage.Assets.Pets.Data)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type InventoryClass = Stackentory.InventoryClass
type PetSchema = Data.PetSchema

--[[ @generic D Data type. ]]
type SavingStackSchema<D> = StackingLib.SavingStackSchema<D>
--[[ @end_section Types ]]


local function subscribeToInventory(player: Player, Inventory: InventoryClass)
    Inventory:subscribeToItemsAdded(
        function(itemData: PetSchema, itemId: string)
            local SendingData
            = {
                {
                    petId = itemId,
                    petName = itemData.petName,
                    petSize = itemData.PetStats.size,
                    petColor = itemData.PetStats.color,
                    petImageId = "rbxassetid://13424524253"
                }
            }

            InventoryNamespace.packets.ClientAddPetsToInventory.sendTo(SendingData :: any, player)
        end
    )

    Inventory:subscribeToItemsRemoved(
        function(itemId: string)
            InventoryNamespace.packets.ClientRemovePetsFromInventory.sendTo({ itemId }, player)
        end
    )
end


--[[ @section Constructor ]]
local function constuctorCallback()
    local function onPlayerAdded(player: Player)
        local PlrDataClass = Registry(player)
        if not PlrDataClass then return end

        local Inventory = PlrDataClass()().Inventory :: InventoryClass

        -- Add existing pets to the player's client inventory.
        do
            local PetsAddingToInventory = {}
            
            for stackIndex: string, SavingStackSchema: SavingStackSchema<PetSchema> in pairs(Inventory().StacksArray) do
                for idIndex: number, id: string in ipairs(SavingStackSchema.StackArray) do
                    table.insert(PetsAddingToInventory,
                        {
                            petId = id,
                            petName = SavingStackSchema.StackData.petName,
                            petSize = SavingStackSchema.StackData.PetStats.size,
                            petColor = SavingStackSchema.StackData.PetStats.color,
                            petImageId = "rbxassetid://13424524253"
                        }
                    )
                end
            end

            InventoryNamespace.packets.ClientAddPetsToInventory.sendTo(PetsAddingToInventory, player)
        end

        subscribeToInventory(player, Inventory)

        -- Subscribe to the player's data state.
        PlrDataClass():subscribe(
            function(self, data, key, ...)
                --[[
                    If the state data remains the same then don't do anything, otherwise recreate the player's inventory subscriptions.
                    Will not do anything if the key isn't nil or the number of path arguments is greater than 0.
                ]]
                if key ~= nil or #{ ... } > 0 then return elseif key == nil and #{ ... } <= 0 then subscribeToInventory(player, Inventory) end
            end,
        
            "inventory_subscription"
        )
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
end

return constuctorCallback()
--[[ @end_section Constructor ]]