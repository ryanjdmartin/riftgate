"""Each track as a pair (Ryan, 24 October): could every track be both a map track and a battle
track, the two crossfading into each other, the map's version not the battle's turned down but
re-voiced: the drums cut, the instruments swapped for less gain, a strategic sound rather than
combat. FTL's pairing: a track written once and voiced twice on one timeline, so a crossfade
at any moment changes what plays, never where the music is.

Hold The Line first. Its battle version is the shipped file, untouched (the forge renders it bit
for bit, checked 24 October). Its map version is a second arrangement on the same groove call:
the same form, tempo, metres and chords, every note taken from the battle recipe as it stands
(captured, not copied, so an edit to the battle's tune moves the map's with it). By rule:

  the kit      gone: no kick, snare, hats, cymbals or toms anywhere.
  the gain     the chugged guitar's figures go to the mechanical guitar, clean and muted (Night
               Shift's rhythm guitar, an octave over the chug), so the polymeter still ticks with
               no wall of gain behind it; the driven bass and the crunch synth go to the soft sub,
               on the riff where the battle's bass plays it and held on the root where it drives.
  the voices   the map's own: the riff on the tine piano two octaves up, the second lift's riff
               and the solo's walk on spiccato cellos, the unison, the climax and the descent on
               the harp, Ryan's tune on the piano with his harmony line on a soft horn, the
               fight's metal chime swapped for the map's bell and its long echo, bowed strings
               held where the guitars ring.
  the bed      the saw drone under every riff section, a dark swept pad on the chords everywhere
               else, the lifts' choir, a backwards swell where the battle fills, a cello or a horn
               holding the note through a bar the battle's drums fill alone.
  the room     more air than the fight's, the map's level (Night Shift's and Low Ground's).

Writes into tools/soundforge/out/pairs/: the map version alone; the pair as one stereo file,
the map left and the battle right, for the listening page's live crossfade (each channel coded
on its own, with no joint or intensity stereo, so neither leaks into the other); and a run as
the game would play it: the battle opening on the map, an engage, the map crossfading into the
fight over three seconds from it, a victory and back to the field, then a hunter's contact whose fight lands
in the keys section, every effect at its shipped level under the game's dips (Sound.DIP). The
page is pair_page.html, copied in as index.html: publish it with manifest.json and the .mp4
files as its `files`.

    tools/spriter/.venv/bin/python tools/soundforge/pair_sketches.py        # all of it (about four minutes)
    tools/spriter/.venv/bin/python tools/soundforge/pair_sketches.py run    # the pair and the run again from the rendered map version
"""
import json
import math
import os
import shutil
import subprocess
import sys
import wave

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
from phone_sketches import Patched, phone_model  # noqa: E402

OUT = os.path.join(F.OUT_SKETCH, "pairs")
PAGE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "pair_page.html")
AUDIO = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "art", "audio")
MAP_LEVEL = F.LEVELS["music_night_shift"]   # the map's level, Night Shift's and Low Ground's

# The game's numbers, as game/audio/sound.gd and the battle screen have them.
DIP = {"contact": (-7.0, 0.7), "engage": (-9.0, 2.4), "cut": (-14.0, 1.6), "victory": (-12.0, 3.0)}
CUT_AFTER = 2.15    # the handover: the dive and the spread (1.85 s), then the scrim's 0.3 s, then the cut
CONTACT_AGAIN = 1.02   # the warning's second beat, 2 dB under the first
FLIP = 3.0          # a pair's crossfade either way, from ENGAGE and from BACK TO THE FIELD (Ryan, 28 October: split the difference of 2.15 and 4)

# A battle as the game plays it, in seconds of the track: the map from the top, an engage in
# the first lift, the fight on through the seven into the drum solo, back to the field, then
# a hunter's catch whose fight lands in the keys section and climbs into the climax.
RUN = [(48.0, "engage"), (116.0, "victory"), (119.0, "field"),
       (146.0, "contact"), (150.0, "engage"), (200.0, "victory"), (203.0, "field")]
RUN_END = 232.0


# ---------------------------------------------------------------- the battle recipe, read

def battle_call(fn=F.music_hold_the_line):
    """A recipe's groove call, captured rather than rendered: its form, metres, chords and voices."""
    call = {}

    def capture(*a, **kw):
        call.update(kw)
        return np.zeros(1)
    with Patched(groove=capture):
        fn()
    return call


def part(call, inst, section, octave=None, mode="riff"):
    """The battle's pattern for a section on the first voice of `inst` (in that octave and mode)
    that plays it."""
    for v in call["voices"]:
        if v["inst"] == inst and section in v["pat"] and v.get("mode", "riff") == mode and (octave is None or v.get("octave", 0) == octave):
            return v["pat"][section]
    raise KeyError("no %s %s voice in octave %s plays %s" % (mode, inst, octave, section))


