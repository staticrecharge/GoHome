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
local LCM = LibCustomMenu


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
  self.awVarsVersion = 2
	self.chVarsVarsion = 2
	self.maxHotkeys = 10
	self.Hotkeys = {}
	for i=1, self.maxHotkeys do
		table.insert(self.Hotkeys, i)
	end
	self.HotkeyTypes = LibStatic:PairedListNew(
		{"Primary", "Specific", "Character", "Account Name", "Guild"},
		nil
		-- {Translations}
	)
	self.PermAccessLevel = LibStatic:PairedListNew(
		{"No Access", "Visitor", "Limited Visitor", "Decorator"},
		{HOUSE_PERMISSION_PRESET_SETTING_INVALID, HOUSE_PERMISSION_PRESET_SETTING_VISITOR, HOUSE_PERMISSION_PRESET_SETTING_LIMITED_VISITOR, HOUSE_PERMISSION_PRESET_SETTING_DECORATOR}
		-- {Translations}
	)

	-- Set defaults, looping through default keybind and character 10x
  self.Defaults = {
		-- Account Wide
		AW = {
			chatEnabled = true,
			debugEnabled = false,
			useNicknames = false,
		},

		--Character
		CH = {},
	}

	for i = 1, self.maxHotkeys do
		self.Defaults.AW[i] = {
			hotkeyType = nil,
			accountName = "@",
			guild = nil,
			specificHouse = nil,
			accountNamePrimaryHouse = true,
			accountNameSpecificHouse = nil,
			guildID = nil,
			outside = false,
			alias = nil,
		}

		self.Defaults.CH[i] = {
			houseID = nil,
			outside = false,
		}
	end

	-- Session Variables
	self:UpdateGuildList()

	-- Saved Variables
	self.SV = {
		AW = ZO_SavedVars:NewAccountWide("GoHomeAccountWideVars", self.awVarsVersion, nil, self.Defaults.AW, GetWorldName()),
		CH = ZO_SavedVars:NewCharacterIdSettings("GoHomeCharacterVars", self.chVarsVarsion, nil, self.Defaults.CH, GetWorldName())
	}

	-- Libraries
	local Options = {
		addonIdentifier = "GoHome",
		addonShortName = "GH",
		prefixColor = self.chatPrefixColor,
		textColor = self.chatTextColor,
		chatEnabled = self.SV.chatEnabled,
		debugEnabled = self.SV.debugEnabled,
	}
	self.Chat = LibStatic.CHAT:New(Options)

	self:ContextMenu()

	-- Modules
	self.Houses:Initialize(self)
	--self.Permissions:Initialize(self)
	self.Settings:Initialize(self)

	-- Events and Hooks

	-- Hotkeys
	for i = 1, self.maxHotkeys do
		ZO_CreateStringId(zo_strformat("SI_BINDING_NAME_GH_HOTKEY_<<1>>", i), zo_strformat("House <<1>>", i))
	end

  -- Slash Commands
	SLASH_COMMANDS["/gohome"] = function(args) self:CommandParse(args) end
	SLASH_COMMANDS["/gh"] = function(args) self:CommandParse(args) end
	SLASH_COMMANDS["/ghcurrent"] = function(...) self.Houses:PrintCurrentHouseData() end
	SLASH_COMMANDS["/ghlist"] = function(...) self:ListHotkeyedHouses() end
	--SLASH_COMMANDS["/ghperm"] = function(...) self:PermissionsEditMenuHide() end
  SLASH_COMMANDS["/ghtest"] = function(...) self:Test(...) end
	for i = 1 , self.maxHotkeys do
		local alias = self.SV.AW[i].alias
		if alias and alias ~= "" then
			self:UpdateAlias(i, alias)
		end
	end

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
GoHome:UpdateGuildList()
Inputs:			  None
Outputs:			None
Description:	Updates the internal guild paired list.
------------------------------------------------------------------------------------------------]]--
function GoHome:UpdateGuildList()
	local guildIds = {}
	local guildNames = {}
	for i=1, GetNumGuilds() do
		local id = GetGuildId(i)
		table.insert(guildNames, GetGuildName(id))
		table.insert(guildIds, id)
	end

	if not self.Guilds then
		self.Guilds = LibStatic:PairedListNew(guildNames, guildIds)
	else
		self.Guilds:UpdateData(guildNames, guildIds)
	end
