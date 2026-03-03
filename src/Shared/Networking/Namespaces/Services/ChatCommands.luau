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
function cmdsNamespace()
    local CmdsNamespace
    = {
        packets
        = {
            -- Server Received !ONLY!
            ServerHandleCommandMessage = ByteNetMax.definePacket({ value = ByteNetMax.array(ByteNetMax.string) })
        }
    }

    return CmdsNamespace
end

local Namespace = ByteNetMax.defineNamespace("cmds", cmdsNamespace)
--[[ @end_section Packets & Namespace Definition ]]


return Namespace