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

    tools/soundforge/.venv-piper/bin/python -m piper.download_voices --data-dir tools/soundforge/out/piper <voice>...
    tools/spriter/.venv/bin/python tools/soundforge/piper_voices.py          # into out/fx
"""
import json
import os
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
DATA = os.path.join(F.OUT_SKETCH, "piper")
PREFIX = "voice5_"
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
TRIALS = [
    ("amy", "machine", V.machine, 1.15),
    ("jenny", "machine", V.machine, 1.15),
    ("jenny", "light", light, 1.15),
    ("jenny", "deep", deep, 1.15),
    ("jenny", "slow", V.machine, 1.35),
]


def resample(x, sr_in):
    if sr_in == SR:
        return x
    n = int(round(len(x) * SR / sr_in))
    return np.interp(np.linspace(0.0, len(x) - 1, n), np.arange(len(x)), x)


def render(voice, text, scale=LENGTH_SCALE):
    """Render a line with Piper to WAV, cached under out/piper, and return it at the forge's rate."""
    path = os.path.join(DATA, "%s_%s_%.2f.wav" % (voice, text.replace(" ", "_"), scale))
    if not os.path.exists(path):
        subprocess.run([PIPER_PY, "-m", "piper", "-m", VOICES[voice], "--data-dir", DATA, "--length-scale", str(scale), "-f", path, "--", text], check=True, capture_output=True)
    with wave.open(path, "rb") as w:
        sr = w.getframerate()
        x = np.frombuffer(w.readframes(w.getnframes()), "<i2").astype(float) / 32767.0
        if w.getnchannels() > 1:
            x = x.reshape(-1, w.getnchannels()).mean(axis=1)
    x = resample(x, sr)
    idx = np.where(np.abs(x) > 0.004)[0]
    a, b = max(0, idx[0] - F.n_of(0.03)), min(len(x), idx[-1] + F.n_of(0.08))
    return x[a:b]


def main(argv):
    os.makedirs(X.OUT, exist_ok=True)
    path = os.path.join(X.OUT, "manifest.json")
    manifest = {}
    if os.path.exists(path):
        with open(path) as fh:
            manifest.update(json.load(fh))
    manifest["voice5"] = []
    for key_, text in V.LINES.items():
        for v, proc, chain, scale in TRIALS:
            raw = render(v, text, scale)
            F.seed(PREFIX + "%s_%s_%s" % (v, key_, proc))
            x = V.level_for_phone(chain(raw), -12.0)
            name = PREFIX + "%s_%s_%s" % (v, key_, proc)
            X.write(name, X.tail(x, 0.3))
            manifest["voice5"].append({"name": name, "voice": v, "model": VOICES[v], "line": key_, "process": proc, "seconds": round(len(x) / SR, 2)})
            print("  %-40s %5.2f s" % (name, len(x) / SR))
    with open(path, "w") as fh:
        json.dump(manifest, fh, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
