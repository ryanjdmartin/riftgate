"""The Far Bank's map half, its fifth round (Ryan, 4 November, on the fourth): the choir in the intro
alone, the plucked string, the cellos re-voiced.

  "Far bank, map half: remove the choir from the entire map half except the P intro. In the climax,
  keep volumes consistent. I think I want the single note plucked guitar for both strings and climax
  section, but lower it 3db for the strings section. I think cellos might need a new voice too for
  the map half, to match more with the plucked string."

The choir's pads leave every section but the intro (P), the strings section and the climax left on
the harp, the bells, the tune and the soft sub. The tune is the plucked string on single notes in
both, as the fourth round's pair had it, the strings section's 3 dB under what he heard there (6 dB
under the violins' level, "lower it 3db" read as his "bring it down like 3 db" was on Hold The Line's
K, from what he heard), the climax's at the violins' level. "Keep volumes consistent" is read as the
climax keeping its level once the choir leaves it: against the rest of the half it fell 0.45 dB on a
phone and rose 1.0 dB in full, the rest's cellos plucked and lighter in the lows, so its voices come
down 0.28 dB, which holds it halfway between the two as the cellos' voices are held (CLIMAX_HOLD),
its rotating swells kept, a row levelling them too. The cellos (the groove's line from the intro's second half, the quiet six-eight, the interlude,
the closer) go to the plucked string in their register for the full pair, beside the bowed cellos,
the harp low and the soft sub with a pluck in a set of whole map halves (CELLOS); the contrabass of
the lift stays bowed. Sets of the strings section (the two levels) and the whole climax (the fourth
round's pair, the level held, the swells levelled) beside them.

The fourth round's, kept (map_four): each lead on single notes, a note that rang on under the next
stopping where the next begins, the tritone at the strings section's end on a soft bell; the shipped
track as the battle half; the map half the first round's (pair_sketches.map_far_bank) with the bells
at half speed and one echo in the groove and the lift alone, the climax's full; the strings section
and the climax without the battle's orchestra, the horns' break-ins in the strings section on the
bells, no horns' melody in the climax, a soft sub on the roots for the cellos and the contrabass.

    tools/spriter/.venv/bin/python tools/soundforge/far_sketches.py      # the pair and the sets, then far5.json beside the pairs
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
PAIR = {"id": "far_bank_r5", "title": "The Far Bank, round five"}
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


# The fifth round (Ryan, 4 November, on the fourth): "remove the choir from the entire map half
# except the P intro. In the climax, keep volumes consistent. I think I want the single note plucked
# guitar for both strings and climax section, but lower it 3db for the strings section. I think
# cellos might need a new voice too for the map half, to match more with the plucked string."
CHOIR_IN = "P"                     # the choir's pad in the intro alone
STRINGS_DB = -6.0                  # the plucked string in the strings section, 3 dB under the fourth round's 3 dB under the violins
# The cellos' voice through the map half (the groove's line from the intro's second half, the quiet
# six-eight, the interlude and the closer), each new voice at the bowed cellos' level on a phone.
# A plucked note is brighter than a bow and dies where a bow holds, so the pluck and the harp meet the
# bowed cellos on a phone 5.5 dB light in full, and the soft sub, dark, 7.4 dB heavy; each sits
# between (measured over the whole map half): the pluck and the harp 2.75 dB over the bowed cellos on
# a phone and as far under in full, the sub 3.7 dB under on a phone and over in full.
CELLOS = {
    "bowed": None,                                    # the cellos as they were
    "pluck": {"inst": "pluck", "level": 2.0},          # the plucked string, the lead's own voice, in the cellos' register
    "harp": {"inst": "harp", "level": 2.25},           # the harp low
    "sub": {"inst": "sub_pluck", "level": 0.755},      # the soft sub with a finger's pluck
}
CELLO = "pluck"                    # the full pair's ("to match more with the plucked string")
CLIMAX_HOLD = 0.968                # the climax's voices 0.28 dB down: with the choir out it fell 0.45 dB against the rest of the half on a phone and rose 1.0 dB in full; halfway is the fourth round's place (-1.50 dB on a phone, -1.67 in full)


def flat(shape):
    """A voice's swells across its run levelled to one gain, the root mean square of what it had, its
    cut before the closer kept."""
    pos = np.linspace(0.0, 1.0, 2001)
    y = np.interp(pos, [q[0] for q in shape], [q[1] for q in shape])
    cut = shape[-1][1] == 0.0 and shape[-2][1] == 0.0
    end = shape[-3][0] if cut else 1.0
    m = float(np.sqrt(np.mean(y[pos <= end] ** 2)))
    return [(0.0, m), (end, m), (shape[-2][0], 0.0), (1.0, 0.0)] if cut else [(0.0, m), (1.0, m)]


def map_five(call, cello=CELLO, strings_db=STRINGS_DB, climax="held"):
    """The fourth round's map half with the plucked string on single notes, the choir in the intro
    alone, the plucked string in the strings section `strings_db` under the violins' level, the
    cellos on `cello` (CELLOS), and the climax `climax`: "as_is" with nothing made up for the choir,
    "held" its voices set to keep its level against the rest (CLIMAX_HOLD), "flat" held and every
    voice's swells levelled too. Voices keep their places in the list, so each keeps its humanising."""
    kw = map_four(call, "pluck", True)
    voices = []
    for v in kw["voices"]:
        v = dict(v)
        if v["inst"] == "pluck" and "E" in v["pat"]:
            v["gain"] = round(v["gain"] * 10.0 ** ((strings_db - LEAD_DB["E"]) / 20.0), 4)
        elif v["inst"] == "cello" and CELLOS[cello]:
            v.update(inst=CELLOS[cello]["inst"], gain=round(v["gain"] * CELLOS[cello]["level"], 4))
        if climax == "flat" and "G" in v["pat"] and v.get("shape"):
            v["shape"] = flat(v["shape"])
        voices.append(v)
    pads = []
    for pad in kw["pad"]:
        if pad["inst"] == "choir":
            pad = dict(pad, sections="".join(c for c in pad["sections"] if c in CHOIR_IN))
        if pad["sections"]:
            pads.append(pad)
    crescendo = dict(kw["crescendo"])
    if climax in ("held", "flat"):
        lo, hi = crescendo["G"]
        crescendo["G"] = (lo * CLIMAX_HOLD, hi * CLIMAX_HOLD)
    return dict(kw, voices=voices, pad=pads, crescendo=crescendo)


