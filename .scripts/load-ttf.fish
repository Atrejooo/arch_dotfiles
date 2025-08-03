#!/usr/bin/fish

# Check if a file path is provided
if test (count $argv) -eq 0
    echo "Usage: load-ttf path/to/font.ttf"
    exit 1
end

set font_file $argv[1]

# Check if file exists and is a .ttf
if not test -f "$font_file"
    echo "Error: File '$font_file' does not exist."
    exit 1
end
if not string match -q '*.ttf' "$font_file"
    echo "Error: '$font_file' is not a .ttf file."
    exit 1
end

# User-local font directory
set user_font_dir ~/.local/share/fonts
mkdir -p "$user_font_dir"

# Copy font
set font_name (basename "$font_file")
echo "Installing '$font_name' to $user_font_dir/"
cp -v "$font_file" "$user_font_dir/"

# Update font cache
echo "Updating font cache..."
fc-cache -f

# Verify installation
set installed_name (fc-list | grep -i "$font_name")
if test -n "$installed_name"
    echo "Success! Font installed:"
    echo "$installed_name"
else
    echo "Warning: Font installed but not detected in fc-list."
    echo "Try restarting applications or checking the font name."
end
