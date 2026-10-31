"""The Far Bank's map half, its second round (Ryan, 30 October): minimal.

  "far bank flipped doesn't work, lets work on the original map version" and, of the map halves,
  "in general the map tracks need to be minimalist."

The shipped track stays the battle half. The first round's map half (pair_sketches.map_far_bank)
kept every orchestral voice and dropped only the kit, the timpani and the hits. Now it thins: the
bells, which play eighths with their echoes through the groove, the lift and the climax, play their
figures at half speed with one echo (Hold The Line's first lift had the same wash: "the bells are
too busy"); the harp's arpeggios and the contrabass's driving three-three-two leave the strings
section and the climax, where the violins, the horns, the cellos and the pads carry them. The rest is
the first round's, from its seed. The sets cut the groove and the lift, the strings section and the
climax from the two map halves as the pair plays them, the first round's as it was heard.

    tools/spriter/.venv/bin/python tools/soundforge/far_sketches.py      # the pair and the sets, then far2.json beside the pairs
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import pair_sketches as P  # noqa: E402

NAME = "music_far_bank"
PAIR = {"id": "far_bank_r2", "title": "The Far Bank, round two"}
MAP_LEVEL = P.PAIRS["far_bank"]["level"]   # the first round's map level, 3 dB under the battle half on a phone
QUIET_ECHO = (3, 0.42, 1)   # the bells' echo, once


def calm(pattern):
    """A bell pattern calmed: a figure in even eighths at half speed, its contour on the quarters;
    any other figure in four-four kept to its notes on the quarters; one in another metre as it was."""
    if len(pattern) % 16:
        return pattern
    notes = [c for c in pattern if c != "."]
    if len(notes) * 2 == len(pattern) and all(pattern[i] != "." for i in range(0, len(pattern), 2)):
        return "".join(n + "..." for n in notes[:len(pattern) // 4])
    return "".join(c if i % 4 == 0 else "." for i, c in enumerate(pattern))


def map_minimal(call):
    """The first round's map half, thinned: see the module's notes."""
    kw = P.map_far_bank(call)
    voices = []
    for v in kw["voices"]:
        v = dict(v, pat=dict(v["pat"]))
        if v["inst"] == "bell":
            v["pat"] = {s: calm(pat) for s, pat in v["pat"].items()}
            v["echo"] = QUIET_ECHO
        elif (v["inst"] == "harp" and v.get("mode") == "chord") or (v["inst"] == "contrabass" and ("E" in v["pat"] or "G" in v["pat"])):
            v["pat"] = {s: pat for s, pat in v["pat"].items() if s not in "EG"}
        voices.append(v)
    return dict(kw, voices=voices)


def render_map():
    """The minimal map half from the first round's seed, at its level."""
    F.seed(NAME + "_map")
    call = P.recipe_call(F.music_far_bank)
    kw = dict(call)
    kw.update(map_minimal(call))
    return F.limit(F.write_level(F.groove(**kw), NAME, MAP_LEVEL))


# Each set: (id, title, note, the bars cut, by index from 0).
SETS = [("fa", "The map's groove and lift", "The groove's bells and the horn's answers, the turn, the lift's bowed riff and its bells.", (8, 24)),
        ("fe", "The map's strings section", "The violins' tune over the cellos' chords, the horns breaking in.", (24, 40)),
        ("fg", "The map's climax", "Its first sixteen bars: the leads swelling in turn from the repeat edge.", (53, 69))]


def main():
    os.makedirs(P.OUT, exist_ok=True)
    m = render_map()
    P.write(PAIR["id"] + "_map", m, aac=False)
    r1, b = P.halves("far_bank")   # the first round's map half as it was heard, the shipped track
    if len(m) != len(b):
        raise ValueError("the halves are %d and %d samples" % (len(m), len(b)))
    P.write(PAIR["id"] + "_pair", [m, b], kbps=384)
    at = P.bar_times(NAME)
    edges = list(at) + [len(m) / F.SR]
    sets = []
    for sid, title, note, (b0, b1) in SETS:
        rows = []
        for rid, rtitle, rnote, x in ((sid + "0", "As it was", "The first round's map half.", r1),
                                      (sid + "1", "Minimal", "The bells at half speed with one echo, the harp's arpeggios and the contrabass's drive gone (the full pair's).", m)):
            cut = x[int(round(edges[b0] * F.SR)):int(round(edges[b1] * F.SR))]
            rows.append({"id": rid, "title": rtitle, "note": rnote, "file": os.path.basename(P.write("far2_" + rid, cut)),
                         "seconds": round(len(cut) / F.SR, 2), "phone_db": P.measure(rid, cut)["phone_db"]})
        sets.append({"id": sid, "half": "map", "title": title, "note": note, "rows": rows})
        print("%-2s %s" % (sid, "  ".join("%s %.1f" % (r["id"], r["phone_db"]) for r in rows)))
    runs, total = F.sections(NAME)
    levels = [P.measure("map", m), P.measure("battle", b)]
    manifest = {"sets": sets, "seams": [], "tracks": [{
        "id": PAIR["id"], "title": PAIR["title"], "new": "map", "bpm": F.MUSIC[NAME]["bpm"], "length": round(total, 3),
        "loop_from_bar": 1 + int(P.LOOP_FROM.get(NAME, 0)), "bar_at": [round(float(t), 4) for t in at],
        "sections": [{"section": s, "bars": [b0, b1], "at": round(t0, 2), "what": what} for s, b0, b1, t0, what in runs],
        "levels": levels}]}
    path = os.path.join(P.OUT, "far2.json")
    with open(path, "w") as f:
        json.dump(manifest, f, indent=1)
    print("%s  map %.1f (phone %.1f)  battle %.1f (phone %.1f)" % (PAIR["id"], levels[0]["mean_db"], levels[0]["phone_db"], levels[1]["mean_db"], levels[1]["phone_db"]))
    print(os.path.relpath(path))
    return 0


if __name__ == "__main__":
    sys.exit(main())
