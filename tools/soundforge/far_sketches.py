"""The Far Bank's map half, its eighth round (Ryan, 6 November, on the seventh): his pick of the lift,
and the plucked string in tune.

  "Far bank lift: the half as far, choir level from the full pair is good."; "fix other uses of the
  plucked string too so I can make sure."

The seventh round's pair, rendered again with forge.py's pluck tuned (the tune on the plucked string in
the strings section and the climax had played every note flat, its high notes by up to a third of a
semitone). The battle half is the shipped track as it stands in art/audio.

The seventh round's, kept: the cellos' and the contrabass's lines on the fretless electric (BASS7), met
halfway with the bowed pair's level between a phone and full; the climax's swells half as far over their
floor (SWELL; 5 November: "fretless bass wins, as does the 'half as far' option for the climax"). No
voice swells in the lift (C): the choir's pad, the one choir from the intro to the lift, doubles there
in the recipe, but the lift rises mostly because its contrabass line on the fretless comes in 11 dB over
the groove's bass on a phone ("In C, let's not swell the volume so far, especially for the choir"): the
lift comes in half as far, the fretless and the bells 3 dB down there and the choir held level
(CHOIR_LIFT, LIFT_DB), his pick.

The sixth round's, kept: the cellos and the contrabass on a true bass instrument, not the battle's
saw strings dropped ("make the map half not just sound like the battle half with the percussion taken
out"); the choir back wherever the fourth round had it; the plucked string 6 dB under the violins in
the strings section, his call.

The fifth round's, kept: the tune on the plucked string one note at a time in the strings section
and the climax; its cello options and its climax hold went with the choir's return.

The fourth round's, kept (map_four): each lead on single notes, a note that rang on under the next
stopping where the next begins, the tritone at the strings section's end on a soft bell; the shipped
track as the battle half; the map half the first round's (pair_sketches.map_far_bank) with the bells
at half speed and one echo in the groove and the lift alone, the climax's full; the strings section
and the climax without the battle's orchestra, the horns' break-ins in the strings section on the
bells, no horns' melody in the climax, a soft sub on the roots for the cellos and the contrabass.

    tools/spriter/.venv/bin/python tools/soundforge/far_sketches.py      # the pair (and a set, when there is one), then far8.json beside the pairs
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
PAIR = {"id": "far_bank_r8", "title": "The Far Bank, round eight"}
FOURTH = os.path.join(P.OUT, "far_bank_r4_map.wav")   # the fourth round's pair's map half, as it was heard
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


# The sixth round (Ryan, 4 November, on the fifth): "Map cellos replacement needs to be a true
# bass-level instrument, not a dropped lead voice. Soft sub is ok, are there others? Also, didn't
# realize that the contrabass is in the same boat. Basically, my goal here is to make the map half not
# just sound like the battle half with the percussion taken out. I think the choirs need to go back,
# that was a mistake. Map climax - keep the swells, but reduce the max on it, so it doesn't swell as
# far. Map strings - 6db under good". The forge's cello and contrabass are its violins' saws with
# vibrato, the battle's string section dropped; their lines go to a true bass instrument, each met
# halfway with the bowed pair's level between a phone and full (BASSES).
BASSES = {
    "bowed": None,                                                                                   # the bowed pair as it was, the reference
    "sub": {"inst": "sub_pluck", "params": {}, "level": 0.745},                                       # the soft sub with a finger's pluck: 3.8 dB under the bowed pair on a phone, over in full
    "upright": {"inst": "real_bass", "params": {"preset": "upright", "amp": "di"}, "level": 3.85},     # an upright bass, plucked, its body (real_bass.py): 3.4 each way
    "fretless": {"inst": "real_bass", "params": {"preset": "fretless", "amp": "di"}, "level": 2.13},   # a fretless electric, its notes blooming into pitch: 0.4 each way
    "flat": {"inst": "real_bass", "params": {"preset": "flat", "amp": "di"}, "level": 2.74},           # flatwounds and a soft thumb, the tone rolled back: 1.1 each way
    "synth": {"inst": "bass", "params": {"drive": 2.5, "cutoff": 600.0}, "level": 0.55},               # the synth bass, the crunch synth dark and soft: 0.3 each way
}
# His picks of the sixth round (Ryan, 5 November: "Far bank map - fretless bass wins, as does the 'half as
# far' option for the climax").
BASS7 = "fretless"
SWELL = 0.5     # the climax's swells rising half as far over their floor ("reduce the max on it, so it doesn't swell as far")
# The lift (5 November: "In C, let's not swell the volume so far, especially for the choir"). No voice
# swells in C by a shape; the lift rises because its parts come in louder: on its own, from the groove
# into the lift the contrabass's line on the fretless rises 11 dB on a phone (8 in full), the choir's
# pad, which the recipe doubles there ("one choir, louder in the lift"), 7, and the bells 4, so the lift
# stood 5.9 dB over the groove on a phone and the choir alone held level took only 1.2 dB off it. The
# full pair's lift comes in half as far, the choir most: the fretless and the bells 3 dB down there and
# the choir held level, about 2 dB over the groove; a set has it as it was, the choir held level alone,
# and half as far with the choir rising 3 dB.
CHOIR_LIFT = 1.0   # the choir's pad in the lift against its level (the recipe's 2.0)
LIFT_DB = -3.0     # the fretless and the bells in the lift
FLOOR = 0.7     # the swells' floor (forge's swells())


def shallower(shape, k):
    """A voice's swells rising `k` as far over their floor, the floor and the closer's cut kept."""
    return [(pos, FLOOR + (lvl - FLOOR) * k if lvl > FLOOR else lvl) for pos, lvl in shape]


def map_six(call, bass=BASS7, swell=SWELL):
    """The fourth round's map half, the choir back everywhere, with the plucked string on single
    notes 6 dB under the violins in the strings section and at them in the climax, the cellos' and
    the contrabass's lines on `bass` (BASSES), and the climax's swells rising `swell` as far."""
    kw = map_four(call, "pluck", True)
    b = BASSES[bass]
    voices = []
    for v in kw["voices"]:
        v = dict(v)
        if v["inst"] == "pluck" and "E" in v["pat"]:
            v["gain"] = round(v["gain"] * 10.0 ** ((STRINGS_DB - LEAD_DB["E"]) / 20.0), 4)
        elif v["inst"] in ("cello", "contrabass") and b:
            v.update(inst=b["inst"], params=dict(b["params"]), gain=round(v["gain"] * b["level"], 4))
        if swell != 1.0 and "G" in v["pat"] and v.get("shape"):
            v["shape"] = shallower(v["shape"], swell)
        voices.append(v)
    return dict(kw, voices=voices)


def map_seven(call, bass=BASS7, swell=SWELL, choir_lift=CHOIR_LIFT, lift_db=LIFT_DB):
    """The sixth round's map half on `bass` with the climax's swells `swell` as far; in the lift (C)
    the choir's pad `choir_lift` times its level rather than the recipe's twice, and the bass and the
    bells `lift_db` dB from where they were. A lift part moves onto a voice of its own in every row,
    whatever its level, so every row's voices keep their places and their humanising."""
    kw = map_six(call, bass, swell)
    voices, moved = [], []
    for v in kw["voices"]:
        v = dict(v)
        if v["inst"] in ("real_bass", "bell") and "C" in v["pat"] and any(c not in ".-" for c in v["pat"]["C"]):
            v["pat"] = dict(v["pat"])
            moved.append(dict(v, gain=round(v["gain"] * 10.0 ** (lift_db / 20.0), 4), pat={"C": v["pat"].pop("C")}))
        voices.append(v)
    pads = []
    for p in kw.get("pad") or []:
        p = dict(p)
        if p["inst"] == "choir" and "C" in p.get("sections", ""):
            p["gains"] = dict(p.get("gains", {}), C=choir_lift)
        pads.append(p)
    return dict(kw, voices=voices + moved, pad=pads)


