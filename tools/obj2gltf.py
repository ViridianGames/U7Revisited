#!/usr/bin/env -S blender -b -P

# Blender command-line script to convert Wavefront OBJ files to glTF.
#
# Usage:
#   obj2gltf.py -- whatsit.obj

import argparse
import bpy
import os
import sys

# Get command line arguments
parser = argparse.ArgumentParser()
parser.add_argument("infile", help="Input OBJ file")
parser.add_argument("--json", action="store_true", help="Output separate JSON glTF")
parser.add_argument("outfile", nargs="?", default=None, help="glTF output file path (optional)")

try:
    argv = sys.argv
    # Get all args after '--'.
    # The custom arguments must be preceded with '--' or Blender will
    # interpret them as its own arguments.
    argv = argv[argv.index("--") + 1:]

    args = parser.parse_args(argv)

    if args.outfile is None:
        outfile = os.path.splitext(args.infile)[0]
    else:
        outfile = args.outfile
except:
    print("Usage: obj2gltf.py -- <input_file> <output_file>")
    sys.exit(1)

# Clear default scene
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()

# Import OBJ file
bpy.ops.wm.obj_import(filepath=args.infile)

# Output binary or separate glTF based on command line flags.
if args.json:
    output_format = 'GLTF_SEPARATE'
else:
    output_format = 'GLB'

# Export the glTF
bpy.ops.export_scene.gltf(filepath=outfile, export_format=output_format)
