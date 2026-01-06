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
    return unit:find("raid") ~= nil                      -- Raid units: raid1, raid2, etc.
  else
    return unit:find("party") ~= nil or unit == "player" -- Party units: party1, party2, or player
  end
end

function M.IsGUIDInGroup(guid)
  local group_size = GetNumGroupMembers() or 0
  if group_size == 0 then
    return false
  end

  if IsInRaid() then
    -- raid1..raidN, including all members (the player may be at any index)
    for i = 1, group_size do
      local unit = "raid" .. i
      if UnitExists(unit) and UnitGUID(unit) == guid then
        return true
      end
    end
  else
    -- party tokens only represent other members (player is not partyN)
    local party_count = group_size - 1
    for i = 1, party_count do
      local unit = "party" .. i
      if UnitExists(unit) and UnitGUID(unit) == guid then
        return true
      end
    end
  end

  return false
end

ns.roster = M
