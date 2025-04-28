#!/bin/bash
# Script to generate common IDE launch configurations for U7Revisited

echo "Setting up IDE configurations for U7Revisited (Linux/macOS)..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}"
VSCODE_DIR="${PROJECT_ROOT}/.vscode"
LAUNCH_JSON_PATH="${VSCODE_DIR}/launch.json"
IDEA_DIR="${PROJECT_ROOT}/.idea"
RUN_CONFIG_DIR="${IDEA_DIR}/runConfigurations"
HELPER_SCRIPT_SH="${PROJECT_ROOT}/copy_executable.sh"

RUN_SCRIPT="run_u7.sh"
DEBUG_EXE="U7Revisited_debug"
RELEASE_EXE="U7Revisited_release"

# --- Generate VS Code Configuration ---
echo "[VS Code] Generating ${LAUNCH_JSON_PATH}..."
mkdir -p "${VSCODE_DIR}"
cat << EOF > "${LAUNCH_JSON_PATH}"
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "(lldb) Launch Debug (via script)",
            "type": "cppdbg",
            "request": "launch",
            "program": "${PROJECT_ROOT}/${RUN_SCRIPT}",
            "args": ["--debug"],
            "stopAtEntry": false,
            "cwd": "${PROJECT_ROOT}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "lldb", // Change to "gdb" if you use GDB
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for lldb/gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ],
            // Optional: Add "preLaunchTask": "Build Debug" if you have a tasks.json
        },
        {
            "name": "(lldb) Launch Release (via script)",
            "type": "cppdbg",
            "request": "launch",
            "program": "${PROJECT_ROOT}/${RUN_SCRIPT}",
            "args": [], // No --debug for release
            "stopAtEntry": false,
            "cwd": "${PROJECT_ROOT}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "lldb", // Change to "gdb" if you use GDB
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for lldb/gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ]
             // Optional: Add "preLaunchTask": "Build Release" if you have a tasks.json
        }
    ]
}
EOF
echo "[VS Code] Configuration written."

# --- Generate Helper Script for CLion ---
echo "[CLion] Generating helper script ${HELPER_SCRIPT_SH}..."
cat << 'EOF' > "${HELPER_SCRIPT_SH}"
#!/bin/bash
# Helper script for IDEs (like CLion) to copy the correct executable to Redist before launch
HELPER_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
BUILD_DIR_DEBUG="${HELPER_SCRIPT_DIR}/build-debug"
BUILD_DIR_RELEASE="${HELPER_SCRIPT_DIR}/build-release"
REDIST_DIR="${HELPER_SCRIPT_DIR}/Redist"
SOURCE_DEBUG_PATH="${BUILD_DIR_DEBUG}/install_prefix/bin/U7Revisited_debug"
SOURCE_RELEASE_PATH="${BUILD_DIR_RELEASE}/install_prefix/bin/U7Revisited_release"
TARGET_DEBUG_PATH="${REDIST_DIR}/U7Revisited_debug"
TARGET_RELEASE_PATH="${REDIST_DIR}/U7Revisited_release"

mkdir -p "$REDIST_DIR"
SOURCE_PATH=""
TARGET_PATH=""

if [[ "$1" == "--debug" ]]; then
    SOURCE_PATH="$SOURCE_DEBUG_PATH"
    TARGET_PATH="$TARGET_DEBUG_PATH"
else # Default to release
    SOURCE_PATH="$SOURCE_RELEASE_PATH"
    TARGET_PATH="$TARGET_RELEASE_PATH"
fi

# Check if source exists before copying
if [ -z "$SOURCE_PATH" ]; then
  echo "Error (Helper Script): Source path variable is empty. Argument was: $1" >&2
  exit 1
fi
if [ ! -f "$SOURCE_PATH" ]; then
  echo "Error (Helper Script): Source executable for copy not found at ${SOURCE_PATH}" >&2
  exit 1 # Fail the 'Before launch' step
fi

echo "IDE Helper: Copying ${SOURCE_PATH} to ${TARGET_PATH}..."
cp "$SOURCE_PATH" "$TARGET_PATH"
if [ $? -ne 0 ]; then
    echo "Error (Helper Script): Failed to copy executable." >&2
    exit 1 # Fail the 'Before launch' step
fi
exit 0 # Success
EOF
chmod +x "${HELPER_SCRIPT_SH}"
echo "[CLion] Helper script created and made executable."

# --- Generate CLion Run Configurations ---
if [ -d "${IDEA_DIR}" ]; then
    echo "[CLion] Generating run configurations in ${RUN_CONFIG_DIR}..."
    mkdir -p "${RUN_CONFIG_DIR}"

    # CLion Debug Config
    cat << EOF > "${RUN_CONFIG_DIR}/U7_Debug.xml"
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="U7_Debug" type="CMakeRunConfiguration" factoryName="Application" REDIRECT_INPUT="false" ELEVATE="false" USE_EXTERNAL_CONSOLE="false" PASS_PARENT_ENVS_2="true" PROJECT_NAME="U7Revisited" TARGET_NAME="${DEBUG_EXE}" CONFIG_NAME="Debug" RUN_TARGET_PROJECT_NAME="U7Revisited" RUN_TARGET_NAME="${DEBUG_EXE}">
    <method v="2">
      <option name="com.jetbrains.cidr.execution.CidrBuildBeforeRunTaskProvider$BuildBeforeRunTask" enabled="true" />
      <option name="RunConfigurationTask" enabled="true" run_configuration_name="Copy_Debug_Helper" run_configuration_type="ShConfigurationType" />
    </method>
  </configuration>
