"""Build the hangar codex page from content/*.json: every chassis with its plate, stats,
passive, traits and its die laid out entry by entry, each entry's component with its
numbers, keywords and maker, and each hardpoint's pin checked against the built model so a
missing socket is flagged rather than assumed. Read-only; regenerate and republish after a
content or model change."""
import json, os, sys, html

ROOT = sys.argv[1] if len(sys.argv) > 1 else "."
OUT = sys.argv[2] if len(sys.argv) > 2 else "codex.html"

def load(n):
    return json.load(open(os.path.join(ROOT, "content", n)))

ch = load("chassis.json")
comps = {e["id"]: e for e in load("components.json")["entries"]}
vocab = {e["id"]: e for e in load("vocabulary.json")["entries"]}
makers = {m["id"]: m for m in ch["makers"]}
MAKER_CLASS = {"minerva": "minerva", "kestrel": "kestrel", "wainwright_sutler": "ws", "aphelion": "aphelion", "arsenal": "arsenal"}
KIND_GLYPH = {"attack": "ATK", "shield": "SHD", "vent": "VENT", "buff": "BUFF"}
REACH = {"melee": "melee", "line": "line of sight", "indirect": "indirect", "": ""}

def esc(s):
    return html.escape(str(s or ""))

def model_pins(cid):
    """The hp_<n> pins the built model actually carries, read from art/models/<id>.glb, so
    the page tags a hardpoint with a real socket and says so when the model has none yet.
    None when there is no model."""
    path = os.path.join(ROOT, "art", "models", cid + ".glb")
    if not os.path.exists(path):
        return None
    import re
    return sorted(set(int(n) for n in re.findall(rb'"hp_(\d+)"', open(path, "rb").read())))

def kw_title(k):
    v = vocab.get(k)
    if not v:
        return k
    return (v.get("name") or k) + " — " + (v.get("codex") or "")

def face_line(f):
    """The numbers as the die shows them."""
    if not f:
        return ""
    kind = f.get("kind", "")
    bits = []
    p, pmax = f.get("power"), f.get("power_max")
    if kind == "attack":
        bits.append(("%d–%d" % (p, pmax)) if pmax and pmax != p else str(p))
        if f.get("crit"):
            bits.append("crit %d%%" % f["crit"])
        r = REACH.get(f.get("reach", ""), f.get("reach", ""))
        if r:
            bits.append(r)
    elif kind == "buff":
        bits.append("%s ×%d" % (vocab.get(f.get("status", ""), {}).get("name") or f.get("status", ""), int(f.get("stacks", 1))))
        if int(f.get("rounds", 1)) > 1:
            bits.append("%d rounds" % int(f["rounds"]))
    elif p is not None:
        bits.append(str(p))
    if f.get("power_per_heat"):
        bits.append("+%s per 10 heat" % f["power_per_heat"])
    if f.get("vents_all"):
        bits.append("vents all")
    if f.get("heat"):
        bits.append("%d heat" % f["heat"])
    return " · ".join(bits)

def pin_html(pin, pins):
    """The pin tag: the socket's name, or the same name flagged when the model lacks it."""
    if not pin:
        return ""
    n = int(pin.split("_")[1])
    if pins is None:
        return '<span class="pin nopin" title="no model built for this chassis yet">%s · no model</span>' % esc(pin)
    if n not in pins:
        return '<span class="pin nopin" title="the model has no hp_%d Empty; the rule wants one per hardpoint">%s · not on the model</span>' % (n, esc(pin))
    return '<span class="pin">%s</span>' % esc(pin)

