#!/bin/bash
# Script to run the appropriate version of U7Revisited (debug or release)
# Copies the executable to Redist/ before running it.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." &> /dev/null && pwd)" # Go one level up to get project root
BUILD_DIR_DEBUG="${PROJECT_ROOT}/build-debug"
BUILD_DIR_RELEASE="${PROJECT_ROOT}/build-release"
REDIST_DIR="${PROJECT_ROOT}/Redist"

# Source paths directly within the build directory
SOURCE_DEBUG_PATH="${BUILD_DIR_DEBUG}/U7Revisited_debug"
SOURCE_RELEASE_PATH="${BUILD_DIR_RELEASE}/U7Revisited_release"

# Target paths within Redist
TARGET_DEBUG_EXE="U7Revisited_debug"
TARGET_RELEASE_EXE="U7Revisited_release"
TARGET_DEBUG_PATH="${REDIST_DIR}/${TARGET_DEBUG_EXE}"
TARGET_RELEASE_PATH="${REDIST_DIR}/${TARGET_RELEASE_EXE}"

# Default to release unless --debug is passed
RUN_DEBUG=false
# Check for --healthcheck flag separately
RUN_HEALTHCHECK=false
GAME_ARGS=() # Array to hold arguments meant for the game

for arg in "$@"; do
  case "$arg" in
    --debug)
      RUN_DEBUG=true
      ;;
    --healthcheck)
      RUN_HEALTHCHECK=true
      ;;
    *)
      # Assume other arguments are for the game executable
      GAME_ARGS+=("$arg")
      ;;
  esac
done

SOURCE_PATH=""
TARGET_PATH=""
TARGET_EXE=""

# Determine which version to prepare and run
if [[ "$RUN_DEBUG" == true ]]; then
    if [ -f "$SOURCE_DEBUG_PATH" ]; then
        echo "Preparing debug version..."
        SOURCE_PATH="$SOURCE_DEBUG_PATH"
        TARGET_PATH="$TARGET_DEBUG_PATH"
        TARGET_EXE="$TARGET_DEBUG_EXE"
    else
        echo "Error: Debug source executable not found at ${SOURCE_DEBUG_PATH}"
        echo "Please build the debug version first using:"
        echo "  meson setup build-debug --buildtype=debug"
        echo "  meson compile -C build-debug"
        exit 1
    fi
else
    if [ -f "$SOURCE_RELEASE_PATH" ]; then
        echo "Preparing release version..."
        SOURCE_PATH="$SOURCE_RELEASE_PATH"
        TARGET_PATH="$TARGET_RELEASE_PATH"
        TARGET_EXE="$TARGET_RELEASE_EXE"
    elif [ -f "$SOURCE_DEBUG_PATH" ]; then
        # Fallback to debug if release not found and debug exists
        echo "Release version not found. Preparing debug version..."
        SOURCE_PATH="$SOURCE_DEBUG_PATH"
        TARGET_PATH="$TARGET_DEBUG_PATH"
        TARGET_EXE="$TARGET_DEBUG_EXE"
    else
        echo "Error: Neither release nor debug source executable found."
        echo "Checked paths:"
        echo "  ${SOURCE_RELEASE_PATH}"
        echo "  ${SOURCE_DEBUG_PATH}"
        echo "Please build the project first using commands like:"
        echo "  meson setup build-release --buildtype=release"
        echo "  meson compile -C build-release"
        echo "or:"
        echo "  meson setup build-debug --buildtype=debug"
        echo "  meson compile -C build-debug"
        exit 1
    fi
fi

# Ensure Redist directory exists
mkdir -p "$REDIST_DIR"

# Copy the executable to Redist
echo "Copying ${SOURCE_PATH} to ${TARGET_PATH}..."
cp "$SOURCE_PATH" "$TARGET_PATH"
if [ $? -ne 0 ]; then
    echo "Error: Failed to copy executable."
    exit 1
fi

# Change to the Redist directory so the application can find Data etc.
echo "Changing directory to ${REDIST_DIR}"
cd "$REDIST_DIR" || exit 1

# Prepare arguments for the executable
EXEC_ARGS=()
if [[ "$RUN_HEALTHCHECK" == true ]]; then
    EXEC_ARGS+=("--healthcheck")
fi
# Append the filtered game arguments
EXEC_ARGS+=("${GAME_ARGS[@]}")

# Run the executable from the Redist directory, passing potentially modified args
echo "Running ${TARGET_EXE} ${EXEC_ARGS[*]} from $(pwd)..."
"./${TARGET_EXE}" "${EXEC_ARGS[@]}" # Pass along potentially modified arguments

exit $?
