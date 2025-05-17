#!/bin/bash

# Check if a directory is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

DIRECTORY="$1"

# Check if the directory exists
if [ ! -d "$DIRECTORY" ]; then
    echo "Error: Directory '$DIRECTORY' does not exist."
    exit 1
fi

# Find all .lua files in the directory and subdirectories
find "$DIRECTORY" -type f -name "*.lua" | while read -r file; do
    echo "Processing: $file"

    # Create a backup of the original file
    cp "$file" "${file}.bak"
    backup_file="${file}.bak"

    # Use sed to find and replace unknown_0003H calls
    sed -E 's/unknown_0003H\(([[:space:]]*)-?([0-9]+)[[:space:]]*,[[:space:]]*-?([0-9]+)[[:space:]]*\)/switch_talk_to(\3, \2)/g' "$backup_file" > "$file.tmp"

    # Move the temporary file to overwrite the original
    mv "$file.tmp" "$file"
done

echo "Processing complete."
