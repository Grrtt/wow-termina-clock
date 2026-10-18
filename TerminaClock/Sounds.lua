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

local function Crossed(before, remaining, threshold)
    return before > threshold and remaining <= threshold
end

-- Real hours replace Termina hours. Do not replay missed cues after a pause.
function Sounds.Cue(before, remaining)
    if not before or remaining >= before or before - remaining > 5 then return nil end
    for _, dawn in ipairs({259200, 172800, 86400}) do
        if Crossed(before, remaining, dawn) then return "dawn" end
    end
    if Crossed(before, remaining, 0) then return "bell" end
    if remaining <= 0 or remaining > 259200 then return nil end
    if remaining <= 21600 then
        local interval = 600
        if remaining <= 1800 then interval = 180
        elseif remaining <= 3600 then interval = 300 end
        if Crossed(before, remaining, 21600) or
            math.ceil(before / interval) ~= math.ceil(remaining / interval) then
            return "bell"
        end
    else
        -- Five tolls at :30, :36, :42, :48, and :54 before each dawn/dusk.
        for _, boundary in ipairs({216000, 172800, 129600, 86400, 43200}) do
            for minutes = 6, 30, 6 do
                if Crossed(before, remaining, boundary + minutes * 60) then return "bell" end
            end
        end
    end
    if math.ceil(before / 3600) ~= math.ceil(remaining / 3600) then return "tick" end
end

function Sounds.Update(now, deadline)
    local remaining = math.max(0, deadline - now)
    if previousDeadline ~= deadline then previous = nil end
    local cue = Sounds.Cue(previous, remaining)
    previous, previousDeadline = remaining, deadline
    if addon.Preview and addon.Preview.IsPlaying() then return end
    if addon.Viewport then addon.Viewport.Update(remaining) end
    if cue == "dawn" and addon.Dawn then
        addon.Dawn.Play(addon.Dawn.Day(remaining), false)
    elseif cue then
        Sounds.Play(cue)
    end
end
