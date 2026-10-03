"""The console audition (Ryan, 3 October: every cut so far has been a worse version of the last,
seeded from the same sounds; try a completely new sound set). The cuts shared a skeleton, my
own grammar, event list, timings and pitch frame, with a new timbre on it each time, and I
cannot hear any of them. So this is the music pass's method instead (the six bass voices
played in turn, voice 12 picked hands down): three moments only, each in six directions that
share no grammar, no source and no pitch frame, short, for Ryan to pick from before any set is
built. A pick can be one direction, or one direction's moment with another's.

  A  teletype    a 70s war room: solenoid clacks, a carriage, a line printing. Mechanical, dry.
  B  weight      nothing above a few hundred hertz: a pulse, two pulses, a swell. Almost silent.
  C  words       the voice says it through a radio, lowered and crushed: a squelch, "copy",
                 "weapons free". No tones.
  D  breakers    industrial foley: a breaker thrown, a bolt sliding and seating, a bank of
                 switches with the hum coming up.
  E  nostromo    a 1979 film computer: a few low sine pings with long decays, slow and sparse.
  F  data        pitch-less gated noise with a modem's rhythm. The static note is lifted.

The moments: a press (any button), an order (a die spent on a foe), the commit (END TURN).

    python3 tools/soundforge/audition_sketches.py          # into out/fx, after fx_sketches.py
"""
import json
import math
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import fx_sketches as X  # noqa: E402
import speech  # noqa: E402
from phone_sketches import phone_model  # noqa: E402

SR = F.SR
n_of, t_of, mix, at = F.n_of, F.t_of, F.mix, F.at


def env(n, pts):
    return F.env_pts(n, pts)


def sine(f, dur, decay, gain=1.0, attack=0.004):
    n = n_of(dur)
    return np.sin(2.0 * math.pi * f * t_of(n)) * F.env_ad(n, attack, decay) * gain


# ---------------------------------------------------------------- A. teletype

def solenoid(pitch=1.0, gain=1.0):
    """A solenoid firing: the armature hitting its stop, the coil's thump, the frame."""
    hit = F.knock([2100.0 * pitch, 3300.0 * pitch, 4700.0 * pitch], [0.004, 0.003, 0.002], [1.0, 0.6, 0.3], noise_gain=0.5) * 0.7
    coil = F.body(300.0 * pitch, 180.0 * pitch, 0.05, drive=1.6, click=0.2) * 0.9
    frame = F.knock([640.0 * pitch, 1150.0 * pitch], [0.02, 0.012], [1.0, 0.4], noise_gain=0.0) * 0.4
    return mix(hit, coil, frame) * gain


def a_press():
    return solenoid(1.0, 1.0)


def a_order():
    """A short line printing: eight characters at a teletype's ten a second, then the bell-less stop."""
    buf = np.zeros(1)
    for k in range(8):
        buf = at(buf, solenoid(F.RNG.uniform(0.92, 1.08), F.RNG.uniform(0.7, 1.0)), k * 0.1 + F.RNG.uniform(-0.004, 0.004))
    buf = at(buf, solenoid(0.7, 1.2), 0.84)
    return buf


def a_commit():
    """The carriage return, a long line printing, the paper advancing."""
    buf = at(np.zeros(1), F.hydraulic(0.25, 1800.0, 600.0, 0.5, floor=300.0), 0.0)   # the carriage sliding
    buf = at(buf, solenoid(0.6, 1.5), 0.24)                                            # the stop
    for k in range(22):
        buf = at(buf, solenoid(F.RNG.uniform(0.9, 1.1), F.RNG.uniform(0.6, 1.0)), 0.4 + k * 0.08 + F.RNG.uniform(-0.004, 0.004))
    buf = at(buf, F.ratchet(6, 0.18, 1400.0, 0.6), 2.2)                                # the paper advancing
    buf = at(buf, solenoid(0.75, 1.2), 2.42)
    return buf


# ---------------------------------------------------------------- B. weight

def pulse(f=92.0, dur=0.12, gain=1.0):
    """A soft low pulse: a sine with a slow front, its second harmonic for the speaker."""
    n = n_of(dur)
    e = env(n, [(0.0, 0.0), (dur * 0.25, 1.0), (dur, 0.0)])
    x = np.sin(2.0 * math.pi * f * t_of(n)) + 0.6 * np.sin(2.0 * math.pi * f * 3.0 * t_of(n)) + 0.3 * np.sin(2.0 * math.pi * f * 5.0 * t_of(n))
    return F.lp(x * e, 700.0) * gain


def b_press():
    return pulse(92.0, 0.1, 1.0)


def b_order():
    return at(pulse(92.0, 0.14, 1.0), pulse(69.0, 0.2, 1.1), 0.22)


