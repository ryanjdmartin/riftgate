"""Night Shift's second round as a pair (Ryan, 29 October, on the pair page): the battle half has
good ideas but skews so close to Hold The Line that it sounds like a remix rather than shared
ideas; not a bad thing in itself, so it is adjusted first, before anything larger:

  the map half   the intro no longer starts on the sub and the pad (it broke the loop's seam);
                 the pad's swell from about 0:10 stays where it is.
  the battle     no crash at the top, for the same reason; the guitar back in the mix and off its
                 straight even pulse onto a groove (Ryan may write it himself on the Melody Desk);
                 a bass line and a synth line all over, since the chug alone does not carry a
                 fight; no drone at all for now (over-used, it tires); drums with Hold The Line's
                 energy and complexity through the whole track.

So the map half is the shipped recipe with its sub's pulse and its pad out of the intro's first
bars, the pad fading in where its filter is darkest, so the swell from 0:10 plays as it did. The
battle half keeps the first cut's form and its keepers (the piano off the beat, the chime's hook,
the lead's long notes, the choir and ringing chords in the breakdown, the riff in D), and gains:

  drums     Night Shift's four on the floor as the base under Hold The Line's density: kick
            pickups, ghost notes on the snare, sixteenths on the hats with the house open hat
            off the beat, a crash and a china each phrase, a tom fill every eighth bar, the
            climax's kick and a double-kick run in D, a snare build out of the breakdown, and
            the map's own industry (knocks, ticks, clanks, glitches) over the kit.
  bass      a driven line all through: root, its octave and fifth on the sixteenths between the
            kick's beats, and a passing note into each chord.
  guitar    palm-muted on the chords' roots at about half its level, in a groove (three to hear).
  synth     an arpeggio on the lead's voice through the grooves (or the chime's hook on a synth,
            or none: the A/B set).

    tools/spriter/.venv/bin/python tools/soundforge/night_sketches.py          # the sets and the full pair, then night2.json beside the pairs
    tools/spriter/.venv/bin/python tools/soundforge/night_sketches.py g        # the named sets only (g s, and full for the pair and the seams)
"""
import json
import os
import sys
from concurrent.futures import ProcessPoolExecutor

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import pair_sketches as P  # noqa: E402
from hold_sketches import copied  # noqa: E402

NAME = "music_night_shift"
MAP_LEVEL = F.LEVELS[NAME]
BATTLE_LEVEL = P.PAIRS["night_shift"]["level"]


# ---------------------------------------------------------------- the map half

