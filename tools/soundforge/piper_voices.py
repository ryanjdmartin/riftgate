"""The voice, third pass: openly licensed synthesisers (Ryan, 6 October: the Mac's voices are
recognisable and Apple-licensed, so look at the open-licence options if we are committing; on
the Mac samples the ring was no good and the shift did little, and either would need another
voice anyway). Piper (MIT) renders the lines offline from voices published under open data
licences; each voice's licence is read from its model card and printed on the page. Only the
machine chain is applied (the band, the syllable-levelling compression, the flange, the
sub-octave), since that is the one Ryan rated.

The voices tried, all female after Samantha and Karen, two of them in uncommon accents after
Karen: amy (US), ljspeech (US, public domain), alba (Scottish, CC BY 4.0), jenny_dioco (Irish),
southern_english_female (English, CC BY-SA 4.0); hfc_female was downloaded and dropped, its data
being CC BY-NC-SA, non-commercial.

Fourth pass (Ryan, 6 October, night): LJ Speech and Southern cut; Alba ok but loses to Jenny;
Amy carries the drawn-out machine cadence and is spot on for the Adjutant's register as the
chain has her, so she is the baseline; Jenny (Irish) is the one to play with, nobody expects
an Irish adjutant, she hits her consonants hard and her cadence (some words rushed, some
slow) plays well for repeated listening. So Amy through the chain as before, and Jenny four
ways: the chain as before; `light`, her natural voice through the band with a gentle
levelling and nothing else; `deep`, two combs fed back hard with grain and half a sub-octave; `slow`, the chain with the
model slowed a third. (Ryan heard only slow differ in the first try; measured, light was 95
percent the chain's signal and deep 75, so both were pushed apart: light 85 now, deep 44. A
`flat` variant with the levelling harder still measured 99 percent the chain, since the chain
already levels hard, and was dropped rather than shown.)

Seventh pass (Ryan, 7 October): Jenny mid slow is good; only her T's and D's come through
too harsh and spike on the speaker. The plosive bursts were hitting the chain's saturator,
which sharpened them, so `tamed` splits the voice at 1.8 kHz and ducks the high band wherever
its three-millisecond envelope leaps past a threshold (a de-esser aimed at plosives), before
a gentler saturator. Both are on the page for the comparison, with two more lines on the
tamed one to hear the voice across more moments.

    tools/soundforge/.venv-piper/bin/python -m piper.download_voices --data-dir tools/soundforge/out/piper <voice>...
    tools/spriter/.venv/bin/python tools/soundforge/piper_voices.py          # into out/fx
"""
import json
import os
import re
import subprocess
import sys
import wave

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import fx_sketches as X  # noqa: E402
import voice_sketches as V  # noqa: E402  (the machine chain, the lines, the levelling)

SR = F.SR
HERE = os.path.dirname(os.path.abspath(__file__))
PIPER_PY = os.path.join(HERE, ".venv-piper", "bin", "python")
SENTENCE_SILENCE = 0.35   # seconds between sentences of one line (Ryan, 7 October: she ran over the full stops)
DATA = os.path.join(F.OUT_SKETCH, "piper")
PREFIX = "voice7_"
VOICES = {
    "amy": "en_US-amy-medium",
    "jenny": "en_GB-jenny_dioco-medium",
}
LENGTH_SCALE = 1.15   # a touch slower than the model's default, as the Mac voices were


def light(x):
    """Her natural voice: the band and a gentle levelling, no flange, no sub-octave. Measured
    against the chain, the first light was 95 percent the same signal; this one is a real
    other end."""
    y = F.bp(x, 180.0, 4500.0, order=3)
    y = V.level_syllables(y, target=0.22, cap=1.6)
    return F.sat(y / (np.max(np.abs(y)) + 1e-9) * 1.05, 1.15)


def deep(x):
    """Far into the machine: two combs fed back hard (3.2 ms and 1.1 ms), half a sub-octave,
    and a sample-and-hold grain. The first deep was 75 percent the chain; this is not."""
    y = F.bp(x, 180.0, 4500.0, order=3)
    y = V.level_syllables(y, target=0.22)
    y = V.flange(y, delay=0.0032, depth=0.0012, rate=0.3, feedback=0.8, wet=0.9)
    y = V.flange(y, delay=0.0011, depth=0.0003, rate=0.7, feedback=0.6, wet=0.6)
    y = F.mix(y, V.sub_octave(y, 0.5))
    hold = 3
    y = np.repeat(y[::hold], hold)[:len(y)]
    return F.sat(y / (np.max(np.abs(y)) + 1e-9) * 1.3, 1.6)