end


--[[------------------------------------------------------------------------------------------------
GoHome:GetGuildLeader(guildId)
Inputs:			  guildId 														- (number) Guild Id to get the leader of
Outputs:			leaderName 													- (string) The name of the guild leader
Description:	Returns the name of the specified guild leader.
------------------------------------------------------------------------------------------------]]--
function GoHome:GetGuildLeader(guildId)
	local _, _, leaderName = GetGuildInfo(guildId)
	return leaderName
end


--[[------------------------------------------------------------------------------------------------
GoHome:ListHotkeyedHouses()
Inputs:			  None
Outputs:			None
Description:	Prints the list of hotkeys and related houses.
------------------------------------------------------------------------------------------------]]--
function GoHome:ListHotkeyedHouses()
	local list = {"Saved Hotkeys"}
	for i = 1, self.maxHotkeys do
		local name
		local outside
		if self.SV.AW[i].hotkeyType ~= nil then
			if self.SV.AW[i].hotkeyType == self.HotkeyTypes["Primary"] then
				name = self:GetPreferredName(GetHousingPrimaryHouse()) outside = self.SV.AW[i].outside
			elseif self.SV.AW[i].hotkeyType == self.HotkeyTypes["Specific"] then
				name = self.Houses:GetPreferredName(self.SV.AW[i].specificHouse) outside = self.SV.AW[i].outside
			elseif self.SV.AW[i].hotkeyType == self.HotkeyTypes["Character"] then
				name = self.Houses:GetPreferredName(self.SV.CH[i].houseID) outside = self.SV.CH[i].outside
			elseif self.SV.AW[i].hotkeyType == self.HotkeyTypes["Account Name"] then
				if self.SV.AW[i].accountNamePrimaryHouse then
					name = zo_strformat("<<1>> - Primary", self.SV.AW[i].accountName)
				else
					name = zo_strformat("<<1>> - <<2>>", self.SV.AW[i].accountName, self.Houses:GetName(self.SV.AW[i].accountNameSpecificHouse))
				end
			elseif self.SV.AW[i].hotkeyType == self.HotkeyTypes["Guild"] then
				name = zo_strformat("<<1>> - Guild House", self.Guilds:GetChoiceByValue(self.SV.AW[i].guildID))
			end
			if outside == nil then
				table.insert(list, zo_strformat("[<<1>>]: <<2>>", i, name))
			else
				table.insert(list, zo_strformat("[<<1>>]: <<2>> (<<3>>)", i, name, (outside and "outside") or "inside"))
			end
		end
	end
	self.Chat:Msg(list)
end


