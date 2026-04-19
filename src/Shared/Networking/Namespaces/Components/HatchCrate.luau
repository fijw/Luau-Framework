--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ByteNet_Max = require(ReplicatedStorage.Networking["ByteNet-Max"])
local ByteNetMax = require(ReplicatedStorage.Networking["ByteNet-Max"])
--[[ @end_section Imports ]]


--[[ @section Packets & Namespace Definition ]]
--[[
    @NOTE No type checking here.
    The new Luau Type Solver hates ByteNet-Max.
]]
local function cmdsNamespace()
    local CmdsNamespace
    = {
        packets
        = {
            -- Server Received !ONLY!
            ServerHatchPet = ByteNetMax.definePacket({ value = ByteNetMax.string })
        }
    }

    return CmdsNamespace
end

local Namespace = ByteNetMax.defineNamespace("cmds", cmdsNamespace)
--[[ @end_section Packets & Namespace Definition ]]


return Namespace