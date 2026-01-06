-- src/config.lua
local addonName, ns = ...
ns = ns or {}
ns.config = ns.config or {}
local M = ns.config

-- Setup default values if not already present
local DEFAULTS = {
    soundChannel = 1, -- 1=Master, 2=SFX, 3=Music, 4=Ambience, 5=Dialog
    cooldownTime = 2, -- Default cooldown between sounds (seconds)
    enableOutsideInstances = false,
    showRaidWarnings = false,
    enableSounds = true,
    allowPlayer = true,
    stripServer = true,
    hardcore = false,
    debugMode = false,
}

-- Get setting value from SavedVariables (kept for other modules)
function M.Get(key)
    if not RoachSFXDB then
        return DEFAULTS[key]
    end

    return RoachSFXDB[key]
end

-- Debug print function
function M.DebugPrint(message)
    if M.Get("debugMode") then
        print("RoachSFX Debug: " .. message)
    end
end

-- Initialize SavedVariables and apply defaults (call this after login / delay)
local function initializeSavedVars()
    RoachSFXDB = RoachSFXDB or {}
    for k, v in pairs(DEFAULTS) do
        if RoachSFXDB[k] == nil then
            RoachSFXDB[k] = v
        end
    end
end

local function buildSettingsCategory()
    -- Callback when a setting value is changed
    local function onSettingChanged(setting, value)
        -- setting:GetVariable() returns the variable_key passed when registering the setting
        local variable = setting:GetVariable()
        RoachSFXDB[variable] = value
        if RoachSFXDB.debugMode then
            M.DebugPrint(variable .. " changed to " .. tostring(value))
        end
    end

    -- Create the main settings category (vertical layout)
    ---@diagnostic disable-next-line: undefined-global
    local category = Settings.RegisterVerticalLayoutCategory("Roach SFX")

    -- Helper: register a simple addon-backed setting (saves directly into RoachSFXDB)
    -- Note: registerAddOnSetting signature requires variable_key and variableTbl (the SavedVariables table)
    local function registerSimpleSetting(category, variable_key, display_name, value_type, default_value)
        local setting = Settings.RegisterAddOnSetting(
            category,    -- category
            variable_key, -- variable (unique setting id)
            variable_key, -- variable_key (key inside variableTbl)
            RoachSFXDB,  -- variableTbl (SavedVariables table)
            value_type,   -- type (e.g. "boolean", "number", etc.)
            display_name, -- name shown in UI
            default_value -- default value
        )
        setting:SetValueChangedCallback(onSettingChanged)
        return setting
    end

    -- Sound Channel (Dropdown)
    do
        local variable = "soundChannel"
        local name = "Sound Channel"
        local tooltip = "Select which sound channel to use."
        local default_value = RoachSFXDB.soundChannel

        local function getChannelOptions()
            -- Settings.CreateControlTextContainer is used to provide dropdown entries.
            local container = Settings.CreateControlTextContainer()
            container:Add(1, "Master")
            container:Add(2, "SFX")
            container:Add(3, "Music")
            container:Add(4, "Ambience")
            container:Add(5, "Dialog")
            return container:GetData()
        end

        local setting = registerSimpleSetting(category, variable, name, type(default_value), default_value)

        -- IMPORTANT: correct function name is CreateDropdown (not CreateDropDown).
        -- This creates a dropdown control bound to the registered setting.
        Settings.CreateDropdown(category, setting, getChannelOptions, tooltip)
    end

    -- Cooldown Time (Slider)
    do
        local variable = "cooldownTime"
        local name = "Cooldown Time"
        local tooltip = "Set the cooldown time (in seconds) between sounds."
        local default_value = RoachSFXDB.cooldownTime

        local setting = registerSimpleSetting(category, variable, name, type(default_value), default_value)

        -- Slider options: min, max, step
        local options = Settings.CreateSliderOptions(1, 10, 1)
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
        local default_value = RoachSFXDB.enableOutsideInstances

        local setting = registerSimpleSetting(category, variable, name, type(default_value), default_value)
        Settings.CreateCheckbox(category, setting, tooltip)
    end

    -- Show Raid Warnings (Checkbox)
    do
        local variable = "showRaidWarnings"
        local name = "Show the roacher's name"
        local tooltip = "Enable display of raid warning type messages."
        local default_value = RoachSFXDB.showRaidWarnings

        local setting = registerSimpleSetting(category, variable, name, type(default_value), default_value)
        Settings.CreateCheckbox(category, setting, tooltip)
    end

    -- Enable Sounds (Checkbox)
    do
        local variable = "enableSounds"
        local name = "Enable Sounds"
        local tooltip = "Toggle all sound effects on or off."
        local default_value = RoachSFXDB.enableSounds

        local setting = registerSimpleSetting(category, variable, name, type(default_value), default_value)
        Settings.CreateCheckbox(category, setting, tooltip)
    end

    -- Allow Player (Checkbox)
    do
        local variable = "allowPlayer"
        local name = "Allow Player"
        local tooltip = "Be notified of your own cowardice."
        local default_value = RoachSFXDB.allowPlayer

        local setting = registerSimpleSetting(category, variable, name, type(default_value), default_value)
        Settings.CreateCheckbox(category, setting, tooltip)
    end

    -- Strip Server (Checkbox)
    do
        local variable = "stripServer"
        local name = "Strip Server"
        local tooltip = "No server name in messages."
        local default_value = RoachSFXDB.stripServer

        local setting = registerSimpleSetting(category, variable, name, type(default_value), default_value)
        Settings.CreateCheckbox(category, setting, tooltip)
    end

    -- Hardcore Mode (Checkbox)
    do
        local variable = "hardcore"
        local name = "Hardcore Realm"
        local tooltip = "Are you in a hardcore realm?"
        local default_value = RoachSFXDB.hardcore

        local setting = registerSimpleSetting(category, variable, name, type(default_value), default_value)
        Settings.CreateCheckbox(category, setting, tooltip)
    end

    -- Debug Mode (Checkbox)
    do
        local variable = "debugMode"
        local name = "Debug Mode"
        local tooltip = "Spam your chat with useless stuff. Why not?"
        local default_value = RoachSFXDB.debugMode

        local setting = registerSimpleSetting(category, variable, name, type(default_value), default_value)
        Settings.CreateCheckbox(category, setting, tooltip)
    end

    -- Demo trigger using a proxy setting + checkbox (works even if CreateCustomControl is absent)
    do
        local variable = "RoachSFX_DemoTrigger" -- internal id only
        local name = "Demo"
        local tooltip = "Check if it works. (requires sound or message enabled, respects cooldown time)"
        local default_value = false

        -- GetValue always returns false so the control never stores state.
        local function getValue()
            return false
        end

        -- SetValue is called when the user toggles the checkbox.
        -- We run the demo action if present. No persistent storage.
        local function setValue(value)
            if value then
                M.DebugPrint("Demo button clicked. Hooray!")
                ns.message.ShowRoachWarning(UnitName("player"))
                ns.sound.PlayRandomRoachSound()
            end
            -- Do not store anything; GetValue returning false ensures UI resets.
        end

        -- Register a proxy setting (no variableTbl needed)
        local setting = Settings.RegisterProxySetting(category, variable, type(default_value), name, default_value,
            getValue,
            setValue)
        -- Use a checkbox as a momentary 'button'
        Settings.CreateCheckbox(category, setting, tooltip)
    end

    -- Funny button using a proxy setting + checkbox (works even if CreateCustomControl is absent)
    do
        local variable = "RoachSFX_FunnyTrigger" -- internal id only
        local name = "DO NOT CLICK."
        local tooltip = "DANGER!!!!!"
        local default_value = false

        local funny_button_state = false

        -- GetValue always returns false so the control never stores state.
        local function getValue()
            return funny_button_state
        end

        -- SetValue is called when the user toggles the checkbox.
        -- We run the demo action if present. No persistent storage.
        local function setValue(value)
            funny_button_state = value
            if value then
                M.DebugPrint("Funny button clicked. Hooray!")
                ns.sound.PlayFunnySoundIn()
            else
                M.DebugPrint("Funny button unclicked...")
                ns.sound.PlayFunnySoundOut()
            end
            -- Do not store anything; getValue returning false ensures UI resets.
        end

        -- Register a proxy setting (no variableTbl needed)
        local setting = Settings.RegisterProxySetting(category, variable, type(default_value), name, default_value,
            getValue,
            setValue)
        -- Use a checkbox as a momentary 'button'
        Settings.CreateCheckbox(category, setting, tooltip)
    end

    -- Register the settings category so it appears in Interface Options
    Settings.RegisterAddOnCategory(category)

end

local evt = CreateFrame("Frame")
evt:RegisterEvent("PLAYER_LOGIN")
evt:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        initializeSavedVars()
        buildSettingsCategory()
        self:UnregisterEvent("PLAYER_LOGIN")
        M.ready = true
    end
end)

ns.config = M
