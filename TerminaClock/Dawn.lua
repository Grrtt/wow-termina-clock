local _, addon = ...
local Dawn = {}
addon.Dawn = Dawn
local overlay = CreateFrame("Frame", "TerminaClockDawnFrame", UIParent)
overlay:SetAllPoints(UIParent)
overlay:SetFrameStrata("FULLSCREEN_DIALOG")
overlay:SetFrameLevel(100)
overlay:EnableMouse(false)
local black = overlay:CreateTexture(nil, "BACKGROUND")
black:SetAllPoints()
black:SetColorTexture(0, 0, 0, 1)
local title = overlay:CreateTexture(nil, "OVERLAY")
title:SetSize(760, 380)
title:SetPoint("CENTER")
local channels = { "Sound_SFXVolume", "Sound_MusicVolume", "Sound_AmbienceVolume", "Sound_DialogVolume" }
local active
local days = { first = { hours = 72 }, second = { hours = 48 }, final = { hours = 24 } }

function Dawn.RecoverAudio()
    local saved = TerminaClockDB.dawnAudioRecovery
    if not saved then return end
    for name, value in pairs(saved) do
        -- Keep volume adjustments made by the player during the transition.
        if tonumber(GetCVar(name)) == 0 then SetCVar(name, value) end
    end
    TerminaClockDB.dawnAudioRecovery = nil
end

local function QuietAudio()
    local saved = {}
    for _, name in ipairs(channels) do
        local value = GetCVar(name)
        if value then saved[name] = value end
    end
    TerminaClockDB.dawnAudioRecovery = saved
    for name in pairs(saved) do SetCVar(name, 0) end
end

function Dawn.Stop()
    if addon.Viewport then addon.Viewport.Stop() end
    active = nil
    overlay:SetScript("OnUpdate", nil)
    overlay:Hide()
    if TerminaClockDB then Dawn.RecoverAudio() end
    if addon.Sounds then addon.Sounds.Stop() end
end

overlay:SetScript("OnHide", function()
    if active then Dawn.Stop() end
end)
overlay:Hide()

local function Update(_, delta)
    if not active then return end
    active.elapsed = active.elapsed + delta
    local elapsed = active.elapsed
    if elapsed >= 5.2 then Dawn.Stop(); return end
    local opacity = math.min(1, elapsed / 0.35, (5.2 - elapsed) / 0.8)
    overlay:SetAlpha(math.max(0, opacity))
    title:SetAlpha(math.max(0, math.min(1, (elapsed - 0.35) / 0.5)))
    if elapsed >= 0.35 and not active.sounded then
        active.sounded = true
        addon.Sounds.Play("dawn", active.preview)
    end
end

function Dawn.Play(day, preview)
    if not days[day] then return false end
    if not preview and TerminaClockDB.transitions == false then
        addon.Sounds.Play("dawn")
        return true
    end
    Dawn.Stop()
    -- Restore at the same boundary that starts the dawn overlay, before its
    -- first fade frame, rather than relying on end-of-animation cleanup.
    QuietAudio()
    active = { elapsed = 0, preview = preview }
    title:SetTexture("Interface\\AddOns\\TerminaClock\\Textures\\dawn-" .. day .. ".tga", "CLAMP", "CLAMP", "NEAREST")
    -- Keep the title inside smaller windows while preserving its aspect ratio.
    local width = math.min(760, UIParent:GetWidth() * 0.85)
    title:SetSize(width, width / 2)
    title:SetAlpha(0)
    overlay:SetAlpha(0)
    overlay:Show()
    overlay:SetScript("OnUpdate", Update)
    return true
end

function Dawn.Day(remaining)
    if remaining <= 86400 then return "final" end
    if remaining <= 172800 then return "second" end
    return "first"
end

overlay:RegisterEvent("PLAYER_LOGOUT")
overlay:RegisterEvent("PLAYER_LEAVING_WORLD")
overlay:SetScript("OnEvent", function() Dawn.Stop() end)
