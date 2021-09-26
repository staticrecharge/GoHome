--[[----------------------------------------------
Title: Go Home
Author: Static_Recharge
Version: 8.0.0
Description: Creates hotkeys for you to set to various houses.
----------------------------------------------]]--


--[[----------------------------------------------
Addon Information
----------------------------------------------]]--
local GH = {
	addonName = "GoHome",
	addonVersion = "8.0.0",
	author = "|CFF0000Static_Recharge|r",
}


--[[----------------------------------------------
Libraries and Aliases
----------------------------------------------]]--
local LAM2 = LibAddonMenu2
local LCM = LibCustomMenu
local CDM = ZO_COLLECTIBLE_DATA_MANAGER
local CS = CHAT_SYSTEM
local EM = EVENT_MANAGER
local CM = CALLBACK_MANAGER


--[[----------------------------------------------
Constant and Variable Declarations
----------------------------------------------]]--
GH.Const = {
	chatPrefix = "|cf49b42[Go Home]:|r ",
	chatTextColor = "|cffffff",
	chatSuffix = "|r",
	HotkeyType = {GetString(GO_HOME_HotkeyTypePrimary), GetString(GO_HOME_HotkeyTypeSpecific), GetString(GO_HOME_HotkeyTypeCharacter), GetString(GO_HOME_HotkeyTypeAccountName), GetString(GO_HOME_HotkeyTypeGuild),
		primary = GetString(GO_HOME_HotkeyTypePrimary),
		specific = GetString(GO_HOME_HotkeyTypeSpecific),
		character = GetString(GO_HOME_HotkeyTypeCharacter),
		accountName = GetString(GO_HOME_HotkeyTypeAccountName),
		guild = GetString(GO_HOME_HotkeyTypeGuild),
	},
	AccessChoicesList = {[1] = "No Access", [2] = "Visitor", [3] = "Limited Visitor", [4] = "Decorator"},
	AccessValuesList = {HOUSE_PERMISSION_PRESET_SETTING_INVALID, HOUSE_PERMISSION_PRESET_SETTING_VISITOR, HOUSE_PERMISSION_PRESET_SETTING_LIMITED_VISITOR, HOUSE_PERMISSION_PRESET_SETTING_DECORATOR},
}

GH.AccountWide = {
	Defaults = {
		chatMessages = true,
		useNicknames = false,
		[1] = {
			hotkeyType = nil,
			accountName = nil,
			guild = nil,
			specificHouse = nil,
			accountNamePrimaryHouse = true,
			accountNameSpecificHouse = nil,
			guildID = nil,
			outside = false,
		},
		[2] = {
			hotkeyType = nil,
			accountName = nil,
			guild = nil,
			specificHouse = nil,
			accountNamePrimaryHouse = true,
			accountNameSpecificHouse = nil,
			guildID = nil,
			outside = false,
		},
		[3] = {
			hotkeyType = nil,
			accountName = nil,
			guild = nil,
			specificHouse = nil,
			accountNamePrimaryHouse = true,
			accountNameSpecificHouse = nil,
			guildID = nil,
			outside = false,
		},
		[4] = {
			hotkeyType = nil,
			accountName = nil,
			guild = nil,
			specificHouse = nil,
			accountNamePrimaryHouse = true,
			accountNameSpecificHouse = nil,
			guildID = nil,
			outside = false,
		},
		[5] = {
			hotkeyType = nil,
			accountName = nil,
			guild = nil,
			specificHouse = nil,
			accountNamePrimaryHouse = true,
			accountNameSpecificHouse = nil,
			guildID = nil,
			outside = false,
		},
		[6] = {
			hotkeyType = nil,
			accountName = nil,
			guild = nil,
			specificHouse = nil,
			accountNamePrimaryHouse = true,
			accountNameSpecificHouse = nil,
			guildID = nil,
			outside = false,
		},
		[7] = {
			hotkeyType = nil,
			accountName = nil,
			guild = nil,
			specificHouse = nil,
			accountNamePrimaryHouse = true,
			accountNameSpecificHouse = nil,
			guildID = nil,
			outside = false,
		},
		[8] = {
			hotkeyType = nil,
			accountName = nil,
			guild = nil,
			specificHouse = nil,
			accountNamePrimaryHouse = true,
			accountNameSpecificHouse = nil,
			guildID = nil,
			outside = false,
		},
		[9] = {
			hotkeyType = nil,
			accountName = nil,
			guild = nil,
			specificHouse = nil,
			accountNamePrimaryHouse = true,
			accountNameSpecificHouse = nil,
			guildID = nil,
			outside = false,
		},
		[10] = {
			hotkeyType = nil,
			accountName = nil,
			guild = nil,
			specificHouse = nil,
			accountNamePrimaryHouse = true,
			accountNameSpecificHouse = nil,
			guildID = nil,
			outside = false,
		},
	},
	SavedVars = {},
	varsVersion = 2,
}

