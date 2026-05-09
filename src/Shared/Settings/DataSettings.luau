--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Reactor = require(ReplicatedStorage.Libraries.Reactor)

local Data = require(ReplicatedStorage.Assets.Pets.Data)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type PetSchema = Data.PetSchema

--[[ @generic T Source type. ]]
type StateEngine<T> = Reactor.StateEngine<T>

export type DataTemplateSchema = setmetatable
<
    {
        gems: StateEngine<number>,
        
        StatsData: StateEngine
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
        >,

        HealingData: StateEngine
        <
            {
                HealingPets: { [string]: number },

                usedHealingSlots: number,
                maxHealingSlots: number
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
        gems = 10_000 :: any,
        
        StatsData
        = {
            level = 100,
            xp = 0,
            xpToNextLevel = 1_000,
            levelsNeededToRebirth = 10,
            rebirths = 0
        } :: any,

        DungeonsData
        = {
            allTimeMaxDungeonLevelReached = 1,
            currentMaxDungeonLevelReached = 1
        } :: any,

        HealingData
        = {
            HealingPets = {},

            usedHealingSlots = 0,
            maxHealingSlots = 10
        } :: any
    } :: DataTemplateSchema,

    PLAYER_DATA_STORAGE_KEY = "test123sttst"
}


table.freeze(DataSettings)
return DataSettings