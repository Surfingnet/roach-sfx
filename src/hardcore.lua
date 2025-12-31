-- src/hardcore.lua
local addonName, ns = ...
ns = ns or {}
ns.hardcore = ns.hardcore or {}
local M = ns.hardcore

---Returns true if the current realm is a Hardcore season realm.
function M.IsHardcoreRealm()
---@diagnostic disable-next-line: undefined-global
    if not C_Seasons or not C_Seasons.GetActiveSeason then -- WoW API global
        return false
    end
---@diagnostic disable-next-line: undefined-global
    return C_Seasons.GetActiveSeason() == Enum.Season.Hardcore -- WoW API global
end

ns.hardcore = M