@echo off
REM Helper script for IDEs (like CLion) to copy the correct executable to Redist before launch (Windows)
setlocal enabledelayedexpansion

SET "HELPER_SCRIPT_DIR=%~dp0"
REM Ensure HELPER_SCRIPT_DIR ends with a backslash
IF "%HELPER_SCRIPT_DIR:~-1%" NEQ "\" SET "HELPER_SCRIPT_DIR=%HELPER_SCRIPT_DIR%\"
SET "PROJECT_ROOT=%HELPER_SCRIPT_DIR%..\"

SET "BUILD_DIR_DEBUG=%PROJECT_ROOT%build-debug"
SET "BUILD_DIR_RELEASE=%PROJECT_ROOT%build-release"
SET "REDIST_DIR=%PROJECT_ROOT%Redist"

REM Assume Meson installs targets to install_prefix/bin like on Linux
REM Adjust this if Meson install behaves differently on Windows
SET "INSTALL_SUBDIR=install_prefix\bin"
SET "SOURCE_DEBUG_PATH=%BUILD_DIR_DEBUG%\%INSTALL_SUBDIR%\U7Revisited_debug.exe"
SET "SOURCE_RELEASE_PATH=%BUILD_DIR_RELEASE%\%INSTALL_SUBDIR%\U7Revisited_release.exe"

SET "TARGET_DEBUG_PATH=%REDIST_DIR%\U7Revisited_debug.exe"
SET "TARGET_RELEASE_PATH=%REDIST_DIR%\U7Revisited_release.exe"

SET "SOURCE_PATH="
SET "TARGET_PATH="

IF /I "%~1"=="--debug" (
    SET "SOURCE_PATH=%SOURCE_DEBUG_PATH%"
    SET "TARGET_PATH=%TARGET_DEBUG_PATH%"
) ELSE (
    REM Default to release
    SET "SOURCE_PATH=%SOURCE_RELEASE_PATH%"
    SET "TARGET_PATH=%TARGET_RELEASE_PATH%"
)

REM Create Redist directory if it doesn't exist
IF NOT EXIST "%REDIST_DIR%\" (
    echo IDE Helper: Creating directory %REDIST_DIR%...
    mkdir "%REDIST_DIR%"
    IF !ERRORLEVEL! NEQ 0 (
        echo Error (Helper Script): Failed to create directory %REDIST_DIR% >&2
        exit /b 1
    )
)

REM Check if source exists before copying
IF "%SOURCE_PATH%"=="" (
    echo Error (Helper Script): Source path variable is empty. Argument was: %1 >&2
    exit /b 1
)
IF NOT EXIST "%SOURCE_PATH%" (
    echo Error (Helper Script): Source executable for copy not found at %SOURCE_PATH% >&2
    echo Note: Assumed install path is build-type\%INSTALL_SUBDIR% >&2
    exit /b 1
)

echo IDE Helper: Copying %SOURCE_PATH% to %TARGET_PATH%...
copy /Y "%SOURCE_PATH%" "%TARGET_PATH%" > nul
IF !ERRORLEVEL! NEQ 0 (
    echo Error (Helper Script): Failed to copy executable. >&2
    exit /b 1
)

echo IDE Helper: Copy successful.
exit /b 0 