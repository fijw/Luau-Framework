--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reactor = require(ReplicatedStorage.Libraries.Reactor)
--[[ @end_section Imports ]]


--[[ @generic T Source type. ]]
type StateEngine<T> = Reactor.AbstractedStateEngine<T>


local Settings
= {
    DATA_TEMPLATE
    = {
        coins = 12_000,
        level = 15,

        Inventory
        = {
            Pets
            = {
                Cat = 25,
                Dog = 3,
                Rabbit = 1
            },

            Items
            = {
                Sword = 1,
                Shield = 1,
                Bow = 1
            }
        }
    },

    PLAYER_DATA_STORAGE_KEY = "hahaa1a"
}


table.freeze(Settings)
return Settings