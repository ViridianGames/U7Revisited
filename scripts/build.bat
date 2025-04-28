@echo off
REM Simple build script for U7Revisited using Meson (Windows)
setlocal enabledelayedexpansion

SET "SCRIPT_DIR=%~dp0"
REM Ensure SCRIPT_DIR ends with a backslash for reliable path joining
IF "%SCRIPT_DIR:~-1%" NEQ "\" SET "SCRIPT_DIR=%SCRIPT_DIR%\"
SET "PROJECT_ROOT=%SCRIPT_DIR%..\"

SET "BUILD_TYPE=debug"
SET "BUILD_DIR=%PROJECT_ROOT%build-debug"
SET "SHOULD_CONFIGURE=false"
SET "SHOULD_CLEAN=false"
SET "SHOULD_RUN=false"
SET "RUN_ARGS="
SET "EXTRA_MESON_ARGS="

REM --- Argument Parsing ---
REM Batch argument parsing is less elegant than bash
:ArgLoop
IF "%~1"=="" GOTO ArgsDone

IF /I "%~1"=="--release" (
    SET "BUILD_TYPE=release"
    SET "BUILD_DIR=%PROJECT_ROOT%build-release"
    SHIFT
    GOTO ArgLoop
)
IF /I "%~1"=="--configure" (
    SET "SHOULD_CONFIGURE=true"
    SHIFT
    GOTO ArgLoop
)
IF /I "%~1"=="--clean" (
    SET "SHOULD_CLEAN=true"
    SHIFT
    GOTO ArgLoop
)
IF /I "%~1"=="--run" (
    SET "SHOULD_RUN=true"
    SHIFT
    REM Collect remaining arguments for run_u7.bat
    SET RUN_ARGS=!cmdcmdline:*--run =!
    GOTO ArgsDone
)
IF /I "%~1"=="-h" GOTO Help
IF /I "%~1"=="--help" GOTO Help

REM Check for -D or -C arguments
echo "%~1" | findstr /B /C:"-D" > nul
IF !ERRORLEVEL! == 0 (
    SET "EXTRA_MESON_ARGS=!EXTRA_MESON_ARGS! %1"
    SHIFT
    GOTO ArgLoop
)
echo "%~1" | findstr /B /C:"-C" > nul
IF !ERRORLEVEL! == 0 (
    SET "EXTRA_MESON_ARGS=!EXTRA_MESON_ARGS! %1"
    SHIFT
    GOTO ArgLoop
)

REM Treat unknown as potential run args if --run hasn't been seen (this is imperfect)
REM A robust solution would require more complex parsing
echo Warning: Unknown or misplaced argument: %1
SHIFT
GOTO ArgLoop

:Help
echo Usage: %~nx0 [--release] [--configure] [--clean] [--run] [-Doption=value...] [run_script_args...]
echo   --release    : Build the release version (default: debug)
echo   --configure  : Force run 'meson setup' even if build dir exists
echo   --clean      : Remove the build directory before building
echo   --run        : Run the project using run_u7.bat after building
echo   -D.../-C...  : Pass arguments directly to 'meson setup'
echo   run_script_args: Arguments passed to run_u7.bat when using --run
exit /b 0

:ArgsDone

echo --- Building U7Revisited (%BUILD_TYPE%) ---

REM --- Clean ---
IF "%SHOULD_CLEAN%"=="true" (
    IF EXIST "%BUILD_DIR%\" (
        echo [Clean] Removing build directory: %BUILD_DIR%...
        rmdir /S /Q "%BUILD_DIR%"
        IF !ERRORLEVEL! NEQ 0 (
            echo [Clean] Error: Failed to remove directory %BUILD_DIR% >&2
            exit /b 1
        )
        echo [Clean] Directory removed.
        SET "SHOULD_CONFIGURE=true"
    ) ELSE (
        echo [Clean] Build directory %BUILD_DIR% not found. Skipping removal.
    )
)

REM --- Configure ---
SET "DO_SETUP=false"
IF "%SHOULD_CONFIGURE%"=="true" (
    SET "DO_SETUP=true"
) ELSE (
    IF NOT EXIST "%BUILD_DIR%\meson-private\coredata.dat" (
        SET "DO_SETUP=true"
    )
)

IF "%DO_SETUP%"=="true" (
    echo [Configure] Configuring (%BUILD_TYPE%) in %BUILD_DIR%...
    REM Check if Meson exists
    where meson > nul 2> nul
    IF !ERRORLEVEL! NEQ 0 (
        echo [Configure] Error: 'meson' command not found in PATH. Please install Meson and ensure it's in your PATH. >&2
        exit /b 1
    )
    meson setup "%BUILD_DIR%" --buildtype="%BUILD_TYPE%" %EXTRA_MESON_ARGS%
    IF !ERRORLEVEL! NEQ 0 (
        echo [Configure] Error: Meson setup failed! >&2
        exit /b 1
    )
    echo [Configure] Meson setup complete.
) ELSE (
     IF NOT "%EXTRA_MESON_ARGS%"=="" (
         echo [Configure] Reconfiguring (%BUILD_TYPE%) in %BUILD_DIR% due to extra args...
         meson configure "%BUILD_DIR%" %EXTRA_MESON_ARGS%
          IF !ERRORLEVEL! NEQ 0 (
            echo [Configure] Error: Meson configure failed! >&2
            exit /b 1
          )
     ) ELSE (
        echo [Configure] Build directory %BUILD_DIR% already configured. Skipping setup. Use --configure to force.
     )
)


REM --- Compile ---
echo [Compile] Compiling (%BUILD_TYPE%) in %BUILD_DIR%...
meson compile -C "%BUILD_DIR%"
IF !ERRORLEVEL! NEQ 0 (
    echo [Compile] Error: Meson compile failed! >&2
    exit /b 1
)
echo [Compile] Meson compile successful.

echo --- Build successful (%BUILD_TYPE%) ---

REM --- Run ---
IF "%SHOULD_RUN%"=="true" (
    echo.
    echo --- Running (%BUILD_TYPE%) ---
    SET "RUN_CMD=run_u7.bat"
    SET "RUN_SCRIPT_PATH=%SCRIPT_DIR%%RUN_CMD%"
    SET "FINAL_RUN_ARGS="

    IF "%BUILD_TYPE%"=="debug" (
        SET "FINAL_RUN_ARGS=--debug %RUN_ARGS%"
    ) ELSE (
        SET "FINAL_RUN_ARGS=%RUN_ARGS%"
    )

    IF NOT EXIST "%RUN_SCRIPT_PATH%" (
        echo [Run] Error: %RUN_CMD% not found in %SCRIPT_DIR%. >&2
        exit /b 1
    )

    echo [Run] Executing: %RUN_SCRIPT_PATH% %FINAL_RUN_ARGS%
    call "%RUN_SCRIPT_PATH%" %FINAL_RUN_ARGS%
    SET RUN_EXIT_CODE=!ERRORLEVEL!
    IF !RUN_EXIT_CODE! NEQ 0 (
        echo [Run] Process exited with code !RUN_EXIT_CODE!. >&2
        echo --- Run failed ---
        exit /b 1
    )
    echo --- Run finished ---
)

exit /b 0 