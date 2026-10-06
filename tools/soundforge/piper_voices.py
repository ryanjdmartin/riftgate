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
PREFIX = "voice3_"
VOICES = {
    "amy": "en_US-amy-medium",
    "ljspeech": "en_US-ljspeech-medium",
    "alba": "en_GB-alba-medium",
    "jenny": "en_GB-jenny_dioco-medium",
    "southern": "en_GB-southern_english_female-low",
}
LENGTH_SCALE = 1.15   # a touch slower than the model's default, as the Mac voices were


def resample(x, sr_in):
    if sr_in == SR:
        return x
    n = int(round(len(x) * SR / sr_in))
    return np.interp(np.linspace(0.0, len(x) - 1, n), np.arange(len(x)), x)


def render(voice, text):
    """Render a line with Piper to WAV, cached under out/piper, and return it at the forge's rate."""
    path = os.path.join(DATA, "%s_%s.wav" % (voice, text.replace(" ", "_")))
    if not os.path.exists(path):
        subprocess.run([PIPER_PY, "-m", "piper", "-m", VOICES[voice], "--data-dir", DATA, "--length-scale", str(LENGTH_SCALE), "-f", path, "--", text], check=True, capture_output=True)
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
    manifest["voice3"] = []
    for key_, text in V.LINES.items():
        for v in VOICES:
            raw = render(v, text)
            for proc in (("raw", "machine") if key_ == "target_locked" else ("machine",)):
                F.seed(PREFIX + "%s_%s_%s" % (v, key_, proc))
                x = V.level_for_phone(V.PROCESS[proc](raw), -12.0)
                name = PREFIX + "%s_%s_%s" % (v, key_, proc)
                X.write(name, X.tail(x, 0.3))
                manifest["voice3"].append({"name": name, "voice": v, "model": VOICES[v], "line": key_, "process": proc, "seconds": round(len(x) / SR, 2)})
                print("  %-40s %5.2f s" % (name, len(x) / SR))
    with open(path, "w") as fh:
        json.dump(manifest, fh, indent=1)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
