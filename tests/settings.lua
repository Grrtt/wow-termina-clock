local addon = {}
assert(loadfile('TerminaClock/Settings.lua'))('TerminaClock', addon)
local settings = addon.Settings
local default = 1792627200
for _, invalid in ipairs({true, 'invalid', 42}) do
    local clean = settings.Normalize(invalid, default)
    assert(clean.deadline == default and clean.scale == 1)
end
for _, invalid in ipairs({0/0, math.huge, -math.huge, '1', false, {}}) do
    local clean = settings.Normalize({scale=invalid,deadline=invalid,x=invalid,y=invalid},default)
    assert(clean.scale == 1 and clean.deadline == default and clean.x == 0 and clean.y == -220)
end
local clean = settings.Normalize({scale=-1, deadline=-1, x=1e10, y=-1e10, muted='false', hidden={}, screenEffect='yes'},default)
assert(clean.scale == 1 and clean.deadline == default and clean.x == 0 and clean.y == -220)
assert(clean.muted == false and clean.hidden == false and clean.screenEffect == true)
clean = settings.Normalize({deadline=1800000000,scale=2,muted=true,screenEffect=false},default)
assert(clean.deadline == 1800000000 and clean.scale == 2 and clean.muted and not clean.screenEffect)
assert(settings.Normalize({deadline=1792652400,camera=false},default,1792652400).deadline == default)
assert(not settings.ValidNumber(0/0,0.5,3))
assert(not settings.ValidNumber(math.huge,0.5,3))
print('Runtime saved-setting validation and finite-number checks passed.')
