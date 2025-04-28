# Ultima VII: Revisited (unoften)

You're at the unoften Ultima VII: Revisited fork, created to contribute improvements and features to the main project. 
Like the Guardian's beacon that called the Avatar to Britannia, this repository calls forth contributors to enhance 
the legacy of this legendary RPG through a modern replacement engine.

## Installation and Building

### Prerequisites

- C++17 compatible compiler (e.g., GCC, Clang, MSVC)
- Meson build system (version 0.60 or newer recommended)
- Ninja build tool (usually installed with Meson)
- Git (for cloning the repository)
- Original Ultima VII game data files (The Black Gate, Forge of Virtue recommended)
- Bash (for Linux/macOS scripts) or CMD/PowerShell (for Windows `.bat` scripts)

### Recommended Workflow using the `u7` Script

The easiest way to manage common development tasks (build, run, clean, IDE setup) is using the unified wrapper script `u7` (Linux/macOS) or `u7.bat` (Windows) located in the project root.

**Argument Flexibility:** Commands (`build`, `clean`, `setup`, `scripts`) and options (`debug`, `release`, `warnings`) can generally be specified in any order before the `run` command or the `--` separator for game arguments. Options can be provided with or without leading `--` (e.g., `debug` is the same as `--debug`). The script will print the effective settings before executing tasks.

1.  **Initial IDE Setup (One Time):**
    *   After cloning, run the IDE setup script:
        *   Linux/macOS: `./u7 setup`
        *   Windows: `.\\u7.bat setup`
    *   This generates standard configuration files for VS Code and CLion (see `scripts/setup_ide.sh` and `scripts/setup_ide.bat` for details) and provides instructions for other IDEs.
    *   **Important CLion Note:** After running the setup, you still need to manually set the 'Working Directory' in the generated `U7_Debug*` and `U7_Release*` configurations to `${PROJECT_DIR}/Redist`.

2.  **Building:**
    *   Build Release (Default): `./u7 build` or `.\\u7.bat build`
    *   Build Debug: `./u7 build --debug` or `.\\u7.bat build --debug`
    *   Clean & Build Release: `./u7 clean build` or `.\\u7.bat clean build`
    *   Clean & Build Debug: `./u7 clean build --debug` or `.\\u7.bat clean build --debug`
    *   Build Release & Show Warnings: `./u7 build --warnings` or `.\\u7.bat build --warnings`
    *   **Build Output:** The build command shows a progress spinner. After completion, it prints a summary of errors (default) or errors and warnings (`--warnings`). It always reports the total counts and final build status.

3.  **Running:**
    *   Ensure original game data is copied to `Redist/Data/U7/` (see "Important Data Files Setup" below).
    *   Run Release (Default - builds first if needed): `./u7 run` or `.\\u7.bat run`
    *   Run Debug (builds first if needed): `./u7 run --debug` or `.\\u7.bat run --debug`
    *   Run Quietly (Default): Logging shows Warnings/Errors only.
    *   Run Verbosely: `./u7 run --verbose` or `./u7 run --debug --verbose` (Shows INFO level logs during loading)
    *   Run Release with game arguments: `./u7 run -- --some-game-flag` or `.\\u7.bat run -- --some-game-flag`
    *   Run Debug with game arguments: `./u7 run --debug -- --some-game-flag` or `.\\u7.bat run --debug -- --some-game-flag`
    *   **Running the Health Check:**
        *   Use `./u7 run --debug --healthcheck` or `.\\u7.bat run --debug --healthcheck` (Health check always runs verbosely)
        *   This performs essential asset loading checks without launching the full game.
        *   Output is color-coded: **Blue** for INFO, **Yellow** for WARN, **Red** for ERROR.
        *   If it exits with code 0 and message "Health check finished successfully.", all core assets loaded without issues.
        *   If it exits with code 0 and message "Health check finished with NON-CRITICAL errors...", core assets loaded, but some issues (like script errors) were detected and logged.
        *   If it exits with code 1, critical assets failed to load.

4.  **Cleaning:**
    *   Clean Release build directory (Default): `./u7 clean` or `.\\u7.bat clean`
    *   Clean Debug build directory: `./u7 clean --debug` or `.\\u7.bat clean --debug`

5.  **Utility Scripts:**
    *   Check and fix missing Lua requires: `./u7 scripts --fix-requires`

