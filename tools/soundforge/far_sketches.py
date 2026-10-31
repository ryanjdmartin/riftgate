"""The Far Bank the other way round (Ryan, 30 October): the shipped track kept a map track, as it
was first meant, and a battle half built on it.

  "Can we try what would happen to Far Bank if we kept it a map track, and built a battle track on
  it? Since it's kind of in the middle, but was originally supposed to be a map track. Don't scrap
  the 'map' version you made just yet, though. Still could go either way."

The battle half is written on the shipped recipe's own groove call, as every new half is (the
bible's pair row): the same form, metres, chords and notes, so the switch keeps its place. The
rift's battle voice is the electronic chug under the orchestra (The Crossing's engine); here it
drives The Far Bank's own bass lines, never The Crossing's three-three-two ostinato or its pattern
of kick and chug: the groove's cellos struck again in eighths, the lift's bowed riff, the strings
section's and the climax's contrabass, a pulse quickening through the quiet before, which builds
with the horns and the strings swelling into the climax. The kick keeps
its places (Ryan's rule for this track, 24 September) on the full orchestral drum, the soft one
gone, with a backbeat, eighths on the hat, a crash at each door, toms into the turns, timpani on
the climax's beats and a roll into it, and brass on the lift's and the climax's pushes; the
climax's crescendo is halved, since a battle half holds its level. The melodies, the bells, the
harp, the horns, the choir and the pads are the shipped track's own. The map half is the shipped
track as it is; the sketched map half and its pair stay (pair_sketches.py).

    tools/spriter/.venv/bin/python tools/soundforge/far_sketches.py      # the flipped pair, then far1.json beside the pairs
"""
import json
import os
import sys
from concurrent.futures import ProcessPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import pair_sketches as P  # noqa: E402

NAME = "music_far_bank"
PAIR = {"id": "far_bank_flip", "title": "The Far Bank, flipped"}
# The battle half at the track's own level, the rift tracks' (forge's LEVELS); the map half 3 dB
# under it on a phone's speaker, where the rift tracks' map halves sit (pair_sketches.PAIRS), until
# the rift tracks are levelled against Hold The Line (the bible's open levelling row). Matched to
# the other battle halves on a phone instead, it would stand 5 dB over the shipped track in full,
# since most of a rift track's power lies under what a phone plays.
UNDER = 3.0


def driven(line, step=2):
    """A held line struck again every `step` steps through each note's length: the bass line driven."""
    out = list(line)
    i = 0
    while i < len(line):
        if line[i] in ".-":
            i += 1
            continue
        j = i + 1
        while j < len(line) and line[j] == "-":
            j += 1
        for k in range(i, j):
            out[k] = line[i] if (k - i) % step == 0 else "."
        i = j
    return "".join(out)


def soft(value, by=0.5):
    """A crescendo's level with its swing from full cut by `by`."""
    return 1.0 + (value - 1.0) * by


def battle_far_bank(call):
    """The Far Bank's battle half: see the module's notes."""
    p = lambda *a, **k: P.part(call, *a, **k)   # noqa: E731
    cellos = p("cello", "A")
    voices = [dict(v) for v in call["voices"]] + [
        # The engine: the electronic chug on the track's own bass lines, an octave under them.
        {"inst": "e_chug", "mode": "riff", "gain": 0.55, "hold": 0.8, "octave": -1,
         "pat": {"P": "0.0.0.0.0.0.0.0." * 4 + driven(cellos), "A": driven(cellos), "B": driven(p("cello", "B")),
                 "C": p("contrabass", "C"), "T": "3.3.3.5.5.5.", "E": p("contrabass", "E"), "G": p("contrabass", "G"),
                 "H": "0" + "." * 63}},
        # The quiet before, held up as a battle half holds its level: the pulse quickening into the climax.
        {"inst": "e_chug", "mode": "riff", "gain": 0.8, "hold": 0.8, "octave": -1,
         "pat": {"V": "0.....0....." * 2 + "g..g..g..g.." + "0.0.0.0.0.0."}},
        # The interlude's exposed chords: the chug on the and of one with the cellos, closed down.
        {"inst": "e_chug", "mode": "riff", "gain": 0.45, "hold": 1.6, "octave": -1, "params": {"cutoff": 500.0},
         "pat": {"D": "..a............." + "..8............." + "..g.............", "Z": "..0..........."}},
        # The quiet before builds: the horns on each bar's chord, climbing into the climax.
        {"inst": "horn", "mode": "chord", "octave": 1, "gain": 0.16, "dur": 12.0, "shape": (0.5, 1.4), "pat": {"V": "0..........."}},
        # Brass on the pushes: the lift's downbeat and the a of four, the climax's from its repeat edge.
        {"inst": "brass", "mode": "stab", "gain": 0.22, "dur": 2, "pat": {"C": "x.............x."}},
        {"inst": "brass", "mode": "stab", "gain": 0.2, "dur": 2, "pat": {"G": "." * 128 + "x.......x.....x." * 24}},
    ]
    drums = {k: dict(d) for k, d in call["drums"].items()}
    # The full drum where the soft one played, in its places.
    drums["kick"].update({s: pat for s, pat in drums.pop("kick_soft").items()})
    drums["snare"].update({"A": "....x.......x..o", "E": "....x.......x..o"})
    drums["hat"].update({s: "x.x.x.x.x.x.x.x." for s in "ABCEP"} | {"V": "x.x.x.x.x.x."})
    drums["snare"]["V"] = "......x....." * 3 + "......x.x.xx"   # the six-eight's backbeat, a roll into the climax
    drums["open"] = dict(drums.get("open", {}), A="..............x.", C="..............x.")
    drums["crash"] = {"*": P.door_pattern(call, "ACEDH"), "G": "x" + "." * 127}
    drums["tom"] = {"B": "........x.x.....", "G": "." * 112 + "....x.x.xx.x.x..", "Z": "..........x.x.", "V": "." * 36 + "x.x.x......."}
    drums["tom2"] = {"B": "............x.xx", "G": "." * 112 + "......x.....x.xx", "Z": "............x.", "V": "." * 36 + "......x.x.x."}
    drums["timp"] = dict(drums["timp"], V="." * 36 + "x.x.x.xxxxxx")
    kit = dict(call["kit"])
    kit.pop("kick_soft", None)
    kit.update({"crash": ([F.crash_real()], 0.55), "tom": (F.variants(lambda q: F.tom_real(130.0, q)), 1.0),
                "tom2": (F.variants(lambda q: F.tom_real(98.0, q)), 1.0)})
    # The strings swell across the quiet before as well.
    pad = [dict(q) for q in call["pad"]] + [{"inst": "strings", "gain": 0.12, "sections": "V", "swell": [(0.0, 0.6), (1.0, 1.5)]}]
    crescendo = {}
    for s, c in call["crescendo"].items():
        crescendo[s] = [(t, soft(v)) for t, v in c] if isinstance(c, list) else c
    return {"kit": kit, "drums": drums, "voices": voices, "pad": pad, "crescendo": crescendo}


