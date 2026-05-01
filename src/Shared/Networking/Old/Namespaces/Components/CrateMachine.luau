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
local function hatchPetNamespace()
    local HatchPetNamespace
    = {
        packets
        = {
            -- Server Received !ONLY!
            ServerOpenCrate = ByteNetMax.definePacket({ value = ByteNetMax.string })
        },

        queries
        = {
			GetCrates = ByteNetMax.defineQuery(
                {
                    request = ByteNetMax.struct(
                        {
                            message = ByteNetMax.unknown
                        }
                    ),

                    response = ByteNetMax.struct(
                        {
                            Crates = ByteNetMax.array(ByteNetMax.unknown)
                        }
                    )
                }
            )
		}
    }

    return HatchPetNamespace
end

local Namespace = ByteNetMax.defineNamespace("hatch", hatchPetNamespace)
--[[ @end_section Packets & Namespace Definition ]]


return Namespace