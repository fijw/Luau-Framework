--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Assets.Pets.Data)

local NetworkLib = require(ReplicatedStorage.Networking.NetworkLib)
--[[ @end_section Imports ]]


type PetSchema = Data.PetSchema


local Packets
= {
    EquipPet = NetworkLib("ph_equip_pet", "Event",
        {
            clientType = nil,
            serverType = "pet_id"
        }
    ),

    UnequipPet = NetworkLib("ph_unequip_pet", "Event",
        {
            clientType = nil,
            serverType = "pet_id"
        }
    )
}


table.freeze(Packets)
return Packets