--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local Reactor = require(ReplicatedStorage.Libraries.Reactor)

local TimeLib = require(ReplicatedStorage.Libraries.TimeLib)
--[[ @end_section Imports ]]


type DataClass = Registry.DataClass


--[[ @section Utility Functions ]]
--[[
    @usage Kick a banned player.

    @param player Player
    @param isPermanent boolean
    @param banDuration number
    @param banReason string

    @return void
]]
local function kickBannedPlayer(player: Player, isPermanent: true?, banDuration: number?, banReason: string)
    if isPermanent == true then
        player:Kick(`\n\nYou have been permanently banned.\nReason: "{banReason}".\n\n\n`)
    elseif banDuration ~= nil then
        local timeLeft = banDuration - os.time()
        player:Kick(`\n\nYou have been temporarily banned.\nDuration Left: {TimeLib.formatTime(timeLeft)}.\nReason: "{banReason}".\n\n\n`)
    end
end

--[[
    @usage Create a moderation data subscription.

    @param player Player
    @param PlrDataClass DataClass

    @return void
]]
local function createModerationDataSubscription(player: Player, PlrDataClass: DataClass)
    PlrDataClass()().ModerationData:subscribe(
        function(self, data, key, ...)
            if data == nil or key ~= "BanData" then return end

            local TypedData = data :: { [string]: any }

            kickBannedPlayer(
                player,
                TypedData.permanent,
                TypedData.banDuration,
                TypedData.banReason
            )
        end,

        "moderation_data_subscription"
    )
end
--[[ @end_section Utility Functions ]]


--[[ @section Constructor ]]
--[[
    @usage Initialize the service.

    @return void
]]
local function constructorCallback()
    local function onPlayerAdded(player: Player)
        local PlrDataClass = Registry(player)
        if not PlrDataClass then return end

        if (PlrDataClass()().ModerationData :: any) == nil then PlrDataClass()(Reactor({}), "ModerationData") end
        createModerationDataSubscription(player, PlrDataClass)

        -- Check the current ban status of the player.
        do
            local BanData = PlrDataClass()().ModerationData().BanData
            if not BanData then return end

            if BanData.permanent ~= true then
                if (BanData.banDuration or 0) <= os.time() then
                    PlrDataClass()().ModerationData(nil, "BanData")
                else
                    kickBannedPlayer(
                        player,
                        BanData.permanent,
                        BanData.banDuration,
                        BanData.banReason
                    )
                end
            else
                kickBannedPlayer(
                    player,
                    BanData.permanent,
                    BanData.banDuration,
                    BanData.banReason
                )
            end
        end
    end

    for i: number, player: Player in ipairs(Players:GetPlayers()) do onPlayerAdded(player) end
    Players.PlayerAdded:Connect(onPlayerAdded)
end

return constructorCallback
--[[ @end_section Constructor ]]