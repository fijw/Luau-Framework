--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Data = require(ReplicatedStorage.Assets.Pets.Data)

local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local Stackentory = require(ServerScriptService.Libraries.DataLibs.Stackentory)
local StackingLib = require(ServerScriptService.Libraries.DataLibs.Stackentory.Stacking)

local HealingMachineGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.HealingMachine)
local InventoryGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.Inventory)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type InventoryClass = Stackentory.InventoryClass

--[[ @generic D Data type. ]]
type SavingStackSchema<D> = StackingLib.SavingStackSchema<D>

--[[ @generic D Data type. ]]
type StackClass<D> = StackingLib.StackClass<D>

type PetSchema = Data.PetSchema
--[[ @end_section Types ]]


--[[ @section Constructor ]]
--[[
    @usage Handles the healing machine packet group.

    @return void
]]
local function constructorCallback()
    -- Handle joining players' healing pets.
    do
        local function onPlayerAdded(player: Player)
            local PlrDataClass = Registry(player)
            if not PlrDataClass then return end

            local Inventory = (PlrDataClass()().Inventory :: InventoryClass)
            if not Inventory then return end

            task.spawn(
                function()
                    local countOfPets = 0
                    for i: string, durationLeft: number in pairs(PlrDataClass()().HealingData().HealingPets) do countOfPets += 1 end

                    while true do
                        if countOfPets <= 0 then break end

                        for i: string, durationLeft: number in pairs(PlrDataClass()().HealingData().HealingPets) do
                            durationLeft -= 1

                            if durationLeft > 0 then PlrDataClass()().HealingData(durationLeft, i, "HealingPets")
                            else
                                PlrDataClass()().HealingData(nil, i, "HealingPets"); countOfPets -= 1

                                local PetStack: StackClass<PetSchema>? = Inventory:fetchStackFromItemId(i)
                                if not PetStack then continue end

                                InventoryGroup.AddPetsToInventory:fireClient(player, { [i] = PetStack.StackData })
                                HealingMachineGroup.RemovePetsFromHealingMachine:fireClient(player, { i })
                                HealingMachineGroup.PetFinishedHealing:fireClient(player, PetStack.StackData.petName)
                            end
                        end

                        task.wait(1)
                    end
                end
            )
        end

        for i: number, player: Player in ipairs(Players:GetPlayers()) do onPlayerAdded(player) end
        Players.PlayerAdded:Connect(onPlayerAdded)
    end

    HealingMachineGroup.RequestHealingSlots:onServerInvoke(
        function(sender)
            local PlrDataClass = Registry(sender)
            if not PlrDataClass then return nil :: any end

            return PlrDataClass()().HealingData().maxHealingSlots
        end
    )

    HealingMachineGroup.HealPets:onServerEvent(
        function(sender, data)
            if not sender then return end

            local PlrDataClass = Registry(sender)
            if not PlrDataClass then return end

            local Inventory = PlrDataClass()().Inventory :: InventoryClass
            if not Inventory then return end

            local numOfPets = 0

            for i: number, petId: string in ipairs(data) do
                local PetStack: StackClass<PetSchema>? = Inventory:fetchStackFromItemId(petId)
                if not PetStack then return end

                numOfPets += 1
                local duration = 60 * 5

                if PlrDataClass()().HealingData().HealingPets[petId] then continue end
                PlrDataClass()().HealingData(duration, petId, "HealingPets")

                InventoryGroup.RemovePetsFromInventory:fireClient(sender, { petId })

                task.spawn(
                    function()
                        duration -= 1

                        while true do
                            duration -= 1; if duration <= 0 then break end
                            task.wait(1)
                        end

                        PlrDataClass()().HealingData(nil, petId, "HealingPets")

                        InventoryGroup.AddPetsToInventory:fireClient(sender, { [petId] = PetStack.StackData })
                        HealingMachineGroup.RemovePetsFromHealingMachine:fireClient(sender, { petId })
                        HealingMachineGroup.PetFinishedHealing:fireClient(sender, PetStack.StackData.petName)
                    end
                )
            end

            HealingMachineGroup.SuccessfullyStartedHealing:fireClient(sender, numOfPets)
        end
    )

    HealingMachineGroup.RequestHealingPets:onServerInvoke(
        function(sender, data)
            if not sender then return nil :: any end

            local PlrDataClass = Registry(sender)
            if not PlrDataClass then return nil :: any end

            local ReturningData: { [string]: PetSchema } = {}

            for i: string, durationLeft: number in pairs(PlrDataClass()().HealingData().HealingPets) do
                local PetStack = (PlrDataClass()().Inventory :: InventoryClass):fetchStackFromItemId(i)
                if not PetStack then continue end

                ReturningData[i] = PetStack.StackData
            end

            return ReturningData
        end
    )

    HealingMachineGroup.RequestPetsForHealingSelection:onServerInvoke(
        function(sender, data)
            if not sender then return nil :: any end

            local PlrDataClass = Registry(sender)
            if not PlrDataClass then return nil :: any end

            local Inventory = PlrDataClass()().Inventory :: InventoryClass
            if not Inventory then return nil :: any end

            local ReturningData: { [string]: PetSchema } = {}

            for i: string, SavingStackSchema: SavingStackSchema<PetSchema> in pairs(Inventory().StacksArray) do
                for i: number, id: string in ipairs(SavingStackSchema.StackArray) do
                    if PlrDataClass()().HealingData().HealingPets[id] then continue end
                    ReturningData[id] = SavingStackSchema.StackData
                end
            end

            return ReturningData
        end
    )
end

return constructorCallback
--[[ @end_section Constructor ]]