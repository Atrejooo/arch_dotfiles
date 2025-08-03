#!/usr/bin/env fish

if test (count $argv) -eq 0
    echo "Usage: yank-file <file1> [file2 ...]"
    return 1
end

set -l uri_list
for file in $argv
    set -l file_path (realpath -- "$file" 2>/dev/null)
    if not test -e "$file_path"
        echo "Error: File '$file' does not exist."
        return 1
    end
    set -a uri_list "file://$file_path"
end

# Create a temporary file to hold URIs with trailing newline
set -l tmpfile (mktemp)
printf "%s\n" $uri_list >$tmpfile
#echo >>$tmpfile # Add trailing newline

# Copy to clipboard
wl-copy --type text/uri-list <$tmpfile
rm $tmpfile # Clean up

echo "Copied to clipboard:"
printf "  - %s\n" $uri_list
