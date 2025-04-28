#!/bin/bash

# Script to check and ensure all Lua scripts in Data/Scripts start with require "U7LuaFuncs"
# Creates .bak files for modifications and prompts user to confirm or restore.

# --- Colors ---
CLR_RST="\e[0m" # Reset
CLR_RED="\e[31m" # Error
CLR_GRN="\e[32m" # Success
CLR_YLW="\e[33m" # Warning / Modified
CLR_BLU="\e[34m" # Info / Headers
CLR_CYN="\e[36m" # Info

# Determine project root (one level up from the script's directory)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." &> /dev/null && pwd)"

SCRIPT_DIR="$PROJECT_ROOT/Redist/Data/Scripts" # Corrected path

# --- Patterns ---
# Pattern to check if the require exists ANYWHERE (no ^ anchor)
ANYWHERE_PATTERN='require[[:space:]]*[\'"']U7LuaFuncs[\'"']'
# Pattern to check if the require is exactly on the FIRST line (with ^ anchor)
FIRST_LINE_PATTERN='^require[[:space:]]*[\'"']U7LuaFuncs[\'"']'
# The exact line to insert if missing
REQUIRED_LINE='require "U7LuaFuncs"'

MODIFIED_COUNT=0
CHECKED_COUNT=0
ERROR_COUNT=0
declare -a MODIFIED_FILES # Array to store names of modified files

shopt -s nullglob # Prevent errors if no *.lua files are found

FILES=("$SCRIPT_DIR"/*.lua)
shopt -u nullglob # Turn off nullglob after expansion

if [ ${#FILES[@]} -eq 0 ]; then
  echo -e "${CLR_YLW}No .lua files found in $SCRIPT_DIR${CLR_RST}"
  exit 0
fi

echo -e "${CLR_BLU}Checking Lua scripts in $SCRIPT_DIR...${CLR_RST}"

for file in "${FILES[@]}"; do
  ((CHECKED_COUNT++))
  # 1. Check if the EXACT line exists ANYWHERE in the file
  # Using -F for fixed string and -x for exact line match
  if grep -q -F -x "$REQUIRED_LINE" "$file"; then
    # Exact line exists. Check if the first line IS that exact line.
    if head -n 1 "$file" | grep -q -F -x "$REQUIRED_LINE"; then # Use exact match here too
        echo -e "${CLR_GRN}OK:       $file${CLR_RST} (require already on first line)"
    else
        # Found exactly, but not on line 1. Don't modify.
        echo -e "${CLR_CYN}OK:       $file${CLR_RST} (require found exactly, but not on first line - consider moving manually?)"
    fi
  else
    # 2. Exact line not found anywhere, insert it at the beginning
    echo -e "${CLR_YLW}MODIFIED: $file${CLR_RST} (Exact require line not found, adding to line 1; backup created as ${file}.bak)"
    sed -i.bak "1i $REQUIRED_LINE" "$file"
    if [ $? -eq 0 ]; then
      MODIFIED_FILES+=("$file")
      ((MODIFIED_COUNT++))
    else
      echo -e "${CLR_RED}ERROR: Failed to modify $file${CLR_RST}" >&2
      rm -f "${file}.bak"
      ((ERROR_COUNT++))
    fi
  fi
done

echo "----------------------------------------"
echo "Checked: $CHECKED_COUNT files"
echo "Attempted Modifications: $MODIFIED_COUNT files"

if [ $ERROR_COUNT -gt 0 ]; then
  echo -e "${CLR_RED}Errors during modification: $ERROR_COUNT files${CLR_RST}" >&2
  # Don't proceed with confirmation/restore if errors occurred during sed
  exit 1
fi

# --- Confirmation Step ---
if [ $MODIFIED_COUNT -gt 0 ]; then
  echo ""
  echo -e "${CLR_CYN}The following files were modified (backups ending in .bak created):${CLR_RST}"
  for modified_file in "${MODIFIED_FILES[@]}"; do
      printf "  - %s\n" "$modified_file"
  done
  echo ""
  echo -e "${CLR_CYN}Please review the changes made to these files.${CLR_RST}"

  while true; do
    # Use cyan for the prompt
    read -p "$(echo -e "${CLR_CYN}Keep the changes? (yes/no):${CLR_RST} ")" yn
    case $yn in
        [Yy]* )
            echo -e "${CLR_GRN}Finalizing changes (removing backups)...${CLR_RST}"
            for modified_file in "${MODIFIED_FILES[@]}"; do
                rm -f "${modified_file}.bak"
                if [ $? -ne 0 ]; then
                     echo -e "${CLR_YLW}WARN: Failed to remove backup ${modified_file}.bak${CLR_RST}" >&2
                fi
            done
            echo -e "${CLR_GRN}Backups removed.${CLR_RST}"
            break;;
        [Nn]* )
            echo -e "${CLR_YLW}Restoring from backups...${CLR_RST}"
            RESTORE_ERRORS=0
            for modified_file in "${MODIFIED_FILES[@]}"; do
                if [ -f "${modified_file}.bak" ]; then
                    mv "${modified_file}.bak" "$modified_file"
                     if [ $? -ne 0 ]; then
                         echo -e "${CLR_RED}ERROR: Failed to restore backup for $modified_file${CLR_RST}" >&2
                         ((RESTORE_ERRORS++))
                     fi
                else
                     echo -e "${CLR_RED}ERROR: Backup file ${modified_file}.bak not found!${CLR_RST}" >&2
                      ((RESTORE_ERRORS++))
                fi
            done
            if [ $RESTORE_ERRORS -eq 0 ]; then
                 echo -e "${CLR_GRN}All files restored from backups.${CLR_RST}"
            else
                 echo -e "${CLR_RED}Errors occurred during restore. Please check manually.${CLR_RST}" >&2
                 exit 1 # Exit with error if restore failed
            fi
            exit 2 # Exit with specific code indicating restoration happened
            break;;
        * ) echo -e "${CLR_YLW}Please answer yes or no.${CLR_RST}";;
    esac
  done
else
  echo -e "${CLR_GRN}No modifications were needed.${CLR_RST}"
fi

echo "----------------------------------------"
echo -e "${CLR_BLU}Script finished.${CLR_RST}"
exit 0 