GH.Character = {
	Defaults = {
		[1] = {houseID = nil, outside = false},
		[2] = {houseID = nil, outside = false},
		[3] = {houseID = nil, outside = false},
		[4] = {houseID = nil, outside = false},
		[5] = {houseID = nil, outside = false},
		[6] = {houseID = nil, outside = false},
		[7] = {houseID = nil, outside = false},
		[8] = {houseID = nil, outside = false},
		[9] = {houseID = nil, outside = false},
		[10] = {houseID = nil, outside = false},
	},
	SavedVars = {},
	varsVersion = 2,
}

GH.HouseData = {}
GH.GuildIndexes = {}
GH.GuildNames = {}
GH.hotkeyIndex = 1
GH.settingsPanelCreated = false


--[[----------------------------------------------
General Functions
----------------------------------------------]]--

--[[ SendToChat(inputString, ...)
Formats chat output with Go Home and color wrappers.
Requires at least one string input, but can take as many extra inputs as needed.
Each new input will be placed on a separate line.
Only the first line will get the Go Home prefix. ]]--
function GH.SendToChat(inputString, ...)
	if not GH.AccountWide.SavedVars.chatMessages or inputString == false then return end
	local Args = {...}
	local Output = {}
	table.insert(Output, GH.Const.chatPrefix)
	table.insert(Output, GH.Const.chatTextColor)
	table.insert(Output, inputString) 
	table.insert(Output, GH.Const.chatSuffix)
	if #Args > 0 then
		for i,v in ipairs(Args) do
		  table.insert(Output, "\n")
			table.insert(Output, GH.Const.chatTextColor)
	    table.insert(Output, v) 
	    table.insert(Output, GH.Const.chatSuffix)
		end
	end
	CS:AddMessage(table.concat(Output))
end

function GH.AbleToFastTravel()
	local canTravel = false
	if not IsInAvAZone() then
		canTravel = true
	end
	return canTravel
end

function GH.UpdateGuildInfo()
	local numGuilds = GetNumGuilds()
	for i = 1, numGuilds do
		GH.GuildIndexes[i] = i
		GH.GuildNames[i] = GetGuildName(GetGuildId(i))
	end
end

function GH.GetGuildLeader(guildID)
	local _, _, leaderName = GetGuildInfo(GetGuildId(guildID))
	return leaderName
end

function GH.Debug()
	local names = GH.GetAllHouseNames()
	d(names)
end

function GH.ListHotkeyedHouses()
	for i=1, 10 do
		if GH.AccountWide.SavedVars[i].hotkeyType ~= nil then
			if GH.AccountWide.SavedVars[i].hotkeyType == GH.Const.HotkeyType.primary then
				GH.SendToChat("[" .. i .. "] - " .. (GH.AccountWide.SavedVars.useNicknames and GH.HouseNickname(GH.GetPrimaryHouse()) or GH.HouseName(GH.GetPrimaryHouse())))
			elseif GH.AccountWide.SavedVars[i].hotkeyType == GH.Const.HotkeyType.specific then
				GH.SendToChat("[" .. i .. "] - " .. (GH.AccountWide.SavedVars.useNicknames and GH.HouseNickname(GH.AccountWide.SavedVars[i].specificHouse) or GH.HouseName(GH.AccountWide.SavedVars[i].specificHouse)))
			elseif GH.AccountWide.SavedVars[i].hotkeyType == GH.Const.HotkeyType.character then
				GH.SendToChat("[" .. i .. "] - " .. (GH.AccountWide.SavedVars[i].useNicknames and GH.HouseNickname(GH.Character.SavedVars[i].houseID) or GH.HouseName(GH.Character.SavedVars[i].houseID)))
			elseif GH.AccountWide.SavedVars[i].hotkeyType == GH.Const.HotkeyType.accountName then
				if GH.AccountWide.SavedVars[i].accountNamePrimaryHouse then
					GH.SendToChat("[" .. i .. "] - " .. GH.AccountWide.SavedVars[i].accountName .. GetString(GO_HOME_TravelToAccountPrimaryEnd))
				else
					GH.SendToChat("[" .. i .. "] - " .. GH.AccountWide.SavedVars[i].accountName .. GetString(GO_HOME_TravelToAccountSpecificEnd) .. GH.HouseName(GH.AccountWide.SavedVars[i].accountNameSpecificHouse))
				end
			elseif GH.AccountWide.SavedVars[i].hotkeyType == GH.Const.HotkeyType.guild then
				GH.SendToChat("[" .. i .. "] - " .. GH.GuildNames[GH.AccountWide.SavedVars[i].guildID] .. GetString(GO_HOME_TravelToGuildEnd))
			end
		end
	end
