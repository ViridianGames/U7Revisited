@echo off
REM Main wrapper script for U7Revisited development tasks (Windows)
setlocal enabledelayedexpansion

SET "SCRIPT_DIR=%~dp0"
REM Ensure SCRIPT_DIR ends with a backslash
IF "%SCRIPT_DIR:~-1%" NEQ "\" SET "SCRIPT_DIR=%SCRIPT_DIR%\"
SET "SCRIPTS_SUBDIR=scripts"
SET "SCRIPTS_DIR=%SCRIPT_DIR%%SCRIPTS_SUBDIR%"

REM --- Colors (Basic - might not work everywhere) ---
REM Using 'echo' with escapes is unreliable. Use 'powershell' for better color.
REM Fallback: No color.

REM --- Helper Function (simulated) ---
:print_header
    echo.
    echo ==================================================
    echo   U7Revisited Task: %~1
    echo ==================================================
    GOTO :EOF

:print_footer
    echo ==================================================
    echo   Task Finished
    echo ==================================================
    echo.
    GOTO :EOF

:print_error
    echo [U7 ERROR] %~1 >&2
    GOTO :EOF

REM --- Check for scripts directory ---
IF NOT EXIST "%SCRIPTS_DIR%\" (
    call :print_error "Scripts directory '%SCRIPTS_DIR%' not found!"
    exit /b 1
)

REM --- Default values ---
SET "BUILD_TYPE=release"
SET "BUILD_ARGS="
SET "RUN_EXTRA_ARGS="
SET "DO_BUILD=false"
SET "DO_CLEAN=false"
SET "DO_CONFIGURE=false"
SET "DO_RUN=false"
SET "DO_SETUP_IDE=false"
SET "DO_HEALTHCHECK=false"
SET "DO_FIX_REQUIRES=false"
SET "SHOW_WARNINGS=false"
SET "COMMAND_GIVEN=false"
SET "RUN_ARGS_STARTED=false"

REM --- Argument Parsing (Simplified - order matters more than Linux) ---
:ArgLoop
IF "%~1"=="" GOTO ArgsDone

    IF "%RUN_ARGS_STARTED%"=="true" (
        REM Collect remaining arguments for the game
        SET RUN_EXTRA_ARGS=!RUN_EXTRA_ARGS! %1
        SHIFT
        GOTO ArgLoop
    )

    IF /I "%~1"=="build" (
        SET "DO_BUILD=true"
        SET "COMMAND_GIVEN=true"
        SHIFT
        GOTO ArgLoop
    )
    IF /I "%~1"=="run" (
        SET "DO_RUN=true"
        SET "COMMAND_GIVEN=true"
        SET "RUN_ARGS_STARTED=true" REM Start collecting game args
        SHIFT
        GOTO ArgLoop
    )
    IF /I "%~1"=="clean" (
        SET "DO_CLEAN=true"
        SET "COMMAND_GIVEN=true"
        SHIFT
        GOTO ArgLoop
    )
    IF /I "%~1"=="configure" (
        SET "DO_CONFIGURE=true"
        SET "COMMAND_GIVEN=true"
        SHIFT
        GOTO ArgLoop
    )
    IF /I "%~1"=="setup" (
        SET "DO_SETUP_IDE=true"
        SET "COMMAND_GIVEN=true"
        SHIFT
        GOTO ArgLoop
    )
    IF /I "%~1"=="healthcheck" (
        SET "DO_HEALTHCHECK=true"
        SET "COMMAND_GIVEN=true"
        SET "BUILD_TYPE=debug" REM Healthcheck implies debug
        SHIFT
        GOTO ArgLoop
    )
    IF /I "%~1"=="scripts" (
        SET "COMMAND_GIVEN=true"
        SHIFT
        IF /I "%~1"=="--fix-requires" (
            SET "DO_FIX_REQUIRES=true"
        ) ELSE (
            call :print_error "Unknown scripts command: %1. Available: --fix-requires"
            exit /b 1
        )
        SHIFT
        GOTO ArgLoop
    )
    IF /I "%~1"=="--debug" (
        SET "BUILD_TYPE=debug"
        SHIFT
        GOTO ArgLoop
    )
    IF /I "%~1"=="debug" (
        SET "BUILD_TYPE=debug"
        SHIFT
        GOTO ArgLoop
    )
    IF /I "%~1"=="--release" (
        SET "BUILD_TYPE=release"
        SHIFT
        GOTO ArgLoop
    )
    IF /I "%~1"=="release" (
        SET "BUILD_TYPE=release"
        SHIFT
        GOTO ArgLoop
    )
    IF /I "%~1"=="--warnings" (
        SET "SHOW_WARNINGS=true"
        SHIFT
        GOTO ArgLoop
    )
    IF /I "%~1"=="warnings" (
        SET "SHOW_WARNINGS=true"
        SHIFT
        GOTO ArgLoop
    )
    IF /I "%~1"=="-h" GOTO Help
    IF /I "%~1"=="--help" GOTO Help

    REM Handle -- separator for game args
    IF "%~1"=="--" (
        SET "RUN_ARGS_STARTED=true"
        SHIFT
        GOTO ArgLoop
    )

    call :print_error "Unknown command or option: %1"
    exit /b 1
    SHIFT
    GOTO ArgLoop

