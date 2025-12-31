-- src/events.lua
local addonName, ns = ...
ns = ns or {}
ns.events = ns.events or {}
local M = ns.events

-- Local helper function to handle roaching for a specific player
local function HandleRoaching(roacherName)
    -- Check if the roacher has roached recently
    if ns.history.IsInHistory(roacherName) then
        return
    end
    -- Record this roach event in history
    ns.history.AddToHistory(roacherName)
    -- Play a random roach sound
    ns.sound.PlayRandomRoachSound()

    -- Display raid warning locally with the roacher's name
    if ns.config.Get("showRaidWarnings") then
        ns.message.ShowRoachWarning(roacherName)
    end
end

-- Specific event handlers
local function OnPlayerEnteringWorld()
    -- Handle player entering world
end

---@diagnostic disable-next-line: unused-local
local function OnUnitSpellcastChannelStart(unit, spellName, _spellRank)
    -- Handle teleportation spells cast by group members as potential roaching
    -- if mob then ignore
    if not UnitIsPlayer(unit) then return end

    -- Check if we should work outside instances
    if not ns.instance.IsPlayerInPvEInstance() and not ns.config.Get("enableOutsideInstances") then
        return
    end

    -- if not in group then ignore
    local casterName = UnitName(unit)
    if not ns.roster.IsUnitInGroup(unit) then
        -- unless it is the player and allowPlayer is true
        if not (unit == "player" and ns.config.Get("allowPlayer")) then
            return
        end
    end

    -- Check if it's a teleportation spell
    if not ns.spells.isTeleportationSpell(spellName) then
        return
    end

    if ns.config.Get("debugMode") then
        ns.config.DebugPrint(casterName .. " started channelling " .. spellName)
        ns.config.DebugPrint("combat detected: " .. ns.combat.IsAnyGroupMemberInCombat())
    end

    -- Check if someone is in combat
    if ns.combat.IsAnyGroupMemberInCombat() then
        HandleRoaching(casterName)
    end
end

local function OnMsgSystem(event, msg, ...)
    local leaverName = ns.chat_parser.DetectLeaverFromSystem(event, msg, ...)
    if not leaverName then
        if ns.chat_parser.DetectSelfOrDisband(event, msg, ...) then
            ns.history.ClearHistory()
            -- TODO: deathlog clear?
        end
        return
    end

    -- Debug: print all leavers regardless of combat
    if ns.config.Get("debugMode") then
        ns.config.DebugPrint(leaverName .. " left the group")
    end

    -- Check if we should work outside instances
    if not ns.instance.IsPlayerInPvEInstance() and not ns.config.Get("enableOutsideInstances") then
        return
    end

    if ns.config.Get("debugMode") then
        ns.config.DebugPrint("combat detected: " .. ns.combat.IsAnyGroupMemberInCombat())
    end

    -- Check if someone is in combat
    if ns.combat.IsAnyGroupMemberInCombat() then
        HandleRoaching(leaverName)
    end
end

-- Main event handler - routes events to specific handlers
function M.OnEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        OnPlayerEnteringWorld()
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        OnUnitSpellcastChannelStart(...)
    elseif event == "CHAT_MSG_SYSTEM" then
        OnMsgSystem(event, ...)
    -- Add more event routing as needed
    end
end

ns.events = M