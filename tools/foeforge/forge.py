#!/usr/bin/env python3
"""Enemy sprites from an image model, then cut down to what the engine loads.

Two steps, both driven from content/foes.json so the prompts and the file names come from
the same place as the codex text:

    generate   render candidate images for a foe with mflux (FLUX on Apple silicon)
    cut        turn one chosen candidate into art/foes/<id>_combat.png and <id>_map.png

    tools/foeforge/.venv/bin/python tools/foeforge/forge.py generate ghoul --n 4
    tools/foeforge/.venv/bin/python tools/foeforge/forge.py cut tools/foeforge/out/ghoul/ghoul_3.png ghoul
    godot --headless --path . --import

`generate` writes tools/foeforge/out/<id>/<id>_<seed>.png and a contact sheet of the batch.
`cut` keys out the flat background, crops to the figure, scales to the sprite frame (48x64,
elites 64x96, map tokens 16x16 or 40x40 for the colossus), quantises to the faction palette
from the enemy sheet, and adds the one-pixel outline. Nothing overwrites art/foes until you
run `cut`, so the exported sketch grids stay until a candidate beats them.
"""

import argparse
import io
import json
import re
import subprocess
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent.parent
FOES = ROOT / "content" / "foes.json"
SHEET = ROOT / "docs" / "sprites-enemies.html"
OUT = ROOT / "tools" / "foeforge" / "out"
ART = ROOT / "art" / "foes"
MFLUX = ROOT / "tools" / "foeforge" / ".venv" / "bin" / "mflux-generate-flux2"
MFLUX_EDIT = ROOT / "tools" / "foeforge" / ".venv" / "bin" / "mflux-generate-flux2-edit"

MODEL = "flux2-klein-4b"
QUANTIZE = "4"
STEPS = "4"
WIDTH, HEIGHT = 512, 768

# The enemy side is the JRPG genre invading (decided 9 October, bible section 9): the roster
# homages the whole genre, Dragon Quest as much as Final Fantasy, but the art is one style of
# our own (bible section 1, the enemy art row, says it in words). The line below anchors it on
# SNES Final Fantasy IV to VI enemy sprites, the nearest concrete reference a model knows for
# this register; naming Chrono Trigger and Dragon Quest pulled in big heads and clean inking.
STYLE = (
    "16-bit SNES JRPG battle sprite in the style of Final Fantasy IV, V and VI enemies: "
    "ornate, detailed, over-the-top high fantasy, "
    "menacing and played straight, never cute or comic, up to twenty colours, one-pixel dark "
    "outline. " + "{rules}" + " The whole creature in frame, facing toward the viewer's left, "
    "centered, isolated on a solid flat pure white background, no text, no border, no ground shadow."
)
# The party's heroes (decided 9 October): the classic JRPG party seen from the other side,
# levelled and on a quest, drawn in the elaborate Final Fantasy boss register.
HERO_STYLE = (
    "16-bit SNES JRPG boss battle sprite: a hero of a classic JRPG party drawn as a final boss, "
    "elaborate and over the top, in the style of Final Fantasy IV, V and VI boss art: "
    "ornate armour or robes with gold trim and flowing cloth, "
    "heroic and terrifying, a face that is not a recognisable "
    "character, played straight, never cute or chibi. Up to twenty colours, one-pixel dark "
    "outline. " + "{rules}" + " Full body, facing toward the viewer's left, centered, "
    "isolated on a solid flat pure white background, no text, no border, no ground shadow."
)

# The domains of 9 October (content/factions.json). The looks are the overworld biome's;
# the domain reads on the map by its ground, so a sprite's hue is free (bible section 9).
# A mood per domain, never a palette: the domain reads on the map by its ground, so each foe
# keeps the colours its own description implies (a wolf grey, a goblin green).
FACTION_LOOK = {
    "meadow": "the bright, saturated light of a sunny overworld field",
    "waste": "sun-bleached and dusty, hard desert light",
    "marsh": "dim and damp, rust and old bone, lantern light in fog",
    "peak": "lit from inside by heat, black rock and embers",
}
# Sentences that name a source series stay out of the prompt (the homage is the shape and the
# move, never a trademark's design; Ryan, 9 October). They live in content for the designers.
SOURCES = ("Final Fantasy", "Dragon Quest", "Chrono Trigger", "Breath of Fire", "Octopath", "Legend of Dragoon",
           "Golden Sun", "Megami Tensei", "Lunar", "Suikoden", "Wild Arms", "Diablo", "Pit Lord",
           "Hellcaster", "of September", "renamed")


def _without_sources(text):
    keep = [s for s in re.split(r"(?<=[.!?:])\s+", text) if s and not any(n in s for n in SOURCES)]
    return " ".join(keep)

# The enemy sheet's three palettes, kept for the optional snap; the domains borrow the nearest.
PALETTE_FOR = {"meadow": "UND", "waste": "DEM", "marsh": "UND", "peak": "DEM"}
# The frames (decided 9 October, Ryan, from an in-engine comparison at the phone's density):
# 72x96 and 96x144 massive, drawn by the slot at whole device pixels, two a pixel on the 1080
# phone; 48x64 lost the art's detail and 96x128 went uneven and thin-outlined at 1.5.
COMBAT_SIZE = {1: (72, 96), 2: (96, 144)}
MAP_SIZE = {1: (16, 16), 2: (16, 16)}
BIG_MAP = {"bone_dragon": (40, 40)}   # the old three-hex colossus's token; the other bosses take MAP_SIZE until the multi-hex boss returns


def load_foes():
    return {e["id"]: e for e in json.loads(FOES.read_text())["entries"]}


# Ryan's rules of 9 October, after the first full pass, said as what to draw, since a diffusion
# model tends to draw what a prompt says not to. Readability at phone scale is the cut's job,
# never the prompt's: a first try that asked for "a few large simple shapes, little fine detail"
# and dropped "ornate, detailed" turned the painterly SNES register into a TV cartoon (Ryan,
# 9 October), while the September Ghoul read best of all from a detailed, painterly render.
RULES = (
    "Its posture follows its own body plan, so it need not stand upright like a person. "
    "Its eyes are solid glowing or blank shapes without pupils. "
    "It carries only what the description names."
)
STYLE = STYLE.replace("{rules}", RULES)
HERO_STYLE = HERO_STYLE.replace("{rules}", RULES)

