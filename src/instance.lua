-- src/instance.lua
local addonName, ns = ...
ns = ns or {}
ns.instance = ns.instance or {}
local M = ns.instance

---Returns true if the player is in a PvE instance (dungeon or raid), otherwise false.
---@return boolean
function M.IsPlayerInPvEInstance()
  local inInstance, instanceType = IsInInstance()
  if not inInstance then
    return false
  end
  return instanceType == "party" or instanceType == "raid"
end

ns.instance = M
