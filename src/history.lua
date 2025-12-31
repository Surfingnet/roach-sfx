-- src/history.lua
local addonName, ns = ...
ns = ns or {}
ns.history = ns.history or {}
local M = ns.history

-- Initialize an empty array of strings
local history = {}

-- Local cleanup function to remove the oldest entry
local function Cleanup()
    if #history > 0 then
        table.remove(history, 1)
    end
end

-- Function to push to the array and schedule delayed cleanup
function M.AddToHistory(name)
    table.insert(history, name)
    C_Timer.After(5, Cleanup)
end

-- Function to check if a name is in the history array
function M.IsInHistory(name)
    for _, hname in ipairs(history) do
        if hname:lower() == name:lower() then
            return true
        end
    end
    return false
end

ns.history = M