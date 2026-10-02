"""The console's fourth cut: the war room (Ryan, 2 October, on the FM terminal and its channel:
the direction holds, war room is the right call, but the execution is arcade and early-Flash,
too fast and chirpy, the high-gain sounds piercing on the speaker; the digital fracturing works
and the high chirps do not; humanity's technology is brutal, military, utilitarian; push it
grimdark, and try a fresh pass rather than iterating on the FM set).

So nothing here is a chirp and nothing is fast. The console is a military data system heard
through the war room's monitors: low, slow, vocoded and broken up. Three materials:

  the carrier   a low tone (E4 and B3 territory, the bottom of what a speaker plays) with a slow
                warble on its loudness and a formant moving over it, so it is organic rather
                than pure: a machine's hum that almost talks. Never a glide in pitch; the
                formant and the loudness are what move.
  the voice     a vocoded blurt: a buzzing source through two formants that move as a mouth
                would, no words, one to three syllables. Humanity's machines answer in grunts.
                Each maker has a vowel.
  the breakup   digital fracturing: buffer stutters (a grain repeating), dropouts (a grain
                lost), bit depth collapsing. The feed failing and recovering is the console's
                texture, and the only thing in it that is quick.

Everything passes through the monitors: a steep roll-off above 3 kHz, a floor at 180 Hz,
saturation for weight. Measured as it is built: the energy from 2 to 8 kHz is held at least
ten decibels under the body (300 Hz to 2 kHz), which is the piercing Ryan heard on the speaker,
and every file is levelled by what the phone model plays of it.

The grammar stays the war room's: the key is a dull switch; acquire is the carrier coming up out
of breakup and steadying; an order is a short blurt sent, and a beat later the machine's
grunt in its maker's vowel; the commit is a long thrum building through stutter into a
three-syllable statement; the round opening is the field reporting, breakup resolving into a
held two-tone; refuse is a flat buzz cut by a dropout; a dismiss is the carrier dropping out.

    python3 tools/soundforge/warroom_sketches.py          # into out/fx, after fx_sketches.py and console_sketches.py
"""
import json
import math
import os
import sys

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import fx_sketches as X  # noqa: E402
import console_sketches as C  # noqa: E402  (the beds, the sequences' event lists, the phone levelling)
from phone_sketches import phone_model  # noqa: E402

SR = F.SR
n_of, t_of, mix, at = F.n_of, F.t_of, F.mix, F.at
E2 = 82.41


def hz(semis, octave):
    return E2 * 2.0 ** (semis / 12.0) * 2.0 ** octave


B3, E4, G4, B4, E5, F4 = hz(7, 1), hz(0, 2), hz(3, 2), hz(7, 2), hz(0, 3), hz(1, 2)


def shape(n, pts):
    return F.env_pts(n, pts)


# ---------------------------------------------------------------- materials

def monitors(x, drive=1.8):
    """The war room's monitors: a floor at 180 Hz, a steep roll-off above 3 kHz, saturation."""
    y = F.hp(x, 180.0, order=2)
    y = F.sat(y * 1.3, drive)
    return F.lp(F.lp(y, 3200.0, order=3), 5000.0)


def formant_move(x, f1, f2, frame=0.014):
    """Two formants whose centres move along the arrays `f1`, `f2` (Hz per sample), frame by
    frame with overlapping windows: a mouth over the source."""
    n = len(x)
    fl = n_of(frame)
    hop = fl // 2
    win = np.hanning(fl)
    out = np.zeros(n + fl)
    src = np.concatenate([x, np.zeros(fl)])
    for s in range(0, n, hop):
        a = float(f1[min(s + hop, n - 1)])
        b = float(f2[min(s + hop, n - 1)])
        seg = src[s:s + fl] * win
        y = F.bp(seg, a * 0.78, a * 1.28, order=2) + F.bp(seg, b * 0.82, b * 1.22, order=2) * 0.55
        out[s:s + fl] += y
    return out[:n]


