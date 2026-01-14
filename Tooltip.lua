local _, addon = ...

local tooltip = {}
addon.Tooltip = tooltip

function tooltip.Init()
	-- Initialize tooltip if needed
end

local function FormatResetTime(seconds)
	if not seconds then return 'Unknown' end

	local days = math.floor(seconds / 86400)
	local hours = math.floor((seconds % 86400) / 3600)
	local mins = math.floor((seconds % 3600) / 60)

	if days > 0 then
		return string.format('%dd %dh %dm', days, hours, mins)
	elseif hours > 0 then
		return string.format('%dh %dm', hours, mins)
	else
		return string.format('%dm', mins)
	end
end

local function GetFormattedTime(hour, min, sec, ampm)
	local showSeconds = KrowiBTI_Options.ShowSeconds

	if ampm == -1 then
		-- 24-hour format
		if showSeconds then
			return string.format('%02d:%02d:%02d', hour, min, sec)
		else
			return string.format('%02d:%02d', hour, min)
		end
	else
		-- 12-hour format
		local ampmText = (ampm == 1) and 'PM' or 'AM'
		if showSeconds then
			return string.format('%d:%02d:%02d %s', hour, min, sec, ampmText)
		else
			return string.format('%d:%02d %s', hour, min, ampmText)
		end
	end
end

local function GetTimeValues(useServerTime)
	local hour, min
	if useServerTime then
		hour, min = GetGameTime()
	else
		hour = tonumber(date('%H'))
		min = tonumber(date('%M'))
	end
	local sec = tonumber(date('%S'))

	local format24 = KrowiBTI_Options.TimeFormat == '24H'

	if format24 then
		return hour, min, sec, -1
	elseif hour >= 12 then
		if hour > 12 then hour = hour - 12 end
		return hour, min, sec, 1 -- PM
	else
		if hour == 0 then hour = 12 end
		return hour, min, sec, 2 -- AM
	end
end

function tooltip.Show(frame)
	GameTooltip:SetOwner(frame, 'ANCHOR_NONE')
	GameTooltip:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT')
	GameTooltip:AddLine(addon.Metadata.Title .. ' ' .. addon.Metadata.Version)
	GameTooltip_AddBlankLineToTooltip(GameTooltip)

	local lHour, lMin, lSec, lAmpm = GetTimeValues(false)
	local localTime = GetFormattedTime(lHour, lMin, lSec, lAmpm)
	GameTooltip:AddDoubleLine(addon.L['Local Time:'], localTime, 1, 1, 1, 1, 1, 1)

	local sHour, sMin, sSec, sAmpm = GetTimeValues(true)
	local serverTime = GetFormattedTime(sHour, sMin, sSec, sAmpm)
	GameTooltip:AddDoubleLine(addon.L['Server Time:'], serverTime, 1, 1, 1, 1, 1, 1)

	-- Daily and Weekly Resets
	local dailyReset = C_DateAndTime.GetSecondsUntilDailyReset()
	local weeklyReset = C_DateAndTime.GetSecondsUntilWeeklyReset()

	if dailyReset or weeklyReset then
		GameTooltip_AddBlankLineToTooltip(GameTooltip)

		if dailyReset then
			local resetTime = FormatResetTime(dailyReset)
			GameTooltip:AddDoubleLine(addon.L['Daily Reset'], resetTime, 1, 1, 1, 1, 1, 1)
		end

		if weeklyReset then
			local resetTime = FormatResetTime(weeklyReset)
			GameTooltip:AddDoubleLine(addon.L['Weekly Reset'], resetTime, 1, 1, 1, 1, 1, 1)
		end
	end

	GameTooltip_AddBlankLineToTooltip(GameTooltip)
	if Calendar_LoadUI then
		GameTooltip:AddLine(addon.L['Left-Click'] .. ': ' .. addon.L['Toggle Calendar'], 0.5, 0.8, 1)
		GameTooltip:AddLine(addon.L['Shift + Left-Click'] .. ': ' .. addon.L['Toggle Time Manager'], 0.5, 0.8, 1)
	else
		GameTooltip:AddLine(addon.L['Left-Click'] .. ': ' .. addon.L['Toggle Time Manager'], 0.5, 0.8, 1)
	end
	GameTooltip:AddLine(addon.L['Right-Click: Options'], 0.5, 0.8, 1)

	GameTooltip:Show()
end