#!/usr/bin/env python3

import os
import argparse
import uuid


def generate_new_basename(old_basename, new_name, index, use_extension, is_dir):
    if use_extension:
        base_new, ext_new = os.path.splitext(new_name)
        if is_dir:
            if old_basename.startswith("."):
                return f".{base_new}_{index}"
            else:
                return f"{base_new}_{index}"
        else:
            if old_basename.startswith("."):
                return f".{base_new}_{index}{ext_new}"
            else:
                return f"{base_new}_{index}{ext_new}"
    else:
        if old_basename.startswith("."):
            rest = old_basename[1:]
            dot_index = rest.find(".")
            if dot_index == -1:
                return f".{new_name}_{index}"
            else:
                return f".{new_name}_{index}{rest[dot_index:]}"
        else:
            dot_index = old_basename.find(".")
            if dot_index == -1:
                return f"{new_name}_{index}"
            else:
                return f"{new_name}_{index}{old_basename[dot_index:]}"


def main():
    parser = argparse.ArgumentParser(description="Bulk rename files and directories.")
    parser.add_argument(
        "-e",
        "--extension",
        action="store_true",
        help="Specify to provide a full new name (including extension)",
    )
    parser.add_argument(
        "new_name",
        type=str,
        help="New base name (or full name with extension if -e is used)",
    )
    parser.add_argument("files", nargs="+", help="Files and directories to rename")

    args = parser.parse_args()
    use_extension = args.extension
    new_name = args.new_name
    old_paths = args.files

    # Validate all paths exist
    for path in old_paths:
        if not os.path.exists(path):
            raise FileNotFoundError(f"Path does not exist: {path}")

    # Precompute new paths
    new_paths = []
    for i, old_path in enumerate(old_paths):
        old_dir = os.path.dirname(old_path)
        old_basename = os.path.basename(old_path)
        is_dir = os.path.isdir(old_path)
        new_basename = generate_new_basename(
            old_basename, new_name, i, use_extension, is_dir
        )
        new_path = os.path.join(old_dir, new_basename)
        new_paths.append(new_path)

    # Create set of absolute new paths
    abs_new_paths = set(os.path.abspath(p) for p in new_paths)
    temp_renames = {}

    # Pass 1: Move files that would be overwritten to temp locations
    for i, old_path in enumerate(old_paths):
        abs_old = os.path.abspath(old_path)
        if abs_old in abs_new_paths:
            temp_name = os.path.join(
                os.path.dirname(old_path), f"temp_{uuid.uuid4().hex}"
            )
            os.rename(old_path, temp_name)
            temp_renames[abs_old] = temp_name

    # Pass 2: Rename all items to their final names
    for i, old_path in enumerate(old_paths):
        abs_old = os.path.abspath(old_path)
        source = temp_renames.get(abs_old, old_path)
        os.rename(source, new_paths[i])


if __name__ == "__main__":
    main()
