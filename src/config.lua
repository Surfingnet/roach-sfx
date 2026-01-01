-- src/config.lua
local addonName, ns = ...
ns = ns or {}
ns.config = ns.config or {}
local M = ns.config

-- Debug print function
function M.DebugPrint(message)
    if M.Get("debugMode") then
        print("RoachSFX Debug: " .. message)
    end
end

-- Saved variables table
RoachSFXDB = RoachSFXDB or {}

-- Get setting value from SavedVariables (kept for other modules)
function M.Get(key)
    return RoachSFXDB[key]
end

-- Setup default values if not already present
local defaults = {
    soundChannel = 1, -- 1=Master, 2=SFX, 3=Music, 4=Ambience, 5=Dialog
    cooldownTime = 5, -- Default cooldown between sounds (seconds)
    enableOutsideInstances = false,
    showRaidWarnings = true,
    enableSounds = true,
    allowPlayer = true,
    stripServer = true,
    hardcore = false,
    debugMode = true,
}

for key, default in pairs(defaults) do
    if RoachSFXDB[key] == nil then
        RoachSFXDB[key] = default
    end
end

-- Callback when a setting value is changed
local function OnSettingChanged(_, setting, value)
    -- setting:GetVariable() returns the variableKey passed when registering the setting
    local variable = setting:GetVariable()
    RoachSFXDB[variable] = value
    if RoachSFXDB.debugMode then
        M.DebugPrint(variable .. " changed to " .. tostring(value))
    end
end

-- Create the main settings category (vertical layout)
---@diagnostic disable-next-line: undefined-global
local category = Settings.RegisterVerticalLayoutCategory("Roach SFX Settings")

-- Helper: register a simple addon-backed setting (saves directly into RoachSFXDB)
-- Note: RegisterAddOnSetting signature requires variableKey and variableTbl (the SavedVariables table)
local function RegisterSimpleSetting(category, variableKey, displayName, valueType, defaultValue)
    local setting = Settings.RegisterAddOnSetting(
        category,    -- category
        variableKey, -- variable (unique setting id)
        variableKey, -- variableKey (key inside variableTbl)
        RoachSFXDB,  -- variableTbl (SavedVariables table)
        valueType,   -- type (e.g. "boolean", "number", etc.)
        displayName, -- name shown in UI
        defaultValue -- default value
    )
    setting:SetValueChangedCallback(OnSettingChanged)
    return setting
end

-- Sound Channel (Dropdown)
do
    local variable = "soundChannel"
    local name = "Sound Channel"
    local tooltip = "Select which sound channel to use."
    local defaultValue = RoachSFXDB.soundChannel

    local function GetChannelOptions()
        -- Settings.CreateControlTextContainer is used to provide dropdown entries.
        local container = Settings.CreateControlTextContainer()
        container:Add(1, "Master")
        container:Add(2, "SFX")
        container:Add(3, "Music")
        container:Add(4, "Ambience")
        container:Add(5, "Dialog")
        return container:GetData()
    end

    local setting = RegisterSimpleSetting(category, variable, name, type(defaultValue), defaultValue)

    -- IMPORTANT: correct function name is CreateDropdown (not CreateDropDown).
    -- This creates a dropdown control bound to the registered setting.
    Settings.CreateDropdown(category, setting, GetChannelOptions, tooltip)
end

-- Cooldown Time (Slider)
do
    local variable = "cooldownTime"
    local name = "Cooldown Time"
    local tooltip = "Set the cooldown time (in seconds) between sounds."
    local defaultValue = RoachSFXDB.cooldownTime

    local setting = RegisterSimpleSetting(category, variable, name, type(defaultValue), defaultValue)

    -- Slider options: min, max, step
    local options = Settings.CreateSliderOptions(1, 5, 1)
    -- Use the built-in label formatter for the steppers (keeps UI consistent)
    ---@diagnostic disable-next-line: undefined-global
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right)
    Settings.CreateSlider(category, setting, options, tooltip)
end

-- Enable Outside Instances (Checkbox)
do
    local variable = "enableOutsideInstances"
    local name = "Enable Outside Instances"
    local tooltip = "Allow effects outside of dungeons and raids."
    local defaultValue = RoachSFXDB.enableOutsideInstances

    local setting = RegisterSimpleSetting(category, variable, name, type(defaultValue), defaultValue)
    Settings.CreateCheckbox(category, setting, tooltip)
end

-- Show Raid Warnings (Checkbox)
do
    local variable = "showRaidWarnings"
    local name = "Show the roacher's name"
    local tooltip = "Enable display of raid warning type messages."
    local defaultValue = RoachSFXDB.showRaidWarnings

    local setting = RegisterSimpleSetting(category, variable, name, type(defaultValue), defaultValue)
    Settings.CreateCheckbox(category, setting, tooltip)
end

-- Enable Sounds (Checkbox)
do
    local variable = "enableSounds"
    local name = "Enable Sounds"
    local tooltip = "Toggle all sound effects on or off."
    local defaultValue = RoachSFXDB.enableSounds

    local setting = RegisterSimpleSetting(category, variable, name, type(defaultValue), defaultValue)
    Settings.CreateCheckbox(category, setting, tooltip)
end

-- Allow Player (Checkbox)
do
    local variable = "allowPlayer"
    local name = "Allow Player"
    local tooltip = "Be notified of your own cowardice."
    local defaultValue = RoachSFXDB.allowPlayer

    local setting = RegisterSimpleSetting(category, variable, name, type(defaultValue), defaultValue)
    Settings.CreateCheckbox(category, setting, tooltip)
end

-- Strip Server (Checkbox)
do
    local variable = "stripServer"
    local name = "Strip Server"
    local tooltip = "Strip the server name away from a player's name in messages."
    local defaultValue = RoachSFXDB.stripServer

    local setting = RegisterSimpleSetting(category, variable, name, type(defaultValue), defaultValue)
    Settings.CreateCheckbox(category, setting, tooltip)
end

-- Hardcore Mode (Checkbox)
do
    local variable = "hardcore"
    local name = "Hardcore Realm"
    local tooltip = "Are you in a hardcore realm?"
    local defaultValue = RoachSFXDB.hardcore

    local setting = RegisterSimpleSetting(category, variable, name, type(defaultValue), defaultValue)
    Settings.CreateCheckbox(category, setting, tooltip)
end

-- Debug Mode (Checkbox)
do
    local variable = "debugMode"
    local name = "Debug Mode"
    local tooltip = "Enable debug messages."
    local defaultValue = RoachSFXDB.debugMode

    local setting = RegisterSimpleSetting(category, variable, name, type(defaultValue), defaultValue)
    Settings.CreateCheckbox(category, setting, tooltip)
end

-- Register the settings category so it appears in Interface Options
Settings.RegisterAddOnCategory(category)

M.ready = true
ns.config = M

if M.Get("debugMode") then
    M.DebugPrint("Config module loaded.")
end