--[[------------------------------------------------------------------------------------------------
GoHome:HotkeyPressed(keyNum)
Inputs:			  keyNum 															- Hotkey index number pressed
Outputs:			None
Description:	Sets up the travel function based on the hotkey pressed.
------------------------------------------------------------------------------------------------]]--
function GoHome:HotkeyPressed(keyNum)
	if not self:AbleToFastTravel() then return end

	-- Outside or Inside text message
	local outside
	local outsideText
	if self.SV.AW[keyNum].hotkeyType == self.HotkeyTypes["Primary"] or self.SV.AW[keyNum].hotkeyType == self.HotkeyTypes["Specific"] then
		outside = self.SV.AW[keyNum].outside
		if outside then
			outsideText = "outside"
		else
			outsideText = "inside"
		end
	else
		outside = self.SV.CH[keyNum].outside
		if outside then
			outsideText = "outside"
		else
			outsideText = "inside"
		end
	end

	local hotkeyType = self.SV.AW[keyNum].hotkeyType

	-- Travel to player's primary house
	if hotkeyType == self.HotkeyTypes["Primary"] then
		local primary = GetHousingPrimaryHouse()
		self:Travel()
		self.Chat:Msg(zo_strformat("Traveling to your primary house, <<1>> (<<2>>).", self.Houses:GetPreferredName(primary), outsideText))

	-- Travel to player's specific house
	elseif hotkeyType == self.HotkeyTypes["Specific"] then
		local specificHouse = self.SV.AW[keyNum].specificHouse
		self:Travel(specificHouse, outside)
		self.Chat:Msg(zo_strformat("Traveling to your <<1>> (<<2>>).", self.Houses:GetPreferredName(specificHouse), outsideText))

	-- Travel to character house
	elseif hotkeyType == self.HotkeyTypes["Character"] then
		local character = self.SV.CH[keyNum].houseID
		self:Travel(character, outside)
		self.Chat:Msg(zo_strformat("Traveling to your <<1>> (<<2>>).", self.Houses:GetPreferredName(character), outsideText))

	-- Travel to account name house
	elseif hotkeyType == self.HotkeyTypes["Account Name"] then
		-- Account name primary house
		local accountName = self.SV.AW[keyNum].accountName
		if self.SV.AW[keyNum].accountNamePrimaryHouse then
			self:Travel(accountName)
			self.Chat:Msg(zo_strformat("Traveling to <<1>>'s primary house.", accountName))
		-- Account name specific house
		else
			local specificHouse = self.SV.AW[keyNum].accountNameSpecificHouse
			self:Travel(accountName, specificHouse)
			self.Chat:Msg(zo_strformat("Traveling to <<1>>'s <<2>>.", accountName, self.Houses:GetName(specificHouse)))
		end

	-- Travel to guild house
	elseif hotkeyType == self.HotkeyTypes["Guild"] then
		local guildId = self.SV.AW[keyNum].guildID
		local guildName = self.Guilds:GetChoiceByValue(guildId)
		local leader = self:GetGuildLeader(guildId)
		-- if the player is the leader then it teleports them to their primary house
		if leader == GetDisplayName() then
			local primary = GetHousingPrimaryHouse()
			self:Travel()
			self.Chat:Msg(zo_strformat("Traveling to your primary house, <<1>>.", self.Houses:GetPreferredName(primary)))
		-- otherwise teleport to the guild leader's primary house
		else
			self:Travel(leader)
			self.Chat:Msg(zo_strformat("Traveling to <<1>>'s guild house.", guildName))
		end
	end
end


--[[------------------------------------------------------------------------------------------------
GoHome:AbleToFastTravel()
Inputs:			  None
Outputs:			canTravel 													- (bool) True if the player is able to fast travel to a house
Description:	Returns true if the player is able to fast travel to a house.
------------------------------------------------------------------------------------------------]]--
function GoHome:AbleToFastTravel()
	local canTravel = false
	if IsPlayerInAvAWorld() then
		self.Chat:Msg("Can't travel while in AvA/PvP zone.")
	elseif IsPlayerMoving() then 
		self.Chat:Msg("Can't travel while moving.")
	elseif IsUnitInCombat("player") then
		self.Chat:Msg("Can't travel while in combat.")
	elseif IsActiveWorldBattleground() then
		self.Chat:Msg("Can't travel while in Battleground zone.")
	else
		canTravel = true
	end
	return canTravel
end


--[[------------------------------------------------------------------------------------------------
GoHome:Travel(...)
Inputs:			  Overloaded function:								- No arguments = Travel to the player's primary house.
																									- @name only = Travel to specified player's primary house.
																									- HouseId, outside = Travel to the player's specified house (inside or outside).
																									- @name and houseId = Travel to the specified house of the specified player.
Outputs:			None
Description:	Handles traveling to various houses.
------------------------------------------------------------------------------------------------]]--
function GoHome:Travel(...)
	Args = {...}
	if #Args == 1 then
		JumpToHouse(Args[1])
	elseif type(Args[1]) == "number" then
		RequestJumpToHouse(Args[1], Args[2])
	elseif type(Args[1]) == "string" then
		JumpToSpecificHouse(Args[1], Args[2])
	else
		JumpToHouse(GetDisplayName())
	end
end


