"""The console's fifth cut, built from Ryan's audition picks (3 October). The picks: A (teletype)
no; B (weight) good but never alone; C (words) order and commit alright, with a version in his
head where the voice speaks unintelligible words in small doses, and a male register, our
Terran Adjutant; D the breakers only; E (the Nostromo pings) alright but pitched down; F the
commit's noise as a comms static, nothing else. Missing: the robotic beeps of the Terran nuke
warning. And of the earlier cuts the structures were right and the tones and pitches wrong:
the FM scramble, the FM die locked, the FM medium confirm and die spent, the war room's round
open, the FM refused. "We needed to boop when we were beeping."

So the materials are:

  the boop     the voice. A hollow square-ish tone (odd harmonics, two oscillators a hair
               apart, low-passed around 1.8 kHz), a slow front of twenty milliseconds, in the
               nuke warning's register: E4, G4, A4, B4 (330 to 494 Hz), an octave under it for
               headphones. A boop, not a beep: lower, duller, longer. Nothing above it.
  the weight   B's pulse under every order and commit, never alone.
  the hum      D's hum (100 Hz and its harmonics) coming up under the commit and the round
               opening; D's breaker as the heavy key, a light breaker as the ordinary key.
  the static   F's gated comms noise, low in the mix, as a bed under the voice and the commit.
  the ping     E's sine ping pitched down an octave and more, for the quiet moments: a hold
               readout, a selection, a dismissal.
  the voice    the formant voice in the male register through the hard radio, speaking words
               that are not words (phonemes drawn to sound like speech), in small doses: the
               commit, and a chatter row on its own to judge the dose.

The structures kept from the earlier cuts, rebuilt: the scramble as quantised boops stepping at
the board's frame rate and landing; the lock as two boops and a pulse; the spend as the pulse
under a boop dyad closing; refuse as F falling to E on dull boops with a dropout; the round
opening as the static and the hum coming up under the warning's alternating two-tone, three
times, and the weight. Piercing measured as before and held ten decibels under the body.

    python3 tools/soundforge/boop_sketches.py          # into out/fx, after fx_sketches.py
"""
import json
import math
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import fx_sketches as X  # noqa: E402
import console_sketches as C  # noqa: E402  (the beds and the sequences' event lists)
import audition_sketches as A  # noqa: E402  (the picked materials: pulse, breaker, burst, ping, radio, squelch)
import speech  # noqa: E402
from phone_sketches import phone_model  # noqa: E402

SR = F.SR
n_of, t_of, mix, at = F.n_of, F.t_of, F.mix, F.at
E2 = 82.41


def hz(semis, octave):
    return E2 * 2.0 ** (semis / 12.0) * 2.0 ** octave


E4, F4, G4, A4, B4, E5, B3 = hz(0, 2), hz(1, 2), hz(3, 2), hz(5, 2), hz(7, 2), hz(0, 3), hz(7, 1)
BOARD = 18.0


def env(n, pts):
    return F.env_pts(n, pts)


# ---------------------------------------------------------------- the boop

def boop(f, dur=0.18, gain=1.0, attack=0.02, release=0.05, bright=1800.0, under=0.5, close=None):
    """A hollow square-ish tone: odd harmonics falling as 1/k, two oscillators a hair apart so
    it beats slowly, an octave under for headphones, low-passed at `bright` (or closing from
    `close[0]` to `close[1]`), a slow front. The nuke warning's register."""
    n = n_of(dur)
    t = t_of(n)
    x = np.zeros(n)
    for d in (0.997, 1.003):
        for k in (1, 3, 5, 7):
            x += np.sin(2.0 * math.pi * f * d * k * t) / k
    x /= 2.0
    x += np.sin(2.0 * math.pi * f * 0.5 * t) * under
    e = env(n, [(0.0, 0.0), (attack, 1.0), (max(attack, dur - release), 0.9), (dur, 0.0)])
    x = x * e
    if close:
        x = F.lp_var(x, np.geomspace(close[0], close[1], n), passes=1)
    else:
        x = F.lp(x, bright)
    return F.sat(x, 1.3) * gain


def warning(f_hi=B4, f_lo=E4, each=0.22, times=3, gain=1.0):
    """The nuke warning: two boops alternating, high then low, `times` over."""
    buf = np.zeros(1)
    for k in range(times):
        buf = at(buf, boop(f_hi, each * 0.9, 1.0, bright=1600.0), k * each * 2.0)
        buf = at(buf, boop(f_lo, each * 0.9, 0.95, bright=1500.0), k * each * 2.0 + each)
    return buf * gain


