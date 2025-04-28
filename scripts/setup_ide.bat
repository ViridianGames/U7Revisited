@echo off
REM Script to generate common IDE launch configurations for U7Revisited (Windows)
setlocal enabledelayedexpansion

echo Setting up IDE configurations for U7Revisited (Windows)...

SET "SCRIPT_DIR=%~dp0"
REM Ensure SCRIPT_DIR ends with a backslash
IF "%SCRIPT_DIR:~-1%" NEQ "\" SET "SCRIPT_DIR=%SCRIPT_DIR%\"

SET "PROJECT_ROOT=%SCRIPT_DIR%"
SET "VSCODE_DIR=%PROJECT_ROOT%.vscode"
SET "LAUNCH_JSON_PATH=%VSCODE_DIR%\launch.json"
SET "IDEA_DIR=%PROJECT_ROOT%.idea"
SET "RUN_CONFIG_DIR=%IDEA_DIR%\runConfigurations"
SET "HELPER_SCRIPT_BAT=%PROJECT_ROOT%copy_executable.bat"

SET "RUN_SCRIPT=run_u7.bat"
SET "DEBUG_EXE=U7Revisited_debug.exe"
SET "RELEASE_EXE=U7Revisited_release.exe"

REM --- Generate VS Code Configuration ---
echo [VS Code] Generating %LAUNCH_JSON_PATH%...
IF NOT EXIST "%VSCODE_DIR%" mkdir "%VSCODE_DIR%"
(
    echo {
    echo     "version": "0.2.0",
    echo     "configurations": [
    echo         {
    echo             "name": "(Windows) Launch Debug (via script)",
    echo             "type": "cppvsdbg",
    echo             "request": "launch",
    echo             "program": "%PROJECT_ROOT%%RUN_SCRIPT%",
    echo             "args": ["--debug"],
    echo             "stopAtEntry": false,
    echo             "cwd": "%PROJECT_ROOT%",
    echo             "environment": [],
    echo             "console": "externalTerminal"
    echo             // Optional: Add "preLaunchTask": "Build Debug" if you have a tasks.json
    echo         },
    echo         {
    echo             "name": "(Windows) Launch Release (via script)",
    echo             "type": "cppvsdbg",
    echo             "request": "launch",
    echo             "program": "%PROJECT_ROOT%%RUN_SCRIPT%",
    echo             "args": [],
    echo             "stopAtEntry": false,
    echo             "cwd": "%PROJECT_ROOT%",
    echo             "environment": [],
    echo             "console": "externalTerminal"
    echo             // Optional: Add "preLaunchTask": "Build Release" if you have a tasks.json
    echo         }
    echo     ]
    echo }
) > "%LAUNCH_JSON_PATH%"
echo [VS Code] Configuration written.

REM --- Generate Helper Script for CLion ---
REM (copy_executable.bat was created separately)
IF EXIST "%HELPER_SCRIPT_BAT%" (
    echo [CLion] Helper script %HELPER_SCRIPT_BAT% already generated.
) ELSE (
    echo [CLion] Warning: Helper script %HELPER_SCRIPT_BAT% not found. Please run the previous step or create it manually.
)


