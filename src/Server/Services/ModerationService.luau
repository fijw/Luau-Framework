--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Registry = require(ServerScriptService.Libraries.DataLibs.Registry)
local Reactor = require(ReplicatedStorage.Libraries.Reactor)
--[[ @end_section Imports ]]


type DataClass = Registry.DataClass


local SecondsPerUnit
= {
    seconds = 1,
    minutes = 60,
    hours = 60 * 60,
    days = 60 * 60 * 24,
    years = 60 * 60 * 24 * 365
}


--[[ @section Utility Functions ]]
--[[
    @usage Format time to a human readable format.

    @param seconds number

    @return string
]]
local function formatTime(seconds: number): string
    local years = math.floor(seconds / SecondsPerUnit.years)
    seconds = seconds % SecondsPerUnit.years

    local days = math.floor(seconds / SecondsPerUnit.days)
    seconds = seconds % SecondsPerUnit.days

    local hours = math.floor(seconds / SecondsPerUnit.hours)
    seconds = seconds % (SecondsPerUnit.hours)

    local minutes = math.floor(seconds / SecondsPerUnit.minutes)
    seconds = seconds % SecondsPerUnit.minutes

    local Results: { string } = {}

    -- Get the time results.
    do
        local yearsTag = if years == 1 then "year" else "years"
        local daysTag = if days == 1 then "day" else "days"
        local hoursTag = if hours == 1 then "hour" else "hours"
        local minutesTag = if minutes == 1 then "minute" else "minutes"
        local secondsTag = if seconds == 1 then "second" else "seconds"

        if years > 0 then
            if days > 0 then
                table.insert(Results, `{years} {yearsTag},`)
            else
                table.insert(Results, `{years} {yearsTag}`)
            end
        end

        if days > 0 then
            if hours > 0 then
                table.insert(Results, `{days} {daysTag},`)
            else
                table.insert(Results, `{days} {daysTag}`)
            end 
        end

        if hours > 0 then
            if minutes > 0 then
                table.insert(Results, `{hours} {hoursTag},`)
            else
                table.insert(Results, `{hours} {hoursTag}`)
            end
        end

        if minutes > 0 then
            if seconds > 0 then
                table.insert(Results, `{minutes} {minutesTag} and`)
            else
                table.insert(Results, `{minutes} {minutesTag}`)
            end
        end

        if seconds > 0 then table.insert(Results, `{seconds} {secondsTag}`) end
    end

    return table.concat(Results, " ")
end

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
        player:Kick(`\n\nYou have been temporarily banned.\nDuration Left: {formatTime(timeLeft)}.\nReason: "{banReason}".\n\n\n`)
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
                if BanData.banDuration <= os.time() then
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

        -- Subscribe to the player's data class.
        PlrDataClass():subscribe(
            function(self, data, key, ...)
                --[[
                    If the state data remains the same then don't do anything, otherwise recreate the player's moderation data subscriptions.
                    Will not do anything if the key isn't nil or the number of path arguments is greater than 0.
                ]]
                if key ~= nil or #{ ... } > 0 then return elseif key == nil and #{ ... } <= 0 then createModerationDataSubscription(player, PlrDataClass) end
            end,
            
            "player_data_class_subscription"
        )
    end

    for i: number, player: Player in ipairs(Players:GetPlayers()) do onPlayerAdded(player) end
    Players.PlayerAdded:Connect(onPlayerAdded)
end

return constructorCallback
--[[ @end_section Constructor ]]