def carrier(f, dur, warble=9.0, depth=0.35, f1=(500.0, 700.0), f2=(1400.0, 1100.0), amp=None):
    """The low tone: saws an octave apart, a slow warble on the loudness, a formant moving
    from f1[0] to f1[1] and f2[0] to f2[1] over the buffer. The pitch never moves."""
    n = n_of(dur)
    t = t_of(n)
    src = F.saws(f, n, (0.996, 1.0, 1.004)) * 0.7 + F.saws(f * 0.5, n, (1.0,)) * 0.5
    w = 1.0 - depth * 0.5 * (1.0 + np.sin(2.0 * math.pi * warble * t + F.RNG.uniform(0.0, 6.0)))
    a1 = np.geomspace(f1[0], f1[1], n)
    a2 = np.geomspace(f2[0], f2[1], n)
    y = formant_move(src, a1, a2) * 2.2 + F.lp(src, 500.0) * 0.5
    if amp is None:
        amp = shape(n, [(0.0, 0.0), (dur * 0.2, 1.0), (dur * 0.8, 0.9), (dur, 0.0)])
    return y * w * amp


def blurt(f, syllables, each=0.11, gap=0.03, drive=2.5):
    """The vocoded voice: a buzz (a pulse train at `f`) through two formants that move within
    each syllable, one to three syllables, no words. `syllables` is a list of (f1 start, f1
    end, f2 start, f2 end)."""
    total = len(syllables) * (each + gap)
    n = n_of(total)
    t = t_of(n)
    ph = np.cumsum(np.full(n, f * (1.0 + 0.004 * np.sin(2.0 * math.pi * 6.0 * t)))) / SR
    pulses = np.zeros(n)
    pulses[np.where(np.diff(np.floor(ph)) > 0)[0]] = 1.0
    src = F.lp(pulses, 3000.0, order=1) * 5.0 + F.saws(f, n, (1.0,)) * 0.3
    a1 = np.full(n, 500.0)
    a2 = np.full(n, 1200.0)
    amp = np.zeros(n)
    pos = 0.0
    for (s1, e1, s2, e2) in syllables:
        a, b = n_of(pos), n_of(pos + each)
        a1[a:b] = np.geomspace(s1, e1, b - a)
        a2[a:b] = np.geomspace(s2, e2, b - a)
        amp[a:b] = shape(b - a, [(0.0, 0.0), (0.012, 1.0), (each * 0.7, 0.85), (each, 0.0)])
        pos += each + gap
    y = formant_move(src * amp, a1, a2) * 2.5
    return F.sat(y, drive)


def stutter(x, grain=0.03, repeats=(2, 5), prob=0.5):
    """Digital fracturing: a grain repeats a few times where the buffer should have moved on."""
    g = n_of(grain)
    out = np.array(x)
    i = 0
    while i + g < len(x):
        if F.RNG.uniform() < prob:
            k = int(F.RNG.integers(repeats[0], repeats[1] + 1))
            for r in range(1, k):
                j = i + r * g
                if j + g <= len(out):
                    out[j:j + g] = x[i:i + g] * (1.0 - 0.12 * r)
            i += k * g
        else:
            i += g
    return out


def dropout(x, grain=0.02, prob=0.3, fade=0.003):
    """A grain lost: the feed goes to nothing for a moment, with a short edge."""
    g = n_of(grain)
    e = n_of(fade)
    out = np.array(x)
    for i in range(0, len(x) - g, g):
        if F.RNG.uniform() < prob:
            out[i:i + g] = 0.0
            out[i - e:i] *= np.linspace(1.0, 0.0, e) if i >= e else 1.0
    return out


def crush_to(x, depth):
    """Bit depth per sample: 3 bits is the feed collapsing, 14 is clean."""
    d = np.broadcast_to(np.asarray(depth, dtype=float), (len(x),))
    steps = 2.0 ** d
    return np.round(x * steps) / steps


