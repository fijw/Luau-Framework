--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.Assets.Pets.Data)

local NetworkLib = require(ReplicatedStorage.Networking.NetworkLib)
--[[ @end_section Imports ]]


type PetSchema = Data.PetSchema


local Packets
= {
    SendTradeRequest = NetworkLib("send_trade_request", "Event",
        {
            clientType = 0,
            serverType = 0
        }
    ),

    AcceptTradeRequest = NetworkLib("accept_trade_request", "Event",
        {
            clientType = nil,
            serverType = nil
        }
    ),

    DeclineTradeRequest = NetworkLib("decline_trade_request", "Event",
        {
            clientType = nil,
            serverType = nil
        }
    ),


    AddPetToTradeOffer = NetworkLib("add_pet_to_trade_offer", "Event",
        {
            clientType = { side = "theirs_or_yours", PetData = {} :: PetSchema },
            serverType = "pet_id"
        }
    ),

    RemovePetFromTradeOffer = NetworkLib("remove_pet_from_trade_offer", "Event",
        {
            clientType = { side = "theirs_or_yours", petId = "" },
            serverType = "pet_id"
        }
    ),

    SetGemsInTradeOffer = NetworkLib("set_gems_in_trade_offer", "Event",
        {
            clientType = { side = "theirs_or_yours", gems = 0 },
            serverType = 0
        }
    ),


    CancelTrade = NetworkLib("cancel_trade", "Event",
        {
            clientType = "player_name_who_cancelled",
            serverType = nil
        }
    ),

    AcceptTrade = NetworkLib("accept_trade", "Event",
        {
            clientType = nil,
            serverType = nil
        }
    )
}


table.freeze(Packets)
return Packets