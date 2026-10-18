local addon = {}
local scripts, frames = {}, {}
local textures = {}
local now = 10
local methods = {}
local function object()
    return setmetatable({scripts = {}}, {__index = function(_, key)
        return methods[key] or function() end
    end})
end
function methods:CreateAnimationGroup() return object() end
function methods:CreateAnimation() return object() end
function methods:CreateTexture() local t = object(); textures[#textures+1] = t; return t end
function methods:SetTexture(path) self.texturePath = path end
function methods:CreateLine() return object() end
function methods:CreateFontString() return object() end
function methods:SetScript(name, fn) self.scripts = self.scripts or {}; self.scripts[name] = fn end
function methods:GetWidth() return 1920 end
function methods:GetCenter() return 0, 0 end
function methods:GetScale() return 1 end
function CreateFrame(_, name)
    local f = object()
    frames[#frames+1] = f
    if name then _G[name] = f end
    return f
end
UIParent = object()
GameTooltip = object()
STANDARD_TEXT_FONT = "font"
SlashCmdList = {}
function GetServerTime() return 1792500000 end
function GetTime() return now end
function date(...) return os.date(...) end
local played = 0
function PlaySoundFile() played = played + 1; return true, played end
function StopSound() end
function GetCVar() return "0.5" end
function SetCVar() end
for _, file in ipairs({'Clock.lua', 'Viewport.lua', 'Sounds.lua', 'Dawn.lua', 'Preview.lua', 'TerminaClock.lua'}) do
    assert(loadfile('TerminaClock/' .. file))('TerminaClock', addon)
end
TerminaClockFrame.scripts.OnEvent(TerminaClockFrame, 'ADDON_LOADED', 'TerminaClock')
assert(TerminaClockDB.scale == 1)
SlashCmdList.TERMINACLOCK('test bell')
SlashCmdList.TERMINACLOCK('test dawn')
TerminaClockDawnFrame.scripts.OnUpdate(TerminaClockDawnFrame, 0.4)
SlashCmdList.TERMINACLOCK('dawn stop')
SlashCmdList.TERMINACLOCK('test tick')
assert(played == 3)
SlashCmdList.TERMINACLOCK('camera')
assert(TerminaClockDB.screenEffect == false)
SlashCmdList.TERMINACLOCK('camera')
assert(TerminaClockDB.screenEffect == true)
SlashCmdList.TERMINACLOCK('sound')
assert(TerminaClockDB.muted)
SlashCmdList.TERMINACLOCK('hide')
assert(TerminaClockDB.hidden)
SlashCmdList.TERMINACLOCK('show')
assert(not TerminaClockDB.hidden)
for _, f in ipairs(frames) do
    if f.scripts and f.scripts.OnUpdate then f.scripts.OnUpdate(f, 0.2) end
end
print('UI initialization and command smoke tests passed.')

local dayTexture
for _, texture in ipairs(textures) do
    if type(rawget(texture, 'texturePath')) == 'string' and texture.texturePath:find('Textures\\second.tga',1,true) then
        dayTexture = texture
    end
end
-- The countdown currently falls in the second day in this harness.
assert(dayTexture)
local deadline = TerminaClockDB.deadline
local normalTexture = dayTexture.texturePath
for _, pair in ipairs({{'1st','first'}, {'2nd','second'}, {'final','final'}}) do
    SlashCmdList.TERMINACLOCK('test ' .. pair[1])
    assert(dayTexture.texturePath:find('Textures\\' .. pair[2] .. '.tga',1,true))
    assert(TerminaClockDB.deadline == deadline)
end
SlashCmdList.TERMINACLOCK('test stop')
assert(dayTexture.texturePath == normalTexture)
SlashCmdList.TERMINACLOCK('test final')
now = now + 16
for _, f in ipairs(frames) do
    if f.scripts and f.scripts.OnUpdate then f.scripts.OnUpdate(f, 0.2) end
end
assert(dayTexture.texturePath == normalTexture)
assert(TerminaClockDB.deadline == deadline)
print('Day-label previews, cancellation, expiration, and unchanged deadline tests passed.')
