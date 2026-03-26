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
local function cmdsNamespace()
    local CmdsNamespace
    = {
        packets
        = {
            -- Server Received !ONLY!
            ServerHandleCommand = ByteNetMax.definePacket({ value = ByteNetMax.array(ByteNetMax.string) }),

            -- Client Received !ONLY!
            ClientFlyCharacter = ByteNetMax.definePacket({ value = ByteNetMax.nothing }),
            ClientUnflyCharacter = ByteNetMax.definePacket({ value = ByteNetMax.nothing }),

            DisplayConsoleResponse = ByteNetMax
            .definePacket(
                {
                    value
                    = ByteNetMax.struct(
                        {
                            response = ByteNetMax.string,
                            color = ByteNetMax.string
                        }
                    )
                }
            ),

            DisplayNewPermissions = ByteNetMax.definePacket({ value = ByteNetMax.nothing }),
            ChangeCmdPermissionsTxt = ByteNetMax.definePacket({ value = ByteNetMax.string })
        }
    }

    return CmdsNamespace
end

local Namespace = ByteNetMax.defineNamespace("cmds", cmdsNamespace)
--[[ @end_section Packets & Namespace Definition ]]


return Namespace