:Help
    echo Usage: %~nx0 [command...] [options...] [-- game_args...]
    echo.
    echo Commands:
    echo   build           Build the project (default: release).
    echo   run             Run the project (builds first if needed, default: release).
    echo   clean           Clean the build directory for the selected type.
    echo   configure       Force configure before build.
    echo   setup           Run the IDE setup script (Windows).
    echo   healthcheck     Run the asset loading health check (implies --debug).
    echo   scripts         Run utility scripts:
    echo     --fix-requires  Check/fix Lua requires (NOT YET IMPLEMENTED for Windows).
    echo.
    echo Options:
    echo   --debug         Perform actions for the debug build type.
    echo   --release       Perform actions for the release build type (default).
    echo   --warnings      Show compiler warnings in the build summary.
    echo   -h, --help      Show this help message.
    echo.
    echo Examples:
    echo   %~nx0 build                # Build release (default)
    echo   %~nx0 build --debug        # Build debug
    echo   %~nx0 run                  # Build (if needed) and run release
    echo   %~nx0 clean build --debug  # Clean debug, then build debug
    echo   %~nx0 run -- --some-game-flag # Run release, passing flag to game
    echo   %~nx0 setup                # Generate IDE config files (Windows)
    echo   %~nx0 healthcheck          # Run health check (debug)
    exit /b 0

:ArgsDone

REM --- Report Effective Settings --- START
IF "%COMMAND_GIVEN%"=="true" (
    echo --- Effective Settings ---
    echo   Build Type:    %BUILD_TYPE%
    echo   Show Warnings: %SHOW_WARNINGS%
    IF "%DO_CLEAN%"=="true" echo   Clean Target:  true
    IF "%DO_CONFIGURE%"=="true" echo   Configure:     true
    echo --------------------------
)
REM --- Report Effective Settings --- END

REM --- Execute Tasks ---

REM Setup IDE
IF "%DO_SETUP_IDE%"=="true" (
    call :print_header "IDE Setup (Windows)"
    SET "SETUP_SCRIPT=%SCRIPTS_DIR%\setup_ide.bat"
    IF EXIST "%SETUP_SCRIPT%" (
        echo --^> Running IDE setup script...
        call "%SETUP_SCRIPT%"
        IF !ERRORLEVEL! NEQ 0 (
            call :print_error "IDE setup script failed with exit code !ERRORLEVEL!."
            exit /b 1
        )
        call :print_footer
    ) ELSE (
        call :print_error "Setup script not found: %SETUP_SCRIPT%"
        exit /b 1
    )
)

REM Fix Lua Requires
IF "%DO_FIX_REQUIRES%"=="true" (
    call :print_header "Fix Lua Requires (Windows)"
    SET "FIX_SCRIPT=%SCRIPTS_DIR%\check_lua_requires.bat"
    IF EXIST "%FIX_SCRIPT%" (
        echo --^> Running Lua require check script (Windows)...
        call "%FIX_SCRIPT%"
        IF !ERRORLEVEL! NEQ 0 (
            call :print_error "Lua require check script failed or not implemented."
            REM Do not exit, just warn
        )
        call :print_footer
    ) ELSE (
        call :print_error "Lua require check script not found or not implemented: %FIX_SCRIPT%"
        REM Do not exit, just warn
    )
)

