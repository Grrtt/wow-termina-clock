local addon = {}
assert(loadfile('TerminaClock/Clock.lua'))('TerminaClock', addon)
assert(loadfile('TerminaClock/Sounds.lua'))('TerminaClock', addon)
local deadline = addon.Clock.defaultDeadline
local days = addon.Clock.Schedule(deadline)
local function cue(timestamp) return addon.Sounds.Cue(timestamp-1, timestamp, deadline) end
assert(addon.Sounds.Cue(nil, deadline-100, deadline) == nil)
for _, day in ipairs(days) do
    local kind, name = cue(day.dawn)
    assert(kind == 'dawn' and name == day.name)
    if day.dusk < deadline then
        kind, name = cue(day.dusk)
        assert(kind == 'dusk' and name == day.name)
    end
    for _, boundary in ipairs({day.dawn, day.dusk}) do
        if boundary < deadline and boundary - 1800 >= days[1].dawn and boundary < deadline - 21600 then
            for minutes = 6,30,6 do assert(cue(boundary-minutes*60) == 'bell') end
        end
    end
end
for _, remaining in ipairs({21600,21000,3600,3300,1800,1620,0}) do
    local kind = cue(deadline-remaining)
    assert(kind == 'bell' or kind == 'dawn' or kind == 'dusk')
end
assert(addon.Sounds.Cue(days[2].dawn-100,days[2].dawn,deadline) == nil)
assert(addon.Sounds.Cue(deadline,deadline-1,deadline) == nil)
assert(cue(days[2].dawn + 3600) == 'tick')
local plays, stops = {}, 0
TerminaClockDB = {}
function PlaySoundFile(path, channel)
    assert(channel == 'Master')
    plays[#plays+1] = path
    return true, #plays
end
function StopSound() stops = stops + 1 end
addon.Sounds.Update(days[2].dawn-1, deadline)
assert(#plays == 0)
addon.Sounds.Update(days[2].dawn, deadline)
assert(#plays == 1 and plays[1]:find('dawn.wav',1,true))
addon.Sounds.Update(days[2].dawn, deadline)
assert(#plays == 1)
TerminaClockDB.muted = true
addon.Sounds.Play('bell')
assert(#plays == 1)
addon.Sounds.Play('tick',true)
assert(#plays == 2 and stops == 1)
local shown, hours, night
addon.Dawn = { Stop = function() end, Play = function(day, _, count, isNight)
    shown, hours, night = day, count, isNight
end }
addon.Sounds.Reset()
addon.Sounds.Update(days[2].dawn-1,deadline)
addon.Sounds.Update(days[2].dawn,deadline)
assert(shown == 'second' and not night)
assert(hours == addon.Clock.DawnHours('second',deadline))
addon.Sounds.Reset()
addon.Sounds.Update(days[2].dusk-1,deadline)
addon.Sounds.Update(days[2].dusk,deadline)
assert(shown == 'second' and night)
print('Local bell, dawn/dusk, sound playback, and transition integration tests passed.')