def render_five(job):
    """A fifth-round map half, unmastered, from the first round's seed; ("four",) is the fourth round's pair."""
    F.seed(NAME + "_map")
    call = P.recipe_call(F.music_far_bank)
    kw = dict(call)
    kw.update(map_four(call) if job == ("four",) else map_five(call, *job))
    return job, unmastered(kw)


# Each set: (id, title, note, the bars cut by index from 0, or None for the whole half, and its rows:
# (the render, title, note)).
PAIR_JOB = (CELLO, STRINGS_DB, "held")
SETS = [
    ("fc", "The cellos, through the whole map half", "The map half from the top on each voice for the cellos (the groove's line from the intro's second half, the quiet six-eight, the interlude and the closer). Switch rows anywhere: each carries on from the same beat.", None,
     [(("bowed", STRINGS_DB, "held"), "The cellos bowed", "As they were."),
      (PAIR_JOB, "The plucked string", "The lead's own voice in the cellos' register (the full pair's)."),
      (("harp", STRINGS_DB, "held"), "The harp", "The harp low, its arpeggios' voice."),
      (("sub", STRINGS_DB, "held"), "The soft sub with a pluck", "The soft sub on the roots, a finger's pluck on its front.")]),
    ("fe", "The map's strings section", "The tune on the plucked string over the harp's arpeggios, the break-ins on the bells, the choir out.", (24, 40),
     [(("pluck", -3.0, "held"), "3 dB under the violins", "As the fourth round had it."),
      (PAIR_JOB, "6 dB under", "3 dB more (the full pair's).")]),
    ("fg", "The map's climax", "All thirty-two bars: the full bells, the harp's arpeggios, the tune on the plucked string at the violins' level, the soft sub.", (53, 85),
     [(("four",), "As the fourth round's pair had it", "The choir under it, every voice swelling in turn from the repeat edge."),
      (PAIR_JOB, "The choir out, its level held", "The climax where it sat against the rest of the half, halfway between a phone and headphones; its swells kept (the full pair's)."),
      (("pluck", STRINGS_DB, "flat"), "Every voice at one level", "The swells levelled too: the plucked string and the harp each at the level its swells averaged.")]),
]