--[[------------------------------------------------------------------------------------------------
GoHome:ContextMenu()
Inputs:				None
Outputs:			None
Description:	Adds the context menu entry.
------------------------------------------------------------------------------------------------]]--
function GoHome:ContextMenu()
	local function GoChatContext(playerName)
		self.Chat:Msg("Traveling to <<1>>'s primary house.", playerName)
		self:Travel(playerName)
	end

	local ZO_ShowPlayerContextMenu = SharedChatSystem.ShowPlayerContextMenu
	function SharedChatSystem.ShowPlayerContextMenu(...)
		local ZO_ClearMenu = ClearMenu
		local ZO_ShowMenu = ShowMenu

		if not ZO_Dialogs_IsShowingDialog() then
			local chat, playerName, rawName = ...
			function ClearMenu(...)
				ClearMenu = ZO_ClearMenu
				ClearMenu(...)
			end
			function ShowMenu(...)
				ShowMenu = ZO_ShowMenu
				AddCustomMenuItem("Travel to Primary House", function(...) GoChatContext(playerName) end)
				return ShowMenu(...)
			end
		end
		return ZO_ShowPlayerContextMenu(...)
	end
end


--[[------------------------------------------------------------------------------------------------
GoHome:UpdateAlias(hotkeyIndex, alias)
Inputs:			  hotkeyIndex 												- hotkey index selected
							newAlias 														- new alias to assign
Outputs:			None
Description:	Removes old alias and assigns a new one if applicable.
------------------------------------------------------------------------------------------------]]--
function GoHome:UpdateAlias(hotkeyIndex, newAlias)
	local oldAlias = self.SV.AW[hotkeyIndex].alias

	-- clear old alias if any
	if oldAlias and oldAlias ~= "" then
		SLASH_COMMANDS[zo_strformat("/<<1>>", oldAlias)] = nil
	end

	-- assign new alias if any
	if newAlias and newAlias ~= "" then
		SLASH_COMMANDS[zo_strformat("/<<1>>", newAlias)] = function() self:HotkeyPressed(hotkeyIndex) end
		self.SV.AW[hotkeyIndex].alias = newAlias
	end
end


--[[------------------------------------------------------------------------------------------------
GoHome:CommandParse(args)
Inputs:			  args 																- table of input arguments
Outputs:			None
Description:	Parses the incoming command.
------------------------------------------------------------------------------------------------]]--
function GoHome:CommandParse(args)
	local Options = {}
	local searchResult = {string.match(args, "^(%S*)%s*(.-)$")}
	for i,v in pairs(searchResult) do
		if (v ~= nil and v~= "") then
			Options[i] = string.lower(v)
		end
	end
	if #Options == 0 then
		local primary = GetHousingPrimaryHouse()
		if self:AbleToFastTravel() then
			self:Travel()
			self.Chat:Msg(zo_strformat("Traveling to your primary house, <<1>>.", self.Houses:GetPreferredName(primary)))
		end
	else
		local option = Options[1]
		-- check for existing alias
		local aliasIndex = self:GetHotkeyIndexByAlias(option)
		--d(aliasIndex)
		if aliasIndex then
			option = aliasIndex
		end
		option = tonumber(option)
		if option then
			if option >= 1 and option <= self.maxHotkeys then
				self:HotkeyPressed(option)
			else
				self.Chat:Msg(zo_strformat("Hotkey \"<<1>>\" out of range.", option))
			end
		else
			self.Chat:Msg("Hotkey or alias not found.")
		end
	end
end


--[[------------------------------------------------------------------------------------------------
GoHome:GetHotkeyIndexByAlias(alias)
Inputs:				alias 															- hotkey alias to look up
Outputs:			index                            		- the hotkey index of the aliased house
Description:	Returns the hotkey index of the aliased house.
------------------------------------------------------------------------------------------------]]--
function GoHome:GetHotkeyIndexByAlias(alias)
	return LibStatic:ReverseTableLookup(self.SV.AW, alias, "alias", 1, self.maxHotkeys)
end


--[[------------------------------------------------------------------------------------------------
GoHome:Test(...)
Inputs:				...
Outputs:			...
Description:	Test function.
------------------------------------------------------------------------------------------------]]--
function GoHome:Test(...)
	self.Chat:Msg("Test")
end


--[[------------------------------------------------------------------------------------------------
Main add-on event registration. Creates the global object, LibStatic, of the LS class.
------------------------------------------------------------------------------------------------]]--
EM:RegisterForEvent("GoHome", EVENT_ADD_ON_LOADED, function(eventCode, addonName)
	if addonName ~= "GoHome" then return end
	EM:UnregisterForEvent("GoHome", EVENT_ADD_ON_LOADED)
	GoHome:Initialize()
end)