# (voice, process name, chain, length scale)
def mid(x):
    """Between the chain and deep (Ryan: somewhere between is probably it): one comb fed back
    harder than the chain's, more sub-octave, a light grain."""
    y = F.bp(x, 180.0, 4500.0, order=3)
    y = V.level_syllables(y, target=0.22)
    y = V.flange(y, delay=0.0032, depth=0.0012, rate=0.3, feedback=0.62, wet=0.7)
    y = F.mix(y, V.sub_octave(y, 0.35))
    hold = 2
    y = np.repeat(y[::hold], hold)[:len(y)]
    return F.sat(y / (np.max(np.abs(y)) + 1e-9) * 1.2, 1.5)


def tame_plosives(y, split=1500.0, win=0.003, thr=0.03, ratio=0.05, release=0.04, protect=None):   # searched 7 October, then pushed harder on Ryan's word (the first setting was not much of a change)
    """Duck the high band where its short envelope leaps: the T's and D's. The gain falls to
    `ratio` of the overshoot at once and recovers over `release`. `protect` is a (start, end)
    span in samples left unducked, with a 5 ms ramp after it: an opening fricative, which is
    no plosive and which the tamer was otherwise holding at 17 dB under its vowel whatever
    the lift gave it (measured 7 October against Ryan's perfect and clipped lines)."""
    low = F.lp(y, split, order=3)
    high = y - low
    n = F.n_of(win)
    env = np.sqrt(np.convolve(high ** 2, np.ones(n) / n, mode="same")) + 1e-6
    gain = np.where(env > thr, (thr + (env - thr) * ratio) / env, 1.0)
    rel = F.n_of(release)
    out = np.empty_like(gain)
    g = 1.0
    for i in range(len(gain)):
        g = gain[i] if gain[i] < g else g + (1.0 - g) / rel
        out[i] = g
    if protect is not None:
        a, b = protect
        r = F.n_of(0.005)
        keep = np.zeros(len(y))
        keep[a:b] = 1.0
        keep[b:min(len(y), b + r)] = np.linspace(1.0, 0.0, r)[:min(len(y), b + r) - b]
        out = 1.0 - (1.0 - out) * (1.0 - keep)
    return low + high * out


def front_of(x):
    """The first consonant's span: from the first sound to where the low band reaches the
    vowel, and the vowel's peak level after it (dB)."""
    lo = F.lp(x, 1500.0, order=3)
    hi = x - lo
    n1, n2 = F.n_of(0.01), F.n_of(0.005)
    le = 20.0 * np.log10(np.sqrt(np.convolve(lo ** 2, np.ones(n1) / n1, mode="same")) + 1e-9)
    he = 20.0 * np.log10(np.sqrt(np.convolve(hi ** 2, np.ones(n2) / n2, mode="same")) + 1e-9)
    start = int(np.argmax(np.maximum(le, he) > -45.0))
    vowel = start + int(np.argmax(le[start:] > -22.0))
    return lo, hi, start, vowel, le[vowel:vowel + F.n_of(0.15)].max()


def front_level(x):
    """How far the first consonant's high band sits under its vowel, in dB."""
    lo, hi, a, b, vpk = front_of(x)
    if b - a < F.n_of(0.005):
        return -99.0
    return 20.0 * np.log10(np.sqrt(np.mean(hi[a:b] ** 2)) + 1e-9) - vpk


def lift_front(x, target=-14.0, cap=18.0):
    """Jenny clips the first phoneme of an utterance (measured 7 October: "squad" opens with 13 ms
    of s at 49 dB under its vowel where "sector" gets 80 ms at 14 under; the decoder and the chain
    were ruled out). Where the first consonant's high band sits further under its vowel than
    `target`, lift that band over its span by the difference, up to `cap`, with 5 ms ramps.
    An opening vowel or nasal has next to nothing in that band, so the lift does nothing there."""
    lo, hi, a, b, vpk = front_of(x)
    if b - a < F.n_of(0.005):
        return x
    lvl = 20.0 * np.log10(np.sqrt(np.mean(hi[a:b] ** 2)) + 1e-9) - vpk
    g_db = min(cap, max(0.0, target - lvl))
    if g_db <= 0.0:
        return x
    g = np.ones(len(x))
    r = F.n_of(0.005)
    g[a:b] = 10.0 ** (g_db / 20.0)
    ramp = np.linspace(1.0, g[a], r)
    g[max(0, a - r):a] = ramp[-(a - max(0, a - r)):] if a > 0 else ramp[:0]
    g[b:min(len(x), b + r)] = np.linspace(g[a], 1.0, r)[:min(len(x), b + r) - b]
    return lo + hi * g


