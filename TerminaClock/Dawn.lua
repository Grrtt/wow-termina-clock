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
local remainingText = overlay:CreateFontString(nil, "OVERLAY")
remainingText:SetFont(STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF", 24, "OUTLINE")
remainingText:SetTextColor(1, 1, 0.9)
remainingText:SetPoint("CENTER", 0, -64)
local channels = { "Sound_SFXVolume", "Sound_MusicVolume", "Sound_AmbienceVolume", "Sound_DialogVolume" }
local active
local days = { first = true, second = true, final = true }

local function ValidVolume(value)
    if type(value) ~= "string" and type(value) ~= "number" then return false end
    local volume = tonumber(value)
    return volume and volume == volume and volume >= 0 and volume <= 1
end

function Dawn.RecoverAudio()
    local saved = TerminaClockDB.dawnAudioRecovery
    TerminaClockDB.dawnAudioRecovery = nil
    if type(saved) ~= "table" then return end
    -- Saved data must never select arbitrary CVars to modify.
    for _, name in ipairs(channels) do
        local value = saved[name]
        if ValidVolume(value) and tonumber(GetCVar(name)) == 0 then
            SetCVar(name, value)
        end
    end
end

local function QuietAudio()
    local saved = {}
    for _, name in ipairs(channels) do
        local value = GetCVar(name)
        if ValidVolume(value) then saved[name] = value end
    end
    TerminaClockDB.dawnAudioRecovery = saved
    for _, name in ipairs(channels) do
        if saved[name] ~= nil then SetCVar(name, 0) end
    end
end

function Dawn.Stop()
    active = nil
    overlay:SetScript("OnUpdate", nil)
    overlay:Hide()
    if TerminaClockDB then Dawn.RecoverAudio() end
    if addon.Sounds then addon.Sounds.Stop() end
    -- A render-frame error must not prevent audio recovery or leave the overlay up.
    if addon.Viewport then
        local restored = pcall(addon.Viewport.Stop)
        if not restored then
            print("Termina Clock: audio restored, but WoW could not restore the render area. Use /termina test stop to retry.")
        end
    end
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
    local textAlpha = math.max(0, math.min(1, (elapsed - 0.35) / 0.5))
    title:SetAlpha(textAlpha)
    remainingText:SetAlpha(textAlpha)
    if elapsed >= 0.35 and not active.sounded then
        active.sounded = true
        addon.Sounds.Play(active.night and "tick" or "dawn", active.preview)
    end
end

function Dawn.Play(day, preview, hours, night)
    if not days[day] then return false end
    if not preview and TerminaClockDB.transitions == false then
        addon.Sounds.Play(night and "tick" or "dawn")
        return true
    end
    Dawn.Stop()
    -- Restore at the same boundary that starts the dawn overlay, before its
    -- first fade frame, rather than relying on end-of-animation cleanup.
    if not night then QuietAudio() end
    hours = hours or addon.Clock.DawnHours(day, TerminaClockDB.deadline or addon.Clock.defaultDeadline)
    active = { elapsed = 0, preview = preview, night = night }
    black:SetColorTexture(night and 0.12 or 0, 0, night and 0.2 or 0, night and 0.45 or 1)
    remainingText:SetText(string.format("–%d Hours Remain–", math.max(0, hours)))
    remainingText:SetAlpha(0)
    title:SetTexture("Interface\\AddOns\\TerminaClock\\Textures\\" .. (night and "night-" or "dawn-") .. day .. ".tga", "CLAMP", "CLAMP", "NEAREST")
    -- Keep the title inside smaller windows while preserving its aspect ratio.
    local width = math.min(760, UIParent:GetWidth() * 0.85)
    title:SetSize(width, width / 2)
    title:SetAlpha(0)
    overlay:SetAlpha(0)
    overlay:Show()
    overlay:SetScript("OnUpdate", Update)
    return true
end


overlay:RegisterEvent("PLAYER_LOGOUT")
overlay:RegisterEvent("PLAYER_LEAVING_WORLD")
overlay:SetScript("OnEvent", function() Dawn.Stop() end)
