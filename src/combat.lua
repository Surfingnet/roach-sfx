-- src/combat.lua
local addonName, ns = ...
ns = ns or {}
ns.combat = ns.combat or {}
local M = ns.combat

---Returns true if at least one group member (or the player) is in combat.
---@return boolean
function M.IsAnyGroupMemberInCombat()
  -- Check if any group member is in combat
  if UnitAffectingCombat("player") then
    return true
  end

  local groupSize = GetNumGroupMembers() or 0
  if groupSize == 0 then
    return false
  end

  if IsInRaid() then
    -- raid1..raidN, including all members (the player may be at any index)
    for i = 1, groupSize do
      local unit = "raid" .. i
      if UnitExists(unit) and UnitIsConnected(unit) then
        if UnitAffectingCombat(unit) then
          return true
        end
      end
    end
  else
    -- party tokens only represent other members (player is not partyN)
    local partyCount = groupSize - 1
    for i = 1, partyCount do
      local unit = "party" .. i
      if UnitExists(unit) and UnitIsConnected(unit) then
        if UnitAffectingCombat(unit) then
          return true
        end
      end
    end
  end

  return false
end

ns.combat = M