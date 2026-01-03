-- src/core.lua
local addonName, ns = ...
ns = ns or {}

local function main()
    if not (ns.config and ns.config.ready) then
        C_Timer.After(1, main)
        return
    end

    if not (ns.events and ns.events.ready) then
        C_Timer.After(1, main)
        return
    end

    -- Create the main addon frame for event handling
    ns.frame = CreateFrame("Frame", addonName .. "Frame")

    -- Set the OnEvent script to the handler in events.lua
    ns.frame:SetScript("OnEvent", function(self, event, ...)
        ns.events.OnEvent(event, ...)
    end)

    -- Register events (add more as needed)
    --ns.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    --ns.frame:RegisterEvent("GROUP_ROSTER_UPDATE")
    --ns.frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")-- TODO: check if really needed
    ns.frame:RegisterEvent("UNIT_SPELLCAST_START")
    ns.frame:RegisterEvent("CHAT_MSG_SYSTEM")
    ns.frame:RegisterEvent("UNIT_HEALTH_FREQUENT")
    ns.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    -- Add other events as needed

    ns.config.DebugPrint("RoachSFX loaded. Hooray!")
end

main()
