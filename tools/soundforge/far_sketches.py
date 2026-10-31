"""The Far Bank's map half, its third round (Ryan, 31 October, on the second): the strings re-voiced.

  "Far bank - minimal bells in groove/lift work. strings section - the issue actually is the
  strings and horns, the harp/bells were fine. The voice needs to change. To what, I'm not sure.
  It just sounds like the battle without drums. CLimax - same issue as above, the full bells are
  actually ok here but the other voices just make it sound too full and close to the battle
  version."

The shipped track stays the battle half; the map half was the first round's, the orchestra
without its kit (pair_sketches.map_far_bank), then the second's, thinner. Now the bells play their
figures at half speed with one echo in the groove and the lift alone and as they were everywhere
else, the climax's full again. The strings section and the climax keep the harp's arpeggios and
lose the orchestra the battle half is made of: the violins' tune goes to one lead (the plucked
string for the full pair, the tine piano and the clean guitar in the sets, each at the violins'
level on a phone's speaker), the horns' break-ins in the strings section to the bells, the horns'
melody in the climax goes, the cellos and the contrabass give way to a soft sub on the roots, the
string pads to the choir alone. The rest is the first round's, from its seed. The sets cut the
strings section and the climax from the first round's map half as it was heard and from each lead's.

    tools/spriter/.venv/bin/python tools/soundforge/far_sketches.py      # the pair and the sets, then far3.json beside the pairs
"""
import json
import os
import sys
from concurrent.futures import ProcessPoolExecutor

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import pair_sketches as P  # noqa: E402
from hold_sketches import master_together, unmastered  # noqa: E402

NAME = "music_far_bank"
PAIR = {"id": "far_bank_r3", "title": "The Far Bank, round three"}
MAP_LEVEL = P.PAIRS["far_bank"]["level"]   # the first round's map level, 3 dB under the battle half on a phone
QUIET_ECHO = (3, 0.42, 1)   # the bells' echo, once
CALM = "ABC"   # the groove, its turn bar and the lift ("minimal bells in groove/lift work")
REVOICED = "EG"   # the strings section and the climax