def breakup(x, amount=1.0, resolve=True):
    """The feed failing and recovering over the buffer: stutter and dropouts dense at the
    start and gone by the end (or the reverse), the bit depth climbing from collapsed to clean."""
    n = len(x)
    p = np.linspace(0.0, 1.0, n)
    if not resolve:
        p = p[::-1]
    depth = 3.5 + 10.5 * p ** 0.8
    y = crush_to(x, depth)
    head = int(n * 0.55)
    if head > n_of(0.06):
        seg = y[:head] if resolve else y[n - head:]
        seg = dropout(stutter(seg, 0.028, (2, 4), 0.45 * amount), 0.018, 0.22 * amount)
        if resolve:
            y[:head] = seg
        else:
            y[n - head:] = seg
    return y


def thrum(f=E4, dur=0.5, gain=1.0):
    """Weight: a low saturated tone with a slow front, its harmonics carrying it to the speaker."""
    n = n_of(dur)
    x = F.saws(f, n, (0.997, 1.0, 1.003)) * 0.6 + np.sin(2.0 * math.pi * f * 0.5 * t_of(n)) * 0.6
    x = F.lp(F.sat(x, 3.0), 1400.0)
    return x * shape(n, [(0.0, 0.0), (dur * 0.15, 1.0), (dur * 0.7, 0.7), (dur, 0.0)]) * gain


# ---------------------------------------------------------------- the verbs

def key(weight=1.0):
    """A dull switch: a low filtered pulse, twenty milliseconds, no ring, no click above."""
    n = n_of(0.03)
    x = F.lp(F.noise(n), 900.0) * F.env_ad(n, 0.0015, 0.006) * 0.8
    x = mix(x, np.sin(2.0 * math.pi * 320.0 * t_of(n)) * F.env_ad(n, 0.001, 0.008) * 0.7 * weight)
    return monitors(x, 1.5)


def acquire(dur=0.36, f=B3, gain=1.0, amount=1.0):
    """The carrier coming up out of breakup and steadying as the brackets land: stutter and
    dropouts at the front, the bit depth climbing, the formant opening, the warble settling."""
    n = n_of(dur)
    amp = shape(n, [(0.0, 0.0), (dur * 0.1, 0.9), (dur * 0.85, 1.0), (dur, 0.0)])
    x = carrier(f, dur, warble=11.0, depth=0.5, f1=(380.0, 720.0), f2=(1700.0, 1150.0), amp=amp)
    return monitors(breakup(x, amount, resolve=True)) * gain


def release(dur=0.22, f=B3, gain=1.0):
    """The carrier dropping out: steady for a moment, then breaking up to nothing."""
    n = n_of(dur)
    amp = shape(n, [(0.0, 0.8), (dur * 0.3, 0.8), (dur, 0.0)])
    x = carrier(f, dur, warble=8.0, depth=0.3, f1=(650.0, 380.0), f2=(1200.0, 1600.0), amp=amp)
    return monitors(breakup(x, 1.0, resolve=False)) * gain


MAKER_VOWEL = {   # each maker's grunt: pitch, and the syllable's formant paths (f1 start, end, f2 start, end)
    "minerva": (hz(7, 0) * 1.5, [(600.0, 450.0, 1100.0, 900.0)]),                 # a low "uh": plain, square
    "kestrel": (hz(0, 1) * 1.5, [(450.0, 300.0, 1900.0, 2200.0)]),                # higher, "ee": quick, thin
    "wainwright_sutler": (hz(7, 0) * 1.2, [(700.0, 550.0, 950.0, 800.0), (500.0, 400.0, 900.0, 700.0)]),   # two low "oh"s: slow iron
    "aphelion": (hz(0, 1) * 1.5, [(350.0, 330.0, 1400.0, 1500.0)]),               # a clean closed "oo": the deep-space programme
    "arsenal": (hz(7, 0) * 1.4, [(650.0, 700.0, 1300.0, 1000.0)]),                # a sour "ah" bending the wrong way
}


