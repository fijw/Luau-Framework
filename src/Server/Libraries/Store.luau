--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Chronovisor = require(ReplicatedStorage.Libraries.Chronovisor)
local Compression = require(ServerScriptService.Libraries.Compression)
local Reactor = require(ReplicatedStorage.Libraries.Reactor)
--[[ @end_section Imports ]]


--[[ @section Types ]]
export type StoredPlayerDataClass
= {
    Data: buffer,
    sessionId: string?
}

--[[ @generic D Data template type. ]]
export type PlayerDataClass<D> = setmetatable
<
    {
        Data: D,

        classIdentifier: string,
        classDataStore: DataStore
    },

    {
        __index
        : {
            saveClassState: (self: PlayerDataClass<D>) -> (),
            removeClassCache: (self: PlayerDataClass<D>) -> ()
        },

        __call: (self: PlayerDataClass<D>) -> (D)
    }
>
--[[ @end_section Types ]]


--[[ @section Variables ]]
local sessionId = game.JobId

local PlayerDataClassCache = {} :: { [string]: PlayerDataClass<any> }
--[[ @end_section Variables ]]


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


--[[ @section Class Callbacks ]]
--[[
    @usage Save the player data class to the data store.

    @param self PlayerDataClass<any>

    @return
]]
local function saveClassStateCallback(self: PlayerDataClass<any>)
    Chronovisor(
        function()
            local SavingData = {}

            for i: string, v: any in pairs(self()) do
                SavingData[i] = Compression(v())
            end

            print(SavingData, "Saving player data class.")

            self.classDataStore:SetAsync(`{self.classIdentifier}`,
                {
                    Data = Compression(SavingData),
                    sessionId = nil
                }
            )
        end
    )
    :onError(function(err: string?) print(`Failed to save player data class data. Error: {err}`) end)

    :execute(
        function()
            local FetchedPlayerDataClass: StoredPlayerDataClass? = self.classDataStore:GetAsync(`{self.classIdentifier}`)

            if not FetchedPlayerDataClass then
                print("No fetched player data class after saving! Possible data mismatch.")

                return
            end

            if FetchedPlayerDataClass.sessionId ~= nil then print("Session ID still exists after saving!") end

            -- Decompress the data and compare it.
            do
                local DecompressedData = Compression(FetchedPlayerDataClass.Data, "decompress")

                for i: string, v: buffer in pairs(DecompressedData :: { [string]: buffer }) do
                    if typeof(self()[i]()) == "table" then
                        if tableMatchComparison(self()[i](), Compression(v, "decompress") :: any) == "match" then continue end
                    else
                        if self()[i]() == Compression(v, "decompress") then continue end
                    end

                    print("Data mismatch after saving!")
                end
            end
        end
    )
    :onError(function(err: string?) print(`Error verifying the player data class saved properly. Error: {err}`) end)
end

--[[
    @usage Remove the player data class from the cache.

    @param self PlayerDataClass<any>

    @return
]]
local function removeClassCacheCallback(self: PlayerDataClass<any>)
    if not PlayerDataClassCache[`{self.classIdentifier}`] then
        print("No cached player data class to remove!")

        return
    end

    PlayerDataClassCache[`{self.classIdentifier}`] = nil
end
--[[ @end_section Class Callbacks ]]


--[[
    @usage Return the player data class data.

    @param self PlayerDataClass<any>

    @return
]]
local function playerDataClassCallback(self: PlayerDataClass<any>): any
    return self.Data
end


--[[ @section Constructor ]]
--[[
    @usage Create a new player data class.

    @generic D Data template type.

    @param classIdentifier number
    @param DataTemplate D?
    @param classDataStoreIdentifier string?

    @return PlayerDataClass<D>?
]]
local function constructorCallback
<D>(
    classIdentifier: number,
    DataTemplate: D?,
    classDataStoreIdentifier: string?
): PlayerDataClass<D>?
    local ExistingClass = PlayerDataClassCache[`{classIdentifier}`]
    if ExistingClass or not DataTemplate or not classDataStoreIdentifier then return ExistingClass end

    local classDataStore = DataStoreService:GetDataStore(classDataStoreIdentifier)

    local NewPlayerDataClass
    = {
        classIdentifier = classIdentifier,
        classDataStore = classDataStore
    }

    setmetatable(NewPlayerDataClass, 
        {
            __index
            = {
                saveClassState = saveClassStateCallback,
                removeClassCache = removeClassCacheCallback
            },

            __call = playerDataClassCallback
        }
    )

    local isInUse: boolean

    Chronovisor(
        function()
            local FetchedPlayerDataClass: StoredPlayerDataClass? = classDataStore:GetAsync(`{classIdentifier}`)

            if FetchedPlayerDataClass then
                if FetchedPlayerDataClass.sessionId ~= sessionId and FetchedPlayerDataClass.sessionId ~= nil then
                    local player = Players:GetPlayerByUserId(classIdentifier)
                    if not player then return end

                    player:Kick(`Your data session is already in use.`)

                    isInUse = true

                    return
                end

                NewPlayerDataClass.Data = FetchedPlayerDataClass.Data
            else
                NewPlayerDataClass.Data = DataTemplate

                for i: string, v: any in pairs(NewPlayerDataClass.Data :: any) do
                    (NewPlayerDataClass.Data :: any)[i] = Compression(v)
                end

                NewPlayerDataClass.Data = Compression(NewPlayerDataClass.Data)
            end

            isInUse = false
        end
    )
    :onError(function(err: string?) print(`Failed to fetch compressed player data class data. Error: {err}`) end)

    repeat task.wait() until isInUse ~= nil
    if isInUse == true then return nil end

    Chronovisor(
        function()
            classDataStore:SetAsync(`{classIdentifier}`,
                {
                    Data = NewPlayerDataClass.Data,
                    sessionId = sessionId
                }
            )
        end
    )
    :onError(function(err: string?) print(`Failed to update the player data class session id. Error: {err}`) end)

    -- Decompress the data and make it reactive.
    do
        NewPlayerDataClass.Data = Compression(NewPlayerDataClass.Data, "decompress") :: any

        for i: string, v: any in pairs(NewPlayerDataClass.Data :: any) do
            (NewPlayerDataClass.Data :: any)[i] = Reactor(Compression(v, "decompress"))
        end
    end

    PlayerDataClassCache[`{classIdentifier}`] = (NewPlayerDataClass :: any) :: PlayerDataClass<D>

    print(NewPlayerDataClass(), "New player data class created.")

    return (NewPlayerDataClass :: any) :: PlayerDataClass<D>
end

return constructorCallback
--[[ @end_section Constructor ]]