def spell(semis):
    return str(semis) if 0 <= semis <= 9 else F._SPELL[semis]


def roots(call, section, steps=16):
    """Each bar's chord root held through the bar, across the section's chord cycle."""
    return "".join(spell(c[0]) + "-" * (steps - 1) for c in call["chords"][section])


# ---------------------------------------------------------------- the map's version

def map_voices(call):
    p = lambda *a, **k: part(call, *a, **k)   # noqa: E731
    rest = lambda bars: "." * (16 * bars)   # noqa: E731
    held = lambda note, steps=16: note + "-" * (steps - 1)   # noqa: E731
    riff = p("bass_real", "N", octave=0)          # E G E F, D G F E, then the rise: four bars
    ostinato = p("guitar_real", "A", octave=-1)   # the chug's seven-step figure
    lift = p("sub_bass", "C")
    down = p("guitar_real", "M", octave=-1)
    seven = p("guitar_real", "X", octave=-1)
    unison = p("lead", "U")
    climax = p("guitar_real", "S", octave=0)
    descent = p("lead", "J")
    return [
        # The pulse: the chug's figures on the mechanical guitar, clean and muted, an octave
        # over the chug's, where a phone's speaker hears it.
        {"inst": "guitar_real", "mode": "riff", "gain": 0.2, "octave": 0, "params": {"clean": True},
         "pat": {"A": ostinato, "N": ostinato, "X": seven, "U": unison, "S": climax, "R": climax, "Z": climax, "J": descent}},
        # The bass: the soft sub on the riff where the battle's bass plays it, and under the
        # cellos' riff...
        {"inst": "sub_bass", "mode": "riff", "gain": 0.4, "hold": 1.0,
         "pat": {"A": rest(4) + riff * 3, "N": riff, "C": lift, "M": down}},
        {"inst": "sub_bass", "mode": "riff", "gain": 0.28, "hold": 1.0, "pat": {"L": p("bass", "L")}},
        # ...and held on the bar's root where the battle drives the bar; Ryan's sub line in the keys.
        {"inst": "sub_bass", "mode": "riff", "gain": 0.36, "legato": True,
         "pat": {"B": "0-----------....", "X": roots(call, "X", 14), "U": roots(call, "U"), "F": p("sub_bass", "F"),
                 "W": held("7") + rest(1), "S": roots(call, "S"), "R": roots(call, "R"), "Z": roots(call, "Z"),
                 "Y": held("0"), "Q": held("0"), "J": held("0", 32)}},
        # The riff on the tine piano two octaves up, from where the battle's power chords
        # arrive; the seven an octave lower; the climax's riff in its third set, as the
        # battle's keys take it.
        {"inst": "epiano", "mode": "riff", "gain": 0.3, "octave": 2, "hold": 1.4,
         "pat": {"A": rest(8) + riff * 2, "N": riff, "Z": climax}},
        {"inst": "epiano", "mode": "riff", "gain": 0.26, "octave": 1, "hold": 1.2, "pat": {"X": seven}},
        {"inst": "epiano", "mode": "riff", "gain": 0.22, "octave": 2, "pat": {"J": descent}},
        # Ryan's tune and the keyboard solo on the piano, his harmony line on a soft horn, which
        # holds the turn's note through the bar the battle's drums fill alone.
        {"inst": "epiano", "mode": "riff", "gain": 0.36, "octave": 2, "hold": 1.0,
         "pat": {"F": p("lead", "F", octave=2), "W": held("7") + rest(1), "Y": held("7"), "K": p("epiano", "K", octave=2)}},
        {"inst": "horn_real", "mode": "riff", "gain": 0.16, "octave": 1, "legato": True,
         "pat": {"F": p("lead", "F", octave=1), "W": held("7", 32)}},
        # Spiccato cellos: the second lift's riff, the bar down, the solo's walk; a held E
        # through the turns.
        {"inst": "cello_real", "mode": "riff", "gain": 0.5, "hold": 1.6,
         "pat": {"L": p("bass", "L"), "M": down, "K": p("bass", "K"), "V": held("0"), "B": "0-----------....", "Q": held("0")}},
        {"inst": "cello_real", "mode": "riff", "gain": 0.28, "octave": 1, "legato": True, "pat": {"X": p("guitar_real", "X", octave=1)}},
        # The unison, the climax and the descent on the harp, let ring.
        {"inst": "harp", "mode": "riff", "gain": 0.48, "octave": 1, "hold": 2.5,
         "pat": {"U": unison, "S": climax, "R": climax, "Z": climax, "J": descent}},
        # The fight's metal chime is the map's bell, with its long echo (down 3 dB from the first
        # cut, Ryan, 28 October: a little loud).
        {"inst": "bell", "mode": "chord", "octave": 2, "gain": 0.1, "echo": (3, 0.4, 3), "dur": 2.5,
         "pat": {s: p("chime_metal", s, mode="chord") for s in "ACFXWRZ"}},
        # Held chords where the battle stabs: the piano on the lifts' beats and the turn, the
        # seven's long beat, the solo's bars and its breath.
        {"inst": "epiano", "mode": "stab", "gain": 0.3, "dur": 8.0, "pat": {"B": "x...............", "C": "x.......x.......", "L": "x.......x......."}},
        {"inst": "epiano", "mode": "stab", "gain": 0.26, "dur": 3.0, "pat": {"X": p("epiano", "X", mode="stab")}},
        {"inst": "epiano", "mode": "stab", "gain": 0.3, "dur": 14.0, "pat": {"K": p("epiano", "K", mode="stab"), "V": "x..............."}},
        {"inst": "epiano", "mode": "chord", "gain": 0.45, "octave": 2, "dur": 20, "pat": {"V": p("epiano", "V", octave=2, mode="chord")}},
        # A backwards swell into each section where the battle fills.
        {"inst": "swell_rev", "mode": "stab", "gain": 0.35, "dur": 2.0,
         "pat": {"B": "..............x.", "W": "." * 30 + "x.", "Y": "..............x.", "V": "..............x.", "Q": "..............x."}},
    ]


