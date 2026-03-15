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
    |    @version 1.0.0                                                     |
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
        local function onPlayerAdded(player: Player)
            local PlayerDataClass = Store(player.UserId, DataTemplate, DataStoreKey)
            if not PlayerDataClass then return end

            task.spawn(
                function()
                    while true do
                        if not Store(player.UserId) then break end

                        PlayerDataClass().level(PlayerDataClass().level() + 100)
                        PlayerDataClass().coins(PlayerDataClass().coins() + 100_000)

                        task.wait(5)
                    end
                end
            )
        end

        local function onPlayerRemoving(player: Player)
            local PlayerDataClass = Store(player.UserId)
            if not PlayerDataClass then return end

            PlayerDataClass:saveClassState()
            PlayerDataClass:removeClassCache()
        end

        -- Handle player data on join and leave.
        do
            for i: number, player: Player in pairs(Players:GetPlayers()) do onPlayerAdded(player) end

            Players.PlayerAdded:Connect(onPlayerAdded)
            Players.PlayerRemoving:Connect(onPlayerRemoving)
        end

        game:BindToClose(function() task.wait(1) end)
    ```
]]
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
export type StoredPlayerDataClassSchema
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
        ClassDataStore: DataStore
    },

    {
        __index
        : {
            saveClassState: (self: PlayerDataClass<D>, keepCurrentSessionId: true?) -> (),
            removeClassCache: (self: PlayerDataClass<D>) -> ()
        },

        __call: (self: PlayerDataClass<D>) -> (D)
    }
>
--[[ @end_section Types ]]


--[[ @section Variables ]]
local sessionId = game.JobId

local PlayerDataClassCache = {} :: { [string]: PlayerDataClass<any> }

local executedCrashHandler = false
--[[ @end_section Variables ]]


--[[ @section Utility Functions ]]
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

--[[
    @usage Continuously saves the player data class to the data store.

    @param PlayerDataClass PlayerDataClass<any>

    @return void
]]
local function autoSaveClassState(PlayerDataClass: PlayerDataClass<any>)
    while true do
        task.wait(60)

        if not PlayerDataClassCache[`{PlayerDataClass.classIdentifier}`] then break end

        PlayerDataClass:saveClassState(true)
    end
end

--[[
    @usage Handles crashes by saving the still cached player data classes to the data store.

    @return void
]]
local function crashHandler()
    game:BindToClose(
        function()
            local numberOfPlayerDataClasses: number? = nil

            repeat
                task.wait()

                for i: string, PlayerDataClass: PlayerDataClass<any> in pairs(PlayerDataClassCache) do
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

    executedCrashHandler = true
end

--[[
    @usage
    ```
        Retries saving the player data class to the data store a specified number of times until it
        succeeds or the maximum number of attempts is reached.
    ```

    @param PlayerDataClass PlayerDataClass<any>
    @param maxAttempts number
    @param keepCurrentSessionId true?
    @param newSessionId string?

    @return void
]]
local function saveClassStateSafely
(
    PlayerDataClass: PlayerDataClass<any>,
    maxAttempts: number,
    keepCurrentSessionId: true?,
    newSessionId: string?
)
    local savedSuccess = false
    local errorWhileSaving: string?

    for i: number = 1, maxAttempts do
        -- Retry saving the player data class to the data store.
        Chronovisor(
            function()
                local savingSessionId = newSessionId

                if keepCurrentSessionId == true then
                    local FetchedPlayerDataClass: StoredPlayerDataClassSchema?

                    FetchedPlayerDataClass = PlayerDataClass.ClassDataStore:GetAsync(PlayerDataClass.classIdentifier)
                    if not FetchedPlayerDataClass then return end

                    savingSessionId = FetchedPlayerDataClass.sessionId
                end

                local SavingData = {}

                -- Compress the class data and save it.
                do
                    if newSessionId then SavingData = PlayerDataClass()
                    else
                        for i: string, v: any in pairs(PlayerDataClass()) do
                            SavingData[i] = Compression(v())
                        end

                        SavingData = Compression(SavingData)
                    end

                    PlayerDataClass.ClassDataStore:SetAsync(PlayerDataClass.classIdentifier,
                        {
                            Data = SavingData,
                            sessionId = savingSessionId
                        }
                    )
                end

                savedSuccess = true
            end
        )
        :onError(function(err: string?) errorWhileSaving = err end)

        if savedSuccess then break end
    end

    if savedSuccess then return end

    if errorWhileSaving then print(`Error while saving player data class. Error: {errorWhileSaving}`) end
end
--[[ @end_section Utility Functions ]]


--[[ @section Class Callbacks ]]
--[[
    @usage Save the player data class to the data store.

    @param self PlayerDataClass<any>
    @param keepCurrentSessionId true?

    @return void
]]
local function saveClassStateCallback
(
    self: PlayerDataClass<any>,
    keepCurrentSessionId: true?
)
    saveClassStateSafely(self, 5, keepCurrentSessionId)

    -- Ensure the data saved successfully and matches the player data class data.
    Chronovisor(
        function()
            local FetchedPlayerDataClass: StoredPlayerDataClassSchema? = self.ClassDataStore:GetAsync(`{self.classIdentifier}`)

            -- Ensure there is saved data and the session ID doesn't still exist if it shouldn't.
            do
                if not FetchedPlayerDataClass then
                    print("No fetched player data class after saving! Possible data mismatch.")

                    return
                end

                if FetchedPlayerDataClass.sessionId ~= nil and keepCurrentSessionId ~= true then
                    print("Session ID still exists after saving!")
                end
            end

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

    @return void
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

    @return any
]]
local function playerDataClassCallback(self: PlayerDataClass<any>): any return self.Data end


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
    -- Ensure the crash handler has been executed and return the existing player data class if available.
    do
        if executedCrashHandler == false then crashHandler() end

        local ExistingClass = PlayerDataClassCache[`{classIdentifier}`]
        if ExistingClass or not DataTemplate or not classDataStoreIdentifier then return ExistingClass end
    end

    local ClassDataStore = DataStoreService:GetDataStore(classDataStoreIdentifier)

    local NewPlayerDataClass
    = {
        classIdentifier = classIdentifier,
        ClassDataStore = ClassDataStore
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

    local isInUseOrUnavailable: boolean

    -- Fetch the player data class data and ensure it's not in use.
    Chronovisor(
        function()
            local FetchedPlayerDataClass: StoredPlayerDataClassSchema? = ClassDataStore:GetAsync(`{classIdentifier}`)

            if FetchedPlayerDataClass then
                if FetchedPlayerDataClass.sessionId ~= sessionId and FetchedPlayerDataClass.sessionId ~= nil then
                    local player = Players:GetPlayerByUserId(classIdentifier)
                    if not player then return end

                    player:Kick(`Your data session is already in use.`)

                    isInUseOrUnavailable = true

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

            isInUseOrUnavailable = false
        end
    )
    :onError(
        function(err: string?)
            print(`Failed to fetch compressed player data class data. Error: {err}`)

            isInUseOrUnavailable = true
        end
    )

    -- If available, save the new session id to the player data class.
    do
        repeat task.wait() until isInUseOrUnavailable ~= nil
        if isInUseOrUnavailable == true then return nil end

        saveClassStateSafely(NewPlayerDataClass :: any, 5, nil, sessionId)
    end

    -- Decompress the data and make it reactive.
    do
        NewPlayerDataClass.Data = Compression(NewPlayerDataClass.Data, "decompress") :: any

        for i: string, v: any in pairs(NewPlayerDataClass.Data :: any) do
            (NewPlayerDataClass.Data :: any)[i] = Reactor(Compression(v, "decompress"))
        end
    end

    -- Add the player data class to the cache and start its auto-saving loop.
    do
        task.spawn(function() autoSaveClassState(NewPlayerDataClass :: any) end)

        PlayerDataClassCache[`{classIdentifier}`] = (NewPlayerDataClass :: any) :: PlayerDataClass<D>
    end

    return (NewPlayerDataClass :: any) :: PlayerDataClass<D>
end

return constructorCallback
--[[ @end_section Constructor ]]