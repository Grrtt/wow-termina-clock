local _, addon = ...
local Viewport = {}
addon.Viewport = Viewport
local driver = CreateFrame("Frame")
local savedPoints, currentStep
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

function Viewport.Stop()
    if not savedPoints then return end
    WorldFrame:ClearAllPoints()
    if #savedPoints == 0 then
        -- Native full-screen WorldFrame can have no Lua-visible anchors.
        -- Clearing its points alone retains the inset size from the preview.
        WorldFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
        WorldFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
    else
        for _, point in ipairs(savedPoints) do
            WorldFrame:SetPoint(unpack(point, 1, 5))
        end
    end
    savedPoints, currentStep = nil, nil
    matte:Hide()
end

function Viewport.SetStep(step)
    if step <= 0 or TerminaClockDB.screenEffect == false then Viewport.Stop(); return end
    if not WorldFrame then return end
    if currentStep == step then return end
    if not savedPoints then
        savedPoints = {}
        for i = 1, WorldFrame:GetNumPoints() do
            savedPoints[i] = { WorldFrame:GetPoint(i) }
        end
    end
    currentStep = step
    local scale = 1 - math.min(step, 4) * 0.05
    local inset = (1 - scale) / 2
    local x = UIParent:GetWidth() * inset
    local y = UIParent:GetHeight() * inset
    borders.TOP:SetSize(UIParent:GetWidth(), y)
    borders.BOTTOM:SetSize(UIParent:GetWidth(), y)
    borders.LEFT:SetSize(x, UIParent:GetHeight())
    borders.RIGHT:SetSize(x, UIParent:GetHeight())
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
