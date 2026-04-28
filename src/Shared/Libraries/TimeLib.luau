--!strict
--!native
--!optimize 2


export type TimeFrameTypes = "minutes" | "hours" | "days" | "years" | "minute" | "hour" | "day" | "year"


--[[ @section Variables ]]
local SECONDS_PER_UNIT
= {
    minutes = 60,
    hours = 60 * 60,
    days = 60 * 60 * 24,
    years = 60 * 60 * 24 * 365,

    minute = 60,
    hour = 60 * 60,
    day = 60 * 60 * 24,
    year = 60 * 60 * 24 * 365
}

local TimeLib = {}
--[[ @end_section Variables ]]


--[[ @section Time Functions ]]
--[[
    @usage Add time to the current time.

    @param timeInteger number
    @param timeFrame TimeFrameTypes

    @return number
]]
function TimeLib.addTimeUp(timeInteger: number, timeFrame: TimeFrameTypes): number
    local multiplier = SECONDS_PER_UNIT[timeFrame] :: number
    return os.time() + (timeInteger * multiplier)
end

--[[
    @usage Format time to a human readable format.

    @param seconds number

    @return string
]]
function TimeLib.formatTime(seconds: number): string
    local years = math.floor(seconds / SECONDS_PER_UNIT.years)
    seconds = seconds % SECONDS_PER_UNIT.years

    local days = math.floor(seconds / SECONDS_PER_UNIT.days)
    seconds = seconds % SECONDS_PER_UNIT.days

    local hours = math.floor(seconds / SECONDS_PER_UNIT.hours)
    seconds = seconds % (SECONDS_PER_UNIT.hours)

    local minutes = math.floor(seconds / SECONDS_PER_UNIT.minutes)
    seconds = seconds % SECONDS_PER_UNIT.minutes

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
--[[ @end_section Time Functions ]]


table.freeze(TimeLib)
return TimeLib