def render_seven(job):
    """A seventh-round map half, unmastered, from the first round's seed."""
    F.seed(NAME + "_map")
    call = P.recipe_call(F.music_far_bank)
    kw = dict(call)
    kw.update(map_seven(call, *job))
    return job, unmastered(kw)


def render_five(job):
    """A fifth-round map half, unmastered, from the first round's seed; ("four",) is the fourth round's pair."""
    F.seed(NAME + "_map")
    call = P.recipe_call(F.music_far_bank)
    kw = dict(call)
    kw.update(map_four(call) if job == ("four",) else map_five(call, *job))
    return job, unmastered(kw)


# Each set: (id, title, note, the bars cut by index from 0, or None for the whole half, and its rows:
# (the render, title, note)).
PAIR_JOB = (BASS7, SWELL, CHOIR_LIFT, LIFT_DB)
SETS = []   # the lift settled on the seventh round's pair (Ryan, 6 November: "the half as far, choir level from the full pair is good")


def main():
    os.makedirs(P.OUT, exist_ok=True)
    jobs = list(dict.fromkeys([PAIR_JOB] + [job for _s, _t, _n, _c, rows in SETS for job, _rt, _rn in rows]))
    with ProcessPoolExecutor(max_workers=4) as pool:
        raw = dict(pool.map(render_seven, jobs))
    # One master and one gain for every render, the gain the one that brings the full pair's to the
    # map's level, so the rows differ only by what changed.
    mastered = dict(zip(jobs, master_together([raw[job] for job in jobs])))
    gain = 10.0 ** ((MAP_LEVEL - F.mean_level(mastered[PAIR_JOB])) / 20.0)
    halves = {job: F.limit(x * gain) for job, x in mastered.items()}
    # The fourth round's pair as he heard it, its own map half, or failing that its render levelled
    # on its own: this round's gain, raised as the choir left, would play it about 1 dB louder than
    # it was, and the climax set's question is whether the climax kept its level.
    if ("four",) in halves and os.path.exists(FOURTH):
        halves[("four",)] = P.read_wav(FOURTH)
    elif ("four",) in halves:
        x = mastered[("four",)]
        halves[("four",)] = F.limit(x * 10.0 ** ((MAP_LEVEL - F.mean_level(x)) / 20.0))
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
            rows.append({"id": rid, "title": rtitle, "note": rnote, "file": os.path.basename(P.write("far8_" + rid, x)),
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
    path = os.path.join(P.OUT, "far8.json")
    with open(path, "w") as f:
        json.dump(manifest, f, indent=1)
    print("%s  map %.1f (phone %.1f)  battle %.1f (phone %.1f)" % (PAIR["id"], levels[0]["mean_db"], levels[0]["phone_db"], levels[1]["mean_db"], levels[1]["phone_db"]))
    print(os.path.relpath(path))
    return 0


if __name__ == "__main__":
    sys.exit(main())
