--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local InventoryGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.Inventory)

local UIComponents = require(script.Components)

local UIUtilitiesLibrary = require(StarterPlayer.StarterPlayerScripts.Libraries.UILib)

local Data = require(ReplicatedStorage.Assets.Pets.Data)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type PetSizeTypes = "Default" | "Huge" | "Gigantic"

type PetSchema = Data.PetSchema
--[[ @end_section Types ]]


local localPlayer = Players.LocalPlayer :: Player
local PlayerGui = (if localPlayer then localPlayer:WaitForChild("PlayerGui") else nil) :: PlayerGui


--[[ @section Constructor ]]
local function constructorCallback()
    local Inventory = UIComponents.Inventory:Clone()
    Inventory.Parent = PlayerGui

    --[[local ContainerFrame = Inventory:WaitForChild("ContainerFrame") :: Frame
    local SearchBox = ContainerFrame:WaitForChild("SearchBox") :: Frame
    local CloseBtn = ContainerFrame:WaitForChild("CloseBtn") :: ImageButton
    local ButtonsFrame = ContainerFrame:WaitForChild("ButtonsFrame") :: ImageLabel
    local MainFrame = ContainerFrame:WaitForChild("MainFrame") :: ImageLabel
    local ScrollingFrame = MainFrame:WaitForChild("ScrollingFrame") :: Frame

    local HandledUI = UIUtilitiesLibrary(Inventory)
    HandledUI:hoverAndToggleSizing(1.15)
    HandledUI:handleButtonPress(CloseBtn, function(pos1: number, pos2: number) end, true)

    InventoryGroup.AddPetsToInventory:onClientEvent(
        function(data: { [string]: PetSchema })
            for i: string, PetSchema: PetSchema in pairs(data) do
                local newPetButton = Instance.new("ImageButton")
                newPetButton.Name = i
                newPetButton.BackgroundTransparency = 1
                newPetButton.Image = PetSchema.petImageId

                if PetSchema.PetStats.size == "Gigantic" then
                    newPetButton.LayoutOrder = 1
                    newPetButton.Size = UDim2.new(0.490943968, 0, 0.743377984, 0)
                elseif PetSchema.PetStats.size == "Huge" then
                    newPetButton.LayoutOrder = 2
                    newPetButton.Size = UDim2.new(0.242385134, 0, 0.501016557, 0)
                else
                    newPetButton.LayoutOrder = 3
                    newPetButton.Size = UDim2.new(0.120999999, 0, 0.250999987, 0)
                end

                newPetButton.Parent = ScrollingFrame
            end
        end
    )

    InventoryGroup.RemovePetsFromInventory:onClientEvent(
        function(data: { string })
            for i: number, petId: string in ipairs(data :: { string }) do
                local PetButton = ScrollingFrame:FindFirstChild(petId)
                if not PetButton then continue end

                PetButton:Destroy()
                PetButton.Parent = nil
            end
        end
    )]]
end

return constructorCallback
--[[ @end_section Constructor ]]