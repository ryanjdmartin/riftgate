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
ways: the chain as before; `light`, less levelling and a shallower flange so more of her own
dynamics survive; `deep`, the flange fed back harder with more sub-octave; `slow`, the chain
with the model slowed a third.

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
PREFIX = "voice4_"
VOICES = {
    "amy": "en_US-amy-medium",
    "jenny": "en_GB-jenny_dioco-medium",
}
LENGTH_SCALE = 1.15   # a touch slower than the model's default, as the Mac voices were


def light(x):
    """Less levelling and a shallower flange: more of the voice's own dynamics survive."""
    y = F.bp(x, 180.0, 4500.0, order=3)
    y = V.level_syllables(y, target=0.22, cap=2.0)
    y = V.flange(y, feedback=0.3, wet=0.3)
    y = F.mix(y, V.sub_octave(y, 0.15))
    return F.sat(y / (np.max(np.abs(y)) + 1e-9) * 1.05, 1.2)


def deep(x):
    """The flange fed back harder, more sub-octave: further into the machine."""
    y = F.bp(x, 180.0, 4500.0, order=3)
    y = V.level_syllables(y, target=0.22)
    y = V.flange(y, delay=0.0034, depth=0.0014, feedback=0.62, wet=0.6)
    y = F.mix(y, V.sub_octave(y, 0.35))
    return F.sat(y / (np.max(np.abs(y)) + 1e-9) * 1.15, 1.4)


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
    manifest["voice4"] = []
    for key_, text in V.LINES.items():
        for v, proc, chain, scale in TRIALS:
            raw = render(v, text, scale)
            F.seed(PREFIX + "%s_%s_%s" % (v, key_, proc))
            x = V.level_for_phone(chain(raw), -12.0)
            name = PREFIX + "%s_%s_%s" % (v, key_, proc)
            X.write(name, X.tail(x, 0.3))
            manifest["voice4"].append({"name": name, "voice": v, "model": VOICES[v], "line": key_, "process": proc, "seconds": round(len(x) / SR, 2)})
            print("  %-40s %5.2f s" % (name, len(x) / SR))
    with open(path, "w") as fh:
        json.dump(manifest, fh, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
