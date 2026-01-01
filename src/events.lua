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
            if ns.config.Get("hardcore") then
                ns.hardcore.clearDeathLog()
            end
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
    if not ns.combat.IsAnyGroupMemberInCombat() then
        return
    end

    if ns.config.Get("hardcore") and ns.hardcore.IsInDeathLog(leaverName) then
        return
    end

    HandleRoaching(leaverName)
end

-- Handler for UNIT_HEALTH_FREQUENT to detect deaths in Hardcore realms
local function OnUnitHealthFrequent(unit)
    --if not ns.config.Get("hardcore") then return end
    if not unit or not ns.roster.IsUnitInGroup(unit) then return end
    if not UnitExists(unit) then return end
    if not (UnitIsDeadOrGhost(unit) or UnitHealth(unit) <= 0) then
        return
    end

    local unitName = UnitName(unit)
    if ns.hardcore.IsInDeathLog(unitName) then
        return
    end

    ns.hardcore.AddToDeathLog(unitName)

    if ns.config.Get("debugMode") then
        ns.config.DebugPrint(unitName .. " has died (from UNIT_HEALTH_FREQUENT event)")
    end
end

-- Paired with OnUnitHealthFrequent to catch all deaths
local function OnCombatLogEventUnfiltered()
    local _, subEvent, _, _, _, _, _, destGUID, destName, _, _, _ = CombatLogGetCurrentEventInfo()

    if not subEvent == "UNIT_DIED" then
        return
    end

    -- check if destGUID corresponds to a raid member
    if not ns.roster.IsGUIDInGroup(destGUID) then
        return
    end

    ns.hardcore.AddToDeathLog(destName)

    if ns.config.Get("debugMode") then
        ns.config.DebugPrint(destName .. " has died (from UNIT_DIED event in COMBAT_LOG_EVENT_UNFILTERED)")
    end
end

-- Disable death detection handlers if not in a Hardcore realm
-- (leaving group when dead on non-hardcore is roaching if the fight goes on!)
if not ns.config.Get("hardcore") then
    OnCombatLogEventUnfiltered = function() end
    OnUnitHealthFrequent = function() end
end

-- Main event handler - routes events to specific handlers
function M.OnEvent(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        OnCombatLogEventUnfiltered()
    elseif event == "UNIT_HEALTH_FREQUENT" then
        OnUnitHealthFrequent(...)
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        OnUnitSpellcastChannelStart(...)
    elseif event == "CHAT_MSG_SYSTEM" then
        OnMsgSystem(event, ...)
    elseif event == "PLAYER_ENTERING_WORLD" then
        OnPlayerEnteringWorld()
    end
    -- Add more event routing as needed
end

M.ready = true
ns.events = M