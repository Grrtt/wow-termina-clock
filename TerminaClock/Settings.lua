local _, addon = ...
local Settings = {}
addon.Settings = Settings

function Settings.ValidNumber(value, minimum, maximum)
    return type(value) == "number" and value == value and value >= minimum and value <= maximum
end

function Settings.Normalize(saved, defaultDeadline, previousDeadline)
    local settings = type(saved) == "table" and saved or {}
    local numbers = {
        x = { -100000, 100000, 0 },
        y = { -100000, 100000, -220 },
        scale = { 0.5, 3, 1 },
        deadline = { 1, 4102444800, defaultDeadline },
    }
    for name, bounds in pairs(numbers) do
        if not Settings.ValidNumber(settings[name], bounds[1], bounds[2]) then
            settings[name] = bounds[3]
        end
    end
    settings.deadline = math.floor(settings.deadline)
    if settings.deadline == previousDeadline then settings.deadline = defaultDeadline end
    if settings.screenEffect == nil and settings.camera == false then settings.screenEffect = false end
    for name, default in pairs({ hidden = false, locked = false, muted = false, screenEffect = true, transitions = true }) do
        if type(settings[name]) ~= "boolean" then settings[name] = default end
    end
    return settings
end
