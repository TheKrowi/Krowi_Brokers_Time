local _, addon = ...;

local menu = {};
addon.Menu = menu;

local menuBuilder;

function menu.Init()
	local lib = LibStub("Krowi_MenuBuilder-1.0");

	menuBuilder = lib:New({
		uniqueTag = "KBT_RIGHT_CLICK_MENU_OPTIONS",
		callbacks = {
			OnCheckboxSelect = function(filters, keys)
				addon.Util.WriteNestedKeys(filters, keys, not menuBuilder:KeyIsTrue(filters, keys));
				addon.TimeLDB.Update();
			end,
			OnRadioSelect = function(filters, keys, value)
				addon.Util.WriteNestedKeys(filters, keys, value);
				addon.TimeLDB.Update();
			end
		}
	});
end

function menu.ShowPopup()
	menuBuilder:ShowPopup(function()
		local menuObj = menuBuilder:GetMenu();
		menu.CreateMenu(nil, menuObj);
	end);
end

function menu.CreateMenu(self, menuObj)
	menuBuilder:CreateTitle(menuObj, "Krowi's Brokers [Time]");

	menuBuilder:CreateDivider(menuObj);
	menuBuilder:CreateTitle(menuObj, addon.L["Time Format"]);

	local timeFormat = menuBuilder:CreateSubmenuButton(menuObj, addon.L["Format"]);
	menuBuilder:CreateRadio(timeFormat, addon.L["12 Hour"], KrowiBT_SavedData, {"TimeFormat"}, "12H");
	menuBuilder:CreateRadio(timeFormat, addon.L["24 Hour"], KrowiBT_SavedData, {"TimeFormat"}, "24H");
	menuBuilder:AddChildMenu(menuObj, timeFormat);

	menuBuilder:CreateDivider(menuObj);
	menuBuilder:CreateTitle(menuObj, addon.L["Time Display"]);

	local timeMode = menuBuilder:CreateSubmenuButton(menuObj, addon.L["Display Mode"]);
	menuBuilder:CreateRadio(timeMode, addon.L["Local Time"], KrowiBT_SavedData, {"TimeMode"}, "Local");
	menuBuilder:CreateRadio(timeMode, addon.L["Server Time"], KrowiBT_SavedData, {"TimeMode"}, "Server");
	menuBuilder:CreateRadio(timeMode, addon.L["Both"], KrowiBT_SavedData, {"TimeMode"}, "Both");
	menuBuilder:AddChildMenu(menuObj, timeMode);

	menuBuilder:CreateDivider(menuObj);
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show Seconds"], KrowiBT_SavedData, {"ShowSeconds"});
end