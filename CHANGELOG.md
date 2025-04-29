# Changelog

All notable changes to the Ultima VII: Revisited project from the unoften fork will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

This section documents changes made in this fork compared to the original `ViridianGames/U7Revisited` baseline.

### Added

**Build System & Workflow:**
- Unified wrapper script (`u7`, `u7.bat`) for common development tasks (build, run, clean, setup), replacing manual Meson commands.
- Standardized debug (`build-debug/`) and release (`build-release/`) build directories managed via Meson build types (`-Dbuildtype=debug|release`).
- Centralized helper scripts for build, run, setup, and copying executables into the `scripts/` directory.
- Enforced 64-bit architecture requirement in the build system.
- Improved `u7 build` output: Shows spinner, captures full log, prints filtered summary (errors-only by default, `--warnings` flag to include warnings), and always reports total error/warning counts and final build status.
- Added flexible argument parsing to `u7` script (e.g., accepts `debug` or `--debug`) and confirmation of effective settings before execution.

**Running & Debugging:**
- Launcher scripts (`scripts/run_u7.sh`, `scripts/run_u7.bat`) called by `u7 run` that handle detecting build type, copying the executable to `Redist/`, and running from the correct directory.
- Health check functionality (`u7 run --debug --healthcheck`) to verify core asset loading without launching the full game.
- Detailed health check status messages and exit codes (0 for success/non-critical errors, 1 for critical failures).

**Logging & Error Handling:**
- ANSI color codes added to console logging (`LoggingCallback`) for improved readability (INFO-Blue, WARN-Yellow, ERROR/FATAL-Red).
- Added `--verbose` flag to `u7 run` command to control log output level (Default: Warnings+, Verbose: Info+). Health check implies verbose.
- Centralized asset error tracking system (`g_AssetLoadErrors`, `AssetLoadError` struct, `AddAssetError` helper) for standardized reporting.

**IDE & Developer Experience:**
- Standardized IDE configuration *templates* (VS Code, CLion) generated via `u7 setup` using scripts in `scripts/setup_ide.*`.
- `.gitignore` updated to ignore common IDE files and standardized build directories.

**Scripting:**
- Refactored Lua C++ function registration (`U7LuaFuncs.cpp`) into a proper Lua module loadable via `require 'U7LuaFuncs'`, fixing script load errors.

**Documentation:**
- This `CHANGELOG.md` file to track changes in the fork.
- Centralized documentation directory (`docs/`). (Note: Original repo had some docs at root).

**Utility Scripts:**
- Added `scripts/check_lua_requires.sh` script to verify and add missing `require "U7LuaFuncs"` to Lua scripts in `Redist/Data/Scripts/`, with interactive confirmation.
- Integrated the check script into the main wrapper via `u7 scripts --fix-requires`.

**New Command:**
- Added `healthcheck` command to `u7` script as a shortcut for `./u7 run --debug --healthcheck`.

### Changed

**Build System:**
- Migrated fully to Meson, removing remnants of CMake or other systems. (Note: Original used Meson but had other files like Makefiles, VS solutions).
- Meson build system now uses `install: true` for the executable target and installs to the standard build directories (`build-*/`), instead of requiring manual copy or custom install targets.

**Workflow:**
- Running the game (`u7 run`) now involves an explicit step of copying the built executable to `Redist/` before execution, ensuring it runs from the location with the necessary data files.
- Project scripts (build, run, setup, etc.) organized into the `scripts/` directory instead of being at the root or elsewhere.

**Error Handling:**
- `LoadCoreGameAssets` now uses the `AddAssetError` system for consistent reporting of issues (file not found, script syntax errors, etc.).
- `LoadCoreGameAssets` differentiates between critical failures (returns `false`, causes health check exit code 1) and non-critical errors like script load failures (logs errors, allows health check exit code 0 if core assets are okay).
- `ScriptingSystem::LoadScript` now returns a boolean and logs errors internally, allowing the calling code (`LoadCoreGameAssets`) to decide if a script load failure is critical.

**Documentation:**
- `README.md` significantly updated to reflect the new `u7` wrapper script workflow, build process, health check, and script locations.

### Removed

- Obsolete build/install mechanisms (e.g., custom Meson `run_target`s like `install_to_redist*`, root-level Makefiles/Justfiles if they existed and were primary).
- Old IDE setup mechanisms (e.g., `ide-config/install.sh`, `ide-config/install.bat`).
- Platform-specific directories from root (e.g., `Linux/`).
- IDE-specific files/directories from version control (e.g., `.vscode/`) in favor of generated configurations via `u7 setup`.

### Fixed

- Health check (`--healthcheck`) now correctly handles missing original U7 data directories (`Data/U7/STATIC`, `Data/U7/GAMEDAT`) without causing a critical failure, allowing checks to pass in CI environments where only local assets are present (Fixes #24).
- Made system library dependencies (`winmm`, `m`, `dl`, `pthread`) explicitly required in `meson.build` for clearer build errors if missing.
- Removed C++20 dependency (`<format>` header) introduced temporarily, improving compatibility with older compilers.
- Resolved Meson deprecation warnings by updating to newer API calls.
- Ensured build configuration enforces a consistent 64-bit architecture across platforms.
- Corrected Lua script loading issues caused by C++ functions not being available via `require` by refactoring to use `luaL_requiref`.
- Iteratively fixed logic in `scripts/check_lua_requires.sh` to correctly handle path detection, duplicate prevention, and reporting for Lua require statements.

## Previous Versions

### Version 1.0.0
- Initial release
