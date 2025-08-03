#!/usr/bin/env python3
import os
import sys
import subprocess
import time
from pathlib import Path


class PumlWatcher:
    def __init__(self, files, invert_colors=False):
        self.files = [Path(f).absolute() for f in files]
        self.invert_colors = invert_colors
        self.file_mtimes = {f: self.get_mtime(f) for f in self.files}

    def get_mtime(self, filepath):
        try:
            return filepath.stat().st_mtime
        except FileNotFoundError:
            return None

    def check_files(self):
        changed = []
        for filepath in self.files:
            current_mtime = self.get_mtime(filepath)
            if current_mtime and current_mtime != self.file_mtimes.get(filepath):
                changed.append(filepath)
                self.file_mtimes[filepath] = current_mtime
        return changed

    def process_puml(self, puml_file):
        svg_file = puml_file.with_suffix(".svg")
        print(f"Regenerating {svg_file}...")

        try:
            subprocess.run(["plantuml", "-tsvg", str(puml_file)], check=True)
            if self.invert_colors:
                print(f"Inverting colors in {svg_file}...")
                subprocess.run(["invert-colors", str(svg_file)], check=True)
        except subprocess.CalledProcessError as e:
            print(f"Error processing {puml_file}: {e}")

    def watch(self):
        print(f"Watching {len(self.files)} file(s)...")
        try:
            while True:
                changed = self.check_files()
                for filepath in changed:
                    self.process_puml(filepath)
                time.sleep(1)
        except KeyboardInterrupt:
            print("\nStopping watcher...")


def main():
    invert_colors = False
    puml_files = []

    for arg in sys.argv[1:]:
        if arg in ["-i", "--invert"]:
            invert_colors = True
        elif arg.endswith(".puml"):
            if os.path.isfile(arg):
                puml_files.append(arg)
            else:
                print(f"Warning: File {arg} does not exist", file=sys.stderr)
        else:
            print(f"Warning: Skipping non-PUML file {arg}", file=sys.stderr)

    if not puml_files:
        print("Usage: ./watch-puml.py [-i] file1.puml [file2.puml ...]")
        print("Error: No valid .puml files specified", file=sys.stderr)
        sys.exit(1)

    for cmd in ["plantuml", "invert-colors"] if invert_colors else ["plantuml"]:
        if not shutil.which(cmd):
            print(f"Error: Command '{cmd}' not found in PATH", file=sys.stderr)
            sys.exit(1)

    print("Watching for changes in:")
    for file in puml_files:
        print(f"  - {file}")
    print(f"Color inversion: {'ON' if invert_colors else 'OFF'}")

    watcher = PumlWatcher(puml_files, invert_colors)
    for file in puml_files:
        watcher.process_puml(Path(file))

    watcher.watch()


if __name__ == "__main__":
    import shutil

    main()
