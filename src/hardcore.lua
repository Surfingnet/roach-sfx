-- src/hardcore.lua
local addonName, ns = ...
ns = ns or {}
ns.hardcore = ns.hardcore or {}
local M = ns.hardcore

---Returns true if the current realm is a Hardcore season realm.
function M.IsHardcoreRealm()
---@diagnostic disable-next-line: undefined-global
    if not C_Seasons or not C_Seasons.GetActiveSeason then -- WoW API global
        return false
    end
---@diagnostic disable-next-line: undefined-global
    return C_Seasons.GetActiveSeason() == Enum.Season.Hardcore -- WoW API global
end

-- Initialize an empty array of strings
local deathLog = {}

-- Function to push to the array
function M.AddToHistory(name)
    table.insert(deathLog, name)
    --C_Timer.After(20, Cleanup)
end

-- Function to check if a name is in the history array
function M.IsInDeathLog(name)
    for _, hname in ipairs(deathLog) do
        if hname:lower() == name:lower() then
            return true
        end
    end
    return false
end

function M.clearDeathLog()
    deathLog = {}
end

ns.hardcore = M