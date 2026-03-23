--[[------------------------------------------------------------------------------------------------
Title:          Settings
Author:         Static_Recharge
Description:    Creates and controls the settings menu and related saved variables.
------------------------------------------------------------------------------------------------]]--


--[[------------------------------------------------------------------------------------------------
Libraries and Aliases
------------------------------------------------------------------------------------------------]]--
local LAM2 = LibAddonMenu2
local CM = CALLBACK_MANAGER
local WM = WINDOW_MANAGER
local EM = EVENT_MANAGER


--[[------------------------------------------------------------------------------------------------
Settings Class Initialization
Settings    													            - Parent object containing all functions, tables, variables, constants and other data managers.
├─ :IsInitialized()                               - Returns true if the object has been successfully initialized.
├─ :CreateSettingsPanel()													- Creates and registers the settings panel with LibAddonMenu.
├─ :Update()                											- Updates the settings panel in LibAddonMenu.
├─ :Changed()               							- Fired when the player first loads in after a settings reset is forced.
└─ :GetParent()                                   - Returns the parent object of this object for reference to parent variables.
------------------------------------------------------------------------------------------------]]--
local Settings = {}


--[[------------------------------------------------------------------------------------------------
Settings:Initialize(Parent)
Inputs:				Parent 															- The parent object containing other required information.  
Outputs:			None
Description:	Initializes all of the variables and tables.
------------------------------------------------------------------------------------------------]]--
function Settings:Initialize(Parent)
  self.Parent = Parent
  self.eventSpace = "GoHomeSettings"
	self.hotkeyIndex = 1

  self:CreateSettingsPanel()

  -- Event Registrations
	EM:RegisterForEvent(self.eventSpace, EVENT_PLAYER_ACTIVATED, function(...) self:Changed() end)

	self.initialized = true
end


--[[------------------------------------------------------------------------------------------------
Settings:IsInitialized()
Inputs:				None
Outputs:			initialized                         - bool for object initialized state
Description:	Returns true if the object has been successfully initialized.
------------------------------------------------------------------------------------------------]]--
function Settings:IsInitialized()
  return self.initialized
end


