local _, addon = ...
local Sounds = {}
addon.Sounds = Sounds
local previous, previousDeadline, handle
local files = { bell = "bell.wav", dawn = "dawn.wav", tick = "tick.wav" }

function Sounds.Stop()
    if handle then StopSound(handle, 100) end
    handle = nil
end

function Sounds.Reset()
    if addon.Dawn then addon.Dawn.Stop() end
    Sounds.Stop()
    previous, previousDeadline = nil, nil
end

function Sounds.Play(name, preview)
    if not files[name] then return false end
    if TerminaClockDB.muted and not preview then return true end
    Sounds.Stop()
    local success
    success, handle = PlaySoundFile("Interface\\AddOns\\TerminaClock\\Sounds\\" .. files[name], "Master")
    if not success then
        handle = nil
        print("Termina Clock: could not play " .. name .. ". Restart WoW after installing the sound files and check your sound settings.")
    end
    return success
end

local function Crossed(before, now, threshold)
    return before < threshold and now >= threshold
end

function Sounds.Cue(before, now, deadline)
    if not before or now <= before or now - before > 5 then return nil end
    if Crossed(before, now, deadline) then return "bell" end
    if now >= deadline then return nil end
    local days = addon.Clock.Schedule(deadline)
    for _, day in ipairs(days) do
        if Crossed(before, now, day.dawn) then return "dawn", day.name end
        if day.dusk < deadline and Crossed(before, now, day.dusk) then return "dusk", day.name end
    end
    if now < days[1].dawn then return nil end
    local remaining = deadline - now
    if remaining <= 21600 then
        local interval = 600
        if remaining <= 1800 then interval = 180
        elseif remaining <= 3600 then interval = 300 end
        if Crossed(before, now, deadline - 21600) or
            math.ceil((deadline - before) / interval) ~= math.ceil(remaining / interval) then
            return "bell"
        end
    else
        for _, day in ipairs(days) do
            for _, boundary in ipairs({day.dawn, day.dusk}) do
                if boundary < deadline then
                    for minutes = 6, 30, 6 do
                        if Crossed(before, now, boundary - minutes * 60) then return "bell" end
                    end
                end
            end
        end
    end
    -- Detect local hour changes, including time zones with fractional offsets.
    local hour = (date or os.date)("%Y%m%d%H", now)
    if hour ~= (date or os.date)("%Y%m%d%H", before) then return "tick" end
end

function Sounds.Update(now, deadline)
    if previousDeadline ~= deadline then previous = nil end
    local cue, day = Sounds.Cue(previous, now, deadline)
    previous, previousDeadline = now, deadline
    if addon.Preview and addon.Preview.IsPlaying() then return end
    if addon.Viewport then addon.Viewport.Update(now, deadline) end
    if (cue == "dawn" or cue == "dusk") and addon.Dawn then
        addon.Dawn.Play(day, false, math.ceil((deadline - now) / 3600), cue == "dusk")
    elseif cue then
        Sounds.Play(cue)
    end
end
