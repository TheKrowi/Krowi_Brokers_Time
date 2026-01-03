local addonName, addon = ...;

addon.L = LibStub(addon.Libs.AceLocale):GetLocale(addonName);

KrowiBTI_Options = KrowiBTI_Options or {
	TimeFormat = "24H",
	TimeMode = "Local",
	ShowSeconds = false,
};

KrowiBTI_SavedData = KrowiBTI_SavedData or {};

local function ConvertTime(hour, min, sec)
	local format24 = KrowiBTI_Options.TimeFormat == "24H";
	local showSeconds = KrowiBTI_Options.ShowSeconds;
	local seconds = showSeconds and sec or nil;

	if format24 then
		return hour, min, seconds, -1;
	elseif hour >= 12 then
		if hour > 12 then hour = hour - 12 end
		return hour, min, seconds, 1; -- PM
	else
		if hour == 0 then hour = 12 end
		return hour, min, seconds, 2; -- AM
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
	return ConvertTime(hour, min, sec);
end

local function FormatTimeString(hour, min, sec, ampm)
	local showSeconds = KrowiBTI_Options.ShowSeconds;
	local timeStr;

	if ampm == -1 then
		-- 24-hour format
		if showSeconds then
			timeStr = format("%02d:%02d:%02d", hour, min, sec);
		else
			timeStr = format("%02d:%02d", hour, min);
		end
	else
		-- 12-hour format
		local ampmText = (ampm == 1) and "pm" or "am";
		if showSeconds then
			timeStr = format("%d:%02d:%02d %s", hour, min, sec, ampmText);
		else
			timeStr = format("%d:%02d %s", hour, min, ampmText);
		end
	end

	return timeStr;
end

function addon.GetDisplayText()
	local mode = KrowiBTI_Options.TimeMode;

	if mode == "Server" then
		local hour, min, sec, ampm = GetTimeValues(true);
		return FormatTimeString(hour, min, sec, ampm);
	elseif mode == "Both" then
		local sHour, sMin, sSec, sAmpm = GetTimeValues(true);
		local lHour, lMin, lSec, lAmpm = GetTimeValues(false);
		local serverTime = FormatTimeString(sHour, sMin, sSec, sAmpm);
		local localTime = FormatTimeString(lHour, lMin, lSec, lAmpm);
		return serverTime .. " / " .. localTime;
	else
		-- Local time (default)
		local hour, min, sec, ampm = GetTimeValues(false);
		return FormatTimeString(hour, min, sec, ampm);
	end
end

local function OnClick(self, button)
	if button == "LeftButton" then
		if IsShiftKeyDown() then
			ToggleTimeManager();
		else
			ToggleCalendar();
		end
		return;
	end

	if button ~= "RightButton" then
		return;
	end

	addon.Menu.ShowPopup();
end

local function OnEnter(self)
	addon.Tooltip.Show(self);
end

local function OnLeave(self)
	GameTooltip:Hide();
end
local updateTimer
local function OnEvent(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		addon.LDB:Update();

		if updateTimer then
			return
		end

		updateTimer = C_Timer.NewTicker(1, function()
			addon.LDB:Update();
		end);
	end
end

local brokers = LibStub("Krowi_Brokers-1.0");
brokers:InitBroker(
	addonName,
	addon,
	"Interface\\Icons\\INV_Misc_PocketWatch_01",
	OnEnter,
	OnLeave,
	OnClick,
	OnEvent,
	addon.GetDisplayText,
	addon.Menu,
	addon.Tooltip
)
brokers:RegisterEvents("PLAYER_ENTERING_WORLD");