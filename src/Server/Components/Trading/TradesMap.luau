--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Data = require(ReplicatedStorage.DataAssets.Pets.Data)
--[[ @end_section Imports ]]


type PetSchema = Data.PetSchema


local TradesMap
: {
    ActiveTrades
    : {
        [string]
        : {
            player1: Player,
            player2: Player,

            Player1Pets: { string },
            Player2Pets: { string },

            player1Coins: number,
            player2Coins: number,

            player1Ready: boolean,
            player2Ready: boolean
        }
    },

    MappedTradingPlayers: { [Player]: string },
    MappedTradeRequests: { [Player]: Player }
}
= {
    ActiveTrades = {},
    MappedTradingPlayers = {},
    MappedTradeRequests = {}
}


return TradesMap