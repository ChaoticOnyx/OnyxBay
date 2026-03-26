#!/usr/bin/env python
"""
Strips station infrastructure from a .dmm map file for Bomb Defusal arena use.
Removes pipes, cables, atmos, alarms, loose items, mobs, etc.
Keeps walls, floors, doors (with access stripped), windows, machines, furniture.

Usage:
    python bombdefusal_strip_map.py input.dmm output.dmm
    python bombdefusal_strip_map.py input.dmm                    # overwrites in-place
    python bombdefusal_strip_map.py input.dmm output.dmm --aggressive  # strip more aggressively
"""

import re
import sys

# Prefixes of types to DELETE completely
STRIP_PREFIXES = [
    # Atmos
    "/obj/machinery/atmospherics",        # All pipes, pumps, mixers, vents, scrubbers
    "/obj/machinery/alarm",               # Air alarms
    "/obj/machinery/firealarm",           # Fire alarms
    "/obj/machinery/portable_atmospherics",

    # Power
    "/obj/structure/cable",               # Power cables
    "/obj/machinery/power",               # APCs, SMESs, generators, solars

    # Disposal
    "/obj/machinery/disposal",
    "/obj/structure/disposalpipe",
    "/obj/structure/disposaloutlet",
    "/obj/structure/disposaljunction",
    "/obj/structure/c_transit",

    # Turrets & security auto
    "/obj/machinery/turretid",
    "/obj/machinery/porta_turret",
    "/obj/machinery/flasher",

    # Telecomms
    "/obj/machinery/telecomms",

    # Cameras
    "/obj/machinery/camera",

    # Loose items on floor
    "/obj/item",

    # Decals / cleanable
    "/obj/effect/decal/cleanable",

    # Job spawn landmarks (we use our own)
    "/obj/effect/landmark/start",

    # Mobs
    "/mob/living/simple_animal",
    "/mob/living/carbon",

    # Reagent dispensers (water tanks, fuel tanks)
    "/obj/structure/reagent_dispensers",

    # Closets/lockers
    "/obj/structure/closet",

    # Crates
    "/obj/structure/largecrate",

    # Flora
    "/obj/structure/flora",

    # Signs, posters
    "/obj/structure/sign",
]

# Additional prefixes for aggressive mode
AGGRESSIVE_EXTRA_STRIP = [
    "/obj/machinery/computer",
    "/obj/machinery/vending",
    "/obj/machinery/teleport",
    "/obj/machinery/requests_console",
    "/obj/machinery/newscaster",
    "/obj/machinery/status_display",
    "/obj/machinery/ai_status_display",
    "/obj/machinery/suit_storage_unit",
    "/obj/machinery/cryopod",
    "/obj/machinery/recharger",
    "/obj/machinery/cell_charger",
    "/obj/machinery/door_timer",
    "/obj/machinery/sleeper",
    "/obj/machinery/optable",
    "/obj/machinery/body_scanconsole",
    "/obj/machinery/bodyscanner",
    "/obj/machinery/chem_dispenser",
    "/obj/machinery/chem_master",
    "/obj/machinery/gibber",
    "/obj/machinery/microwave",
    "/obj/machinery/smartfridge",
    "/obj/machinery/reagentgrinder",
    "/obj/machinery/photocopier",
    "/obj/machinery/fax",
    "/obj/machinery/hologram",
    "/obj/machinery/mineral",
    "/obj/machinery/autolathe",
    "/obj/effect/floor_decal",
    "/obj/structure/bookcase",
    "/obj/structure/filingcabinet",
    "/obj/structure/bed",  # but NOT /obj/structure/bed/chair
]

# In aggressive mode, these are still kept even if parent matches AGGRESSIVE_EXTRA_STRIP
AGGRESSIVE_KEEP_EXCEPTIONS = [
    "/obj/structure/bed/chair",
]

# Door-related type prefixes where we strip access vars
DOOR_PREFIXES = [
    "/obj/machinery/door",
]

# Var names to strip from doors
DOOR_STRIP_VARS = [
    "req_access",
    "req_one_access",
]


def parse_tile_objects(definition_str):
    """Parse a tile definition string into individual object entries."""
    definition_str = definition_str.strip()
    if definition_str.startswith("(") and definition_str.endswith(")"):
        definition_str = definition_str[1:-1]

    objects = []
    depth = 0
    current = ""
    for ch in definition_str:
        if ch == "{":
            depth += 1
            current += ch
        elif ch == "}":
            depth -= 1
            current += ch
        elif ch == "," and depth == 0:
            obj = current.strip()
            if obj:
                objects.append(obj)
            current = ""
        else:
            current += ch
    obj = current.strip()
    if obj:
        objects.append(obj)
    return objects


