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
        coins: StateEngine<number>,
        
        GameplayData: StateEngine
        <
            {
                level: number,
                xp: number,
                xpToNextLevel: number,
                levelsNeededToRebirth: number,
                rebirths: number
            }
        >,
        
        DungeonsData: StateEngine
        <
            {
                totalDungeonsLevelsCompleted: number,
                currentMaxDungeonLevelReached: number
            }
        >,

        [string]: StateEngine<any>
    },

    {
        index
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
            >
        }
    }
>
--[[ @end_section Types ]]


local DataSettings
= {
    DataTemplate
    = {
        coins = 12_000 :: any,
        level = 15 :: any
    } :: DataTemplateSchema,

    PLAYER_DATA_STORAGE_KEY = "test123121434"
}


table.freeze(DataSettings)
return DataSettings