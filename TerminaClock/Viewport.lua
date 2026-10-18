local _, addon = ...
local Viewport = {}
addon.Viewport = Viewport
local driver = CreateFrame("Frame")
local savedPoints, savedRect, currentStep, restoring
local retryElapsed = 0
local matte = CreateFrame("Frame", nil, UIParent)
matte:SetParent(nil)
matte:SetAllPoints(UIParent)
matte:SetFrameStrata("BACKGROUND")
matte:SetFrameLevel(0)
local borders = {}
for _, edge in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do
    local border = matte:CreateTexture(nil, "BACKGROUND")
    border:SetColorTexture(0, 0, 0, 1)
    border:SetPoint(edge, UIParent, edge)
    borders[edge] = border
end
matte:Hide()

local function PhysicalRect(frame)
    local left, bottom, width, height = frame:GetRect()
    if not left or not bottom or not width or not height then return nil end
    local scale = frame:GetEffectiveScale()
    return {left * scale, bottom * scale, width * scale, height * scale}
end

local function MatchesRect(expected)
    local actual = PhysicalRect(WorldFrame)
    if not actual or not expected then return false end
    for index = 1,4 do
        if math.abs(actual[index] - expected[index]) > 1 then return false end
    end
    return true
end

local function FinishRestore()
    savedPoints, savedRect, currentStep, restoring = nil, nil, nil, nil
    driver:SetScript("OnUpdate", nil)
end

local function MatchesAnchors()
    local expected = savedPoints
    if #expected == 0 then
        expected = { {"TOPLEFT", UIParent, "TOPLEFT", 0, 0}, {"BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0} }
    end
    if WorldFrame:GetNumPoints() ~= #expected then return false end
    for index, point in ipairs(expected) do
        local actual = {WorldFrame:GetPoint(index)}
        for field = 1,5 do
            if actual[field] ~= point[field] then return false end
        end
    end
    return true
end

local function ApplyRestore()
    -- Keep the baseline if WoW ignores or rejects a resize. A later update
    -- retries it rather than capturing the inset viewport as the new baseline.
    local applied = pcall(function()
        WorldFrame:ClearAllPoints()
        if #savedPoints == 0 then
            WorldFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
            WorldFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
        else
            for _, point in ipairs(savedPoints) do WorldFrame:SetPoint(unpack(point, 1, 5)) end
        end
    end)
    if applied and MatchesAnchors() and MatchesRect(savedRect) then FinishRestore(); return true end
    return false
end

local function RetryRestore(_, elapsed)
    if not restoring then return end
    retryElapsed = retryElapsed + elapsed
    if retryElapsed < 0.1 then return end
    retryElapsed = 0
    ApplyRestore()
end

function Viewport.Stop()
    matte:Hide()
    if not savedPoints then return true end
    restoring, currentStep, retryElapsed = true, nil, 0
    if ApplyRestore() then return true end
    driver:SetScript("OnUpdate", RetryRestore)
    return false
end

function Viewport.RestoreFull()
    savedPoints = {}
    savedRect = PhysicalRect(UIParent)
    return Viewport.Stop()
end

function Viewport.SetStep(step)
    if step <= 0 or TerminaClockDB.screenEffect == false then Viewport.Stop(); return end
    if not WorldFrame then return end
    if currentStep == step and not restoring then return end
    restoring = nil
    driver:SetScript("OnUpdate", nil)
    if not savedPoints then
        savedPoints = {}
        savedRect = PhysicalRect(WorldFrame) or PhysicalRect(UIParent)
        for i = 1, WorldFrame:GetNumPoints() do
            savedPoints[i] = { WorldFrame:GetPoint(i) }
        end
    end
    currentStep = step
    local scale = 1 - math.min(step, 4) * 0.05
    local inset = (1 - scale) / 2
    local coordinateScale = UIParent:GetEffectiveScale() / WorldFrame:GetEffectiveScale()
    local x = UIParent:GetWidth() * inset * coordinateScale
    local y = UIParent:GetHeight() * inset * coordinateScale
    local borderScale = UIParent:GetEffectiveScale() / matte:GetEffectiveScale()
    borders.TOP:SetSize(UIParent:GetWidth() * borderScale, UIParent:GetHeight() * inset * borderScale)
    borders.BOTTOM:SetSize(UIParent:GetWidth() * borderScale, UIParent:GetHeight() * inset * borderScale)
    borders.LEFT:SetSize(UIParent:GetWidth() * inset * borderScale, UIParent:GetHeight() * borderScale)
    borders.RIGHT:SetSize(UIParent:GetWidth() * inset * borderScale, UIParent:GetHeight() * borderScale)
    matte:Show()
    WorldFrame:ClearAllPoints()
    WorldFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, -y)
    WorldFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -x, y)
end

function Viewport.Step(now, deadline)
    for index, day in ipairs(addon.Clock.Schedule(deadline)) do
        local untilDawn = day.dawn - now
        if index > 1 and now < deadline and untilDawn > 0 and untilDawn <= 1800 then
            return math.min(4, math.floor((1800 - untilDawn) / 360))
        end
    end
    return 0
end

function Viewport.Update(now, deadline)
    Viewport.SetStep(Viewport.Step(now, deadline))
end

driver:RegisterEvent("PLAYER_LOGOUT")
driver:RegisterEvent("PLAYER_LEAVING_WORLD")
driver:SetScript("OnEvent", function() Viewport.Stop() end)
