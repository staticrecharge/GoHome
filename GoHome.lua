--[[------------------------------------------------------------------------------------------------
Title:					GoHome
Author:					Static_Recharge
Version:				9.0.0
Description:		Creates hotkeys for you to set to various houses.

LS                                                - Object containing all functions, tables, variables, constants and other data managers.
├─ :IsInitialized()                               - Returns true if the object has been successfully initialized.
├─ 
├─ 
├─ 
├─ 
└─ :Test(...)                                     - For internal add-on testing only.
------------------------------------------------------------------------------------------------]]--


--[[------------------------------------------------------------------------------------------------
Libraries and Aliases
------------------------------------------------------------------------------------------------]]--
local EM = EVENT_MANAGER


--[[------------------------------------------------------------------------------------------------
Globals
------------------------------------------------------------------------------------------------]]--



--[[------------------------------------------------------------------------------------------------
GoHome Class Initialization
GoHome                                                - Parent object containing all functions, tables, variables, constants and other data managers.
------------------------------------------------------------------------------------------------]]--
GoHome = {}


--[[------------------------------------------------------------------------------------------------
GoHome:Initialize()
Inputs:				None
Outputs:			None
Description:	Initializes all of the variables, object managers, slash commands and main event
							callbacks.
------------------------------------------------------------------------------------------------]]--
function GoHome:Initialize()
	-- Static definitions
	self.addonName = "GoHome"
	self.addonVersion = "9.0.0"
	self.author = "|cFF0000Static_Recharge|r"
  self.chatPrefixColor = "F49B42"
	self.chatTextColor = "FFFFFF"
  self.varsVersion = 2

	-- Set defaults, looping through default keybind and character 10x
  self.Defaults = {
		chatEnabled = true,
    debugEnabled = false,
		useNicknames = false,
	}

	for i = 1, 10 do
		self.Defaults[i] = {
			hotkeyType = nil,
			accountName = nil,
			guild = nil,
			specificHouse = nil,
			accountNamePrimaryHouse = true,
			accountNameSpecificHouse = nil,
			guildID = nil,
			outside = false,
		}
	end

	for i = 1, 10 do
  self.CharDefaults[i] = {houseID = nil, outside = false}
	end

	-- Session Variables

	-- Saved Variables Initialization

	-- Library Initializations
	local Options = {
		addonIdentifier = "GH",
		prefixColor = self.chatPrefixColor,
		textColor = self.chatTextColor,
		chatEnabled = self.SV.chatEnabled,
		debugEnabled = self.SV.debugEnabled,
	}
	self.Chat = LibStatic.CHAT:New(Options)

	-- Child Initialization
	self.Settings = self.SETTINGS:New()
	self.Houses = self.HOUSES:New()
	--self.Permissions = self.PERMISSIONS:New()


	-- Event Registrations


  -- Slash Commands
  --SLASH_COMMANDS["/ghtest"] = function(...) self:Test(...) end

  self.initialized = true
end


--[[------------------------------------------------------------------------------------------------
GoHome:IsInitialized()
Inputs:				None
Outputs:			initialized                         - bool for object initialized state
Description:	Returns true if the object has been successfully initialized.
------------------------------------------------------------------------------------------------]]--
function GoHome:IsInitialized()
  return self.initialized
end


--[[------------------------------------------------------------------------------------------------
Main add-on event registration. Creates the global object, LibStatic, of the LS class.
------------------------------------------------------------------------------------------------]]--
EM:RegisterForEvent("GoHome", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
	if addonName ~= "GoHome" then return end
	EM:UnregisterForEvent("GoHome", EVENT_ADD_ON_LOADED)
	GoHome = GoHome:Initialize()
end)