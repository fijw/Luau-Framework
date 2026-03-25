--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Chronovisor = require(ReplicatedStorage.Libraries.Chronovisor)
local Reactor = require(ReplicatedStorage.Libraries.Reactor)
local Compression = require(ServerScriptService.Libraries.Compression)

local DataSettings = require(ReplicatedStorage.Settings.DataSettings)
--[[ @end_section Imports ]]


--[[ @section Types ]]
type DataTemplateSchema = DataSettings.DataTemplateSchema

--[[ @generic T Source type. ]]
type StateEngine<T> = Reactor.AbstractedStateEngine<T>

--[[ @generic D Data template type. ]]
export type DataClass = setmetatable
<
    {
        classKey: string,
        ClassDataStore: DataStore,

        ClassData: DataTemplateSchema
    },

    {
        __index
        : {
            saveClass: (self: DataClass, keepInUseStatus: true?) -> (),
            deleteClass: (self: DataClass) -> ()
        },

        __call: (self: DataClass) -> (DataTemplateSchema)
    }
>

export type StoredDataClassSchema
= {
    Data: buffer,
    inUse: boolean
}
--[[ @end_section Types ]]


--[[ @section Variables ]]
local SettingsDataStore = DataStoreService:GetDataStore(DataSettings.PLAYER_DATA_STORAGE_KEY)

local CachedDataClasses = {} :: { [number]: DataClass }

local DataLib = {}
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
    @usage Fetches the player's stored data from the data store.

    @param playerId number

    @return StoredDataClassSchema?
]]
function DataLib.forciblyFetchStoredPlayerData(playerId: number): StoredDataClassSchema?
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


--[[ @section Utility Functions ]]
--[[
    @usage Continuously saves the player data class to the data store.

    @param PlayerDataClass PlayerDataClass<any>

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
    @todo to be used
]]
--[[
    @usage Compares two tables to see if they match.

    @param tableComparison1 { [any]: any }
    @param tableComparison2 { [any]: any }

    @return "match" | "mismatch"
]]
local function tableMatchComparison
(
    tableComparison1: { [any]: any },
    tableComparison2: { [any]: any }
): "match" | "mismatch"
    for i: any, v: any in pairs(tableComparison1) do
        if typeof(v) == "table" and typeof(tableComparison2[i]) == "table" then
            if tableMatchComparison(v, tableComparison2[i]) == "mismatch" then
                return "mismatch"
            else
                continue
            end
        end

        if tableComparison2[i] ~= v then return "mismatch" end
    end

    return "match"
end
--[[ @end_section Utility Functions ]]


--[[ @section Inheritance Functions ]]
--[[
    @usage Save the data class to the class data store.

    @param self DataClass
    @param keepInUseStatus true?

    @return void
]]
local function saveClassCallback(self: DataClass, keepInUseStatus: true?)
    local SavingClassData = {}

    for i: string, v: StateEngine<any> in pairs(self.ClassData :: { [string]: StateEngine<any> }) do
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

    @return DataTemplateSchema
]]
local function dataClassCallback(self: DataClass): DataTemplateSchema return self.ClassData end


--[[ @section Constructor ]]
--[[
    @usage Return the player's data class.

    @param self unknown
    @param player Player

    @return DataClass?
]]
local function constructorCallback(self: unknown, player: Player): DataClass?
    local CachedDataClass = CachedDataClasses[player.UserId]
    if CachedDataClass then return CachedDataClass end

    local existingData = DataLib.forciblyFetchStoredPlayerData(player.UserId) :: StoredDataClassSchema

    if not existingData then
        local CompressedDataTemplate = {}

        for i: string, v: any in pairs(DataSettings.DataTemplate :: { [string]: any }) do
            CompressedDataTemplate[i] = Compression(v)
        end

        existingData
        = {
            Data = Compression(CompressedDataTemplate),
            inUse = true
        }
    else
        if existingData.inUse == true then
            player:Kick("\n\nYour data is already in use.\n\n\n")

            return nil
        end
    end

    local ModifiedClassData = {}

    for i: string, v: any in pairs(Compression(existingData.Data, "decompress") :: { [string]: any }) do
        ModifiedClassData[i] = Reactor(Compression(v, "decompress"))
    end

    local NewDataClass
    = {
        ClassDataStore = SettingsDataStore,
        classKey = `{player.UserId}`,
        ClassData = ModifiedClassData
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

setmetatable(DataLib, { __call = constructorCallback })
--[[ @end_section Constructor ]]


table.freeze(DataLib)
return DataLib


--[[
    @todo clone over the data verifying stuff for saving data and also include the 5 retries for saving data on failure.
]]