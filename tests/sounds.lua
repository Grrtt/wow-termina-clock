local addon = {}
assert(loadfile("TerminaClock/Sounds.lua"))("TerminaClock", addon)
local cue = addon.Sounds.Cue
assert(cue(nil, 100) == nil)
assert(cue(86401, 86400) == "dawn")
assert(cue(172801, 172800) == "dawn")
assert(cue(259201, 259200) == "dawn")
assert(cue(21601, 21600) == "bell")
assert(cue(21001, 21000) == "bell")
assert(cue(3601, 3600) == "bell")
assert(cue(3301, 3300) == "bell")
assert(cue(1801, 1800) == "bell")
assert(cue(1621, 1620) == "bell")
assert(cue(1, 0) == "bell")
assert(cue(0, 0) == nil)
assert(cue(90000, 86400) == nil)
assert(cue(86000, 90000) == nil)
assert(cue(43381, 43380) == nil)
for _, boundary in ipairs({216000,172800,129600,86400,43200}) do
    for minutes = 6,30,6 do
        local remaining = boundary + minutes * 60
        assert(cue(remaining + 1, remaining) == "bell")
    end
end
assert(cue(39601, 39600) == "tick")
local plays, stops = {}, 0
TerminaClockDB = {}
function PlaySoundFile(path, channel)
    assert(channel == "Master")
    plays[#plays + 1] = path
    return true, #plays
end
function StopSound() stops = stops + 1 end
addon.Sounds.Update(0, 86401)
assert(#plays == 0)
addon.Sounds.Update(1, 86401)
assert(#plays == 1 and plays[1]:find("dawn.wav", 1, true))
addon.Sounds.Update(1, 86401)
assert(#plays == 1)
TerminaClockDB.muted = true
addon.Sounds.Play("bell")
assert(#plays == 1)
addon.Sounds.Play("tick", true)
assert(#plays == 2 and stops == 1)
assert(not addon.Sounds.Play("invalid", true))
addon.Sounds.Update(2, 172802)
assert(#plays == 2)
print("Sound scheduling and playback tests passed.")

local shown
addon.Dawn = { Stop = function() end, Day = function() return "second" end, Play = function(day) shown = day end }
addon.Sounds.Reset()
addon.Sounds.Update(0, 172801)
addon.Sounds.Update(1, 172801)
assert(shown == "second")
print("Automatic dawn transition integration test passed.")