MAP_PADS = [
    # The drone under every riff section from the top, a little darker than the fight's.
    {"inst": "sweep", "gain": 0.4, "octave": 0, "rate": 0.08, "depth": 0.3, "open": 0.55, "sections": "ANSRZ", "chord": [0, 7, 12]},
    # A dark swept pad on the chords everywhere else.
    {"inst": "sweep", "gain": 0.14, "octave": 1, "rate": 0.05, "depth": 0.6, "open": 0.4, "sections": "BCLMXUFWYKVQJ"},
    {"inst": "choir_real", "gain": 0.16, "vowel": "oh", "sections": "C"},
    {"inst": "choir_real", "gain": 0.12, "vowel": "ah", "sections": "Z"},
    {"inst": "strings_real", "gain": 0.12, "sections": "RZYKV"},
]


def map_hold_the_line():
    """Hold The Line's map version on the battle's own groove call, kit and drums emptied."""
    call = battle_call(F.music_hold_the_line)
    return F.groove(bpm=call["bpm"], form=call["form"], meter=call["meter"], kit={}, drums={},
                    chords=call["chords"], voices=map_voices(call), pad=[dict(p) for p in MAP_PADS],
                    air=(0.25, 0.1), master=1.1, headroom=0.6, tilt=1.5, presence=0.25, low=(150.0, -6.0),
                    human=call["human"])


# ---------------------------------------------------------------- the files

def read_wav(path):
    with wave.open(path, "rb") as w:
        return np.frombuffer(w.readframes(w.getnframes()), "<i2") / 32767.0


def write(name, x, kbps=256):
    """A WAV (mono, or stereo for a list of two) and its AAC in an MP4, into OUT. Stereo is coded
    as two channels with nothing shared between them."""
    os.makedirs(OUT, exist_ok=True)
    chans = x if isinstance(x, list) else [x]
    pcm = np.stack([(np.clip(c, -1.0, 1.0) * 32767.0).astype("<i2") for c in chans], axis=1)
    wav = os.path.join(OUT, name + ".wav")
    with wave.open(wav, "wb") as w:
        w.setnchannels(len(chans))
        w.setsampwidth(2)
        w.setframerate(F.SR)
        w.writeframes(pcm.tobytes())
    m4a = os.path.join(OUT, name + ".mp4")
    apart = ["-aac_ms", "0", "-aac_is", "0", "-aac_pns", "0"] if len(chans) > 1 else []
    subprocess.run(["ffmpeg", "-y", "-loglevel", "error", "-i", wav, "-c:a", "aac", "-b:a", "%dk" % kbps] + apart
                   + ["-movflags", "+faststart", m4a], check=True, capture_output=True)
    return m4a


def effects_of(events):
    """The effects a run plays, as (seconds, name, dB): the warning's two beats, the engage and
    its cut, the victory."""
    out = []
    for when, what in events:
        if what == "contact":
            out += [(when, "contact", 0.0), (when + CONTACT_AGAIN, "contact", -2.0)]
        elif what == "engage":
            out += [(when, "engage", 0.0), (when + CUT_AFTER, "cut", 0.0)]
        elif what == "victory":
            out.append((when, "victory", 0.0))
    return sorted(out)


