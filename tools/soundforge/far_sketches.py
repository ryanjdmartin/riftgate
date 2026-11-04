"""The Far Bank's map half, its fourth round (Ryan, 3 November, on the third): the leads on single notes.

  "Map strings section - Can I hear the same cuts, but with the leads playing single notes and not
  the chords, and the leads dropped like 3dB? Same with the climax section, but with no volume
  change."

Each lead plays one note at a time now. The clean guitar plays one string where it played a power
chord (the root, its fifth and its octave); a note that rang on under the next (the violins' bowing,
a note sounding a third past its length, which the leads took over) stops where the next begins;
the tritone that sounded against the strings section's last note moves off the lead onto a soft
bell. The plucked string and the tine piano already struck one note at a time. Each lead meets the
violins' level on a phone again, the strings section's 3 dB under it and the climax's at it.

Kept from the third round: the shipped track as the battle half; the map half the first round's
(pair_sketches.map_far_bank) with the bells at half speed and one echo in the groove and the lift
alone, as they were everywhere else, the climax's full; the strings section and the climax keeping
the harp's arpeggios without the orchestra the battle half is made of: the violins' tune on one lead
(the plucked string for the full pair, the tine piano and the clean guitar in the sets), the horns'
break-ins in the strings section on the bells, no horns' melody in the climax, a soft sub on the
roots for the cellos and the contrabass, the choir alone for the string pads. The rest is the first
round's, from its seed. The sets cut the strings section and the climax from the third round's map
half as its pair had it and from each lead's.

    tools/spriter/.venv/bin/python tools/soundforge/far_sketches.py      # the pair and the sets, then far4.json beside the pairs
"""
import json
import os
import sys
from concurrent.futures import ProcessPoolExecutor

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import pair_sketches as P  # noqa: E402
from hold_sketches import master_together, unmastered  # noqa: E402

NAME = "music_far_bank"
PAIR = {"id": "far_bank_r4", "title": "The Far Bank, round four"}
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


def clean_string(f, dur, damp=0.993):
    """The clean guitar on one string: the forge's clean guitar (guitar_real, clean and let ring) on
    its root alone, without the fifth and the octave that make it a power chord."""
    n = F.n_of(dur)
    x = F.pluck(f * F.RNG.uniform(0.998, 1.002), dur, bright=F.RNG.uniform(0.4, 0.6), damp=damp)[:n]
    scrape = F.bp(F.noise(F.n_of(0.012)), 2000.0, 7000.0) * F.env_ad(F.n_of(0.012), 0.0002, 0.003) * 0.6
    x = F.at(x, scrape, 0.0)[:n]
    x = np.clip(F.sat(F.hp(x, 400.0) * 2.5 + x * 1.2, 2.0) * 1.2, -1.0, 1.0)
    x = F.cabinet(x, peaks=((110.0, 1.0), (420.0, 0.9), (1150.0, 0.6)))
    return F.mix(x * F.env_ad(n, 0.001, dur * 0.7, curve=2.0), F.body(200.0, 90.0, 0.05, drive=2.0, click=0.2) * 0.3)


F.NOTE_INST["guitar_string"] = lambda f, d, p: clean_string(f, d, p.get("damp", 0.993))


def one_at_a_time(pat, hold):
    """A riff pattern whose notes never ring into the next: a note written n steps long sounds n
    times `hold`, so one whose next note comes sooner is cut to the longest it can be and stop by
    then. The pattern repeats, so its last note runs to its first."""
    starts = [i for i, c in enumerate(pat) if c not in ".-"]
    out = list(pat)
    for k, i in enumerate(starts):
        n = 1
        while i + n < len(pat) and pat[i + n] == "-":
            n += 1
        gap = (starts[k + 1] if k + 1 < len(starts) else len(pat) + starts[0]) - i
        for j in range(i + min(n, max(1, int(gap / hold))), i + n):
            out[j] = "."
    return "".join(out)


# The leads to try on the violins' tune (Ryan, 31 October: "The voice needs to change. To what, I'm
# not sure."), two octaves up where the violins played it, each on single notes (3 November) at the
# violins' level on a phone's speaker in each section: a plucked or struck note dies where a bow
# holds it, so the strings section's long notes and the climax's quicker ones take a gain each.
# The third round's, the clean guitar on its power chord and every note ringing on, stay for its row.
LEADS = {
    "pluck": {"inst": "pluck", "E": 0.98, "G": 0.42},          # the plucked string
    "tine": {"inst": "epiano", "E": 0.29, "G": 0.21},          # the tine piano
    "clean": {"inst": "guitar_string", "E": 0.45, "G": 0.24},  # the clean guitar on one string
}
LEADS_R3 = {
    "pluck": {"inst": "pluck", "E": 1.0, "G": 0.43},
    "tine": {"inst": "epiano", "E": 0.27, "G": 0.2},
    "clean": {"inst": "guitar_real", "E": 0.42, "G": 0.23, "params": {"mute": False, "clean": True}},
}
LEAD = "pluck"   # the full pair's
VIOLINS = {"E": 0.42, "G": 0.44}   # the violins' tune in each section, whose level a lead's gain meets
LEAD_DB = {"E": -3.0, "G": 0.0}    # the leads 3 dB under the violins in the strings section, at them in the climax
TRITONE_BELL = 0.08                # the tritone against the strings section's last note, on a soft bell
# The soft sub on the roots the contrabass drove, held, about 3 dB under the cellos and the
# contrabass together in each section.
SUB = {"inst": "sub_bass", "mode": "riff", "gain": 0.17, "legato": True,
       "pat": {"E": "0-------3-------a-------7-------0-------5-------3-------g-------",
               "G": "0-------8-------a-------7-------0-------5-------3-------g-------"}}
