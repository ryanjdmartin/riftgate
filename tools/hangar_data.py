"""The hangar page's generated data and its publish map.

The hangar page (tools/hangar.html) renders the codex, the bench, the content editor, the text
and the models from files published beside it, so one republish refreshes every tab. The
Bench reads every brief in docs/briefs/, parsed by tools/hangar_designs.py into
build/hangar/designs.json, and the Text tab (and a Chassis sheet's codex and flavour) every shown
text, listed by tools/hangar_text.py into build/hangar/text.json. This writes the one piece the
browser cannot read for itself, the hp_<n> pins each built
model carries (docs/hangar/pins.json, from art/models/<chassis>.glb), checks the renders
manifest (docs/hangar/renders.json) against the files on disk, and prints the `files` map
to pass to the Artifact tool, published path to source path. The map carries the Models
tab too: its script (tools/hangar_motion.js as hangar/motion.js) and every built machine's
model and rig sidecar. An artifact does not serve .glb files, so each model is written as
the same glTF in JSON with its binary embedded (build/hangar/models/<id>.model.json, git
ignores build/; three.js loads it as it would the .glb), and the sidecar goes as it is
(art/models/<id>.rig.json as hangar/models/<id>.rig.json). The silhouette classes go the same
way (art/models/shapes/<class>_<maker>.glb as hangar/models/shapes/<class>_<maker>.model.json),
and each class's variants beside them, with a manifest naming them (build/hangar/shapes.json as
hangar/shapes.json: the classes in the engine's order from sim/content_db.gd's SHAPES, the
variants and their classes from art/models/shapes/variants.json, the makers from the content),
so the Models tab can show a class or a variant alone or fit a class to any mount. The Foes
tab's formations (20 November, Ryan: "we're tuning around the formations, so I need the
context") read the engine's own rules for a pack, which live in GDScript the browser cannot
read: the boss tiers that scale a commander and an elite, the threat rating by a composition's
size, the ramp's span and the words a move's condition and aim are said in. foe_rules() reads
them out of sim/ into build/hangar/foe_rules.json (hangar/foe_rules.json beside the page) and
checks that ContentDB.scale_boss and ContentDB.foes_for still scale what the page says they do,
failing the run when either has moved. What every piece does, the lines the game's code composes
from a component's numbers and a foe move's (20 November, Ryan: "Bullion fragmenter, for instance,
nowhere lists what it actually DOES in the hangar"), is the game's own words too: readouts() runs
tools/hangar_readouts.gd headless into build/hangar/readouts.json (hangar/readouts.json), so
Godot must be on the PATH and the project imported once. Run it after a content, model or render
change, then publish tools/hangar.html with the printed map to the page's URL.

    python3 tools/hangar_data.py            # write pins.json and the models' JSON, check the manifest, print the map
    python3 tools/hangar_data.py --check    # check only, no write
"""
import subprocess
import base64, json, os, re, struct, sys

import hangar_designs
import hangar_text

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONTENT = ["chassis", "components", "modules", "foes", "factions", "vocabulary"]
FOE_RULES = os.path.join("build", "hangar", "foe_rules.json")


def gd_source(rel):
    return open(os.path.join(ROOT, rel), encoding="utf-8").read()