def get_type_path(obj_str):
    """Extract the type path from an object string (strip {var=val} modifiers)."""
    brace = obj_str.find("{")
    if brace != -1:
        return obj_str[:brace].strip()
    return obj_str.strip()


def is_door(type_path):
    """Check if this type is a door."""
    for prefix in DOOR_PREFIXES:
        if type_path.startswith(prefix):
            return True
    return False


def strip_door_access(obj_str):
    """Remove req_access and req_one_access vars from a door's {var} block."""
    brace_start = obj_str.find("{")
    if brace_start == -1:
        return obj_str  # No vars to strip

    brace_end = obj_str.rfind("}")
    if brace_end == -1:
        return obj_str

    type_part = obj_str[:brace_start].strip()
    vars_str = obj_str[brace_start + 1:brace_end].strip()

    # Parse semicolon-separated var assignments
    # Handle nested list() by tracking parens
    var_assignments = []
    depth = 0
    current = ""
    for ch in vars_str:
        if ch == "(":
            depth += 1
            current += ch
        elif ch == ")":
            depth -= 1
            current += ch
        elif ch == ";" and depth == 0:
            assignment = current.strip()
            if assignment:
                var_assignments.append(assignment)
            current = ""
        else:
            current += ch
    assignment = current.strip()
    if assignment:
        var_assignments.append(assignment)

    # Filter out access vars
    kept_vars = []
    for var_assign in var_assignments:
        var_name = var_assign.split("=")[0].strip()
        if var_name not in DOOR_STRIP_VARS:
            kept_vars.append(var_assign)

    if not kept_vars:
        return type_part  # No vars left, just return the type
    return type_part + "{" + "; ".join(kept_vars) + "}"


def should_strip(type_path, aggressive=False):
    """Check if a type should be removed entirely."""
    for prefix in STRIP_PREFIXES:
        if type_path.startswith(prefix):
            return True

    if aggressive:
        # Check aggressive keep exceptions first
        for keep in AGGRESSIVE_KEEP_EXCEPTIONS:
            if type_path.startswith(keep):
                return False
        for prefix in AGGRESSIVE_EXTRA_STRIP:
            if type_path.startswith(prefix):
                return True

    return False


def strip_dmm(input_path, output_path, aggressive=False):
    with open(input_path, "r", encoding="utf-8") as f:
        content = f.read()

    lines = content.split("\n")
    output_lines = []
    stripped_count = 0
    access_stripped = 0
    in_grid = False

    for line in lines:
        if in_grid:
            output_lines.append(line)
            continue

        # Check if this is the start of grid section
        if re.match(r'\(\d+,\d+,\d+\)\s*=\s*\{"', line):
            in_grid = True
            output_lines.append(line)
            continue

        # Check if this is a tile definition
        match = re.match(r'^("[^"]+"\s*=\s*)\((.+)\)\s*$', line)
        if match:
            key_part = match.group(1)
            objects_str = match.group(2)

            objects = parse_tile_objects("(" + objects_str + ")")
            kept = []
            for obj in objects:
                type_path = get_type_path(obj)
                if should_strip(type_path, aggressive):
                    stripped_count += 1
                elif is_door(type_path):
                    new_obj = strip_door_access(obj)
                    if new_obj != obj:
                        access_stripped += 1
                    kept.append(new_obj)
                else:
                    kept.append(obj)

            if kept:
                output_lines.append(key_part + "(" + ",".join(kept) + ")")
            else:
                output_lines.append(line)
        else:
            output_lines.append(line)

    with open(output_path, "w", encoding="utf-8") as f:
        f.write("\n".join(output_lines))

    print(f"Done!")
    print(f"  Objects stripped:       {stripped_count}")
    print(f"  Door access stripped:   {access_stripped}")
    print(f"  Output: {output_path}")


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    aggressive = "--aggressive" in sys.argv
    args = [a for a in sys.argv[1:] if not a.startswith("--")]

    input_path = args[0]
    if len(args) >= 2:
        output_path = args[1]
    else:
        output_path = input_path
        print(f"WARNING: Overwriting {input_path} in-place!")

    mode = "AGGRESSIVE" if aggressive else "NORMAL"
    print(f"Stripping map: {input_path} -> {output_path} (mode: {mode})")
    strip_dmm(input_path, output_path, aggressive)


if __name__ == "__main__":
    main()
