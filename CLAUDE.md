# CLAUDE.md

Krowi's Brokers [Time] (prefix `KrowiBTI`, acronym `KBTI`) is a World of Warcraft LibDataBroker addon in Lua 5.1 that shows local time, server time or both on a broker bar, with the daily and weekly reset timers in its tooltip; a click opens the calendar or the Time Manager. The workspace-wide rules (tooling traps, the game loop, taint, git, release safety, how Krowi wants choices presented) load from `../CLAUDE.md` and `Krowi_ClaudeKit/WowAddons.md`; this file adds only what is specific to this repo.

There is no build, lint or test step: the game is the test harness. The `krowi` plugin (enabled in `.claude/settings.json`) syntax-checks every edited `.lua` with Lua 5.1 and guards the known tooling traps. The repo is public, but `.claude/settings.json` points at the private kit by absolute path, so the plugin loads only on Krowi's machine; that is intended.

## Clients and loading

- One TOC, `Krowi_Brokers_Time.toc`, for every client: `## Interface: 120000, 110207, 50503, 20505, 11508` (Retail 12.0 and 11.2.7, Mists Classic, TBC Anniversary, Classic Era).
- The client differences are handled at runtime in `OnClick` (`Krowi_Brokers_Time.lua:89-113`): `ToggleTimeManager()` on Retail (`addon.Util.IsMainline`), `TimeManager_Toggle()` elsewhere, and the calendar only where `Calendar_LoadUI` exists. In wow-ui-source that is Retail and the Wrath, Cata and Mists UIParent, not Vanilla or TBC, so on Era and Anniversary a left-click opens the Time Manager, and the tooltip hints follow (`Tooltip.lua:103-108`).
- `## SavedVariables: KrowiBTI_Options, KrowiBTI_SavedData` (account-wide) with `## LoadSavedVariablesFirst: 1`, so the saved values exist when the code runs: `Krowi_Brokers_Time.lua:3-14` merges `defaultOptions` (`TimeFormat`, `TimeMode`, `ShowSeconds`) into `KrowiBTI_Options` key by key at file scope. A new option is a new default there; a new saved variable must be added to the TOC line or it is lost on logout. There are no migrations.
- Load order is the TOC: `Libs\Files.xml` (Krowi_Util, the bundled CallbackHandler-1.0 and LibDataBroker-1.1, Krowi_Menu, Krowi_Brokers, then `Libs.lua`), `Localization\Files.xml` (`enUS.lua`, `deDE.lua`, `ruRU.lua`, `Shared.lua`), `Tooltip.lua`, `Menu.lua`, `Krowi_Brokers_Time.lua`. A file only sees what earlier files defined, and a new `.lua` must be listed in the TOC or a `Files.xml`.
- There is no `ADDON_LOADED` handler: the main file does everything at load (`Krowi_Brokers_Time.lua:145-155`). `addon.Broker:InitBroker(...)` calls `addon.Menu.Init()` and `addon.Tooltip.Init()` (an empty stub, required because `addon.Tooltip` exists) and creates the LDB object as `addon.LDB`; then `PLAYER_ENTERING_WORLD` is registered, and its first firing starts a 1 s `C_Timer.NewTicker` that calls `addon.LDB:Update()`.

## Libraries

