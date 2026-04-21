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
local function marketplaceNamespace()
    local MarketplaceNamespace
    = {
        packets
        = {
            -- Server Received !ONLY!
            ServerPlacePetOnMarketplace = ByteNetMax.definePacket(
                {
                    value = ByteNetMax.struct(
                        {
                            petId = ByteNetMax.string,
                            price = ByteNetMax.string
                        }
                    )
                }
            ),

            ServerBuyPetFromMarketplace = ByteNetMax.definePacket({ value = ByteNetMax.string }),

            ServerRemoveOwnedPetFromMarketplace = ByteNetMax.definePacket({ value = ByteNetMax.string }),


            -- Client Received !ONLY!
            ClientPlacedPetOnMarketplace = ByteNetMax.definePacket({ value = ByteNetMax.string }),
            ClientBoughtPetFromMarketplace = ByteNetMax.definePacket({ value = ByteNetMax.string }),
            ClientRemovedPetFromMarketplace = ByteNetMax.definePacket({ value = ByteNetMax.string }),


            ClientInsertPetsIntoMarketplace = ByteNetMax.definePacket(
                {
                    value = ByteNetMax.array(
                        ByteNetMax.struct(
                            {
                                petId = ByteNetMax.string,
                                PetData = ByteNetMax.unknown
                            }
                        )
                    )
                }
            ),

            ClientRemovePetsFromMarketplace = ByteNetMax.definePacket({ value = ByteNetMax.array(ByteNetMax.string) })
        }
    }

    return MarketplaceNamespace
end

local Namespace = ByteNetMax.defineNamespace("marketplace", marketplaceNamespace)
--[[ @end_section Packets & Namespace Definition ]]


return Namespace