def sent(f=hz(7, 1), gain=1.0):
    """An order going out: a two-syllable blurt, low, through the monitors."""
    x = blurt(f, [(500.0, 650.0, 1300.0, 1100.0), (600.0, 450.0, 1100.0, 1300.0)], each=0.1, gap=0.025)
    return monitors(crush_to(x, 9.0)) * gain


def ack(maker="minerva", gain=1.0):
    """The machine answering, a beat after: its grunt in its maker's vowel, lower and rougher
    than the order, with a little breakup on its tail."""
    f, syl = MAKER_VOWEL[maker]
    x = blurt(f, syl, each=0.13, gap=0.03, drive=3.0)
    n = len(x)
    tail = int(n * 0.35)
    x[n - tail:] = dropout(stutter(x[n - tail:], 0.022, (2, 3), 0.4), 0.016, 0.25)
    return monitors(crush_to(x, 8.0), 2.2) * gain


def order(weight="medium", maker="minerva"):
    """Small (a lock): a one-syllable blurt, nothing answers. Medium (a die spent): the order,
    then the machine's grunt a beat later. Large (the commit): a thrum building through
    stutter into a three-syllable statement, then every machine answering in turn."""
    if weight == "small":
        x = blurt(hz(7, 1), [(550.0, 450.0, 1100.0, 900.0)], each=0.1, drive=2.0)
        return mix(monitors(F.lp(crush_to(x, 9.0), 2200.0)), thrum(B3, 0.14, 0.4)) * 0.9
    if weight == "medium":
        return at(sent(), ack(maker, 0.9), 0.36)
    th = thrum(E4, 0.7, 1.0)
    th = breakup(th, 0.8, resolve=True)
    buf = at(np.zeros(1), th, 0.0)
    statement = blurt(hz(0, 1), [(450.0, 600.0, 1000.0, 1300.0), (650.0, 500.0, 1300.0, 1000.0), (500.0, 350.0, 900.0, 700.0)], each=0.15, gap=0.03, drive=2.8)
    buf = at(buf, monitors(crush_to(statement, 9.0)), 0.5)
    buf = at(buf, thrum(hz(0, 1), 0.6, 0.6), 0.5)
    for k, m in enumerate(("minerva", "kestrel", "wainwright_sutler")):
        buf = at(buf, ack(m, 0.7), 1.25 + k * 0.22)
    return buf


def refuse():
    """A flat buzz on the wrong note, cut by a dropout and gone."""
    n = n_of(0.3)
    x = F.saws(F4, n, (0.995, 1.0, 1.005)) * shape(n, [(0.0, 0.0), (0.01, 1.0), (0.26, 0.9), (0.3, 0.0)])
    x = F.lp(F.sat(x, 3.0), 1200.0)
    x[n_of(0.14):n_of(0.17)] = 0.0
    x[n_of(0.2):n_of(0.22)] = 0.0
    x[n_of(0.17):] *= 0.7
    return monitors(crush_to(x, 6.0), 2.5)


def scramble(dur=0.45, f=B3, gain=1.0):
    """Digits flipping: the carrier at full breakup for the length of the scramble, settling
    only at the very end. No pitches stepping; the fracture is the work."""
    n = n_of(dur)
    amp = shape(n, [(0.0, 0.0), (0.02, 0.8), (dur * 0.9, 0.9), (dur, 0.0)])
    x = carrier(f, dur, warble=14.0, depth=0.6, f1=(500.0, 600.0), f2=(1300.0, 1200.0), amp=amp)
    p = np.linspace(0.0, 1.0, n)
    y = crush_to(x, 4.0 + 10.0 * np.clip((p - 0.8) / 0.2, 0.0, 1.0))
    head = int(n * 0.85)
    y[:head] = dropout(stutter(y[:head], 0.03, (2, 5), 0.6), 0.02, 0.3)
    return monitors(y) * gain


