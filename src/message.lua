-- src/message.lua
local addonName, ns = ...
ns = ns or {}
ns.message = ns.message or {}
local M = ns.message

local roachQuotes = {
    "XYZ is a coward",
    "XYZ roached out!",
    "XYZ used to work at Blizzard",
    "XYZ quit faster than Patch 1.12",
    "XYZ quit, a true classic",
    "XYZ went AFK",
    "XYZ betrayed the group",
    "Have you seen XYZ recently?",
    "XYZ's courage went offline",
    "XYZ left us hanging",
    "XYZ exited stage left",
    "XYZ abandoned ship",
    "XYZ couldn't handle the heat",
    "XYZ left us in the dust",
    "XYZ left, now we know their true class",
    "XYZ pulled a disappearing act",
    "XYZ found a better quest",
    "XYZ is testing 'single-player mode'",
    "Everyone knew XYZ couldn't handle it",
    "See you losers, says XYZ...",
    -- TODO, more funny quotes for roaching
}

local roachQuotesCt = #roachQuotes

-- Local function to strip server from name
local function StripServer(name)
    return name:gsub("-.*", "") -- Remove everything after first dash
end

---Get a random roach message with the player's name inserted.
---@param name string The name to insert
---@return string
local function GetRandomRoachMessage(name)
    local quote = roachQuotes[fastrandom(roachQuotesCt)]
    local result = string.gsub(quote, "XYZ", name) -- Replace placeholder with player name
    return result
end

---Display a raid warning message locally for a player who roached out.
---@param name string The name of the player who roached
function M.ShowRoachWarning(name)
    if not ns.config.Get("showRaidWarnings") then return end
    local displayName = ns.config.Get("stripServer") and StripServer(name) or name
    local message = GetRandomRoachMessage(displayName)
    ---@diagnostic disable-next-line: undefined-global
    RaidNotice_AddMessage(RaidWarningFrame, message, ChatTypeInfo["RAID_WARNING"])
end

ns.message = M
