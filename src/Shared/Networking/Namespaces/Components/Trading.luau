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
local function tradingNamespace()
    local TradingNamespace
    = {
        packets
        = {
            -- Server Received !ONLY!
            ServerSendTradeRequest = ByteNetMax.definePacket({ value = ByteNetMax.string }),
            ServerTradeRequestAccepted = ByteNetMax.definePacket({ value = ByteNetMax.string }),

            ServerAddPetToTradeOffer = ByteNetMax.definePacket({ value = ByteNetMax.string }),
            ServerRemovePetFromTradeOffer = ByteNetMax.definePacket({ value = ByteNetMax.string }),

            ServerSetCoinsInTrade = ByteNetMax.definePacket({ value = ByteNetMax.string }),


            -- Server AND Client Received! (?)
            CancelTrade = ByteNetMax.definePacket({ value = ByteNetMax.string }),
            ReadyUp = ByteNetMax.definePacket({ value = ByteNetMax.nothing }),
        }
    }

    return TradingNamespace
end

local Namespace = ByteNetMax.defineNamespace("trading", tradingNamespace)
--[[ @end_section Packets & Namespace Definition ]]


return Namespace