def report():
    """The round opening: the field reports. Breakup resolving into a held two-tone, B3 and
    E4, the formant opening wide, then settling to nothing. The console's one long line."""
    n = n_of(0.9)
    amp = shape(n, [(0.0, 0.0), (0.08, 0.8), (0.5, 1.0), (0.8, 0.8), (0.9, 0.0)])
    a = carrier(B3, 0.9, warble=9.0, depth=0.45, f1=(380.0, 800.0), f2=(1800.0, 1100.0), amp=amp)
    b = carrier(E4, 0.9, warble=7.0, depth=0.35, f1=(400.0, 750.0), f2=(1600.0, 1200.0), amp=amp * shape(n, [(0.0, 0.0), (0.3, 0.0), (0.45, 1.0), (0.9, 1.0)]))
    x = breakup(mix(a, b * 0.8), 1.0, resolve=True)
    return at(monitors(x), thrum(hz(0, 1), 0.5, 0.5), 0.35)


def figure(down=True, gain=0.6):
    """A panel coming or going: the carrier with its formant falling (down) or rising, brief."""
    f1 = (750.0, 350.0) if down else (350.0, 750.0)
    f2 = (1500.0, 900.0) if down else (900.0, 1500.0)
    n = n_of(0.22)
    x = carrier(B3, 0.22, warble=6.0, depth=0.2, f1=f1, f2=f2, amp=shape(n, [(0.0, 0.0), (0.03, 1.0), (0.18, 0.8), (0.22, 0.0)]))
    return monitors(crush_to(x, 8.0)) * gain


# ---------------------------------------------------------------- the events

WAR = {
    "verb_key": ((lambda: key(1.0)), -24.0, None, "the key: a dull switch"),
    "verb_acquire": ((lambda: acquire(0.36, B3, 1.0)), -16.0, None, "acquire: the carrier coming up out of breakup"),
    "verb_scramble": ((lambda: scramble(0.45, B3, 1.0)), -17.0, None, "the scramble: the carrier at full breakup"),
    "verb_order_small": ((lambda: order("small")), -17.0, None, "an order: one syllable, nothing answers"),
    "verb_order_medium": ((lambda: order("medium")), -14.0, None, "an order and the machine's grunt"),
    "verb_order_large": ((lambda: order("large")), -11.0, None, "the commit: the thrum, the statement, every machine answering"),
    "verb_refuse": (refuse, -15.0, None, "refuse: a flat buzz cut by a dropout"),
    "key": ((lambda: key(1.0)), -24.0, "ui_tap", ""),
    "key_heavy": ((lambda: key(1.6)), -21.0, "ui_tap", ""),
    "select": ((lambda: at(key(1.0), acquire(0.26, B3, 0.8, 0.8), 0.0)), -17.0, "ui_tap", ""),
    "dismiss": ((lambda: release(0.2, B3, 0.9)), -21.0, "ui_back", ""),
    "die_lift": ((lambda: at(key(0.9), acquire(0.28, E4, 0.75, 0.9), 0.0)), -17.0, "die_pick", ""),
    "die_drop_back": ((lambda: release(0.18, E4, 0.9)), -21.0, "die_drop", ""),
    "die_lock": ((lambda: at(key(1.0), order("small"), 0.02)), -16.0, "die_lock", ""),
    "die_unlock": ((lambda: release(0.14, B3, 0.7)), -20.0, "die_lock", ""),
    "die_spend": ((lambda: order("medium", "minerva")), -14.0, "die_drop", ""),
    "die_spend_self": ((lambda: at(order("medium", "minerva"), figure(False, 0.4), 0.7)), -14.0, "die_drop", ""),
    "reroll": ((lambda: at(key(1.1), scramble(0.24, E4, 0.9), 0.0)), -16.0, "die_roll", ""),
    "round_acquire": (report, -12.0, None, "the field reports"),
    "end_turn": ((lambda: at(at(key(1.6), order("large"), 0.0), scramble(0.3, E4, 0.4), 2.0)), -11.0, "resolve", ""),
    "resolve": ((lambda: at(key(1.6), order("large"), 0.0)), -11.0, "resolve", ""),
    "route_set": ((lambda: at(key(1.0), scramble(0.45, B3, 0.8), 0.0)), -16.0, "plot", ""),
    "route_clear": ((lambda: release(0.2, E4, 0.8)), -20.0, "ui_back", ""),
    "hold_readout": ((lambda: acquire(0.26, B3, 0.6, 0.6)), -19.0, None, ""),
    "codex_open": ((lambda: at(at(key(1.0), figure(True, 0.5), 0.0), acquire(0.36, B3, 0.9), 0.15)), -15.0, "codex_open", ""),
    "codex_close": ((lambda: at(release(0.18, B3, 0.8), figure(False, 0.4), 0.05)), -18.0, "codex_close", ""),
    "menu_open": ((lambda: at(at(key(1.6), figure(True, 0.6), 0.02), order("small"), 0.28)), -14.0, "menu_open", ""),
    "menu_close": ((lambda: at(key(1.0), figure(False, 0.55), 0.0)), -17.0, "menu_open", ""),
    "refuse": (refuse, -15.0, "ui_back", ""),
}
for _m in MAKER_VOWEL:
    WAR["ack_" + _m] = ((lambda m=_m: ack(m, 1.0)), -16.0, None, "the %s grunt" % _m)