end

function GH.IsPermIndexSelected()
	if GH.permIndex == nil then return true else return false end
end


--[[----------------------------------------------
Housing Functions
----------------------------------------------]]--

--[[ UpdateHouseData()
Collects all of the housing data from the collections menu. ]]--
function GH.UpdateHouseData()
	for i, categoryData in CDM:CategoryIterator({GH.IsNotHousingCategory}) do
		for _, subCategoryData in categoryData:SubcategoryIterator({GH.IsNotHousingCategory}) do
			for _, subCatCollectibleData in subCategoryData:CollectibleIterator({GH.IsHouse}) do
				if not subCatCollectibleData:IsBlocked() then
					GH.HouseData[subCatCollectibleData:GetReferenceId()] = {
						name = subCatCollectibleData:GetFormattedName(),
						unlocked = subCatCollectibleData:IsUnlocked(),
						nickname = subCatCollectibleData:GetFormattedNickname(),
						collectibleID = subCatCollectibleData:GetId()
					}
				end
			end
		end
	end
	GH.HouseNames = GH.GetNames()
end

function GH.IsHousingCategory(categoryData)
	return categoryData:IsHousingCategory()
end

function GH.IsHouse(collectibleData)
	return collectibleData:IsCategoryType(COLLECTIBLE_CATEGORY_TYPE_HOUSE)
end

function GH.HouseName(houseID)
	return GH.HouseData[houseID].name
end

function GH.HouseNickname(houseID)
	return GH.HouseData[houseID].nickname
end

function GH.HouseIsUnlocked(houseID)
	return GH.HouseData[houseID].unlocked
end

function GH.GetPrimaryHouse()
	return GetHousingPrimaryHouse()
end

function GH.SetPrimaryHouse(houseID)
	return SetHousingPrimaryHouse(houseID)
end

function GH.GetOwnedHouseIDs()
	local Owned = {}
	for i,v in pairs(GH.HouseData) do
		if v.unlocked then
			table.insert(Owned, i)
		end
	end
	return Owned
end

function GH.GetNames()
	local ownedNameList
	if GH.AccountWide.SavedVars.useNicknames then
		ownedNameList = GH.GetOwnedHouseNicknames()
	else
		ownedNameList = GH.GetOwnedHouseNames()
	end
	return ownedNameList
end

function GH.GetOwnedHouseNames()
	local Owned = {}
	for i,v in pairs(GH.HouseData) do
		if v.unlocked then
			table.insert(Owned, v.name)
		end
	end
	return Owned
end

function GH.GetOwnedHouseNicknames()
	local Owned = {}
	for i,v in pairs(GH.HouseData) do
		if v.unlocked then
			table.insert(Owned, v.nickname)
		end
	end
	return Owned
end

function GH.ListOwnedHouses()
	for i,v in pairs(GH.HouseData) do
		if v.unlocked then
			d("ID: " .. i .. ", CollectibleID: " .. v.collectibleID .. ", Name: " .. v.name)
		end
	end
end

function GH.GetAllHouseNames()
	local Houses = {}
	for i,v in pairs(GH.HouseData) do
		table.insert(Houses, v.name)
	end
	return Houses
end

function GH.GetAllHouseNicknames()
	local Houses = {}
	for i,v in pairs(GH.HouseData) do
		table.insert(Houses, v.nickname)
	end
	return Houses
end

function GH.GetAllHouseIDs()
	local Houses = {}
	for i,v in pairs(GH.HouseData) do
		table.insert(Houses, i)
	end
	return Houses
end

function GH.CurrentHouseData()
	local houseID = GetCurrentZoneHouseId()
	local collectibleID = GetCollectibleIdForHouse(houseID)
	local name = GetCollectibleName(collectibleID)
	local nickname = GetCollectibleNickname(collectibleID)

	return houseID, collectibleID, name, nickname
