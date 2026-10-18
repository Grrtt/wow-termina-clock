local _, addon = ...
local Clock = {}
addon.Clock = Clock

-- Estimated stress-test end: October 21, 2026, 17:00 PDT (October 22, 00:00 UTC).
-- Assumes a three-hour stress test after the announced 14:00 PDT start.
-- This is a guess, not an announced stress-test end time.
Clock.previousDefaultDeadline = 1792652400
Clock.defaultDeadline = 1792627200

local function LocalDate(timestamp)
    return (date or os.date)("*t", timestamp)
end

local function LocalTime(calendar, dayOffset, hour)
    return (time or os.time)({
        year = calendar.year, month = calendar.month, day = calendar.day + dayOffset,
        hour = hour, min = 0, sec = 0,
    })
end

function Clock.Schedule(deadline)
    local calendar = LocalDate(deadline)
    local finalOffset = 0
    if LocalTime(calendar, 0, 6) >= deadline then finalOffset = -1 end
    local days = {}
    for index, name in ipairs({ "first", "second", "final" }) do
        local offset = finalOffset + index - 3
        days[index] = {
            name = name,
            dawn = LocalTime(calendar, offset, 6),
            dusk = LocalTime(calendar, offset, 18),
        }
    end
    return days
end

function Clock.Day(now, deadline)
    local current
    for _, day in ipairs(Clock.Schedule(deadline)) do
        if now >= day.dawn then current = day end
    end
    return current
end

function Clock.DawnHours(dayName, deadline)
    for _, day in ipairs(Clock.Schedule(deadline)) do
        if day.name == dayName then return math.ceil((deadline - day.dawn) / 3600) end
    end
end

function Clock.State(now, deadline)
    local remaining = math.max(0, deadline - now)
    local calendar = LocalDate(now)
    local hour24 = calendar.hour
    local day = Clock.Day(now, deadline)
    local titles = { first = "Dawn of the First Day", second = "Dawn of the Second Day", final = "Dawn of the Final Day" }
    local labels = { first = "1st", second = "2nd", final = "Final" }
    local title, dayLabel = "The final days", "--"
    if remaining == 0 then
        title, dayLabel = "A new dawn", "New"
    elseif day then
        title, dayLabel = titles[day.name], labels[day.name]
        if hour24 < 6 or hour24 >= 18 then title = title:gsub("Dawn of", "Night of") end
    end
    local seconds = hour24 * 3600 + calendar.min * 60 + calendar.sec
    return {
        dayLabel = dayLabel,
        dayName = day and day.name,
        daytime = hour24 >= 6 and hour24 < 18,
        halfProgress = ((seconds - 21600) % 43200) / 43200,
        minuteProgress = (seconds % 3600) / 3600,
        hour = hour24 % 12 == 0 and 12 or hour24 % 12,
        remaining = remaining,
        hours = math.ceil(remaining / 3600),
        title = title,
        urgent = remaining > 0 and remaining <= 21600,
        progress = 1 - math.min(remaining / 259200, 1),
        text = string.format("%02d:%02d:%02d", math.floor(remaining / 3600),
            math.floor(remaining / 60) % 60, math.floor(remaining) % 60),
    }
end
