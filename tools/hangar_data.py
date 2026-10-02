"""The hangar page's generated data and its publish map.

The hangar page (tools/hangar.html) renders the codex, the content editor, the names list
and the renders from files published beside it, so one republish refreshes every tab.
This writes the one piece the browser cannot read for itself, the hp_<n> pins each built
model carries (docs/hangar/pins.json, from art/models/<chassis>.glb), checks the renders
manifest (docs/hangar/renders.json) against the files on disk, and prints the `files` map
to pass to the Artifact tool, published path to source path. Run it after a content, model
or render change, then publish tools/hangar.html with the printed map to the page's URL.

    python3 tools/hangar_data.py            # write pins.json, check the manifest, print the map
    python3 tools/hangar_data.py --check    # check only, no write
"""
import json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONTENT = ["chassis", "components", "foes", "factions", "vocabulary", "reserved_names"]


def model_pins(cid):
    """The hp_<n> pins the built model carries, or None when there is no model yet."""
    path = os.path.join(ROOT, "art", "models", cid + ".glb")
    if not os.path.exists(path):
        return None
    return sorted(set(int(n) for n in re.findall(rb'"hp_(\d+)"', open(path, "rb").read())))


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