def gd_const(src, name, rel):
    """A GDScript constant's value, an int, a float, a string or a literal array or dictionary
    of them, as JSON reads it: the bracketed literal taken whole, its comments and trailing
    commas dropped."""
    m = re.search(r"^const %s\s*:?=\s*" % re.escape(name), src, re.M)
    if not m:
        raise SystemExit("%s: const %s not found (tools/hangar_data.py reads it for the hangar's formations)" % (rel, name))
    i = m.end()
    if src[i] not in "[{":
        line = src[i:src.index("\n", i)]
        return json.loads(re.sub(r"\s*#.*$", "", line).strip())
    depth, j, in_str = 0, i, False
    while j < len(src):
        ch = src[j]
        if in_str:
            if ch == "\\":
                j += 1
            elif ch == '"':
                in_str = False
        elif ch == '"':
            in_str = True
        elif ch in "[{":
            depth += 1
        elif ch in "]}":
            depth -= 1
            if depth == 0:
                break
        j += 1
    lines = []
    for line in src[i:j + 1].split("\n"):
        out, quoted = "", False
        for k, ch in enumerate(line):
            if ch == '"' and (k == 0 or line[k - 1] != "\\"):
                quoted = not quoted
            if ch == "#" and not quoted:
                break
            out += ch
        lines.append(out)
    return json.loads(re.sub(r",(\s*[\]}])", r"\1", "\n".join(lines)))


def gd_func(src, name):
    """A GDScript function's body, from its signature to the next top-level line."""
    m = re.search(r"^(?:static )?func %s\(.*?$(.*?)(?=^\S)" % re.escape(name), src, re.M | re.S)
    return m.group(1) if m else ""


READOUTS = os.path.join("build", "hangar", "readouts.json")


def readouts():
    """Run tools/hangar_readouts.gd headless into build/hangar/readouts.json: the lines the game's
    code composes for every component and every foe move. Godot must be on the PATH and the
    project imported once (`godot --headless --path . --import`, the README's first run); a
    problem is returned, never a stale file kept."""
    out = os.path.join(ROOT, READOUTS)
    if not os.path.isdir(os.path.join(ROOT, ".godot")):
        return ["readouts: the project has no .godot import yet; run `godot --headless --path . --import` first (README)"]
    if os.path.exists(out):
        os.remove(out)
    try:
        r = subprocess.run(["godot", "--headless", "--path", ROOT, "-s", "tools/hangar_readouts.gd", "--", out],
                           cwd=ROOT, capture_output=True, text=True, timeout=300)
    except FileNotFoundError:
        return ["readouts: no `godot` on the PATH, so the game's own lines for the pieces cannot be written"]
    except subprocess.TimeoutExpired:
        return ["readouts: tools/hangar_readouts.gd ran past five minutes (a script error before quit() hangs Godot)"]
    if r.returncode != 0 or not os.path.exists(out):
        return ["readouts: tools/hangar_readouts.gd failed (exit %d):\n%s" % (r.returncode, (r.stdout + r.stderr)[-2000:])]
    return []


