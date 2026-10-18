unpack = table.unpack or unpack
local frames = {}
local blocked = false
local function object()
    return setmetatable({scripts={},points={},shown=false,scale=1}, {__index=function(self,key)
        if key == 'IsProtected' or key == 'SetScale' or key == 'CreateAnimationGroup' then
            return function() error('Viewport must not inspect combat or change UI scale') end
        end
        if key == 'CreateTexture' or key == 'CreateFontString' then return function() return object() end end
        if key == 'SetScript' then return function(_,name,fn) self.scripts[name]=fn end end
        if key == 'Show' then return function() self.shown=true end end
        if key == 'Hide' then return function() self.shown=false end end
        if key == 'GetEffectiveScale' then return function() return self.scale end end
        if key == 'ClearAllPoints' then return function()
            if self == WorldFrame and blocked then
                if blocked == 'error' then error('Simulated rejected resize') end
                return
            end
            self.points={}
        end end
        if key == 'SetPoint' then return function(_, ...)
            if self == WorldFrame and blocked then return end
            self.points[#self.points+1]={...}
        end end
        if key == 'GetNumPoints' then return function() return #self.points end end
        if key == 'GetPoint' then return function(_,index) return unpack(self.points[index],1,5) end end
        if key == 'GetWidth' then return function() return 1920/self.scale end end
        if key == 'GetHeight' then return function() return 1080/self.scale end end
        if key == 'GetRect' then return function()
            if self == WorldFrame and #self.points == 2 then
                local top,bottom=self.points[1],self.points[2]
                return top[4],bottom[5],1920+bottom[4]-top[4],1080+top[5]-bottom[5]
            end
            return 0,0,1920/self.scale,1080/self.scale
        end end
        return function() end
    end})
end
function CreateFrame() local f=object(); frames[#frames+1]=f; return f end
function InCombatLockdown() error('No combat checks') end
UIParent,WorldFrame=object(),object()
WorldFrame:SetPoint('TOPLEFT',UIParent,'TOPLEFT',0,0)
WorldFrame:SetPoint('BOTTOMRIGHT',UIParent,'BOTTOMRIGHT',0,0)
TerminaClockDB={}
local addon={}
loadfile('TerminaClock/Clock.lua')('TerminaClock',addon)
loadfile('TerminaClock/Viewport.lua')('TerminaClock',addon)
local view=addon.Viewport
local days=addon.Clock.Schedule(addon.Clock.defaultDeadline)
for index=2,3 do
    for step=1,4 do
        assert(view.Step(days[index].dawn-(1800-step*360),addon.Clock.defaultDeadline)==step)
    end
    assert(view.Step(days[index].dawn,addon.Clock.defaultDeadline)==0)
end
-- UI and world coordinates can have different scales; 80% stays 80% physically.
UIParent.scale=0.75
for step=1,4 do
    view.SetStep(step)
    local _,_,width=WorldFrame:GetRect()
    assert(math.abs(width-1920*(1-step*0.05))<0.001)
end
assert(view.Stop())
assert(WorldFrame.points[1][4]==0 and not frames[2].shown)
-- Silently ignored restoration must remain pending and retry after it is permitted.
view.SetStep(4)
blocked=true
assert(not view.Stop())
assert(frames[1].scripts.OnUpdate)
assert(not frames[2].shown)
frames[1].scripts.OnUpdate(frames[1],0.2)
assert(math.abs(WorldFrame.points[1][4]-192)<0.001)
blocked=false
frames[1].scripts.OnUpdate(frames[1],0.2)
assert(WorldFrame.points[1][4]==0 and frames[1].scripts.OnUpdate==nil)
-- Rejected operations also preserve the baseline for a later retry.
view.SetStep(3)
blocked='error'
assert(not view.Stop())
blocked=false
frames[1].scripts.OnUpdate(frames[1],0.2)
assert(WorldFrame.points[1][4]==0)
-- A forced recovery works even when the previous session lost its snapshot.
WorldFrame:ClearAllPoints()
WorldFrame:SetPoint('TOPLEFT',UIParent,'TOPLEFT',100,-100)
WorldFrame:SetPoint('BOTTOMRIGHT',UIParent,'BOTTOMRIGHT',-100,100)
assert(view.RestoreFull())
assert(WorldFrame.points[1][4]==0)
-- A native full-screen world frame may have no explicit anchors.
WorldFrame:ClearAllPoints()
view.SetStep(4)
assert(view.Stop() and #WorldFrame.points==2)
-- Dawn starts only after an immediate restoration attempt.
function GetCVar() return '0.5' end
function SetCVar() end
addon.Sounds={Stop=function() end,Play=function() return true end}
loadfile('TerminaClock/Dawn.lua')('TerminaClock',addon)
TerminaClockDB.deadline=addon.Clock.defaultDeadline
view.SetStep(4)
assert(addon.Dawn.Play('second',true,37))
assert(WorldFrame.points[1][4]==0)
frames[3].scripts.OnUpdate(frames[3],5.3)
assert(WorldFrame.points[1][4]==0)
print('Viewport restoration retries, forced recovery, scaled coordinates, and dawn timing passed.')
