--!strict
--!native
--!optimize 2


--[[ @section Imports ]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Store = require(ServerScriptService.Libraries.Store)
local Reactor = require(ReplicatedStorage.Libraries.Reactor)
--[[ @end_section Imports ]]


--[[ @section Types ]]
--[[ @generic T Source type. ]]
type StateEngine<T> = Reactor.AbstractedStateEngine<T>

--[[ @generic D Data template type. ]]
type PlayerDataClass<D> = Store.PlayerDataClass<D>
--[[ @end_section Types ]]


local SecondsPerUnit
= {
    minutes = 60,
    hours = 60 * 60,
    days = 60 * 60 * 24,
    years = 60 * 60 * 24 * 365
}


--[[ @section Utility Functions ]]
--[[
    @usage Kick the player and clear their moderation data.

    @param player Player
    @param PlayerDataClass PlayerDataClass<any>

    @return void
]]
local function kickPlayer(player: Player, PlayerDataClass: PlayerDataClass<any>)
    local kickReason = (PlayerDataClass() :: { [string]: StateEngine<any> }).kickReason();

    PlayerDataClass().isKicked(false);
    PlayerDataClass().kickReason = nil

    player:Kick(`\n\nYou have been kicked.\n\nReason: "{kickReason :: string}".\n\n\n`)
end

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

    local result = {}

    -- Get the time results.
    do
        local yearsTag = if years == 1 then "year" else "years"
        local daysTag = if days == 1 then "day" else "days"
        local hoursTag = if hours == 1 then "hour" else "hours"
        local minutesTag = if minutes == 1 then "minute" else "minutes"

        if years > 0 then table.insert(result, `{years} {yearsTag}`) end
        if days > 0 then table.insert(result, `{days} {daysTag}`) end
        if hours > 0 then table.insert(result, `{hours} {hoursTag}`) end
        if minutes > 0 then table.insert(result, `{minutes} {minutesTag}`) end
    end

    return table.concat(result, " ")
end
--[[ @end_section Utility Functions ]]


--[[
    @usage Check for moderation data or moderation data changes.

    @param player Player

    @return void
]]
local function onPlayerAdded(player: Player)
    repeat task.wait() until Store(player.UserId)

    local PlayerDataClass = Store(player.UserId)
    if not PlayerDataClass then return end

    -- Check for existing moderation data.
    do
        if (PlayerDataClass() :: { [string]: StateEngine<any> }).isBanned() then
            if (PlayerDataClass() :: { [string]: StateEngine<any> }).banDuration ~= nil then
                if os.time() >= (PlayerDataClass() :: { [string]: StateEngine<any> }).banDuration() then
                    (PlayerDataClass() :: { [string]: StateEngine<any> }).isBanned = Reactor(false);
                    (PlayerDataClass() :: { [string]: StateEngine<any> }).banDuration = nil
                    (PlayerDataClass() :: { [string]: StateEngine<any> }).banReason = nil
                else
                    local timeLeft = (PlayerDataClass() :: { [string]: StateEngine<any> }).banDuration() - os.time()
                    player:Kick(`\n\nYou have been temporarily banned.\n\nDuration Left: {formatTime(timeLeft)}.\n\nReason: "{(PlayerDataClass() :: { [string]: any }).banReason()}".\n\n\n`)
                end
            else
                player:Kick(`\n\nYou have been permanently banned.\n\nReason: "{(PlayerDataClass() :: { [string]: any }).banReason()}".\n\n\n`)
            end
        end

        if (PlayerDataClass() :: { [string]: StateEngine<any> }).isKicked() then
            kickPlayer(player, PlayerDataClass)
        end
    end

    -- Subscribe to moderation data changes.
    do
        (PlayerDataClass() :: { [string]: StateEngine<any> }).isBanned
        :subscribe(
            function(self, data, key, ...)
                if data ~= true then return end

                if (PlayerDataClass() :: { [string]: StateEngine<any> }).banDuration ~= nil then
                    local timeLeft = (PlayerDataClass() :: { [string]: StateEngine<any> }).banDuration() - os.time()
                    player:Kick(`\n\nYou have been temporarily banned.\n\nDuration Left: {formatTime(timeLeft)}.\n\nReason: "{(PlayerDataClass() :: { [string]: any }).banReason()}".\n\n\n`)
                else
                    player:Kick(`\n\nYou have been permanently banned.\n\nReason: "{(PlayerDataClass() :: { [string]: any }).banReason()}".\n\n\n`)
                end
            end
        );

        (PlayerDataClass() :: { [string]: StateEngine<any> }).isKicked
        :subscribe(
            function(self, data, key, ...)
                if data ~= true then return end

                kickPlayer(player, PlayerDataClass)
            end
        )
    end
end


--[[ @section Constructor ]]
--[[
    @usage Initialize the service.

    @return void
]]
local function constructorCallback()
    for i: number, player: Player in ipairs(Players:GetPlayers()) do
        onPlayerAdded(player)
    end

    Players.PlayerAdded:Connect(onPlayerAdded)
end

return constructorCallback
--[[ @end_section Constructor ]]