def gains(n, events):
    """The music's two gains through a run, the map's and the battle's, each sample: an equal
    power crossfade (Sound._fade_to's cosine and sine) over each change, and the dips the game
    applies on top (Sound._dip: a 30 ms drop, a quadratic climb back, a new dip taking over
    from wherever the last one is)."""
    t = np.arange(n) / F.SR
    battle = np.zeros(n)
    for when, what in events:
        if what in ("engage", "field"):
            x = np.clip((t - when) / FLIP, 0.0, 1.0)
            battle = np.where(t >= when, x if what == "engage" else 1.0 - x, battle)
    dip = np.zeros(n)
    for when, name, _db in effects_of(events):
        if name not in DIP:
            continue
        depth, recover = DIP[name]
        i = int(when * F.SR)
        now, low = float(dip[i]), min(float(dip[i]), depth)
        s = t[i:] - when
        u = np.clip((s - 0.03) / recover, 0.0, 1.0)
        dip[i:] = np.where(s < 0.03, now + (low - now) * s / 0.03, low * (1.0 - u * u))
    g = 10.0 ** (dip / 20.0)
    return np.cos(battle * math.pi / 2.0) * g, np.sin(battle * math.pi / 2.0) * g


def run(map_x, battle_x):
    """The run: both versions through their gains, the effects at their files' levels over them
    (the game's knobs at their defaults, every bus at 0 dB), three seconds faded at the end."""
    n = int(RUN_END * F.SR)
    gm, gb = gains(n, RUN)
    x = map_x[:n] * gm + battle_x[:n] * gb
    effects = effects_of(RUN)
    fx = np.zeros(n + F.SR * 5)
    for when, name, db in effects:
        s = read_wav(os.path.join(AUDIO, name + ".wav")) * 10.0 ** (db / 20.0)
        i = int(when * F.SR)
        fx[i:i + len(s)] += s
    x = x + fx[:n]
    x[-F.SR * 3:] *= np.linspace(1.0, 0.0, F.SR * 3)
    return x, effects


def measure(name, x):
    # Padded to a power of two: the forge's filters are whole-file FFTs, slow on a length with a
    # large prime factor (a track's), and the padding keeps the filters' wrap off the music.
    padded = np.concatenate([x, np.zeros((1 << int(math.ceil(math.log2(len(x))))) - len(x))])
    return {"name": name, "mean_db": round(F.mean_level(x), 1), "phone_db": round(F.mean_level(phone_model(padded)[:len(x)]), 1),
            "peak_db": round(20.0 * math.log10(float(np.max(np.abs(x))) + 1e-9), 1), "under_150": round(F.low_share(padded), 2)}


def main(argv):
    which = argv[0] if argv else "all"
    os.makedirs(OUT, exist_ok=True)
    map_wav = os.path.join(OUT, "hold_map.wav")
    if which == "all" or not os.path.exists(map_wav):
        F.seed("music_hold_the_line_map")
        x = F.limit(F.write_level(map_hold_the_line(), "music_hold_the_line_map", MAP_LEVEL))
        write("hold_map", x)
        print("hold_map       %6.2f s  %s" % (len(x) / F.SR, os.path.relpath(map_wav)))
    map_x = read_wav(map_wav)
    battle_x = read_wav(os.path.join(AUDIO, "music_hold_the_line.wav"))
    if len(map_x) != len(battle_x):
        print("the map version is %d samples, the battle's %d: not one timeline" % (len(map_x), len(battle_x)))
        return 1
    write("hold_pair", [map_x, battle_x], kbps=384)
    x, effects = run(map_x, battle_x)
    write("hold_run", x)
    runs, total = F.sections("music_hold_the_line")
    m = F.MUSIC["music_hold_the_line"]
    form = m["form"].replace(" ", "")
    steps, _, scales = F._bars(form, m.get("meter"))
    bar_at = np.concatenate([[0.0], np.cumsum([s * k * 15.0 / m["bpm"] for s, k in zip(steps, scales)])])
    manifest = {
        "track": "music_hold_the_line", "length": round(total, 3), "bpm": m["bpm"], "loop_from_bar": 9,
        "bar_at": [round(float(b), 4) for b in bar_at[:-1]],
        "sections": [{"section": s, "bars": [b0, b1], "at": round(t, 2), "what": what} for s, b0, b1, t, what in runs],
        "run": {"events": [{"at": w, "what": e} for w, e in RUN], "effects": [{"at": round(w, 2), "name": nm, "db": db} for w, nm, db in effects],
                "end": RUN_END, "flip": FLIP},
        "levels": [measure("map", map_x), measure("battle", battle_x)],
    }
    with open(os.path.join(OUT, "manifest.json"), "w") as f:
        json.dump(manifest, f, indent=1)
    shutil.copyfile(PAGE, os.path.join(OUT, "index.html"))
    for lv in manifest["levels"]:
        print("%-8s mean %6.1f dB  phone %6.1f dB  peak %6.1f dB  under 150 Hz %4.2f" % (lv["name"], lv["mean_db"], lv["phone_db"], lv["peak_db"], lv["under_150"]))
    print(os.path.relpath(OUT))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
