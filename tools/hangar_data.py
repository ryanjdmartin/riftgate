"""The hangar page's generated data and its publish map.

The hangar page (tools/hangar.html) renders the codex, the content editor, the names list
and the renders from files published beside it, so one republish refreshes every tab.
This writes the one piece the browser cannot read for itself, the hp_<n> pins each built
model carries (docs/hangar/pins.json, from art/models/<chassis>.glb), checks the renders
manifest (docs/hangar/renders.json) against the files on disk, and prints the `files` map
to pass to the Artifact tool, published path to source path. The map carries the Animation
tab too: its script (tools/hangar_motion.js as hangar/motion.js) and every built machine's
model and rig sidecar. An artifact does not serve .glb files, so each model is written as
the same glTF in JSON with its binary embedded (build/hangar/models/<id>.model.json, git
ignores build/; three.js loads it as it would the .glb), and the sidecar goes as it is
(art/models/<id>.rig.json as hangar/models/<id>.rig.json). The silhouette classes go the same
way (art/models/shapes/<class>_<maker>.glb as hangar/models/shapes/<class>_<maker>.model.json),
with a manifest naming them (build/hangar/shapes.json as hangar/shapes.json: the classes in
the engine's order from sim/content_db.gd's SHAPES, the makers from the content), so the
Models tab can show a class alone or fit it to any mount. Run it after a content, model
or render change, then publish tools/hangar.html with the printed map to the page's URL.

    python3 tools/hangar_data.py            # write pins.json and the models' JSON, check the manifest, print the map
    python3 tools/hangar_data.py --check    # check only, no write
"""
import base64, json, os, re, struct, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONTENT = ["chassis", "components", "modules", "foes", "factions", "vocabulary", "reserved_names"]


def model_pins(cid):
    """The hp_<n> pins the built model carries, or None when there is no model yet."""
    path = os.path.join(ROOT, "art", "models", cid + ".glb")
    if not os.path.exists(path):
        return None
    return sorted(set(int(n) for n in re.findall(rb'"hp_(\d+)"', open(path, "rb").read())))


def glb_to_json(src, dst):
    """The glTF in a .glb as one JSON file, its binary chunk a base64 data URI (images stay
    in buffer views, so nothing else moves)."""
    data = open(src, "rb").read()
    if data[:4] != b"glTF":
        raise SystemExit("not a glb: " + src)
    off, doc, binary = 12, None, b""
    while off < len(data):
        length, kind = struct.unpack_from("<II", data, off)
        chunk = data[off + 8:off + 8 + length]
        off += 8 + length
        if kind == 0x4E4F534A:
            doc = json.loads(chunk)
        elif kind == 0x004E4942:
            binary = chunk
    if doc.get("buffers"):
        doc["buffers"][0]["uri"] = "data:application/octet-stream;base64," + base64.b64encode(binary).decode("ascii")
        doc["buffers"][0]["byteLength"] = len(binary)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    with open(dst, "w") as f:
        json.dump(doc, f, separators=(",", ":"))


