#!/bin/bash

# Check for directory argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <source-directory>"
    exit 1
fi

source_dir="$1"
target_dir="/usr/local/bin"

# Verify source directory exists
if [ ! -d "$source_dir" ]; then
    echo "Error: Directory '$source_dir' does not exist" >&2
    exit 1
fi

# Confirm destructive action
read -p "This will DELETE ALL FILES in $target_dir. Continue? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Clear target directory
echo "Clearing $target_dir..."
sudo rm -rf "$target_dir"/* 2>/dev/null
sudo rm -rf "$target_dir"/.* 2>/dev/null  # Remove dotfiles too

# Process each executable file
find "$source_dir" -maxdepth 1 -type f -executable -print0 | while IFS= read -r -d $'\0' file; do
    # Get filename without path
    filename=$(basename -- "$file")
    
    # Remove extension
    newname="${filename%.*}"
    
    # Skip if filename becomes empty after extension removal
    if [ -z "$newname" ]; then
        echo "Warning: Skipping file with no basename: '$filename'" >&2
        continue
    fi
    
    target="$target_dir/$newname"
    
    # Copy with preserved permissions
    echo "Installing: $filename -> $newname"
    sudo cp -p "$file" "$target"
done

echo "Installation complete - $target_dir has been replaced with new executables"