def main():
    os.makedirs(P.OUT, exist_ok=True)
    jobs = list(dict.fromkeys([PAIR_JOB] + [job for _s, _t, _n, _c, rows in SETS for job, _rt, _rn in rows]))
    with ProcessPoolExecutor(max_workers=4) as pool:
        raw = dict(pool.map(render_five, jobs))
    # One master and one gain for every render, the gain the one that brings the full pair's to the
    # map's level, so the rows differ only by what changed.
    mastered = dict(zip(jobs, master_together([raw[job] for job in jobs])))
    gain = 10.0 ** ((MAP_LEVEL - F.mean_level(mastered[PAIR_JOB])) / 20.0)
    halves = {job: F.limit(x * gain) for job, x in mastered.items()}
    m = halves[PAIR_JOB]
    P.write(PAIR["id"] + "_map", m, aac=False)
    _r1, b = P.halves("far_bank")   # the shipped track
    if len(m) != len(b):
        raise ValueError("the halves are %d and %d samples" % (len(m), len(b)))
    P.write(PAIR["id"] + "_pair", [m, b], kbps=384)
    at = P.bar_times(NAME)
    edges = list(at) + [len(m) / F.SR]
    sets = []
    for sid, title, note, cut, rows_in in SETS:
        rows = []
        for k, (job, rtitle, rnote) in enumerate(rows_in):
            rid = "%s%d" % (sid, k)
            x = halves[job]
            if cut:
                x = x[int(round(edges[cut[0]] * F.SR)):int(round(edges[cut[1]] * F.SR))]
            rows.append({"id": rid, "title": rtitle, "note": rnote, "file": os.path.basename(P.write("far5_" + rid, x)),
                         "seconds": round(len(x) / F.SR, 2), "phone_db": P.measure(rid, x)["phone_db"]})
        sets.append({"id": sid, "half": "map", "title": title, "note": note, "rows": rows})
        print("%-2s %s" % (sid, "  ".join("%s %.1f" % (r["id"], r["phone_db"]) for r in rows)))
    runs, total = F.sections(NAME)
    levels = [P.measure("map", m), P.measure("battle", b)]
    manifest = {"sets": sets, "seams": [], "tracks": [{
        "id": PAIR["id"], "title": PAIR["title"], "new": "map", "bpm": F.MUSIC[NAME]["bpm"], "length": round(total, 3),
        "loop_from_bar": 1 + int(P.LOOP_FROM.get(NAME, 0)), "bar_at": [round(float(t), 4) for t in at],
        "sections": [{"section": s, "bars": [b0, b1], "at": round(t0, 2), "what": what} for s, b0, b1, t0, what in runs],
        "levels": levels}]}
    path = os.path.join(P.OUT, "far5.json")
    with open(path, "w") as f:
        json.dump(manifest, f, indent=1)
    print("%s  map %.1f (phone %.1f)  battle %.1f (phone %.1f)" % (PAIR["id"], levels[0]["mean_db"], levels[0]["phone_db"], levels[1]["mean_db"], levels[1]["phone_db"]))
    print(os.path.relpath(path))
    return 0


if __name__ == "__main__":
    sys.exit(main())
