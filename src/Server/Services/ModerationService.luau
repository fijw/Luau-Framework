--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local DataLib = require(ServerScriptService.Libraries.DataLib)
local Reactor = require(ReplicatedStorage.Libraries.Reactor)
--[[ @end_section Imports ]]


--[[ @section Types ]]
--[[ @generic T Source type. ]]
type StateEngine<T> = Reactor.AbstractedStateEngine<T>

type DataClass = DataLib.DataClass
--[[ @end_section Types ]]


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

    local Results = {}

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
local function kickBannedPlayer(player: Player, isPermanent: boolean, banDuration: number, banReason: string)
    if isPermanent == true then
        if banReason == "" then
            player:Kick(`\n\nYou have been permanently banned.\nThere is no reason attached to this ban.\n\n\n`)
        else
            player:Kick(`\n\nYou have been permanently banned.\nReason: "{banReason}".\n\n\n`)
        end
    else
        local timeLeft = banDuration - os.time()

        if banReason == "" then
            player:Kick(`\n\nYou have been temporarily banned.\nDuration Left: {formatTime(timeLeft)}.\nThere is no reason attached to this ban.\n\n\n`)
        else
            player:Kick(`\n\nYou have been temporarily banned.\nDuration Left: {formatTime(timeLeft)}.\nReason: "{banReason}".\n\n\n`)
        end
    end
end
--[[ @end_section Utility Functions ]]


--[[ @section Constructor ]]
local function constructorCallback()
    local function onPlayerAdded(player: Player)
        local PlrDataClass = DataLib(player)
        if not PlrDataClass then return end

        if (PlrDataClass().ModerationData :: any) == nil then
            PlrDataClass().ModerationData
            = Reactor(
                {
                    BanData
                    = {
                        isBanned = false,
                        permanent = false,
                        banDuration = 0,
                        banReason = ""
                    }
                }
            )
        end

        PlrDataClass().ModerationData
        :subscribe(
            function(self, data, key, ...)
                if data ~= true or key ~= "isBanned" then return end

                kickBannedPlayer(
                    player,
                    PlrDataClass().ModerationData().BanData.permanent,
                    PlrDataClass().ModerationData().BanData.banDuration,
                    PlrDataClass().ModerationData().BanData.banReason
                )
            end
        )

        local BanData = PlrDataClass().ModerationData().BanData

        if BanData.isBanned == true then
            if BanData.permanent == false then
                if BanData.banDuration <= os.time() then
                    PlrDataClass().ModerationData(false, "isBanned", "BanData")
                    PlrDataClass().ModerationData(0, "banDuration", "BanData")
                    PlrDataClass().ModerationData("", "banReason", "BanData")
                else
                    kickBannedPlayer(
                        player,
                        BanData.permanent,
                        BanData.banDuration,
                        BanData.banReason
                    )
                end
            elseif BanData.permanent == true then
                kickBannedPlayer(
                    player,
                    BanData.permanent,
                    BanData.banDuration,
                    BanData.banReason
                )
            end
        end
    end

    -- Handle player data on join and leave.
    do
        for i: number, player: Player in pairs(Players:GetPlayers()) do onPlayerAdded(player) end

        Players.PlayerAdded:Connect(onPlayerAdded)
    end
end

return constructorCallback
--[[ @end_section Constructor ]]