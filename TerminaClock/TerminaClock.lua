local addonName, addon = ...
local Clock = addon.Clock
local frame = CreateFrame("Frame", "TerminaClockFrame", UIParent)
frame:SetSize(280, 160)
frame:SetClampedToScreen(true)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")

local function Label(size, x, y, text)
    local label = frame:CreateFontString(nil, "OVERLAY")
    label:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE")
    label:SetPoint("CENTER", frame, "CENTER", x, y)
    label:SetTextColor(1, 0.85, 0.48)
    label:SetText(text or "")
    return label
end

local texturePath = "Interface\\AddOns\\TerminaClock\\Textures\\"
local function Texture(name, width, height, layer)
    local texture = frame:CreateTexture(nil, layer or "ARTWORK")
    texture:SetSize(width, height)
    texture:SetPoint("CENTER")
    texture:SetTexture(texturePath .. name .. ".tga", "CLAMP", "CLAMP", "NEAREST")
    return texture
end
local dial = Texture("dial", 256, 128, "BACKGROUND")
local dayTexture = Texture("first", 256, 128)
local sun = Texture("sun", 25, 25, "OVERLAY")
local moon = Texture("moon", 25, 25, "OVERLAY")
local minuteStar = Texture("star", 16, 16, "OVERLAY")
local hourLabel = Texture("hour6", 22, 22, "OVERLAY")
local currentHour
local finalTimer = Label(23, 0, -69)
finalTimer:Hide()
local dayTextures = { ["1st"] = "first", ["2nd"] = "second", Final = "final", New = "new", ["--"] = "waiting" }
local currentDay
local labelPreview, labelPreviewUntil
local sounds = addon.Sounds

local function ApplySettings()
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", UIParent, "CENTER", TerminaClockDB.x, TerminaClockDB.y)
    frame:SetScale(TerminaClockDB.scale)
    frame:SetShown(not TerminaClockDB.hidden)
end

local function Refresh()
    local now = GetServerTime()
    local state = Clock.State(now, TerminaClockDB.deadline)
    if labelPreview and GetTime() >= labelPreviewUntil then
        labelPreview = nil
        ApplySettings()
    end
    local dayLabel = labelPreview or state.dayLabel
    if currentDay ~= dayLabel then
        dayTexture:SetTexture(texturePath .. dayTextures[dayLabel] .. ".tga", "CLAMP", "CLAMP", "NEAREST")
        currentDay = dayLabel
    end
    -- The original HUD shows an hour marker advancing in discrete steps.
    local hourStep = math.floor(state.halfProgress * 12) / 12
    local angle = math.pi - hourStep * math.pi
    local x, y = math.cos(angle) * 105, math.sin(angle) * 81 - 42
    sun:SetShown(state.daytime)
    moon:SetShown(not state.daytime)
    sun:ClearAllPoints()
    moon:ClearAllPoints()
    sun:SetPoint("CENTER", frame, "CENTER", x, y)
    moon:SetPoint("CENTER", frame, "CENTER", x, y)
    hourLabel:ClearAllPoints()
    hourLabel:SetPoint("CENTER", frame, "CENTER", x, y + 23)
    if currentHour ~= state.hour then
        hourLabel:SetTexture(texturePath .. "hour" .. state.hour .. ".tga", "CLAMP", "CLAMP", "NEAREST")
        currentHour = state.hour
    end
    local minuteAngle = math.pi / 2 - state.minuteProgress * 2 * math.pi
    minuteStar:ClearAllPoints()
    minuteStar:SetPoint("CENTER", frame, "CENTER", math.cos(minuteAngle) * 40,
        math.sin(minuteAngle) * 29 - 23)
    finalTimer:SetShown(state.urgent or state.remaining == 0)
    finalTimer:SetText(state.text)
    finalTimer:SetTextColor(1, 0.3, 0.2, state.urgent and (0.8 + 0.2 * math.sin(GetTime() * 2)) or 1)
    sounds.Update(now, TerminaClockDB.deadline)

end

frame:SetScript("OnDragStart", function(self)
    if not TerminaClockDB.locked then self:StartMoving() end
end)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local x, y = self:GetCenter()
    local parentX, parentY = UIParent:GetCenter()
    local scale = self:GetScale()
    TerminaClockDB.x, TerminaClockDB.y = x * scale - parentX, y * scale - parentY
    ApplySettings()
end)
frame:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:AddLine("Termina Clock")
    local state = Clock.State(GetServerTime(), TerminaClockDB.deadline)
    GameTooltip:AddLine(state.title, 1, 1, 0.8)
    GameTooltip:AddLine(state.text .. " remaining", 1, 1, 1)
    GameTooltip:AddLine("Target: " .. date("%Y-%m-%d %H:%M:%S", TerminaClockDB.deadline) .. " (local time)", 1, 1, 1)
    GameTooltip:AddLine("Estimated stress-test end: three hours after it starts.", 1, 0.8, 0.4, true)
    GameTooltip:AddLine("The clock follows your computer's local time.", 1, 1, 1)
    GameTooltip:AddLine("Drag to move. /termina for commands.", 1, 1, 1)
    GameTooltip:Show()
end)
frame:SetScript("OnLeave", function() GameTooltip:Hide() end)

