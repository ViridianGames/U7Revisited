#!/bin/bash
# Script to remove the fork-specific note from README.md before creating a PR.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." &> /dev/null && pwd)"
README_FILE="${PROJECT_ROOT}/README.md"

START_MARKER='<!-- FORK_NOTE_START -->'
END_MARKER='<!-- FORK_NOTE_END -->'

echo "Preparing ${README_FILE} for PR by removing fork note..."

# Use sed to delete the block between the markers (inclusive)
# -i modifies the file in-place
# The command finds the start marker, then deletes until the end marker
sed -i "/${START_MARKER}/,/${END_MARKER}/d" "${README_FILE}"

if [ $? -eq 0 ]; then
  echo "Fork note removed successfully."
  echo "Please review README.md and commit the changes."
else
  echo "Error removing fork note. Check markers in ${README_FILE}." >&2
  exit 1
fi

exit 0 