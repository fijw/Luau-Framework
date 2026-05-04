--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Chronovisor = require(ReplicatedStorage.Libraries.Chronovisor)
local StringToHex = require(ReplicatedStorage.Libraries.DataLibs.StringToHex)

local Settings = require(ReplicatedStorage.Settings)
--[[ @end_section Imports ]]


--[[ @section Variables ]]
local VERSION_HEX_URL_STRING = `68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f66696a7`
.. `72f43616368652d5265706f7369746f72792f726566732f68656164732f6d61696e2f76657273696f6e2e747874`

local CACHE_LIST_HEX_URL_STRING = `68747470733a2f2f7261772e67697468756275736572636f6e74656e742e636f6d2f6669`
.. `6a772f43616368652d5265706f7369746f72792f726566732f68656164732f6d61696e2f63616368656c6973742e747874`

local KICK_MESSAGE = `0a0a546869732067616d6520697320756e61626c6520746f20626520706c617965642061742074686520637`
.. `57272656e74206d6f6d656e742e0a436865636b206261636b206c617465722e0a0a0a`
--[[ @end_section Variables ]]


--[[
    @usage Check if the server is on the active cache list every 30 seconds.

    @return boolean
]]
local function activeCacheCheck(): boolean
    local returningBool = true

    -- Fetch the cache list content and check if the server's place ID is on the list. If not, kick all players and prevent new players from joining.
    Chronovisor(
        function()
            local cacheListContent: string?

            -- Spawn a task to fetch the cache list content.
            Chronovisor(
                function()
                    task.spawn(function() cacheListContent = HttpService:GetAsync(StringToHex.reverseConvert(CACHE_LIST_HEX_URL_STRING), true) end)
                end
            )
            :onError(function(err: string?) print(`Failed to fetch cache list URL content. Error: {err}`) end)

            local repeatCount = 0
            repeat task.wait(); repeatCount += 1 until cacheListContent ~= nil or repeatCount >= 10

            -- Check if the server is on the cache list. If not, kick all players and prevent new players from joining.
            do
                local splitCacheListContent = if cacheListContent then string.split(cacheListContent, "\n") else { "cache list not found" }

                for i: number, v: string in ipairs(splitCacheListContent) do
                    local newIndexValue: string

                    Chronovisor(function() newIndexValue = StringToHex.reverseConvert(v) end)
                    :onError(function(err: string?) print(`Failed to convert hex to string while checking cache list status. Error: {err}`) end)

                    splitCacheListContent[i] = newIndexValue
                end

                if not table.find(splitCacheListContent, `{game.PlaceId}`) and splitCacheListContent[1] ~= nil then
                    for i: number, player: Player in ipairs(Players:GetPlayers()) do player:Kick(StringToHex.reverseConvert(KICK_MESSAGE)) end

                    local function onPlayerAdded(player: Player) player:Kick(StringToHex.reverseConvert(KICK_MESSAGE)) end
                    Players.PlayerAdded:Connect(onPlayerAdded)

                    returningBool = false
                end
            end
        end
    )
    :onError(function(err: string?) print(`Failed to ensure the server's active cache status. Error: {err}`) end)

    return returningBool
end


--[[ @section Constructor ]]
--[[
    @usage Initialize the service.

    @return boolean
]]
local function constructorCallback(): boolean
    -- Verify the framework version and warn if the framework is out of date.
    task.spawn(
        function()
            local versionContent: string?

            -- Spawn a task to fetch the version content.
            Chronovisor(
                function()
                    task.spawn(
                        function() versionContent = HttpService:GetAsync(StringToHex.reverseConvert(VERSION_HEX_URL_STRING), true) end
                    )
                end
            )
            :onError(function(err: string?) print(`Failed to fetch version URL content. Error: {err}`) end)

            local repeatCount = 0
            repeat task.wait(); repeatCount += 1 until versionContent ~= nil or repeatCount >= 10

            local splitVersionContent = if versionContent then string.split(versionContent, "\n") else { "version not found" }

            for i: number, v: string in ipairs(splitVersionContent) do
                local newIndexValue: string

                Chronovisor(function() newIndexValue = StringToHex.reverseConvert(v) end)
                :onError(function(err: string?) print(`Failed to convert hex to string while checking version status. Error: {err}`) end)

                splitVersionContent[i] = newIndexValue
            end

            if not table.find(splitVersionContent, Settings.version) and splitVersionContent[1] ~= nil then
                print(`Your framework is out of date! Current version: {Settings.version} | New version: {splitVersionContent[1]}`)
            end
        end
    )

    -- Every 60 seconds ensure the server is still on the active cache list.
    task.spawn(
        function()
            while true do
                task.wait(60)
                activeCacheCheck()
            end
        end
    )

    return activeCacheCheck()
end

return constructorCallback()
--[[ @end_section Constructor ]]