BREAK_INS = (0.09, 0.14)   # the horns' break-ins on the bells, soft and loud: the groove's bell and the lift's


def map_four(call, lead=LEAD, single=True):
    """The first round's map half re-voiced: see the module's notes; `single` False is the third
    round's. A voice that loses its part stays in the list, so every other voice keeps its index and
    with it its humanising."""
    leads = LEADS if single else LEADS_R3
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
            # The tune on the lead, and the tritone against its last note (a held note alone at
            # the section's end) on the lead in the third round, on a soft bell now.
            for sec in REVOICED:
                if sec not in v["pat"]:
                    continue
                pat = v["pat"].pop(sec)
                if single and v.get("legato"):
                    added.append({"inst": "bell", "mode": "riff", "octave": 2, "gain": TRITONE_BELL, "pat": {sec: pat}})
                    continue
                gain = leads[lead][sec] * v["gain"] / VIOLINS[sec] * (10.0 ** (LEAD_DB[sec] / 20.0) if single else 1.0)
                added.append(dict(v, pat={sec: one_at_a_time(pat, v.get("hold", 0.95)) if single else pat}, inst=leads[lead]["inst"],
                                  gain=round(gain, 3), params=leads[lead].get("params", {})))
        elif inst == "horn" and mode == "chord" and "E" in v["pat"]:
            added.append({"inst": "bell", "mode": "chord", "octave": 2, "dur": 3.5, "gain": BREAK_INS[v["gain"] > 0.2], "pat": {"E": v["pat"].pop("E")}})
        elif inst in ("horn", "cello", "contrabass"):
            v["pat"] = {s: pat for s, pat in v["pat"].items() if s not in REVOICED}
        voices.append(v)
    pads = [dict(p, sections="".join(c for c in p["sections"] if c not in REVOICED)) if p["inst"] == "strings" else p for p in kw["pad"]]
    return dict(kw, voices=voices + added + [dict(SUB, pat=dict(SUB["pat"]))], pad=[p for p in pads if p["sections"]])


def render_map(job):
    """The re-voiced map half with one lead, unmastered, from the first round's seed."""
    lead, single = job
    F.seed(NAME + "_map")
    call = P.recipe_call(F.music_far_bank)
    kw = dict(call)
    kw.update(map_four(call, lead, single))
    return job, unmastered(kw)


# Each set: (id, title, note, the bars cut, by index from 0).
SETS = [("fe", "The map's strings section", "The tune over the harp's arpeggios, the break-ins on the bells; the leads on single notes, 3 dB under the violins' level on a phone.", (24, 40)),
        ("fg", "The map's climax", "Its first sixteen bars: the full bells, the tune on single notes at the violins' level, swelling in turn from the repeat edge.", (53, 69))]
THIRD = ("pluck", False)   # the third round's pair, the reference row
ROWS = [(("pluck", True), "The plucked string", "The tune on the plucked string, one note at a time (the full pair's)."),
        (("tine", True), "The tine piano", "The tune on the tine piano, one note at a time."),
        (("clean", True), "The clean guitar", "The tune on the clean guitar on one string, where it played a power chord.")]


def main():
    os.makedirs(P.OUT, exist_ok=True)
    jobs = [THIRD] + [job for job, _t, _n in ROWS]
    with ProcessPoolExecutor(max_workers=4) as pool:
        raw = dict(pool.map(render_map, jobs))
    # One master and one gain for the leads and the third round's, the gain the one that brings the
    # full pair's to the map's level, so the rows differ only by what changed.
    mastered = dict(zip(jobs, master_together([raw[job] for job in jobs])))
    gain = 10.0 ** ((MAP_LEVEL - F.mean_level(mastered[(LEAD, True)])) / 20.0)
    leads = {job: F.limit(x * gain) for job, x in mastered.items()}
    m = leads[(LEAD, True)]
    P.write(PAIR["id"] + "_map", m, aac=False)
    _r1, b = P.halves("far_bank")   # the shipped track
    if len(m) != len(b):
        raise ValueError("the halves are %d and %d samples" % (len(m), len(b)))
    P.write(PAIR["id"] + "_pair", [m, b], kbps=384)
    at = P.bar_times(NAME)
    edges = list(at) + [len(m) / F.SR]
    sets = []
    for sid, title, note, (b0, b1) in SETS:
        rows = []
        for k, (rtitle, rnote, x) in enumerate([("As the third round's pair had it", "The plucked string, each note ringing a third past its length into the next, the tritone on it at the strings section's end, at the violins' level.", leads[THIRD])] +
                                               [(rtitle, rnote, leads[job]) for job, rtitle, rnote in ROWS]):
            rid = "%s%d" % (sid, k)
            cut = x[int(round(edges[b0] * F.SR)):int(round(edges[b1] * F.SR))]
            rows.append({"id": rid, "title": rtitle, "note": rnote, "file": os.path.basename(P.write("far4_" + rid, cut)),
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
    path = os.path.join(P.OUT, "far4.json")
    with open(path, "w") as f:
        json.dump(manifest, f, indent=1)
    print("%s  map %.1f (phone %.1f)  battle %.1f (phone %.1f)" % (PAIR["id"], levels[0]["mean_db"], levels[0]["phone_db"], levels[1]["mean_db"], levels[1]["phone_db"]))
    print(os.path.relpath(path))
    return 0


if __name__ == "__main__":
    sys.exit(main())