def main():
    check_only = "--check" in sys.argv
    chassis = json.load(open(os.path.join(ROOT, "content", "chassis.json")))["entries"]
    pins = {e["id"]: model_pins(e["id"]) for e in chassis}
    pins_path = os.path.join(ROOT, "docs", "hangar", "pins.json")
    if not check_only:
        json.dump({"_about": "hp_<n> pins per chassis, read from art/models/<id>.glb by tools/hangar_data.py; null means no model built yet",
                   "pins": pins}, open(pins_path, "w"), indent=1)
    manifest = json.load(open(os.path.join(ROOT, "docs", "hangar", "renders.json")))
    files = {}
    for n in CONTENT:
        files["content/%s.json" % n] = "content/%s.json" % n
    files["hangar/pins.json"] = "docs/hangar/pins.json"
    files["hangar/renders.json"] = "docs/hangar/renders.json"
    files["hangar/motion.js"] = "tools/hangar_motion.js"
    # The foes' combat sprites (4 November, Ryan: the sprites in the hangar's foe list, compared
    # and inventoried): every foe with art, and a manifest saying which sprite is a rough
    # placeholder (tools/placeholder_art.py's table, read as text so no PIL is needed here).
    ph_src = open(os.path.join(ROOT, "tools", "placeholder_art.py")).read()
    placeholders = set(re.findall(r'^\s+"([a-z0-9_]+)": \(\w+, (?:True|False)\),', ph_src, re.M))
    art = {}
    for e in json.load(open(os.path.join(ROOT, "content", "foes.json")))["entries"]:
        src = os.path.join("art", "foes", "%s_combat.png" % e["id"])
        if os.path.exists(os.path.join(ROOT, src)):
            files["hangar/foes/%s.png" % e["id"]] = src
            art[e["id"]] = "placeholder" if e["id"] in placeholders else "picked"
            continue
        # A promoted form wears its hero's sprite until the boss register's is cut (the game's
        # Sprites._foe does the same): published under the form's own path, marked "hero".
        hero = str(e.get("promotes", ""))
        hero_src = os.path.join("art", "foes", "%s_combat.png" % hero)
        if hero and os.path.exists(os.path.join(ROOT, hero_src)):
            files["hangar/foes/%s.png" % e["id"]] = hero_src
            art[e["id"]] = "hero"
    foes_manifest = os.path.join(ROOT, "docs", "hangar", "foes.json")
    if not check_only:
        json.dump({"_about": "Which foes have a combat sprite in art/foes (hangar/foes/<id>.png beside the page) and whether it is a picked render (or a recolour of one), a rough placeholder from tools/placeholder_art.py, or its hero's (a promoted form, until the boss register's is cut); written by tools/hangar_data.py (4 November).",
                   "art": art}, open(foes_manifest, "w"), indent=1)
    files["hangar/foes.json"] = "docs/hangar/foes.json"
    for cid, p in pins.items():
        if p is None:
            continue
        built = os.path.join("build", "hangar", "models", cid + ".model.json")
        if not check_only:
            glb_to_json(os.path.join(ROOT, "art", "models", cid + ".glb"), os.path.join(ROOT, built))
        files["hangar/models/%s.model.json" % cid] = built
        if os.path.exists(os.path.join(ROOT, "art", "models", cid + ".rig.json")):
            files["hangar/models/%s.rig.json" % cid] = "art/models/%s.rig.json" % cid
    # The silhouette classes, every class in every maker's metal, and their manifest.
    shapes_src = open(os.path.join(ROOT, "sim", "content_db.gd")).read()
    classes = [c for c in json.loads(re.search(r'const SHAPES := (\[[^\]]*\])', shapes_src).group(1)) if c != "none"]
    makers = [m["id"] for m in json.load(open(os.path.join(ROOT, "content", "chassis.json")))["makers"]]
    present = {"classes": [], "makers": []}
    for c in classes:
        for m in makers:
            src = os.path.join(ROOT, "art", "models", "shapes", "%s_%s.glb" % (c, m))
            if not os.path.exists(src):
                continue
            built = os.path.join("build", "hangar", "models", "shapes", "%s_%s.model.json" % (c, m))
            if not check_only:
                glb_to_json(src, os.path.join(ROOT, built))
            files["hangar/models/shapes/%s_%s.model.json" % (c, m)] = built
            if c not in present["classes"]:
                present["classes"].append(c)
            if m not in present["makers"]:
                present["makers"].append(m)
    manifest_path = os.path.join("build", "hangar", "shapes.json")
    if not check_only:
        os.makedirs(os.path.dirname(os.path.join(ROOT, manifest_path)), exist_ok=True)
        json.dump({"_about": "the silhouette classes published beside the hangar page, written by tools/hangar_data.py", **present},
                  open(os.path.join(ROOT, manifest_path), "w"), indent=1)
    files["hangar/shapes.json"] = manifest_path
    missing = []
    groups = [b["images"] for b in manifest["classes"]["blocks"]]
    for cid, d in manifest["chassis"].items():
        groups.append(d["images"])
        if d.get("before"):
            groups.append(d["before"]["images"])
        if cid not in pins:
            missing.append("renders.json names a chassis the content has not got: " + cid)
    for g in groups:
        for im in g:
            src = os.path.join("docs", "hangar", "renders", im["file"])
            if not os.path.exists(os.path.join(ROOT, src)):
                missing.append("missing render: " + src)
            files["hangar/renders/" + im["file"]] = src
    for cid in pins:
        if cid not in manifest["chassis"]:
            print("note: no renders yet for", cid, file=sys.stderr)
    if missing:
        print("\n".join(missing), file=sys.stderr)
        sys.exit(1)
    print(json.dumps(files, indent=1))
    print("%d files; pins for %d chassis%s" % (len(files), len(pins), "" if check_only else " written to docs/hangar/pins.json"), file=sys.stderr)


if __name__ == "__main__":
    main()
