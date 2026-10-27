"""Build a proposal's look test (a model in this folder, never content) the way forge.py builds
a unit, then render it through the game's own 3D view with look_shot.gd:

    BPY_PYTHON=<python with the bpy wheel>   # or run this under Blender's own Python
    $BPY_PYTHON tools/lowforge/looks/build_look.py -- --model wslook_v12 --out art/models/wslook_v12.glb --tiles /tmp/tiles
    godot --headless --path . --import
    godot --path . --resolution 360x640 -s tools/lowforge/looks/look_shot.gd -- wslook_v12 wainwright_sutler v12.png 45 30 520 520

The look modules' LOOKS lists are registered into models_low for the run only. Delete the
built art/models/wslook_* and ktlook_* files afterwards: they are look tests, not the game's models."""
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
import kestrel_looks  # noqa: E402
import kestrel_looks2  # noqa: E402
import kestrel_looks3  # noqa: E402
import kestrel_looks4  # noqa: E402
import models_low  # noqa: E402
import ws_multirotor  # noqa: E402

for module in (ws_multirotor, kestrel_looks, kestrel_looks2, kestrel_looks3, kestrel_looks4):
    for n in module.LOOKS:
        setattr(models_low, n, getattr(module, n))
runpy.run_path(os.path.join(LF, "bl_low.py"), run_name="__main__")
