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
                allTimeMaxDungeonLevelReached: number,
                currentMaxDungeonLevelReached: number
            }
        >
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
                    }?,

                    ModerationHistory
                    : {
                        Bans: { [string]: { banningUserId: number, duration: string?, reason: string } }?,
                        Unbans: { [string]: { unbanningUserId: number, reason: string } }?,
                        DataResets: { [string]: { resettingUserId: number, reason: string } }?
                    }?
                }
            >,

            DeveloperSpawnedPets: StateEngine
            <
                {
                    {
                        petName: string,
                        petSize: string,
                        petColor: string
                    }
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
        coins = 12_000 :: any,
        level = 15 :: any
    } :: DataTemplateSchema,

    PLAYER_DATA_STORAGE_KEY = "t12k4567"
}


table.freeze(DataSettings)
return DataSettings