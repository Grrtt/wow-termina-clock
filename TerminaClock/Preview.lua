local _, addon = ...
local Preview = {}
addon.Preview = Preview
local driver = CreateFrame("Frame")
local active

function Preview.IsPlaying()
    return active ~= nil
end

function Preview.Stop()
    if not active then return end
    active = nil
    driver:SetScript("OnUpdate", nil)
    addon.Dawn.Stop()
end

local function Update(_, delta)
    if not active then return end
    active.elapsed = active.elapsed + delta
    local elapsed = active.elapsed
    if elapsed >= 35.3 then Preview.Stop(); return end
    if elapsed >= 30 then
        if not active.dawn then
            active.dawn = true
            addon.Dawn.Play(active.day, true)
        end
        return
    end
    local bell = math.floor(elapsed / 6)
    if bell > active.bell then
        active.bell = bell
        addon.Sounds.Play("bell", true)
        addon.Viewport.SetStep(math.min(4, bell))
    end
end

function Preview.DayEnd(day)
    day = day or "second"
    if day ~= "first" and day ~= "second" and day ~= "final" then return false end
    Preview.Stop()
    addon.Dawn.Stop()
    active = { elapsed = 0, bell = 0, day = day }
    addon.Sounds.Play("bell", true)
    driver:SetScript("OnUpdate", Update)
    return true
end

driver:RegisterEvent("PLAYER_LOGOUT")
driver:RegisterEvent("PLAYER_LEAVING_WORLD")
driver:SetScript("OnEvent", function() Preview.Stop() end)
