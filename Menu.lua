local addonName, addon = ...

local menu = {}
addon.Menu = menu

local menuBuilder

function menu.RefreshBroker()
	addon.LDB:Update()
end

function menu.Init()
	local lib = LibStub("Krowi_MenuBuilder-1.0")

	menuBuilder = lib:New({
		uniqueTag = addon.Metadata.Prefix .. "_RIGHT_CLICK_MENU_OPTIONS",
		callbacks = {
			OnCheckboxSelect = function(filters, keys)
				addon.Util.WriteNestedKeys(filters, keys, not menuBuilder:KeyIsTrue(filters, keys))
				menu.RefreshBroker()
			end,
			OnRadioSelect = function(filters, keys, value)
				addon.Util.WriteNestedKeys(filters, keys, value)
				menu.RefreshBroker()
			end
		}
	})
end

local function CreateMenu(menuObj, caller)
	menuBuilder:CreateTitle(menuObj, addon.Metadata.Title .. " " .. addon.Metadata.Version)

	menuBuilder:CreateDivider(menuObj)

	local timeFormat = menuBuilder:CreateSubmenuButton(menuObj, addon.L["Format"])
	menuBuilder:CreateRadio(timeFormat, addon.L["12 Hour"], KrowiBTI_Options, {"TimeFormat"}, "12H")
	menuBuilder:CreateRadio(timeFormat, addon.L["24 Hour"], KrowiBTI_Options, {"TimeFormat"}, "24H")
	menuBuilder:AddChildMenu(menuObj, timeFormat)

	local timeMode = menuBuilder:CreateSubmenuButton(menuObj, addon.L["Display Mode"])
	menuBuilder:CreateRadio(timeMode, addon.L["Local Time"], KrowiBTI_Options, {"TimeMode"}, "Local")
	menuBuilder:CreateRadio(timeMode, addon.L["Server Time"], KrowiBTI_Options, {"TimeMode"}, "Server")
	menuBuilder:CreateRadio(timeMode, addon.L["Both"], KrowiBTI_Options, {"TimeMode"}, "Both")
	menuBuilder:AddChildMenu(menuObj, timeMode)

	menuBuilder:CreateCheckbox(menuObj, addon.L["Show Seconds"], KrowiBTI_Options, {"ShowSeconds"})

	menu.CreateElvUIOptionsMenu(menuBuilder, menuObj, caller)
	menu.CreateTitanOptionsMenu(menuBuilder, menuObj, caller)
end

function menu.ShowPopup(caller)
	menuBuilder:ShowPopup(function()
		local menuObj = menuBuilder:GetMenu()
		CreateMenu(menuObj, caller)
	end)
end