"""Lowforge: units in the mid-nineties 3D register, built by code from a brief.

    tools/spriter/.venv/bin/python tools/lowforge/forge.py build badger sparrowhawk   # from models_low.py
    tools/spriter/.venv/bin/python tools/lowforge/forge.py export badger              # from a hand-edited .blend
    tools/spriter/.venv/bin/python tools/lowforge/forge.py shapes                     # the component silhouette classes, every maker
    godot --headless --path . --import

`build` writes art/models/<id>.glb with the tiles embedded, the tiles as PNGs under
tools/lowforge/tiles/<maker>/ for review, and a working file tools/lowforge/models/<id>.blend
for hand edits in Blender (a rebuild overwrites it; save an edited copy under another name
or stop rebuilding that unit), and art/models/<id>.rig.json beside the glTF: the joints'
axes and limits and the idle acts (`b.joint(..., axis=, limits=)`, `b.act(...)`), which
MechRig reads. `export` turns a working file back into the glTF as it is: add joint_* and
hp_* Empties in Blender and they come through, since the engine reads them (no sidecar).
Needs Blender (BLENDER=/path if not in /Applications), or BPY_PYTHON=<a python with the bpy
wheel> where there is none (bl_bpy.py; a cloud session). glbcmp.py shows a rebuilt model's
geometry unchanged.
"""

import os
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
BLENDER = os.environ.get("BLENDER", "/Applications/Blender.app/Contents/MacOS/Blender")
BPY_PYTHON = os.environ.get("BPY_PYTHON", "")   # a Python with the `bpy` wheel, in place of a Blender binary (bl_bpy.py)


def _run(cmd):
    if BPY_PYTHON:
        cmd = [BPY_PYTHON, str(HERE / "bl_bpy.py"), "--"] + cmd[cmd.index("--") + 1:]
    r = subprocess.run(cmd, capture_output=True, text=True)
    for line in (r.stdout + r.stderr).splitlines():
        if "lowforge" in line or "Traceback" in line or "  File" in line or "Error:" in line:
            print(line)
    if r.returncode != 0:
        print(r.stderr[-2000:])
        raise SystemExit("Blender failed")


def build(names):
    for n in names:
        out = ROOT / "art" / "models" / f"{n}.glb"
        blend = HERE / "models" / f"{n}.blend"
        _run([BLENDER, "-b", "-P", str(HERE / "bl_low.py"), "--", "--model", n, "--out", str(out),
              "--tiles", str(HERE / "tiles"), "--blend", str(blend)])
    print("now: godot --headless --path . --import")


def export(names):
    for n in names:
        src = Path(n) if n.endswith(".blend") else HERE / "models" / f"{n}.blend"
        ident = src.stem
        out = ROOT / "art" / "models" / f"{ident}.glb"
        _run([BLENDER, "-b", "-P", str(HERE / "bl_low.py"), "--", "--blend", str(src), "--out", str(out)])
    print("now: godot --headless --path . --import")


def shapes(_names):
    """The silhouette classes every swapped component wears (models_low.SHAPES), one file a
    class a maker, into art/models/shapes."""
    _run([BLENDER, "-b", "-P", str(HERE / "bl_low.py"), "--", "--shapes", str(ROOT / "art" / "models" / "shapes"),
          "--tiles", str(HERE / "tiles")])
    print("now: godot --headless --path . --import")


def terrain(_names):
    """The battlefield's material tiles, into art/terrain for the 3D columns."""
    _run([BLENDER, "-b", "-P", str(HERE / "bl_low.py"), "--", "--terrain", str(ROOT / "art" / "terrain")])
    print("now: godot --headless --path . --import")


if __name__ == "__main__":
    cmds = {"build": build, "export": export, "terrain": terrain, "shapes": shapes}
    if len(sys.argv) < 2 or sys.argv[1] not in cmds or (sys.argv[1] in ("build", "export") and len(sys.argv) < 3):
        raise SystemExit(__doc__)
    cmds[sys.argv[1]](sys.argv[2:])
