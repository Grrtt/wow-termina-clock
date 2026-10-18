local _, addon = ...
local Clock = {}
addon.Clock = Clock

-- October 22, 2026, 07:00 UTC: end of October 21 in US Pacific time.
-- This is an adjustable estimate, not an announced shutdown time.
Clock.defaultDeadline = 1792652400

function Clock.State(now, deadline)
    local remaining = math.max(0, deadline - now)
    local hours = math.ceil(remaining / 3600)
    local title = "The final days"
    if remaining == 0 then
        title = "A new dawn"
    elseif remaining <= 86400 then
        title = "Dawn of the Final Day"
    elseif remaining <= 172800 then
        title = "Dawn of the Second Day"
    elseif remaining <= 259200 then
        title = "Dawn of the First Day"
    end
    -- Anchor the virtual Termina dawn to the deadline, so every cue and hand agrees.
    local cycleSeconds = (259200 - remaining) % 86400
    local hour24 = (6 + math.floor(cycleSeconds / 3600)) % 24
    return {
        dayLabel = remaining == 0 and "New" or (remaining <= 86400 and "Final" or
            (remaining <= 172800 and "2nd" or (remaining <= 259200 and "1st" or "--"))),
        daytime = cycleSeconds < 43200,
        halfProgress = (cycleSeconds % 43200) / 43200,
        minuteProgress = (cycleSeconds % 3600) / 3600,
        hour = hour24 % 12 == 0 and 12 or hour24 % 12,
        remaining = remaining,
        hours = hours,
        title = title,
        urgent = remaining > 0 and remaining <= 21600,
        progress = 1 - math.min(remaining / 259200, 1),
        text = string.format("%02d:%02d:%02d", math.floor(remaining / 3600),
            math.floor(remaining / 60) % 60, math.floor(remaining) % 60),
    }
end
