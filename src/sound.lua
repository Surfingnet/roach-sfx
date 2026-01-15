-- src/sound.lua
local addonName, ns = ...
ns = ns or {}
ns.sound = ns.sound or {}
local M = ns.sound

local channels = {
    "Master",
    "SFX",
    "Music",
    "Ambience",
    "Dialog"
}

-- List of available sound files (add new .ogg files here)
local SOUND_FILES = {
    "do_you_see_my_mana.ogg",
    "what_am_i_supposed_to_do.ogg",
    "why_am_i_walking.ogg",
    "now_we_are_gonna_wait.ogg",
    "i_worked_at_blizzard_1.ogg",
    "tuco_get_out.ogg",
    "discord_leave.ogg",
    "sinistar_run_coward.ogg",
    "terminator_2_hasta_la_vista_baby.ogg",
    "danger.ogg",
    "i_leave_you_guys.ogg",
    "trump_bye_bye.ogg",
    -- Add more sound files as needed
}

local SOUND_FILES_CT = #SOUND_FILES

-- To avoid repeating
local last_played_index = 0

-- Cooldown tracking
local last_played_time = 0

-- Play a random roach sound
function M.play_random_roach_sound()
    if SOUND_FILES_CT == 0 then return end

    -- Check if sounds are enabled
    if not ns.config.get("enableSounds") then return end

    -- Check cooldown to prevent spam
    local current_time = GetTime()
    local cooldown = ns.config.get("cooldownTime") or 2
    if current_time - last_played_time < cooldown then
        return -- Still on cooldown
    end

    local random_index = fastrandom(SOUND_FILES_CT)

    while (random_index == last_played_index) do
        random_index = fastrandom(SOUND_FILES_CT)
    end

    local sound_file = SOUND_FILES[random_index]
    local sound_path = "Interface\\AddOns\\roach-sfx\\sounds\\" .. sound_file

    -- Get sound channel from config
    local channel = channels[ns.config.get("soundChannel")]

    -- Play the sound
    PlaySoundFile(sound_path, channel)

    -- Update last played time
    last_played_time = current_time

    -- Update last played index
    last_played_index = random_index
end

function M.play_funny_sound_in()
    local sound_file = "TADA.ogg"
    local sound_path = "Interface\\AddOns\\roach-sfx\\sounds\\" .. sound_file
    PlaySoundFile(sound_path, "Master")
end

function M.play_funny_sound_out()
    local sound_file = "sad_crowd_aww.ogg"
    local sound_path = "Interface\\AddOns\\roach-sfx\\sounds\\" .. sound_file
    PlaySoundFile(sound_path, "Master")
end

-- Absolute requirement
local function one_in_a_million()
    local chance = fastrandom(1000000)
    if chance == 69420 then
        local sound_file = "not_rick_roll_trust_me.ogg"
        local sound_path = "Interface\\AddOns\\roach-sfx\\sounds\\" .. sound_file
        PlaySoundFile(sound_path, "Master")
    end
end

one_in_a_million() -- Never delete this line, very important

ns.sound = M
