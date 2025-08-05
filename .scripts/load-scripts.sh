#!/bin/bash

# Check for directory argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <source-directory>"
    exit 1
fi

source_dir="$1"
target_dir="/usr/local/bin"
list_file="$source_dir/.script_list"

# Verify source directory exists
if [ ! -d "$source_dir" ]; then
    echo "Error: Directory '$source_dir' does not exist" >&2
    exit 1
fi

# Create .script_list if it doesn't exist
if [ ! -f "$list_file" ]; then
    touch "$list_file"
fi

# Read previous script names
previous_scripts=()
if [ -s "$list_file" ]; then
    mapfile -t previous_scripts < "$list_file"
fi

# Get current executables (without extensions)
current_scripts=()
while IFS= read -r -d $'\0' file; do
    filename=$(basename -- "$file")
    script_name="${filename%.*}"
    current_scripts+=("$script_name")
done < <(find "$source_dir" -maxdepth 1 -type f -executable -print0)

# Copy new executables (without extensions) to /usr/local/bin
for script_name in "${current_scripts[@]}"; do
    executable=$(find "$source_dir" -maxdepth 1 -type f -executable -name "$script_name.*" -print -quit)
    if [ -n "$executable" ]; then
        echo "Installing: $script_name"
        sudo cp -p "$executable" "$target_dir/$script_name"
    fi
done

# Remove orphaned scripts (in .script_list but not in current_scripts)
for old_script in "${previous_scripts[@]}"; do
    if [[ ! " ${current_scripts[*]} " =~ " $old_script " ]]; then
        echo "Removing orphaned script: $old_script"
        sudo rm -f "$target_dir/$old_script"
    fi
done

# Update .script_list with current script names
printf "%s\n" "${current_scripts[@]}" > "$list_file"

echo "Sync complete. Current scripts:"
printf " - %s\n" "${current_scripts[@]}"
