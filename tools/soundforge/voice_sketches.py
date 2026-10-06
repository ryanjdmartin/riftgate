"""The voice, roughly, from the Mac's own synthesiser (Ryan, 6 October: try the voice using the Mac
tools, just roughly, to see). The target is the Terran Adjutant's register: smooth and human,
soulless and slightly synthesised, a machine assistant, neither monotone nor perfect human
cadence. The forge's formant voice could not reach it, so this starts from a real voice
(`say`, Apple's speech synthesis) and processes it down into the machine rather than building
speech up.

Two processings, each on three voices:

  machine   the Adjutant: a band from 180 Hz to 4.5 kHz, soft compression so every syllable
            sits level, a flange (a short modulated delay with feedback) for the metallic
            sheen, a faint sub-octave under the voiced parts.
  comm      the same over the hard channel: 300 Hz to 3.4 kHz, more compression, 10 bits, a
            squelch either side.

The voices: Samantha (US, the smooth one), Karen (AU, a little drier), Daniel (GB, male).
Rendered slower than conversation (`-r 165`). Rough by design.

    python3 tools/soundforge/voice_sketches.py          # into out/fx; needs `say` (macOS)
"""
import json
import math
import os
import subprocess
import sys
import wave

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import fx_sketches as X  # noqa: E402
import audition_sketches as A  # noqa: E402  (the squelch)
from phone_sketches import phone_model  # noqa: E402

SR = F.SR
n_of, t_of, mix, at = F.n_of, F.t_of, F.mix, F.at
RAW = os.path.join(F.OUT_SKETCH, "say")

LINES = {"target_locked": "target locked", "weapons_online": "weapons online", "machine_lost": "machine lost",
         "all_units": "all units committed", "incoming": "incoming"}
VOICES = {"samantha": "Samantha", "karen": "Karen", "daniel": "Daniel"}
RATE = 165


def say(voice, text):
    """Render a line with the Mac's synthesiser to a 48 kHz WAV, cached under out/say."""
    os.makedirs(RAW, exist_ok=True)
    path = os.path.join(RAW, "%s_%s.wav" % (voice, text.replace(" ", "_")))
    if not os.path.exists(path):
        subprocess.run(["say", "-v", VOICES[voice], "-r", str(RATE), "-o", path, "--file-format=WAVE", "--data-format=LEI16@48000", text], check=True)
    with wave.open(path, "rb") as w:
        assert w.getframerate() == SR, w.getframerate()
        x = np.frombuffer(w.readframes(w.getnframes()), "<i2").astype(float) / 32767.0
        if w.getnchannels() > 1:
            x = x.reshape(-1, w.getnchannels()).mean(axis=1)
    # trim the silence either side
    idx = np.where(np.abs(x) > 0.004)[0]
    a, b = max(0, idx[0] - n_of(0.03)), min(len(x), idx[-1] + n_of(0.08))
    return x[a:b]


def level_syllables(x, win=0.03, target=0.2, cap=4.0):
    """Soft compression: a slow gain toward one level wherever the voice sounds, so every
    syllable sits level, the soulless part."""
    n = n_of(win)
    env = np.sqrt(np.convolve(x ** 2, np.ones(n) / n, mode="same")) + 1e-6
    gain = np.clip(target / env, 0.0, cap)
    gain = np.convolve(gain, np.ones(n) / n, mode="same")
    on = (env > 0.01).astype(float)
    on = np.convolve(on, np.ones(n) / n, mode="same")
    return x * (1.0 + (gain - 1.0) * on)


def flange(x, delay=0.0028, depth=0.0012, rate=0.35, feedback=0.45, wet=0.5):
    """A short modulated delay with feedback: the metallic sheen of a processed voice."""
    n = len(x)
    t = t_of(n)
    d = (delay + depth * np.sin(2.0 * math.pi * rate * t)) * SR
    out = np.array(x, dtype=float)
    buf = np.zeros(n)
    for i in range(n):
        j = i - d[i]
        if j <= 0:
            continue
        k = int(j)
        fr = j - k
        s = buf[k] * (1.0 - fr) + buf[min(k + 1, n - 1)] * fr if k + 1 < n else buf[k]
        buf[i] = x[i] + feedback * s
        out[i] = x[i] + wet * s
    return out


def sub_octave(x, gain=0.25):
    """A faint octave under the voiced parts: a half-rate copy through a low-pass."""
    half = np.repeat(x[::2], 2)[:len(x)]
    return F.lp(half, 400.0) * gain


def machine(x):
    y = F.bp(x, 180.0, 4500.0, order=3)
    y = level_syllables(y, target=0.22)
    y = flange(y)
    y = mix(y, sub_octave(y, 0.22))
    return F.sat(y / (np.max(np.abs(y)) + 1e-9) * 1.1, 1.3)


def comm(x):
    y = F.bp(x, 300.0, 3400.0, order=4)
    y = level_syllables(y, target=0.28, cap=6.0)
    y = flange(y, wet=0.35)
    y = F.sat(y / (np.max(np.abs(y)) + 1e-9) * 1.6, 2.2)
    steps = 2.0 ** 10
    y = np.round(y * steps) / steps
    buf = at(A.sq(0.8), y, 0.03)
    return at(buf, A.sq(0.6, 0.022), 0.03 + len(y) / SR + 0.02)


PROCESS = {"raw": (lambda x: x), "machine": machine, "comm": comm}


def level_for_phone(x, db):
    return x * 10.0 ** ((db - F.loudness(phone_model(x))) / 20.0)


def main(argv):
    os.makedirs(X.OUT, exist_ok=True)
    path = os.path.join(X.OUT, "manifest.json")
    manifest = {}
    if os.path.exists(path):
        with open(path) as fh:
            manifest.update(json.load(fh))
    manifest["voice"] = []
    for key_, text in LINES.items():
        for v in VOICES:
            raw = say(v, text)
            for proc in ("raw", "machine", "comm") if key_ == "target_locked" else ("machine", "comm"):
                F.seed("voice_%s_%s_%s" % (v, key_, proc))
                x = level_for_phone(PROCESS[proc](raw), -12.0)
                name = "voice_%s_%s_%s" % (v, key_, proc)
                X.write(name, X.tail(x, 0.3))
                manifest["voice"].append({"name": name, "voice": v, "line": key_, "process": proc, "seconds": round(len(x) / SR, 2)})
                print("  %-36s %5.2f s" % (name, len(x) / SR))
    with open(path, "w") as fh:
        json.dump(manifest, fh, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
