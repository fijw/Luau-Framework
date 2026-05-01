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
local function devSpawningNamespace()
    local DevSpawningNamespace
    = {
        packets
        = {
            -- Server Received !ONLY!
            ServerDeveloperSpawnPet = ByteNetMax.definePacket(
                {
                    value = ByteNetMax.struct(
                        {
                            petName = ByteNetMax.string,
                            petSize = ByteNetMax.string,
                            petColor = ByteNetMax.string,
                            receivingId = ByteNetMax.string
                        }
                    )
                }
            )
        }
    }

    return DevSpawningNamespace
end

local Namespace = ByteNetMax.defineNamespace("dev_spawning", devSpawningNamespace)
--[[ @end_section Packets & Namespace Definition ]]


return Namespace