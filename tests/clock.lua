local addon = {}
assert(loadfile('TerminaClock/Clock.lua'))('TerminaClock', addon)
local clock, deadline = addon.Clock, addon.Clock.defaultDeadline
assert(os.date('!%Y-%m-%d %H:%M', deadline) == '2026-10-22 00:00')
local days = clock.Schedule(deadline)
for index, day in ipairs(days) do
    assert(os.date('*t', day.dawn).hour == 6)
    assert(os.date('*t', day.dusk).hour == 18)
    local label = ({'1st','2nd','Final'})[index]
    assert(clock.State(day.dawn, deadline).dayLabel == label)
    assert(clock.State(day.dawn, deadline).daytime)
    assert(clock.State(day.dawn, deadline).hour == 6)
    assert(not clock.State(day.dusk, deadline).daytime)
    assert(clock.State(day.dusk, deadline).hour == 6)
    assert(clock.DawnHours(day.name, deadline) == math.ceil((deadline - day.dawn) / 3600))
    if index > 1 then
        assert(clock.State(day.dawn - 1, deadline).dayLabel == ({'1st','2nd'})[index-1])
    end
end
assert(clock.State(days[1].dawn - 1, deadline).dayLabel == '--')
assert(clock.State(deadline - 1, deadline).dayLabel == 'Final')
assert(clock.State(deadline, deadline).dayLabel == 'New')
assert(clock.State(deadline + 1, deadline).remaining == 0)
assert(days[3].dawn < deadline and deadline - days[3].dawn <= 90000)
assert(clock.State(deadline - 3661, deadline).text == '01:01:01')
-- Minute markers must match the computer's local clock.
local example = days[2].dawn + 2*3600 + 30*60
local state = clock.State(example, deadline)
assert(state.hour == 8 and state.minuteProgress == 0.5)
local zone = os.getenv('TZ') or 'system local'
if zone == 'America/Chicago' then
    assert(clock.DawnHours('first', deadline) == 61)
    assert(clock.DawnHours('final', deadline) == 13)
elseif zone == 'Europe/Berlin' then
    assert(clock.DawnHours('first', deadline) == 68)
    assert(clock.DawnHours('final', deadline) == 20)
end
print('Local day labels, dawn/dusk, remaining hours, and shared endpoint passed: ' .. zone)
