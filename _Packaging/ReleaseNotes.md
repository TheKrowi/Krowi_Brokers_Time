### Changed
- Extracted broker initialization logic into new Krowi_Brokers-1.0 library for reuse across addons
- Refactored event registration and initialization flow to use centralized broker library
- Improved code organization by consolidating broker setup into standardized library calls

### Changed (3.1)
- Removed unused Krowi_PopupDialog submodule references
- Code cleanup: removed blank line in main addon file
- Updated localization file formatting

### Changed (3.2)
- Updated Krowi_Brokers library to latest version
- Simplified broker initialization by removing redundant parameters (icon, display function, menu, and tooltip now handled internally)
- Refactored menu callback handling to use dedicated RefreshBroker function
- Fixed menu popup to correctly pass caller reference for ElvUI and Titan Panel integration

### Fixed (3.2)
- Tooltip now uses localized strings for "Local Time:" and "Server Time:" labels
- Added missing "Weekly Reset" translation key
- Removed unused translation keys and outdated feature references

### Changed (3.3)
- Updated Krowi_Brokers and Krowi_Menu libraries to latest versions
- Code style consistency: removed semicolons throughout all files
- Simplified menu structure by removing redundant dividers and title sections

### Added (3.3)
- LoadSavedVariablesFirst flag in TOC for proper variable initialization
- Default values handling for saved variables to prevent nil errors