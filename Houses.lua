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
local Houses = ZO_InitializingObject:Subclass()


--[[------------------------------------------------------------------------------------------------
Houses:Initialize(Parent)
Inputs:				Parent 					                    - The parent object containing other required information.  
Outputs:			None
Description:	Initializes all of the variables and tables.
------------------------------------------------------------------------------------------------]]--
function Houses:Initialize(Parent)
  self.Parent = Parent
  self.Data = {}
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
  for i, categoryData in CDM:CategoryIterator({categoryData:IsHousingCategory()}) do
		for _, subCategoryData in categoryData:SubcategoryIterator({categoryData:IsHousingCategory()}) do
			for _, subCatCollectibleData in subCategoryData:CollectibleIterator({collectibleData:IsCategoryType(COLLECTIBLE_CATEGORY_TYPE_HOUSE)}) do
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
GoHome.HOUSES = Houses