- Submodules under `Libs/`: `Krowi_Util`, `Krowi_Menu`, `Krowi_Brokers` (develop and release them in `../Krowi_Libraries/<lib>`, never here). Bundled, not submodules: CallbackHandler-1.0 and LibDataBroker-1.1. Krowi_Util embeds LibStub, AceLocale and the same CallbackHandler and LibDataBroker minors.
- `Libs/Libs.lua` calls `KROWI_LIBMAN:NewAddon(...)`, which sets `addon.Util` (Krowi_Util), `addon.MenuBuilder` (Krowi_Menu: Blizzard's `MenuUtil` on Retail, a `UIDropDownMenu` frame on Classic), `addon.Broker` (Krowi_Brokers), `addon.Metadata` (TOC fields) and `addon.Localization`.
- `Krowi_Brokers` is shared with Krowi_Brokers_System and Krowi_Brokers_Currency; a change there usually means releasing all three. Only the first copy loaded runs (`Krowi_Brokers_2`, minor 0), and its single frame `Krowi_Brokers_HelperFrame` hands every event any of these addons registered to every handler (`Libs/Krowi_Brokers/Krowi_Brokers.lua:58-79`), so `OnEvent` must check the event name. It also adds `addon.Menu.CreateElvUIOptionsMenu` and `CreateTitanOptionsMenu`, which `Menu.lua` calls last.

## Architecture

- `Krowi_Brokers_Time.lua`: defaults and the broker text (`addon.GetDisplayText()`). Server time comes from `GetGameTime()`, local time from `date()`. `GetGameTime` has no seconds, so both use the local clock's seconds (`Krowi_Brokers_Time.lua:42`). The 12-hour form writes `am`/`pm` in lowercase.
- `Tooltip.lua`: local and server time, `C_DateAndTime.GetSecondsUntilDailyReset()` and `GetSecondsUntilWeeklyReset()` (present on all four clients) and click hints. It has its own copy of the time conversion, with `AM`/`PM` in capitals, and is drawn once on `OnEnter`, not refreshed while hovered.
- `Menu.lua`: the right-click menu (Format, Display Mode, Show Seconds), built with `addon.MenuBuilder`; its radios and checkbox write straight into `KrowiBTI_Options`, and `addon.Menu.RefreshBroker()` updates the text.
- Clicks: left opens the calendar, Shift+left the Time Manager (a plain left-click where there is no calendar), right the menu.

## Taint-sensitive areas

The tooltip fills Blizzard's shared `GameTooltip` (`Tooltip.lua:70-112`; `OnLeave` hides it). `OnClick` calls Blizzard's UI toggles from addon code: `ToggleCalendar()`, which loads `Blizzard_Calendar` on demand, and `ToggleTimeManager()` or `TimeManager_Toggle()`. The addon reads no `C_Calendar` data, and `GetGameTime`, `date` and the `C_DateAndTime` reset timers return no secret values in the 12.1.5 API documentation. Run the `krowi:taint-reviewer` agent after changing the click handler, the tooltip or the event handling.

Two hazards the baseline review (2026-10-17) found plausible on Retail 12.x but could not confirm from source: filling `GameTooltip` from addon code can run Blizzard's widget-set cleanup tainted, the LayoutFrame "secret number value" class of WoWUIBugs #811 (a private tooltip, ideally one Krowi_Brokers provides for every broker, removes it); and the calendar opened out of combat inside a Mythic+ key, an encounter or a PvP match may hit its own unprobed `C_Calendar` compares tainted (`Blizzard_Calendar.lua` `CalendarFrame_Update`). Test the second with a click between pulls of a key.

## Localization

`Localization/enUS.lua`, `deDE.lua`, `ruRU.lua` and `Shared.lua`. The code is above the `AUTOGENTOKEN` marker (line 4 in `enUS.lua`, line 5 in the others, after `if not L then return end`) and the CurseForge export below it. Every release replaces everything below the marker with a fresh export, which writes `= true` where a translation equals its key (`deDE.lua:13`) and leaves untranslated keys out, so they fall back to English. New strings go below the marker in `enUS.lua`, and Krowi has to add them on the CurseForge localization page too (`Shared.lua:1` links it), or the next release drops them. `ruRU.lua` lacks `Left-Click`, `Shift + Left-Click`, `Toggle Calendar` and `Toggle Time Manager`; the open community PR #2 adds them below the marker, where the next release overwrites them unless they are on CurseForge as well. `Shared.lua` sets `addon.L` last.

## Code style

Match the file you are editing:

- Tabs for indentation, except `Libs/Libs.lua` (4 spaces). Single quotes, except in the CurseForge export. No semicolons.
- Line 1 is `local addonName, addon = ...` in the main file and `local _, addon = ...` elsewhere (`Localization/Shared.lua` opens with its CurseForge link), with no banner above it. A module file makes a local table and publishes it (`local menu = {}`, then `addon.Menu = menu`); its functions are `module.Name` in PascalCase, helpers `local function PascalCase`, locals camelCase. `Krowi_Brokers_Time.lua` calls the global `format`, `Tooltip.lua` `string.format`.
- CRLF on disk (LF in git, `core.autocrlf=true`), no final newline, no BOM, except `Krowi_Brokers_Time.lua`, which starts with a UTF-8 BOM. The game and the plugin's syntax check accept it; a new file gets none.
- `.vscode/settings.json` lists the globals the Lua language server accepts (`Lua.diagnostics.globals`); add a new WoW global there.

## Testing in game

`.vscode/settings.json` fsdeploys on every save (`deployWorkspaceOnSave`) to `_retail_`, `_classic_`, `_classic_era_`, `_ptr_` and `_classic_era_ptr_`. Its nodes exclude `.claude` and `docs`, so a save no longer copies a worktree's files into the AddOns folder, but it still redeploys the main checkout over a worktree deploy. Before an in-game check, run the kit's `Deploy.ps1 -WhatIf` and deploy, then `/reload` and `Read-GameErrors.ps1` (see `WowAddons.md`, Closing the loop with the game). The addon needs a broker display: Titan Panel is installed on every client, ElvUI on Classic, Era and the PTR. Hover for the tooltip, left-click for the calendar (Shift for the Time Manager; on Era and Anniversary always the Time Manager), right-click for the menu.

## Git and release

- `main` is the only branch, and both the integration and the release branch: Releases 1.0 to 4.0 are commits and tags on `main`. Branch from `main` and open PRs against it.
- Release only with the plugin's `krowi:release` skill; releases are cut on `main`. Uploads are `--stability stable`: every GitHub release so far is a full release.
- The 2.0 and 4.0 changelog entries put client-only changes under client headings (`### Mists Classic`, `### TBC Classic`, `### WoW Classic`) after `### Added` and `### Changed`.

## Known debt (verified 2026-10-17)

- On Retail and Mists, a left-click in combat does nothing and the first one per session prints "Interface action failed because of an AddOn.": `ToggleCalendar()` (`Krowi_Brokers_Time.lua:105`) ends in `ShowUIPanel(CalendarFrame)`, which refuses an insecure caller in combat. Return early on `InCombatLockdown()` or fall back to the Time Manager. Era and Anniversary have no calendar and are not affected.
- The TOC's Interface numbers trail the clients (12.1.5, 5.5.4, 2.5.6 and 1.15.9 in wow-ui-source), and 110207 is a Retail version that no longer exists (`Krowi_Brokers_Time.toc:1`).
- The TOC claims TBC Anniversary (20505), but `.vscode/settings.json` has no `_anniversary_` node and the addon is not installed in that client.
- `Tooltip.lua:26-68` duplicates the time conversion of `Krowi_Brokers_Time.lua:18-68`, with `AM`/`PM` where the broker text has `am`/`pm`.
- `_Packaging/Description.md` says that without Show Seconds the text updates every 30 seconds; the ticker always runs every second (`Krowi_Brokers_Time.lua:139`).
- `KrowiBTI_SavedData` is created (`Krowi_Brokers_Time.lua:16`) and never used. The strings `Time Display` and `Time Format` are in every locale file and used nowhere; `Tooltip.lua:11` returns an unlocalized `'Unknown'`.
- `Libs/Files.xml:4-5` loads the bundled CallbackHandler-1.0 and LibDataBroker-1.1 after Krowi_Util has loaded the same minors, so LibStub ignores them.
- Leftovers: `Localization/Shared.lua:4` sets a local `L` it never uses, and `.vscode/settings.json` lists the global `Krowi_Brokers_EventFrame`, a frame that no longer exists.