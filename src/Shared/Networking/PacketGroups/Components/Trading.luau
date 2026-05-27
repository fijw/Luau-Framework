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
    SendTradeRequest = NetworkLib("td_send_trade_request", "Event",
        {
            clientType = "sending_display_name",
            serverType = 0
        }
    ),

    AcceptTradeRequest = NetworkLib("td_accept_trade_request", "Event",
        {
            clientType = nil,
            serverType = nil
        }
    ),

    DeclineTradeRequest = NetworkLib("td_decline_trade_request", "Event",
        {
            clientType = nil,
            serverType = nil
        }
    ),


    AddPetToTradeOffer = NetworkLib("td_add_pet_to_trade_offer", "Event",
        {
            clientType = { petId = "", PetData = {} :: PetSchema },
            serverType = "pet_id"
        }
    ),

    RemovePetFromTradeOffer = NetworkLib("td_remove_pet_from_trade_offer", "Event",
        {
            clientType = "pet_id",
            serverType = "pet_id"
        }
    ),

    SetGemsInTradeOffer = NetworkLib("td_set_gems_in_trade_offer", "Event",
        {
            clientType = 0,
            serverType = 0
        }
    ),


    CancelTrade = NetworkLib("td_cancel_trade", "Event",
        {
            clientType = "other_player_display_name",
            serverType = nil
        }
    ),

    AcceptTrade = NetworkLib("td_accept_trade", "Event",
        {
            clientType = "yours_or_theirs" :: "yours" | "theirs",
            serverType = nil
        }
    ),

    TradeCompleted = NetworkLib("td_trade_completed", "Event",
        {
            clientType = "other_player_display_name",
            serverType = nil
        }
    ),


    SearchForTradingPets = NetworkLib("td_search_for_trading_pets", "Function",
        {
            clientType = { ["pet_id" :: string] = {} :: PetSchema },
            serverType = { side = "yours_or_theirs" :: "yours" | "theirs", text = "searching_string" }
        }
    ),


    TradeOfferUpdated = NetworkLib("td_trade_offer_updated", "Event",
        {
            clientType = nil,
            serverType = nil
        }
    ),

    DisplayCountdown = NetworkLib("td_display_countdown", "Event",
        {
            clientType = nil,
            serverType = nil
        }
    ),

    HideCountdown = NetworkLib("td_hide_countdown", "Event",
        {
            clientType = nil,
            serverType = nil
        }
    )
}


table.freeze(Packets)
return Packets