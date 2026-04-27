--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ByteNetMax = require(ReplicatedStorage.Networking["ByteNet-Max"])
--[[ @end_section Imports ]]


--[[ @section Packets & Namespace Definition ]]
--[[
    @NOTE No type checking here.
    The new Luau Type Solver hates ByteNet-Max.
]]
local function inventoryNamespace()
    local InventoryNamespace
    = {
        packets
        = {
            -- Client Received !ONLY!
            ClientAddPetsToInventory = ByteNetMax.definePacket(
                {
                    value = ByteNetMax.array(
                        ByteNetMax.struct(
                            {
                                petId = ByteNetMax.string,
                                petName = ByteNetMax.string,
                                petSize = ByteNetMax.string,
                                petColor = ByteNetMax.string,
                                petImageId = ByteNetMax.string
                            }
                        )
                    )
                }
            ),

            ClientRemovePetsFromInventory = ByteNetMax.definePacket({ value = ByteNetMax.array(ByteNetMax.string) })
        }
    }

    return InventoryNamespace
end

local Namespace = ByteNetMax.defineNamespace("inventory", inventoryNamespace)
--[[ @end_section Packets & Namespace Definition ]]


return Namespace