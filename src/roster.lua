-- src/roster.lua
local addonName, ns = ...
ns = ns or {}
ns.roster = ns.roster or {}
local M = ns.roster

---Check if a unit is currently in the group (party/raid)
---@param unit string The unit ID to check
---@return boolean
function M.IsUnitInGroup(unit)
  if not unit then return false end

  if IsInRaid() then
    return unit:find("raid") ~= nil  -- Raid units: raid1, raid2, etc.
  else
    return unit:find("party") ~= nil or unit == "player"  -- Party units: party1, party2, or player
  end
end

ns.roster = M