# The hero split (decided 9 October): a hero met in its domain's final is the genre's party
# member, a small chibi battle sprite in one slot (CHIBI_SIZE, drawn by the slot at 4x); its
# promoted form at the finale is the boss register, massive, 64x96 (HERO_STYLE above).
CHIBI_STYLE = (
    "16-bit SNES JRPG party member battle sprite with small chibi proportions and a big head, "
    "the hero of a classic JRPG party, simple bold shapes, about twelve colours, one-pixel "
    "dark outline. Full body, facing toward the viewer's left, centered, isolated on a solid "
    "flat pure white background, no text, no border, no ground shadow. A face that is not a "
    "recognisable character, played straight and determined, never comic."
)
CHIBI_SIZE = (36, 48)   # exactly twice the wildlife's pixel beside it: a deliberate party-sprite coarseness, not a mismatch

DOMAIN_NAME = {"meadow": "the grasslands", "waste": "the desert", "marsh": "the swamp and graveyard", "peak": "the volcano"}


def prompt_for(foe):
    look = FACTION_LOOK.get(foe.get("faction", ""), "")
    where = DOMAIN_NAME.get(foe.get("faction", ""), "the overworld")
    # A foe's sprite brief (design.sprite) leads: the model weighs the start of a prompt most,
    # and a brief says the shape (a blob, a ball of fire) the style text would otherwise turn
    # into a muscled body (9 October: every Bomb and Gel came out humanoid without one). With
    # a brief, the codex's rule text stays out; without one, it fills in as before.
    brief = foe.get("design", {}).get("sprite", "")
    fantasy = _without_sources(foe.get("design", {}).get("fantasy", ""))
    body = " ".join(s for s in [fantasy] + ([] if brief else [foe.get("codex", "")]) if s)
    lead = f"{brief[0].upper() + brief[1:]}. " if brief else ""
    if foe.get("hero"):
        return f"{lead}{HERO_STYLE} Subject: {foe['name']}, a hero of the party who comes out of {where}. {body} Light: {look}."
    size = "A towering elite, twice the height of a common foe." if int(foe.get("size") or 1) > 1 else ""
    return f"{lead}{STYLE} Subject: {foe['name']}, a monster of {where}. {body} {size} Light: {look}."


PICKER_HTML = """<!doctype html><html><head><meta charset="utf-8"><title>Foe picker</title>
<style>
:root{--bg:#14171c;--panel:#1d2126;--ink:#e7ebee;--muted:#8a949e;--pick:#f2b233}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--ink);font:15px -apple-system,Helvetica,sans-serif}
header{display:flex;gap:16px;align-items:baseline;padding:12px 20px;border-bottom:1px solid #2e353e}
h1{font-size:22px;margin:0}#pos{color:var(--muted)}#hint{color:var(--muted);margin-left:auto;font-size:13px}
#row{display:flex;gap:14px;padding:16px 20px;overflow-x:auto}
figure{margin:0;flex:0 0 auto;background:#fff;border:4px solid transparent;cursor:pointer;position:relative}
figure .pair{display:flex;align-items:flex-end;gap:0}
figure img.full{display:block;height:min(62vh,700px);width:auto}
figure img.game{display:block;image-rendering:pixelated;background:#5ca848;padding:10px;align-self:stretch;object-fit:contain;object-position:bottom}
#ref{display:flex;align-items:center;gap:8px;color:var(--muted);font-size:13px}
#ref img{image-rendering:pixelated;background:#5ca848;padding:6px;height:140px}
figure.pick{border-color:var(--pick)}
figcaption{position:absolute;left:0;top:0;background:#000c;color:#fff;padding:3px 8px;font-weight:600}
figure.pick figcaption{background:var(--pick);color:#000}
#out{padding:8px 20px 20px;display:flex;gap:10px;align-items:center}
#text{flex:1;background:var(--panel);color:var(--ink);border:1px solid #2e353e;padding:8px;font:13px ui-monospace,Menlo,monospace;min-height:40px}
button{background:var(--pick);border:0;padding:9px 14px;font-weight:600;cursor:pointer}
</style></head><body>
<header><h1 id="name"></h1><span id="pos"></span><span id="hint">1-9 pick and move on &middot; &larr; &rarr; move &middot; 0 clears</span><span id="ref">__REF__</span></header>
<div id="row"></div>
<div id="out"><div id="text"></div><button id="copy">Copy picks</button></div>
<script>
const FOES = __FOES__;
let i = 0, picks = {};
try { picks = JSON.parse(localStorage.getItem('foe-picks') || '{}'); } catch (e) {}
function save(){ try { localStorage.setItem('foe-picks', JSON.stringify(picks)); } catch (e) {} }
function text(){ return FOES.filter(f => picks[f.id]).map(f => f.id + ' ' + picks[f.id]).join(', '); }
function show(){
  const f = FOES[i];
  document.getElementById('name').textContent = f.name;
  document.getElementById('pos').textContent = (i + 1) + ' of ' + FOES.length + ' · ' + f.note;
  const row = document.getElementById('row'); row.innerHTML = '';
  f.cands.forEach((c, k) => {
    const fig = document.createElement('figure');
    if (picks[f.id] === c.label) fig.className = 'pick';
    fig.innerHTML = '<div class="pair"><img class="full" src="' + c.src + '">' + (c.game ? '<img class="game" src="' + c.game + '" style="width:' + c.gw + 'px">' : '') + '</div><figcaption>' + (k + 1) + ' · ' + c.label + '</figcaption>';
    fig.onclick = () => choose(k);
    row.appendChild(fig);
  });
  document.getElementById('text').textContent = text() || 'no picks yet';
}
function choose(k){ const f = FOES[i]; picks[f.id] = f.cands[k].label; save(); if (i < FOES.length - 1) i++; show(); }
document.addEventListener('keydown', e => {
  if (e.key >= '1' && e.key <= '9') { const k = +e.key - 1; if (k < FOES[i].cands.length) choose(k); }
  else if (e.key === '0') { delete picks[FOES[i].id]; save(); show(); }
  else if (e.key === 'ArrowRight') { i = Math.min(FOES.length - 1, i + 1); show(); }
  else if (e.key === 'ArrowLeft') { i = Math.max(0, i - 1); show(); }
});
document.getElementById('copy').onclick = () => { navigator.clipboard.writeText(text()); };
show();
</script></body></html>"""


def game_preview(src, dest, frame, scale):
    """A candidate cut as the game will draw it (its frame, sixteen colours, the outline) and
    blown up by the slot's scale with nearest sampling, cached beside the render: the picker
    shows it so a pick is judged at phone scale, where a face's details do not survive."""
    if dest.exists() and dest.stat().st_mtime >= src.stat().st_mtime:
        return
    c = cut_sprite(key_background(Image.open(src)), frame)
    c.resize((c.width * scale, c.height * scale), Image.NEAREST).save(dest)