def component_card(cid, slot, pin, pins=None):
    c = comps.get(cid)
    if c is None:
        return '<div class="entry missing"><div class="slot">%s</div><div class="cname">unknown component %s</div></div>' % (esc(slot), esc(cid))
    f = c.get("face") or {}
    kind = f.get("kind", "")
    planned = c.get("status") == "planned"
    kws = "".join('<span class="kw" title="%s">%s</span>' % (esc(kw_title(k)), esc(vocab.get(k, {}).get("name", k))) for k in f.get("keywords", []))
    # The silhouette class the model wears when this component is fitted to a hardpoint
    # (decided 29 September): the die carries the identity, the model only its kind.
    shape = c.get("shape", "")
    if shape:
        kws = ('<span class="kw shape" title="Silhouette class: what the model wears at the pin when this component is fitted (its own maker\'s metal)">%s</span>' % esc(shape.replace("_", " "))) + kws
    mk = makers.get(c.get("maker", ""), {}).get("name", "")
    tier = c.get("tier")
    tier_html = ('<span class="tier" title="Blueprint tier">T%s</span>' % esc(tier)) if tier else ""
    pas = ""
    if c.get("passive"):
        pas = '<div class="pas"><b>%s.</b> %s</div>' % (esc(c["passive"].get("name", "")), esc(c["passive"].get("description", "")))
    return ('<div class="entry %s%s">'
            '<div class="slot">%s%s</div>'
            '<div class="kind %s">%s</div>'
            '<div class="cname">%s%s</div>'
            '<div class="nums">%s</div>'
            '<div class="kws">%s</div>'
            '<div class="cmaker">%s</div>%s</div>') % (
        esc(kind), " planned" if planned else "", esc(slot),
        pin_html(pin, pins),
        esc(kind), esc(KIND_GLYPH.get(kind, kind.upper())),
        esc(c.get("name", cid)), tier_html + (' <span class="tag">planned</span>' if planned else ""),
        esc(face_line(f)), kws, esc(mk), pas)

cards = []
for e in ch["entries"]:
    mk = makers.get(e.get("maker", ""), {})
    fixed = e.get("fixed", []) or []
    loadout = e.get("loadout", []) or []
    hp = int(e.get("hardpoints", 0))
    die = len(fixed) + hp
    pins = model_pins(e["id"])
    entries = []
    for cid in fixed:
        entries.append(component_card(cid, "fixed", None))
    for i in range(hp):
        cid = loadout[i] if i < len(loadout) else None
        pin = "hp_%d" % (i + 1)
        if cid is None:
            entries.append('<div class="entry blank"><div class="slot">hardpoint%s</div><div class="cname">empty</div></div>' % pin_html(pin, pins))
        else:
            entries.append(component_card(cid, "hardpoint", pin, pins))
    # The model's pin count against the hardpoints, said once at the top of the die.
    if pins is None:
        pin_note = '<p class="pinnote">No model built yet.</p>'
    elif len(pins) != hp or pins != list(range(1, hp + 1)):
        pin_note = '<p class="pinnote">The model carries %d pin%s (%s) for %d hardpoint%s: the ones marked below are missing on it.</p>' % (
            len(pins), "" if len(pins) == 1 else "s", ", ".join("hp_%d" % n for n in pins) or "none", hp, "" if hp == 1 else "s")
    else:
        pin_note = ""
    stats = [("hull", e.get("hull")), ("shield", e.get("shield")), ("field recharge", e.get("recharge_field")),
             ("armour", e.get("armour")), ("heat max", e.get("heat_max")), ("cooling", e.get("cooling")),
             ("move", e.get("movespeed")), ("die", "d%d" % die)]
    stat_html = "".join('<div class="stat"><span class="k">%s</span><span class="v">%s</span></div>' % (esc(k), esc(v)) for k, v in stats)
    p = e.get("passive")
    if p:
        planned = p.get("status") == "planned"
        pas = '<div class="passive%s"><h4>%s%s</h4><p>%s</p></div>' % (
            " planned" if planned else "", esc(p.get("name", "")),
            ' <span class="tag">planned</span>' if planned else "", esc(p.get("description", "")))
    else:
        pas = '<div class="passive none"><h4>No passive</h4><p>Unwritten.</p></div>'
    traits = "".join('<span class="kw" title="%s">%s</span>' % (esc(kw_title(t)), esc(vocab.get(t, {}).get("name", t))) for t in e.get("traits", []))
    clash = (e.get("design") or {}).get("name_clash")
    note = ('<p class="clash"><b>Name:</b> %s</p>' % esc(clash)) if clash else ""
    cards.append(
        '<section class="chassis %s" id="%s">'
        '<div class="head"><p class="desig">%s</p><h2>%s</h2>'
        '<p class="sub">%s · %s%s</p></div>'
        '<div class="stats">%s</div>%s%s'
        '<h3>The die · %d entries</h3>%s<div class="die">%s</div>%s</section>' % (
            MAKER_CLASS.get(e.get("maker", ""), "other"), esc(e["id"]),
            esc(e.get("designation", "")), esc(e.get("name", "")),
            esc(mk.get("name", "")), esc(e.get("silhouette", "")),
            (" · " + traits) if traits else "",
            stat_html, pas, note, die, pin_note, "".join(entries),
            ('<p class="codex">%s</p>' % esc(e.get("codex"))) if e.get("codex") else ""))

