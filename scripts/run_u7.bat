@echo off
REM Script to run the appropriate version of U7Revisited (debug or release)
REM Copies the executable to Redist/ before running it.

SET "SCRIPT_DIR=%~dp0"
REM Ensure SCRIPT_DIR ends with a backslash for reliable path joining
IF "%SCRIPT_DIR:~-1%" NEQ "\" SET "SCRIPT_DIR=%SCRIPT_DIR%\"
SET "PROJECT_ROOT=%SCRIPT_DIR%..\"

SET "BUILD_DIR_DEBUG=%PROJECT_ROOT%build-debug"
SET "BUILD_DIR_RELEASE=%PROJECT_ROOT%build-release"
SET "REDIST_DIR=%PROJECT_ROOT%Redist"

REM Source paths directly within the build directory
SET "SOURCE_DEBUG_PATH=%BUILD_DIR_DEBUG%\U7Revisited_debug.exe"
SET "SOURCE_RELEASE_PATH=%BUILD_DIR_RELEASE%\U7Revisited_release.exe"

REM Target paths within Redist
SET TARGET_DEBUG_EXE=U7Revisited_debug.exe
SET TARGET_RELEASE_EXE=U7Revisited_release.exe
SET TARGET_DEBUG_PATH=%REDIST_DIR%\%TARGET_DEBUG_EXE%
SET TARGET_RELEASE_PATH=%REDIST_DIR%\%TARGET_RELEASE_EXE%

REM Default to release unless --debug is passed
SET RUN_DEBUG=false
FOR %%A IN (%*) DO (
    IF /I "%%A"=="--debug" SET RUN_DEBUG=true
)

SET SOURCE_PATH=
SET TARGET_PATH=
SET TARGET_EXE=

REM Determine which version to prepare and run
IF "%RUN_DEBUG%"=="true" (
    IF EXIST "%SOURCE_DEBUG_PATH%" (
        echo Preparing debug version...
        SET SOURCE_PATH=%SOURCE_DEBUG_PATH%
        SET TARGET_PATH=%TARGET_DEBUG_PATH%
        SET TARGET_EXE=%TARGET_DEBUG_EXE%
    ) ELSE (
        echo Error: Debug source executable not found at %SOURCE_DEBUG_PATH%
        echo Please build the debug version first using:
        echo   meson setup build-debug --buildtype=debug
        echo   meson compile -C build-debug
        exit /b 1
    )
) ELSE (
    IF EXIST "%SOURCE_RELEASE_PATH%" (
        echo Preparing release version...
        SET SOURCE_PATH=%SOURCE_RELEASE_PATH%
        SET TARGET_PATH=%TARGET_RELEASE_PATH%
        SET TARGET_EXE=%TARGET_RELEASE_EXE%
    ) ELSE IF EXIST "%SOURCE_DEBUG_PATH%" (
        REM Fallback to debug if release not found and debug exists
        echo Release version not found. Preparing debug version...
        SET SOURCE_PATH=%SOURCE_DEBUG_PATH%
        SET TARGET_PATH=%TARGET_DEBUG_PATH%
        SET TARGET_EXE=%TARGET_DEBUG_EXE%
    ) ELSE (
        echo Error: Neither release nor debug source executable found.
        echo Checked paths:
        echo   %SOURCE_RELEASE_PATH%
        echo   %SOURCE_DEBUG_PATH%
        echo Please build the project first using commands like:
        echo   meson setup build-release --buildtype=release
        echo   meson compile -C build-release
        echo or:
        echo   meson setup build-debug --buildtype=debug
        echo   meson compile -C build-debug
        exit /b 1
    )
)

REM Ensure Redist directory exists
IF NOT EXIST "%REDIST_DIR%" (
    echo Creating directory %REDIST_DIR%...
    mkdir "%REDIST_DIR%"
    IF ERRORLEVEL 1 (
        echo Error: Failed to create directory %REDIST_DIR%
        exit /b 1
    )
)

REM Copy the executable to Redist
echo Copying %SOURCE_PATH% to %TARGET_PATH%...
copy /Y "%SOURCE_PATH%" "%TARGET_PATH%" > nul
IF ERRORLEVEL 1 (
    echo Error: Failed to copy executable.
    exit /b 1
)

REM Change to the Redist directory so the application can find Data etc.
echo Changing directory to %REDIST_DIR%
pushd "%REDIST_DIR%"
IF ERRORLEVEL 1 (
    echo Failed to change directory to %REDIST_DIR%
    exit /b 1
)

REM Run the executable from the Redist directory
echo Running %TARGET_EXE% from %CD%...
"%TARGET_EXE%" %*
SET EXIT_CODE=%ERRORLEVEL%

popd
echo Exited with code %EXIT_CODE%
exit /b %EXIT_CODE%
