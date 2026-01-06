-- src/hardcore.lua
local addonName, ns = ...
ns = ns or {}
ns.hardcore = ns.hardcore or {}
local M = ns.hardcore

-- Initialize an empty array of strings
local death_log = {}

-- Function to push to the array
function M.AddToDeathLog(name)
    table.insert(death_log, name)
    --C_Timer.After(20, Cleanup)
end

-- Function to check if a name is in the history array
function M.IsInDeathLog(name)
    for _, hname in ipairs(death_log) do
        if hname:lower() == name:lower() then
            return true
        end
    end
    return false
end

function M.ClearDeathLog()
    death_log = {}
end

ns.hardcore = M
