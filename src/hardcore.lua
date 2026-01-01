-- src/hardcore.lua
local addonName, ns = ...
ns = ns or {}
ns.hardcore = ns.hardcore or {}
local M = ns.hardcore

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