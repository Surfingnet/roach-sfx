-- src/chat_parser.lua
local addonName, ns = ...
ns = ns or {}
ns.chat_parser = ns.chat_parser or {}
local M = ns.chat_parser

-- Constructs a secure Lua pattern for Blizzard strings containing "%s"
local function makeNamePattern(format_string)
    local placeholder = "<<<PLAYERNAME>>>"
    local s = format_string

    -- handle positional specifiers like %1$s, %2$s, ...
    s = s:gsub("%%(%d+)%$s", placeholder)
    -- handle simple %s
    s = s:gsub("%%s", placeholder)

    -- escape magic characters for Lua patterns
    s = s:gsub("([%^%$%(%)%%.%[%]%*%+%-%?])", "%%%1")

    -- allow any characters (including spaces / multibyte) for the captured name
    s = s:gsub(placeholder, "(.+)")

    return "^" .. s .. "$"
end

-- Constructs an exact pattern (no captures) for a given string
local function makeExactPattern(format_string)
    local s = format_string
    s = s:gsub("([%^%$%(%)%%.%[%]%*%+%-%?])", "%%%1")
    return "^" .. s .. "$"
end

-- trim leading/trailing spaces just in case
local function trimSpaces(name)
    return name:match("^%s*(.-)%s*$")
end

-- List of constants (only these will be used)
local LEAVERS_CONSTS = { -- messages indicating that somebody has left
    "ERR_RAID_MEMBER_REMOVED_S",--ok
    "ERR_LEFT_GROUP_S",--ok
}
local SELF_CONSTS = { -- messages indicating that the client has left
    "ERR_RAID_YOU_LEFT",--ok
    "ERR_LEFT_GROUP_YOU",--ok
}
local DISBAND_CONSTS = { -- messages indicating that the group has been disbanded
    "ERR_GROUP_DISBANDED",--ok
}

local leaver_patterns = {}
for _, cname in ipairs(LEAVERS_CONSTS) do
    local val = _G[cname]
    if type(val) == "string" then
        table.insert(leaver_patterns, makeNamePattern(val))
    end
end

local self_patterns = {}
for _, cname in ipairs(SELF_CONSTS) do
    local val = _G[cname]
    if type(val) == "string" then
        table.insert(self_patterns, makeExactPattern(val))
    end
end

local disband_patterns = {}
for _, cname in ipairs(DISBAND_CONSTS) do
    local val = _G[cname]
    if type(val) == "string" then
        table.insert(disband_patterns, makeExactPattern(val))
    end
end

-- Returns the name of the leaver (string) if the message corresponds to "X has left the group", otherwise nil
function M.DetectLeaverFromSystem(event, msg, ...)
    if event ~= "CHAT_MSG_SYSTEM" then return end
    if not msg or msg == "" then return end
    for _, pat in ipairs(leaver_patterns) do
        local name = msg:match(pat)
        if name and name ~= "" then
            return trimSpaces(name)
        end
    end
end

-- Detects if the message indicates that the client has left or the group has been disbanded.
-- Returns "self", "disband", or nil.
function M.DetectSelfOrDisband(event, msg, ...)
    if event ~= "CHAT_MSG_SYSTEM" then return end
    if not msg or msg == "" then return end
    for _, pat in ipairs(disband_patterns) do
        if msg:match(pat) then
            return "disband"
        end
    end
    for _, pat in ipairs(self_patterns) do
        if msg:match(pat) then
            return "self"
        end
    end
end

ns.chat_parser = M