def pierce(x):
    """How piercing a sound is: the 2 to 8 kHz band against the body, 300 Hz to 2 kHz, in dB."""
    def band_db(lo, hi):
        y = F.bp(x, lo, hi)
        return 20.0 * math.log10(math.sqrt(float(np.mean(y ** 2))) + 1e-9)
    return band_db(2000.0, 8000.0) - band_db(300.0, 2000.0)


def render_one(name):
    F.seed("war_" + name)
    fn, db, beside, note = WAR[name]
    x = C.level_for_phone(fn(), db)
    return x, db, beside, note


def main(argv):
    os.makedirs(X.OUT, exist_ok=True)
    path = os.path.join(X.OUT, "manifest.json")
    manifest = {"singles": [], "sequences": [], "console": []}
    if os.path.exists(path):
        with open(path) as fh:
            manifest.update(json.load(fh))
    manifest["warroom"] = []
    print("war_")
    worst = -99.0
    for name in WAR:
        x, db, beside, note = render_one(name)
        X.write("war_" + name, X.tail(x, 0.3))
        pr = pierce(x)
        worst = max(worst, pr)
        manifest["warroom"].append({"name": "war_" + name, "beside": beside, "seconds": round(len(x) / SR, 2),
                                    "phone_db": db, "full_db": round(F.loudness(x), 1), "pierce_db": round(pr, 1), "note": note})
        print("  war_%-18s %5.2f s  phone %6.1f  full %6.1f  pierce %6.1f" % (name, len(x) / SR, db, F.loudness(x), pr))
    print("  worst pierce %.1f dB (the rule: under -10)" % worst)
    print("sequences")
    C.OPS_NAMES = {"touch": "key", "touch_heavy": "key_heavy"}
    names = {"touch": "key", "touch_heavy": "key_heavy"}
    seqs = [
        ("con_turn", X.bed("music_hold_the_line", 8, 8, 104), C.TURN),
        ("con_climax", X.bed("music_hold_the_line", C.climax_bar(), 8, 104), C.TURN),
        ("con_map", X.bed("music_night_shift", 8, 6, 94), C.MAP),
    ]
    for key_, base, events in seqs:
        F.seed("war_seq_" + key_)
        buf = np.array(base) * 10.0 ** (C.BED_DB / 20.0)
        for when, con, now, db in events:
            if con is not None:
                x, _, _, _ = render_one(names.get(con, con))
            elif now is not None:
                x = X.level(X.shipped(now), F.LEVELS[now])
            else:
                continue
            buf = at(buf, x * 10.0 ** (db / 20.0), when)
        name = "seq_%s_war" % key_
        X.write(name, X.tail(buf, 0.5))
        manifest["warroom"].append({"name": name, "seconds": round(len(buf) / SR, 2), "which": "war"})
        print("  %-20s %5.1f s" % (name, len(buf) / SR))
    with open(path, "w") as fh:
        json.dump(manifest, fh, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
