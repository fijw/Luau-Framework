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
local function rebirthNamespace()
    local RebirthNamespace
    = {
        packets
        = {
            -- Server Received !ONLY!
            ServerRebirthPlayer = ByteNetMax.definePacket({ value = ByteNetMax.nothing }),

            -- Client Received !ONLY!
            ClientRebirthed = ByteNetMax.definePacket({ value = ByteNetMax.nothing })
        }
    }

    return RebirthNamespace
end

local Namespace = ByteNetMax.defineNamespace("rebirth", rebirthNamespace)
--[[ @end_section Packets & Namespace Definition ]]


return Namespace