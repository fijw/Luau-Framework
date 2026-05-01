--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local UIUtilitiesLibrary = require(StarterPlayer.StarterPlayerScripts.Libraries.UILib)
local Components = require(script.Components)

local CratesData = require(ReplicatedStorage.Assets.Crates.Data)
local PetsData = require(ReplicatedStorage.Assets.Pets.Data)

local CrateMachineGroup = require(ReplicatedStorage.Networking.PacketGroups.Components.CrateMachine)
--[[ @end_section Imports ]]


type CrateSchema = CratesData.CrateSchema
type PetSchema = PetsData.PetSchema


--[[ @section Variables ]]
local localPlayer = Players.LocalPlayer :: Player
local PlayerGui = (if localPlayer then localPlayer:WaitForChild("PlayerGui") else nil) :: PlayerGui

local CachedCrateContainers = {}
--[[ @end_section Variables ]]


--[[ @section Constructor ]]
--[[
    @usage Initialize the service.
    
    @return void
]]
local function constructorCallback()
    local clonedCrateMachine = Components.CrateMachine:Clone()
    clonedCrateMachine.Parent = PlayerGui

    local machineContainer = clonedCrateMachine:WaitForChild("Container") :: Frame
    local searchBox = machineContainer:WaitForChild("SearchBox") :: Frame
    local closeBtn = machineContainer:WaitForChild("CloseBtn") :: ImageButton
    local mainFrame = machineContainer:WaitForChild("MainFrame") :: Frame
    local innerContainer = mainFrame:WaitForChild("InnerContainer") :: Frame
    local crateFrame = innerContainer:WaitForChild("CrateFrame") :: Frame
    local crateContainer = crateFrame:WaitForChild("CrateContainer") :: Frame

    local HandledUI = UIUtilitiesLibrary(clonedCrateMachine)
    HandledUI:hoverAndToggleSizing(1.15)
    HandledUI:handleButtonPress(closeBtn, function(pos1: number, pos2: number) end, true)

    -- Add existing crates to the crate machine.
    do
        local Crates: { CrateSchema } = CrateMachineGroup.GetCrates:invokeServer()

        print(Crates, "inv")

        for i: number, Crate: CrateSchema in ipairs(Crates) do
            local clonedCrateContainer = crateContainer:Clone()
            clonedCrateContainer.Parent = crateFrame
            clonedCrateContainer.Name = Crate.name

            local chancesContainer = clonedCrateContainer:WaitForChild("ChancesContainer") :: Frame
            local purchaseBtn = clonedCrateContainer:WaitForChild("PurchaseButton") :: ImageButton

            local crateName = clonedCrateContainer:WaitForChild("CrateName") :: TextLabel
            crateName.Text = Crate.name

            local priceText = clonedCrateContainer:WaitForChild("PriceText") :: TextLabel
            priceText.Text = `{Crate.price} Gems`

            local detailsContainer = chancesContainer:WaitForChild("DetailsContainer") :: Frame
            detailsContainer.Visible = false

            for Pet: PetSchema, chance: number in pairs(Crate.Chances) do
                local clonedDetailsContainer = detailsContainer:Clone()
                clonedDetailsContainer.Parent = chancesContainer
                clonedDetailsContainer.Name = Pet.petName
                clonedDetailsContainer.Visible = true
                
                local ImageLabel = clonedDetailsContainer:WaitForChild("ImageLabel") :: ImageLabel
                local TextLabel = clonedDetailsContainer:WaitForChild("TextLabel") :: TextLabel

                ImageLabel.Image = Pet.petImageId
                TextLabel.Text = `{chance}%`
            end

            HandledUI:handleButtonPress(purchaseBtn,
                function(pos1: number, pos2: number) CrateMachineGroup.OpenCrate:fireServer(Crate.name) end
            )

            table.insert(CachedCrateContainers, clonedCrateContainer)
        end
    end
end

return constructorCallback
--[[ @end_section Constructor ]]