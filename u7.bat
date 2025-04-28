@echo off
REM Main wrapper script for U7Revisited development tasks (Windows)
setlocal enabledelayedexpansion

SET "SCRIPT_DIR=%~dp0"
REM Ensure SCRIPT_DIR ends with a backslash
IF "%SCRIPT_DIR:~-1%" NEQ "\" SET "SCRIPT_DIR=%SCRIPT_DIR%\"
SET "SCRIPTS_SUBDIR=scripts"
SET "SCRIPTS_DIR=%SCRIPT_DIR%%SCRIPTS_SUBDIR%"

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
SET "BUILD_TYPE=debug"
SET "BUILD_ARGS="
SET "RUN_EXTRA_ARGS="
SET "DO_BUILD=false"
SET "DO_CLEAN=false"
SET "DO_CONFIGURE=false"
SET "DO_RUN=false"
SET "DO_SETUP_IDE=false"
SET "COMMAND_GIVEN=false"

REM --- Argument Parsing ---
:ArgLoop
IF "%~1"=="" GOTO ArgsDone

    IF /I "%~1"=="build" (
        SET "DO_BUILD=true"
        SET "COMMAND_GIVEN=true"
        SHIFT
        GOTO ArgLoop
    )
    IF /I "%~1"=="run" (
        SET "DO_RUN=true"
        SET "COMMAND_GIVEN=true"
        SHIFT
        REM Collect remaining arguments for the game
        SET RUN_EXTRA_ARGS=!cmdcmdline:*%1=!
        GOTO ArgsDone
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
    IF /I "%~1"=="--release" (
        SET "BUILD_TYPE=release"
        SET "BUILD_ARGS=%BUILD_ARGS% --release"
        SHIFT
        GOTO ArgLoop
    )
    IF /I "%~1"=="-h" GOTO Help
    IF /I "%~1"=="--help" GOTO Help

    REM Handle -- separator for game args
    IF "%~1"=="--" (
        SHIFT
        SET RUN_EXTRA_ARGS=!cmdcmdline:*-- =!
        GOTO ArgsDone
    )

    REM Unknown argument handling
    IF "%COMMAND_GIVEN%"=="false" (
        call :print_error "Unknown command or option: %1. Commands must come before options like --release."
        exit /b 1
    ) ELSE (
        call :print_error "Unknown argument: %1. Did you mean to put it after '--' for the 'run' command?"
        exit /b 1
    )
    SHIFT
    GOTO ArgLoop

:Help
    echo Usage: %~nx0 [command...] [options...] [-- game_args...]
    echo.
    echo Commands:
    echo   build         Build the project (default: debug).
    echo   run           Run the project (builds first if needed, default: debug).
    echo   clean         Clean the build directory for the selected type.
    echo   configure     Force configure before build.
    echo   setup         Run the IDE setup script (Windows).
    echo.
    echo Options:
    echo   --release     Perform actions for the release build type.
    echo   -h, --help    Show this help message.
    echo.
    echo Examples:
    echo   %~nx0 build                # Build debug
    echo   %~nx0 build --release      # Build release
    echo   %~nx0 run                  # Build (if needed) and run debug
    echo   %~nx0 clean build --release # Clean release, then build release
    echo   %~nx0 run -- --some-game-flag # Run debug, passing flag to game
    echo   %~nx0 setup                # Generate IDE config files (Windows)
    exit /b 0

:ArgsDone

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

REM Handle build dependencies
IF "%DO_CLEAN%"=="true" (
    SET "BUILD_ARGS=%BUILD_ARGS% --clean"
)
IF "%DO_CONFIGURE%"=="true" (
     SET "BUILD_ARGS=%BUILD_ARGS% --configure"
)

REM Build (if build cmd or run cmd was specified, and not only setup)
SET "BUILD_NEEDED=false"
IF "%DO_BUILD%"=="true" SET "BUILD_NEEDED=true"
IF "%DO_RUN%"=="true" SET "BUILD_NEEDED=true"

SET "BUILD_SCRIPT=%SCRIPTS_DIR%\build.bat"

REM Logic to prevent setup-only triggering build
SET "SKIP_BUILD=false"
IF "%DO_SETUP_IDE%"=="true" (
    IF "%COMMAND_GIVEN%"=="true" (
        IF "%DO_BUILD%"=="false" IF "%DO_RUN%"=="false" IF "%DO_CLEAN%"=="false" IF "%DO_CONFIGURE%"=="false" (
            SET "SKIP_BUILD=true"
        )
    )
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

REM Run
IF "%DO_RUN%"=="true" (
    call :print_header "Run (%BUILD_TYPE%)"
    SET "RUN_SCRIPT=%SCRIPTS_DIR%\run_u7.bat"
    SET "RUN_FLAGS="
    IF /I "%BUILD_TYPE%"=="debug" (
        SET "RUN_FLAGS=--debug %RUN_EXTRA_ARGS%"
    ) ELSE (
        SET "RUN_FLAGS=%RUN_EXTRA_ARGS%"
    )

    IF EXIST "%RUN_SCRIPT%" (
         echo --^> Running execution script: %RUN_SCRIPT% %RUN_FLAGS%
         call "%RUN_SCRIPT%" %RUN_FLAGS%
         SET RUN_EXIT_CODE=!ERRORLEVEL!
         IF !RUN_EXIT_CODE! NEQ 0 (
             echo [U7 INFO] Game process exited with code !RUN_EXIT_CODE!.
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