REM --- Generate CLion Run Configurations ---
IF EXIST "%IDEA_DIR%\" (
    echo [CLion] Generating run configurations in %RUN_CONFIG_DIR%...
    IF NOT EXIST "%RUN_CONFIG_DIR%" mkdir "%RUN_CONFIG_DIR%"

    REM CLion Debug Config
    (
        echo ^<component name="ProjectRunConfigurationManager"^>
        echo   ^<configuration default="false" name="U7_Debug_Windows" type="CMakeRunConfiguration" factoryName="Application" REDIRECT_INPUT="false" ELEVATE="false" USE_EXTERNAL_CONSOLE="false" PASS_PARENT_ENVS_2="true" PROJECT_NAME="U7Revisited" TARGET_NAME="%DEBUG_EXE%" CONFIG_NAME="Debug" RUN_TARGET_PROJECT_NAME="U7Revisited" RUN_TARGET_NAME="%DEBUG_EXE%"^>
        echo     ^<method v="2"^>
        echo       ^<option name="com.jetbrains.cidr.execution.CidrBuildBeforeRunTaskProvider$BuildBeforeRunTask" enabled="true" /^>
        echo       ^<option name="RunConfigurationTask" enabled="true" run_configuration_name="Copy_Debug_Helper_Windows" run_configuration_type="BatchConfigurationType" /^>
        echo     ^</method^>
        echo   ^</configuration^>
        echo ^</component^>
    ) > "%RUN_CONFIG_DIR%\U7_Debug_Windows.xml"

    REM CLion Release Config
    (
        echo ^<component name="ProjectRunConfigurationManager"^>
        echo   ^<configuration default="false" name="U7_Release_Windows" type="CMakeRunConfiguration" factoryName="Application" REDIRECT_INPUT="false" ELEVATE="false" USE_EXTERNAL_CONSOLE="false" PASS_PARENT_ENVS_2="true" PROJECT_NAME="U7Revisited" TARGET_NAME="%RELEASE_EXE%" CONFIG_NAME="Release" RUN_TARGET_PROJECT_NAME="U7Revisited" RUN_TARGET_NAME="%RELEASE_EXE%"^>
        echo     ^<method v="2"^>
        echo       ^<option name="com.jetbrains.cidr.execution.CidrBuildBeforeRunTaskProvider$BuildBeforeRunTask" enabled="true" /^>
        echo        ^<option name="RunConfigurationTask" enabled="true" run_configuration_name="Copy_Release_Helper_Windows" run_configuration_type="BatchConfigurationType" /^>
        echo    ^</method^>
        echo   ^</configuration^>
        echo ^</component^>
    ) > "%RUN_CONFIG_DIR%\U7_Release_Windows.xml"

    REM Helper script runner configurations
    (
        echo ^<component name="ProjectRunConfigurationManager"^>
        echo   ^<configuration default="false" name="Copy_Debug_Helper_Windows" type="BatchConfigurationType" factoryName="Batch"^>
        echo     ^<option name="INTERPRETER_OPTIONS" value="" /^>
        echo     ^<option name="WORKING_DIRECTORY" value="$PROJECT_DIR$" /^>
        echo     ^<option name="PARENT_ENVS" value="true" /^>
        echo     ^<option name="SCRIPT_NAME" value="$PROJECT_DIR$\copy_executable.bat" /^>
        echo     ^<option name="PARAMETERS" value="--debug" /^>
        echo     ^<method v="2" /^>
        echo   ^</configuration^>
        echo ^</component^>
    ) > "%RUN_CONFIG_DIR%\Copy_Debug_Helper_Windows.xml"

    (
        echo ^<component name="ProjectRunConfigurationManager"^>
        echo   ^<configuration default="false" name="Copy_Release_Helper_Windows" type="BatchConfigurationType" factoryName="Batch"^>
        echo     ^<option name="INTERPRETER_OPTIONS" value="" /^>
        echo     ^<option name="WORKING_DIRECTORY" value="$PROJECT_DIR$" /^>
        echo     ^<option name="PARENT_ENVS" value="true" /^>
        echo     ^<option name="SCRIPT_NAME" value="$PROJECT_DIR$\copy_executable.bat" /^>
        echo     ^<option name="PARAMETERS" value="" /^>
        echo     ^<method v="2" /^>
        echo   ^</configuration^>
        echo ^</component^>
    ) > "%RUN_CONFIG_DIR%\Copy_Release_Helper_Windows.xml"

    echo [CLion] Run configurations written to %RUN_CONFIG_DIR%\
    echo [CLion] NOTE: You may need to reload the project or restart CLion for changes to take effect.
    echo [CLion] NOTE: These configurations use the 'CMake Application' type. Ensure your project loads correctly in CLion first.
    echo [CLion] NOTE: Make sure to set the 'Working Directory' in the main 'U7_Debug_Windows' and 'U7_Release_Windows' configurations to '%PROJECT_ROOT%Redist'

) ELSE (
    echo [CLion] Skipping run configuration generation: Directory %IDEA_DIR% not found.
    echo [CLion] Please open the project in CLion first to create the .idea directory.
)


REM --- Instructions for Other IDEs ---
echo.
echo --- Instructions for Other IDEs ---
echo.
echo [Visual Studio (Windows)]
echo 1. Open the Solution.
echo 2. Right-click the 'U7Revisited' project in Solution Explorer ^> Properties.
echo 3. Go to 'Configuration Properties' ^> 'Debugging'.
echo 4. Set 'Command' to: $(ProjectDir)..\%RUN_SCRIPT%
echo 5. Set 'Command Arguments' to: --debug (for Debug config) or leave blank (for Release config).
echo 6. Set 'Working Directory' to: $(ProjectDir)..\Redist
echo 7. Repeat for both Debug and Release configurations.
echo.
echo [NetBeans]
echo 1. Open the Project.
echo 2. Right-click the project ^> Properties.
echo 3. Go to the 'Run' category.
echo 4. Set 'Run Command' to: cmd /c ""%%PROJECT_DIR%%\%RUN_SCRIPT%" --debug" (Adjust path, add/remove --debug).
echo    Alternatively, use 'Working Directory' and 'Run File' if NetBeans separates them.
echo 5. Set 'Working Directory' to: %%PROJECT_DIR%%\Redist
echo 6. Configure separate run configurations for Debug and Release if needed.
echo.
echo -------------------------------------
echo IDE setup script finished.
echo Remember to commit generated '.vscode\launch.json', '.idea\runConfigurations\*', and 'copy_executable.bat' to your repository if desired.

endlocal
exit /b 0 