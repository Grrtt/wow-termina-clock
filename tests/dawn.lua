local frames = {}
local textValue
local function object()
    local obj = { scripts = {}, shown = false }
    return setmetatable(obj, {__index = function(self, key)
        if key == 'SetText' then return function(_, text) textValue = text end end
        if key == 'SetScript' then return function(_, name, fn) self.scripts[name] = fn end end
        if key == 'CreateFontString' then return function() return object() end end
        if key == 'CreateTexture' then return function() return object() end end
        if key == 'Hide' then return function()
            self.shown = false
            if self.scripts.OnHide then self.scripts.OnHide(self) end
        end end
        if key == 'Show' then return function() self.shown = true end end
        if key == 'GetWidth' then return function() return 1920 end end
        return function() end
    end})
end
function CreateFrame()
    local f = object()
    frames[#frames+1] = f
    return f
end
UIParent = object()
TerminaClockDB = {}
local values = { Sound_SFXVolume = '0.8', Sound_MusicVolume = '0.3', Sound_AmbienceVolume = '0.5', Sound_DialogVolume = '1' }
function GetCVar(name) return values[name] end
function SetCVar(name, value) values[name] = tostring(value) end
local plays, stops = 0, 0
local restored = false
local addon = { Viewport = { Stop = function() restored = true end }, Sounds = {
    Play = function(name, preview) assert(name == 'dawn' or name == 'tick'); plays = plays + 1 end,
    Stop = function() stops = stops + 1 end,
}}
assert(loadfile('TerminaClock/Clock.lua'))('TerminaClock', addon)
assert(loadfile('TerminaClock/Dawn.lua'))('TerminaClock', addon)
local dawn, overlay = addon.Dawn, frames[1]
assert(dawn.Play('first', true))
assert(restored and overlay.shown and plays == 0)
assert(textValue:find(tostring(addon.Clock.DawnHours('first',addon.Clock.defaultDeadline)),1,true))
for _, value in pairs(values) do assert(value == '0') end
assert(TerminaClockDB.dawnAudioRecovery.Sound_MusicVolume == '0.3')
assert(plays == 0)
overlay.scripts.OnUpdate(overlay, 0.4)
assert(plays == 1)
overlay.scripts.OnUpdate(overlay, 1)
assert(plays == 1)
overlay.scripts.OnUpdate(overlay, 4)
assert(values.Sound_SFXVolume == '0.8' and values.Sound_MusicVolume == '0.3')
assert(not overlay.shown and overlay.scripts.OnUpdate == nil)
assert(TerminaClockDB.dawnAudioRecovery == nil)
for _, day in ipairs({'first','second','final'}) do
    assert(dawn.Play(day, true))
    dawn.Stop()
    assert(values.Sound_DialogVolume == '1')
end
assert(not dawn.Play('invalid', true))
dawn.Play('final', true)
SetCVar('Sound_MusicVolume', '0.7')
overlay.scripts.OnEvent()
assert(values.Sound_MusicVolume == '0.7' and values.Sound_SFXVolume == '0.8')
TerminaClockDB.transitions = false
assert(dawn.Play('first', false))
assert(not overlay.shown and values.Sound_SFXVolume == '0.8')
TerminaClockDB.dawnAudioRecovery = { Sound_SFXVolume = '0.9' }
values.Sound_SFXVolume = '0'
dawn.RecoverAudio()
assert(values.Sound_SFXVolume == '0.9')
TerminaClockDB.transitions = true
dawn.Play('second',true,37,true)
assert(textValue == '–37 Hours Remain–')
assert(values.Sound_SFXVolume == '0.9')
overlay.scripts.OnUpdate(overlay,0.4)
dawn.Stop()
assert(values.Sound_SFXVolume == '0.9')
print('Dawn timing, audio restoration, cancellation, preview, and recovery tests passed.')

-- Recovery data cannot choose unrelated CVars or supply invalid volumes.
values.UnrelatedSetting = '0'
TerminaClockDB.dawnAudioRecovery = {
    UnrelatedSetting = '1',
    Sound_SFXVolume = '1.5',
    Sound_MusicVolume = '-1',
    Sound_AmbienceVolume = {},
    Sound_DialogVolume = '0.4',
}
values.Sound_SFXVolume, values.Sound_MusicVolume = '0', '0'
values.Sound_AmbienceVolume, values.Sound_DialogVolume = '0', '0'
dawn.RecoverAudio()
assert(values.UnrelatedSetting == '0')
assert(values.Sound_SFXVolume == '0' and values.Sound_MusicVolume == '0')
assert(values.Sound_AmbienceVolume == '0' and values.Sound_DialogVolume == '0.4')
for _, invalid in ipairs({false,'invalid',42}) do
    TerminaClockDB.dawnAudioRecovery = invalid
    dawn.RecoverAudio()
    assert(TerminaClockDB.dawnAudioRecovery == nil)
end
-- Animation cleanup still restores audio if WoW rejects viewport restoration.
values.Sound_SFXVolume = '0.8'
dawn.Play('second',true,37)
assert(values.Sound_SFXVolume == '0')
addon.Viewport.Stop = function() error('Simulated render-frame restriction') end
dawn.Stop()
assert(values.Sound_SFXVolume == '0.8')
assert(not overlay.shown and overlay.scripts.OnUpdate == nil)
print('Audio recovery allowlist, malformed data, and cleanup-error isolation passed.')
