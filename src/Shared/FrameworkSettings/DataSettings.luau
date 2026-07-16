--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reactor = require(ReplicatedStorage.Libraries.Reactor)
--[[ @end_section Imports ]]


--[[ @section Types ]]
--[[ @generic T Source type. ]]
type StateEngine<T> = Reactor.StateEngine<T>

export type DataTemplateSchema = setmetatable
<
    {
        clicks: StateEngine<number>,
        rebirths: StateEngine<number>
    },

    {
        __index
        : {
            GiftedGamepasses: { number },

            ModerationData: StateEngine
            <
                {
                    BanData
                    : {
                        permanent: true?,
                        banDuration: number?,
                        banReason: string
                    }?,

                    ModerationHistory
                    : {
                        numOfBans: number?,
                        nunOfUnbans: number?,
                        numOfDataResets: number?,

                        Bans: { [string]: { banningUserId: number, banDuration: string?, banReason: string, index: number } }?,
                        Unbans: { [string]: { unbanningUserId: number, unbanReason: string, index: number } }?,
                        DataResets: { [string]: { resettingUserId: number, resetReason: string, index: number } }?
                    }?
                }
            >,

            Inventory: StateEngine<unknown>
        }
    }
>
--[[ @end_section Types ]]


local DataSettings
= {
    DataTemplate
    = {
        clicks = 0 :: any,
        rebirths = 0 :: any
    } :: DataTemplateSchema,

    PLAYER_DATA_STORAGE_KEY = "data_key_4"
}


table.freeze(DataSettings)
return DataSettings