BATTLE_SAID = {   # each section's battle layers, on the page beside the shipped track's own
    "P": "the chug on the root under eighths on the hat, the groove's cellos driven from the fifth bar",
    "A": "the groove's cellos struck in eighths on the chug, the full drum in its places, a backbeat, eighths on the hat",
    "B": "toms into the next section",
    "C": "the bowed riff on the chug, brass on the downbeat and the push",
    "E": "the contrabass's line on the chug, the full drum on one and three",
    "D": "the chug on the and of one with the cellos, the timpani",
    "Z": "toms into the next half",
    "T": "the turn on the chug in six-eight",
    "V": "a build: the chug's pulse quickening over a six-eight backbeat, the horns and the strings swelling, toms and a timpani roll into the climax",
    "G": "the contrabass's line on the chug, a crash every eight bars and toms into it, brass from the repeat edge",
    "H": "the closer's hit on the chug",
}


def render(half):
    """One half, mastered, before its level."""
    if half == "map":
        F.seed(NAME)
        return half, F.music_far_bank()
    F.seed(NAME + "_battle")
    call = P.recipe_call(F.music_far_bank)
    kw = dict(call)
    kw.update(battle_far_bank(call))
    return half, F.groove(**kw)


def main():
    os.makedirs(P.OUT, exist_ok=True)
    with ProcessPoolExecutor(max_workers=2) as pool:
        raw = dict(pool.map(render, ("map", "battle")))
    b = F.limit(F.write_level(raw["battle"], NAME, F.LEVELS[NAME]))
    phone = P.measure("map", raw["map"])
    m = F.limit(F.write_level(raw["map"], NAME, phone["mean_db"] + P.measure("battle", b)["phone_db"] - UNDER - phone["phone_db"]))
    for half, x in (("map", m), ("battle", b)):
        P.write("%s_%s" % (PAIR["id"], half), x, aac=False)
    if len(m) != len(b):
        raise ValueError("the halves are %d and %d samples" % (len(m), len(b)))
    P.write(PAIR["id"] + "_pair", [m, b], kbps=384)
    runs, total = F.sections(NAME)
    levels = [P.measure("map", m), P.measure("battle", b)]
    manifest = {"sets": [], "seams": [], "tracks": [{
        "id": PAIR["id"], "title": PAIR["title"], "new": "battle", "bpm": F.MUSIC[NAME]["bpm"], "length": round(total, 3),
        "loop_from_bar": 1 + int(P.LOOP_FROM.get(NAME, 0)), "bar_at": [round(float(t), 4) for t in P.bar_times(NAME)],
        "sections": [{"section": s, "bars": [b0, b1], "at": round(at, 2), "what": "%s; the battle: %s" % (what, BATTLE_SAID[s])} for s, b0, b1, at, what in runs],
        "levels": levels}]}
    path = os.path.join(P.OUT, "far1.json")
    with open(path, "w") as f:
        json.dump(manifest, f, indent=1)
    print("%s  map %.1f (phone %.1f)  battle %.1f (phone %.1f)" % (PAIR["id"], levels[0]["mean_db"], levels[0]["phone_db"], levels[1]["mean_db"], levels[1]["phone_db"]))
    print(os.path.relpath(path))
    return 0


if __name__ == "__main__":
    sys.exit(main())
