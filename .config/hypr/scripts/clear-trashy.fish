#!/usr/bin/fish

set trash_dir "$HOME/.trashy"

if test -d "$trash_dir"
    echo "Found trash directory at $trash_dir"
    # Delete all contents but keep the directory itself
    rm -rf "$trash_dir"/*
    rm -rf "$trash_dir"/.* 2>/dev/null # Silently ignore . and .. entries
    echo "All contents of $trash_dir have been deleted"
else
    echo "Trash directory $trash_dir does not exist"
end
