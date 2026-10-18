local driver = { scripts = {} }
function CreateFrame() return driver end
function driver:SetScript(name, fn) self.scripts[name] = fn end
function driver:RegisterEvent() end
local bells, dawns, stops = 0, {}, 0
local steps = {}
TerminaClockDB = { deadline = 1792652400 }
local addon = {
    Viewport = { SetStep = function(step) steps[#steps+1] = step end },
    Sounds = { Play = function(name, preview) assert(name == 'bell' and preview); bells = bells + 1 end },
    Dawn = { Stop = function() stops = stops + 1 end,
        Play = function(day, preview) assert(preview); dawns[#dawns+1] = day end },
}
assert(loadfile('TerminaClock/Preview.lua'))('TerminaClock', addon)
local preview = addon.Preview
assert(preview.DayEnd())
assert(preview.IsPlaying() and bells == 1)
driver.scripts.OnUpdate(driver, 6)
driver.scripts.OnUpdate(driver, 6)
assert(bells == 3 and #dawns == 0)
driver.scripts.OnUpdate(driver, 6)
driver.scripts.OnUpdate(driver, 6)
assert(bells == 5 and #dawns == 0)
assert(#steps == 4 and steps[1] == 1 and steps[4] == 4)
driver.scripts.OnUpdate(driver, 6)
assert(#dawns == 1 and dawns[1] == 'second')
driver.scripts.OnUpdate(driver, 5.4)
assert(not preview.IsPlaying() and driver.scripts.OnUpdate == nil)
assert(TerminaClockDB.deadline == 1792652400)
assert(preview.DayEnd('final'))
driver.scripts.OnUpdate(driver, 30)
assert(dawns[2] == 'final')
preview.Stop()
assert(not preview.IsPlaying())
assert(not preview.DayEnd('invalid'))
preview.DayEnd()
driver.scripts.OnEvent()
assert(not preview.IsPlaying())
print('Day-end preview sequence, cancellation, and unchanged deadline tests passed.')