end

--[[ GH.Travel(...)
Handles traveling to various houses.
Overloaded function:
- No arguments = Travel to the player's primary house.
- @name only = Travel to specified player's primary house.
- HouseID only = Travel to the player's specified house.
- @name and houseID = Travel to the specified house of the specified player. ]]--
function GH.Travel(...)
	Args = {...}
	if #Args == 1 then
		JumpToHouse(Args[1])
	elseif type(Args[1]) == "number" then
			RequestJumpToHouse(Args[1], Args[2])
	elseif type(Args[1]) == "string" then
		JumpToSpecificHouse(Args[1], Args[2])
	end
end

function GH.GetCurrentHouseInfo()
	local houseID, collectibleID, name, nickname = GH.CurrentHouseData()

	if houseID == 0 then GH.SendToChat(GetString(GO_HOME_PlayerNotInKnownHouse)) else
		GH.SendToChat(
			GetString(GO_HOME_CurrentHouseDataTitle),
			GetString(GO_HOME_HouseIDLabel) .. houseID,
			GetString(GO_HOME_CollectibleIDLabel) .. collectibleID,
			GetString(GO_HOME_HouseNameLabel) .. name,
			GetString(GO_HOME_HouseNicknameLabel) .. nickname
		)
	end
end

function GH.SetDefaultVisitorAccess(permission, allHouses)
	AddHousingPermission(GH.permIndex, HOUSE_PERMISSION_USER_GROUP_GENERAL, true, permission, allHouses)
end

function GH.GetListPermNames(id, permGroup)
	local num = GetNumHousingPermissions(id, permGroup)
	local Names = {}
	if num > 0 then
		for i=1, num do
			table.insert(Names, GetHousingUserGroupDisplayName(id, permGroup, i))
		end
	end
	return Names
end

function GH.GetListPermIndexes(id, permGroup)
	local num = GetNumHousingPermissions(id, permGroup)
	local Indexes = {}
	if num > 0 then
		for i=1, num do
			table.insert(Indexes, i)
		end
	end
	return Indexes
end


