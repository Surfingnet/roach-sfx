-- src/events.lua
local addonName, ns = ...
ns = ns or {}
ns.events = ns.events or {}
local M = ns.events

-- Local helper function to handle roaching for a specific player
local function handle_roaching(name)
    ns.config.debug_print(name .. " is roaching out!")
    -- Check if the roacher has roached recently
    if ns.history.is_in_history(name) then
        return
    end
    -- Record this roach event in history
    ns.history.add_to_history(name)
    -- Play a random roach sound
    ns.sound.play_random_roach_sound()
    -- Display raid warning locally with the roacher's name
    ns.message.show_roach_warning(name)
end

---returns true if checks relevant to all events are passed
---@return boolean
local function common_checks()
    -- Check if we should work outside instances
    if not ns.instance.is_player_in_pve_instance() and not ns.config.get("enableOutsideInstances") then
        ns.config.debug_print("not in an instance")
        return false
    end

    -- Check if someone is in combat
    if not ns.combat.is_group_in_combat() then
        ns.config.debug_print("combat not detected")
        return false
    else
        ns.config.debug_print("combat detected")
    end

    return true
end

---@diagnostic disable-next-line: unused-local
local function on_unit_spellcast_start(unit_target, _, spell_id)
    ns.config.debug_print(unit_target .. " " .. tostring(spell_id))

    -- Handle teleportation spells cast by group members as potential roaching
    -- if mob then ignore
    if not UnitIsPlayer(unit_target) then return end

    -- if not in group then ignore
    if not ns.roster.is_unit_in_group(unit_target) then
        -- unless it is the player and allowPlayer is true
        if not (unit_target == "player" and ns.config.get("allowPlayer")) then
            return
        end
    end

    -- Check if it's a teleportation spell
    if not ns.spells.is_teleportation_spell(spell_id) then
        return
    end

    if not common_checks() then return end

    local caster_name = UnitName(unit_target) -- target of tp spell is the caster of it
    handle_roaching(caster_name)
end

local function on_msg_system(event, msg, ...)
    local leaver_name = ns.chat_parser.detect_leaver(event, msg, ...)
    if not leaver_name then
        local self_or_disband = ns.chat_parser.detect_self_or_disband(event, msg, ...)

        if self_or_disband == "disband" then
            ns.config.debug_print("Group disbanded")
            if not common_checks() then return end
            -- TODO: get the real leader name and remember it
            handle_roaching("the leader")
            ns.history.clear_history()
            if ns.config.get("hardcore") then
                ns.hardcore.clear_death_log()
            end
        elseif self_or_disband == "self" then
            ns.config.debug_print("You left the group")
            if not common_checks() then return end
            handle_roaching(UnitName("player"))
            ns.history.clear_history()
            if ns.config.get("hardcore") then
                ns.hardcore.clear_death_log()
            end
        end

        return
    end

    -- Debug: print all leavers regardless of combat
    ns.config.debug_print(leaver_name .. " left the group")
    if not common_checks() then return end
    if ns.config.get("hardcore") and ns.hardcore.is_in_death_log(leaver_name) then
        ns.config.debug_print("he's dead anyway")
        return
    end

    handle_roaching(leaver_name)
end

-- Handler for UNIT_HEALTH_FREQUENT to detect deaths in Hardcore realms
local function on_unit_health_frequent(unit)
    -- Disable death detection handlers if not in a Hardcore realm
    -- (leaving group when dead in non-hardcore is roaching)
    if not ns.config.get("hardcore") then return end

    if not unit or not ns.roster.is_unit_in_group(unit) then return end
    if not UnitExists(unit) then return end
    if not (UnitIsDeadOrGhost(unit) or UnitHealth(unit) <= 0) then
        return
    end

    local unit_name = UnitName(unit)
    if ns.hardcore.is_in_death_log(unit_name) then
        return
    end

    ns.hardcore.add_to_death_log(unit_name)

    if ns.config.get("debugMode") then
        ns.config.debug_print(unit_name .. " has died (UNIT_HEALTH_FREQUENT)")
    end
end

-- Paired with onUnitHealthFrequent to catch all deaths
local function on_combat_log_event_unfiltered()
    -- Disable death detection handlers if not in a Hardcore realm
    -- (leaving group when dead in non-hardcore is roaching)
    if not ns.config.get("hardcore") then return end

    local _, sub_event, _, _, _, _, _, dest_guid, dest_name, _, _, _ = CombatLogGetCurrentEventInfo()

    if not sub_event == "UNIT_DIED" then
        return
    end

    -- check if destGUID corresponds to a raid member
    if not ns.roster.is_guid_in_group(dest_guid) then
        return
    end

    ns.hardcore.add_to_death_log(dest_name)

    if ns.config.get("debugMode") then
        ns.config.debug_print(dest_name .. " has died (COMBAT_LOG_EVENT_UNFILTERED)")
    end
end

-- Main event handler - routes events to specific handlers
function M.on_event(event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        on_combat_log_event_unfiltered()
    elseif event == "UNIT_HEALTH_FREQUENT" then
        on_unit_health_frequent(...)
    elseif event == "UNIT_SPELLCAST_START" then
        on_unit_spellcast_start(...)
    elseif event == "CHAT_MSG_SYSTEM" then
        on_msg_system(event, ...)
    end
    -- Add more event routing as needed
end

M.ready = true
ns.events = M
