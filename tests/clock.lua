local addon = {}
assert(loadfile("TerminaClock/Clock.lua"))("TerminaClock", addon)
local clock = addon.Clock
local deadline = clock.defaultDeadline
assert(os.date("!%Y-%m-%d %H:%M", deadline) == "2026-10-22 07:00")
for _, case in ipairs({
    { 259201, "The final days" },
    { 259200, "Dawn of the First Day" },
    { 172800, "Dawn of the Second Day" },
    { 86400, "Dawn of the Final Day" },
    { 0, "A new dawn" },
    { -1, "A new dawn" },
}) do
    local state = clock.State(deadline - case[1], deadline)
    assert(state.title == case[2], case[2])
    assert(state.progress >= 0 and state.progress <= 1)
end
assert(clock.State(deadline - 3661, deadline).text == "01:01:01")
assert(clock.State(deadline - 1, deadline).hours == 1)
assert(clock.State(deadline - 21600, deadline).urgent)
assert(not clock.State(deadline, deadline).urgent)
print("Countdown boundary tests passed.")
