# Changelog

All notable changes to the Ultima VII: Revisited project from this fork will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Standardized IDE configuration *templates* (VS Code, JetBrains, NetBeans) in `ide-config/` directory.
- `.gitignore` entries to ignore IDE-specific directories while tracking `ide-config/`.
- Build system migrated to Meson from CMake.
- Separate debug and release build configurations using Meson build types (`-Dbuildtype=debug|release`).
- Launcher scripts (`run_u7.sh`, `run_u7.bat`) that detect and run the appropriate build type (`_debug` or `_release`) from the build directory (`build-debug/bin` or `build-release/bin`).
- Enforced 64-bit architecture requirement in the build system.
- Unified wrapper script (`u7`, `u7.bat`) for common dev tasks (build, run, clean, setup).
- Build scripts (`scripts/build.sh`, `scripts/build.bat`) called by the wrapper.
- IDE setup scripts (`scripts/setup_ide.sh`, `scripts/setup_ide.bat`) called by the wrapper.
- Helper scripts for CLion setup (`scripts/copy_executable.sh`, `scripts/copy_executable.bat`).

### Changed
- Build system uses standard Meson build directories (`build-debug/`, `build-release/`) instead of copying artifacts to source `Redist/`.
- Launcher scripts (`run_u7.sh`, `run_u7.bat`) now change to the project root directory before execution to ensure correct asset loading.
- Meson build system uses `install: true` for the executable target.
- Build, Run, Setup, and Helper scripts moved into the `scripts/` directory.
- `run_u7.sh`/`.bat` scripts now copy the executable to `Redist/` before running, and execute from within `Redist/`.
- README updated to reflect the new `u7` wrapper script workflow and script locations.

### Removed
- Obsolete custom Meson `run_target`s for installation (`install_to_redist*`).
- Installation scripts (`ide-config/install.sh`, `ide-config/install.bat`) for copying IDE configurations.
- Removed Linux-specific NetBeans configuration files (Linux directory) as they're no longer needed with the Meson build system.
- Removed IDE-specific .vscode directory from version control in favor of standardized ide-config directory.

### Fixed
- Made system library dependencies (`winmm`, `m`, `dl`, `pthread`) required in `meson.build` for clearer errors.
- Removed C++20 dependency (`<format>` header) for better compiler compatibility.
- Fixed Meson deprecation warnings by updating to the newer API.
- Build configuration ensures consistent 64-bit architecture across platforms.

## Previous Versions

### Version 1.0.0
- Initial release