--[[----------------------------------------------
Keybind Functions
----------------------------------------------]]--
function GH_HOTKEY_PRESSED(keyNum)
	-- Outside or Inside text message
	local outside
	if GH.AccountWide.SavedVars[keyNum].hotkeyType == GH.Const.HotkeyType.primary or GH.AccountWide.SavedVars[keyNum].hotkeyType == GH.Const.HotkeyType.specific then
		if GH.AccountWide.SavedVars[keyNum].outside then
			outside = GetString(GO_HOME_TravelOutside)
		else
			outside = GetString(GO_HOME_TravelInside)
		end
	else
		if GH.Character.SavedVars[keyNum].outside then
			outside = GetString(GO_HOME_TravelOutside)
		else
			outside = GetString(GO_HOME_TravelInside)
		end
	end
	-- Travel to player's primary house
	if GH.AccountWide.SavedVars[keyNum].hotkeyType == GH.Const.HotkeyType.primary then
		GH.Travel(GH.GetPrimaryHouse(), GH.AccountWide.SavedVars[keyNum].outside)
		GH.SendToChat(GetString(GO_HOME_TravelToPlayerPrimaryHouse) .. (GH.AccountWide.SavedVars.useNicknames and GH.HouseNickname(GH.GetPrimaryHouse()) or GH.HouseName(GH.GetPrimaryHouse())) .. outside)
	-- Travel to player's specific house
	elseif GH.AccountWide.SavedVars[keyNum].hotkeyType == GH.Const.HotkeyType.specific then
		GH.Travel(GH.AccountWide.SavedVars[keyNum].specificHouse, GH.AccountWide.SavedVars[keyNum].outside)
		GH.SendToChat(GetString(GO_HOME_TravelToTextStart) .. (GH.AccountWide.SavedVars.useNicknames and GH.HouseNickname(GH.AccountWide.SavedVars[keyNum].specificHouse) or GH.HouseName(GH.AccountWide.SavedVars[keyNum].specificHouse)) .. outside)
	-- Travel to character house
	elseif GH.AccountWide.SavedVars[keyNum].hotkeyType == GH.Const.HotkeyType.character then
		GH.Travel(GH.Character.SavedVars[keyNum].houseID, GH.Character.SavedVars[keyNum].outside)
		GH.SendToChat(GetString(GO_HOME_TravelToTextStart) .. (GH.AccountWide.SavedVars.useNicknames and GH.HouseNickname(GH.Character.SavedVars[keyNum].houseID) or GH.HouseName(GH.Character.SavedVars[keyNum].houseID)) .. outside)
	-- Travel to account name house
	elseif GH.AccountWide.SavedVars[keyNum].hotkeyType == GH.Const.HotkeyType.accountName then
		-- Account name primary house
		if GH.AccountWide.SavedVars[keyNum].accountNamePrimaryHouse then
			GH.Travel(GH.AccountWide.SavedVars[keyNum].accountName)
			GH.SendToChat(GetString(GO_HOME_TravelToTextStart) .. GH.AccountWide.SavedVars[keyNum].accountName .. GetString(GO_HOME_TravelToAccountPrimaryEnd))
		-- Account name specific house
		else
			GH.Travel(GH.AccountWide.SavedVars[keyNum].accountName, GH.AccountWide.SavedVars[keyNum].accountNameSpecificHouse)
			GH.SendToChat(GetString(GO_HOME_TravelToTextStart) .. GH.AccountWide.SavedVars[keyNum].accountName .. GetString(GO_HOME_TravelToAccountSpecificEnd) .. GH.HouseName(GH.AccountWide.SavedVars[keyNum].accountNameSpecificHouse))
		end
	-- Travel to guild house
	elseif GH.AccountWide.SavedVars[keyNum].hotkeyType == GH.Const.HotkeyType.guild then
		local leader = GH.GetGuildLeader(GH.AccountWide.SavedVars[keyNum].guildID)
		-- if the player is the leader then it teleports them to their primary house
		if leader == GetDisplayName() then
			GH.Travel(GH.GetPrimaryHouse(), GH.AccountWide.SavedVars[keyNum].outside)
			GH.SendToChat(GetString(GO_HOME_TravelToPlayerPrimaryHouse) .. (GH.AccountWide.SavedVars.useNicknames and GH.HouseNickname(GH.GetPrimaryHouse()) or GH.HouseName(GH.GetPrimaryHouse())))
		-- otherwise teleport to the guild leader's primary house
		else
			GH.Travel(leader)
			GH.SendToChat(GetString(GO_HOME_TravelToTextStart) .. GH.GuildNames[GH.AccountWide.SavedVars[keyNum].guildID] ..GetString(GO_HOME_TravelToGuildEnd))
		end
	end
end


--[[----------------------------------------------
Context Menu Functions
----------------------------------------------]]--
function GH.GoChatContext(playerName)
	GH.SendToChat(GetString(GO_HOME_TravelToTextStart) .. playerName .. GetString(GO_HOME_TravelToAccountPrimaryEnd))
	GH.Travel(playerName)
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
			AddCustomMenuItem(GetString(GO_HOME_ContextTravelToPrimaryLabel), function() GH.GoChatContext(playerName) end)
			return ShowMenu(...)
		end
	end
	return ZO_ShowPlayerContextMenu(...)
end