def foe_rules():
    """The engine's rules for a pack as the Foes tab's formations show them, read out of
    sim/, with every way the scaling the page assumes no longer matches the code."""
    db, foe = gd_source("sim/content_db.gd"), gd_source("sim/foe.gd")
    problems = []
    scale = gd_func(db, "scale_boss")
    for what, pat in [("its HP by the tier's hp, rounded", r'f\.hp_max = maxi\(1, roundi\(f\.hp_max \* float\(s\["hp"\]\)\)\)'),
                      ("its attack by the tier's attack", r'f\.attack \+= int\(s\["attack"\]\)'),
                      ("its armour by its armour_step a tier above one", r'f\.armour \+= f\.armour_step \* clampi\(t, 0, BOSS_TIERS\.size\(\) - 1\)')]:
        if not re.search(pat, scale):
            problems.append("ContentDB.scale_boss no longer scales %s as the hangar's formations show it: update SCALING in tools/hangar.html and foe_rules() in tools/hangar_data.py" % what)
    packs = gd_func(db, "foes_for")
    calls = len(re.findall(r"scale_boss\(", packs))
    for what, pat in [("a boss pack's commanders", r"scale_boss\(b, sq\.boss_tier\)"),
                      ("a commander's parts", r"for part in parts_for\(b\):\s*scale_boss\(part, sq\.boss_tier\)"),
                      ("a pack's elite", r"if is_elite\(fid\):\s*scale_boss\(f, sq\.boss_tier\)"),
                      ("an elite's parts, left at their own numbers", r"out\.append_array\(parts_for\(f\)\)")]:
        if not re.search(pat, packs):
            problems.append("ContentDB.foes_for no longer treats %s as the hangar's formations show it: update SCALING in tools/hangar.html and foe_rules() in tools/hangar_data.py" % what)
    if calls != 3:
        problems.append("ContentDB.foes_for calls scale_boss %d times where the hangar's formations expect 3 (a commander, its parts, an elite)" % calls)
    battle = gd_source("sim/battle.gd")
    boss_squad = re.search(r"func make_boss_unit\(.*?\bu\.squad = (\d+)", battle, re.S)
    if not boss_squad:
        problems.append("Battle.make_boss_unit no longer sets its unit's squad: the hangar shows a boss fight's threat rating from it")
    campaign, ramp = gd_source("sim/campaign.gd"), gd_source("sim/ramp.gd")
    rules = {
        "_about": "The engine's rules for a pack, read out of sim/ by tools/hangar_data.py (20 November) for the hangar's formations: never edited by hand. boss_tiers is ContentDB.BOSS_TIERS, index 0 for tier one (ContentDB.scale_boss: HP times hp rounded, attack plus attack, armour plus armour_step a tier above one); scaled says whom ContentDB.foes_for scales; squad_by_size and squad_default are a composition's threat rating where it writes no squad (ContentDB.squad_of), boss_squad a boss fight's (Battle.make_boss_unit); tier_every and ramp_top place a tier on the Convergences (ContentDB.first_ramp_of, Ramp.TOP); final_escort is the tier's own units beside a final's hero (Campaign: the battle's columns less one); when_text and aim_text are how a move's condition and aim are said (Foe.WHEN_TEXT, Foe.AIM_TEXT).",
        "boss_tiers": gd_const(db, "BOSS_TIERS", "sim/content_db.gd"),
        "scaled": {"commanders": True, "commander_parts": True, "elites": True, "elite_parts": False, "rank_and_file": False},
        "squad_by_size": gd_const(db, "SQUAD_BY_SIZE", "sim/content_db.gd"),
        "squad_default": gd_const(db, "SQUAD_DEFAULT", "sim/content_db.gd"),
        "boss_squad": int(boss_squad.group(1)) if boss_squad else 4,
        "composition_sizes": gd_const(db, "COMPOSITION_SIZES", "sim/content_db.gd"),
        "hunt_caveats": gd_const(db, "HUNT_CAVEATS", "sim/content_db.gd"),
        "columns": gd_const(gd_source("sim/skirmish.gd"), "DEFAULT_COLUMNS", "sim/skirmish.gd"),
        "tier_every": gd_const(campaign, "TIER_EVERY", "sim/campaign.gd"),
        "final_after": gd_const(campaign, "FINAL_AFTER", "sim/campaign.gd"),
        "ramp_top": gd_const(ramp, "TOP", "sim/ramp.gd"),
        "when_text": gd_const(foe, "WHEN_TEXT", "sim/foe.gd"),
        "aim_text": gd_const(foe, "AIM_TEXT", "sim/foe.gd"),
        "numbered_riders": gd_const(foe, "NUMBERED_RIDERS", "sim/foe.gd"),
        "action_effects": gd_const(foe, "ACTION_EFFECTS", "sim/foe.gd"),
        "resist": {"default": gd_const(foe, "RESIST_DEFAULT", "sim/foe.gd"), "massive": gd_const(foe, "RESIST_MASSIVE", "sim/foe.gd"),
                   "boss": gd_const(foe, "RESIST_BOSS", "sim/foe.gd")},
    }
    rules["final_escort"] = rules["columns"] - 1
    return rules, problems


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
    # The briefs (5 November; a machine's on its Chassis sheet and the rest on a tab's Briefs since 20 November): every brief in docs/briefs/ parsed
    # by tools/hangar_designs.py into build/hangar/designs.json, a header each checked.
    _docs, problems = hangar_designs.build(check_only)
    if problems:
        print("\n".join(problems), file=sys.stderr)
        sys.exit(1)
    files["hangar/designs.json"] = hangar_designs.OUT
    # The Text tab's inventory (9 November), a Chassis sheet's codex and flavour with it: every shown
    # text as tools/hangar_text.py lists it, with who wrote each from docs/hangar/text.json, into
    # build/hangar/text.json.
    _slots, _groups, problems = hangar_text.build(check_only)
    if problems:
        print("\n".join(problems), file=sys.stderr)
        sys.exit(1)
    files["hangar/text.json"] = hangar_text.OUT
    # The engine's rules for a pack (20 November), for the Foes tab's formations: the boss
    # tiers, the threat rating by size, the ramp's span and the move words, read out of sim/.
    rules, problems = foe_rules()
    if problems:
        print("\n".join(problems), file=sys.stderr)
        sys.exit(1)
    if not check_only:
        os.makedirs(os.path.dirname(os.path.join(ROOT, FOE_RULES)), exist_ok=True)
        with open(os.path.join(ROOT, FOE_RULES), "w", encoding="utf-8") as f:
            json.dump(rules, f, indent=1, ensure_ascii=False)
    files["hangar/foe_rules.json"] = FOE_RULES
    # What every piece does as the game's codex prints it (20 November, Ryan: "Bullion fragmenter,
    # for instance, nowhere lists what it actually DOES in the hangar"): the lines the code
    # composes from a piece's numbers, written by the game's own code (tools/hangar_readouts.gd,
    # run headless here) into build/hangar/readouts.json, so the page never words them itself.
    if not check_only:
        problems = readouts()
        if problems:
            print("\n".join(problems), file=sys.stderr)
            sys.exit(1)
    files["hangar/readouts.json"] = READOUTS
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
    # A class's variants (art/models/shapes/variants.json, lowforge's VARIANTS), published the
    # same way, for the mounts whose sidecar `fits` name one and for the Models tab's Classes.
    vpath = os.path.join(ROOT, "art", "models", "shapes", "variants.json")
    variants = {k: v for k, v in json.load(open(vpath)).items() if not k.startswith("_")} if os.path.exists(vpath) else {}
    present = {"classes": [], "makers": [], "variants": {}}
    for c in classes + list(variants):
        for m in makers:
            src = os.path.join(ROOT, "art", "models", "shapes", "%s_%s.glb" % (c, m))
            if not os.path.exists(src):
                continue
            built = os.path.join("build", "hangar", "models", "shapes", "%s_%s.model.json" % (c, m))
            if not check_only:
                glb_to_json(src, os.path.join(ROOT, built))
            files["hangar/models/shapes/%s_%s.model.json" % (c, m)] = built
            if c in variants:
                present["variants"][c] = variants[c]
            elif c not in present["classes"]:
                present["classes"].append(c)
            if m not in present["makers"]:
                present["makers"].append(m)
        # A burn weapon's fire over the class (models_low.BURNS), one file a class.
        src = os.path.join(ROOT, "art", "models", "shapes", "burn_%s.glb" % c)
        if os.path.exists(src):
            built = os.path.join("build", "hangar", "models", "shapes", "burn_%s.model.json" % c)
            if not check_only:
                glb_to_json(src, os.path.join(ROOT, built))
            files["hangar/models/shapes/burn_%s.model.json" % c] = built
    # Where each class's muzzle flare blooms (lowforge's MUZZLES), read as the game reads it.
    files["hangar/models/shapes/muzzles.json"] = os.path.join("art", "models", "shapes", "muzzles.json")
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
        for kept in ("candidate", "before"):   # a cut saved as a candidate final, and the last cut
            if d.get(kept):
                groups.append(d[kept]["images"])
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
