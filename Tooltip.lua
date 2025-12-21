local _, addon = ...;

local tooltip = {};
addon.Tooltip = tooltip;

local function GetFormattedTime(hour, min, sec, ampm)
	local showSeconds = KrowiBT_SavedData.ShowSeconds;
	
	if ampm == -1 then
		-- 24-hour format
		if showSeconds then
			return string.format("%02d:%02d:%02d", hour, min, sec);
		else
			return string.format("%02d:%02d", hour, min);
		end
	else
		-- 12-hour format
		local ampmText = (ampm == 1) and "PM" or "AM";
		if showSeconds then
			return string.format("%d:%02d:%02d %s", hour, min, sec, ampmText);
		else
			return string.format("%d:%02d %s", hour, min, ampmText);
		end
	end
end

local function GetTimeValues(useServerTime)
	local hour, min;
	if useServerTime then
		hour, min = GetGameTime();
	else
		hour = tonumber(date("%H"));
		min = tonumber(date("%M"));
	end
	local sec = tonumber(date("%S"));
	
	local format24 = KrowiBT_SavedData.TimeFormat == "24H";
	
	if format24 then
		return hour, min, sec, -1;
	elseif hour >= 12 then
		if hour > 12 then hour = hour - 12 end
		return hour, min, sec, 1; -- PM
	else
		if hour == 0 then hour = 12 end
		return hour, min, sec, 2; -- AM
	end
end

function tooltip.ShowTimeTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT");
	
	GameTooltip:AddLine("Krowi's Brokers [Time]");
	GameTooltip:AddLine(" ");
	
	-- Local time
	local lHour, lMin, lSec, lAmpm = GetTimeValues(false);
	local localTime = GetFormattedTime(lHour, lMin, lSec, lAmpm);
	GameTooltip:AddDoubleLine("Local Time:", localTime, 1, 1, 1, 1, 1, 1);
	
	-- Server time
	local sHour, sMin, sSec, sAmpm = GetTimeValues(true);
	local serverTime = GetFormattedTime(sHour, sMin, sSec, sAmpm);
	GameTooltip:AddDoubleLine("Server Time:", serverTime, 1, 1, 1, 1, 1, 1);
	
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine("|cff00ccffLeft-Click:|r Open Calendar", 0.7, 0.7, 0.7);
	GameTooltip:AddLine("|cff00ccffShift + Left-Click:|r Time Manager", 0.7, 0.7, 0.7);
	GameTooltip:AddLine("|cff00ccffRight-Click:|r Options", 0.7, 0.7, 0.7);
	
	GameTooltip:Show();
end