</component>
EOF

    # CLion Release Config
    cat << EOF > "${RUN_CONFIG_DIR}/U7_Release.xml"
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="U7_Release" type="CMakeRunConfiguration" factoryName="Application" REDIRECT_INPUT="false" ELEVATE="false" USE_EXTERNAL_CONSOLE="false" PASS_PARENT_ENVS_2="true" PROJECT_NAME="U7Revisited" TARGET_NAME="${RELEASE_EXE}" CONFIG_NAME="Release" RUN_TARGET_PROJECT_NAME="U7Revisited" RUN_TARGET_NAME="${RELEASE_EXE}">
    <method v="2">
      <option name="com.jetbrains.cidr.execution.CidrBuildBeforeRunTaskProvider$BuildBeforeRunTask" enabled="true" />
       <option name="RunConfigurationTask" enabled="true" run_configuration_name="Copy_Release_Helper" run_configuration_type="ShConfigurationType" />
   </method>
  </configuration>
</component>
EOF

   # Helper script runner configurations (these show up in Run/Debug list but just run the script)
   cat << EOF > "${RUN_CONFIG_DIR}/Copy_Debug_Helper.xml"
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="Copy_Debug_Helper" type="ShConfigurationType">
    <option name="SCRIPT_TEXT" value="" />
    <option name="INDEPENDENT_SCRIPT_PATH" value="true" />
    <option name="SCRIPT_PATH" value="\$PROJECT_DIR\$/copy_executable.sh" />
    <option name="SCRIPT_OPTIONS" value="--debug" />
    <option name="INDEPENDENT_SCRIPT_WORKING_DIRECTORY" value="true" />
    <option name="SCRIPT_WORKING_DIRECTORY" value="\$PROJECT_DIR\$" />
    <option name="INDEPENDENT_INTERPRETER_PATH" value="true" />
    <option name="INTERPRETER_PATH" value="/bin/bash" />
    <option name="INTERPRETER_OPTIONS" value="" />
    <option name="EXECUTE_IN_TERMINAL" value="false" />
    <option name="EXECUTE_SCRIPT_FILE" value="true" />
    <envs />
    <method v="2" />
  </configuration>
</component>
EOF
   cat << EOF > "${RUN_CONFIG_DIR}/Copy_Release_Helper.xml"
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="Copy_Release_Helper" type="ShConfigurationType">
    <option name="SCRIPT_TEXT" value="" />
    <option name="INDEPENDENT_SCRIPT_PATH" value="true" />
    <option name="SCRIPT_PATH" value="\$PROJECT_DIR\$/copy_executable.sh" />
    <option name="SCRIPT_OPTIONS" value="" />
    <option name="INDEPENDENT_SCRIPT_WORKING_DIRECTORY" value="true" />
    <option name="SCRIPT_WORKING_DIRECTORY" value="\$PROJECT_DIR\$" />
    <option name="INDEPENDENT_INTERPRETER_PATH" value="true" />
    <option name="INTERPRETER_PATH" value="/bin/bash" />
    <option name="INTERPRETER_OPTIONS" value="" />
    <option name="EXECUTE_IN_TERMINAL" value="false" />
    <option name="EXECUTE_SCRIPT_FILE" value="true" />
    <envs />
    <method v="2" />
  </configuration>
</component>
EOF


    echo "[CLion] Run configurations written to ${RUN_CONFIG_DIR}/"
    echo "[CLion] NOTE: You may need to reload the project or restart CLion for changes to take effect."
    echo "[CLion] NOTE: These configurations use the 'CMake Application' type. Ensure your project loads correctly in CLion first."
    echo "[CLion] NOTE: Make sure to set the 'Working Directory' in the main 'U7_Debug' and 'U7_Release' configurations to '${PROJECT_ROOT}/Redist'"

else
    echo "[CLion] Skipping run configuration generation: Directory ${IDEA_DIR} not found."
    echo "[CLion] Please open the project in CLion first to create the .idea directory."
fi


# --- Instructions for Other IDEs ---
echo ""
echo "--- Instructions for Other IDEs ---"
echo ""
echo "[Visual Studio (Windows)]"
echo "1. Open the Solution."
echo "2. Right-click the 'U7Revisited' project in Solution Explorer -> Properties."
echo "3. Go to 'Configuration Properties' -> 'Debugging'."
echo "4. Set 'Command' to: \$(ProjectDir)..\\${RUN_SCRIPT}  (Adjust path if needed)"
echo "5. Set 'Command Arguments' to: --debug (for Debug config) or leave blank (for Release config)."
echo "6. Set 'Working Directory' to: \$(ProjectDir)..\\Redist  (Ensure this points to the Redist folder)"
echo "7. Repeat for both Debug and Release configurations."
echo ""
echo "[NetBeans]"
echo "1. Open the Project."
echo "2. Right-click the project -> Properties."
echo "3. Go to the 'Run' category."
echo "4. Set 'Run Command' to something like: \"\${PROJECT_DIR}/${RUN_SCRIPT}\" --debug (Adjust path and add/remove --debug)."
echo "   Alternatively, use 'Working Directory' and 'Run File' if NetBeans separates them."
echo "5. Set 'Working Directory' to: \${PROJECT_DIR}/Redist"
echo "6. Configure separate run configurations for Debug and Release if needed."
echo ""
echo "-------------------------------------"
echo "IDE setup script finished."
echo "Remember to commit generated '.vscode/launch.json', '.idea/runConfigurations/*', and 'copy_executable.sh' to your repository if desired."
echo "A 'setup_ide.bat' and 'copy_executable.bat' would be needed for Windows users." 