def hum(dur=1.2, gain=1.0, rise=0.6):
    n = n_of(dur)
    t = t_of(n)
    x = np.sin(2.0 * math.pi * 100.0 * t) + 0.5 * np.sin(2.0 * math.pi * 300.0 * t) + 0.25 * np.sin(2.0 * math.pi * 500.0 * t)
    x = F.lp(F.sat(x, 1.5), 900.0)
    return x * env(n, [(0.0, 0.0), (rise, 0.7), (dur * 0.85, 0.7), (dur, 0.0)]) * gain


def static(dur, gain=0.3, rate=30.0):
    """F's gated comms noise, low, as a bed."""
    return A.burst(dur, rate, gain, 500.0, 2600.0)


def ping(f=hz(0, 1), dur=0.8, gain=1.0):
    """E's ping pitched down: E3 with its harmonics so the speaker hears it."""
    n = n_of(dur)
    t = t_of(n)
    x = np.sin(2.0 * math.pi * f * t) + 0.5 * np.sin(2.0 * math.pi * f * 2.0 * t) + 0.2 * np.sin(2.0 * math.pi * f * 3.0 * t)
    return F.room(x * F.env_ad(n, 0.008, dur * 0.3), decay=0.14, mix=0.1, cut=2500.0) * gain


def babble(n_words=1, voice="vega", gain=1.0, seedword="x"):
    """Words that are not words: a few phonemes drawn to fall like speech (a consonant, a
    stressed vowel, a consonant or two), in the male register through the hard radio."""
    cons = ["K", "T", "D", "G", "P", "B", "M", "N", "V", "S", "SH", "R", "L"]
    vows = ["AA", "AH", "EH", "IH", "AO", "UH", "ER", "IY"]
    buf = np.zeros(1)
    pos = 0.0
    for w in range(n_words):
        shape_ = int(F.RNG.integers(0, 3))
        if shape_ == 0:
            ph = [cons[int(F.RNG.integers(0, len(cons)))], vows[int(F.RNG.integers(0, len(vows)))] + "'", cons[int(F.RNG.integers(0, len(cons)))]]
        elif shape_ == 1:
            ph = [cons[int(F.RNG.integers(0, len(cons)))], vows[int(F.RNG.integers(0, len(vows)))] + "'", cons[int(F.RNG.integers(0, len(cons)))], vows[int(F.RNG.integers(0, len(vows)))]]
        else:
            ph = [vows[int(F.RNG.integers(0, len(vows)))] + "'", cons[int(F.RNG.integers(0, len(cons)))], vows[int(F.RNG.integers(0, len(vows)))], cons[int(F.RNG.integers(0, len(cons)))]]
        name = "babble_%s_%d_%d" % (seedword, w, shape_)
        speech.WORDS[name] = ph
        x = speech.say(name, voice)
        buf = at(buf, A.radio(x), pos)
        pos += len(x) / SR + 0.07
    return buf * gain


# ---------------------------------------------------------------- the events

def key(weight=1.0):
    """The key: a light breaker. Heavy: the breaker thrown."""
    return A.breaker(weight, 0.55 if weight <= 1.0 else 0.9)


def scramble(dur=0.45, land=B4, rate=BOARD, gain=1.0):
    """The FM scramble's structure in boops: quantised notes stepping at the board's frame
    rate from the E set, the pool narrowing, landing on `land`, each a short dull boop."""
    pool = (E4, G4, A4, B4, E5)
    buf = np.zeros(n_of(dur) + n_of(0.25))
    step = 1.0 / rate
    t = 0.0
    k = 0
    total = max(1, int(dur / step))
    while t < dur - step * 0.5:
        p = k / max(total - 1, 1)
        choices = pool if p < 0.5 else pool[:3] if land == E4 else pool[2:]
        f = choices[int(F.RNG.integers(0, len(choices)))]
        buf = at(buf, boop(f, step * 0.85, 0.45 + 0.4 * p, attack=0.006, release=0.02, bright=1500.0, under=0.3), t)
        t += step
        k += 1
    buf = at(buf, boop(land, 0.2, 1.0, bright=1700.0), dur)
    return buf * gain


def lock():
    """Two boops and the pulse: the corners snapping on."""
    buf = at(np.zeros(1), boop(E4, 0.09, 0.9, attack=0.008, release=0.03), 0.0)
    buf = at(buf, boop(B4, 0.16, 1.0, attack=0.01, close=(2200.0, 900.0)), 0.1)
    return at(buf, A.pulse(92.0, 0.1, 0.7), 0.1)


def spend():
    """The pulse under a boop dyad closing: a die spent."""
    n = n_of(0.3)
    dy = mix(boop(E4, 0.3, 0.7, attack=0.015, close=(2400.0, 700.0)), boop(B4, 0.3, 0.6, attack=0.015, close=(2400.0, 700.0)))
    return at(A.pulse(92.0, 0.16, 1.0), dy, 0.0)