--[[------------------------------------------------------------------------------------------------
Settings:CreateSettingsPanel()
Inputs:				None  
Outputs:			None
Description:	Creates and registers the settings panel with LibAddonMenu.
------------------------------------------------------------------------------------------------]]--
function Settings:CreateSettingsPanel()
	local Parent = self:GetParent()
  local AW = Parent.SV.AW
  local CH = Parent.SV.CH
  local AWDef = Parent.Defaults.AW
  local CHDef = Parent.Defaults.CH
	local panelData = {
		type = "panel",
		name = "Go Home",
		displayName = "|cFFFFFFF49B42Go Home|r",
		author = Parent.author,
		website = "https://www.esoui.com/downloads/info1604-GoHome.html",
		feedback = "https://www.esoui.com/portal.php?&uid=6533",
		slashCommand = "/ghmenu",
		registerForRefresh = true,
		registerForDefaults = true,
		version = Parent.addonVersion,
	}

  local optionsData = {}
	local controls = {}
	local i = 0

	i = i + 1
	optionsData[i] = {
		type = "header",
		name = "Primary House",
	}

	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = "Set Primary House",
		choices = Parent.Houses:GetOwnedHouseNames(),
		choicesValues = Parent.Houses:GetOwnedHouseIds(),
		sort = "name-up",
		getFunc = function() return GetHousingPrimaryHouse() end,
		setFunc = function(var) SetHousingPrimaryHouse(var) end,
		width = "full",
		scrollable = true,
		tooltip = "Changing this setting will change your primary house without having to travel to it first.",
		reference = "GH_PrimaryHouseDropdown_LAM",
	}

	i = i + 1
	optionsData[i] = {
		type = "header",
		name = "Key Bindings",
	}

	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = "Hotkey",
		choices = Parent.Hotkeys,
		getFunc = function() return self.hotkeyIndex end,
		setFunc = function(var) self.hotkeyIndex = var end,
		width = "half",
		scrollable = true,
		tooltip = "Select which hotkey to edit.",
	}

	i = i + 1
	optionsData[i] = {
		type = "editbox",
		name = "Alias",
		getFunc = function() return AW[self.hotkeyIndex].alias end,
		setFunc = function(var) Parent:UpdateAlias(self.hotkeyIndex, var) end,
		width = "half",
		tooltip = "Assign a short alias to a hotkey. When filled in it will create a new slash command, \"/alias\". Do not include the /.",
		default = AWDef[self.hotkeyIndex].alias,
	}

	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = "House Type",
		choices = Parent.HotkeyTypes:GetChoices(),
		choicesValues = Parent.HotkeyTypes:GetValues(),
		getFunc = function() return AW[self.hotkeyIndex].hotkeyType end,
		setFunc = function(var) AW[self.hotkeyIndex].hotkeyType = var end,
		width = "half",
		scrollable = true,
		tooltip = "Primary = your primary house\nSpecific = a specific house of yours\nCharacter = Character specific house\nAccount Name = travel to an account name\nGuild = Guild Leader's primary house",
		default = AWDef[self.hotkeyIndex].hotkeyType,
	}

	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = "Specific House",
		choices = Parent.Houses:GetOwnedHouseNames(),
		choicesValues = Parent.Houses:GetOwnedHouseIds(),
		sort = "name-up",
		getFunc = function() return AW[self.hotkeyIndex].specificHouse end,
		setFunc = function(var) AW[self.hotkeyIndex].specificHouse = var end,
		width = "half",
		scrollable = true,
		disabled = function() return AW[self.hotkeyIndex].hotkeyType ~= Parent.HotkeyTypes["Specific"] end,
		reference = "GH_SpecificHouseDropdown_LAM",
		default = AWDef[self.hotkeyIndex].specificHouse,
	}

	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = "Character House",
		choices = Parent.Houses:GetOwnedHouseNames(),
		choicesValues = Parent.Houses:GetOwnedHouseIds(),
		sort = "name-up",
		getFunc = function() return CH[self.hotkeyIndex].houseID end,
		setFunc = function(var) CH[self.hotkeyIndex].houseID = var end,
		width = "half",
		scrollable = true,
		disabled = function() return AW[self.hotkeyIndex].hotkeyType ~= Parent.HotkeyTypes["Character"] end,
		tooltip = "This setting is character specific.",
		reference = "GH_CharacterHouseDropdown_LAM",
		default = CHDef[self.hotkeyIndex].houseID,
	}

	i = i + 1
	optionsData[i] = {
		type = "editbox",
		name = "Account Name",
		getFunc = function() return AW[self.hotkeyIndex].accountName end,
		setFunc = function(var) AW[self.hotkeyIndex].accountName = var end,
		width = "half",
		disabled = function() return AW[self.hotkeyIndex].hotkeyType ~= Parent.HotkeyTypes["Account Name"] end,
		tooltip = "Must start with @.",
		default = AWDef[self.hotkeyIndex].accountName,
	}

	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = "Account House",
		choices = Parent.Houses:GetAllHouseNames(),
		choicesValues = Parent.Houses:GetAllHouseIds(),
		sort = "name-up",
		scrollable = true,
		getFunc = function() return AW[self.hotkeyIndex].accountNameSpecificHouse end,
		setFunc = function(var) AW[self.hotkeyIndex].accountNameSpecificHouse = var end,
		width = "half",
		scrollable = true,
		disabled = function() return AW[self.hotkeyIndex].hotkeyType ~= Parent.HotkeyTypes["Account Name"] or AW[self.hotkeyIndex].accountNamePrimaryHouse end,
		tooltip = "If you want to travel to someone's house that is not their primary, select it from the list. The addon can't tell which houses they own, so all are listed.",
		reference = "GH_AccountHouseDropdown_LAM",
		default = AWDef[self.hotkeyIndex].accountNameSpecificHouse,
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
		name = "Account Primary House",
		getFunc = function() return AW[self.hotkeyIndex].accountNamePrimaryHouse end,
		setFunc = function(var) AW[self.hotkeyIndex].accountNamePrimaryHouse = var end,
		width = "half",
		disabled = function() return AW[self.hotkeyIndex].hotkeyType ~= Parent.HotkeyTypes["Account Name"] end,
		tooltip = "Will override the \"Account House\" option and take you to their primary house instead.",
		reference = "GH_AccountPrimaryHouseCheckBox_LAM",
		default = AWDef[self.hotkeyIndex].accountNamePrimaryHouse,
	}

	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = "Guild House",
		choices = Parent.Guilds:GetChoices(),
		choicesValues = Parent.Guilds:GetValues(),
		getFunc = function() return AW[self.hotkeyIndex].guildID end,
		setFunc = function(var) AW[self.hotkeyIndex].guildID = var end,
		width = "half",
		scrollable = true,
		disabled = function() return AW[self.hotkeyIndex].hotkeyType ~= Parent.HotkeyTypes["Guild"] end,
		tooltip = "Will teleport you to the Guild Leader's primary house. If the guild house is someone's other than the Guild Leader's then use the \"Account Name\" option instead.",
		reference = "GH_GuildHouseDropdown_LAM",
		default = AWDef[self.hotkeyIndex].guildID,
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
		name = "Outside",
		getFunc = function() if AW[self.hotkeyIndex].hotkeyType == Parent.HotkeyTypes["Primary"] or AW[self.hotkeyIndex].hotkeyType == Parent.HotkeyTypes["Specific"] then return AW[self.hotkeyIndex].outside else return CH[self.hotkeyIndex].outside end end,
		setFunc = function(var) if AW[self.hotkeyIndex].hotkeyType == Parent.HotkeyTypes["Primary"] or AW[self.hotkeyIndex].hotkeyType == Parent.HotkeyTypes["Specific"] then AW[self.hotkeyIndex].outside = var else CH[self.hotkeyIndex].outside = var end end,
		width = "half",
		disabled = function() return AW[self.hotkeyIndex].hotkeyType ~= Parent.HotkeyTypes["Primary"] and AW[self.hotkeyIndex].hotkeyType ~= Parent.HotkeyTypes["Specific"] and AW[self.hotkeyIndex].hotkeyType ~= Parent.HotkeyTypes["Character"] end,
		tooltip = "Select to travel to the outside of the house.",
		default = AWDef[self.hotkeyIndex].outside,
	}

	i = i + 1
	optionsData[i] = {
		type = "button",
    name = "Clear Key Binding",
    func = function() AW[self.hotkeyIndex] = AWDef[self.hotkeyIndex] CH[self.hotkeyIndex] = CHDef[self.hotkeyIndex] end,
    width = "half",
	}

  i = i + 1
  optionsData[i] = {
		type = "header",
		name = "Misc.",
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
		name = "Use House Nicknames",
		getFunc = function() return AW.useNicknames end,
		setFunc = function(var) AW.useNicknames = var self:Update() end,
		width = "half",
		default = AWDef.useNicknames,
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "Chat Messages",
    getFunc = function() return AW.chatEnabled end,
    setFunc = function(value) AW.chatEnabled = value Parent.Chat:SetChatEnabled(value) end,
    tooltip = "Disables ALL chat messages from this add-on.",
    width = "half",
		default = AWDef.chatEnabled,
	}

	i = i + 1
	optionsData[i] = {
		type = "checkbox",
    name = "Debugging Mode",
    getFunc = function() return AW.debugEnabled end,
    setFunc = function(value) AW.debugEnabled = value Parent.Chat:SetDebugEnabled(value) end,
    tooltip = "Turns on extra messages for the purposes of debugging. Not intended for normal use. Must have chat messages enabled.",
    width = "half",
		default = AWDef.debugEnabled,
		disabled = not AWDef.chatEnabled,
	}

	local function LAMPanelCreated(panel)
		if panel ~= Parent.LAMSettingsPanel then return end
		Parent.LAMReady = true
		self.Controls = {
			Primary = WM:GetControlByName("GH_PrimaryHouseDropdown_LAM"),
			Specific = WM:GetControlByName("GH_SpecificHouseDropdown_LAM"),
			Character = WM:GetControlByName("GH_CharacterHouseDropdown_LAM"),
			Account = WM:GetControlByName("GH_AccountHouseDropdown_LAM"),
			Guild = WM:GetControlByName("GH_GuildHouseDropdown_LAM"),
		}
	end

	local function LAMPanelOpened(panel)
		if panel ~= Parent.LAMSettingsPanel then return end
		self:Update()
	end

	Parent.LAMSettingsPanel = LAM2:RegisterAddonPanel(Parent.addonName .. "_LAM", panelData)
	CM:RegisterCallback("LAM-PanelControlsCreated", LAMPanelCreated)
	CM:RegisterCallback("LAM-PanelOpened", LAMPanelOpened)
	LAM2:RegisterOptionControls(Parent.addonName .. "_LAM", optionsData)
