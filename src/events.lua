-- src/events.lua
local addonName, ns = ...
ns = ns or {}
ns.events = ns.events or {}
local M = ns.events

-- Local helper function to handle roaching for a specific player
local function HandleRoaching(roacherName)
    ns.config.DebugPrint(roacherName .. " is roaching out!")
    -- Check if the roacher has roached recently
    if ns.history.IsInHistory(roacherName) then
        return
    end
    -- Record this roach event in history
    ns.history.AddToHistory(roacherName)
    -- Play a random roach sound
    ns.sound.PlayRandomRoachSound()
    -- Display raid warning locally with the roacher's name
    ns.message.ShowRoachWarning(roacherName)
end

---returns true if checks relevant to all events are passed
---@return boolean
local function CrossEventChecks()
    -- Check if we should work outside instances
    if not ns.instance.IsPlayerInPvEInstance() and not ns.config.Get("enableOutsideInstances") then
        ns.config.DebugPrint("not in an instance")
        return false
    end

    -- Check if someone is in combat
    if not ns.combat.IsAnyGroupMemberInCombat() then
        ns.config.DebugPrint("combat not detected")
        return false
    else
        ns.config.DebugPrint("combat detected")
    end

    return true
end

---@diagnostic disable-next-line: unused-local
local function OnUnitSpellcastStart(unitTarget, _castGUID, spellID)
    ns.config.DebugPrint(unitTarget .. " " .. tostring(spellID))

    -- Handle teleportation spells cast by group members as potential roaching
    -- if mob then ignore
    if not UnitIsPlayer(unitTarget) then return end

    -- if not in group then ignore
    if not ns.roster.IsUnitInGroup(unitTarget) then
        -- unless it is the player and allowPlayer is true
        if not (unitTarget == "player" and ns.config.Get("allowPlayer")) then
            return
        end
    end

    -- Check if it's a teleportation spell
    if not ns.spells.isTeleportationSpell(spellID) then
        return
    end

    if not CrossEventChecks() then return end

    local casterName = UnitName(unitTarget)
    HandleRoaching(casterName)
end

local function OnMsgSystem(event, msg, ...)
    local leaverName = ns.chat_parser.DetectLeaverFromSystem(event, msg, ...)
    if not leaverName then
        local selfOrDisband = ns.chat_parser.DetectSelfOrDisband(event, msg, ...)

        if selfOrDisband == "disband" then
            ns.config.DebugPrint("Group disbanded")
            if not CrossEventChecks() then return end
            -- TODO: get the real leader name and remember it
            HandleRoaching("the leader")
            ns.history.ClearHistory()
            if ns.config.Get("hardcore") then
                ns.hardcore.clearDeathLog()
            end
        elseif selfOrDisband == "self" then
            ns.config.DebugPrint("You left the group")
            if not CrossEventChecks() then return end
            HandleRoaching(UnitName("player"))
            ns.history.ClearHistory()
            if ns.config.Get("hardcore") then
                ns.hardcore.clearDeathLog()
            end
        end

        return
    end

    -- Debug: print all leavers regardless of combat
    ns.config.DebugPrint(leaverName .. " left the group")
    if not CrossEventChecks() then return end
    if ns.config.Get("hardcore") and ns.hardcore.IsInDeathLog(leaverName) then
        ns.config.DebugPrint("he's dead anyway")
        return
    end

    HandleRoaching(leaverName)
end

-- Handler for UNIT_HEALTH_FREQUENT to detect deaths in Hardcore realms
local function OnUnitHealthFrequent(unit)
    -- Disable death detection handlers if not in a Hardcore realm
    -- (leaving group when dead in non-hardcore is roaching)
    if not ns.config.Get("hardcore") then return end

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
        ns.config.DebugPrint(unitName .. " has died (UNIT_HEALTH_FREQUENT)")
    end
end

-- Paired with OnUnitHealthFrequent to catch all deaths
local function OnCombatLogEventUnfiltered()
    -- Disable death detection handlers if not in a Hardcore realm
    -- (leaving group when dead in non-hardcore is roaching)
    if not ns.config.Get("hardcore") then return end

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
        ns.config.DebugPrint(destName .. " has died (COMBAT_LOG_EVENT_UNFILTERED)")
    end
end

-- Main event handler - routes events to specific handlers
function M.OnEvent(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        OnCombatLogEventUnfiltered()
    elseif event == "UNIT_HEALTH_FREQUENT" then
        OnUnitHealthFrequent(...)
    elseif event == "UNIT_SPELLCAST_START" then
        OnUnitSpellcastStart(...)
    elseif event == "CHAT_MSG_SYSTEM" then
        OnMsgSystem(event, ...)
    end
    -- Add more event routing as needed
end

M.ready = true
ns.events = M