def spend_self():
    buf = spend()
    return at(buf, boop(E5, 0.14, 0.5, attack=0.02, close=(2000.0, 800.0)), 0.34)


def refuse():
    """F falling to E on dull boops, a dropout cutting the second."""
    a = boop(F4, 0.14, 1.0, attack=0.01, bright=1100.0)
    b = boop(E4, 0.22, 0.9, attack=0.01, bright=1000.0)
    b[n_of(0.08):n_of(0.11)] = 0.0
    buf = at(a, b, 0.13)
    return at(buf, A.pulse(69.0, 0.14, 0.6), 0.13)


def acquire(f=E4, dur=0.3, gain=1.0):
    """A boop coming up out of the static: the bed, then the note clean."""
    buf = at(np.zeros(1), static(dur * 0.6, 0.35, 40.0), 0.0)
    return at(buf, boop(f, dur * 0.7, 1.0, attack=0.03, close=(900.0, 2000.0)), dur * 0.3) * gain


def report():
    """The round opening: the static and the hum come up, the warning's two-tone three times
    over them, the weight under it, the static cutting at the end."""
    buf = at(np.zeros(1), static(1.5, 0.3, 24.0), 0.0)
    buf = at(buf, hum(1.6, 0.7, 0.5), 0.0)
    buf = at(buf, warning(B4, E4, 0.2, 3, 0.9), 0.25)
    buf = at(buf, A.pulse(69.0, 0.3, 0.9), 0.25)
    return at(buf, A.pulse(92.0, 0.2, 0.7), 1.3)


def commit(voice=True):
    """The commit: three breakers thrown with the hum coming up (D), a rising boop figure E, G,
    B over the hum, the weight swelling, the static bed, and one word that is not a word on
    the radio after. Weapons free."""
    buf = at(np.zeros(1), static(1.6, 0.25, 20.0), 0.0)
    for k in range(3):
        buf = at(buf, A.breaker(1.0 + 0.1 * k, 0.9 + 0.15 * k), k * 0.26)
    buf = at(buf, hum(1.7, 0.8, 0.7), 0.2)
    for k, f in enumerate((E4, G4, B4)):
        buf = at(buf, boop(f, 0.22 if k < 2 else 0.5, 0.9, attack=0.02, close=(2200.0, 900.0) if k == 2 else None), 0.85 + k * 0.2)
    buf = at(buf, A.pulse(55.0, 0.5, 1.0), 1.2)
    if voice:
        buf = at(buf, A.sq(0.6), 1.85)
        buf = at(buf, babble(1, "vega", 0.8, "commit"), 1.9)
    return buf


def chatter(words=3):
    """The voice on its own, to judge the dose: a few words that are not words, the squelch
    either side, static under."""
    buf = at(np.zeros(1), static(1.6, 0.2, 26.0), 0.0)
    buf = at(buf, A.sq(0.8), 0.05)
    buf = at(buf, babble(words, "vega", 0.9, "chatter"), 0.1)
    return at(buf, A.sq(0.6, 0.022), len(buf) / SR - 0.02)


