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
local function mergingNamespace()
    local MergingNamespace
    = {
        packets
        = {
            -- Server Received !ONLY!
            ServerMergePets = ByteNetMax.definePacket({ value = ByteNetMax.array(ByteNetMax.string) }),

            -- Client Received !ONLY!
            ClientDisplayReceivedMergedPet = ByteNetMax.definePacket({ value = ByteNetMax.string })
        }
    }

    return MergingNamespace
end

local Namespace = ByteNetMax.defineNamespace("merging", mergingNamespace)
--[[ @end_section Packets & Namespace Definition ]]


return Namespace