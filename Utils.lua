-- Utils.lua
-- Common utilities for MegaPandaMarker addon

local _, Addon = ...
Addon.Utils = {}

-- String utilities
function Addon.Utils.toLower(str)
    return str:lower()
end

function Addon.Utils.toTitleCase(str)
    return str:lower():gsub("(%a)([%w_'’-]*)", function(first, rest)
        return first:upper() .. rest
    end)
end

function Addon.Utils.split(str, sep)
    local t = {}
    sep = sep or ","
    for part in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(t, part)
    end
    return t
end

-- Data parsing utility
function Addon.Utils.parseDataString(data_str)
    local db = {}
    for entry in string.gmatch(data_str, "([^;]+)") do
        local key, prio, role = string.match(entry, "([^,]+),([^,]+),([^,]+)")
        if key and prio and role then
            db[Addon.Utils.toLower(key)] = { priority = tonumber(prio), role = { tonumber(role) } }
        end
    end
    return db
end

-- Timer utilities for sequential and retry operations
function Addon.Utils.scheduleSequence(count, delay, action, onComplete)
    local i = count
    local function step()
        if i > 0 then
            action(i)
            i = i - 1
            C_Timer.After(delay, step)
        else
            if onComplete then C_Timer.After(delay, onComplete) end
        end
    end
    step()
end

function Addon.Utils.clearMarkerWithRetry(unit, retryCount, delay)
    local function attempt(rem)
        C_Timer.After(delay, function()
            if GetRaidTargetIndex(unit) ~= 0 then
                SetRaidTarget(unit, 0)
                if rem > 0 then attempt(rem - 1) end
            end
        end)
    end
    attempt(retryCount)
end

return Addon.Utils
