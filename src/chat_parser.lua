-- src/chat_parser.lua
local addonName, ns = ...
ns = ns or {}
ns.chat_parser = ns.chat_parser or {}
local M = ns.chat_parser

-- Constructs a secure Lua pattern for Blizzard strings containing "%s"
local function MakeNamePattern(formatString)
    local PH = "<<<PLAYERNAME>>>"
    local s = formatString:gsub("%%s", PH)
    s = s:gsub("([%^%$%(%)%%.%[%]%*%+%-%?])", "%%%1")
    s = s:gsub(PH, "(%S+)")
    return "^" .. s .. "$"
end

-- Constructs an exact pattern (no captures) for a given string
local function MakeExactPattern(formatString)
    local s = formatString
    s = s:gsub("([%^%$%(%)%%.%[%]%*%+%-%?])", "%%%1")
    return "^" .. s .. "$"
end

-- List of candidate constants (only these will be used)
local leaverConsts = {
    "ERR_LEFT_GROUP_S",
    "ERR_LEAVE_GROUP_S",
    "ERR_RAID_MEMBER_REMOVED_S",
    "ERR_LEFT_RAID_MEMBER_S",
}
local selfConsts = { -- messages indicating that the client has left
    "ERR_LEFT_GROUP",
    "YOU_LEFT_PARTY",
    "YOU_LEFT_RAID",
    "ERR_LEFT_RAID",
    "ERR_LEAVE_GROUP", -- variant possible
}
local disbandConsts = { -- messages indicating that the group has been disbanded
    "ERR_GROUP_DISBANDED",
    "ERR_RAID_DISBANDED",
}

local leaverPatterns = {}
for _, cname in ipairs(leaverConsts) do
    local val = _G[cname]
    if type(val) == "string" then
        table.insert(leaverPatterns, MakeNamePattern(val))
    end
end

local selfPatterns = {}
for _, cname in ipairs(selfConsts) do
    local val = _G[cname]
    if type(val) == "string" then
        table.insert(selfPatterns, MakeExactPattern(val))
    end
end

local disbandPatterns = {}
for _, cname in ipairs(disbandConsts) do
    local val = _G[cname]
    if type(val) == "string" then
        table.insert(disbandPatterns, MakeExactPattern(val))
    end
end

-- Returns the name of the leaver (string) if the message corresponds to "X has left the group", otherwise nil
function M.DetectLeaverFromSystem(event, msg, ...)
    if event ~= "CHAT_MSG_SYSTEM" then return end
    if not msg or msg == "" then return end
    for _, pat in ipairs(leaverPatterns) do
        local name = msg:match(pat)
        if name and name ~= "" then
            return name
        end
    end
end

-- Detects if the message indicates that the client has left or the group has been disbanded.
-- Returns "self", "disband", or nil.
function M.DetectSelfOrDisband(event, msg, ...)
    if event ~= "CHAT_MSG_SYSTEM" then return end
    if not msg or msg == "" then return end
    for _, pat in ipairs(disbandPatterns) do
        if msg:match(pat) then
            return "disband"
        end
    end
    for _, pat in ipairs(selfPatterns) do
        if msg:match(pat) then
            return "self"
        end
    end
end

ns.chat_parser = M