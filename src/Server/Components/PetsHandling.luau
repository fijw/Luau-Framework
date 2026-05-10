--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Data = require(ReplicatedStorage.Assets.Pets.Data)

local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local Stackentory = require(ServerScriptService.Libraries.DataLibs.Stackentory)
local StackingLib = require(ServerScriptService.Libraries.DataLibs.Stackentory.Stacking)

local PetsHandlingGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.PetsHandling)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type PetSchema = Data.PetSchema
type InventoryClass = Stackentory.InventoryClass

--[[ @generic D Data type. ]]
type StackClass<D> = StackingLib.StackClass<D>
--[[ @end_section Types ]]


local CachedEquippedPets: { [Player]: { [string]: { PetData: PetSchema, model: Model } } } = {}


--[[ @section Constructor ]]
--[[
    @usage Initialize the component.
    
    @return void
]]
local function constructorCallback()
    local AssetsFolder = workspace:WaitForChild("Assets") :: Folder
    local PetsFolder = AssetsFolder:WaitForChild("Pets") :: Folder
    local GameFolder = workspace:WaitForChild("Game") :: Folder
    local GamePetsFolder = GameFolder:WaitForChild("Pets") :: Folder

    PetsHandlingGroup.EquipPet:onServerEvent(
        function(sender, data)
            if not sender then return end

            local PlrDataClass = Registry(sender)
            if not PlrDataClass then return end

            local Inventory = PlrDataClass()().Inventory :: InventoryClass
            if not Inventory then return end

            local FoundStack: StackClass<PetSchema>? = Inventory:fetchStackFromItemId(data)
            if not FoundStack then return end

            if not FoundStack.StackData.Equipped or table.find(FoundStack.StackData.Equipped, data) then return end
            table.insert(FoundStack.StackData.Equipped or {}, data)

            -- Create the pet model and cache it.
            do
                local foundPetModelClone = PetsFolder:FindFirstChild(FoundStack.StackData.petName)
                if not foundPetModelClone then return else foundPetModelClone = foundPetModelClone:Clone() end

                foundPetModelClone.Name = data
                foundPetModelClone.Parent = GamePetsFolder

                CachedEquippedPets[sender] = { model = foundPetModelClone, PetData = FoundStack.StackData }
            end
        end
    )

    PetsHandlingGroup.UnequipPet:onServerEvent(
        function(sender, data)
            if not sender then return end

            -- Remove the pet from the stack's equipped pets data.
            do
                local PlrDataClass = Registry(sender)
                if not PlrDataClass then return end

                local Inventory = PlrDataClass()().Inventory :: InventoryClass
                if not Inventory then return end

                local FoundStack: StackClass<PetSchema>? = Inventory:fetchStackFromItemId(data)
                if not FoundStack then return end

                local foundEquippedIndex = table.find(FoundStack.StackData.Equipped or {}, data)
                if not FoundStack.StackData.Equipped or not foundEquippedIndex then return end

                table.remove(FoundStack.StackData.Equipped, foundEquippedIndex)
            end

            local FoundCache = CachedEquippedPets[sender]
            if not FoundCache then return end

            local FoundCachedPet = FoundCache[data]
            if not FoundCachedPet then return end

            FoundCachedPet.model:Destroy()
            FoundCachedPet.model.Parent = nil

            FoundCache[data] = nil
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]