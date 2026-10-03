"""Run bl_low.py under Blender as a Python module (the `bpy` wheel) instead of a Blender
binary, for a machine with no Blender installed, a cloud session for one:

    python3.11 -m venv .bpy && .bpy/bin/pip install bpy==5.0.1
    BPY_PYTHON=.bpy/bin/python tools/spriter/.venv/bin/python tools/lowforge/forge.py build badger

forge.py calls this with the same arguments it would give Blender after `--`. The wheel
registers bmesh and mathutils only once bpy is imported, so that happens first here.
"""
import os
import runpy
import sys

import bpy  # noqa: F401  (registers bmesh and mathutils)

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
os.chdir(HERE)
runpy.run_path(os.path.join(HERE, "bl_low.py"), run_name="__main__")
