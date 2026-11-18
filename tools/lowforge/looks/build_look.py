"""Build a proposal's look test (a model in this folder, never content) the way forge.py builds
a unit, then render it through the game's own 3D view with look_shot.gd:

    BPY_PYTHON=<python with the bpy wheel>   # or run this under Blender's own Python
    $BPY_PYTHON tools/lowforge/looks/build_look.py -- --model wslook_v12 --out art/models/wslook_v12.glb --tiles /tmp/tiles
    godot --headless --path . --import
    godot --path . --resolution 360x640 -s tools/lowforge/looks/look_shot.gd -- wslook_v12 wainwright_sutler v12.png 45 30 520 520

The look modules' LOOKS lists are registered into models_low for the run only. Delete the
built art/models/wslook_* and ktlook_* files afterwards: they are look tests, not the game's models.
sheet.py beside this does all of it for a module that carries a SHEET, the cleaning up included."""
import os
import runpy
import sys

import bpy  # noqa: F401  (registers bmesh and mathutils)

HERE = os.path.dirname(os.path.abspath(__file__))
LF = os.path.dirname(HERE)
ROOT = os.path.dirname(os.path.dirname(LF))
argv = sys.argv[sys.argv.index("--") + 1:]
for i, a in enumerate(argv):
    if a in ("--out", "--tiles") and not os.path.isabs(argv[i + 1]):
        argv[i + 1] = os.path.join(ROOT, argv[i + 1])
sys.argv = sys.argv[:sys.argv.index("--") + 1] + argv
sys.path.insert(0, LF)
sys.path.insert(0, HERE)
os.chdir(LF)
import models_low  # noqa: E402

# Every module in this folder that lists LOOKS is registered, so a new round is a new file and
# no edit here. One that fails to import (a round written before a rule the builder now holds,
# or a file mid-edit while several rounds are built side by side) is named and skipped: a look
# is never the game's, so one broken round must not stop another's build.
for path in sorted(os.listdir(HERE)):
    name, ext = os.path.splitext(path)
    if ext != ".py" or name in ("build_look", "sheet"):
        continue
    try:
        module = __import__(name)
    except Exception as e:  # noqa: BLE001
        print("build_look: %s skipped (%s: %s)" % (name, type(e).__name__, e))
        continue
    for n in getattr(module, "LOOKS", []):
        setattr(models_low, n, getattr(module, n))
runpy.run_path(os.path.join(LF, "bl_low.py"), run_name="__main__")
