"""Lowforge: units in the mid-nineties 3D register, built by code from a brief.

    tools/spriter/.venv/bin/python tools/lowforge/forge.py build honey_badger sparrowhawk
    godot --headless --path . --import
    RIFTGATE_MECH3D_MODEL=honey_badger RIFTGATE_MECH3D_LOOK=tile godot --path . --resolution 360x640 --position 2000,2000 -s tools/hero_shot.gd -- badger minerva out.png front 480 480

Writes art/models/<model>.glb with the tiles embedded, and the tiles as PNGs under
tools/lowforge/tiles for review. Needs Blender (BLENDER=/path if not in /Applications).
"""

import os
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
BLENDER = os.environ.get("BLENDER", "/Applications/Blender.app/Contents/MacOS/Blender")


def build(names):
    for n in names:
        out = ROOT / "art" / "models" / f"{n}.glb"
        cmd = [BLENDER, "-b", "-P", str(HERE / "bl_low.py"), "--", "--model", n, "--out", str(out), "--tiles", str(HERE / "tiles")]
        r = subprocess.run(cmd, capture_output=True, text=True)
        for line in (r.stdout + r.stderr).splitlines():
            if "lowforge" in line or "Error" in line or "Traceback" in line or "  File" in line or "Error:" in line:
                print(line)
        if r.returncode != 0:
            print(r.stderr[-2000:])
            raise SystemExit("Blender failed")
    print("now: godot --headless --path . --import")


if __name__ == "__main__":
    if len(sys.argv) < 3 or sys.argv[1] != "build":
        raise SystemExit(__doc__)
    build(sys.argv[2:])