SET = {
    "boop": ((lambda: boop(E4, 0.2)), -17.0, None, "the boop alone, E4: the voice of the set"),
    "warning": ((lambda: warning(B4, E4, 0.22, 3)), -14.0, None, "the nuke warning's two-tone, three times"),
    "key": ((lambda: key(1.0)), -23.0, "ui_tap", "a light breaker"),
    "key_heavy": ((lambda: key(1.6)), -20.0, "ui_tap", "the breaker thrown"),
    "select": ((lambda: at(key(1.0), ping(hz(0, 1), 0.6, 0.8), 0.02)), -18.0, "ui_tap", "the key and a low ping"),
    "dismiss": ((lambda: ping(hz(7, 0), 0.5, 0.8)), -21.0, "ui_back", "a lower ping"),
    "die_lift": ((lambda: at(key(0.9), boop(E4, 0.12, 0.8, attack=0.012), 0.02)), -17.0, "die_pick", ""),
    "die_drop_back": ((lambda: boop(B3, 0.12, 0.8, attack=0.01, bright=1100.0)), -21.0, "die_drop", "a dull low boop"),
    "die_lock": (lock, -16.0, "die_lock", "two boops and the pulse"),
    "die_unlock": ((lambda: boop(B3, 0.1, 0.7, attack=0.01, bright=1000.0)), -20.0, "die_lock", ""),
    "die_spend": (spend, -14.0, "die_drop", "the pulse under a boop dyad closing"),
    "die_spend_self": (spend_self, -14.0, "die_drop", ""),
    "reroll": ((lambda: at(key(1.1), scramble(0.24, E4, 30.0, 0.9), 0.02)), -16.0, "die_roll", "the scramble in boops"),
    "round_acquire": (report, -12.0, None, "the field reports: static, the hum, the warning, the weight"),
    "end_turn": ((lambda: at(at(key(1.6), commit(True), 0.0), scramble(0.3, E4, BOARD, 0.4), 2.7)), -11.0, "resolve", "the commit, a word, then ENEMY PHASE as a scramble"),
    "resolve": ((lambda: at(key(1.6), commit(True), 0.0)), -11.0, "resolve", "the commit"),
    "commit_no_voice": ((lambda: commit(False)), -11.0, None, "the commit without the word"),
    "route_set": ((lambda: at(key(1.0), scramble(0.45, B4, BOARD, 0.8), 0.02)), -16.0, "plot", ""),
    "route_clear": ((lambda: ping(hz(7, 0), 0.4, 0.7)), -20.0, "ui_back", ""),
    "hold_readout": ((lambda: ping(hz(0, 1), 0.7, 0.7)), -19.0, None, "the low ping alone"),
    "codex_open": ((lambda: at(at(key(1.0), static(0.4, 0.3, 30.0), 0.02), acquire(E4, 0.3, 0.9), 0.1)), -15.0, "codex_open", ""),
    "codex_close": ((lambda: at(ping(hz(7, 0), 0.4, 0.7), static(0.15, 0.25, 40.0), 0.0)), -18.0, "codex_close", ""),
    "menu_open": ((lambda: at(at(key(1.6), hum(0.6, 0.5, 0.2), 0.0), boop(E4, 0.3, 0.8, attack=0.03, close=(1800.0, 700.0)), 0.15)), -14.0, "menu_open", ""),
    "menu_close": ((lambda: at(key(1.0), boop(B3, 0.2, 0.7, attack=0.02, bright=1200.0), 0.03)), -17.0, "menu_open", ""),
    "refuse": (refuse, -15.0, "ui_back", "F to E on dull boops, a dropout"),
    "chatter_1": ((lambda: chatter(1)), -14.0, None, "one word that is not a word"),
    "chatter_3": ((lambda: chatter(3)), -14.0, None, "three"),
}


def pierce(x):
    def band_db(lo, hi):
        y = F.bp(x, lo, hi)
        return 20.0 * math.log10(math.sqrt(float(np.mean(y ** 2))) + 1e-9)
    return band_db(2000.0, 8000.0) - band_db(300.0, 2000.0)


def render_one(name):
    F.seed("set_" + name)
    fn, db, beside, note = SET[name]
    x = A.level_for_phone(fn(), db)
    return x, db, beside, note


def main(argv):
    os.makedirs(X.OUT, exist_ok=True)
    path = os.path.join(X.OUT, "manifest.json")
    manifest = {}
    if os.path.exists(path):
        with open(path) as fh:
            manifest.update(json.load(fh))
    manifest["set"] = []
    worst = -99.0
    for name in SET:
        x, db, beside, note = render_one(name)
        X.write("set_" + name, X.tail(x, 0.35))
        pr = pierce(x)
        worst = max(worst, pr)
        manifest["set"].append({"name": "set_" + name, "beside": beside, "seconds": round(len(x) / SR, 2), "phone_db": db, "pierce_db": round(pr, 1), "note": note})
        print("  set_%-16s %5.2f s  phone %6.1f  pierce %6.1f" % (name, len(x) / SR, db, pr))
    print("  worst pierce %.1f dB" % worst)
    names = {"touch": "key", "touch_heavy": "key_heavy"}
    seqs = [
        ("con_turn", X.bed("music_hold_the_line", 8, 8, 104), C.TURN),
        ("con_climax", X.bed("music_hold_the_line", C.climax_bar(), 8, 104), C.TURN),
        ("con_map", X.bed("music_night_shift", 8, 6, 94), C.MAP),
    ]
    for key_, base, events in seqs:
        F.seed("set_seq_" + key_)
        buf = np.array(base) * 10.0 ** (C.BED_DB / 20.0)
        for when, con, now, db in events:
            if con is not None:
                x, _, _, _ = render_one(names.get(con, con))
            elif now is not None:
                x = X.level(X.shipped(now), F.LEVELS[now])
            else:
                continue
            buf = at(buf, x * 10.0 ** (db / 20.0), when)
        name = "seq_%s_set" % key_
        X.write(name, X.tail(buf, 0.5))
        manifest["set"].append({"name": name, "seconds": round(len(buf) / SR, 2)})
        print("  %-20s %5.1f s" % (name, len(buf) / SR))
    with open(path, "w") as fh:
        json.dump(manifest, fh, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
