"""A look round's contact sheet in one command (15 November): build each model a look module's
SHEET names, import them, render each view through the game's own 3D view (look_shot.gd), lay
the renders out under their labels as the sheets in docs/looks/ are, and delete the built models
again, since a look test is never content.

    $BPY_PYTHON tools/lowforge/looks/sheet.py siege_looks                    # the module's SHEET into its `out`
    $BPY_PYTHON tools/lowforge/looks/sheet.py siege_looks --project /tmp/copy --only mnlook_siege

Run it under the Python that holds bpy (the README's cloud recipe) with Pillow beside it. With no
display (a cloud session) each render runs under xvfb-run, on the Compatibility renderer.

A module's SHEET:

    SHEET = {"title": "The siege battery, 15 November (look tests, not content)",
             "out": "docs/looks/minerva_siege.png", "cell": (320, 320),
             "rows": [{"model": "mnlook_siege", "label": "The H-tank", "views": ["codex", "above", ("side", 90, 8)]}]}

A view is a name from VIEWS below or (label, yaw, pitch); a row may carry its own "cell". Yaw 0 is
head on, 45 the codex's front three-quarter, 90 its flank with the nose to the right and 180 its
tail; the pitch is the camera's tilt down, so 180 and 75 are from above, nose up. `--project` builds, imports and renders in
another copy of the project (its own .godot), so several rounds built side by side never meet in one
import; the sheet is written under this checkout either way. `--only` renders some of the models,
`--keep` leaves the built files, `--raw <dir>` keeps each render beside the sheet.
"""
import argparse
import os
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
LF = os.path.dirname(HERE)
ROOT = os.path.dirname(os.path.dirname(LF))

VIEWS = {
    "codex": ("codex angle", 45.0, 30.0),
    "above": ("from above", 180.0, 75.0),
    "skirmish": ("skirmish angle", 155.0, 48.0),
    "rear": ("rear three-quarter", 225.0, 30.0),
    "front": ("head on", 0.0, 12.0),
    "side": ("from the side", 90.0, 8.0),
}
GROUND = (236, 238, 242)
INK = (24, 26, 30)
FONT = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"


def run(cmd, cwd=None, seconds=600):
    """A command under the watchdog every headless Godot run wears; its output, and whether it came back clean."""
    p = subprocess.run(["perl", "-e", "alarm %d; exec @ARGV" % seconds] + cmd, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    return p.returncode == 0, p.stdout


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("module")
    ap.add_argument("--project", default=ROOT)
    ap.add_argument("--only", nargs="*", default=None)
    ap.add_argument("--keep", action="store_true")
    ap.add_argument("--raw", default=None)
    ap.add_argument("--out", default=None)
    a = ap.parse_args()

    import bpy  # noqa: F401  (the look modules import mathutils, which bpy registers)
    from PIL import Image, ImageDraw, ImageFont
    sys.path.insert(0, LF)
    sys.path.insert(0, HERE)
    os.chdir(LF)
    module = __import__(a.module)
    sheet = module.SHEET
    project = os.path.abspath(a.project)
    godot = shutil.which("godot") or os.path.expanduser("~/bin/godot")
    work = tempfile.mkdtemp(prefix="looksheet_")
    rows = [r for r in sheet["rows"] if a.only is None or r["model"] in a.only]
    models = []
    for r in rows:
        if r["model"] not in models:
            models.append(r["model"])
    for m in models:
        if "look_" not in m:
            sys.exit("sheet: %s is no look test's name (<maker>look_<name>): this tool deletes what it builds" % m)

    # Build.
    for m in models:
        ok, out = run([sys.executable, os.path.join(HERE, "build_look.py"), "--", "--model", m,
                       "--out", os.path.join(project, "art", "models", m + ".glb"), "--tiles", os.path.join(work, "tiles")], seconds=300)
        tail = [line for line in out.splitlines() if line.startswith("lowforge:") or line.startswith("build_look:") or "Error" in line or "error" in line]
        print("\n".join(tail[-6:]))
        if not ok or not os.path.exists(os.path.join(project, "art", "models", m + ".glb")):
            print(out[-3000:])
            sys.exit("sheet: %s did not build" % m)

    try:
        # Import, then render every view.
        ok, out = run([godot, "--headless", "--path", project, "--import"], seconds=900)
        if not ok:
            print(out[-2000:])
            sys.exit("sheet: the import failed")
        wrap = [] if os.environ.get("DISPLAY") else ["xvfb-run", "-a"]
        cells = []   # (row index, label, image path)
        for ri, r in enumerate(rows):
            w, h = r.get("cell", sheet.get("cell", (320, 320)))
            maker = getattr(getattr(module, r["model"]), "maker", "minerva")
            for v in r["views"]:
                label, yaw, pitch = VIEWS[v] if isinstance(v, str) else v
                png = os.path.join(work, "%s_%d_%d.png" % (r["model"], len(cells), ri))
                ok, out = run(wrap + [godot, "--path", project, "--rendering-method", "gl_compatibility", "--resolution", "360x640",
                                      "-s", "tools/lowforge/looks/look_shot.gd", "--", r["model"], maker, png,
                                      str(yaw), str(pitch), str(int(w)), str(int(h))], cwd=project, seconds=180)
                if not ok or not os.path.exists(png):
                    print(out[-2000:])
                    sys.exit("sheet: %s did not render (%s)" % (r["model"], label))
                cells.append((ri, "%s: %s" % (r["label"], label) if r.get("label") else label, png))
                if a.raw:
                    os.makedirs(a.raw, exist_ok=True)
                    shutil.copy(png, os.path.join(a.raw, "%s_%s.png" % (r["model"], label.replace(" ", "_"))))
    finally:
        if not a.keep:
            folder = os.path.join(project, "art", "models")
            for f in os.listdir(folder):
                if any(f == m + ".glb" or f.startswith(m + ".") or f.startswith(m + "_") for m in models):
                    os.remove(os.path.join(folder, f))

    # Lay the sheet out: a title line, then a row a model, each cell its label over its render.
    font = ImageFont.truetype(FONT, 13)
    head = ImageFont.truetype(FONT, 13)
    pad, label_h, title_h = 6, 22, 30
    images = [(ri, label, Image.open(p).convert("RGBA")) for ri, label, p in cells]
    row_ids = sorted({ri for ri, _, _ in images})
    widths = [sum(im.width for ri, _, im in images if ri == k) for k in row_ids]
    heights = [max(im.height for ri, _, im in images if ri == k) for k in row_ids]
    W = max(widths) + pad * 2
    H = title_h + sum(hh + label_h for hh in heights) + pad
    canvas = Image.new("RGB", (W, H), GROUND)
    draw = ImageDraw.Draw(canvas)
    draw.text((pad, 6), sheet["title"], font=head, fill=INK)
    y = title_h
    for k, hh in zip(row_ids, heights):
        x = pad
        for ri, label, im in images:
            if ri != k:
                continue
            draw.text((x, y + 2), label, font=font, fill=INK)
            ground = Image.new("RGBA", im.size, GROUND + (255,))
            canvas.paste(Image.alpha_composite(ground, im).convert("RGB"), (x, y + label_h))
            x += im.width
        y += hh + label_h
    out = a.out or sheet["out"]
    out = out if os.path.isabs(out) else os.path.join(ROOT, out)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    canvas.save(out)
    shutil.rmtree(work, ignore_errors=True)
    print("sheet: %d renders of %d models -> %s (%dx%d)" % (len(cells), len(models), out, W, H))


if __name__ == "__main__":
    main()
