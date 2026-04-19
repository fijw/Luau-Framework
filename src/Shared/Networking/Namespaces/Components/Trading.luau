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
            -- Server AND Client Received!
            SendTradeRequest = ByteNetMax.definePacket({ value = ByteNetMax.string }),
            TradeRequestAccepted = ByteNetMax.definePacket({ value = ByteNetMax.string }),

            CancelTrade = ByteNetMax.definePacket({ value = ByteNetMax.string }),
            ReadyUp = ByteNetMax.definePacket({ value = ByteNetMax.nothing }),

            AddPetToTrade = ByteNetMax.definePacket({ value = ByteNetMax.string }),
            RemovePetFromTrade = ByteNetMax.definePacket({ value = ByteNetMax.string }),

            SetCoinsInTrade = ByteNetMax.definePacket({ value = ByteNetMax.string }),


            -- Client Received !ONLY!
            ClientTradeCompleted = ByteNetMax.definePacket({ value = ByteNetMax.string }), 
            ClientTradeRequestDeclined = ByteNetMax.definePacket({ value = ByteNetMax.string }),

            ClientReceivedTradeRequest
            = ByteNetMax.definePacket(
                {
                    value = ByteNetMax.struct(
                        {
                            senderIdString = ByteNetMax.string,
                            senderName = ByteNetMax.string
                        }
                    )
                }
            )
        }
    }

    return CmdsNamespace
end

local Namespace = ByteNetMax.defineNamespace("cmds", cmdsNamespace)
--[[ @end_section Packets & Namespace Definition ]]


return Namespace