def map_intro(call):
    """The shipped map with its front cut (Ryan: don't start with the sub and the drone, it breaks
    the loop; the drone's crescendo from about 0:10 works): the sub's pulse joins at the intro's
    fifth bar, and the pad is silent for three bars and fades in through the fourth, where its
    slow filter is at its darkest, so from 0:10 it opens just as it did."""
    kw = copied(call)
    for v in kw["voices"]:
        if v["inst"] == "sub_bass" and "I" in v["pat"]:
            v["pat"]["I"] = "." * 64 + v["pat"]["I"] * (64 // len(v["pat"]["I"]))
    for p in kw["pad"]:
        if "I" in p.get("sections", ""):
            p["enter"] = {"I": (3, 1)}
    return kw


# ---------------------------------------------------------------- the battle half

def bars(*xs):
    return "".join(xs)


FILL_TOM, FILL_TOM2 = "....x.x.xx.x.x..", "......x.....x.xx"   # Hold The Line's fill, in a phrase's last bar
GROOVE_KICK = bars("x...x...x...x..x", "x...x..xx...x...", "x...x...x...x..x", "x...x..xx...x.x.",
                   "x...x...x...x..x", "x...x..xx...x...", "x...x...x...x..x", "x...x...x.......")
LEAD_KICK = bars("x...x...x...x..x", "x..x..x.x...x...", "x...x...x...x..x", "x..x..x.x...x.x.",
                 "x...x...x...x..x", "x..x..x.x...x...", "x...x...x...x..x", "x...x...x.......")
GROOVE_SNARE = bars("....x..o....x..o", "....x..o.o..x...", "....x..o....x..o", "....x..o.o..x.o.",
                    "....x..o....x..o", "....x..o.o..x...", "....x..o....x..o", "....x.......x...")
HATS = "xx.xxx.xxx.xxx.x" * 7 + "xx.xxx.x........"   # sixteenths round the open hat, out for the fill
OPENS = "..x...x...x...x." * 7 + "..x...x........."
FILLS = {"tom": "." * 112 + FILL_TOM, "tom2": "." * 112 + FILL_TOM2}

# The guitar's grooves, one bar on each chord's root (Ryan: not straight, more of a groove).
GROOVES = {
    "g0": ("Straight, as the first cut", "Every eighth on the root, as the first cut had it, at the new level, for reference.", "r.r.r.r.r.r.r.r."),
    "g1": ("The hook's rhythm", "On the chime's hook: one, two, the and of two, four, a pickup.", "r...r.r.....r.r."),
    "g2": ("Three, three, two", "Three-three-two twice in sixteenths, locked with the bass line's rhythm.", "r..r..r.r..r..r."),
    "g3": ("The gallop", "Pairs of sixteenths pushing into the beat.", "r.rr..r.r.rr..r."),
}

# The bass line's bar: the root long on one and short on the a of one, its octave on the and of
# two, the root on three, the fifth on its a, and a passing note into the next chord, between the
# kick's beats. Each chord as (root, its octave, its fifth, the passing note), on the driven bass an
# octave down (0 is E1).
LINE_BAR = "R-.R..O.R-.F..P."
CHORD_NOTES = {   # by the chord's root and the next chord's root
    (0, 8): ("0", "c", "7", "7"), (8, 10): ("8", "e", "c", "9"), (10, 7): ("a", "j", "f", "8"), (7, 0): ("7", "i", "d", "l"),
    (0, 5): ("0", "c", "7", "4"), (5, 3): ("5", "f", "c", "4"), (3, -2): ("3", "e", "a", "9"), (-2, 0): ("a", "j", "f", "l"),
    (0, 0): ("0", "c", "7", "l"), (8, 7): ("8", "e", "c", "8"),
}


def line(roots):
    """The bass line over a run of bar roots (each with the next, the last wrapping to the first)."""
    out = []
    for i, r in enumerate(roots):
        nr, o, f, pn = CHORD_NOTES[r, roots[(i + 1) % len(roots)]]
        out.append(LINE_BAR.replace("R", nr).replace("O", o).replace("F", f).replace("P", pn))
    return "".join(out)


def bar_roots(call, section, n=None):
    chords = call["chords"][section]
    return [chords[b % len(chords)][0] for b in range(n or len(chords))]


def battle_round_two(call, groove="g2", synth="arp"):
    """Night Shift's battle half, second cut: see the module's notes."""
    p = lambda *a, **k: P.part(call, *a, **k)   # noqa: E731
    riff = p("bass", "D", gain=0.34)
    voices = []
    for v in call["voices"]:
        inst, v = v["inst"], dict(v)
        if inst in ("guitar_real", "bass"):
            continue   # the mechanical guitar and the crunch synth's dark roots and riff: the groove, the line and the riff below
        if inst == "brass":
            v["gain"] = 0.24
        elif inst == "chime_metal":
            v["gain"] = 0.2
        elif inst == "sub_bass" and "A" in v["pat"]:
            v["gain"] = 0.24   # the pulse under the line
        elif inst == "lead":
            v.update(inst="lead_real", gain=0.3)
        voices.append(v)
    fig = GROOVES[groove][2]
    chug = {s: P.figure(fig, [P.spell(r) for r in bar_roots(call, s)]) for s in "IACDRO"}
    voices += [
        # The guitar palm-muted on the roots, a groove under the band rather than its lead.
        {"inst": "guitar_real", "mode": "riff", "gain": 0.38, "octave": -1, "pat": chug},
        # The line all through the grooves, the riff in D, held roots through the breakdown.
        {"inst": "bass_real", "mode": "riff", "gain": 0.38, "hold": 0.9, "octave": -1, "params": {"drive": 3.5},
         "pat": {s: line(bar_roots(call, s)) for s in "IACRO"}},
        {"inst": "bass_real", "mode": "riff", "gain": 0.38, "hold": 1.1, "params": {"drive": 3.5}, "pat": {"D": riff}},
        {"inst": "bass", "mode": "riff", "gain": 0.3, "hold": 1.0, "params": {"drive": 3.5, "cutoff": 900.0}, "pat": {"D": riff}},
        {"inst": "bass_real", "mode": "riff", "gain": 0.32, "legato": True, "params": {"drive": 3.5}, "pat": {"B": p("sub_bass", "B")}},
        # Ringing chords through the breakdown.
        {"inst": "guitar_hold", "mode": "stab", "gain": 0.55, "dur": 16, "pat": {"B": "x..............."}},
    ]
    if synth == "arp":
        # Up and down two octaves of each chord in sixteenths on the lead's voice, the intro's
        # second half and every groove.
        arp = "0123432101234321"
        voices.append({"inst": "lead", "mode": "chord", "octave": 2, "gain": 0.12, "dur": 1.4,
                       "pat": {"I": "." * 64 + arp, "A": arp, "C": arp, "R": arp, "O": arp}})
    elif synth == "hook":
        # The chime's hook an octave under it on the FM synth, where the chime plays it.
        voices.append({"inst": "synlead", "mode": "chord", "octave": 1, "gain": 0.2, "dur": 3.0,
                       "pat": {s: p("chime_metal", s, mode="chord") for s in "ARO"}})
    drums = {
        "kick": {"I": "x...x...x...x..." * 7 + "x...x...x.......", "A": GROOVE_KICK, "C": LEAD_KICK, "R": GROOVE_KICK,
                 "B": "x.....x...x....." * 6 + "x...x...x...x..." + "x.x.x.x.x.x.x.x.",
                 "D": "x.xx..x.x.xx..x." * 3 + "x.xx..x.x.xx.xx." + "x.xx..x.x.xx..x." * 2 + "x.xx.xx.x.xx.xx." + "x...x...x.......",
                 "O": bars("x...x...x...x..x", "x...x..xx...x...") * 4},
        "kick_hard": {"D": "." * 120 + "xxxxxxxx"},   # a double-kick run out of the riff
        "snare": {"I": "....x.......x..." * 8, "A": GROOVE_SNARE, "C": GROOVE_SNARE, "R": GROOVE_SNARE,
                  "B": "........x......." * 6 + "4.4.5.5.6.6.7.7." + "5566778899xxxxxx",   # half time, then a build
                  "D": "....x..o.o..x..o" * 7 + "....x.......x.x.",
                  "O": bars("....x..o....x..o", "....x..o.o..x...") * 4},
        "hat": {"I": HATS, "A": HATS, "R": "x" * 112 + "xxxxxxxx........", "O": "xx.xxx.xxx.xxx.x",
                "B": "x.x.x.x.x.x.x.x." * 6 + "." * 32, "D": "x" * 120 + "........"},
        "open": {"I": OPENS, "A": OPENS, "O": "..x...x...x...x.", "C": "..............x." * 7 + "." * 16},
        "ride": {"C": "x.x.x.x.x.x.x.x." * 7 + "x.x.x.x........."},
        # A crash at every door but the top's (Ryan: it broke the loop), and each phrase.
        "crash": {"*": P.door_pattern(call, "ABCDRO"), "A": "x" + "." * 127, "C": "x" + "." * 127,
                  "D": "x" + "." * 31, "R": "x" + "." * 31},
        "china": {"A": "." * 62 + "x." + "." * 64, "C": "." * 62 + "x." + "." * 64, "O": "." * 62 + "x." + "." * 64,
                  "D": "........x......." + "." * 16, "R": "........x......." + "." * 16},
        "stack": {"D": "..x...x...x...x.", "R": "..x...x...x...x."},
        "tom": {s: FILLS["tom"] for s in "IACR"},
        "tom2": {s: FILLS["tom2"] for s in "IACR"},
        # The map's industry over the kit.
        "knock": {s: "......x.......x." for s in "ACRO"} | {"D": "..x...x...x...x."},
        "tick": {s: "x" * 16 for s in "ACRO"},
        "clank": {"A": "..............x" + "." * 49, "R": "..............x" + "." * 17, "D": "..............x" + "." * 17},
        "glitch": {"I": "........x.......", "A": "...x.......x....x.........x.....", "D": "...x.......x....", "O": "........x......."},
    }
    kit = P.fight_kit()
    kit.update({"knock": (F.knock_perc(), 0.5), "tick": (F.tick(), 0.22), "clank": (F.clank(), 0.25),
                "glitch": (F.glitch_perc(), 0.3), "kick_hard": (F.variants(F.kick_real), 1.9)})
    return {"kit": kit, "drums": drums, "voices": voices, "pad": [{"inst": "choir_real", "gain": 0.22, "vowel": "oh", "sections": "B"}],
            "drum_gain": {"I": 1.0, "A": 1.1, "B": 1.0, "C": 1.1, "D": 1.25, "R": 1.2, "O": 1.1},
            "air": (0.12, 0.06), "master": 1.1, "headroom": 0.6, "tilt": 1.5, "presence": 0.25, "low": (150.0, -6.0)}


# ---------------------------------------------------------------- the renders

def on_form(form):
    """The recipe's call on another form (an excerpt)."""
    saved = F.MUSIC[NAME]["form"]
    F.MUSIC[NAME]["form"] = form
    try:
        return P.recipe_call(F.music_night_shift)
    finally:
        F.MUSIC[NAME]["form"] = saved


def battle(form=None, **opts):
    call = on_form(form) if form else P.recipe_call(F.music_night_shift)
    kw = dict(call)
    kw.update(battle_round_two(call, **opts))
    return F.groove(**kw)


def map_half():
    return F.groove(**map_intro(P.recipe_call(F.music_night_shift)))


EXCERPT = "AAAAAAAA"   # the groove's eight chords, from its first bar
SETS = [
    {"id": "g", "half": "battle", "title": "The battle's guitar: its groove", "note": "The groove's eight bars with the round's drums, bass line and arpeggio; only the guitar's rhythm changes, at its new level, about half the first cut's.",
     "rows": [(k, g[0], g[1], {"groove": k}) for k, g in GROOVES.items()]},
    {"id": "s", "half": "battle", "title": "The battle's synth line", "note": "The same bars on the three-three-two guitar: the bass line alone, the chime's hook on a synth, or an arpeggio.",
     "rows": [("s0", "The bass line alone", "No synth line: the line, the guitar and the drums carry it.", {"synth": None}),
              ("s1", "The hook on a synth", "The chime's hook doubled an octave under it on the FM synth.", {"synth": "hook"}),
              ("s2", "An arpeggio", "Up and down two octaves of each chord in sixteenths on the lead's voice (the full pair's).", {"synth": "arp"})]},
]
PAIR = {"id": "night_shift_r2", "title": "Night Shift, round two"}
INTRO = "intro: the kick on every beat and the hats, the pad fading in through the fourth bar and swelling from 0:10, the sub from the fifth"


def render_row(job):
    si, ri = job
    F.seed("night2_" + SETS[si]["id"])
    return si, ri, battle(EXCERPT, **SETS[si]["rows"][ri][3])


def render_full(which):
    if which == "battle":
        F.seed(NAME + "_battle")
        x, db = battle(), BATTLE_LEVEL
    else:
        F.seed(NAME)
        x, db = map_half(), MAP_LEVEL
    P.write("%s_%s" % (PAIR["id"], which), F.limit(F.write_level(x, NAME, db)), aac=False)
    return which


def seam(x):
    """The loop's seam as the game plays it: the outro's last four bars, then the top on into the groove's fifth bar."""
    at = P.bar_times(NAME)
    return np.concatenate([x[int(round(at[68] * F.SR)):], x[:int(round(at[12] * F.SR))]])


def main(argv):
    wanted = argv or [s["id"] for s in SETS] + ["full"]
    os.makedirs(P.OUT, exist_ok=True)
    jobs = [(si, ri) for si, s in enumerate(SETS) if s["id"] in wanted for ri in range(len(s["rows"]))]
    with ProcessPoolExecutor(max_workers=4) as pool:
        fulls = [pool.submit(render_full, w) for w in (("battle", "map") if "full" in wanted else ())]
        raw = {(si, ri): x for si, ri, x in pool.map(render_row, jobs)}
        for f in fulls:
            f.result()
    path = os.path.join(P.OUT, "night2.json")
    manifest = json.load(open(path)) if os.path.exists(path) else {"sets": [], "tracks": [], "seams": []}
    for si, s in enumerate(SETS):
        if s["id"] not in wanted:
            continue
        gain = 10.0 ** ((BATTLE_LEVEL - F.mean_level(raw[si, 0])) / 20.0)   # one gain for the set, from its first row
        rows = []
        for ri, (rid, title, note, _opts) in enumerate(s["rows"]):
            x = F.limit(raw[si, ri] * gain)
            rows.append({"id": rid, "title": title, "note": note, "file": os.path.basename(P.write("night2_" + rid, x)),
                         "seconds": round(len(x) / F.SR, 2), "phone_db": P.measure(rid, x)["phone_db"]})
        manifest["sets"] = [e for e in manifest["sets"] if e["id"] != s["id"]] + [{"id": s["id"], "half": s["half"], "title": s["title"], "note": s["note"], "rows": rows}]
        print("%-2s %s" % (s["id"], "  ".join("%s %.1f" % (r["id"], r["phone_db"]) for r in rows)))
    manifest["sets"].sort(key=lambda e: [s["id"] for s in SETS].index(e["id"]))
    if "full" in wanted:
        m, b = (P.read_wav(os.path.join(P.OUT, "%s_%s.wav" % (PAIR["id"], w))) for w in ("map", "battle"))
        if len(m) != len(b):
            raise ValueError("the halves are %d and %d samples" % (len(m), len(b)))
        P.write(PAIR["id"] + "_pair", [m, b], kbps=384)
        runs, total = F.sections(NAME)
        levels = [P.measure("map", m), P.measure("battle", b)]
        manifest["tracks"] = [{"id": PAIR["id"], "title": PAIR["title"], "new": "both", "bpm": F.MUSIC[NAME]["bpm"], "length": round(total, 3),
                               "loop_from_bar": 1, "bar_at": [round(float(t), 4) for t in P.bar_times(NAME)],
                               "sections": [{"section": s, "bars": [b0, b1], "at": round(at, 2), "what": INTRO if s == "I" else what} for s, b0, b1, at, what in runs],
                               "levels": levels}]
        shipped = {"map": P.read_wav(os.path.join(P.AUDIO, NAME + ".wav")), "battle": P.read_wav(os.path.join(P.OUT, "night_shift_battle.wav"))}
        notes = {"map": ("As it ships", "The outro into the intro: the sub's pulse and the pad from the top.", "The front cut", "The intro on the kick and the hats; the pad fades in through the fourth bar and swells from 0:10, the sub joins at the fifth."),
                 "battle": ("The first cut", "With the crash at the top.", "Round two", "No crash at the top; the round's band through the seam.")}
        manifest["seams"] = []
        for half, x in (("map", m), ("battle", b)):
            t0, n0, t1, n1 = notes[half]
            rows = []
            for rid, title, note, src in (("was", t0, n0, shipped[half]), ("new", t1, n1, x)):
                cut = seam(src)
                rows.append({"id": "%s_%s" % (half, rid), "title": title, "note": note, "seconds": round(len(cut) / F.SR, 2),
                             "file": os.path.basename(P.write("night2_seam_%s_%s" % (half, rid), cut))})
            manifest["seams"].append({"id": "n" + half[0], "half": half, "title": "The %s half's loop: the outro into the top" % half,
                                      "note": "The outro's last four bars, then the top into the groove's fifth bar, as the game loops it.", "rows": rows})
        print("%s  map %.1f (phone %.1f)  battle %.1f (phone %.1f)" % (PAIR["id"], levels[0]["mean_db"], levels[0]["phone_db"], levels[1]["mean_db"], levels[1]["phone_db"]))
    with open(path, "w") as f:
        json.dump(manifest, f, indent=1)
    print(os.path.relpath(path))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
