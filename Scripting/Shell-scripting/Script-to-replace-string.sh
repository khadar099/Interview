#!/bin/bash                            # Use the bash shell to run this script

# ------------ CONFIGURATION ------------
TARGET_DIR="./your-folder"            # Folder to search in (change to your actual folder path)
SEARCH_STRING="khadar"                # The string you want to find
REPLACE_STRING="basha"                # The string you want to replace it with

echo "Starting replacement in directory: $TARGET_DIR"  # Notify user that the script has started

# ------------ FIND & REPLACE LOOP ------------
find "$TARGET_DIR" -type f \                      # Find all files (not directories) in the target folder
  -exec grep -Il "$SEARCH_STRING" {} \; |         # For each file, check if it contains the string 'khadar'
while read -r file; do                             # Loop over each matching file

    echo "Updating file: $file"                   # Show which file is being processed

    sed -i "s/$SEARCH_STRING/$REPLACE_STRING/g" "$file"  # Replace all instances of 'khadar' with 'basha' in-place

done                                               # End of while loop

echo "Replacement complete."                       # Final message after all files have been processed
