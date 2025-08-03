#!/usr/bin/env fish

function print_help
    echo "Turns filenames into snake_case."
    echo ""
    echo "Usage:"
    echo "  snake [options] [paths]..."
    echo ""
    echo "Options:"
    echo "  -h"
    echo "    Display help text and exit."
    echo "  -p"
    echo "    Print a preview only instead of applying changes."
    echo "  -r"
    echo "    Recursivey runs on all subdirectories and their content."
    echo "  -q"
    echo "    Do not print log messages."
    echo "  -o"
    echo "    Overwrite existing files."
    echo "  -s"
    echo "    Replace German special characters: ä -> ae, ö -> oe, ü -> ue and ß -> ss."
end

set -g preview false
set -g recursive false
set -g verbose true
set -g overwrite false
set -g special false
set -g paths
set -g recursion_options -r

while set -q argv[1]
    set arg $argv[1]
    # Options
    if string match -rq -- '^-.+$' $arg
        for i in (seq 2 (string length -- $arg))
            set opt (string sub -s $i -l 1 -- $arg)
            switch $opt
                case h
                    print_help
                    exit 0
                case p
                    set preview true
                    set recursion_options "$recursion_options"p
                case r
                    set recursive true
                case q
                    set verbose false
                    set recursion_options "$recursion_options"q
                case o
                    set overwrite true
                    set recursion_options "$recursion_options"o
                case s
                    set special true
                    set recursion_options "$recursion_options"s
                case "*"
                    echo "Invalid option -$opt. Run snake -h for help."
                    exit 1
            end
        end
        # Path
    else
        set paths $paths (realpath -- $arg)
    end
    set -e argv[1]
end

if test $(count $paths) = 0
    echo "No paths specified. Run snake -h for help."
    exit 2
end

for path in $paths
    if not $preview && not test -e $path
        echo "ERROR $path: Does not exist"
        E continue
    end
    # Extract basename
    set -g target $(path basename $path)
    # Replace whitespace with underscore
    set target $(echo $target | sed -E 's/ /_/g')
    # Ensure whitespaces are single
    set target $(echo $target | sed -E 's/_+/_/g')
    # Do not allow whitespaces around hyphen
    set target $(echo $target | sed -E 's/_*-_*/-/g')
    # camelCase / PascalCase to snake_case
    set target $(echo $target | sed -E 's/([a-zäöüß])([A-ZÄÖÜ])/\1_\L\2/g')
    # Remaining upper case to lower case
    set target $(echo $target | sed -E 's/[A-ZÄÖÜ]/\L&/g')
    # If special is set, replace ä, ö, ü, ß
    if $special
        set target $(echo $target | sed -E 's/ä/ae/g; s/ö/oe/g; s/ü/ue/g; s/ß/ss/g')
    end
    # Add directory prefix again
    set target "$(path dirname $path)/$target"
    set was_moved false
    if $preview
        # Print as preview only
        if test $path = $target
            echo "(P) NOP      $path"
        else if test -e $target
            echo "(P) Conflict $path: $target already exists!"
        else
            echo "(P) Move     $path -> $(path basename $target)"
        end
    else if test $path = $target
        # Stop if path and target are the same
        if $verbose
            echo "Unchanged: $path"
        end
    else if not $overwrite && test -e $target
        # Stop if target exists and overwrite is false
        if $verbose
            echo "Cannot rename $path -> $target: File already exists (force with -o)"
        end
    else
        # Move file
        mv $path $target
        set was_moved true
        if $verbose
            echo "Moved: $path -> $target"
        end
    end
    # Recursion
    if $recursive
        set origin $path
        if $was_moved
            set origin $target
        end
        if test -d $origin
            set r_paths $origin/*
            if count $r_paths >/dev/null
                snake $recursion_options $origin/*
            end
        end
    end
end
