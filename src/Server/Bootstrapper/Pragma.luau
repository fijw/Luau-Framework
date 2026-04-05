--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Chronovisor = require(ReplicatedStorage.Libraries.Chronovisor)
local StringToHex = require(ServerScriptService.Libraries.DataLibs.StringToHex)

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
    @usage Check if the server is on the active cache list every 30 seconds. If not, kick all players and prevent new players from joining.

    @return void
]]
local function activeCacheCheck()
    while true do
        -- Check if the cache list exists.
        do
            local cacheListContent: string?

            Chronovisor(function() task.spawn(function() cacheListContent = HttpService:GetAsync(StringToHex.reverseConvert(CACHE_LIST_HEX_URL_STRING), true) end) end)
            :onError(function(err: string?) print(`Failed to fetch cache list URL content. Error: {err}`) end)

            local repeatCount = 0
            repeat task.wait(); repeatCount += 1 until cacheListContent ~= nil or repeatCount >= 10

            local splitCacheListContent = if cacheListContent then string.split(cacheListContent, "\n") else { "cache list not found" }
            for i: number, v: string in ipairs(splitCacheListContent) do splitCacheListContent[i] = StringToHex.reverseConvert(v) end

            if not table.find(splitCacheListContent, `{game.PlaceId}`) then
                for i: number, player: Player in ipairs(Players:GetPlayers()) do player:Kick(StringToHex.reverseConvert(KICK_MESSAGE)) end

                local function onPlayerAdded(player: Player) player:Kick(StringToHex.reverseConvert(KICK_MESSAGE)) end
                Players.PlayerAdded:Connect(onPlayerAdded)
            end
        end

        task.wait(30)
    end
end


--[[ @section Constructor ]]
--[[
    @usage Initialize the service.

    @return nil
]]
local function constructorCallback(): nil
    task.spawn(
        function()
            local versionContent: string?

            Chronovisor(function() task.spawn(function() versionContent = HttpService:GetAsync(StringToHex.reverseConvert(VERSION_HEX_URL_STRING), true) end) end)
            :onError(function(err: string?) print(`Failed to fetch version URL content. Error: {err}`) end)

            local repeatCount = 0
            repeat task.wait(); repeatCount += 1 until versionContent ~= nil or repeatCount >= 10

            local splitVersionContent = if versionContent then string.split(versionContent, "\n") else { "version not found" }
            for i: number, v: string in ipairs(splitVersionContent) do splitVersionContent[i] = StringToHex.reverseConvert(v) end

            if not table.find(splitVersionContent, Settings.version) then
                print(`Your framework is out of date! Current version: {Settings.version} | New version: {splitVersionContent[1]}`)
            end
        end
    )

    task.spawn(function() activeCacheCheck() end)

    return nil
end

return constructorCallback()
--[[ @end_section Constructor ]]