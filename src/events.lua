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

-- Main event handler - routes events to specific handlers
function M.OnEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        M.OnPlayerEnteringWorld()
    elseif event == "GROUP_ROSTER_UPDATE" then
        M.OnGroupRosterUpdate()
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" then
        M.OnUnitSpellcastChannelStart(...)
    -- Add more event routing as needed
    end
end

-- Specific event handlers
function M.OnPlayerEnteringWorld()
    -- Handle player entering world
    ns.roster.InitializeRoster()
end

function M.OnGroupRosterUpdate()
    -- Handle roster changes
    local leftMembers = ns.roster.UpdateRoster()
    -- Check if we should work outside instances
    if not ns.instance.IsPlayerInPvEInstance() and not ns.config.Get("enableOutsideInstances") then
        return
    end
    -- Process left members if needed
    if #leftMembers > 0 then
        -- Debug: print all leavers regardless of combat
        if ns.config.Get("debugMode") then
            for _, name in ipairs(leftMembers) do
                ns.config.DebugPrint(name .. " left the group")
            end
        end
        
        if ns.combat.IsAnyGroupMemberInCombat() then
            local roacherName = leftMembers[1]
            HandleRoaching(roacherName)
        end
    end
end

---@diagnostic disable-next-line: unused-local
function M.OnUnitSpellcastChannelStart(unit, spellName, _spellRank)
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

    HandleRoaching(casterName)
end

ns.events = M