#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.8"
# dependencies = [
#     "icecream",
# ]
# ///
"""
Merge two Flameshot configuration files while preserving section boundaries.
Usage: uv run merge_flameshot_configs.py config1.ini config2.ini [output.ini]
"""

import sys
from pathlib import Path
from collections import OrderedDict
from icecream import ic

# Disable icecream output by default
ic.disable()


def parse_ini_file(filepath):
    """Parse INI file and return ordered dict of sections with their key-value pairs."""
    ic(f"Parsing {filepath}")
    sections = OrderedDict()
    current_section = None
    
    with open(filepath, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            
            # Skip empty lines and comments
            if not line or line.startswith('#') or line.startswith(';'):
                continue
            
            # Check if it's a section header
            if line.startswith('[') and line.endswith(']'):
                current_section = line[1:-1]
                if current_section not in sections:
                    sections[current_section] = OrderedDict()
                    ic(f"Found section: {current_section}")
            elif current_section and '=' in line:
                # Parse key-value pair
                key, value = line.split('=', 1)
                sections[current_section][key.strip()] = value.strip()
    
    ic(f"Parsed {len(sections)} sections from {filepath}")
    return sections


def merge_configs(config1, config2):
    """Merge two config dictionaries, with config2 overriding config1."""
    ic("Merging configurations")
    merged = OrderedDict(config1)
    
    for section, items in config2.items():
        if section not in merged:
            merged[section] = OrderedDict()
            ic(f"Adding new section: {section}")
        
        # Update/add items from config2
        for key, value in items.items():
            if key in merged[section] and merged[section][key] != value:
                ic(f"Overriding {section}.{key}: {merged[section][key]} -> {value}")
            merged[section][key] = value
    
    ic(f"Merge complete: {len(merged)} sections total")
    return merged


def write_ini_file(filepath, sections):
    """Write sections to INI file."""
    ic(f"Writing to {filepath}")
    with open(filepath, 'w', encoding='utf-8') as f:
        for section, items in sections.items():
            f.write(f'[{section}]\n')
            for key, value in items.items():
                f.write(f'{key}={value}\n')
            f.write('\n')
    ic(f"Successfully wrote {filepath}")


def main():
    if len(sys.argv) < 3:
        print("Usage: uv run merge_flameshot_configs.py config1.ini config2.ini [output.ini]")
        print("\nMerges two Flameshot config files, with config2 taking precedence.")
        print("If output file is not specified, writes to stdout.")
        sys.exit(1)
    
    config1_path = Path(sys.argv[1])
    config2_path = Path(sys.argv[2])
    output_path = Path(sys.argv[3]) if len(sys.argv) > 3 else None
    
    # Validate input files exist
    if not config1_path.exists():
        print(f"Error: {config1_path} does not exist", file=sys.stderr)
        sys.exit(1)
    
    if not config2_path.exists():
        print(f"Error: {config2_path} does not exist", file=sys.stderr)
        sys.exit(1)
    
    # Parse both configs
    ic(f"Reading {config1_path}")
    config1 = parse_ini_file(config1_path)
    
    ic(f"Reading {config2_path}")
    config2 = parse_ini_file(config2_path)
    
    # Merge configs
    merged = merge_configs(config1, config2)
    
    # Write output
    if output_path:
        # Backup existing file if it exists
        if output_path.exists():
            backup_path = Path(str(output_path) + '.bak')
            ic(f"Backing up {output_path} to {backup_path}")
            output_path.rename(backup_path)
        
        write_ini_file(output_path, merged)
        ic(f"Success: merged config written to {output_path}")
    else:
        # Print to stdout if no output file specified
        for section, items in merged.items():
            print(f'[{section}]')
            for key, value in items.items():
                print(f'{key}={value}')
            print()


if __name__ == '__main__':
    main()