def picker(args):
    """One page for picking: every foe's candidates big, one foe at a time, number keys to pick.
    The heroes' chibi renders (<id>_chibi) sit beside their boss register; set-aside first
    rounds (<id>_v1) only with --all. Written into the git-ignored out folder, so the images load by relative path."""
    foes = load_foes()
    order = []
    for fid, foe in foes.items():
        rounds = [("_chibi", "chibi party sprite"), ("", "boss register" if foe.get("hero") else "")]
        for t in args.tags:
            rounds.append((f"_{t}", t))
        if args.all:
            rounds.append(("_v1", "first round"))   # the set-aside first rounds, only on request
        for suffix, note in rounds:
            d = OUT / (fid + suffix)
            cands = sorted(p for p in d.glob(f"{fid}_*.png") if re.fullmatch(rf"{re.escape(fid)}_\d+", p.stem)) if d.is_dir() else []
            if not cands:
                continue
            key = fid + suffix
            # The frame the game draws it at, and the slot's scale (bible section 9, the hero split).
            if suffix == "_chibi":
                frame, scale = CHIBI_SIZE, 4
            elif foe.get("hero") or int(foe.get("size") or 1) > 1:
                frame, scale = COMBAT_SIZE[2], 2
            else:
                frame, scale = COMBAT_SIZE[1], 2
            entry = []
            for p in cands:
                g = p.with_name(f"game_{p.name}")
                game_preview(p, g, frame, scale)
                entry.append({"src": f"{key}/{p.name}", "game": f"{key}/{g.name}", "gw": frame[0] * scale + 20, "label": p.stem.rsplit("_", 1)[1]})
            order.append({"id": key, "name": foe["name"] + (" (chibi)" if suffix == "_chibi" else ""),
                          "note": " ".join(x for x in [foe.get("faction", ""), note] if x), "cands": entry})
    # The old Ghoul (15 September), the one cut that read best at phone scale, as the yardstick.
    ref = ""
    ghoul = OUT / "ghoul" / "ghoul_game_ref.png"
    if not ghoul.exists():
        try:
            data = subprocess.run(["git", "show", "2bd7ffa:art/foes/ghoul_combat.png"], cwd=ROOT, capture_output=True, check=True).stdout
            img = Image.open(io.BytesIO(data))
            ghoul.parent.mkdir(parents=True, exist_ok=True)
            img.resize((img.width * 2, img.height * 2), Image.NEAREST).save(ghoul)
        except (subprocess.CalledProcessError, FileNotFoundError, OSError):
            pass
    if ghoul.exists():
        ref = f'<img src="ghoul/{ghoul.name}">the old Ghoul, at the same scale'
    dest = OUT / "picker.html"
    dest.write_text(PICKER_HTML.replace("__FOES__", json.dumps(order)).replace("__REF__", ref))
    print(f"wrote {dest.relative_to(ROOT)}: {len(order)} sets; open it with: open {dest.relative_to(ROOT)}")


def prompts(args):
    """Every foe's prompt, in content order, into one sheet to read before generating."""
    foes = load_foes()
    have = {p.stem.removesuffix("_combat") for p in ART.glob("*_combat.png")}
    lines = ["# Foeforge prompts", "",
             "Generated by `forge.py prompts` from `content/foes.json`; regenerate after the text changes.",
             "Each foe's prompt is its fantasy and codex text on the fixed brief (the heroes on the boss brief).",
             "`art` says whether `art/foes` holds a sprite for it today (an inherited sketch grid counts).", ""]
    for fid, foe in foes.items():
        kind = "hero" if foe.get("hero") else ("boss" if int(foe.get("size") or 1) > 1 else "foe")
        lines += [f"## {foe['name']} (`{fid}`, {foe.get('faction', '')}, {kind}, art: {'yes' if fid in have else 'no'})", "",
                  "```", prompt_for(foe), "```", ""]
    dest = Path(args.out) if args.out else ROOT / "tools" / "foeforge" / "prompts.md"
    dest.write_text("\n".join(lines))
    print(f"wrote {dest.relative_to(ROOT)}: {len(foes)} prompts")


def chibi_prompt_for(foe):
    brief = foe.get("design", {}).get("sprite", foe["name"])
    return f"{CHIBI_STYLE} The hero: {brief}."


def generate(args):
    foes = load_foes()
    foe = foes[args.foe]
    chibi = getattr(args, "chibi", False)
    if chibi and not foe.get("hero"):
        sys.exit(f"{args.foe} is not a hero; only heroes have a chibi form")
    name = args.foe + ("_chibi" if chibi else "") + (f"_{args.tag}" if args.tag else "")
    out = OUT / name
    out.mkdir(parents=True, exist_ok=True)
    prompt = args.prompt or (chibi_prompt_for(foe) if chibi else prompt_for(foe))
    takes = foe.get("design", {}).get("variants", []) if args.variants else []
    if args.variants and not takes:
        sys.exit(f"{args.foe} has no design.variants")
    (out / "prompt.txt").write_text(prompt + "\n")
    print(prompt)
    height = HEIGHT if int(foe.get("size") or 1) == 1 else 1024
    made = []
    prompts_used = []
    for k, seed in enumerate(range(args.seed, args.seed + args.n)):
        path = out / f"{args.foe}_{seed}.png"
        if path.exists():
            path.unlink()   # mflux never overwrites; it writes a suffixed twin, which the contact sheet would miss
        p = prompt
        if takes:
            # Each candidate its own design take: the brief's shape swapped for the take's, so
            # the four differ in body plan and pose rather than in seed noise (Ryan, 9 October:
            # more creative entropy within the style).
            take = takes[k % len(takes)]
            brief = foe.get("design", {}).get("sprite", "")
            p = prompt.replace(brief[0].upper() + brief[1:], take[0].upper() + take[1:], 1) if brief else f"{take}. {prompt}"
        if args.ref:
            # A style reference through the edit model: the reference is drawn from for its
            # finish only, never its creature.
            p = ("Draw a different creature in exactly the same art style as the reference image: "
                 "the same outline weight, shading, palette approach and level of detail. Do not draw "
                 "the reference's creature. " + p)
            cmd = [str(MFLUX_EDIT), "--model", MODEL, "--quantize", QUANTIZE, "--prompt", p,
                   "--image-paths", args.ref, "--steps", STEPS, "--seed", str(seed), "--output", str(path)]
        else:
            cmd = [str(MFLUX), "--model", MODEL, "--quantize", QUANTIZE, "--prompt", p,
                   "--width", str(WIDTH), "--height", str(height), "--steps", STEPS,
                   "--seed", str(seed), "--output", str(path)]
        prompts_used.append(f"{path.name}: {p}")
        print("rendering", path.name)
        subprocess.run(cmd, check=True)
        made.append(path)
    (out / "prompt.txt").write_text("\n\n".join(prompts_used) + "\n")
    contact(made, out / "contact.png")
    print(f"{len(made)} candidates in {out.relative_to(ROOT)}")


