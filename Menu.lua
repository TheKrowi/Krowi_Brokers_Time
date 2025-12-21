local _, addon = ...;

local menu = {};
addon.Menu = menu;

local function GetSetting(key, defaultValue)
	local value = KrowiBT_SavedData[key];
	if value == nil then return defaultValue; end
	return value;
end

local function SetSetting(key, value)
	KrowiBT_SavedData[key] = value;
	if addon.TimeLDB then
		addon.TimeLDB.Update();
	end
end

local function CreateRadio(menuObj, text, key, valueToStore)
	local compareValue = valueToStore ~= nil and valueToStore or text;
	
	local button = menuObj:CreateRadio(
		text,
		function()
			return GetSetting(key) == compareValue;
		end,
		function()
			SetSetting(key, compareValue);
		end
	);
	if button.SetResponse then
		button:SetResponse(MenuResponse.Refresh);
	end
	return button;
end

local function CreateCheckbox(menuObj, text, key, defaultValue)
	return menuObj:CreateCheckbox(
		text,
		function()
			return GetSetting(key, defaultValue);
		end,
		function()
			local currentValue = GetSetting(key, defaultValue);
			SetSetting(key, not currentValue);
		end
	);
end

function menu.CreateMenu(self, menuObj)
	addon.MenuUtil:CreateTitle(menuObj, "Krowi's Brokers [Time]");
	
	addon.MenuUtil:CreateDivider(menuObj);
	addon.MenuUtil:CreateTitle(menuObj, "Time Format");
	
	local timeFormat = addon.MenuUtil:CreateButton(menuObj, "Format");
	CreateRadio(timeFormat, "12 Hour", "TimeFormat", "12H");
	CreateRadio(timeFormat, "24 Hour", "TimeFormat", "24H");
	addon.MenuUtil:AddChildMenu(menuObj, timeFormat);
	
	addon.MenuUtil:CreateDivider(menuObj);
	addon.MenuUtil:CreateTitle(menuObj, "Time Display");
	
	local timeMode = addon.MenuUtil:CreateButton(menuObj, "Display Mode");
	CreateRadio(timeMode, "Local Time", "TimeMode", "Local");
	CreateRadio(timeMode, "Server Time", "TimeMode", "Server");
	CreateRadio(timeMode, "Both", "TimeMode", "Both");
	addon.MenuUtil:AddChildMenu(menuObj, timeMode);
	
	addon.MenuUtil:CreateDivider(menuObj);
	CreateCheckbox(menuObj, "Show Seconds", "ShowSeconds", false);
	CreateCheckbox(menuObj, "Colored Text", "ShowColoredText", false);
end