def b_commit():
    n = n_of(1.1)
    e = env(n, [(0.0, 0.0), (0.5, 1.0), (0.8, 1.0), (1.1, 0.0)])
    t = t_of(n)
    x = np.sin(2.0 * math.pi * 55.0 * t) + 0.7 * np.sin(2.0 * math.pi * 165.0 * t) + 0.4 * np.sin(2.0 * math.pi * 275.0 * t) * env(n, [(0.0, 0.0), (0.7, 1.0), (1.1, 0.6)])
    return at(F.lp(x * e, 800.0), pulse(92.0, 0.16, 0.9), 0.75)


# ---------------------------------------------------------------- C. words

speech.WORDS.setdefault("copy", ["K", "AA'", "P", "IY"])
speech.WORDS.setdefault("free", ["F", "R", "IY'"])
speech.WORDS.setdefault("affirm", ["AH", "F", "ER'", "M"])


def radio(x, drop=0.0):
    """A hard military radio: band 400 to 2,800 Hz, heavy compression, held samples."""
    y = F.bp(x, 400.0, 2800.0, order=4)
    y = F.sat(y / (np.max(np.abs(y)) + 1e-9) * 2.0, 3.0)
    hold = 6
    y = np.repeat(y[::hold], hold)[:len(x)]
    return y


def sq(gain=1.0, dur=0.018):
    n = n_of(dur)
    return F.bp(F.noise(n), 500.0, 2600.0, order=3) * F.env_ad(n, 0.0005, dur * 0.4) * gain


def c_press():
    return sq(1.0)


def c_order():
    w = speech.say("copy", "vega")
    buf = at(sq(0.9), radio(w), 0.03)
    return at(buf, sq(0.7, 0.022), 0.03 + len(w) / SR + 0.02)


def c_commit():
    w = speech.say("weapons free", "vega")
    buf = at(sq(1.0), radio(w), 0.03)
    buf = at(buf, sq(0.8, 0.024), 0.03 + len(w) / SR + 0.03)
    a = speech.say("affirm", "betty")
    buf = at(buf, radio(a) * 0.8, 0.03 + len(w) / SR + 0.32)
    return at(buf, sq(0.6, 0.02), 0.03 + len(w) / SR + 0.32 + len(a) / SR + 0.02)


# ---------------------------------------------------------------- D. breakers

def breaker(gain=1.0, size=1.0):
    """A breaker thrown: the handle's travel, the contacts slamming home, the cabinet."""
    travel = F.hydraulic(0.06 * size, 900.0, 2400.0, 0.4, floor=250.0)
    slam = mix(F.knock([380.0 / size, 720.0 / size, 1900.0], [0.03 * size, 0.018, 0.005], [1.0, 0.5, 0.4], noise_gain=0.6),
               F.thud(140.0, 60.0, 0.22 * size, click=0.5, drive=2.0, body_gain=1.0) * 0.8)
    cabinet = F.knock([210.0 / size, 330.0 / size], [0.06, 0.04], [1.0, 0.6], noise_gain=0.0) * 0.5
    return at(at(travel, slam, 0.05 * size), cabinet, 0.052 * size) * gain


def d_press():
    return breaker(1.0, 0.8)


def d_order():
    """A bolt sliding and seating."""
    slide = F.hydraulic(0.22, 600.0, 1800.0, 0.5, floor=200.0)
    grit = F.bp(F.noise(n_of(0.22)), 1200.0, 4000.0) * env(n_of(0.22), [(0.0, 0.0), (0.03, 0.4), (0.18, 0.5), (0.22, 0.0)]) * 0.4
    seat = mix(F.knock([520.0, 940.0, 2600.0], [0.025, 0.012, 0.004], [1.0, 0.5, 0.3], noise_gain=0.5), F.thud(160.0, 70.0, 0.18, click=0.3, drive=2.0) * 0.6)
    return at(mix(slide, grit), seat, 0.21)


def d_commit():
    """A bank of breakers thrown in turn, and the hum coming up under them."""
    buf = np.zeros(1)
    for k in range(3):
        buf = at(buf, breaker(1.0 + 0.15 * k, 1.0 + 0.2 * k), k * 0.3)
    n = n_of(1.4)
    hum = (np.sin(2.0 * math.pi * 100.0 * t_of(n)) + 0.5 * np.sin(2.0 * math.pi * 300.0 * t_of(n)) + 0.25 * np.sin(2.0 * math.pi * 500.0 * t_of(n)))
    hum = F.lp(F.sat(hum, 1.5), 900.0) * env(n, [(0.0, 0.0), (0.9, 0.7), (1.2, 0.7), (1.4, 0.0)])
    return at(buf, hum, 0.25)


# ---------------------------------------------------------------- E. nostromo

