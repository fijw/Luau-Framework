--[[
    -------------------------------------------------------------------------
    |                                                                       |
    |    @author                                                            |
    |    ```                                                                |
    |        Roblox: @roblox_user_5618502527                                |
    |        GitHub: @fijw (k4)                                             |
    |        Twitter: @Xjwfi (k4)                                           |
    |        Discord: @vfjx (k4)                                            |
    |    ```                                                                |
    |                                                                       |
    |    @version 1.0.5                                                     |
    |                                                                       |
    |    @description                                                       |
    |    ```                                                                |
    |        Library for storing and retrieving player data. Includes       |
    |        features such as auto-saving, session locking, and reactive    |
    |        data.                                                          |
    |    ```                                                                |
    |                                                                       |
    -------------------------------------------------------------------------

    @usage
    ```luau
        local LoggedJoinedPlrs: { Player } = {}

        local function onPlayerAdded(player: Player)
            table.insert(LoggedJoinedPlrs, player)

            local PlrDataClass = Registry(player)
            if not PlrDataClass then return end

            print(PlrDataClass(), `{player.UserId}'s data upon joining`)

            PlrDataClass().coins:subscribe(function(self, data, key, ...) print(`new coins: {data}`) end)
            PlrDataClass().coins:wrapToPeek(function(self, data) print(`peeked coins: {data}`) end)

            local oldCoins = PlrDataClass().coins() :: number
            PlrDataClass().coins(oldCoins + 100_000)

            -- Attempt to transfer 100,000 coins from the first player to the second player.
            if #LoggedJoinedPlrs > 1 and #LoggedJoinedPlrs < 3 or #LoggedJoinedPlrs == 2 then
                local txPlr1, txPlr2 = LoggedJoinedPlrs[1], LoggedJoinedPlrs[2]
                if not txPlr1 or not txPlr2 then return end

                Registry.atomicTransaction(LoggedJoinedPlrs,
                    function(PlayerStates)
                        local oldPlr1Coins = PlayerStates[txPlr1].coins() :: number
                        local oldPlr2Coins = PlayerStates[txPlr2].coins() :: number
                        if oldPlr1Coins < 100_000 then print("not enough coins from plr1"); return false end

                        PlayerStates[txPlr1].coins(oldPlr1Coins - 100_000)
                        PlayerStates[txPlr2].coins(oldPlr2Coins + 100_000)

                        local changedPlr1Coins = PlayerStates[txPlr1].coins() :: number
                        local changedPlr2Coins = PlayerStates[txPlr2].coins() :: number

                        if changedPlr1Coins ~= oldPlr1Coins - 100_000 or changedPlr2Coins ~= oldPlr2Coins + 100_000 then
                            print("transfer didn't work correctly, data doesn't match expected values")
                            return false
                        end

                        print(`Gave {txPlr2.UserId} 100_000 coins from {txPlr1.UserId}.`)

                        return true
                    end
                )
            end
        end

        local function onPlayerRemoving(player: Player)
            local IndexedJoinedPlr = table.find(LoggedJoinedPlrs, player)
            if IndexedJoinedPlr then table.remove(LoggedJoinedPlrs, IndexedJoinedPlr) end

            local PlrDataClass = Registry(player)
            if not PlrDataClass then return end

            PlrDataClass:saveClass()
            PlrDataClass:deleteClass()
        end

        Players.PlayerAdded:Connect(onPlayerAdded)
        Players.PlayerRemoving:Connect(onPlayerRemoving)
    ```
]]
--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Chronovisor = require(ReplicatedStorage.Libraries.Chronovisor)
local Reactor = require(ReplicatedStorage.Libraries.Reactor)
local Compression = require(ReplicatedStorage.Libraries.DataLibs.Compression)
local TableUtils = require(ReplicatedStorage.Libraries.TableUtils)

local DataSettings = require(ReplicatedStorage.Settings.DataSettings)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type DataTemplateSchema = DataSettings.DataTemplateSchema

--[[ @generic T State type. ]]
type StateEngine<T> = Reactor.StateEngine<T>


export type StoredDataClassSchema
= {
    Data: buffer,
    inUse: boolean
}


export type DataClass = setmetatable
<
    {
        classKey: string,
        ClassDataStore: DataStore,

        ClassData: StateEngine<DataTemplateSchema>
    },

    {
        __index
        : {
            saveClass: (self: DataClass, keepInUseStatus: true?) -> (),
            deleteClass: (self: DataClass) -> ()
        },

        __call: (self: DataClass) -> (StateEngine<DataTemplateSchema>)
    }
>
--[[ @end_section Types ]]


--[[ @section Variables ]]
local SettingsDataStore = DataStoreService:GetDataStore(DataSettings.PLAYER_DATA_STORAGE_KEY)

local CachedDataClasses = {}

local Registry = {}
--[[ @end_section Variables ]]


-- Prevent data loss from a crash by waiting for all data classes to be saved before shutting down.
do
    game:BindToClose(
        function()
            local numberOfPlayerDataClasses: number? = nil

            repeat
                task.wait()

                for i: string, DataClass: DataClass in pairs(CachedDataClasses :: { [string]: DataClass }) do
                    if not numberOfPlayerDataClasses then
                        numberOfPlayerDataClasses = 1

                        continue
                    end
                    
                    numberOfPlayerDataClasses += 1
                end

                if not numberOfPlayerDataClasses then break end
                numberOfPlayerDataClasses = nil
            until numberOfPlayerDataClasses == 0
        end
    )
end


--[[
    @usage Continuously saves the player data class to the data store.

    @param PlayerDataClass PlayerDataClass

    @return void
]]
local function autoSaveDataClass(DataClass: DataClass)
    while true do
        task.wait(60)

        if not CachedDataClasses[tonumber(DataClass.classKey) :: number] then break end
        DataClass:saveClass(true)
    end
end


--[[
    @usage Fetches the player's stored data from the data store.

    @param playerId number

    @return StoredDataClassSchema?
]]
function Registry.forciblyFetchStoredPlayerData(playerId: number): StoredDataClassSchema?
    local ExistingData: StoredDataClassSchema?

    Chronovisor(
        function()
            local AsyncData: StoredDataClassSchema? = SettingsDataStore:GetAsync(`{playerId}`)
            if not AsyncData then return end

            ExistingData = AsyncData
        end
    )
    :onError(function(err: string?) print(`Failed to forcibly fetch stored player data. Error: {err}`) end)

    return ExistingData
end

--[[
    @usage Commences an atomic transaction between multiple players or a single player.

    @param Players { Player }
    @param transformFunction (state: DataTemplateSchema) -> (boolean)

    @return boolean
]]
function Registry.atomicTransaction
(
    Players: { Player },
    transformFunction: (PlayerStates: { [Player]: DataTemplateSchema }) -> (boolean)
): boolean
    local StateClones: { [Player]: DataTemplateSchema } = {}

    -- Clone the players' states.
    for i: number, player: Player in ipairs(Players) do
        local PlrDataClass = constructorCallback(nil :: any, player)
        if not PlrDataClass then return false end

        local StateClone = TableUtils.deepClone(PlrDataClass()())
        StateClones[player] = StateClone :: DataTemplateSchema
    end

    -- Attempt to commence the atomic transaction and return if it fails.
    do
        local successResult = false

        Chronovisor(function() if transformFunction(StateClones) then successResult = true end end)
        :onError(function(err: string?) print(`Failed to commence an atomic transaction. Error: {err}`); successResult = false end)

        if not successResult then return false end
    end

    -- Update the players' states.
    for i: number, player: Player in ipairs(Players) do
        local PlrDataClass = constructorCallback(nil :: any, player)
        if not PlrDataClass then return false end

        PlrDataClass.ClassData(StateClones[player])
    end

    return true
end


--[[ @section Inheritance Functions ]]
--[[
    @usage Save the data class to the class data store.

    @param self DataClass
    @param keepInUseStatus true?

    @return void
]]
local function saveClassCallback(self: DataClass, keepInUseStatus: true?)
    local SavingClassData = {}

    for i: string, v: StateEngine<any> in pairs(self()() :: { [string]: StateEngine<any> }) do
        SavingClassData[i] = Compression(v())
    end

    Chronovisor(
        function()
            self.ClassDataStore:SetAsync(self.classKey,
                {
                    Data = Compression(SavingClassData),
                    inUse = if keepInUseStatus == true then true else false
                }
            )
        end
    )
    :onError(function(err: string?) print(`Failed to save {self.classKey}'s data class. Error: {err}`) end)

    local FetchedStoredData = Registry.forciblyFetchStoredPlayerData(tonumber(self.classKey) :: number)
    if not FetchedStoredData then return end

    -- Prevent data mismatches by comparing the stored data and the saving data.
    do
        local DecompressedStoredData = {}

        for i: string, v: buffer in pairs(Compression(FetchedStoredData.Data, "decompress") :: { [string]: buffer }) do
            DecompressedStoredData[i] = Compression(v, "decompress")
        end

        local DecompressedSavingData = {}

        for i: string, v: buffer in pairs(SavingClassData :: { [string]: buffer }) do
            DecompressedSavingData[i] = Compression(v, "decompress")
        end

        if TableUtils.deepCompare(DecompressedStoredData, DecompressedSavingData) == "match" then return end

        print(`Data mismatch when saving [{self.classKey}]'s data.`)

        self:saveClass(keepInUseStatus)
    end
end

--[[
    @usage Delete the data class from the cached data classes.

    @param self DataClass

    @return void
]]
local function deleteClassCallback(self: DataClass) CachedDataClasses[tonumber(self.classKey) :: number] = nil end
--[[ @end_section Inheritance Functions ]]


--[[
    @usage Return the data class data.

    @param self DataClass

    @return StateEngine<DataTemplateSchema>
]]
local function dataClassCallback(self: DataClass): StateEngine<DataTemplateSchema> return self.ClassData end


--[[ @section Constructor ]]
--[[
    @usage Return the player's data class.

    @param self typeof(Registry)
    @param player Player
    @param create true?

    @return DataClass?
]]
function constructorCallback(self: typeof(Registry), player: Player, create: true?): DataClass?
    local CachedDataClass = CachedDataClasses[player.UserId]
    if CachedDataClass then return CachedDataClass end

    if not create and not CachedDataClass then
        repeat task.wait() until CachedDataClasses[player.UserId]
        return CachedDataClasses[player.UserId]
    end

    local ExistingData = Registry.forciblyFetchStoredPlayerData(player.UserId) :: StoredDataClassSchema

    -- If there's no existing data then use the template data. If there's existing data but it's in use then kick the player.
    if not ExistingData then
        local CompressedDataTemplate = {}

        for i: string, v: any in pairs(DataSettings.DataTemplate :: { [string]: any }) do
            CompressedDataTemplate[i] = Compression(v)
        end

        ExistingData
        = {
            Data = Compression(CompressedDataTemplate),
            inUse = true
        }
    else
        if ExistingData.inUse == true then
            player:Kick("\n\nYour data is already in use.\n\n\n")

            return nil
        end

        local DecompressedExistingData: { [string]: buffer } = Compression(ExistingData.Data, "decompress")

        for i: string, v: any in pairs(DataSettings.DataTemplate :: { [string]: any }) do
            if DecompressedExistingData[i] then continue end
            DecompressedExistingData[i] = Compression(v)
        end

        ExistingData.Data = Compression(DecompressedExistingData)
    end

    local ModifiedClassData = {}

    for i: string, v: any in pairs(Compression(ExistingData.Data, "decompress") :: { [string]: any }) do
        ModifiedClassData[i] = Reactor(Compression(v, "decompress"))
    end

    local NewDataClass
    = {
        ClassDataStore = SettingsDataStore,
        classKey = `{player.UserId}`,
        ClassData = Reactor(ModifiedClassData)
    }

    setmetatable(NewDataClass,
        {
            __index
            = {
                saveClass = saveClassCallback,
                deleteClass = deleteClassCallback
            },

            __call = dataClassCallback
        }
    );

    ((NewDataClass :: any) :: DataClass):saveClass(true)
    task.spawn(function() autoSaveDataClass((NewDataClass :: any) :: DataClass) end)

    CachedDataClasses[player.UserId] = (NewDataClass :: any) :: DataClass

    return (NewDataClass :: any) :: DataClass
end

setmetatable(Registry, { __call = constructorCallback })
--[[ @end_section Constructor ]]


table.freeze(Registry)
return Registry