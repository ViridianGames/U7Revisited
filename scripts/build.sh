#!/bin/bash
# Simple build script for U7Revisited using Meson

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." &> /dev/null && pwd)" # Go one level up to get project root
BUILD_TYPE="debug" # Default to debug
BUILD_DIR="${PROJECT_ROOT}/build-debug"
SHOULD_CONFIGURE=false
SHOULD_CLEAN=false
SHOULD_RUN=false
RUN_ARGS=() # Arguments to pass to run_u7.sh

# --- Argument Parsing ---
EXTRA_MESON_ARGS=() # For passing things like -Doption=value to meson setup
POSITIONAL_ARGS=() # For args after --

while [[ $# -gt 0 ]]; do
  case "$1" in
    --release)
      BUILD_TYPE="release"
      BUILD_DIR="${PROJECT_ROOT}/build-release"
      shift # past argument
      ;;
    --configure)
      SHOULD_CONFIGURE=true
      shift # past argument
      ;;
    --clean)
      SHOULD_CLEAN=true
      shift # past argument
      ;;
    --run)
      SHOULD_RUN=true
      shift # past argument
      # All remaining arguments are passed to run_u7.sh
      RUN_ARGS=("$@")
      break # Stop parsing after --run
      ;;
    -D*|-C*)
      # Pass Meson setup/configure arguments through
      EXTRA_MESON_ARGS+=("$1")
      shift
      ;;
    --) # End of options
      shift
      POSITIONAL_ARGS+=("$@") # Treat rest as positional, though we don't use them currently
      break
      ;;
    -h|--help)
      echo "Usage: $0 [--release] [--configure] [--clean] [--run] [-Doption=value...] [--] [run_script_args...]"
      echo "  --release    : Build the release version (default: debug)"
      echo "  --configure  : Force run 'meson setup' even if build dir exists"
      echo "  --clean      : Remove the build directory before building"
      echo "  --run        : Run the project using run_u7.sh after building"
      echo "  -D.../-C...  : Pass arguments directly to 'meson setup'"
      echo "  run_script_args: Arguments passed to run_u7.sh when using --run"
      exit 0
      ;;
    *) # Unknown option
      POSITIONAL_ARGS+=("$1") # Treat unknown as positional for now
      echo "Warning: Unknown or misplaced argument: $1"
      shift
      ;;
  esac
done


echo "--- Building U7Revisited (${BUILD_TYPE}) ---"

# --- Clean ---
if [[ "$SHOULD_CLEAN" == true && -d "$BUILD_DIR" ]]; then
  echo "[Clean] Removing build directory: ${BUILD_DIR}..."
  if rm -rf "$BUILD_DIR"; then
    echo "[Clean] Directory removed."
    SHOULD_CONFIGURE=true # Need to reconfigure after clean
  else
    echo "[Clean] Error: Failed to remove directory ${BUILD_DIR}" >&2
    exit 1
  fi
fi

# --- Configure ---
if [[ "$SHOULD_CONFIGURE" == true || ! -d "$BUILD_DIR" ]]; then
  echo "[Configure] Configuring (${BUILD_TYPE}) in ${BUILD_DIR}..."
  # Check if Meson exists
  if ! command -v meson &> /dev/null; then
      echo "[Configure] Error: 'meson' command not found. Please install Meson." >&2
      exit 1
  fi
  meson setup "$BUILD_DIR" --buildtype="$BUILD_TYPE" "${EXTRA_MESON_ARGS[@]}"
  if [ $? -ne 0 ]; then
    echo "[Configure] Error: Meson setup failed!" >&2
    exit 1
  fi
  echo "[Configure] Meson setup complete."
elif [[ ${#EXTRA_MESON_ARGS[@]} -gt 0 ]]; then
     echo "[Configure] Reconfiguring (${BUILD_TYPE}) in ${BUILD_DIR} due to extra args..."
     meson configure "$BUILD_DIR" "${EXTRA_MESON_ARGS[@]}"
      if [ $? -ne 0 ]; then
        echo "[Configure] Error: Meson configure failed!" >&2
        exit 1
      fi
else
  echo "[Configure] Build directory ${BUILD_DIR} already configured. Skipping setup. Use --configure to force."
fi

# --- Compile ---
echo "[Compile] Compiling (${BUILD_TYPE}) in ${BUILD_DIR}..."
meson compile -C "$BUILD_DIR"
COMPILE_EXIT_CODE=$?
if [ ${COMPILE_EXIT_CODE} -ne 0 ]; then
  echo "[Compile] Error: Meson compile failed!" >&2
  exit 1
fi
echo "[Compile] Meson compile successful."

echo "--- Build successful (${BUILD_TYPE}) ---"

# --- Run ---
if [[ "$SHOULD_RUN" == true ]]; then
  echo "" # Newline before run section
  echo "--- Running (${BUILD_TYPE}) ---"
  RUN_CMD="${PROJECT_ROOT}/scripts/run_u7.sh" # Use PROJECT_ROOT
  RUN_FLAGS=()
  if [[ "$BUILD_TYPE" == "debug" ]]; then
     RUN_FLAGS+=("--debug")
  fi
  # Combine script flags and user-provided args
  RUN_FLAGS+=("${RUN_ARGS[@]}") # These already contain remaining args from build script call

  if [ ! -f "$RUN_CMD" ]; then
      echo "[Run] Error: ${RUN_CMD} not found." >&2
      exit 1
  fi
  if [ ! -x "$RUN_CMD" ]; then
      echo "[Run] Error: ${RUN_CMD} is not executable. Attempting to chmod +x..." >&2
      chmod +x "$RUN_CMD"
      if [ $? -ne 0 ]; then
          echo "[Run] Error: Failed to make ${RUN_CMD} executable." >&2
          exit 1
      fi
  fi


  echo "[Run] Executing: ${RUN_CMD} ${RUN_FLAGS[@]}"
  "${RUN_CMD}" "${RUN_FLAGS[@]}"
  RUN_EXIT_CODE=$?
  if [ ${RUN_EXIT_CODE} -ne 0 ]; then
      echo "[Run] Process exited with code ${RUN_EXIT_CODE}." >&2
      echo "--- Run failed ---"
      exit 1 # Indicate failure
  fi
   echo "--- Run finished ---"
fi

exit 0 