nav = "".join('<a href="#%s">%s</a>' % (esc(e["id"]), esc(e.get("name", ""))) for e in ch["entries"])
page = """<title>Hangar Codex</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@500;600;700&family=IBM+Plex+Sans:wght@400;500;600&family=IBM+Plex+Mono:wght@400;500&display=swap">
<style>
:root{--ground:#ECE8DF;--paper:#F6F3EC;--sunk:#E2DDD2;--ink:#1F2226;--ink-2:#4B5058;--ink-3:#7C8189;--rule:#CFC9BC;
--minerva:#4E6A3B;--kestrel:#33639C;--ws:#8A5730;--aphelion:#B3302C;--arsenal:#3E434D;--other:#6E7279;
--atk:#A8402F;--shd:#2F63A8;--vent:#8A6A12;--acc:var(--other)}
@media (prefers-color-scheme: dark){:root:not([data-theme="light"]){color-scheme:dark;
--ground:#191B1F;--paper:#22252B;--sunk:#1D2025;--ink:#E6E2D8;--ink-2:#B6B1A6;--ink-3:#7F7B73;--rule:#383C44;
--minerva:#8DB36F;--kestrel:#7FA9E0;--ws:#D39562;--aphelion:#E8756F;--arsenal:#A9B0BC;--other:#A0A5AD;
--atk:#E88870;--shd:#7FA9E0;--vent:#E0B44A}}
:root[data-theme="dark"]{color-scheme:dark;
--ground:#191B1F;--paper:#22252B;--sunk:#1D2025;--ink:#E6E2D8;--ink-2:#B6B1A6;--ink-3:#7F7B73;--rule:#383C44;
--minerva:#8DB36F;--kestrel:#7FA9E0;--ws:#D39562;--aphelion:#E8756F;--arsenal:#A9B0BC;--other:#A0A5AD;
--atk:#E88870;--shd:#7FA9E0;--vent:#E0B44A}
*{box-sizing:border-box}
body{margin:0;background:var(--ground);color:var(--ink);font:15px/1.45 "IBM Plex Sans","Helvetica Neue",Arial,sans-serif}
.wrap{max-width:900px;margin:0 auto;padding-inline:16px;padding-block:0 56px}
header.top{position:sticky;top:env(safe-area-inset-top,0px);z-index:5;background:var(--ground);border-bottom:1px solid var(--rule);padding-block:12px 8px}
h1{font:700 30px/1 "Barlow Condensed",Arial,sans-serif;text-transform:uppercase;letter-spacing:.02em;margin:0}
.lede{color:var(--ink-3);font-size:13px;margin:2px 0 8px;max-width:70ch}
nav{display:flex;gap:4px;overflow-x:auto;scrollbar-width:none}nav::-webkit-scrollbar{display:none}
nav a{flex:0 0 auto;border:1px solid var(--rule);border-radius:4px;padding:5px 10px;text-decoration:none;color:var(--ink-2);
font:600 14px/1 "Barlow Condensed",Arial,sans-serif;letter-spacing:.04em;text-transform:uppercase}
nav a:hover{border-color:var(--acc);color:var(--ink)}
.chassis{--acc:var(--other);background:var(--paper);border:1px solid var(--rule);border-left:4px solid var(--acc);
border-radius:3px;padding:14px;margin-top:14px;scroll-margin-top:120px}
.chassis.minerva{--acc:var(--minerva)}.chassis.kestrel{--acc:var(--kestrel)}.chassis.ws{--acc:var(--ws)}
.chassis.aphelion{--acc:var(--aphelion)}.chassis.arsenal{--acc:var(--arsenal)}
.desig{font:500 12px/1.4 "IBM Plex Mono",Menlo,monospace;color:var(--ink-3);text-transform:uppercase;letter-spacing:.06em;margin:0}
.chassis h2{font:700 27px/1 "Barlow Condensed",Arial,sans-serif;text-transform:uppercase;letter-spacing:.02em;margin:1px 0 2px;color:var(--acc)}
.sub{color:var(--ink-3);font-size:13px;margin:0 0 10px}
.stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(88px,1fr));gap:1px;background:var(--rule);border:1px solid var(--rule);border-radius:3px;overflow:hidden;margin-bottom:10px}
.stat{background:var(--sunk);padding:5px 8px;display:flex;flex-direction:column;gap:1px}
.stat .k{font:600 10px/1.3 "Barlow Condensed",Arial,sans-serif;text-transform:uppercase;letter-spacing:.1em;color:var(--ink-3)}
.stat .v{font-variant-numeric:tabular-nums;font-weight:600;font-size:15px}
.passive{border:1px dashed var(--rule);border-radius:3px;padding:8px 10px;margin-bottom:10px}
.passive h4{margin:0 0 2px;font:600 16px/1.2 "Barlow Condensed",Arial,sans-serif;text-transform:uppercase;letter-spacing:.04em}
.passive p{margin:0;color:var(--ink-2);font-size:14px;max-width:70ch}
.passive.none h4,.passive.none p{color:var(--ink-3)}
.chassis h3{font:600 13px/1 "Barlow Condensed",Arial,sans-serif;text-transform:uppercase;letter-spacing:.1em;color:var(--ink-3);margin:12px 0 6px}
.die{display:grid;gap:6px}
.entry{display:grid;grid-template-columns:auto auto 1fr auto;grid-template-areas:"slot kind name maker" "slot kind nums nums" "slot kind kws kws" "pas pas pas pas";
gap:1px 10px;align-items:baseline;background:var(--sunk);border:1px solid var(--rule);border-radius:3px;padding:7px 10px}
.entry.blank,.entry.missing{opacity:.6}
.slot{grid-area:slot;font:600 10px/1.4 "Barlow Condensed",Arial,sans-serif;text-transform:uppercase;letter-spacing:.08em;color:var(--ink-3);min-width:64px}
.slot .pin{display:block;font:400 10px/1.3 "IBM Plex Mono",Menlo,monospace;letter-spacing:0;text-transform:none;opacity:.8}
.slot .pin.nopin{color:var(--atk);opacity:1;cursor:help}
.pinnote{margin:0 0 6px;font-size:13px;color:var(--atk)}
.kind{grid-area:kind;font:600 10px/1.4 "IBM Plex Mono",Menlo,monospace;letter-spacing:.06em;padding:1px 5px;border:1px solid currentColor;border-radius:2px;color:var(--ink-3)}
.kind.attack{color:var(--atk)}.kind.shield{color:var(--shd)}.kind.vent{color:var(--vent)}
.cname{grid-area:name;font-weight:600}
.nums{grid-area:nums;font-variant-numeric:tabular-nums;font-size:13px;color:var(--ink-2)}
.kws{grid-area:kws;display:flex;gap:5px;flex-wrap:wrap}
.kw{border:1px solid var(--rule);border-radius:999px;padding:0 7px;font:600 10px/1.7 "Barlow Condensed",Arial,sans-serif;
text-transform:uppercase;letter-spacing:.08em;color:var(--ink-2);cursor:help}
.kw.shape{border-style:dashed;color:var(--ink-3)}
.cmaker{grid-area:maker;font-size:11px;color:var(--ink-3);text-align:right}
.pas{grid-area:pas;font-size:13px;color:var(--ink-2);border-top:1px dashed var(--rule);margin-top:5px;padding-top:5px}
.tier{font:600 9px/1.6 "IBM Plex Mono",Menlo,monospace;letter-spacing:.06em;border:1px solid var(--rule);color:var(--ink-3);border-radius:2px;padding:0 4px;margin-left:5px;vertical-align:1px}
.tag{font:600 9px/1.6 "Barlow Condensed",Arial,sans-serif;text-transform:uppercase;letter-spacing:.1em;
border:1px solid var(--ink-3);color:var(--ink-3);border-radius:2px;padding:0 4px;vertical-align:1px}
.codex{color:var(--ink-2);font-size:14px;margin:10px 0 0;max-width:70ch}
.clash{font-size:13px;color:var(--ink-2);background:var(--sunk);border-radius:3px;padding:6px 8px;margin:0 0 10px}
@media (max-width:520px){.entry{grid-template-columns:auto 1fr;grid-template-areas:"slot kind" "name name" "nums nums" "kws kws" "maker maker" "pas pas"}.cmaker{text-align:left}}
</style>
<div class="wrap">
<header class="top"><h1>Hangar Codex</h1>
<p class="lede">Every chassis with its die laid out entry by entry: fixed components first, then each hardpoint with the model pin it mounts on, read from the built model, so a hardpoint the model has no socket for yet says so. The dashed chip on a component is its silhouette class, the shape the model wears at the pin when it is fitted. Generated from <code>content/*.json</code> and <code>art/models/*.glb</code>; hover a keyword for its rule. Numbers are placeholders.</p>
<nav>__NAV__</nav></header>
__CARDS__
</div>"""
page = page.replace("__NAV__", nav).replace("__CARDS__", "".join(cards))
open(OUT, "w").write(page)
print("codex: %d chassis, %d components -> %s (%d KB)" % (len(ch["entries"]), len(comps), OUT, os.path.getsize(OUT) // 1024))
