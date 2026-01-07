# Changelog
All notable changes to this project will be documented in this file.

## 3.3 - 2026-01-07
### Changed
- Updated Krowi_Brokers and Krowi_Menu libraries to latest versions
- Code style consistency: removed semicolons throughout all files
- Simplified menu structure by removing redundant dividers and title sections

### Added
- LoadSavedVariablesFirst flag in TOC for proper variable initialization
- Default values handling for saved variables to prevent nil errors

## 3.2 - 2026-01-06
### Changed
- Updated Krowi_Brokers library to latest version
- Simplified broker initialization by removing redundant parameters (icon, display function, menu, and tooltip now handled internally)
- Refactored menu callback handling to use dedicated RefreshBroker function
- Fixed menu popup to correctly pass caller reference for ElvUI and Titan Panel integration

### Fixed
- Tooltip now uses localized strings for "Local Time:" and "Server Time:" labels
- Added missing "Weekly Reset" translation key
- Removed unused translation keys and outdated feature references

## 3.1 - 2026-01-04
### Changed
- Removed unused Krowi_PopupDialog submodule references
- Code cleanup: removed blank line in main addon file
- Updated localization file formatting

## 3.0 - 2026-01-03
### Changed
- Extracted broker initialization logic into new Krowi_Brokers-1.0 library for reuse across addons
- Refactored event registration and initialization flow to use centralized broker library
- Improved code organization by consolidating broker setup into standardized library calls

## 2.1 - 2025-12-29
### Fixed
- Localization now properly applied to menu items

## 2.0 - 2025-12-29
### Change
- Menu generation and handling (dev note: for classic user this should be an invisible change; for mainline users this should reflect in modern looking drop down menus)

### Mists Classic
- Added support

### WoW Classic
- Added support

## 1.1 - 2025-12-22
### Added
- Russian localization (thank you ZamestoTV)

## 1.0 - 2025-12-22
### Added
- Local time, server time, or both display modes
- 12-hour and 24-hour format options
- Optional seconds display (updates every 1 second when enabled)
- Optional colored text (green) for time display
- Daily and weekly reset timers in tooltip
- Calendar integration (left-click to open)
- Time Manager integration (Shift + left-click to open)
- Clean tooltip showing local time, server time, and reset timers
- Right-click menu for quick settings access