end


--[[------------------------------------------------------------------------------------------------
Settings:Update()
Inputs:				None
Outputs:			None
Description:	Updates the settings panel in LibAddonMenu.
------------------------------------------------------------------------------------------------]]--
function Settings:Update()
	local Parent = self:GetParent()
	if not Parent.LAMReady then return end

	local h = Parent.Houses
	local g = Parent.Guilds
	local c = self.Controls

	--Update House Data
	h:Update()

	-- Update owned house dropdowns
	c.Primary:UpdateChoices(h:GetOwnedHouseNames(), h:GetOwnedHouseIds())
	c.Primary:UpdateValue()
	c.Specific:UpdateChoices(h:GetOwnedHouseNames(), h:GetOwnedHouseIds())
	c.Specific:UpdateValue()
	c.Character:UpdateChoices(h:GetOwnedHouseNames(), h:GetOwnedHouseIds())
	c.Character:UpdateValue()

	-- Update all house dropdowns
	c.Account:UpdateChoices(h:GetAllHouseNames(), h:GetAllHouseIds())
	c.Account:UpdateValue()

	-- Update guild dropdowns
	Parent:UpdateGuildList()
	c.Guild:UpdateChoices(g:GetChoices(), g:GetValues())
	c.Guild:UpdateValue()
end


--[[------------------------------------------------------------------------------------------------
Settings:Changed()
Inputs:				None
Outputs:			None
Description:	Sends a message the the settings have been reset.
------------------------------------------------------------------------------------------------]]--
function Settings:Changed()
	local Parent = self:GetParent()
	if not Parent.SV.settingsChanged then return end
	Parent.SV.settingsChanged = false
	Parent.Chat:Msg("Settings have been reset, please ensure they are to your preference.")
  EM:UnregisterForEvent(self.eventSpace, EVENT_PLAYER_ACTIVATED)
end


--[[------------------------------------------------------------------------------------------------
Settings:GetParent()
Inputs:				None
Outputs:			Parent          										- The parent object of this object.
Description:	Returns the parent object of this object for reference to parent variables.
------------------------------------------------------------------------------------------------]]--
function Settings:GetParent()
  return self.Parent
end

--[[------------------------------------------------------------------------------------------------
Global template assignment
------------------------------------------------------------------------------------------------]]--
GoHome.Settings = Settings