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