local function Message(text)
    print("|cffffd078Termina Clock:|r " .. text)
end

SLASH_TERMINACLOCK1 = "/termina"
SlashCmdList.TERMINACLOCK = function(input)
    local command, value = input:match("^(%S*)%s*(.-)%s*$")
    command = command:lower()
    addon.Preview.Stop()
    labelPreview = nil
    if command == "hide" or command == "show" then
        TerminaClockDB.hidden = command == "hide"
    elseif command == "lock" then
        TerminaClockDB.locked = not TerminaClockDB.locked
        Message(TerminaClockDB.locked and "Position locked." or "Position unlocked.")
    elseif command == "scale" then
        local scale = tonumber(value)
        if not scale or scale < 0.5 or scale > 3 then
            Message("Use /termina scale 0.5 through 3.")
            return
        end
        TerminaClockDB.scale = scale
    elseif command == "deadline" then
        local deadline = tonumber(value)
        if not deadline or deadline ~= deadline or deadline < 1 or deadline > 4102444800 then
            Message("Use /termina deadline <Unix timestamp in seconds>.")
            return
        end
        TerminaClockDB.deadline = math.floor(deadline)
        sounds.Reset()
    elseif command == "dawn" or command == "dusk" then
        if value == "stop" then addon.Dawn.Stop(); return end
        local day = value ~= "" and value or "first"
        local hours
        if command == "dusk" then
            for _, entry in ipairs(Clock.Schedule(TerminaClockDB.deadline)) do
                if entry.name == day then hours = math.ceil((TerminaClockDB.deadline - entry.dusk) / 3600) end
            end
        end
        if not addon.Dawn.Play(day, true, hours, command == "dusk") then
            Message("Use /termina dawn first | second | final | stop.")
        end
        return
    elseif command == "transitions" then
        TerminaClockDB.transitions = TerminaClockDB.transitions == false
        addon.Dawn.Stop()
        Message(TerminaClockDB.transitions and "Dawn transitions enabled." or "Dawn transitions disabled.")
    elseif command == "screen" or command == "camera" then
        if value == "test" then
            addon.Preview.DayEnd()
            return
        end
        TerminaClockDB.screenEffect = TerminaClockDB.screenEffect == false
        addon.Viewport.Stop()
        Message(TerminaClockDB.screenEffect and "Pre-dawn screen effect enabled." or "Pre-dawn screen effect disabled.")
    elseif command == "sound" then
        TerminaClockDB.muted = not TerminaClockDB.muted
        sounds.Stop()
        Message(TerminaClockDB.muted and "Sounds muted." or "Sounds enabled.")
    elseif command == "test" then
        local labels = { first = "1st", ["1st"] = "1st", second = "2nd", ["2nd"] = "2nd", final = "Final" }
        if labels[value] then
            labelPreview, labelPreviewUntil = labels[value], GetTime() + 15
            frame:Show()
            Refresh()
            Message("Previewing " .. labelPreview .. " for 15 seconds. /termina test stop to finish.")
            return
        end
        local preview, day = value:match("^(%S+)%s*(%S*)$")
        if preview == "dayend" then
            if not addon.Preview.DayEnd(day ~= "" and day or "second") then
                Message("Use /termina test dayend [first|second|final].")
            end
            return
        end
        if value == "stop" then ApplySettings(); Refresh(); return end
        if value == "dawn" then addon.Dawn.Play("first", true); return end
        local name = value ~= "" and value or "bell"
        if not sounds.Play(name, true) then Message("Use /termina test bell | dawn | tick | dayend [second|final] | 1st | 2nd | final | stop.") end
        return
    elseif command == "reset" then
        sounds.Reset()
        TerminaClockDB = { x = 0, y = -220, scale = 1, deadline = Clock.defaultDeadline }
        sounds.Reset()
    else
        Message("/termina show | hide | lock | scale <0.5–3> | deadline <Unix seconds> | dawn/dusk <first|second|final|stop> | transitions | screen [test] | sound | test <bell|dawn|tick|dayend|stop> | reset")
        return
    end
    ApplySettings()
    Refresh()
end

frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, _, name)
    if name ~= addonName then return end
    TerminaClockDB = TerminaClockDB or {}
    if TerminaClockDB.deadline == Clock.previousDefaultDeadline then
        TerminaClockDB.deadline = Clock.defaultDeadline
    end
    local defaults = { x = 0, y = -220, scale = 1, deadline = Clock.defaultDeadline }
    for key, value in pairs(defaults) do
        if type(TerminaClockDB[key]) ~= "number" then TerminaClockDB[key] = value end
    end
    -- Preserve an explicit opt-out from the old camera effect after upgrading.
    if TerminaClockDB.screenEffect == nil and TerminaClockDB.camera == false then
        TerminaClockDB.screenEffect = false
    end
    addon.Dawn.RecoverAudio()
    ApplySettings()
    Refresh()
    local elapsed = 0
    local ticker = CreateFrame("Frame")
    ticker:SetScript("OnUpdate", function(_, delta)
        elapsed = elapsed + delta
        if elapsed < 0.1 then return end
        elapsed = 0
        Refresh()
    end)
    self:UnregisterEvent("ADDON_LOADED")
end)
