@echo off
REM Script to run the appropriate version of U7Revisited (debug or release)
REM Copies the executable to Redist/ before running it.
setlocal enabledelayedexpansion

SET "SCRIPT_DIR=%~dp0"
REM Ensure SCRIPT_DIR ends with a backslash for reliable path joining
IF "%SCRIPT_DIR:~-1%" NEQ "\" SET "SCRIPT_DIR=%SCRIPT_DIR%\"
SET "PROJECT_ROOT=%SCRIPT_DIR%..\"

SET "BUILD_DIR_DEBUG=%PROJECT_ROOT%build-debug"
SET "BUILD_DIR_RELEASE=%PROJECT_ROOT%build-release"
SET "REDIST_DIR=%PROJECT_ROOT%Redist"

REM Assumed source paths from copy_executable.bat
SET "INSTALL_SUBDIR=install_prefix\bin"
SET "SOURCE_DEBUG_PATH=%BUILD_DIR_DEBUG%\%INSTALL_SUBDIR%\U7Revisited_debug.exe"
SET "SOURCE_RELEASE_PATH=%BUILD_DIR_RELEASE%\%INSTALL_SUBDIR%\U7Revisited_release.exe"

REM Target paths within Redist
SET TARGET_DEBUG_EXE=U7Revisited_debug.exe
SET TARGET_RELEASE_EXE=U7Revisited_release.exe
SET TARGET_DEBUG_PATH=%REDIST_DIR%\%TARGET_DEBUG_EXE%
SET TARGET_RELEASE_PATH=%REDIST_DIR%\%TARGET_RELEASE_EXE%

REM Parse arguments
SET RUN_DEBUG=false
SET RUN_HEALTHCHECK=false
SET PASS_VERBOSE=false
SET GAME_ARGS=

:ParseRunArgsLoop
IF "%~1"=="" GOTO ParseRunArgsDone

    IF /I "%~1"=="--debug" (
        SET RUN_DEBUG=true
    ) ELSE IF /I "%~1"=="--healthcheck" (
        SET RUN_HEALTHCHECK=true
        REM Healthcheck implies debug and verbose for the run
        SET RUN_DEBUG=true
        SET PASS_VERBOSE=true
    ) ELSE IF /I "%~1"=="--verbose" (
        SET PASS_VERBOSE=true
    ) ELSE (
        REM Collect other args as game args
        SET GAME_ARGS=!GAME_ARGS! %1
    )
    SHIFT
    GOTO ParseRunArgsLoop

:ParseRunArgsDone

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
        echo Please build the debug version first.
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
        echo Please build the project first.
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

REM Copy the executable to Redist using the helper script (consistent logic)
SET "COPY_SCRIPT=%SCRIPT_DIR%copy_executable.bat"
SET "COPY_ARG="
IF "%RUN_DEBUG%"=="true" SET "COPY_ARG=--debug"
echo Copying executable via: %COPY_SCRIPT% %COPY_ARG%
call "%COPY_SCRIPT%" %COPY_ARG%
IF ERRORLEVEL 1 (
    echo Error: Failed to copy executable using %COPY_SCRIPT%.
    exit /b 1
)

REM Change to the Redist directory so the application can find Data etc.
echo Changing directory to %REDIST_DIR%
pushd "%REDIST_DIR%"
IF ERRORLEVEL 1 (
    echo Failed to change directory to %REDIST_DIR%
    exit /b 1
)

REM Prepare arguments for the executable
SET EXEC_ARGS=
IF "%RUN_HEALTHCHECK%"=="true" (
    SET EXEC_ARGS=--healthcheck
)
IF "%PASS_VERBOSE%"=="true" (
    REM Avoid double adding if healthcheck already added it
    echo "%EXEC_ARGS%" | findstr /I /C:"--verbose" > nul
    IF ERRORLEVEL 1 SET EXEC_ARGS=%EXEC_ARGS% --verbose
)
REM Append the collected game arguments
SET EXEC_ARGS=%EXEC_ARGS% %GAME_ARGS%

REM Run the executable from the Redist directory
echo Running %TARGET_EXE% %EXEC_ARGS% from %CD%...
"%TARGET_EXE%" %EXEC_ARGS%
SET EXIT_CODE=%ERRORLEVEL%

popd
echo Exited with code %EXIT_CODE%
exit /b %EXIT_CODE%