def ping(f, dur=0.6, gain=1.0):
    n = n_of(dur)
    x = np.sin(2.0 * math.pi * f * t_of(n)) + 0.08 * np.sin(2.0 * math.pi * f * 2.0 * t_of(n))
    return F.room(x * F.env_ad(n, 0.006, dur * 0.3), decay=0.12, mix=0.1, cut=3000.0) * gain


def e_press():
    return ping(440.0, 0.35, 1.0)


def e_order():
    return at(ping(440.0, 0.5, 1.0), ping(330.0, 0.7, 0.9), 0.28)


def e_commit():
    buf = np.zeros(1)
    for k, (f, g) in enumerate(((330.0, 0.9), (440.0, 0.9), (330.0, 0.8), (220.0, 1.0))):
        buf = at(buf, ping(f, 0.8, g), k * 0.34)
    return buf


# ---------------------------------------------------------------- F. data

def burst(dur, pattern_hz, gain=1.0, lo=500.0, hi=3200.0):
    """Gated noise: a band of noise switched on and off at `pattern_hz` with a random pattern."""
    n = n_of(dur)
    x = F.bp(F.noise(n), lo, hi, order=3)
    step = n_of(1.0 / pattern_hz)
    gate = np.zeros(n)
    for i in range(0, n, step):
        if F.RNG.uniform() < 0.6:
            gate[i:i + step] = 1.0
    gate = np.convolve(gate, np.ones(n_of(0.002)) / n_of(0.002), mode="same")
    return x * gate * env(n, [(0.0, 0.0), (0.005, 1.0), (dur - 0.01, 1.0), (dur, 0.0)]) * gain


def f_press():
    return burst(0.012, 400.0, 1.0)


def f_order():
    return at(burst(0.14, 40.0, 1.0), burst(0.05, 120.0, 0.8, 800.0, 2400.0), 0.17)


def f_commit():
    buf = at(np.zeros(1), burst(0.5, 24.0, 1.0), 0.0)
    buf = at(buf, burst(0.3, 80.0, 0.9, 700.0, 2600.0), 0.55)
    return at(buf, burst(0.08, 10.0, 1.0, 400.0, 1800.0), 0.9)


# ---------------------------------------------------------------- the table

DIRECTIONS = {
    "a": ("teletype", (a_press, a_order, a_commit)),
    "b": ("weight", (b_press, b_order, b_commit)),
    "c": ("words", (c_press, c_order, c_commit)),
    "d": ("breakers", (d_press, d_order, d_commit)),
    "e": ("nostromo", (e_press, e_order, e_commit)),
    "f": ("data", (f_press, f_order, f_commit)),
}
MOMENTS = ("press", "order", "commit")
LEVELS = {"press": -22.0, "order": -15.0, "commit": -11.0}   # by what the phone plays


def level_for_phone(x, db):
    return x * 10.0 ** ((db - F.loudness(phone_model(x))) / 20.0)


def main(argv):
    os.makedirs(X.OUT, exist_ok=True)
    path = os.path.join(X.OUT, "manifest.json")
    manifest = {}
    if os.path.exists(path):
        with open(path) as fh:
            manifest.update(json.load(fh))
    manifest["audition"] = []
    for key_, (name, fns) in DIRECTIONS.items():
        for moment, fn in zip(MOMENTS, fns):
            F.seed("aud_%s_%s" % (key_, moment))
            x = level_for_phone(fn(), LEVELS[moment])
            fname = "aud_%s_%s" % (key_, moment)
            X.write(fname, X.tail(x, 0.35))
            manifest["audition"].append({"name": fname, "direction": name, "moment": moment, "seconds": round(len(x) / SR, 2)})
            print("  %-14s %5.2f s" % (fname, len(x) / SR))
    # the three moments in a row per direction, over four bars of Hold The Line's riff
    bed = X.bed("music_hold_the_line", 8, 4, 104) * 10.0 ** (-4.0 / 20.0)
    for key_, (name, fns) in DIRECTIONS.items():
        F.seed("aud_seq_" + key_)
        buf = np.array(bed)
        for when, (moment, fn) in zip((0.4, 2.2, 4.8), zip(MOMENTS, fns)):
            buf = at(buf, level_for_phone(fn(), LEVELS[moment]), when)
        buf = at(buf, level_for_phone(fns[0](), LEVELS["press"]), 1.4)
        buf = at(buf, level_for_phone(fns[1](), LEVELS["order"]), 3.4)
        fname = "aud_%s_run" % key_
        X.write(fname, X.tail(buf, 0.4))
        manifest["audition"].append({"name": fname, "direction": name, "moment": "run", "seconds": round(len(buf) / SR, 2)})
        print("  %-14s %5.2f s" % (fname, len(buf) / SR))
    with open(path, "w") as fh:
        json.dump(manifest, fh, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
