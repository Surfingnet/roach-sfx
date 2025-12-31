-- src/core.lua
local addonName, ns = ...
ns = ns or {}

-- Create the main addon frame for event handling
ns.frame = CreateFrame("Frame", addonName.."Frame")

-- Set the OnEvent script to the handler in events.lua
ns.frame:SetScript("OnEvent", function(self, event, ...)
    ns.events.OnEvent(event, ...)
end)

-- Register events (add more as needed)
ns.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
ns.frame:RegisterEvent("GROUP_ROSTER_UPDATE")
ns.frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
--ns.frame:RegisterEvent("UNIT_HEALTH_FREQUENT")
--ns.frame:RegisterEvent("UNIT_DIED")
-- Add other events as needed

-- Initialize other modules
ns.roster.InitializeRoster()
ns.config.Initialize()
ns.config.RegisterOptions()