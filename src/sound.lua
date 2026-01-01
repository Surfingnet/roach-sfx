-- src/sound.lua
local addonName, ns = ...
ns = ns or {}
ns.sound = ns.sound or {}
local M = ns.sound

-- List of available sound files (add new .ogg files here)
local soundFiles = {
    "do_you_see_my_mana.ogg",
    "what_am_i_supposed_to_do.ogg",
    "why_am_i_walking.ogg",
    "now_we_are_gonna_wait.ogg",
    "i_worked_at_blizzard_1.ogg",
    -- Add more sound files as needed
}

local soundFilesCt = #soundFiles

-- Cooldown tracking
local lastPlayed = 0

-- Play a random roach sound
function M.PlayRandomRoachSound()
    if soundFilesCt == 0 then return end

    -- Check if sounds are enabled
    if not ns.config.Get("enableSounds") then return end

    -- Check cooldown to prevent spam
    local currentTime = GetTime()
    local cooldown = ns.config.Get("cooldownTime") or 3
    if currentTime - lastPlayed < cooldown then
        return -- Still on cooldown
    end

    local randomIndex = fastrandom(soundFilesCt)
    local soundFile = soundFiles[randomIndex]
    local soundPath = "Interface\\AddOns\\roach-sfx\\sounds\\" .. soundFile

    -- Get sound channel from config
    local channel = ns.config.Get("soundChannel") or "SFX"

    -- Play the sound
    PlaySoundFile(soundPath, channel)

    -- Update last played time
    lastPlayed = currentTime
end

ns.sound = M
