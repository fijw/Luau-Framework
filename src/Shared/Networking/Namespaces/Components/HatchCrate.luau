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
local function hatchNamespace()
    local HatchNamespace
    = {
        packets
        = {
            -- Server Received !ONLY!
            ServerHatchPet = ByteNetMax.definePacket({ value = ByteNetMax.string })
        }
    }

    return HatchNamespace
end

local Namespace = ByteNetMax.defineNamespace("hatch", hatchNamespace)
--[[ @end_section Packets & Namespace Definition ]]


return Namespace