#!/usr/bin/env python3
import re
import sys
import os
from pathlib import Path


def parse_color_file(file_path):
    color_dict = {}
    with open(file_path, "r") as f:
        for line in f:
            line = line.strip()
            if not line or "=" not in line:
                continue
            key, value = line.split("=", 1)
            color_dict[key.strip()] = value.strip()
    return color_dict


def replace_colors_in_file(color_dict, target_path):
    with open(target_path, "r") as f:
        lines = f.readlines()

    pattern_annotation = r"@@([a-zA-Z0-9_]+)@@"
    pattern_hex = r"(#[\da-fA-F]{6})"
    updated_lines = []
    pending_replacement = None

    for line in lines:
        current_line = line

        # Process pending replacement from the previous line
        if pending_replacement is not None:
            hex_match = re.search(pattern_hex, current_line)
            if hex_match:
                current_line = current_line.replace(
                    hex_match.group(1), pending_replacement, 1
                )
            pending_replacement = None

        # Process annotations in the current line
        annotations = re.findall(pattern_annotation, current_line)
        if annotations:
            replacement_value = None
            for annot in annotations:
                if annot in color_dict:
                    replacement_value = color_dict[annot]
                    break

            if replacement_value:
                hex_match = re.search(pattern_hex, current_line)
                if hex_match:
                    current_line = current_line.replace(
                        hex_match.group(1), replacement_value, 1
                    )
                else:
                    pending_replacement = replacement_value
            updated_lines.append(current_line)
        else:
            updated_lines.append(current_line)

    with open(target_path, "w") as f:
        f.writelines(updated_lines)


def generate_css(color_entries):
    """Generate CSS content from color dictionary"""
    return [f"@define-color {key} {value};" for key, value in color_entries]


def generate_env(color_entries):
    """Generate environment file content from color dictionary"""
    groups = {}
    prefix_order = []
    for key, value in color_entries:
        prefix = key.split("_")[0]
        if prefix not in groups:
            prefix_order.append(prefix)
            groups[prefix] = []
        groups[prefix].append((key, value))

    lines = []
    for i, prefix in enumerate(prefix_order):
        for key, value in groups[prefix]:
            env_key = "COLOR_" + key.upper()
            env_value = value.lstrip("#")
            lines.append(f"export {env_key}='{env_value}'")
        if i < len(prefix_order) - 1:
            lines.append("")
    return lines


def generate_toml(color_entries):
    """Generate TOML content from color dictionary"""
    lines = ["[palettes.colors]"]
    lines.extend(f"{key} = '{value}'" for key, value in color_entries)
    return lines


# Generator mapping
generators = {
    "css": generate_css,
    "env": generate_env,
    "toml": generate_toml,
}


def ensure_directory_exists(filepath):
    """Ensure the directory for the target file exists"""
    path = Path(filepath)
    if len(path.parts) > 1:  # Only if path contains directories
        path.parent.mkdir(parents=True, exist_ok=True)


def generate_file(color_dict, target_path):
    """Generate a new file at the specified path using the appropriate format"""
    # Convert to sorted list of items for consistent output
    color_entries = sorted(color_dict.items())

    # Get file extension
    ext = Path(target_path).suffix.lstrip(".").lower()

    # Get appropriate generator
    generator = generators.get(ext)
    if not generator:
        supported = ", ".join(generators.keys())
        print(f"Unsupported file format: {ext} for {target_path}")
        print(f"Supported formats: {supported}")
        return False

    # Ensure directory exists
    ensure_directory_exists(target_path)

    # Generate and write content
    content = generator(color_entries)
    with open(target_path, "w") as f:
        f.write("\n".join(content))

    return True


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <color_file_path> <target_file_path>")
        sys.exit(1)

    color_file = sys.argv[1]
    target_instruction_file = sys.argv[2]

    color_dict = parse_color_file(color_file)
    make_targets = []
    replace_targets = []

    # Process the .target file
    with open(target_instruction_file, "r") as f:
        for line in f:
            # Strip whitespace and skip empty lines and comments
            clean_line = line.strip()
            if not clean_line or clean_line.startswith("#"):
                continue

            # Split into command and path
            parts = clean_line.split(maxsplit=1)
            if len(parts) < 2:
                continue  # Skip malformed lines

            command, path = parts[0], parts[1].strip()
            # Expand ~ to absolute path
            expanded_path = os.path.expanduser(path)

            if command == "make":
                make_targets.append(expanded_path)
            elif command == "replace":
                replace_targets.append(expanded_path)

    # Process replacement targets
    for target_file in replace_targets:
        replace_colors_in_file(color_dict, target_file)
        print(f"Successfully updated colors in {target_file}")

    # Process make targets
    for target_file in make_targets:
        if generate_file(color_dict, target_file):
            print(f"Successfully generated: {target_file}")
