--[[------------------------------------------------------------------------------------------------
Title:          Houses
Author:         Static_Recharge
Description:    Handles the House information for the add-on.
------------------------------------------------------------------------------------------------]]--


--[[------------------------------------------------------------------------------------------------
Libraries and Aliases
------------------------------------------------------------------------------------------------]]--
local CDM = ZO_COLLECTIBLE_DATA_MANAGER


--[[------------------------------------------------------------------------------------------------
Houses Class Initialization
Houses    - Object containing all functions, tables, variables, and constants.
------------------------------------------------------------------------------------------------]]--
local Houses = {}


--[[------------------------------------------------------------------------------------------------
Houses:Initialize(Parent)
Inputs:				Parent 					                    - The parent object containing other required information.  
Outputs:			None
Description:	Initializes all of the variables and tables.
------------------------------------------------------------------------------------------------]]--
function Houses:Initialize(Parent)
  self.Parent = Parent
  self.Data = {}

	self:Update()

	self.initialized = true
end


--[[------------------------------------------------------------------------------------------------
Houses:IsInitialized()
Inputs:				None
Outputs:			initialized                         - bool for object initialized state
Description:	Returns true if the object has been successfully initialized.
------------------------------------------------------------------------------------------------]]--
function Houses:IsInitialized()
  return self.initialized
end


--[[------------------------------------------------------------------------------------------------
Houses:Update()
Inputs:				None
Outputs:			None
Description:	Updates the internal house information.
------------------------------------------------------------------------------------------------]]--
function Houses:Update()
	local function IsHouseCategory(categoryData)
		return categoryData:IsHousingCategory()
	end

	local function IsHouse(collectibleData)
		return collectibleData:IsCategoryType(COLLECTIBLE_CATEGORY_TYPE_HOUSE)
	end
	
	for i, categoryData in CDM:CategoryIterator({IsHouseCategory}) do
		for _, subCategoryData in categoryData:SubcategoryIterator({IsHouseCategory}) do
			for _, subCatCollectibleData in subCategoryData:CollectibleIterator({IsHouse}) do
				if not subCatCollectibleData:IsBlocked() then
					local name, description, icon, deprecatedLockedIcon, unlocked, purchasable, isActive, categoryType, hint = GetCollectibleInfo(subCatCollectibleData:GetId())
					self.Data[subCatCollectibleData:GetReferenceId()] = {
						name = name,
						description = description,
						nickname = subCatCollectibleData:GetFormattedNickname(),
						unlocked = unlocked,
						icon = icon,
						collectibleID = subCatCollectibleData:GetId(),
						texture = GetHousePreviewBackgroundImage(subCatCollectibleData:GetReferenceId()),
					}
				end
			end
		end
	end
end


--[[------------------------------------------------------------------------------------------------
Houses:GetName(id)
Inputs:				id 																	- house id to look up
Outputs:			name                              	- The name of the house
Description:	Returns the name of the specified house.
------------------------------------------------------------------------------------------------]]--
function Houses:GetName(id)
  return self.Data[id].name
end


--[[------------------------------------------------------------------------------------------------
Houses:GetNickName(id)
Inputs:				id 																	- house id to look up
Outputs:			nickname                            - The nickname of the house
Description:	Returns the nickname of the specified house.
------------------------------------------------------------------------------------------------]]--
function Houses:GetNickName(id)
  return self.Data[id].nickname
end


--[[------------------------------------------------------------------------------------------------
Houses:GetPreferredName(id)
Inputs:				id 																	- house id to look up
Outputs:			prefName                            - The preferred name of the house
Description:	Returns the preferred name of the specified house based on the saved settings.
------------------------------------------------------------------------------------------------]]--
function Houses:GetPreferredName(id)
	local Parent = self:GetParent()
	local useNicknames = Parent.SV.AW.useNicknames
	local prefName = ""
	if useNicknames then
		prefName = self.Data[id].nickname
	else
		prefName = self.Data[id].name
	end
	return prefName
end


--[[------------------------------------------------------------------------------------------------
Houses:IsUnlocked(id)
Inputs:				id 																	- house id to look up
Outputs:			unlocked                            - true if the house is unlocked
Description:	Returns the unlocked status of the house.
------------------------------------------------------------------------------------------------]]--
function Houses:IsUnlocked(id)
  return self.Data[id].unlocked
end


--[[------------------------------------------------------------------------------------------------
Houses:GetOwnedHouseIds()
Inputs:				None
Outputs:			Owned 															- List of owned house Ids
Description:	Returns the list of owned house Ids.
------------------------------------------------------------------------------------------------]]--
function Houses:GetOwnedHouseIds()
	local Owned = {}
	for i,v in pairs(self.Data) do
		if v.unlocked then
			table.insert(Owned, i)
		end
	end
	return Owned
end


--[[------------------------------------------------------------------------------------------------
Houses:GetOwnedHouseNames()
Inputs:				None
Outputs:			Owned 															- List of owned house preferred names
Description:	Returns the list of owned house preferred names.
------------------------------------------------------------------------------------------------]]--
function Houses:GetOwnedHouseNames()
	local Owned = {}
	local name
	for i,v in pairs(self.Data) do
		if v.unlocked then
			name = self:GetPreferredName(i)
			table.insert(Owned, name)
		end
	end
	return Owned
end


--[[------------------------------------------------------------------------------------------------
Houses:GetAllHouseIds()
Inputs:				None
Outputs:			All 																- List of all house Ids
Description:	Returns the list of all house Ids.
------------------------------------------------------------------------------------------------]]--
function Houses:GetAllHouseIds()
	local All = {}
	for i,v in pairs(self.Data) do
		table.insert(All, i)
	end
	return All
end


--[[------------------------------------------------------------------------------------------------
Houses:GetAllHouseNames()
Inputs:				None
Outputs:			All 																- List of all house Ids
Description:	Returns the list of all house names.
------------------------------------------------------------------------------------------------]]--
function Houses:GetAllHouseNames()
	local All = {}
	local name
	for i,v in pairs(self.Data) do
		name = self:GetName(i)
		table.insert(All, name)
	end
	return All
end


--[[------------------------------------------------------------------------------------------------
Houses:PrintCurrentHouseData()
Inputs:				None
Outputs:			None
Description:	Prints data about the current house the player is in.
------------------------------------------------------------------------------------------------]]--
function Houses:PrintCurrentHouseData()
	local Parent = self:GetParent()
	local isInHouse = GetCurrentZoneHouseId() ~= 0
	if not isInHouse then return nil end

	local houseId = GetCurrentZoneHouseId()
	local collectibleId = GetCollectibleIdForHouse(houseId)
	local name = GetCollectibleName(collectibleId)
	local nickname = GetCollectibleNickname(collectibleId)

	Parent.Chat:Msg("Current House Data",
										zo_strformat("houseId: <<1>>", houseId),
										zo_strformat("collectibleId: <<1>>", collectibleId),
										zo_strformat("name: <<1>>", name),
										zo_strformat("nickname: <<1>>", nickname)
									)
end


--[[------------------------------------------------------------------------------------------------
Houses:GetParent()
Inputs:				None
Outputs:			Parent                              - The parent object of this object.
Description:	Returns the parent object of this object for reference to parent variables.
------------------------------------------------------------------------------------------------]]--
function Houses:GetParent()
  return self.Parent
end


--[[------------------------------------------------------------------------------------------------
Global template assignment
------------------------------------------------------------------------------------------------]]--
GoHome.Houses = Houses