--[[----------------------------------------------
Settings Menu
----------------------------------------------]]--
function GH.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "Go Home",
		displayName = "|cf49b42Go Home|r",
		author = GH.author,
		website = "https://www.esoui.com/downloads/info1604-GoHome.html",
		feedback = "https://www.esoui.com/portal.php?&uid=6533",
		slashCommand = "/ghmenu",
		registerForRefresh = true,
		registerForDefaults = true,
		version = GH.addonVersion,
	}
	
	local optionsData = {}
	local i = 1
	optionsData[i] = {
		type = "header",
		name = GetString(GO_HOME_SettingsPrimaryHouseLabel),
	}
	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = GetString(GO_HOME_SettingsPrimaryHouseLabel),
		choices = GH.GetNames(),
		choicesValues = GH.GetOwnedHouseIDs(),
		sort = "name-up",
		getFunc = function() return GH.GetPrimaryHouse() end,
		setFunc = function(var) GH.SetPrimaryHouse(var) end,
		width = "full",
		scrollable = true,
		tooltip = GetString(GO_HOME_TooltipSetPrimaryHouse),
		reference = "GH_PrimaryHouseDropdown_LAM",
	}
	i = i + 1
	optionsData[i] = {
		type = "header",
		name = GetString(GO_HOME_SettingsKeybindingsLabel),
	}
	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = "Hotkey",
		choices = {[1] = 1, [2] = 2, [3] = 3, [4] = 4, [5] = 5, [6] = 6, [7] = 7, [8] = 8, [9] = 9, [10] = 10,},
		getFunc = function() return GH.hotkeyIndex end,
		setFunc = function(var) GH.hotkeyIndex = var end,
		width = "half",
		scrollable = true,
		tooltip = "Select which hotkey to edit.",
	}
	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = GetString(GO_HOME_SettingsHouseTypeLabel),
		choices = GH.Const.HotkeyType,
		getFunc = function() return GH.AccountWide.SavedVars[GH.hotkeyIndex].hotkeyType end,
		setFunc = function(var) GH.AccountWide.SavedVars[GH.hotkeyIndex].hotkeyType = var end,
		width = "half",
		scrollable = true,
		tooltip = GetString(GO_HOME_TooltipHouseType),
		reference = "GH_HotkeyTypeDropdown_LAM",
	}
	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = GetString(GO_HOME_SettingsSpecificHouseLabel),
		choices = GH.GetNames(),
		choicesValues = GH.GetOwnedHouseIDs(),
		sort = "name-up",
		getFunc = function() return GH.AccountWide.SavedVars[GH.hotkeyIndex].specificHouse end,
		setFunc = function(var) GH.AccountWide.SavedVars[GH.hotkeyIndex].specificHouse = var end,
		width = "half",
		scrollable = true,
		disabled = function() if GH.AccountWide.SavedVars[GH.hotkeyIndex].hotkeyType == GH.Const.HotkeyType.specific then return false else return true end end,
		tooltip = GetString(GO_HOME_TooltipSpecificHouse),
		reference = "GH_SpecificHouseDropdown_LAM",
	}
	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = GetString(GO_HOME_SettingsCharacterHouseLabel),
		choices = GH.GetNames(),
		choicesValues = GH.GetOwnedHouseIDs(),
		sort = "name-up",
		getFunc = function() return GH.Character.SavedVars[GH.hotkeyIndex].houseID end,
		setFunc = function(var) GH.Character.SavedVars[GH.hotkeyIndex].houseID = var end,
		width = "half",
		scrollable = true,
		disabled = function() if GH.AccountWide.SavedVars[GH.hotkeyIndex].hotkeyType == GH.Const.HotkeyType.character then return false else return true end end,
		tooltip = GetString(GO_HOME_TooltipCharacterHouse),
		reference = "GH_CharacterHouseDropdown_LAM",
	}
	i = i + 1
	optionsData[i] = {
		type = "editbox",
		name = GetString(GO_HOME_SettingsAccountNameLabel),
		getFunc = function() return GH.AccountWide.SavedVars[GH.hotkeyIndex].accountName end,
		setFunc = function(var) GH.AccountWide.SavedVars[GH.hotkeyIndex].accountName = var end,
		width = "half",
		disabled = function() if GH.AccountWide.SavedVars[GH.hotkeyIndex].hotkeyType == GH.Const.HotkeyType.accountName then return false else return true end end,
		tooltip = GetString(GO_HOME_TooltipAccountName),
		reference = "GH_AccountNameEditBox_LAM",
	}
	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = GetString(GO_HOME_SettingsAccountHouseLabel),
		choices = GH.GetAllHouseNames(),
		choicesValues = GH.GetAllHouseIDs(),
		sort = "name-up",
		scrollable = true,
		getFunc = function() return GH.AccountWide.SavedVars[GH.hotkeyIndex].accountNameSpecificHouse end,
		setFunc = function(var) GH.AccountWide.SavedVars[GH.hotkeyIndex].accountNameSpecificHouse = var end,
		width = "half",
		scrollable = true,
		disabled = function() if GH.AccountWide.SavedVars[GH.hotkeyIndex].hotkeyType == GH.Const.HotkeyType.accountName and not GH.AccountWide.SavedVars[GH.hotkeyIndex].accountNamePrimaryHouse then return false else return true end end,
		tooltip = GetString(GO_HOME_TooltipAccountHouse),
		reference = "GH_AccountHouseDropdown_LAM",
	}
	i = i + 1
	optionsData[i] = {
		type = "checkbox",
		name = GetString(GO_HOME_SettingsAccountPrimaryHouseLabel),
		getFunc = function() return GH.AccountWide.SavedVars[GH.hotkeyIndex].accountNamePrimaryHouse end,
		setFunc = function(var) GH.AccountWide.SavedVars[GH.hotkeyIndex].accountNamePrimaryHouse = var end,
		width = "half",
		disabled = function() if GH.AccountWide.SavedVars[GH.hotkeyIndex].hotkeyType == GH.Const.HotkeyType.accountName then return false else return true end end,
		tooltip = GetString(GO_HOME_TooltipAccountPrimaryHouse),
		reference = "GH_AccountPrimaryHouseCheckBox_LAM",
	}
	i = i + 1
	optionsData[i] = {
		type = "dropdown",
		name = GetString(GO_HOME_SettingsGuildHouseLabel),
		choices = GH.GuildNames,
		choicesValues = GH.GuildIndexes,
		getFunc = function() return GH.AccountWide.SavedVars[GH.hotkeyIndex].guildID end,
		setFunc = function(var) GH.AccountWide.SavedVars[GH.hotkeyIndex].guildID = var end,
		width = "half",
		scrollable = true,
		disabled = function() if GH.AccountWide.SavedVars[GH.hotkeyIndex].hotkeyType == GH.Const.HotkeyType.guild then return false else return true end end,
		tooltip = GetString(GO_HOME_TooltipGuildHouse),
		reference = "GH_GuildHouseDropdown_LAM",
	}
	i = i + 1
	optionsData[i] = {
		type = "checkbox",
		name = GetString(GO_HOME_SettingsOutsideLabel),
		getFunc = function() if GH.AccountWide.SavedVars[GH.hotkeyIndex].hotkeyType == GH.Const.HotkeyType.primary or GH.AccountWide.SavedVars[GH.hotkeyIndex].hotkeyType == GH.Const.HotkeyType.specific then return GH.AccountWide.SavedVars[GH.hotkeyIndex].outside else return GH.Character.SavedVars[GH.hotkeyIndex].outside end end,
		setFunc = function(var) if GH.AccountWide.SavedVars[GH.hotkeyIndex].hotkeyType == GH.Const.HotkeyType.primary or GH.AccountWide.SavedVars[GH.hotkeyIndex].hotkeyType == GH.Const.HotkeyType.specific then GH.AccountWide.SavedVars[GH.hotkeyIndex].outside = var else GH.Character.SavedVars[GH.hotkeyIndex].outside = var end end,
		width = "half",
		disabled = function() if (GH.AccountWide.SavedVars[GH.hotkeyIndex].hotkeyType == GH.Const.HotkeyType.primary or GH.AccountWide.SavedVars[GH.hotkeyIndex].hotkeyType == GH.Const.HotkeyType.specific or GH.AccountWide.SavedVars[GH.hotkeyIndex].hotkeyType == GH.Const.HotkeyType.character) then return false else return true end end,
		tooltip = GetString(GO_HOME_TooltipOutside),
		reference = "GH_OutsideCheckBox_LAM",
	}
	i = i + 1
	optionsData[i] = {
		type = "button",
    name = "Clear Key Binding",
    func = function() GH.AccountWide.SavedVars[GH.hotkeyIndex] = GH.AccountWide.Defaults[GH.hotkeyIndex] end,
    tooltip = "",
    width = "half",
	}
	i = i + 1
	optionsData[i] = {
		type = "header",
		name = "House Permissions",
	}
	i = i + 1
	optionsData[i] = {
		type = "button",
    name = "Open Permissions Editor",
    func = function() end,
    tooltip = "",
    width = "full",
	}
	i = i + 1
	optionsData[i] = {
		type = "header",
		name = GetString(GO_HOME_SettingsSettingsLabel),
	}
	i = i + 1
	optionsData[i] = {
		type = "checkbox",
		name = GetString(GO_HOME_SettingsChatMessagesLabel),
		getFunc = function() return GH.AccountWide.SavedVars.chatMessages end,
		setFunc = function(var) GH.AccountWide.SavedVars.chatMessages = var end,
		width = "half",
		tooltip = GetString(GO_HOME_TooltipChatMessages),
	}
	i = i + 1
	optionsData[i] = {
		type = "checkbox",
		name = GetString(GO_HOME_SettingsHouseNicknamesLabel),
		getFunc = function() return GH.AccountWide.SavedVars.useNicknames end,
		setFunc = function(var) GH.AccountWide.SavedVars.useNicknames = var GH.UpdateMenu() end,
		width = "half",
		tooltip = GetString(GO_HOME_TooltipHouseNicknames),
	}

	GH.LAMSettingsPanel = LAM2:RegisterAddonPanel(GH.addonName, panelData)
	LAM2:RegisterOptionControls(GH.addonName, optionsData)
	CM:RegisterCallback("LAM-PanelControlsCreated", GH.LAMPanelCreated) 