REM Build Dependencies
SET "BUILD_EXTRA="
IF "%DO_CLEAN%"=="true" SET "BUILD_EXTRA=%BUILD_EXTRA% --clean"
IF "%DO_CONFIGURE%"=="true" SET "BUILD_EXTRA=%BUILD_EXTRA% --configure"
IF "%SHOW_WARNINGS%"=="true" SET "BUILD_EXTRA=%BUILD_EXTRA% --warnings"
IF /I "%BUILD_TYPE%"=="debug" SET "BUILD_ARGS=--debug %BUILD_EXTRA%"
IF /I "%BUILD_TYPE%"=="release" SET "BUILD_ARGS=%BUILD_EXTRA%"

REM Build
SET "BUILD_NEEDED=false"
IF "%DO_BUILD%"=="true" SET "BUILD_NEEDED=true"
IF "%DO_RUN%"=="true" SET "BUILD_NEEDED=true"
IF "%DO_HEALTHCHECK%"=="true" SET "BUILD_NEEDED=true"

SET "BUILD_SCRIPT=%SCRIPTS_DIR%\build.bat"

REM Logic to prevent build if only setup/scripts was called
SET "SKIP_BUILD=false"
IF "%COMMAND_GIVEN%"=="true" (
    SET ONLY_NON_BUILD_COMMAND=true
    IF "%DO_BUILD%"=="true" SET ONLY_NON_BUILD_COMMAND=false
    IF "%DO_RUN%"=="true" SET ONLY_NON_BUILD_COMMAND=false
    IF "%DO_HEALTHCHECK%"=="true" SET ONLY_NON_BUILD_COMMAND=false
    IF "%DO_CLEAN%"=="true" SET ONLY_NON_BUILD_COMMAND=false
    IF "%DO_CONFIGURE%"=="true" SET ONLY_NON_BUILD_COMMAND=false
    IF "%DO_SETUP_IDE%"=="false" IF "%DO_FIX_REQUIRES%"=="false" SET ONLY_NON_BUILD_COMMAND=false

    IF "%ONLY_NON_BUILD_COMMAND%"=="true" SET "SKIP_BUILD=true"
)

IF "%BUILD_NEEDED%"=="true" IF "%SKIP_BUILD%"=="false" (
    call :print_header "Build (%BUILD_TYPE%)"
    IF EXIST "%BUILD_SCRIPT%" (
        echo --^> Running build script: %BUILD_SCRIPT% %BUILD_ARGS%
         call "%BUILD_SCRIPT%" %BUILD_ARGS%
         IF !ERRORLEVEL! NEQ 0 (
             call :print_error "Build script failed with exit code !ERRORLEVEL!."
             exit /b 1
         )
        call :print_footer
    ) ELSE (
        call :print_error "Build script not found: %BUILD_SCRIPT%"
        exit /b 1
    )
)

REM Run / Healthcheck
IF "%DO_RUN%"=="true" OR "%DO_HEALTHCHECK%"=="true" (
    SET "RUN_HEADER="
    SET "RUN_FLAGS="
    IF "%DO_HEALTHCHECK%"=="true" (
        SET "RUN_HEADER=Health Check"
        SET "RUN_FLAGS=--healthcheck"
    ) ELSE (
        SET "RUN_HEADER=Run (%BUILD_TYPE%)"
        IF /I "%BUILD_TYPE%"=="debug" SET "RUN_FLAGS=%RUN_FLAGS% --debug"
        REM Add collected game args
        SET "RUN_FLAGS=%RUN_FLAGS% %RUN_EXTRA_ARGS%"
    )
    call :print_header "%RUN_HEADER%"
    SET "RUN_SCRIPT=%SCRIPTS_DIR%\run_u7.bat"

    IF EXIST "%RUN_SCRIPT%" (
         echo --^> Running execution script: %RUN_SCRIPT% %RUN_FLAGS%
         call "%RUN_SCRIPT%" %RUN_FLAGS%
         SET RUN_EXIT_CODE=!ERRORLEVEL!
         IF !RUN_EXIT_CODE! NEQ 0 (
             echo [U7 INFO] Process exited with code !RUN_EXIT_CODE!.
         )
         call :print_footer
    ) ELSE (
         call :print_error "Run script not found: %RUN_SCRIPT%"
         exit /b 1
    )
)

REM If no command was given, show help implicitly.
IF "%COMMAND_GIVEN%"=="false" (
    call :Help
    exit /b 1
)

endlocal
exit /b 0 