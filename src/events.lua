-- src/events.lua
local addonName, ns = ...
ns = ns or {}
ns.events = ns.events or {}
local M = ns.events

-- Local helper function to handle roaching for a specific player
local function handleRoaching(name)
    ns.config.DebugPrint(name .. " is roaching out!")
    -- Check if the roacher has roached recently
    if ns.history.IsInHistory(name) then
        return
    end
    -- Record this roach event in history
    ns.history.AddToHistory(name)
    -- Play a random roach sound
    ns.sound.PlayRandomRoachSound()
    -- Display raid warning locally with the roacher's name
    ns.message.ShowRoachWarning(name)
end

---returns true if checks relevant to all events are passed
---@return boolean
local function crossEventChecks()
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
local function onUnitSpellcastStart(unit_target, _, spell_id)
    ns.config.DebugPrint(unit_target .. " " .. tostring(spell_id))

    -- Handle teleportation spells cast by group members as potential roaching
    -- if mob then ignore
    if not UnitIsPlayer(unit_target) then return end

    -- if not in group then ignore
    if not ns.roster.IsUnitInGroup(unit_target) then
        -- unless it is the player and allowPlayer is true
        if not (unit_target == "player" and ns.config.Get("allowPlayer")) then
            return
        end
    end

    -- Check if it's a teleportation spell
    if not ns.spells.isTeleportationSpell(spell_id) then
        return
    end

    if not crossEventChecks() then return end

    local caster_name = UnitName(unit_target) -- target of tp spell is the caster of it
    handleRoaching(caster_name)
end

local function onMsgSystem(event, msg, ...)
    local leaver_name = ns.chat_parser.DetectLeaverFromSystem(event, msg, ...)
    if not leaver_name then
        local self_or_disband = ns.chat_parser.DetectSelfOrDisband(event, msg, ...)

        if self_or_disband == "disband" then
            ns.config.DebugPrint("Group disbanded")
            if not crossEventChecks() then return end
            -- TODO: get the real leader name and remember it
            handleRoaching("the leader")
            ns.history.ClearHistory()
            if ns.config.Get("hardcore") then
                ns.hardcore.ClearDeathLog()
            end
        elseif self_or_disband == "self" then
            ns.config.DebugPrint("You left the group")
            if not crossEventChecks() then return end
            handleRoaching(UnitName("player"))
            ns.history.ClearHistory()
            if ns.config.Get("hardcore") then
                ns.hardcore.ClearDeathLog()
            end
        end

        return
    end

    -- Debug: print all leavers regardless of combat
    ns.config.DebugPrint(leaver_name .. " left the group")
    if not crossEventChecks() then return end
    if ns.config.Get("hardcore") and ns.hardcore.IsInDeathLog(leaver_name) then
        ns.config.DebugPrint("he's dead anyway")
        return
    end

    handleRoaching(leaver_name)
end

-- Handler for UNIT_HEALTH_FREQUENT to detect deaths in Hardcore realms
local function onUnitHealthFrequent(unit)
    -- Disable death detection handlers if not in a Hardcore realm
    -- (leaving group when dead in non-hardcore is roaching)
    if not ns.config.Get("hardcore") then return end

    if not unit or not ns.roster.IsUnitInGroup(unit) then return end
    if not UnitExists(unit) then return end
    if not (UnitIsDeadOrGhost(unit) or UnitHealth(unit) <= 0) then
        return
    end

    local unit_name = UnitName(unit)
    if ns.hardcore.IsInDeathLog(unit_name) then
        return
    end

    ns.hardcore.AddToDeathLog(unit_name)

    if ns.config.Get("debugMode") then
        ns.config.DebugPrint(unit_name .. " has died (UNIT_HEALTH_FREQUENT)")
    end
end

-- Paired with onUnitHealthFrequent to catch all deaths
local function onCombatLogEventUnfiltered()
    -- Disable death detection handlers if not in a Hardcore realm
    -- (leaving group when dead in non-hardcore is roaching)
    if not ns.config.Get("hardcore") then return end

    local _, sub_event, _, _, _, _, _, dest_guid, dest_name, _, _, _ = CombatLogGetCurrentEventInfo()

    if not sub_event == "UNIT_DIED" then
        return
    end

    -- check if destGUID corresponds to a raid member
    if not ns.roster.IsGUIDInGroup(dest_guid) then
        return
    end

    ns.hardcore.AddToDeathLog(dest_name)

    if ns.config.Get("debugMode") then
        ns.config.DebugPrint(dest_name .. " has died (COMBAT_LOG_EVENT_UNFILTERED)")
    end
end

-- Main event handler - routes events to specific handlers
function M.OnEvent(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        onCombatLogEventUnfiltered()
    elseif event == "UNIT_HEALTH_FREQUENT" then
        onUnitHealthFrequent(...)
    elseif event == "UNIT_SPELLCAST_START" then
        onUnitSpellcastStart(...)
    elseif event == "CHAT_MSG_SYSTEM" then
        onMsgSystem(event, ...)
    end
    -- Add more event routing as needed
end

M.ready = true
ns.events = M
