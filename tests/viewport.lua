unpack = table.unpack or unpack
local drivers = {}
local function object()
    return setmetatable({ scripts = {}, points = {}, shown = false }, { __index = function(self, key)
        if key == 'SetScript' then return function(_, name, fn) self.scripts[name] = fn end end
        if key == 'CreateAnimationGroup' or key == 'SetScale' then
            return function() error('Viewport must not transform or scale the UI') end
        end
        if key == 'CreateTexture' then return function() return object() end end
        if key == 'Show' then return function() self.shown = true end end
        if key == 'Hide' then return function() self.shown = false end end
        if key == 'ClearAllPoints' then return function() self.points = {} end end
        if key == 'SetPoint' then return function(_, ...) self.points[#self.points+1] = {...} end end
        if key == 'GetPoint' then return function(_, i) return unpack(self.points[i]) end end
        if key == 'GetNumPoints' then return function() return #self.points end end
        if key == 'GetWidth' then return function() return 1920 end end
        if key == 'GetHeight' then return function() return 1080 end end
        return function() end
    end })
end
function CreateFrame() local f=object(); drivers[#drivers+1]=f; return f end
UIParent, WorldFrame = object(), object()
WorldFrame:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', 0, 0)
WorldFrame:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', 0, 0)
local combat = false
function InCombatLockdown() return combat end
TerminaClockDB = {}
local addon = {}
assert(loadfile('TerminaClock/Clock.lua'))('TerminaClock', addon)
assert(loadfile('TerminaClock/Viewport.lua'))('TerminaClock', addon)
local view = addon.Viewport
local deadline = addon.Clock.defaultDeadline
local days = addon.Clock.Schedule(deadline)
for index = 2,3 do
    local dawn = days[index].dawn
    assert(view.Step(dawn - 1800, deadline) == 0)
    assert(view.Step(dawn - 1440, deadline) == 1)
    assert(view.Step(dawn - 1080, deadline) == 2)
    assert(view.Step(dawn - 720, deadline) == 3)
    assert(view.Step(dawn - 360, deadline) == 4)
    assert(view.Step(dawn, deadline) == 0)
end
assert(view.Step(days[3].dusk - 360, deadline) == 0)
assert(view.Step(deadline, deadline) == 0)
view.SetStep(4)
assert(math.abs(WorldFrame.points[1][4] - 192) < 0.001)
assert(math.abs(WorldFrame.points[1][5] + 108) < 0.001)
assert(drivers[2].shown)
view.Stop()
assert(WorldFrame.points[1][4] == 0 and not drivers[2].shown)
view.SetStep(2)
combat = true
view.Stop()
assert(math.abs(WorldFrame.points[1][4] - 96) < 0.001)
combat = false
drivers[1].scripts.OnEvent(drivers[1], 'PLAYER_REGEN_ENABLED')
assert(WorldFrame.points[1][4] == 0)
combat = true
view.SetStep(3)
assert(WorldFrame.points[1][4] == 0)
combat = false
TerminaClockDB.screenEffect = false
view.SetStep(3)
assert(WorldFrame.points[1][4] == 0)
TerminaClockDB.screenEffect = true
WorldFrame:ClearAllPoints()
view.SetStep(4)
view.Stop()
assert(#WorldFrame.points == 2)
assert(WorldFrame.points[1][1] == 'TOPLEFT' and WorldFrame.points[1][4] == 0)
assert(WorldFrame.points[2][1] == 'BOTTOMRIGHT' and WorldFrame.points[2][5] == 0)
print('World-only shrink, unchanged UI, restoration, combat deferral, and schedule tests passed.')
