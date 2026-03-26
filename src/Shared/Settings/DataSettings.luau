--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reactor = require(ReplicatedStorage.Libraries.Reactor)
--[[ @end_section Imports ]]


--[[ @section Types ]]
--[[ @generic T Source type. ]]
type StateEngine<T> = Reactor.AbstractedStateEngine<T>

export type DataTemplateSchema = setmetatable
<
    {
        Inventory: StateEngine
        <
            {
                Pets: { [string]: { str: number, spe: number } },
                Items: { [string]: { dam: number, dur: number } }
            }
        >,

        coins: StateEngine<number>,
        level: StateEngine<number>
    },

    {
        __index
        : {
            ModerationData: StateEngine
            <
                {
                    BanData
                    : {
                        permanent: true?,
                        banDuration: number?,
                        banReason: string
                    }?
                }
            >,

            [string]: StateEngine<any>
        }
    }
>
--[[ @end_section Types ]]


local DataSettings
= {
    DataTemplate
    = {
        Inventory
        = {
            Pets
            = {
                Cat = { str = 1, spe = 2 },
                Dog = { str = 1, spe = 2 },
                Rabbit = { str = 1, spe = 2 }
            },

            Items
            = {
                Sword = { dam = 1, dur = 1 },
                Shield = { dam = 1, dur = 1 },
                Bow = { dam = 1, dur = 1 }
            }
        } :: DataTemplateSchema,

        coins = 12_000,
        level = 15,
    },

    PLAYER_DATA_STORAGE_KEY = "aqaa2222e31"
}


table.freeze(DataSettings)
return DataSettings