end

function GH.UpdateMenu()
	if not GH.settingsPanelCreated then return end
	GH_PrimaryHouseDropdown_LAM:UpdateChoices(GH.GetNames(), GH.GetOwnedHouseIDs())
	GH_AccountHouseDropdown_LAM:UpdateChoices(GH.GetAllHouseNames(), GH.GetAllHouseIDs())
	GH_CharacterHouseDropdown_LAM:UpdateChoices(GH.GetNames(), GH.GetOwnedHouseIDs())
	GH_SpecificHouseDropdown_LAM:UpdateChoices(GH.GetNames(), GH.GetOwnedHouseIDs())
end

function GH.LAMPanelCreated(panel)
	if panel ~= GH.LAMSettingsPanel then return end
	GH.settingsPanelCreated = true
	--GH.UpdateMenu()
end


--[[----------------------------------------------
Setup, Initialization and Event Callbacks
----------------------------------------------]]--
function GH.Initialize()
	GH.AccountWide.SavedVars = ZO_SavedVars:NewAccountWide("GoHomeAccountWideVars", GH.AccountWide.varsVersion, nil, GH.AccountWide.Defaults, GetWorldName())
	GH.Character.SavedVars = ZO_SavedVars:NewCharacterIdSettings("GoHomeCharacterVars", GH.Character.varsVersion, nil, GH.Character.Defaults, GetWorldName())
	
	GH.UpdateGuildInfo()
	GH.UpdateHouseData()
	GH.CreateSettingsWindow()
	
	ZO_CreateStringId("BINDING_NAME_GH_HOTKEY_1", GetString(GO_HOME_HotkeyLabel) .. "1")
	ZO_CreateStringId("BINDING_NAME_GH_HOTKEY_2", GetString(GO_HOME_HotkeyLabel) .. "2")
	ZO_CreateStringId("BINDING_NAME_GH_HOTKEY_3", GetString(GO_HOME_HotkeyLabel) .. "3")
	ZO_CreateStringId("BINDING_NAME_GH_HOTKEY_4", GetString(GO_HOME_HotkeyLabel) .. "4")
	ZO_CreateStringId("BINDING_NAME_GH_HOTKEY_5", GetString(GO_HOME_HotkeyLabel) .. "5")
	ZO_CreateStringId("BINDING_NAME_GH_HOTKEY_6", GetString(GO_HOME_HotkeyLabel) .. "6")
	ZO_CreateStringId("BINDING_NAME_GH_HOTKEY_7", GetString(GO_HOME_HotkeyLabel) .. "7")
	ZO_CreateStringId("BINDING_NAME_GH_HOTKEY_8", GetString(GO_HOME_HotkeyLabel) .. "8")
	ZO_CreateStringId("BINDING_NAME_GH_HOTKEY_9", GetString(GO_HOME_HotkeyLabel) .. "9")
	ZO_CreateStringId("BINDING_NAME_GH_HOTKEY_10", GetString(GO_HOME_HotkeyLabel) .. "10")

	SLASH_COMMANDS["/gohome"] = GH.CommandParse
	SLASH_COMMANDS["/gh"] = GH.CommandParse
	SLASH_COMMANDS["/ghdebug"] = GH.Debug
	SLASH_COMMANDS["/ghcurrent"] = GH.GetCurrentHouseInfo
	SLASH_COMMANDS["/ghlist"] = GH.ListHotkeyedHouses
	
	EM:UnregisterForEvent(GH.addonName, EVENT_ADD_ON_LOADED)
	EM:RegisterForEvent(GH.addonName, EVENT_COLLECTIBLE_NOTIFICATION_NEW, GH.OnCollectibleNotificationNew)
end

function GH.OnAddonLoaded(event, addonName)
	if addonName == GH.addonName then
		GH.Initialize()
	end
end

function GH.OnCollectibleNotificationNew(eventCode, id, notificationID)
	if GetCollectibleCategoryType(id) == COLLECTIBLE_CATEGORY_TYPE_HOUSE then
		GH.UpdateHouseData()
		GH.UpdateMenu()
	end
end

EM:RegisterForEvent(GH.addonName, EVENT_ADD_ON_LOADED, GH.OnAddonLoaded)