def set_front(y, target=-18.0, floor=-12.0, cap=18.0):
    """Set the first consonant's high band to `target` dB under its vowel on a finished line,
    with 5 ms ramps. The chain is not linear in level (the syllable leveller lifts a quiet
    opening more than a loud one, measured 7 October: the same lift in gave fronts anywhere
    from 4 to 17 dB under out), so the level is set where it is heard, on the output."""
    lo, hi, a, b, vpk = front_of(y)
    if b - a < F.n_of(0.005):
        return y
    g_db = min(cap, max(floor, target - front_level(y)))
    g = np.ones(len(y))
    r = F.n_of(0.005)
    g[a:b] = 10.0 ** (g_db / 20.0)
    if a > 0:
        n0 = min(r, a)
        g[a - n0:a] = np.linspace(1.0, g[a], n0)
    g[b:min(len(y), b + r)] = np.linspace(g[a], 1.0, r)[:min(len(y), b + r) - b]
    return lo + hi * g


def mid_tamed(x, protect_front=False):
    """The mid chain with the plosives tamed before a gentler saturator. `protect_front` keeps
    the tamer off the first consonant's span (a fricative opening)."""
    protect = None
    if protect_front:
        lo, hi, a, b, vpk = front_of(x)
        protect = (a, b)
    y = F.bp(x, 180.0, 4500.0, order=3)
    y = V.level_syllables(y, target=0.22)
    y = V.flange(y, delay=0.0032, depth=0.0012, rate=0.3, feedback=0.62, wet=0.7)
    y = F.mix(y, V.sub_octave(y, 0.35))
    y = tame_plosives(y, protect=protect)
    hold = 2
    y = np.repeat(y[::hold], hold)[:len(y)]
    return F.sat(y / (np.max(np.abs(y)) + 1e-9) * 1.1, 1.25)


LINES = dict(V.LINES, shield_up="shield up", gate_breached="gate breached")
# the seventh pass: Jenny mid slow as picked, and the same with the plosives tamed
TRIALS = [
    ("jenny", "mid_slow", mid, 1.35),
    ("jenny", "mid_slow_tamed", mid_tamed, 1.35),
]


def resample(x, sr_in):
    if sr_in == SR:
        return x
    n = int(round(len(x) * SR / sr_in))
    return np.interp(np.linspace(0.0, len(x) - 1, n), np.arange(len(x)), x)


def render(voice, text, scale=LENGTH_SCALE, draw=0):
    """Render a line with Piper to WAV, cached under out/piper, and return it at the forge's rate.
    Piper samples: every call is a fresh draw, so `draw` names another one of the same text."""
    path = os.path.join(DATA, "%s_%s_%.2f%s.wav" % (voice, text.replace(" ", "_"), scale, "_d%d" % draw if draw else ""))
    if not os.path.exists(path):
        # A full stop is a sentence end to the phonemiser only when the next word is capitalised
        # (measured 7 October: lowercase after it, and "gate breached. the city is lost" came out
        # as one sentence phrased "gate breached the city, is lost"); the silence between
        # sentences is Piper's flag, nothing by default. The cache is keyed by the text as given.
        said = re.sub(r"([.!?])\s+([a-z])", lambda m: m.group(1) + " " + m.group(2).upper(), text)
        subprocess.run([PIPER_PY, "-m", "piper", "-m", VOICES[voice], "--data-dir", DATA, "--length-scale", str(scale), "--sentence-silence", str(SENTENCE_SILENCE), "-f", path, "--", said], check=True, capture_output=True)
    with wave.open(path, "rb") as w:
        sr = w.getframerate()
        x = np.frombuffer(w.readframes(w.getnframes()), "<i2").astype(float) / 32767.0
        if w.getnchannels() > 1:
            x = x.reshape(-1, w.getnchannels()).mean(axis=1)
    x = resample(x, sr)
    # the trim keeps a soft consonant at the front: a lower threshold and more room, since
    # "get wrecked" lost its g and "so it begins" its s at the first setting (Ryan, 7 October)
    idx = np.where(np.abs(x) > 0.0004)[0]
    a, b = max(0, idx[0] - F.n_of(0.14)), min(len(x), idx[-1] + F.n_of(0.08))
    return x[a:b]


def main(argv):
    os.makedirs(X.OUT, exist_ok=True)
    path = os.path.join(X.OUT, "manifest.json")
    manifest = {}
    if os.path.exists(path):
        with open(path) as fh:
            manifest.update(json.load(fh))
    manifest["voice7"] = []
    for key_, text in LINES.items():
        for v, proc, chain, scale in TRIALS:
            raw = render(v, text, scale)
            F.seed(PREFIX + "%s_%s_%s" % (v, key_, proc))
            x = V.level_for_phone(chain(raw), -14.0)   # the baseline mix (7 October): ten over the music's mean, under the blows, over the console
            name = PREFIX + "%s_%s_%s" % (v, key_, proc)
            X.write(name, X.tail(x, 0.3))
            manifest["voice7"].append({"name": name, "voice": v, "model": VOICES[v], "line": key_, "process": proc, "seconds": round(len(x) / SR, 2)})
            print("  %-40s %5.2f s" % (name, len(x) / SR))
    with open(path, "w") as fh:
        json.dump(manifest, fh, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
