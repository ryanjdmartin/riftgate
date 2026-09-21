"""Lowforge: units in the mid-nineties 3D register, built by code from a brief.

    tools/spriter/.venv/bin/python tools/lowforge/forge.py build badger sparrowhawk   # from models_low.py
    tools/spriter/.venv/bin/python tools/lowforge/forge.py export badger              # from a hand-edited .blend
    godot --headless --path . --import

`build` writes art/models/<id>.glb with the tiles embedded, the tiles as PNGs under
tools/lowforge/tiles/<maker>/ for review, and a working file tools/lowforge/models/<id>.blend
for hand edits in Blender (a rebuild overwrites it; save an edited copy under another name
or stop rebuilding that unit). `export` turns a working file back into the glTF as it is:
add joint_* and hp_* Empties in Blender and they come through, since the engine reads them.
Needs Blender (BLENDER=/path if not in /Applications).
"""

import os
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
BLENDER = os.environ.get("BLENDER", "/Applications/Blender.app/Contents/MacOS/Blender")


def _run(cmd):
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


if __name__ == "__main__":
    if len(sys.argv) < 3 or sys.argv[1] not in ("build", "export"):
        raise SystemExit(__doc__)
    (build if sys.argv[1] == "build" else export)(sys.argv[2:])
