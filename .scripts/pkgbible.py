#!/usr/bin/env python3
import subprocess
import sys
import os
import tomlkit
from collections import OrderedDict


def get_explicit_packages():
    """Get explicitly installed packages and foreign packages"""
    explicit = set()
    foreign = set()

    # Get explicitly installed packages
    output = subprocess.check_output(["pacman", "-Qe"]).decode().splitlines()
    for line in output:
        explicit.add(line.split()[0])

    # Get foreign packages (manually installed)
    output = subprocess.check_output(["pacman", "-Qm"]).decode().splitlines()
    for line in output:
        foreign.add(line.split()[0])

    return explicit, foreign


def get_package_descriptions(packages):
    """Get descriptions for a list of packages"""
    descs = {}
    for pkg in packages:
        try:
            output = subprocess.check_output(
                ["pacman", "-Qi", pkg], stderr=subprocess.DEVNULL
            ).decode()
            for line in output.splitlines():
                if line.startswith("Description"):
                    descs[pkg] = line.split(":", 1)[1].strip()
                    break
        except subprocess.CalledProcessError:
            descs[pkg] = f"Description not found for {pkg}"
    return descs


def generate_build_script(doc, file_path):
    """Generate a build script with packages marked with KEEP tag"""
    base_path = os.path.splitext(file_path)[0]
    build_script_path = f"{base_path}_build.sh"

    # Collect packages with KEEP tag
    keep_pkgs = []
    for pkg_name, pkg_data in doc.items():
        if isinstance(pkg_data, tomlkit.items.Table):
            tags = pkg_data.get("tags", [])
            if "KEEP" in [str(tag).strip() for tag in tags]:
                keep_pkgs.append(pkg_name)

    # Write build script
    with open(build_script_path, "w") as f_build:
        f_build.write("#!/bin/sh\n")
        f_build.write("# Auto-generated package installation script\n")
        f_build.write("# Packages marked with KEEP tag in pkgbible.toml\n\n")

        if keep_pkgs:
            f_build.write("sudo pacman -S --needed --noconfirm \\\n")
            for i, pkg in enumerate(keep_pkgs):
                suffix = " \\" if i < len(keep_pkgs) - 1 else ""
                f_build.write(f"    {pkg}{suffix}\n")
        else:
            f_build.write("# No packages with KEEP tag found\n")

    # Make the script executable
    os.chmod(build_script_path, 0o755)


def process_pkgbible(file_path):
    # Get current package information
    explicit, foreign = get_explicit_packages()
    current_pkgs = explicit

    # Initialize TOML document
    if os.path.exists(file_path):
        with open(file_path, "r") as f:
            doc = tomlkit.load(f)
    else:
        doc = tomlkit.document()

    # Process existing entries
    for pkg in list(doc.keys()):
        # Skip non-table entries and comments
        if not isinstance(doc[pkg], tomlkit.items.Table):
            continue

        # Ensure tags exist
        if "tags" not in doc[pkg]:
            doc[pkg]["tags"] = tomlkit.array()

        # Update tags
        tags = [str(t) for t in doc[pkg]["tags"]]

        # Handle REMOVED tag
        if pkg in current_pkgs and "REMOVED" in tags:
            tags.remove("REMOVED")
        elif pkg not in current_pkgs and "REMOVED" not in tags:
            tags.append("REMOVED")

        # Handle FOREIGN tag
        if pkg in foreign and "FOREIGN" not in tags:
            tags.append("FOREIGN")

        # Update tags array
        doc[pkg]["tags"] = tomlkit.array(tags)

    # Find missing packages
    existing_pkgs = set(doc.keys())
    missing_pkgs = current_pkgs - existing_pkgs
    descs = get_package_descriptions(missing_pkgs)

    # Add missing packages
    for pkg in missing_pkgs:
        doc[pkg] = tomlkit.table()
        doc[pkg]["desc"] = descs.get(pkg, f"Description not found for {pkg}")
        doc[pkg]["tags"] = tomlkit.array(["FOREIGN"] if pkg in foreign else [])

    # Write back to file
    with open(file_path, "w") as f:
        f.write(tomlkit.dumps(doc))

    # Generate build script
    generate_build_script(doc, file_path)


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: pkgbible <path-to-pkgbible.toml>")
        sys.exit(1)

    try:
        process_pkgbible(sys.argv[1])
        print(f"Successfully updated {sys.argv[1]} and generated build script")
    except subprocess.CalledProcessError as e:
        print(f"Error executing pacman command: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}")
        sys.exit(1)