For more options, run `./u7 --help` or `.\\u7.bat --help`.

The `u7` script calls other helper scripts (`build.*`, `run_u7.*`, `setup_ide.*`, `copy_executable.*`) located in the `scripts/` directory.

### Manual Building with Meson (Alternative)

If you prefer not to use the `u7` wrapper script, you can use Meson directly.

1.  **Configure (choose one):**
    *   **Debug Build:**
        ```bash
        meson setup build-debug --buildtype=debug
        ```
    *   **Release Build:**
        ```bash
        meson setup build-release --buildtype=release
        ```

2.  **Compile:**
    *   Compile the configured build type:
        ```bash
        meson compile -C build-debug
        # or
        meson compile -C build-release
        ```

The compiled executable will be located in `build-<type>/install_prefix/bin/` (e.g., `build-debug/install_prefix/bin/U7Revisited_debug`).

### Running the Game Manually

**Important Data Files Setup:**
1.  Ensure you have legally obtained the original Ultima VII game files.
2.  Copy the *contents* of your original DOS `ULTIMA7` game data folder into the `Redist/Data/U7/` directory within this project.
3.  This must include the original game files (STATIC, GAMEDAT, etc.) required by the engine.
4.  The engine currently supports The Black Gate and data from Forge of Virtue.

**Run using the Individual Launcher Scripts:**

If building manually, use the provided scripts in the `scripts/` directory. They copy the executable to the `Redist/` directory and run it from there.

*   **On Linux/macOS:**
    ```bash
    ./scripts/run_u7.sh          # Runs Release build by default
    ./scripts/run_u7.sh --debug  # Runs Debug build
    ```
*   **On Windows:**
    ```bash
    .\\scripts\\run_u7.bat         # Runs Release build by default
    .\\scripts\\run_u7.bat --debug # Runs Debug build
    ```

## Developer Installation Notes

- Follow the **Recommended Workflow using the `u7` Script** section above.
- Ensure the original game data is copied to `Redist/Data/U7/` as described.
- The `u7 setup` command helps configure common IDEs.

## IDE Setup

Using the `u7 setup` or `u7.bat setup` command (see "Recommended Workflow") is the preferred method for configuring common IDEs (VS Code, CLion) automatically.

If setting up manually or using another IDE:

1.  **Open the Project:** Open the project's root folder.
2.  **Build System:** Ensure your IDE integrates with Meson or can run the `./build.sh` / `.\\build.bat` script.
3.  **Run/Debug Configuration:**
    *   Configure your IDE to execute the `./scripts/run_u7.sh` (Linux/macOS) or `.\\scripts\\run_u7.bat` (Windows) script.
    *   Pass `--debug` as an argument to the script for debug builds.
    *   Set the **Working Directory** for the script execution to the project's root directory (the directory containing this README). The `run_u7.*` script handles changing into the `Redist` directory internally.

## Documentation

Project-specific documentation can be found in the `docs/` directory:

*   `docs/CODING_STANDARDS.md`: Guidelines for writing code in this project.
*   `docs/MODELING_GUIDE.md`: Information on 3D model requirements and integration.
*   `docs/ROADMAP.md`: Overview of planned features and development direction.

## Controls:

- `WASD`:  Move around.
- `Q/E`:  Rotate left and right.
- `Mousewheel`:  Zoom in/Zoom out.
- To teleport to a location, left-click there in the minimap.
- Press `ESC` to exit.

## Feedback

For feedback about this fork and contributions, please open an issue in this repository.

## Original Project Information

This is an open source project based on the work from [github.com/viridiangames](https://github.com/viridiangames).

The original author, Anthony Salter, welcomes feedback at anthony.salter@gmail.com with `Revisited` in the subject line.

**From the original README:** "FEEDBACK IS WELCOME BOY HOWDY IS IT WELCOME!"

Have fun, and Rule Britannia.

## Legal Disclaimers

Ultima VII: The Black Gate and any associated trademarks and copyrights are property of Electronic Arts Inc. This project is a non-commercial fan-made engine replacement, and is not affiliated with or endorsed by Electronic Arts.

This project does not include any original game content. To use this software, you must legally own a copy of Ultima VII: The Black Gate.

The U7Revisited engine code is provided under the BSD 2-Clause License as detailed in the [LICENSE] file.

This project is made by fans, for fans, to preserve and enhance the legacy of Ultima VII for future generations.
