local _, addon = ...;

local menu = {};
addon.Menu = menu;

local MenuBuilder;

function menu.Init()
	local lib = LibStub("Krowi_MenuBuilder-1.0");
	
	MenuBuilder = lib:New({
		callbacks = {
			-- Checkbox callback: Read setting value
			KeyIsTrue = function(filters, keys)
				local key = keys[1];
				local defaultValue = keys[2];
				local value = KrowiBT_SavedData[key];
				if value == nil then return defaultValue; end
				return value;
			end,
			
			-- Radio callback: Check if setting equals text
			KeyEqualsText = function(text, filters, keys)
				local key = keys[1];
				local valueToCompare = keys[2] ~= nil and keys[2] or text;
				local value = KrowiBT_SavedData[key];
				return value == valueToCompare;
			end,
			
			-- Checkbox select: Toggle setting value
			OnCheckboxSelect = function(filters, keys)
				local key = keys[1];
				local defaultValue = keys[2];
				local value = KrowiBT_SavedData[key];
				if value == nil then value = defaultValue; end
				KrowiBT_SavedData[key] = not value;
				if addon.TimeLDB then
					addon.TimeLDB.Update();
				end
			end,
			
			-- Radio select: Set setting value
			OnRadioSelect = function(text, filters, keys)
				local key = keys[1];
				local valueToStore = keys[2] ~= nil and keys[2] or text;
				KrowiBT_SavedData[key] = valueToStore;
				if addon.TimeLDB then
					addon.TimeLDB.Update();
				end
			end
		}
	});
	
	addon.MenuBuilder = MenuBuilder;
end

function menu.ShowPopup(anchor)
	MenuBuilder:ShowPopup(function()
		local menuObj = MenuBuilder:GetMenu();
		if menuObj.SetTag then
			menuObj:SetTag("KBT_RIGHT_CLICK_MENU_OPTIONS");
		end
		menu.CreateMenu(nil, menuObj);
	end, anchor);
end

function menu.CreateMenu(self, menuObj)
	MenuBuilder:CreateTitle(menuObj, "Krowi's Brokers [Time]");
	
	MenuBuilder:CreateDivider(menuObj);
	MenuBuilder:CreateTitle(menuObj, "Time Format");
	
	local timeFormat = MenuBuilder:CreateSubmenuButton(menuObj, "Format");
	MenuBuilder:CreateRadio(timeFormat, "12 Hour", nil, {"TimeFormat", "12H"});
	MenuBuilder:CreateRadio(timeFormat, "24 Hour", nil, {"TimeFormat", "24H"});
	MenuBuilder:AddChildMenu(menuObj, timeFormat);
	
	MenuBuilder:CreateDivider(menuObj);
	MenuBuilder:CreateTitle(menuObj, "Time Display");
	
	local timeMode = MenuBuilder:CreateSubmenuButton(menuObj, "Display Mode");
	MenuBuilder:CreateRadio(timeMode, "Local Time", nil, {"TimeMode", "Local"});
	MenuBuilder:CreateRadio(timeMode, "Server Time", nil, {"TimeMode", "Server"});
	MenuBuilder:CreateRadio(timeMode, "Both", nil, {"TimeMode", "Both"});
	MenuBuilder:AddChildMenu(menuObj, timeMode);
	
	MenuBuilder:CreateDivider(menuObj);
	MenuBuilder:CreateCheckbox(menuObj, "Show Seconds", nil, {"ShowSeconds", false});
end