def calm(pattern):
    """A bell pattern calmed: a figure in even eighths at half speed, its contour on the quarters;
    any other figure in four-four kept to its notes on the quarters; one in another metre as it was."""
    if len(pattern) % 16:
        return pattern
    notes = [c for c in pattern if c != "."]
    if len(notes) * 2 == len(pattern) and all(pattern[i] != "." for i in range(0, len(pattern), 2)):
        return "".join(n + "..." for n in notes[:len(pattern) // 4])
    return "".join(c if i % 4 == 0 else "." for i, c in enumerate(pattern))


# The leads to try on the violins' tune (Ryan: "The voice needs to change. To what, I'm not sure."),
# two octaves up where the violins played it, each at the violins' level on a phone's speaker in
# each section: a plucked or struck note dies where a bow holds it, so the strings section's long
# notes and the climax's quicker ones take a gain each.
LEADS = {
    "pluck": {"inst": "pluck", "E": 1.0, "G": 0.43},                                              # the plucked string
    "tine": {"inst": "epiano", "E": 0.27, "G": 0.2},                                              # the tine piano
    "clean": {"inst": "guitar_real", "E": 0.42, "G": 0.23, "params": {"mute": False, "clean": True}},   # the clean guitar
}
LEAD = "pluck"   # the full pair's
VIOLINS = {"E": 0.42, "G": 0.44}   # the violins' tune in each section, whose level a lead's gain meets
# The soft sub on the roots the contrabass drove, held, about 3 dB under the cellos and the
# contrabass together in each section.
SUB = {"inst": "sub_bass", "mode": "riff", "gain": 0.17, "legato": True,
       "pat": {"E": "0-------3-------a-------7-------0-------5-------3-------g-------",
               "G": "0-------8-------a-------7-------0-------5-------3-------g-------"}}
BREAK_INS = (0.09, 0.14)   # the horns' break-ins on the bells, soft and loud: the groove's bell and the lift's


def map_three(call, lead=LEAD):
    """The first round's map half re-voiced: see the module's notes. A voice that loses its part
    stays in the list, so every other voice keeps its index and with it its humanising."""
    kw = P.map_far_bank(call)
    voices, added = [], []
    for v in kw["voices"]:
        v = dict(v, pat=dict(v["pat"]))
        inst, mode = v["inst"], v.get("mode", "riff")
        if inst == "bell":
            calmed = {s: calm(pat) for s, pat in v["pat"].items() if s in CALM}
            if calmed:
                added.append(dict(v, pat=calmed, echo=QUIET_ECHO))
                v["pat"] = {s: pat for s, pat in v["pat"].items() if s not in CALM}
        elif inst == "violin" and any(s in v["pat"] for s in REVOICED):
            # The tune, and the tritone against its last note, on the lead.
            for sec in REVOICED:
                if sec in v["pat"]:
                    added.append(dict(v, pat={sec: v["pat"].pop(sec)}, inst=LEADS[lead]["inst"],
                                      gain=round(LEADS[lead][sec] * v["gain"] / VIOLINS[sec], 3), params=LEADS[lead].get("params", {})))
        elif inst == "horn" and mode == "chord" and "E" in v["pat"]:
            added.append({"inst": "bell", "mode": "chord", "octave": 2, "dur": 3.5, "gain": BREAK_INS[v["gain"] > 0.2], "pat": {"E": v["pat"].pop("E")}})
        elif inst in ("horn", "cello", "contrabass"):
            v["pat"] = {s: pat for s, pat in v["pat"].items() if s not in REVOICED}
        voices.append(v)
    pads = [dict(p, sections="".join(c for c in p["sections"] if c not in REVOICED)) if p["inst"] == "strings" else p for p in kw["pad"]]
    return dict(kw, voices=voices + added + [dict(SUB, pat=dict(SUB["pat"]))], pad=[p for p in pads if p["sections"]])


def render_map(lead):
    """The re-voiced map half with one lead, unmastered, from the first round's seed."""
    F.seed(NAME + "_map")
    call = P.recipe_call(F.music_far_bank)
    kw = dict(call)
    kw.update(map_three(call, lead))
    return lead, unmastered(kw)


# Each set: (id, title, note, the bars cut, by index from 0).
SETS = [("fe", "The map's strings section", "The tune over the harp's arpeggios, the break-ins.", (24, 40)),
        ("fg", "The map's climax", "Its first sixteen bars: the full bells, the leads swelling in turn from the repeat edge.", (53, 69))]
ROWS = [("pluck", "The plucked string", "The tune on the plucked string (the full pair's)."),
        ("tine", "The tine piano", "The tune on the tine piano."),
        ("clean", "The clean guitar", "The tune on the clean guitar.")]


def main():
    os.makedirs(P.OUT, exist_ok=True)
    with ProcessPoolExecutor(max_workers=3) as pool:
        raw = dict(pool.map(render_map, [lead for lead, _t, _n in ROWS]))
    # One master and one gain for the leads, the gain the one that brings the full pair's to the
    # map's level, so the leads differ only by what changed.
    mastered = dict(zip([lead for lead, _t, _n in ROWS], master_together([raw[lead] for lead, _t, _n in ROWS])))
    gain = 10.0 ** ((MAP_LEVEL - F.mean_level(mastered[LEAD])) / 20.0)
    leads = {lead: F.limit(x * gain) for lead, x in mastered.items()}
    m = leads[LEAD]
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
        for k, (rtitle, rnote, x) in enumerate([("As it was", "The first round's map half: the violins' tune, the horns, the cellos and the contrabass, the string pads.", r1)] +
                                               [(rtitle, rnote, leads[lead]) for lead, rtitle, rnote in ROWS]):
            rid = "%s%d" % (sid, k)
            cut = x[int(round(edges[b0] * F.SR)):int(round(edges[b1] * F.SR))]
            rows.append({"id": rid, "title": rtitle, "note": rnote, "file": os.path.basename(P.write("far3_" + rid, cut)),
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
    path = os.path.join(P.OUT, "far3.json")
    with open(path, "w") as f:
        json.dump(manifest, f, indent=1)
    print("%s  map %.1f (phone %.1f)  battle %.1f (phone %.1f)" % (PAIR["id"], levels[0]["mean_db"], levels[0]["phone_db"], levels[1]["mean_db"], levels[1]["phone_db"]))
    print(os.path.relpath(path))
    return 0


if __name__ == "__main__":
    sys.exit(main())
