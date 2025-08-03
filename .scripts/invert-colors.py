#!/usr/bin/env python3

import re
import sys


def invert_hex_color(hex_color):
    """Invert a hex color (e.g., #002233 -> #ffddcc)."""
    # Remove '#' and convert to lowercase
    hex_str = hex_color.group(1).lower()

    # Split into RGB components (2 chars each)
    r, g, b = hex_str[0:2], hex_str[2:4], hex_str[4:6]

    # Convert each component to integer (base 16), invert, and clamp to 00-ff
    inverted_r = format(255 - int(r, 16), "02x")
    inverted_g = format(255 - int(g, 16), "02x")
    inverted_b = format(255 - int(b, 16), "02x")

    # Combine into new hex color
    return f"#{inverted_r}{inverted_g}{inverted_b}"


def process_file(filename):
    """Process a file to invert all hex colors."""
    try:
        with open(filename, "r") as file:
            content = file.read()

        # Find and replace all 6-digit hex colors (case-insensitive)
        inverted_content = re.sub(r"#([a-fA-F0-9]{6})", invert_hex_color, content)

        # Write the modified content back to the file
        with open(filename, "w") as file:
            file.write(inverted_content)

        print(f"Successfully inverted colors in {filename}")
    except Exception as e:
        print(f"Error processing file: {e}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python invert-colors.py <file.txt>")
        sys.exit(1)

    input_file = sys.argv[1]
    process_file(input_file)
