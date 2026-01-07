-- src/instance.lua
local addonName, ns = ...
ns = ns or {}
ns.instance = ns.instance or {}
local M = ns.instance

---Returns true if the player is in a PvE instance (dungeon or raid), otherwise false.
---@return boolean
function M.is_player_in_pve_instance()
  local in_instance, instance_type = IsInInstance()
  if not in_instance then
    return false
  end
  return instance_type == "party" or instance_type == "raid"
end

ns.instance = M
