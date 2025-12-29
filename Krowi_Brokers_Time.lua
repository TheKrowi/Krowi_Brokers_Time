local addonName, addon = ...;

addon.L = LibStub(addon.Libs.AceLocale):GetLocale(addonName);

KrowiBT_SavedData = KrowiBT_SavedData or {
	TimeFormat = "12H", -- 12H or 24H
	TimeMode = "Local", -- Local, Server, or Both
	ShowSeconds = false,
};

-- Time formatting functions
local function ConvertTime(hour, min, sec)
	local format24 = KrowiBT_SavedData.TimeFormat == "24H";
	local showSeconds = KrowiBT_SavedData.ShowSeconds;
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
	local showSeconds = KrowiBT_SavedData.ShowSeconds;
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

function addon.GetFormattedTime()
	local mode = KrowiBT_SavedData.TimeMode;

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
local updateTimer = nil;

local function StartTimeUpdates()
	if updateTimer then return end

	local updateInterval = KrowiBT_SavedData.ShowSeconds and 1 or 30;
	updateTimer = C_Timer.NewTicker(updateInterval, function()
		if addon.TimeLDB then
			addon.TimeLDB.Update();
		end
	end);
end

local function StopTimeUpdates()
	if updateTimer then
		updateTimer:Cancel();
		updateTimer = nil;
	end
end

local function OnEvent(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		StartTimeUpdates();
		if addon.TimeLDB then
			addon.TimeLDB.Update();
		end
	end
end

local function OnShow(self)
	StartTimeUpdates();
	if addon.TimeLDB then
		addon.TimeLDB.Update();
	end
end

local function OnHide(self)
	StopTimeUpdates();
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
	addon.Tooltip.ShowTimeTooltip(self);
end

local function OnLeave(self)
	GameTooltip:Hide();
end

local function Create_Frames()
	local LDB = LibStub("LibDataBroker-1.1", true);
	if not LDB then
		return;
	end

	addon.Menu.Init();

	local TimeLDB = LDB:NewDataObject("Krowi_Brokers_Time", {
		type = "data source",
		tocname = "Krowi_Brokers_Time",
		text = addon.GetFormattedTime(),
		icon = "Interface\\Icons\\INV_Misc_PocketWatch_01",
		category = "Information",
	});

	TimeLDB.OnShow = OnShow;
	TimeLDB.OnHide = OnHide;
	TimeLDB.OnClick = OnClick;
	TimeLDB.OnEnter = OnEnter;
	TimeLDB.OnLeave = OnLeave;
	TimeLDB.Update = function()
		TimeLDB.text = addon.GetFormattedTime();
	end
	addon.TimeLDB = TimeLDB;

	local ldbFrame = CreateFrame("Frame");
	ldbFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	ldbFrame:SetScript("OnEvent", OnEvent);

	-- Initial update
	TimeLDB.Update();
end

Create_Frames();