def contact(paths, dest):
    imgs = [Image.open(p).convert("RGB") for p in paths]
    if not imgs:
        return
    w = 256
    h = int(imgs[0].height * w / imgs[0].width)
    sheet = Image.new("RGB", (w * len(imgs), h + 20), (27, 31, 38))
    d = ImageDraw.Draw(sheet)
    for i, (p, im) in enumerate(zip(paths, imgs)):
        sheet.paste(im.resize((w, h), Image.LANCZOS), (i * w, 0))
        d.text((i * w + 4, h + 4), p.stem, fill=(232, 228, 214))
    sheet.save(dest)


# ---------------------------------------------------------------- cut

def parse_palettes():
    text = SHEET.read_text(encoding="utf-8")
    palettes = {}
    for name, body in re.findall(r"var (UND|DEM|ELD) = \{(.*?)\};", text, re.S):
        entries = re.findall(r"'?([^\s:'\",{}]+)'?\s*:\s*'(#[0-9a-fA-F]{6})'", body)
        palettes[name] = [tuple(int(v[i:i + 2], 16) for i in (1, 3, 5)) for _, v in entries]
    return palettes


def key_background(img, tol=48):
    """Alpha out the flat background: anything close to the corner colour, flood-filled from
    the edges so a white detail inside the figure survives."""
    img = img.convert("RGBA")
    w, h = img.size
    px = img.load()
    corners = [px[0, 0], px[w - 1, 0], px[0, h - 1], px[w - 1, h - 1]]
    bg = tuple(sum(c[i] for c in corners) // 4 for i in range(3))

    def near(p):
        return all(abs(p[i] - bg[i]) <= tol for i in range(3))

    seen = bytearray(w * h)
    stack = [(x, 0) for x in range(w)] + [(x, h - 1) for x in range(w)] + [(0, y) for y in range(h)] + [(w - 1, y) for y in range(h)]
    while stack:
        x, y = stack.pop()
        i = y * w + x
        if seen[i] or not near(px[x, y]):
            continue
        seen[i] = 1
        px[x, y] = (0, 0, 0, 0)
        if x > 0:
            stack.append((x - 1, y))
        if x < w - 1:
            stack.append((x + 1, y))
        if y > 0:
            stack.append((x, y - 1))
        if y < h - 1:
            stack.append((x, y + 1))
    return img


def key_holes(img, tol=24, min_area=400):
    """Alpha out pockets of background the edge fill cannot reach (sky between branches, the gap
    between an arm and a body): connected patches within `tol` of the background colour and at
    least `min_area` pixels at the render's size. Opt-in per cut, since a white robe or an eye's
    highlight is the same colour; the area floor spares highlights, not robes."""
    img = img.convert("RGBA")
    w, h = img.size
    px = img.load()
    bg = (255, 255, 255)   # the prompt's flat white; the corners are already keyed by now

    def near(p):
        return p[3] > 0 and all(abs(p[i] - bg[i]) <= tol for i in range(3))

    seen = bytearray(w * h)
    for sy in range(h):
        for sx in range(w):
            if seen[sy * w + sx] or not near(px[sx, sy]):
                continue
            region, stack = [], [(sx, sy)]
            seen[sy * w + sx] = 1
            while stack:
                x, y = stack.pop()
                region.append((x, y))
                for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                    if 0 <= nx < w and 0 <= ny < h and not seen[ny * w + nx] and near(px[nx, ny]):
                        seen[ny * w + nx] = 1
                        stack.append((nx, ny))
            if len(region) >= min_area:
                for x, y in region:
                    px[x, y] = (0, 0, 0, 0)
    return img


def quantize(img, palette, colours=16):
    """Flatten the shading into a few coherent regions (median cut on the opaque pixels),
    then, if a palette is given, snap each region colour to its nearest palette colour.
    Snapping pixel by pixel speckles, because neighbouring shades fall either side of a
    palette boundary; snapping regions keeps the plates flat, the way a pixel artist
    would. With no palette the model's own colours stay, reduced to `colours`."""
    w, h = img.size
    px = img.load()
    # Median cut needs an RGB image. Paint transparent pixels the figure's mean colour so
    # they cost no palette entry and bleed nothing at the edges; alpha is already hard.
    arr = np.array(img)
    opaque = arr[..., 3] >= 128
    fill = arr[opaque][:, :3].mean(axis=0).astype(np.uint8) if opaque.any() else np.zeros(3, np.uint8)
    rgb_arr = arr[..., :3].copy()
    rgb_arr[~opaque] = fill
    rgb = Image.fromarray(rgb_arr, "RGB")
    flat = rgb.quantize(colors=colours, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).convert("RGB")
    fp = flat.load()
    cache = {}
    for y in range(h):
        for x in range(w):
            if px[x, y][3] < 128:
                px[x, y] = (0, 0, 0, 0)
                continue
            r, g, b = fp[x, y]
            if not palette:
                px[x, y] = (r, g, b, 255)
                continue
            if (r, g, b) not in cache:
                cache[(r, g, b)] = min(palette, key=lambda c: (c[0] - r) ** 2 + (c[1] - g) ** 2 + (c[2] - b) ** 2)
            px[x, y] = cache[(r, g, b)] + (255,)
    return img


def source_palette(keyed, colours=16):
    """The palette from the full-size render's opaque pixels, before any shrinking: averaging
    in the shrink washes out highlights and darks, so a palette taken after it is duller."""
    arr = np.array(keyed)
    px = arr[arr[..., 3] >= 128][:, :3]
    if len(px) == 0:
        return [(0, 0, 0)]
    q = Image.fromarray(px.reshape(1, -1, 3), "RGB").quantize(colors=colours, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    pal = q.getpalette()[:colours * 3]
    return [tuple(pal[i:i + 3]) for i in range(0, len(pal), 3)]


def sharpen_quantize(small, keyed, colours=16, amount=60):
    """The gentle sharpen (decided 9 October; Ryan may want it stronger after a phone read):
    after the shrink, an unsharp mask of `amount` percent and a slight contrast lift, then
    every pixel snapped to the full render's own palette. A stronger pass that also kept
    the dark linework speckled the goblin and the mandragora; this one only gives back the
    contrast the shrink averaged away."""
    from PIL import ImageEnhance, ImageFilter
    a = np.array(small)
    opaque = a[..., 3] >= 128
    rgb = Image.fromarray(a[..., :3], "RGB")
    if amount > 0:
        rgb = rgb.filter(ImageFilter.UnsharpMask(radius=1, percent=int(amount), threshold=3))
        rgb = ImageEnhance.Contrast(rgb).enhance(1.0 + 0.08 * amount / 60.0)
    pal = np.array(source_palette(keyed, colours), dtype=np.int32)
    out = np.array(rgb).astype(np.int32)
    idx = ((out[..., None, :] - pal[None, None, :, :]) ** 2).sum(-1).argmin(-1)
    res = np.zeros((a.shape[0], a.shape[1], 4), np.uint8)
    res[..., :3] = pal[idx]
    res[..., 3] = np.where(opaque, 255, 0)
    return Image.fromarray(res, "RGBA")


def cut_sprite(keyed, frame, colours=16, sharpen=60, palette=None):
    """One sprite as the game draws it: fitted to its frame, flattened to `colours` (the
    gentle sharpen with the render's own palette unless a faction palette is asked for or
    `sharpen` is negative, which is the old median cut), and outlined."""
    small = fit(keyed, frame)
    if palette or sharpen < 0:
        return outline(quantize(small, palette, colours))
    return outline(sharpen_quantize(small, keyed, colours, sharpen))


def outline(img, colour=(20, 22, 28, 255)):
    """One-pixel outline around the opaque shape, drawn into transparent neighbours."""
    w, h = img.size
    src = img.load()
    out = img.copy()
    dst = out.load()
    for y in range(h):
        for x in range(w):
            if src[x, y][3] >= 128:
                continue
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h and src[nx, ny][3] >= 128:
                    dst[x, y] = colour
                    break
    return out


def fit(img, frame):
    """Scale the cropped figure into the frame, keeping aspect, feet on the floor, with a
    one-pixel margin for the outline. Transparent pixels are painted the figure's mean
    colour before scaling so edge pixels blend with the figure rather than with black, and
    alpha is hard-thresholded afterwards so nothing is half there."""
    fw, fh = frame
    bbox = img.getbbox()
    fig = np.array(img.crop(bbox)).astype(np.float32)
    opaque = fig[..., 3] >= 128
    if opaque.any():
        mean = fig[opaque][:, :3].mean(axis=0)
        fig[~opaque, :3] = mean
    fig[..., 3] = np.where(opaque, 255.0, 0.0)
    fig_img = Image.fromarray(fig.astype(np.uint8), "RGBA")
    inner = (fw - 2, fh - 2)
    scale = min(inner[0] / fig_img.width, inner[1] / fig_img.height)
    size = (max(1, round(fig_img.width * scale)), max(1, round(fig_img.height * scale)))
    small = np.array(fig_img.resize(size, Image.LANCZOS))
    small[..., 3] = np.where(small[..., 3] >= 128, 255, 0)
    small[small[..., 3] == 0] = 0
    canvas = Image.new("RGBA", frame, (0, 0, 0, 0))
    canvas.paste(Image.fromarray(small, "RGBA"), ((fw - size[0]) // 2, fh - 1 - size[1]))
    return canvas


def cut(args):
    foes = load_foes()
    foe = foes[args.foe]
    pal = parse_palettes()[PALETTE_FOR.get(foe.get("faction", "marsh"), "UND")] if args.faction_palette else None
    src = key_background(Image.open(args.image), args.tol)
    if args.holes:
        src = key_holes(src)
    size = int(foe.get("size") or 1)
    ART.mkdir(parents=True, exist_ok=True)
    frame = CHIBI_SIZE if (foe.get("hero") and size == 1) else COMBAT_SIZE[size]   # a hero in one slot is its chibi
    combat = cut_sprite(src, frame, args.colours, args.sharpen, pal)
    combat.save(ART / f"{args.foe}_combat.png")
    map_frame = BIG_MAP.get(args.foe, MAP_SIZE[size])
    token = outline(quantize(fit(src, map_frame), pal, min(args.colours, 8)))
    token.save(ART / f"{args.foe}_map.png")
    preview = Image.new("RGBA", (combat.width * 4 + token.width * 4 + 24, max(combat.height, token.height) * 4), (27, 31, 38, 255))
    preview.paste(combat.resize((combat.width * 4, combat.height * 4), Image.NEAREST), (0, 0))
    preview.paste(token.resize((token.width * 4, token.height * 4), Image.NEAREST), (combat.width * 4 + 24, 0))
    pv = OUT / args.foe / f"{args.foe}_cut_preview.png"
    pv.parent.mkdir(parents=True, exist_ok=True)
    preview.save(pv)
    print(f"wrote {args.foe}_combat.png {combat.size} and {args.foe}_map.png {token.size}; preview {pv.relative_to(ROOT)}")


# ---------------------------------------------------------------- the rift

RIFT_PROMPT = (
    "16-bit SNES RPG battle sprite in the style of Final Fantasy VI: ornate, detailed, "
    "over-the-top dark fantasy, up to twenty colours, one-pixel dark outline. Subject: a "
    "swirling vortex of violet, magenta and black energy tearing a ragged hole in reality, "
    "seen from slightly above, a spiral of light sucked into a black centre, jagged torn edges "
    "of the world curling outward, tendrils of dark energy and pale cyan lightning at the rim, "
    "unsettling. Wider than it is tall. Centered, isolated on a solid flat pure white background, "
    "no text, no border, no ground shadow."
)
RIFT_FRAME = (128, 128)  # at the map's 2x this spans the three rift hexes and reaches up over the scenery
RIFT_TWIST = 7.0         # degrees between frames: the spiral turns a little, then back


def generate_rift(args):
    out = OUT / "rift"
    out.mkdir(parents=True, exist_ok=True)
    prompt = args.prompt or RIFT_PROMPT
    (out / "prompt.txt").write_text(prompt + "\n")
    print(prompt)
    made = []
    for seed in range(args.seed, args.seed + args.n):
        path = out / f"rift_{seed}.png"
        cmd = [str(MFLUX), "--model", MODEL, "--quantize", QUANTIZE, "--prompt", prompt,
               "--width", "768", "--height", "640", "--steps", STEPS,
               "--seed", str(seed), "--output", str(path)]
        print("rendering", path.name)
        subprocess.run(cmd, check=True)
        made.append(path)
    contact(made, out / "contact.png")
    print(f"{len(made)} candidates in {out.relative_to(ROOT)}")


RIFT_EDIT = (
    "Redraw this pixel art vortex with exactly the same style, size, colours and outline, "
    "as the next frame of its animation: the spiral has turned a quarter turn, the arcs of "
    "cyan lightning strike in different places, and the torn dark tendrils at the rim have "
    "shifted. Solid flat pure white background, no text, no shadow."
)


def rift_frames(args):
    """Distinct frames from a chosen candidate through the edit model (Ryan, 23 September:
    a turn is not an animation): the reference is frame 0, and each seed asks for the
    next frame of the same vortex."""
    out = OUT / "rift"
    out.mkdir(parents=True, exist_ok=True)
    prompt = args.prompt or RIFT_EDIT
    made = [Path(args.image)]
    for seed in range(args.seed, args.seed + args.n):
        path = out / f"frame_{seed}.png"
        if args.mode == "edit":
            # Keeps the drawing closely: the lightning and colour move, the rim less so.
            cmd = [str(MFLUX_EDIT), "--model", MODEL, "--quantize", QUANTIZE, "--prompt", prompt,
                   "--image-paths", args.image, "--steps", STEPS, "--seed", str(seed), "--output", str(path)]
        else:
            # Redraws from the reference at `strength`: looser, so the tendrils at the rim
            # move too (Ryan, 23 September).
            ref = Image.open(args.image)
            cmd = [str(MFLUX), "--model", MODEL, "--quantize", QUANTIZE, "--prompt", prompt,
                   "--image-path", args.image, "--image-strength", str(args.strength),
                   "--width", str(ref.width), "--height", str(ref.height), "--steps", STEPS,
                   "--seed", str(seed), "--output", str(path)]
        print("rendering", path.name)
        subprocess.run(cmd, check=True)
        made.append(path)
    contact(made, out / "frames_contact.png")
    print(f"{len(made) - 1} frames in {out.relative_to(ROOT)}; cut-rift with --frames to build the strip")


def _key_rift(path):
    src = key_background(Image.open(path))
    # The tendrils close pockets of background that the flood fill from the edges never
    # reaches; a vortex has no white detail worth keeping, so every near-white pixel goes.
    px = src.load()
    for y in range(src.height):
        for x in range(src.width):
            r, g, b, a = px[x, y]
            if a and r > 225 and g > 225 and b > 225:
                px[x, y] = (0, 0, 0, 0)
    return src


def _core(img):
    """The centre of the vortex: the centroid of its near-black opaque pixels."""
    arr = np.array(img)
    dark = (arr[..., 3] >= 128) & (arr[..., :3].max(axis=2) < 40)
    ys, xs = np.nonzero(dark)
    if len(xs) == 0:
        b = img.getbbox()
        return ((b[0] + b[2]) / 2.0, (b[1] + b[3]) / 2.0)
    return (xs.mean(), ys.mean())


def _place(img, scale, core, target, frame):
    """Scale the keyed figure by `scale` and paste it so `core` lands on `target`, clipped
    to the frame; edge pixels blend with the figure's mean colour, alpha hard afterwards."""
    fig = np.array(img).astype(np.float32)
    opaque = fig[..., 3] >= 128
    if opaque.any():
        fig[~opaque, :3] = fig[opaque][:, :3].mean(axis=0)
    fig[..., 3] = np.where(opaque, 255.0, 0.0)
    size = (max(1, round(img.width * scale)), max(1, round(img.height * scale)))
    small = np.array(Image.fromarray(fig.astype(np.uint8), "RGBA").resize(size, Image.LANCZOS))
    small[..., 3] = np.where(small[..., 3] >= 128, 255, 0)
    small[small[..., 3] == 0] = 0
    canvas = Image.new("RGBA", frame, (0, 0, 0, 0))
    dx = int(round(target[0] - core[0] * scale))
    dy = int(round(target[1] - core[1] * scale))
    canvas.paste(Image.fromarray(small, "RGBA"), (dx, dy), Image.fromarray(small, "RGBA"))
    return canvas


def _luma(img):
    a = np.array(img).astype(np.float32)
    return (a[..., :3].mean(axis=2)) * (a[..., 3] >= 128)


def _snap_cores(frames, reach=10):
    """Line every frame up with the first as a whole drawing, not by any one feature: the
    eye tracks the whole thing, and aligning on the black core alone still read as a bob
    (Ryan, 23 September). Each frame is shifted by the whole pixels that make its
    brightness best match the first frame's, searched within `reach`."""
    ref = _luma(frames[0])
    out = [frames[0]]
    h, w = ref.shape
    for f in frames[1:]:
        lum = _luma(f)
        best, best_score = (0, 0), -1e18
        for dy in range(-reach, reach + 1):
            for dx in range(-reach, reach + 1):
                a = ref[max(0, dy):h + min(0, dy), max(0, dx):w + min(0, dx)]
                b = lum[max(0, -dy):h + min(0, -dy), max(0, -dx):w + min(0, -dx)]
                score = float((a * b).sum())
                if score > best_score:
                    best, best_score = (dx, dy), score
        moved = Image.new("RGBA", f.size, (0, 0, 0, 0))
        moved.paste(f, best, f)
        out.append(moved)
    return out


def _similarity(a, b):
    """How alike two frames are: the correlation of their brightness, 0 to 1."""
    x, y = _luma(a).ravel(), _luma(b).ravel()
    x, y = x - x.mean(), y - y.mean()
    return float((x * y).sum() / (np.sqrt((x * x).sum() * (y * y).sum()) + 1e-6))


BAYER4 = np.array([[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]) / 16.0


def _dither_mix(a, b):
    """Half of each frame's pixels, chosen by a 4x4 Bayer pattern, so the mix stays in the
    two frames' own colours and reads as a pixel-art tween rather than a blur."""
    A, B = np.array(a), np.array(b)
    h, w = A.shape[:2]
    thr = np.tile(BAYER4, (h // 4 + 1, w // 4 + 1))[:h, :w]
    take_b = (thr >= 0.5)[..., None]
    return Image.fromarray(np.where(take_b, B, A).astype(np.uint8), "RGBA")


def cut_rift(args):
    """One candidate into three frames: the vortex turned a little each way about its
    centre (an image model cannot draw a consistent second frame; a turn of a few degrees,
    ping-ponged, reads as the spiral moving). Written as one strip, frames side by side."""
    frames = []
    if args.frames:
        # Distinct drawings (rift_frames), cut at one scale and aligned on the black core:
        # fitting each to its own bounds let a stray bolt shrink a whole frame and drop
        # its centre (Ryan, 23 September).
        keyed = [_key_rift(path) for path in [args.image] + args.frames]
        ref = keyed[0]
        bbox = ref.getbbox()
        inner = (RIFT_FRAME[0] - 2, RIFT_FRAME[1] - 2)
        scale = min(inner[0] / (bbox[2] - bbox[0]), inner[1] / (bbox[3] - bbox[1]))
        ref_core = _core(ref)
        # Where the reference's core lands when the reference is fitted the usual way.
        fitted_w = round((bbox[2] - bbox[0]) * scale)
        fitted_h = round((bbox[3] - bbox[1]) * scale)
        origin = ((RIFT_FRAME[0] - fitted_w) // 2, RIFT_FRAME[1] - 1 - fitted_h)
        target = (origin[0] + (ref_core[0] - bbox[0]) * scale, origin[1] + (ref_core[1] - bbox[1]) * scale)
        for img in keyed:
            frames.append(outline(quantize(_place(img, scale, _core(img), target, RIFT_FRAME), None, args.colours)))
        frames = _snap_cores(frames)
        for i in range(len(frames)):
            print("frame %d likeness to the others: %s" % (i, " ".join("%.2f" % _similarity(frames[i], frames[j]) for j in range(len(frames)) if j != i)))
    else:
        src = _key_rift(args.image)
        for angle in [-RIFT_TWIST, 0.0, RIFT_TWIST]:
            turned = src.rotate(angle, resample=Image.BICUBIC, expand=False)
            frames.append(outline(quantize(fit(turned, RIFT_FRAME), None, args.colours)))
    if args.tween and len(frames) > 1:
        # A frame between each pair, in the register: a Bayer-dithered half-and-half of
        # the two, no new colours (Ryan, 23 September: a tiny bit smoother).
        tweened = []
        for i, f in enumerate(frames):
            tweened.append(f)
            tweened.append(_dither_mix(f, frames[(i + 1) % len(frames)]))
        frames = tweened
    strip = Image.new("RGBA", (RIFT_FRAME[0] * len(frames), RIFT_FRAME[1]), (0, 0, 0, 0))
    for k, f in enumerate(frames):
        strip.paste(f, (k * RIFT_FRAME[0], 0))
    dest = ROOT / "art" / "terrain" / "rift.png"
    strip.save(dest)
    preview = strip.resize((strip.width * 3, strip.height * 3), Image.NEAREST)
    pv = OUT / "rift" / "rift_cut_preview.png"
    preview.save(pv)
    print(f"wrote {dest.relative_to(ROOT)} {strip.size}; preview {pv.relative_to(ROOT)}")


# ---------------------------------------------------------------- mechs: the hybrid

CHASSIS = ROOT / "content" / "chassis.json"
MECH_ART = ROOT / "art" / "mechs"
MECH_FRAME = (80, 96)
MECH_STYLE = (
    "Isometric pixel art game sprite of a heavy military mech in the style of Into the Breach: "
    "chunky, rugged, grounded military hardware, riveted plates, exposed pistons, a cockpit slit "
    "glowing cyan, an amber marking light. Keep this pose, proportions and camera angle. Clean "
    "one-pixel dark outline, flat cel shading with strong top-face highlights, isolated on a "
    "solid flat pure white background, no text, no ground shadow."
)
MAKER_LOOK = {
    "minerva": "cold steel grey plates with deep red armour panels",
    "kestrel": "cold steel with cobalt blue airframe panels",
    "wainwright_sutler": "cold steel with bone-white armour plates",
}
# The edit model keeps the render's shape and adds the finish; the instruction says so in
# as many words, then names the finish wanted and the colours to keep.
MECH_EDIT = (
    "Redraw this isometric pixel art mech with exactly the same silhouette, pose, parts, "
    "proportions and camera angle, adding finish: riveted steel plates, panel lines, worn "
    "edges, tread texture on any tracks, hydraulic pistons at the joints, cel shading with "
    "strong top highlights, one-pixel dark outline. Keep the same colours: {look}, cyan cockpit "
    "glass, amber marking lights. Solid flat pure white background, no shadow, no text."
)


def load_chassis():
    d = json.loads(CHASSIS.read_text())
    return {e["id"]: e for e in d["entries"]}


def mech_prompt(c):
    body = " ".join(s for s in [c.get("design", {}).get("fantasy", ""), c.get("codex", "")] if s)
    look = MAKER_LOOK.get(c.get("maker", ""), "cold steel")
    return f"{MECH_STYLE} Subject: the {c['name']}, a war machine. {body} Light: {look}."


def mech_reference(chassis_id, turn, src=""):
    """The renderer's own sprite, on white and blown up, as the model's composition
    reference: the design stays fixed and the model does the finish. `src` is any render
    (a blendforge review sprite, say); by default the sprite already in art/mechs."""
    src = Path(src) if src else MECH_ART / f"{chassis_id}_combat_{turn}.png"
    im = Image.open(src).convert("RGBA")
    bg = Image.new("RGBA", im.size, (255, 255, 255, 255))
    bg.paste(im, (0, 0), im)
    k = 8
    ref = OUT / chassis_id / f"{chassis_id}_{turn}_ref.png"
    ref.parent.mkdir(parents=True, exist_ok=True)
    bg.convert("RGB").resize((im.width * k, im.height * k), Image.NEAREST).save(ref)
    return ref, (im.width * k, im.height * k)


def mech(args):
    c = load_chassis()[args.chassis]
    ref, (w, h) = mech_reference(args.chassis, args.turn, args.ref)
    out = OUT / args.chassis
    if args.mode == "edit":
        prompt = args.prompt or MECH_EDIT.format(look=MAKER_LOOK.get(c.get("maker", ""), "cold steel"))
    else:
        prompt = args.prompt or mech_prompt(c)
    (out / "prompt.txt").write_text(prompt + "\n")
    print(prompt)
    made = []
    for seed in range(args.seed, args.seed + args.n):
        path = out / f"{args.chassis}_{args.turn}_{seed}.png"
        if args.mode == "edit":
            # Edit mode: the render is the picture being edited, not a noisy starting point,
            # so the design survives and the model only adds what the instruction asks for.
            cmd = [str(MFLUX_EDIT), "--model", MODEL, "--quantize", QUANTIZE, "--prompt", prompt,
                   "--image-paths", str(ref), "--steps", STEPS, "--seed", str(seed), "--output", str(path)]
        else:
            cmd = [str(MFLUX), "--model", MODEL, "--quantize", QUANTIZE, "--prompt", prompt,
                   "--image-path", str(ref), "--image-strength", str(args.strength),
                   "--width", str(w), "--height", str(h), "--steps", STEPS,
                   "--seed", str(seed), "--output", str(path)]
        print("rendering", path.name)
        subprocess.run(cmd, check=True)
        made.append(path)
    contact(made, out / f"contact_{args.turn}.png")
    print(f"{len(made)} candidates in {out.relative_to(ROOT)}")


def cut_mech(args):
    src = key_background(Image.open(args.image))
    MECH_ART.mkdir(parents=True, exist_ok=True)
    if args.chunk > 1:
        # The other genre: mechs at a coarser pixel grid than the foes. Fit into a frame
        # `chunk` times smaller, quantise there, then scale up by nearest neighbour so each
        # mech pixel is a block of foe pixels.
        small_frame = (MECH_FRAME[0] // args.chunk, MECH_FRAME[1] // args.chunk)
        small = outline(quantize(fit(src, small_frame), None, args.colours))
        sprite = small.resize((small.width * args.chunk, small.height * args.chunk), Image.NEAREST)
    else:
        sprite = outline(quantize(fit(src, MECH_FRAME), None, args.colours))
    dest = Path(args.out) if args.out else MECH_ART / f"{args.chassis}_combat_{args.turn}.png"
    sprite.save(dest)
    pv = dest.with_name(dest.stem + "_preview.png") if args.out else OUT / args.chassis / f"{args.chassis}_{args.turn}_cut_preview.png"
    pv.parent.mkdir(parents=True, exist_ok=True)
    sprite.resize((sprite.width * 4, sprite.height * 4), Image.NEAREST).save(pv)
    print(f"wrote {dest} {sprite.size}; preview {pv}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    m = sub.add_parser("mech", help="candidates for a mech's combat sprite, from the renderer's sprite as reference")
    m.add_argument("chassis")
    m.add_argument("--turn", default="front_right", choices=["front", "front_left", "front_right"])
    m.add_argument("--n", type=int, default=2)
    m.add_argument("--seed", type=int, default=1)
    m.add_argument("--mode", default="edit", choices=["edit", "img2img"], help="edit (default) keeps the render's design and adds finish; img2img redraws freely from it and rarely keeps the design")
    m.add_argument("--strength", type=float, default=0.3, help="img2img only: how far the model may stray from the render; lower is freer")
    m.add_argument("--prompt", default="")
    m.add_argument("--ref", default="", help="reference sprite to refine (default: the one in art/mechs); e.g. a blendforge render in tools/blendforge/out")
    m.set_defaults(func=mech)
    cm = sub.add_parser("cut-mech", help="cut a chosen candidate into art/mechs/<chassis>_combat_<turn>.png")
    cm.add_argument("image")
    cm.add_argument("chassis")
    cm.add_argument("--turn", default="front_right", choices=["front", "front_left", "front_right"])
    cm.add_argument("--colours", type=int, default=16, help="colours to keep (default 16, the foes' density; 8 was tried for a genre split and dulls a finished sprite)")
    cm.add_argument("--chunk", type=int, default=1, help="pixel size relative to the foes: 2 draws the mech on a grid twice as coarse (tried; it loses too much at 40x48)")
    cm.add_argument("--out", default="", help="write here instead of art/mechs (for experiments)")
    cm.set_defaults(func=cut_mech)
    pk = sub.add_parser("picker", help="a page for picking candidates, one foe at a time (tools/foeforge/out/picker.html)")
    pk.add_argument("--all", action="store_true", help="also show the set-aside first rounds (<id>_v1)")
    pk.add_argument("--tags", nargs="*", default=[], help="also show experiments' sets (out/<id>_<tag>), beside each foe's current set")
    pk.set_defaults(func=picker)
    p = sub.add_parser("prompts", help="every foe's prompt into tools/foeforge/prompts.md, to read before generating (no model needed)")
    p.add_argument("--out", default="")
    p.set_defaults(func=prompts)
    g = sub.add_parser("generate")
    g.add_argument("foe")
    g.add_argument("--n", type=int, default=4)
    g.add_argument("--seed", type=int, default=1)
    g.add_argument("--prompt", default="")
    g.add_argument("--chibi", action="store_true", help="a hero's chibi party sprite, into out/<hero>_chibi")
    g.add_argument("--tag", default="", help="an experiment's own folder: out/<foe>_<tag>")
    g.add_argument("--ref", default="", help="a style reference image, through the edit model (its finish, never its creature)")
    g.add_argument("--variants", action="store_true", help="each candidate from its own take in design.variants")
    g.set_defaults(func=generate)
    c = sub.add_parser("cut")
    c.add_argument("image")
    c.add_argument("foe")
    c.add_argument("--colours", type=int, default=16, help="colours to keep (default 16)")
    c.add_argument("--sharpen", type=int, default=60, help="the gentle sharpen's unsharp amount, percent (default 60; raise it for a crisper cut, -1 for the old plain median cut)")
    c.add_argument("--tol", type=int, default=48, help="how far from the background colour still keys out (default 48); raise it, to 90 or so, when a render left a grey ground shadow")
    c.add_argument("--holes", action="store_true", help="also key enclosed pockets of background (sky between branches); off by default, since a white robe is the same colour")
    c.add_argument("--faction-palette", action="store_true", help="snap to the faction palette from the enemy sheet instead of keeping the model's colours")
    c.set_defaults(func=cut)
    r = sub.add_parser("rift", help="candidates for the rift: a vortex tearing a hole in reality")
    r.add_argument("--n", type=int, default=4)
    r.add_argument("--seed", type=int, default=1)
    r.add_argument("--prompt", default="")
    r.set_defaults(func=generate_rift)
    cr = sub.add_parser("cut-rift", help="cut a chosen candidate into art/terrain/rift.png, three frames")
    cr.add_argument("image")
    cr.add_argument("--colours", type=int, default=16)
    cr.add_argument("--frames", nargs="*", default=[], help="further frames (rift-frames output) after the first; without them, the one image turned")
    cr.add_argument("--tween", action="store_true", help="a dithered half-and-half frame between each pair, for a smoother turn")
    cr.set_defaults(func=cut_rift)
    rf = sub.add_parser("rift-frames", help="the next frames of a chosen vortex through the edit model")
    rf.add_argument("image")
    rf.add_argument("--n", type=int, default=3)
    rf.add_argument("--seed", type=int, default=1)
    rf.add_argument("--prompt", default="")
    rf.add_argument("--mode", default="edit", choices=["edit", "img2img"], help="edit keeps the drawing and moves the lightning; img2img redraws from it and moves the rim too")
    rf.add_argument("--strength", type=float, default=0.6, help="img2img only: how close to the reference to stay")
    rf.set_defaults(func=rift_frames)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    sys.exit(main())
