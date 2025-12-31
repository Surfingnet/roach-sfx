-- src/config.lua
local addonName, ns = ...
ns = ns or {}
ns.config = ns.config or {}
local M = ns.config

-- Default settings
local defaults = {
    soundChannel = "SFX",          -- Sound channel: "Master", "SFX", "Music", "Ambience", "Dialog"
    cooldownTime = 5,              -- Minimum time between sounds (seconds)
    enableOutsideInstances = false, -- Whether to work outside PvE instances
    showRaidWarnings = true,       -- Whether to show raid warning messages
    enableSounds = true,           -- Whether to play roach sounds
    allowPlayer = false,           -- Whether to notify when player themselves roaches
    stripServer = true,            -- Whether to strip server name from displayed names
    debugMode = false              -- Enable debug logging
}

-- Initialize config
function M.Initialize()
    RoachSFXDB = RoachSFXDB or {}
    for k, v in pairs(defaults) do
        if RoachSFXDB[k] == nil then
            RoachSFXDB[k] = v
        end
    end
end

-- Get setting value
function M.Get(key)
    return RoachSFXDB[key]
end

-- Debug print function
function M.DebugPrint(message)
    if M.Get("debugMode") then
        print("RoachSFX Debug: " .. message)
    end
end

-- Create the options panel
local function CreateOptionsPanel()
    local panel = CreateFrame("Frame", "RoachSFXOptions", UIParent)
    panel.name = "Roach SFX"

    -- Title
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Roach SFX Settings")

    -- Checkbox for outside instances setting
    local outsideCheck = CreateFrame("CheckButton", "RoachSFXOutsideCheck", panel, "InterfaceOptionsCheckButtonTemplate")
    outsideCheck:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)
    outsideCheck.Text:SetText("Enable outside PvE instances (dungeons/raids)")
    outsideCheck:SetChecked(RoachSFXDB.enableOutsideInstances)
    outsideCheck:SetScript("OnClick", function(self)
        RoachSFXDB.enableOutsideInstances = self:GetChecked()
    end)

    -- Sound channel dropdown
    local soundChannelLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    soundChannelLabel:SetPoint("TOPLEFT", outsideCheck, "BOTTOMLEFT", 0, -16)
    soundChannelLabel:SetText("Sound Channel:")

    local soundChannelDropDown = CreateFrame("Frame", "RoachSFXSoundChannelDropDown", panel, "UIDropDownMenuTemplate")
    soundChannelDropDown:SetPoint("TOPLEFT", soundChannelLabel, "BOTTOMLEFT", -16, -8)

    local soundChannels = {"Master", "SFX", "Music", "Ambience", "Dialog"}

    UIDropDownMenu_Initialize(soundChannelDropDown, function(frame, level, menuList)
        for _, channel in ipairs(soundChannels) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = channel
            info.value = channel
            info.checked = (RoachSFXDB.soundChannel == channel)
            info.func = function(self)
                RoachSFXDB.soundChannel = self.value
                UIDropDownMenu_SetSelectedValue(soundChannelDropDown, self.value)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    UIDropDownMenu_SetSelectedValue(soundChannelDropDown, RoachSFXDB.soundChannel)
    UIDropDownMenu_SetWidth(soundChannelDropDown, 120)

    -- Sound cooldown slider
    local cooldownLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    cooldownLabel:SetPoint("TOPLEFT", soundChannelLabel, "BOTTOMLEFT", 0, -40)
    cooldownLabel:SetText("Sound Cooldown (seconds):")

    local cooldownSlider = CreateFrame("Slider", "RoachSFXCooldownSlider", panel, "OptionsSliderTemplate")
    cooldownSlider:SetPoint("TOPLEFT", cooldownLabel, "BOTTOMLEFT", 0, -8)
    cooldownSlider:SetMinMaxValues(1, 5)
    cooldownSlider:SetValueStep(1)
    cooldownSlider:SetObeyStepOnDrag(true)
    cooldownSlider:SetValue(RoachSFXDB.cooldownTime)
    cooldownSlider.Low:SetText("1")
    cooldownSlider.High:SetText("5")
    cooldownSlider.Text:SetText(RoachSFXDB.cooldownTime)
    cooldownSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)  -- Round to nearest integer
        RoachSFXDB.cooldownTime = value
        self.Text:SetText(value)
    end)

    -- Checkbox for raid warnings setting
    local raidWarningCheck = CreateFrame("CheckButton", "RoachSFXRaidWarningCheck", panel, "InterfaceOptionsCheckButtonTemplate")
    raidWarningCheck:SetPoint("TOPLEFT", cooldownSlider, "BOTTOMLEFT", -10, -16)
    raidWarningCheck.Text:SetText("Show raid warning messages")
    raidWarningCheck:SetChecked(RoachSFXDB.showRaidWarnings)
    raidWarningCheck:SetScript("OnClick", function(self)
        RoachSFXDB.showRaidWarnings = self:GetChecked()
    end)

    -- Checkbox for sounds setting
    local soundCheck = CreateFrame("CheckButton", "RoachSFXSoundCheck", panel, "InterfaceOptionsCheckButtonTemplate")
    soundCheck:SetPoint("TOPLEFT", raidWarningCheck, "BOTTOMLEFT", 0, -8)
    soundCheck.Text:SetText("Play roach sounds")
    soundCheck:SetChecked(RoachSFXDB.enableSounds)
    soundCheck:SetScript("OnClick", function(self)
        RoachSFXDB.enableSounds = self:GetChecked()
    end)

    -- Checkbox for player notification setting
    local playerCheck = CreateFrame("CheckButton", "RoachSFXPlayerCheck", panel, "InterfaceOptionsCheckButtonTemplate")
    playerCheck:SetPoint("TOPLEFT", soundCheck, "BOTTOMLEFT", 0, -8)
    playerCheck.Text:SetText("Be notified of your own cowardice")
    playerCheck:SetChecked(RoachSFXDB.allowPlayer)
    playerCheck:SetScript("OnClick", function(self)
        RoachSFXDB.allowPlayer = self:GetChecked()
    end)

    -- Checkbox for server stripping setting
    local serverCheck = CreateFrame("CheckButton", "RoachSFXServerCheck", panel, "InterfaceOptionsCheckButtonTemplate")
    serverCheck:SetPoint("TOPLEFT", playerCheck, "BOTTOMLEFT", 0, -8)
    serverCheck.Text:SetText("Strip server name from displayed names")
    serverCheck:SetChecked(RoachSFXDB.stripServer)
    serverCheck:SetScript("OnClick", function(self)
        RoachSFXDB.stripServer = self:GetChecked()
    end)

    -- Checkbox for debug mode setting
    local debugCheck = CreateFrame("CheckButton", "RoachSFXDebugCheck", panel, "InterfaceOptionsCheckButtonTemplate")
    debugCheck:SetPoint("TOPLEFT", serverCheck, "BOTTOMLEFT", 0, -8)
    debugCheck.Text:SetText("Enable debug mode")
    debugCheck:SetChecked(RoachSFXDB.debugMode)
    debugCheck:SetScript("OnClick", function(self)
        RoachSFXDB.debugMode = self:GetChecked()
    end)

    -- Refresh function for when panel is shown
    panel.refresh = function()
        outsideCheck:SetChecked(RoachSFXDB.enableOutsideInstances)
        UIDropDownMenu_SetSelectedValue(soundChannelDropDown, RoachSFXDB.soundChannel)
        cooldownSlider:SetValue(RoachSFXDB.cooldownTime)
        cooldownSlider.Text:SetText(RoachSFXDB.cooldownTime)
        raidWarningCheck:SetChecked(RoachSFXDB.showRaidWarnings)
        soundCheck:SetChecked(RoachSFXDB.enableSounds)
        playerCheck:SetChecked(RoachSFXDB.allowPlayer)
        serverCheck:SetChecked(RoachSFXDB.stripServer)
        debugCheck:SetChecked(RoachSFXDB.debugMode)
    end

    return panel
end

-- Register the options panel
function M.RegisterOptions()
    local panel = CreateOptionsPanel()
---@diagnostic disable-next-line: undefined-global
    InterfaceOptions_AddCategory(panel) -- WoW API function
end

ns.config = M