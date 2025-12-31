-- src/roster.lua
local addonName, ns = ...
ns = ns or {}
ns.roster = ns.roster or {}
local M = ns.roster

local prevRoster = {}
local lastGroupType = false  -- false for party, true for raid

-- Build a table { name = {dead = boolean} } of present group members
local function BuildRoster()
  local t = {}
  if IsInRaid() then
    local n = GetNumGroupMembers() or 0
    for i = 1, n do
      local name, _, _, _, _, _, _, _, isDead = GetRaidRosterInfo(i)
      if name then t[name] = {dead = isDead} end
    end
  else
    local pname = UnitName("player")
    if pname then t[pname] = {dead = UnitIsDead("player")} end
    local n = math.max(0, (GetNumGroupMembers() or 0) - 1)
    for i = 1, n do
      local unit = "party"..i
      if UnitExists(unit) then
        local name = UnitName(unit)
        if name then t[name] = {dead = UnitIsDead(unit)} end
      end
    end
  end
  return t
end

---Initialize the roster state (called on load / PLAYER_ENTERING_WORLD).
function M.InitializeRoster()
  prevRoster = BuildRoster()
  lastGroupType = IsInRaid()
end

---Update the roster and return the list of members that left.
---@return string[] leftList
function M.UpdateRoster()
  local newRoster = BuildRoster()
  local currentType = IsInRaid()

  if currentType ~= lastGroupType then
    -- Group type changed, update state but don't report leavers
    lastGroupType = currentType
    prevRoster = newRoster
    return {}
  end

  local left = {}

  for name in pairs(prevRoster) do
    if not newRoster[name] and prevRoster[name] and not prevRoster[name].dead then
      table.insert(left, name)
    end
  end

  -- Update the known state
  prevRoster = newRoster

  return left
end

---Check if a unit is currently in the group/raid.
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
