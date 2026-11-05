"""Night Shift's eighteenth round as a pair (Ryan, 5 November, on the seventeenth): the duel's lower
bass playing on under the upper's phrases, the backing 3 dB under the basses.

  "for the dueling basses, don't cut out the lower one when the upper comes in, since it sounds
  fragmented and empty without the lower end. So that means: -copy the upper line in lowered unison,
  and/or -play a backing rhythm, and/or, -play a complimentary line. We could also try what the upper
  bass line sounds like doing chords instead. I think the two basses being different voices sounds
  better, so like in the first option. Keep the backing voices at the 3db under, that works."

Under each of the upper bass's phrases the lower plays on, 3 dB under its own phrases so the answer
stays on top: the upper's line an octave down for the full pair (DUEL_SUPPORT), beside three-three-two
on the roots and a walking line of its own in quarters; under a stop's fill it holds the root through
the gap, but in unison, where it doubles the fill. A set has those and the upper bass in chords (each
note with its fifth, two strings into one amp) over the unison or the rhythm. The second bass stays
the active bass, the backing 3 dB under the basses (DUEL_BACKING).

The seventeenth round's, kept: R's sixteen bars a duel (DUEL), the track's bass and a second bassist
an octave over it trading phrases on his rhythms, two bars each, a bar each, then half a bar each,
through two bars of stop-time (the band's hit on each bar's one, then one bass alone) and a hole (the
whole band out on a bar's last beat), then the two together on three-three-two under the band's hits,
climbing into the outro in octaves; the backing trading the tune over them at one level under the
basses (DUEL_LEVELS); the sub out of R.

The sixteenth round's, kept: the bass the fingers into the modern prog drive (real_bass.py's
MODERN) wherever it plays; C's long notes, the lead guitar's line, on that bass an octave under the
guitar (LEAD), the top of its high string.

The fifteenth round's, kept: the drive on the fingers through an amp, a step at a time; on a held
E1 every step's overtones fall away as the note rings, the grind at the attack.

The fourteenth round's, kept: the rhythm guitar back in the breakdown (B) alone, the lead guitar's
lines kept; D's hold without the bass; R at one level; the plucked string 3 dB down wherever the
arpeggio takes it. In detail: the rhythm guitar's ringing chords in the breakdown alone (GUITARS
"breakdown"); D's hold without the bass (D_BASS), the house piano carrying three-three-two over the
nod's riff; the plucked string 3 dB down (PLUCK_DB), since at the synth lead's level on a phone and in
full it read 1.6 dB over it by the ear's weighting (BS.1770), its 2 to 5 kHz 6 dB hotter. Why the
modelled basses read as guitars is real_bass.py's.

The thirteenth round's, kept: the map half without its muted guitar (his call); the rhythm guitar
out of the walk and its ghost notes, R's tenth, the hold and the stop-time hits; the bass voices.

The twelfth round's, kept as a way of the guitar: the bass plays single notes, and the guitar that
walked the same line in unison played every note as a power chord (root, fifth and octave), so the
line sounded in chords over it; on one string (guitar_one) it went into the gain as hard as the
three strings did and met their level on a phone and in full.

The eleventh round's, kept: every part the driven bass played (the walk, the hold under the two
synth lines, the breakdown's held roots, R's turn) on a finger bass with no drive: the driven bass's
two strings, its finger's thump, its body and its cabinet, evened as a compressor would, beside the
synth bass, the finger bass with a touch of drive, a slapped bass with its clip taken out and the
slap with the same touch. On a sine at a note's peak the driven bass's amp makes 39% harmonic
distortion and the tenth round's slap a little driven 41%; the clean voices make none and the touch
about 5%, an amp just breaking up. That measured the amp alone: the string under it is the forge's
plucked string, bright and ringing whatever the amp does (the fourteenth round's). Each meets the
driven bass's level on a phone and in full alike (BASS_VOICES).

The tenth round's, kept: R twice as long, sixteen bars (the duel's now); the chime's hook, the sub's
pulse and the piano's off-beats resting where R leaves the room. The map half without its muted
guitar (his call since the twelfth); its R twice as long, the groove again repeating, so the halves
keep one timeline.

Kept from the earlier rounds: the battle half as a jam in turns of two bars, the walk with the
arpeggio or the hook and never both, the hold under the two together on three-three-two 6 dB down,
the outro's hold into the top; the synth lines' voicings by job; the intro on three-three-two all
through; D the piano's turn and the factory's blended, the riff dark and low as the map's nod; the
guitar a tenth over the bass in R; the bass 3 dB down everywhere; the map half (the intro without
its front), no crash at the top and no drone.

    tools/spriter/.venv/bin/python tools/soundforge/night_sketches.py          # the set and the full pair, then night18.json beside the pairs
    tools/spriter/.venv/bin/python tools/soundforge/night_sketches.py nu       # the named sets only (nu, and full for the pair)
"""
import json
import os
import sys
from concurrent.futures import ProcessPoolExecutor

import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import forge as F  # noqa: E402
import real_bass  # noqa: E402,F401  (the real basses' voice)
import pair_sketches as P  # noqa: E402
from hold_sketches import copied, master_together, run_steps  # noqa: E402

NAME = "music_night_shift"
MAP_LEVEL = F.LEVELS[NAME]
BATTLE_LEVEL = P.PAIRS["night_shift"]["level"]
R_BARS = 16   # R twice as long (Ryan, 3 November: "R also can be rewritten and extended")
FORM10 = F.MUSIC[NAME]["form"].replace("R" * 8, "R" * R_BARS)


# ---------------------------------------------------------------- the map half

MAP_GUITAR = False   # the map's muted guitar out (Ryan, 4 November: "Map groove sounds better without the muted guitar")


def map_intro(call, guitar=MAP_GUITAR):
    """The shipped map with its front cut (Ryan: don't start with the sub and the drone, it breaks
    the loop; the drone's crescendo from about 0:10 works): the sub's pulse joins at the intro's
    fifth bar, and the pad is silent for three bars and fades in through the fourth, where its
    slow filter is at its darkest, so from 0:10 it opens just as it did. Without `guitar`, the
    muted guitar's rhythm is gone from every section; its voices stay in the list, empty, so every
    other voice keeps its humanising."""
    kw = copied(call)
    if not guitar:
        for v in kw["voices"]:
            if v["inst"] == "guitar_real":
                v["pat"] = {}
    for v in kw["voices"]:
        if v["inst"] == "sub_bass" and "I" in v["pat"]:
            v["pat"]["I"] = "." * 64 + v["pat"]["I"] * (64 // len(v["pat"]["I"]))
    for p in kw["pad"]:
        if "I" in p.get("sections", ""):
            p["enter"] = {"I": (3, 1)}
    return kw


# ---------------------------------------------------------------- the battle half

def bars(*xs):
    return "".join(xs)


FILL_TOM, FILL_TOM2 = "....x.x.xx.x.x..", "......x.....x.xx"   # Hold The Line's fill, in a phrase's last bar
GROOVE_KICK = bars("x...x...x...x..x", "x...x..xx...x...", "x...x...x...x..x", "x...x..xx...x.x.",
                   "x...x...x...x..x", "x...x..xx...x...", "x...x...x...x..x", "x...x...x.......")
LEAD_KICK = bars("x...x...x...x..x", "x..x..x.x...x...", "x...x...x...x..x", "x..x..x.x...x.x.",
                 "x...x...x...x..x", "x..x..x.x...x...", "x...x...x...x..x", "x...x...x.......")
GROOVE_SNARE = bars("....x..o....x..o", "....x..o.o..x...", "....x..o....x..o", "....x..o.o..x.o.",
                    "....x..o....x..o", "....x..o.o..x...", "....x..o....x..o", "....x.......x...")
HATS = "xx.xxx.xxx.xxx.x" * 7 + "xx.xxx.x........"   # sixteenths round the open hat, out for the fill
OPENS = "..x...x...x...x." * 7 + "..x...x........."
FILLS = {"tom": "." * 112 + FILL_TOM, "tom2": "." * 112 + FILL_TOM2}

# The second round's groove, one bar on each chord's root: the hold's.
THREE_THREE_TWO = "r..r..r.r..r..r."
EIGHTHS = "r.r.r.r.r.r.r.r."   # round one's chug

# The bass line's notes for each chord as (root, its octave, its fifth, the passing note into the
# next chord), on the driven bass an octave down (0 is E1).
CHORD_NOTES = {   # by the chord's root and the next chord's root
    (0, 8): ("0", "c", "7", "7"), (8, 10): ("8", "e", "c", "9"), (10, 7): ("a", "j", "f", "8"), (7, 0): ("7", "i", "d", "l"),
    (0, 5): ("0", "c", "7", "4"), (5, 3): ("5", "f", "c", "4"), (3, -2): ("3", "e", "a", "9"), (-2, 0): ("a", "j", "f", "l"),
    (0, 0): ("0", "c", "7", "l"), (8, 7): ("8", "e", "c", "8"),
    (0, -2): ("0", "c", "7", "9"), (-2, 3): ("a", "j", "f", "2"), (3, 0): ("3", "e", "a", "l"),   # D's Em D G
}


def line_bar(fig, root, next_root):
    """The bass line's bar on a groove before the next chord (the second round's): a hit by the and
    of two takes the octave, one by the a of three the fifth, the bar's last hit from beat four the
    passing note, the rest the root; a hit with room after it holds two steps."""
    root_, octave, fifth, passing = CHORD_NOTES[root, next_root]
    hits = [i for i, c in enumerate(fig) if c == "r"]
    bar = ["."] * 16
    for j, h in enumerate(hits):
        last = j == len(hits) - 1
        bar[h] = passing if last and h >= 12 else octave if 6 <= h <= 7 else fifth if 11 <= h <= 13 else root_
        if (16 if last else hits[j + 1]) - h >= 3:
            bar[h + 1] = "-"
    return "".join(bar)


# The hold under the hook and the arpeggio together, a bar's guitar and bass on its chord's root
# before the next chord's (Ryan: "back to holding the rhythm and chords like your first take"):
# three-three-two, the guitar on the root and the bass on its line (the second round's groove, the
# third round's first row), or round one's eighths on the root.
HOLDS = {
    "332": (lambda r, n: P.figure(THREE_THREE_TWO, [P.spell(r)]), lambda r, n: line_bar(THREE_THREE_TWO, r, n)),
    "eighths": (lambda r, n: P.figure(EIGHTHS, [P.spell(r)]), lambda r, n: P.figure(EIGHTHS, [P.spell(r)])),
}
HOLD = 0.5   # the hold 6 dB under the walk ("and go down in volume")

# The jam's rhythms (Ryan, 30 October): the two he kept of the second round's grooves and his four
# from the Melody Desk, a bar's hits in sixteenths. The third round's pull-backs are gone (the root
# held under a pickup was "too jarringly slow"); the hold under both synth lines makes the room.
RHYTHMS = {
    "332": "x..x..x.x..x..x.",       # three, three, two
    "gallop": "x.xx..x.x.xx..x.",    # pairs of sixteenths pushing into the beat
    "pairs": "xx.xx.xx.xx.x.x.",     # his first
    "offbeats": "xx.x.x.x.x.xx.x.",  # his second
    "bursts": "xxx..x.x.x..xxx.",    # his third
    "threes": "xxx..xxx..x.xxx.",    # his fourth
    "quarters": "x...x...x...x...",  # a walk in quarters: the lower bass's own line under the upper's phrases in R's duel
}

# Each rhythm's figures: the line's notes on its hits as steps along E minor from the bar's chord
# root (0 the root, 4 its fifth, 7 its octave), "A" and "V" a semitone under and over the next
# chord's root, "b" the blues note (E minor's flat fifth, for E's bars alone).
FIGURES = {
    "332": {"home": [0, 0, 0, 0, 0, 0], "lift": [0, 0, 7, 0, 4, "A"], "climb": [0, 2, 3, 4, 6, 7]},
    "gallop": {"drive": [0, 0, 0, 7, 0, 0, 0, "A"], "octs": [0, 7, 7, 0, 0, 7, 7, "V"], "walk": [0, 0, 2, 3, 4, 4, 6, "A"]},
    "pairs": {"pops": [0, 7, 0, 7, 0, 7, 0, 7, 4, "A"], "stairs": [0, 0, 2, 2, 3, 3, 4, 4, 6, "A"], "fall": [7, 7, 6, 6, 4, 4, 2, 2, 0, "V"]},
    "offbeats": {"run": [0, 0, 2, 3, 4, 6, 7, 4, "A"], "zigzag": [0, 7, 0, 6, 0, 4, 0, 2, "A"], "blues": [0, 0, 2, 3, "b", 4, 6, 7, "A"]},
    "bursts": {"turn": [0, 1, 0, 4, 6, 7, 6, 4, "A"], "chug": [0, 0, 0, 7, 0, 7, 0, 0, "A"], "rise": [0, 2, 4, 7, 4, 2, 0, 2, "A"]},
    "threes": {"octs": [0, 0, 7, 0, 0, 7, 4, 0, 0, "A"], "steps": [0, 2, 3, 4, 3, 2, 7, 6, 4, "A"], "climb": [0, 0, 0, 2, 2, 2, 4, 6, 7, "A"]},
    "quarters": {"walk": [0, 2, 4, "A"]},
}

# The battle half in turns of two bars (Ryan, 30 October: "Jam session, everybody gets a turn, we
# keep it moving, we try different additions at different points"): what the guitar and the bass
# play, a rhythm and its figure (the walk) or the hold, and the synth lines over it, the walk with
# the arpeggio or the hook, never both; the intro sets the tone on three-three-two and never walks
# (Ryan, 30 October: "not straying too far from 3-3-2 - its setting the tone"; "3-3-2 all through
# wins"). A synth line's turn names its voicing after the colon (VOICINGS). The chords run Em C D Bm
# Em A G D through A, C and R, E minor through the intro, Em Em D G through D and Em C Bm Em through
# the outro; the breakdown (B) keeps its own voices.
TURNS = {
    "I": [("332.home", ""), ("332.home", ""), ("332.home", "arp:high"), ("332.home", "arp:high")],   # on the root: "Intro I shouldn't walk"
    "A": [("hold", "both:push")] * 4 + [("offbeats.run", "hook:back"), ("gallop.drive", "hook:back"), ("bursts.rise", "hook:back"), ("threes.octs", "hook:back")],
    "C": [("332.lift", ""), ("pairs.pops", ""), ("gallop.walk", ""), ("threes.climb", ""),   # under the lead guitar's long notes
          ("offbeats.zigzag", "arp:back"), ("bursts.chug", "arp:back"), ("pairs.stairs", "arp:back"), ("threes.steps", "arp:back")],
    "D": [("332.home", "")] * 4,
    "R": [("rest", "")] * 8,   # the duel's (DUEL): its two basses and its backing are their own voices
    "O": [("hold", "both:high")] * 4,
}
# The synth lines' voicings, (the arpeggio's voice, the hook's), each picked for its job (Ryan, 30
# October: "When the arpeggio is taking a backseat, the synth lead works best. When we want to push
# the hook, the swapped version is best. When we want to highlight the arpeggio, either the plucked
# or tine are great ... The plucked is certainly more unique"): the arpeggio behind on the synth
# lead, the hook pushed on the synth lead over the arpeggio on the FM synth, the arpeggio
# highlighted on the plucked string, the hook otherwise on the FM synth.
VOICINGS = {"back": ("lead", "fm"), "push": ("fm", "lead"), "high": ("pluck", "fm")}
UP = "R"   # the later spot where the guitar leaves the bass's octave ("save the octave-up for a later spot")

# D, the dark synth's section, plays Hold The Line's first riff, which the map half voices as a nod
# (the crunch synth dark and low) and the battle's first rounds voiced as Hold The Line's own riff
# section (the riff on the driven bass and the crunch synth over the guitar's chug, the gallop on
# the kick, a double-kick run out). Ryan, 30 October: "night shift D is a subtle nod to Hold the
# Line in the Map version, but essentially a straight copy in the battle version. It needs to do
# something different." So the riff goes back to the map's nod and D takes a turn of its own, on
# Night Shift's four on the floor with the map's sixteenths on the hat: the house piano stabbing
# the chords in three-three-two over the hold ("piano"), the riff alone on the crunch synth an
# octave up answered by the walk two bars at a time ("trade"), or the industry's knocks, clanks
# and ticks on three-three-two over the hold ("factory"); "copy" is the fourth round's. The hold is
# the head's, 6 dB down, since the turn is another voice's. The chords run Em Em D G twice.
D_TURNS = {
    "copy": [("332.home", "")] * 4,
    "piano": [("hold", "")] * 4,
    "trade": [("rest", ""), ("pairs.pops", ""), ("rest", ""), ("threes.climb", "")],
    "factory": [("hold", "")] * 4,
    "blend": [("hold", "")] * 4,
}
# The piano's turn and the factory's blended (Ryan, 30 October: "can we blend the piano take with
# the factory take (elegantly)?"; 31 October: "go blended for D"): the piano's three-three-two a
# little under its own turn, the knocks in its gaps a step before each of its hits, a clank every
# second bar, the ticks soft.
D_PLAN = "blend"
D_BASS = False   # the bass out of D's hold (Ryan, 4 November: "The bass 3-3-2s in D don't make sense, they cause a bad kind of discord, I think the piano can carry that rhythm on its own")
PIANO_BLEND = 0.5
BLEND_KNOCK = "..c..c....c..c.."
BLEND_CLANK = "." * 16 + ".......c........"
BLEND_TICK = "5" * 16
# Each turn's levels keep D within about 2 dB of the fourth round's on a phone's speaker, since a
# battle half holds its level (the bible's pair row): the piano and the industry lead their turns,
# the nod sits 5 dB under the piano, the call meets the walk's answers.
NOD = {"gain": 0.67, "hold": 1.0, "params": {"drive": 2.5, "cutoff": 600.0}}   # the map's dark synth, opened a little for a phone
PIANO_D = 0.6   # each of the piano's three chord tones
CALL = 0.55   # the riff's call when D trades
FACTORY = "h"   # the industry's hits when D is the factory's, 1.8 of full
D_DRUMS = 1.4   # the kit in D on four on the floor, which strikes the kick less often than the gallop did
# The guitar over the bass in the later spot (Ryan, 30 October: "can we do a two-octave separation
# instead of messing with volumes?"; 31 October: "The octave split - still isn't doing it for me.
# Maybe octave isnt the right call after all. Try 5ths and some others?"): the walk's notes moved by
# an interval, (the guitar's octave, the move in semitones, or ("steps", k) along E minor with a note
# off the scale moved a minor third), at the unison guitar's level.
SPLITS = {
    "octave": (0, 0),            # the third round's
    "two octaves": (1, 0),       # the seventh's
    "fifth": (-1, 7),            # in the bass's own register: the power chord's fifth
    "fourth": (-1, 5),
    "tenth": (0, ("steps", 2)),  # an octave and a third, the twin guitars' harmony
    "twelfth": (0, 7),           # an octave and a fifth
}
UP_SPLIT = "tenth"   # Ryan, 2 November: "the tenth up is good"
UP_GAIN = 0.45
# The driven bass down wherever it plays (Ryan, 2 November: "maybe bring the bass down 3db.
# Actually I'd like to hear the whole track with driven bass down 3 db everywhere").
BASS_DB = -3.0
ARP = "0123432101234321"   # up and down two octaves of the chord in sixteenths

# The synth lines' voices (Ryan, 30 October: "The hook is hard to hear over the arpeggios. Maybe
# instead of lead an octave up, another voice?"): the arpeggio two octaves up and the hook an octave
# under the chime, each new voice at the phone level of the line's fourth-round voice.
ARP_VOICES = {
    "lead": {"inst": "lead", "gain": 0.16},      # the synth lead, the fourth round's
    "fm": {"inst": "synlead", "gain": 0.14},     # the FM synth
    "pluck": {"inst": "pluck", "gain": 0.64},    # a plucked string
}
# The plucked string down wherever the arpeggio takes it (Ryan, 4 November: "Plucked guitar needs to
# be a bit quieter whenever it's used, it pierces so it sounds loud"). At 0.64 it met the synth lead
# on a phone and in full within a third of a dB, and read 1.6 dB over it by the ear's weighting
# (BS.1770's), its 2 to 5 kHz 6 dB hotter than the synth lead's.
PLUCK_DB = -3.0   # his call (4 November: "Plucked string -3Db is good")
HOOK_VOICES = {
    "fm": {"inst": "synlead", "gain": 0.28},     # the FM synth, the fourth round's
    "lead": {"inst": "lead", "gain": 0.25},      # the synth lead
}
SYNTH_PARTS = tuple("arp:" + v for v in ARP_VOICES) + tuple("hook:" + v for v in HOOK_VOICES)

SCALE = (0, 2, 3, 5, 7, 8, 10)   # E natural minor, the track's key
GHOST = 0.7   # a group's sixteenths after its first, 3 dB under it


def along(home, d):
    """The note `d` steps along E minor from a chord's root."""
    o, pc = divmod(home, 12)
    k = SCALE.index(pc) + d
    return 12 * o + SCALE[k % 7] + 12 * (k // 7)


def moved(pat, by):
    """A riff pattern's notes moved `by` semitones, or along E minor by ("steps", k), a note off the
    scale (an approach note, the blues note) a minor third."""
    out = []
    for c in pat:
        if c in ".-":
            out.append(c)
            continue
        n = int(c) if c.isdigit() else F.NOTE[c]
        if isinstance(by, int):
            out.append(P.spell(n + by))
        else:
            out.append(P.spell(along(n, by[1]) if n % 12 in SCALE else n + 3))
    return "".join(out)


def jam_bar(choice, home, next_home):
    """One bar of the walk on a chord's root (in the line's first octave, E to D#) before the next
    bar's: (step, note, steps to the next hit, accented) for each hit. A hit is accented when it
    opens a group of sixteenths or falls on a beat."""
    rhythm, _, fig = choice.partition(".")
    hits = [i for i, c in enumerate(RHYTHMS[rhythm]) if c == "x"]
    notes = FIGURES[rhythm][fig]
    if len(notes) != len(hits):
        raise ValueError("%s has %d notes for %d hits" % (choice, len(notes), len(hits)))
    if "b" in notes and home != 0:
        raise ValueError("%s: the blues note is E minor's" % choice)
    out = []
    for j, (h, t) in enumerate(zip(hits, notes)):
        n = next_home - 1 if t == "A" else next_home + 1 if t == "V" else home + 6 if t == "b" else along(home, t)
        room = (hits[j + 1] if j + 1 < len(hits) else 16) - h
        out.append((h, n, room, j == 0 or hits[j - 1] != h - 1 or h % 4 == 0))
    return out


def form_roots(call):
    """The call's form and each bar's chord root, a section's chords read from its run's start."""
    form = call["form"].replace(" ", "")
    roots, run_start = [], 0
    for k, sec in enumerate(form):
        if k > 0 and form[k - 1] != sec:
            run_start = k
        chords = call["chords"][sec]
        roots.append(chords[(k - run_start) % len(chords)][0])
    return form, roots


BAND_PARTS = ("walk", "ghost", "bass_walk", "bass_ghost", "hold_guitar", "hold_bass", "stop_guitar", "stop_bass")


def turn_parts(call, turns, hold="332"):
    """The turns' patterns by section, {part: {section: pattern}}: the walk split into its accented
    hits ("walk") and the rest ("ghost"), on the bass alone where a turn's choice is "bass:" and a
    figure ("bass_walk", "bass_ghost"); the hold's guitar and bass; stop-time's hits on each bar's
    one ("stop"); and the bars the arpeggio and the hook play. A walking note holds two steps where
    it has room."""
    form, roots = form_roots(call)
    out = {key: {} for key in BAND_PARTS + SYNTH_PARTS}
    rest = "." * 16
    for k, sec in enumerate(form):
        if sec not in turns or (k > 0 and form[k - 1] == sec) or sec in out["walk"]:
            continue
        n = 1
        while k + n < len(form) and form[k + n] == sec:
            n += 1
        if n > 2 * len(turns[sec]):
            raise ValueError("%s runs %d bars on %d turns" % (sec, n, len(turns[sec])))
        hook = P.part(call, "chime_metal", sec, mode="chord") if any(t.split(":")[0] in ("hook", "both") for _c, t in turns[sec]) else rest
        bars_ = {key: [] for key in out}
        for i in range(n):
            choice, synth = turns[sec][i // 2]
            synth, _, voicing = synth.partition(":")
            arp_voice, hook_voice = VOICINGS[voicing or "back"]
            root, next_root = roots[k + i], roots[(k + i + 1) % len(form)]
            played = {}
            if choice == "rest":
                pass
            elif choice == "hold":
                guitar, bass = HOLDS[hold]
                played = {"hold_guitar": guitar(root, next_root), "hold_bass": bass(root, next_root)}
            elif choice == "stop":
                hit = P.spell(root % 12) + "--" + "." * 13
                played = {"stop_guitar": hit, "stop_bass": hit}
            elif synth == "both":
                raise ValueError("%s %s: the walk takes the arpeggio or the hook, never both" % (sec, choice))
            else:
                alone, _, fig = choice.rpartition(":")
                for key, acc in (("walk", True), ("ghost", False)):
                    bar = ["."] * 16
                    for h, note, room, accented in jam_bar(fig, root % 12, next_root % 12):
                        if accented == acc:
                            bar[h] = P.spell(note)
                            for q in range(1, min(room, 2)):
                                bar[h + q] = "-"
                    played[("bass_" if alone == "bass" else "") + key] = "".join(bar)
            for key in BAND_PARTS:
                bars_[key].append(played.get(key, rest))
            for v in ARP_VOICES:
                bars_["arp:" + v].append(ARP if synth in ("arp", "both") and v == arp_voice else rest)
            for v in HOOK_VOICES:
                bars_["hook:" + v].append(hook[16 * i % len(hook):][:16] if synth in ("hook", "both") and v == hook_voice else rest)
        for key in out:
            out[key][sec] = "".join(bars_[key])
    return out


# ---------------------------------------------------------------- R, the duel

# R's sixteen bars run Em C D Bm Em A G D twice, bars counted from 0 here: a duel between two basses
# (Ryan, 5 November: "I think we need to rewrite it again, into more of a dueling basses type jam. The
# stop time was cool, we can do more of that unexpected kind of thing. The backing instruments trading
# tunes around was cool too, just keep their volumes consistent so they don't overshadow the basses
# when they're doing their thing"). The track's bass and a second bassist an octave over it trade
# phrases on his rhythms, the answer often the call's rhythm on another figure: two bars each, then a
# bar each, then half a bar each, through two bars of stop-time where the band hits each bar's one
# with both basses on its root and one bass fills the gap alone, and a hole where the whole band drops
# out on a bar's last beat; then the two together on three-three-two under the band's hits and
# climbing into the outro in octaves. One plays at a time until the last two bars, so the duel reads
# in mono by register and voice: the first on the fingers into the modern drive (BASS), the second an
# octave up on the active bass near the bridge into the same drive (DUEL_B2; The Omnific's two basses).
# The backing trades the tune over them as the sixteenth round's R did, every voice at one level a
# margin under the basses (DUEL_BACKING): the hook on the synth lead then the FM synth, each answered
# a chord tone higher; the house piano on the hook's rhythm; the plucked string's arpeggio; the hook
# on each in the bar-each trades; the chime's hook with the band's hits; the piano's off-beats under
# the trades. The sub rests through R: two basses are the low end.
DUEL = [   # each bar's phrases: (bass, rhythm.figure, the steps it plays from and to)
    ((1, "pairs.pops", 0, 16),),                                  # the first bass calls
    ((1, "pairs.stairs", 0, 16),),
    ((2, "pairs.fall", 0, 16),),                                  # the second answers on the call's rhythm, falling
    ((2, "pairs.pops", 0, 16),),
    ((1, "gallop.drive", 0, 16),),                                # the call again, galloping
    ((1, "gallop.walk", 0, 16),),
    ((2, "gallop.octs", 0, 16),),                                 # answered in octaves
    ((2, "threes.steps", 0, 16),),
    ((1, "bursts.turn", 4, 16),),                                 # stop-time: after the band's hit the first bass fills alone
    ((2, "bursts.rise", 4, 16),),                                 # then the second
    ((1, "threes.climb", 0, 16),),                                # a bar each
    ((2, "threes.steps", 0, 16),),
    ((1, "offbeats.blues", 0, 8), (2, "offbeats.run", 8, 16)),    # half a bar each: up to the blues note, answered home
    ((1, "offbeats.zigzag", 0, 8), (2, "offbeats.zigzag", 8, 12)),   # the hole after the second's two notes
    ((1, "332.lift", 0, 16), (2, "332.lift", 0, 16)),             # together, under the band's hits
    ((1, "threes.climb", 0, 16), (2, "threes.climb", 0, 16)),     # climbing into the outro in octaves
]
DUEL_STOPS = (8, 9)   # the band on each bar's one, both basses on its root, then one bass alone
DUEL_HOLE = (13, 12)   # the bar, and the step from which the whole band rests
DUEL_HITS = 14   # the band's hits on three-three-two with both basses
DUEL_TOGETHER = (14, 15)
DUEL_OCTAVE = {1: -1, 2: 0}   # the second bass an octave over the first
# Each voice alone over the bars it plays, against the first bass on a phone and in full, met halfway:
# the second bass an octave up (the Omnific's 1.4 dB each way, the fingers' 0.7), and each backing
# voice brought to the first bass's level before its margin under it. At their sixteenth-round gains
# the synth lead stood 2.2 dB over the bass on a phone, the FM synth 4.1 and the plucked string 2.8,
# where the house piano, the chime and the off-beats sat 5 to 8 dB under it.
DUEL_B2 = {"real_omnific": 0.634, "real_modern": 0.749}
DUEL_BACKING = 3.0   # the backing's margin under the basses, in dB (Ryan, 5 November: "Keep the backing voices at the 3db under, that works")
# The lower bass under the upper's phrases (Ryan, 5 November: "don't cut out the lower one when the upper
# comes in, since it sounds fragmented and empty without the lower end. So that means: -copy the upper
# line in lowered unison, and/or -play a backing rhythm, and/or, -play a complimentary line"): the upper's
# line an octave down ("unison"), three-three-two on the roots ("rhythm"), or a walking line of its own
# in quarters ("line"), each 3 dB under its own phrases so the answer stays on top; under a stop's
# fill its root held from the band's hit, the stop's gap kept, but in unison, where it doubles the fill.
# And the upper bass in chords ("We could also try what the upper bass line sounds like doing chords
# instead"): each note with its fifth, two strings into one amp, met halfway with its single notes.
DUEL_SUPPORT = "unison"
SUPPORT_DB = -3.0
DUEL_CHORDS = 0.786   # the upper bass in chords against its single notes: at one gain 2.2 dB over on a phone, 2.0 in full
DUEL_LEVELS = {"lead": 0.915, "fm": 0.722, "piano": 2.241, "pluck": 0.877, "chime": 2.165, "offbeats": 1.932}   # each within 1.6 dB each way
PIANO_TURN = ("x...x.x.....x...", "x..x..x.x..x..x.")   # the house piano on the hook's rhythm, then on three-three-two
STOP_HIT = "x" + "." * 15
PIANO_OFFBEAT = 0.165   # each of the house piano's three chord tones at the off-beats' level (the sixteenth round's)
HITS_332 = "x..x..x.x..x..x."


def r_bars(bars):
    """A pattern through R's sixteen bars: {bar: its sixteen steps}, rests elsewhere."""
    return "".join(bars.get(b, "." * 16) for b in range(R_BARS))


def r_tiled(pat, keep):
    """A pattern repeated through R's sixteen bars, kept only in the bars `keep` passes."""
    whole = (pat * (16 * R_BARS // len(pat) + 1))[:16 * R_BARS]
    return "".join(whole[16 * b:16 * b + 16] if keep(b) else "." * 16 for b in range(R_BARS))


def holed(pat):
    """A pattern through R with the hole's steps rested."""
    b, s = DUEL_HOLE
    return pat[:16 * b + s] + "." * (16 - s) + pat[16 * (b + 1):]


def degrees_up(pat, k):
    """A chord-mode pattern's degrees `k` higher: a line moved up its chords' tones."""
    return "".join(str(int(c) + k) if c.isdigit() else c for c in pat)


def duel_lines(call, support=DUEL_SUPPORT):
    """Each bass's line through R, split as the walk is into its accented hits and the rest:
    {(bass, "walk" or "ghost"): pattern}, with the first bass's part under the second's phrases as
    bass "support" (DUEL_SUPPORT). A stop bar opens on both basses' root, held three steps, or under
    the second's fill held through the gap where the support is "rhythm" or "line"."""
    roots = [c[0] for c in call["chords"]["R"]]
    out = {(b, k): [] for b in (1, 2, "support") for k in ("walk", "ghost")}

    def place(cells, key, choice, root, next_root, lo, hi):
        for h, note, room, accented in jam_bar(choice, root % 12, next_root % 12):
            if lo <= h < hi:
                row = cells[key, "walk" if accented else "ghost"]
                row[h] = P.spell(note)
                for q in range(1, min(room, 2, hi - h)):
                    row[h + q] = "-"

    for bar, phrases in enumerate(DUEL):
        root, next_root = roots[bar % len(roots)], roots[(bar + 1) % len(roots)] if bar + 1 < R_BARS else call["chords"]["O"][0][0]
        cells = {key: ["."] * 16 for key in out}
        if bar in DUEL_STOPS:
            for b in (1, 2):
                cells[b, "walk"][0:3] = [P.spell(root % 12), "-", "-"]
        for bass, choice, lo, hi in phrases:
            place(cells, bass, choice, root, next_root, lo, hi)
        for bass, choice, lo, hi in phrases if support else ():
            if bass != 2 or any(b == 1 and lo1 < hi and lo < hi1 for b, _c, lo1, hi1 in phrases):
                continue   # the first bass plays there itself
            if support == "unison":
                for key in ("walk", "ghost"):
                    cells["support", key][lo:hi] = cells[2, key][lo:hi]
            elif bar in DUEL_STOPS:
                cells[1, "walk"][3:16] = ["-"] * 13   # the root held through the gap under the fill
            else:
                place(cells, "support", "332.home" if support == "rhythm" else "quarters.walk", root, next_root, lo, hi)
        for key in out:
            out[key].append("".join(cells[key]))
    return {key: "".join(v) for key, v in out.items()}


def duel_voices(call, b2="real_omnific", backing_db=DUEL_BACKING, bass_db=BASS_DB, levels=None, b2_level=None,
                support=DUEL_SUPPORT, chords=False, chords_level=None):
    """R's voices: the two basses (the first as the track's bass, the second on `b2` an octave up at
    its level against the first, DUEL_B2, in chords where `chords`, DUEL_CHORDS), the first's part under
    the second's phrases (`support`, DUEL_SUPPORT, SUPPORT_DB) and the backing trading the tune over
    them, each at the basses' level `backing_db` under (DUEL_LEVELS)."""
    lv = dict(DUEL_LEVELS, **(levels or {}))
    under = 10.0 ** (-backing_db / 20.0)
    bv1, bv2 = BASS_VOICES[BASS], BASS_VOICES[b2]
    g1 = 0.27 * 10.0 ** (bass_db / 20.0) * bv1["level"]
    g2 = g1 * (DUEL_B2[b2] if b2_level is None else b2_level) * ((DUEL_CHORDS if chords_level is None else chords_level) if chords else 1.0)
    lines = duel_lines(call, support)
    voices = []
    for bass, (bv, g, params) in ((1, (bv1, g1, dict(bv1["params"]))), (2, (bv2, g2, dict(bv2["params"], fifth=chords))),
                                  ("support", (bv1, g1 * 10.0 ** (SUPPORT_DB / 20.0), dict(bv1["params"])))):
        for key, k in (("walk", 1.0), ("ghost", GHOST)):
            voices.append({"inst": bv["inst"], "params": params, "mode": "riff", "gain": g * k, "hold": 0.9,
                           "octave": DUEL_OCTAVE[1 if bass == "support" else bass], "pat": {"R": lines[bass, key]},
                           "duel": "support" if bass == "support" else "bass%d" % bass})
    hook = P.part(call, "chime_metal", "R", mode="chord")
    up = degrees_up(hook, 1)
    offbeats = P.part(call, "epiano", "R", mode="stab")

    def recipe(inst):
        # the recipe's own R voice's settings (the chime's echo, the piano's length), its patterns aside
        return {k: w for k, w in next(v for v in call["voices"] if v["inst"] == inst and "R" in v["pat"]).items() if k != "pat"}
    backing = [
        ("lead", dict(HOOK_VOICES["lead"], mode="chord", octave=1, dur=3.0, pat={"R": r_bars({0: hook, 1: up, 10: hook})})),
        ("fm", dict(HOOK_VOICES["fm"], mode="chord", octave=1, dur=3.0, pat={"R": r_bars({2: hook, 3: up, 11: up})})),
        ("pluck", dict(ARP_VOICES["pluck"], mode="chord", octave=2, dur=1.4, pat={"R": r_bars({6: ARP, 7: ARP})})),
        ("chime", dict(recipe("chime_metal"), gain=0.2, pat={"R": r_bars({b: hook for b in DUEL_TOGETHER})})),
        ("offbeats", dict(recipe("epiano"), pat={"R": holed(r_tiled(offbeats, lambda b: b not in DUEL_STOPS + DUEL_TOGETHER + (4, 5)))})),
    ] + [("piano", {"inst": "epiano", "mode": "chord", "octave": 1, "gain": PIANO_OFFBEAT, "dur": 1.5,
                    "pat": {"R": r_bars(dict([(4, PIANO_TURN[0].replace("x", str(k))), (5, PIANO_TURN[1].replace("x", str(k)))]
                                             + [(b, STOP_HIT.replace("x", str(k))) for b in DUEL_STOPS] + [(DUEL_HITS, HITS_332.replace("x", str(k)))]))}})
         for k in range(3)]
    for name, v in backing:
        voices.append(dict(v, gain=v["gain"] * lv[name] * under, duel=name))
    return voices


def duel_drums():
    """R's kit bar by bar under the duel: the groove under the trades, a crash and a china opening
    each turn; each stop's one alone with the hat keeping time, the second's snare build into the
    bar-each trades; the whole kit out from the hole's step; the band's hits on three-three-two with
    the basses, kick and snare together under a crash; a fill into the outro. The industry rests
    through the stops, the hole and the hits."""
    groove = lambda pat, b: pat[16 * (b % 8):16 * (b % 8) + 16]   # noqa: E731
    bars = {k: [] for k in ("kick", "snare", "hat", "crash", "china", "stack", "tom", "tom2", "knock", "tick", "clank")}
    for b in range(R_BARS):
        turn_start = b % 2 == 0
        if b in DUEL_STOPS:
            first = b == DUEL_STOPS[0]
            row = {"kick": STOP_HIT, "crash": STOP_HIT, "hat": "....x...x...x..." if first else "....x...x.......",
                   "snare": "." * 16 if first else "..........6.7.8x"}
        elif b == DUEL_HITS:
            row = {"kick": HITS_332, "snare": HITS_332, "crash": STOP_HIT, "china": "........x......."}
        else:
            last = b == R_BARS - 1
            row = {"kick": groove(GROOVE_KICK, b), "snare": groove(GROOVE_SNARE, b), "hat": "xxxxxxxx........" if last else "x" * 16,
                   "china": "........x......." if turn_start else "." * 16, "stack": "..x...x...x...x.",
                   "tom": FILL_TOM if last else "." * 16, "tom2": FILL_TOM2 if last else "." * 16,
                   "knock": "......x.......x.", "tick": "x" * 16, "clank": "..............x." if turn_start else "." * 16}
            if turn_start:
                row["crash"] = STOP_HIT
            if b == DUEL_HOLE[0]:
                row = {k: v[:DUEL_HOLE[1]] + "." * (16 - DUEL_HOLE[1]) for k, v in row.items()}
        for k in bars:
            bars[k].append(row.get(k, "." * 16))
    return {k: "".join(v) for k, v in bars.items()}


# ---------------------------------------------------------------- the bass

def slap_drive(f, dur):
    """A slapped bass a little driven (Ryan, 3 November: "a whole new voice that's more of a slightly
    distorted bass/slap bass"): the forge's slap (the thumb's thump, the string's snap against the
    frets, a quick decay) through one more asymmetric stage, an amp pushed a little, its growl lifted
    where a phone's speaker plays."""
    y = F.asat(F.slap_bass(f, dur) * 1.6, 2.2)
    return F.hp(F.lp(y + F.bp(y, 600.0, 1400.0) * 0.35, 5000.0), 45.0) * 0.8


F.NOTE_INST["slap_drive"] = lambda f, d, p: slap_drive(f, d)

# The clean bass (Ryan, 3 November, on the tenth round: "Can I get night shift battle with some clean
# bass options? Or at least only very slightly distorted?"). Measured on a sine at a note's peak, the
# driven bass's amp makes 39% harmonic distortion, the tenth round's slap a little driven 41%, the
# forge's plain slap 26% by its own clip and the synth bass's stage 17%; the clean voices make none,
# and the touch (TOUCH) about 5%, an amp just breaking up.
TOUCH = (0.5, 0.8)   # the touch of drive: the stage's input at the note's peak, and its drive


def evened(x, amount, most=4.0):
    """A compressor's evenness on one note, without saturation: the note's level followed (about
    13 ms) and pulled toward its loudest by `amount`, never more than `most` times up, so the line
    holds through each note's sustain."""
    env = np.maximum(F.lp(np.abs(x), 12.0), 0.0)
    env = np.maximum(env / (np.max(env) + 1e-9), 1e-4)
    return x * np.minimum(env ** -amount, most)


def amp(y, touch):
    """The amp: clean, or with a touch of drive (TOUCH), on a note brought to one peak first."""
    y = y / (np.max(np.abs(y)) + 1e-9) * TOUCH[0]
    return F.asat(y, TOUCH[1]) if touch else y


def finger_bass(f, dur, touch=False):
    """A finger bass: the driven bass's two strings, the finger's thump and the body's peak, evened
    as a compressor would, into the amp clean or with a touch of drive, then a tone open enough for
    the string's own overtones, which a phone plays where it plays little of the fundamental, and
    the driven bass's cabinet."""
    n = F.n_of(dur)
    bright = F.RNG.uniform(0.5, 0.62)
    x = F.pluck(f, dur, bright=bright, damp=0.998)[:n] + F.pluck(f * 1.001, dur, bright=bright * 0.6, damp=0.998)[:n] * 0.5
    x = x + F.bp(x, 80.0, 140.0) * 0.8
    thump = F.lp(F.noise(F.n_of(0.02)), 900.0) * F.env_ad(F.n_of(0.02), 0.0005, 0.006) * 0.5
    y = amp(evened(F.at(x, thump, 0.0)[:n], 0.45), touch)
    y = F.lp(y, 3200.0) + F.bp(y, 600.0, 1200.0) * 0.3
    return F.hp(F.bass_cabinet(y), 40.0)


def slap_clean(f, dur, touch=False):
    """A slapped bass with its clip taken out: the forge's slap (the thumb's thump, the string's
    bright snap against the frets, its quick decay), evened as a compressor would, into the same
    amp."""
    n = F.n_of(dur)
    x = F.pluck(f, dur, bright=0.95, damp=0.996)[:n]
    snap = F.bp(F.noise(F.n_of(0.01)), 2500.0, 9000.0) * F.env_ad(F.n_of(0.01), 0.0002, 0.002) * 0.9
    thump = F.lp(F.noise(F.n_of(0.025)), 700.0) * F.env_ad(F.n_of(0.025), 0.0005, 0.007) * 0.7
    y = amp(evened(F.at(F.at(x, snap, 0.0), thump, 0.0)[:n], 0.3), touch)
    return F.hp(F.lp(y, 4500.0), 50.0) * F.env_ad(n, 0.001, dur * 0.45, curve=2.0)


F.NOTE_INST["finger_bass"] = lambda f, d, p: finger_bass(f, d, p.get("touch", False))
F.NOTE_INST["slap_clean"] = lambda f, d, p: slap_clean(f, d, p.get("touch", False))

# Every part the driven bass plays on another voice, measured against it alone over the whole battle
# half (`level`). The slaps meet it on a phone's speaker and in full alike. The synth bass is dark: a
# phone plays little of it, so at the driven bass's level on a phone it would sit 6 dB over it in
# full, and at its level in full 6 dB under it on a phone; it sits between, 3 dB under on a phone and
# 3 dB over in full. The clean voices and their touch meet it on a phone and in full alike, within a
# fifth of a dB: the string's own overtones and the cabinet carry them on a phone as the amp carries
# the driven bass.
BASS_VOICES = {
    "driven": {"inst": "bass_real", "params": {"drive": 3.5}, "level": 1.0},           # the ninth round's
    "synth": {"inst": "bass", "params": {"drive": 2.5, "cutoff": 600.0}, "level": 2.29},   # the synth bass: the crunch synth dark and soft
    "slap": {"inst": "slap_drive", "params": {}, "level": 0.71},                       # a slapped bass a little driven
    "finger": {"inst": "finger_bass", "params": {}, "level": 9.10},                    # a finger bass, clean
    "finger_touch": {"inst": "finger_bass", "params": {"touch": True}, "level": 6.55}, # the finger bass with a touch of drive
    "slap_clean": {"inst": "slap_clean", "params": {}, "level": 11.51},                # the slap, clean
    "slap_touch": {"inst": "slap_clean", "params": {"touch": True}, "level": 8.25},    # the slap with a touch of drive
    # The real basses (real_bass.py; Ryan, 4 November: "Yes, build me some real bass options, please"),
    # each met halfway between the driven bass's level on a phone and in full as the synth bass is:
    # like it, each is darker than the driven bass, from 1.7 dB under it on a phone and over it in
    # full (near the bridge) to 4.6 (the flatwounds).
    "real_finger": {"inst": "real_bass", "params": {"preset": "finger", "amp": "di"}, "level": 6.75},   # fingers over the neck pickup, a direct box
    "real_bridge": {"inst": "real_bass", "params": {"preset": "bridge", "amp": "di"}, "level": 4.80},   # fingers near the bridge, its pickup
    "real_pick": {"inst": "real_bass", "params": {"preset": "pick", "amp": "di"}, "level": 6.06},       # a pick between the pickups
    "real_flat": {"inst": "real_bass", "params": {"preset": "flat", "amp": "di"}, "level": 8.71},       # flatwounds and a soft thumb, the tone rolled back
    "real_grit": {"inst": "real_bass", "params": {"preset": "finger", "amp": "grit"}, "level": 5.19},   # the fingers through an amp just breaking up
    # The fingers through an amp driven harder (Ryan, 4 November: "What happens if we distort it a
    # little? Will it take it? Can we achieve the 'omnific' sound?").
    # Each met halfway as the rest, phone and full closer the harder it is driven (from 1.7 dB each
    # way for a little more drive to 0.6 for the active bass).
    "real_dirt": {"inst": "real_bass", "params": {"preset": "finger", "amp": "dirt"}, "level": 3.37},        # a little more drive
    "real_driven": {"inst": "real_bass", "params": {"preset": "finger", "amp": "driven"}, "level": 1.80},    # driven, the mids pushed
    "real_modern": {"inst": "real_bass", "params": {"preset": "finger", "amp": "modern"}, "level": 2.07},    # the fingers into a modern prog drive
    "real_omnific": {"inst": "real_bass", "params": {"preset": "active", "amp": "modern"}, "level": 1.54},   # an active bass near the bridge into it
}
BASS = "real_modern"   # the full pair's (Ryan, 4 November: "go with the fingers-into-a-modern-drive-prog bass you built")
# The lead guitar's lines on the bass (Ryan, 4 November: "wherever there's a lead guitar, I want that
# bass instead playing the high lines"): the same bass an octave under the guitar, the top of a
# six-string bass (the lick runs to B5 at the guitar's octave, an octave past it), or at the guitar's
# own octave, a piccolo bass's; each met halfway with the lead guitar's level (0.5 dB each way an
# octave down, 0.1 at its octave).
LEAD = "bass"
LEAD_LEVEL = {"bass": 1.600, "piccolo": 1.297}

# The guitar's strings (Ryan, 4 November, of the eleventh round's clean basses: "Are these bass
# lines playing chords? Can I hear them as singles if so?"). The bass plays single notes; the guitar
# that walks the same line in unison plays every note as a power chord (root, fifth and octave), so
# the line sounds in chords over the bass. Then (4 November, of the twelfth round): "I think I know my
# issue now, I feel like this wants to just be a bass jam. Rip the guitar out from everything, as an
# experiment." GUITARS names, for each way, the guitar's parts that go to one string and the parts
# that go: the walk with its ghost notes and R's tenth ("walk", "up"), the hold under the two synth
# lines ("hold", whose chords were his own call of 30 October: "the walk needs to calm down back to
# holding the rhythm and chords like your first take"), the stop-time hits ("stop"), the breakdown's
# ringing chords ("ring"), and the lead guitar's lines ("lead": C's long notes, R's answer and lick).
GUITARS = {
    "chords": ((), ()),                                          # the eleventh round's power chords
    "walk": (("walk", "up"), ()),                                # the twelfth round's pair
    "all": (("walk", "up", "hold", "stop"), ()),
    "out": ((), ("walk", "up", "hold", "stop", "ring")),          # the rhythm guitar out of everything
    "breakdown": ((), ("walk", "up", "hold", "stop")),           # back in the breakdown alone (Ryan, 4 November: "Put the the rhythm guitar back in on B")
    "none": ((), ("walk", "up", "hold", "stop", "ring", "lead")),  # every guitar out, the lead guitar's lines too
}
GUITAR = "breakdown"   # the full pair's
ONE_LEVEL = 1.0   # pushed as hard, the one string meets the power chords on a phone and in full alike (measured over the whole battle half: within a tenth of a dB)
# The guitar on one string (guitar_one) is pair_sketches', shared with Hold The Line's sketches.


def battle_half(call, turns=None, hold="332", split=UP_SPLIT, d=D_PLAN, bass_db=BASS_DB, bass=BASS, guitar=GUITAR,
                d_bass=D_BASS, pluck_db=PLUCK_DB, lead=LEAD, duel_b2="real_omnific", duel_backing=DUEL_BACKING,
                duel_support=DUEL_SUPPORT, duel_chords=False):
    """Night Shift's battle half: see the module's notes. `hold` is what the guitar and the bass play
    under the hook and the arpeggio together; `split` the guitar's interval over the bass in the
    later spot (SPLITS); `d` D's turn; `bass_db` the bass's level, wherever it plays; `bass` its
    voice (BASS_VOICES); `guitar` which of the guitar's parts go to one string and which go (GUITARS);
    `d_bass` the bass in D's hold or not; `duel_b2` R's second bass (BASS_VOICES), `duel_backing`
    the backing's margin under the basses there (DUEL_BACKING), `duel_support` the first bass's part
    under the second's phrases (DUEL_SUPPORT) and `duel_chords` the second in chords; `pluck_db` the plucked
    string's level, wherever it plays; `lead` the lead guitar's lines on the guitar or on the bass
    (LEAD_LEVEL's ways)."""
    up_octave, by = SPLITS[split]
    one, out = GUITARS[guitar]

    def strings(part, v):
        # The guitar's part on one string where `guitar` says so: the voice stays in its place in
        # the list, so every other voice keeps its seed.
        if part in out:
            return dict(v, pat={})
        if part == "lead" and lead != "guitar":
            b = BASS_VOICES[bass]
            return dict(v, inst=b["inst"], params=dict(b["params"]), gain=v["gain"] * LEAD_LEVEL[lead],
                        octave=v.get("octave", 0) - (1 if lead == "bass" else 0))
        return dict(v, inst="guitar_one", gain=v["gain"] * ONE_LEVEL) if part in one else v
    p = lambda *a, **k: P.part(call, *a, **k)   # noqa: E731
    riff = p("bass", "D", gain=0.34)
    voices = []
    for v in call["voices"]:
        inst, v = v["inst"], dict(v)
        if inst in ("guitar_real", "bass"):
            continue   # the mechanical guitar and the crunch synth's dark roots and riff: the walk, the hold and the riff below
        if inst == "brass":
            v["gain"] = 0.24
        elif inst == "chime_metal":
            v["gain"] = 0.2
        elif inst == "sub_bass" and "A" in v["pat"]:
            v["gain"] = 0.24   # the pulse under the line
        elif inst == "lead":
            v.update(inst="lead_real", gain=0.3)
            v = strings("lead", v)
        if "R" in v["pat"]:
            # R is the duel's: the recipe's own R parts (the sub's pulse, the piano's off-beats, the
            # chime's hook) rest, the duel's backing taking the piano's and the chime's.
            v["pat"] = {sec: x for sec, x in v["pat"].items() if sec != "R"}
        voices.append(v)
    parts = turn_parts(call, dict(turns or TURNS, D=D_TURNS[d]), hold)
    hold_bass = dict(parts["hold_bass"])
    if not d_bass:
        hold_bass.pop("D", None)   # the piano carries D's three-three-two alone
    bass_walk = {"walk": dict(parts["walk"]), "ghost": parts["ghost"]}
    for key, g in (("walk", 1.0), ("ghost", GHOST)):
        # The guitar palm-muted and the driven bass in unison through the walk, a group's first
        # sixteenth on top: the guitar on its interval over the bass in the later spot, the bass on
        # the riff in D, and on its own in the bass's turn.
        voices += [
            strings("walk", {"inst": "guitar_real", "mode": "riff", "gain": 0.45 * g, "octave": -1, "pat": {s: x for s, x in parts[key].items() if s != UP}}),
            {"inst": "bass_real", "mode": "riff", "gain": 0.27 * g, "hold": 0.9, "octave": -1, "params": {"drive": 3.5},
             "pat": {s: x for s, x in bass_walk[key].items() if s != "D" or d != "copy"}},
            strings("up", {"inst": "guitar_real", "mode": "riff", "gain": UP_GAIN * g, "octave": up_octave, "pat": {s: moved(x, by) for s, x in parts[key].items() if s == UP}}),
            {"inst": "bass_real", "mode": "riff", "gain": 0.27 * g, "hold": 0.9, "octave": -1, "params": {"drive": 3.5}, "pat": parts["bass_" + key]},
        ]
    voices += [
        # The hold under the hook and the arpeggio together.
        strings("hold", {"inst": "guitar_real", "mode": "riff", "gain": 0.45 * HOLD, "octave": -1, "pat": parts["hold_guitar"]}),
        {"inst": "bass_real", "mode": "riff", "gain": 0.27 * HOLD, "hold": 0.9, "octave": -1, "params": {"drive": 3.5}, "pat": hold_bass},
        # Stop-time's hits: the guitar let ring and the bass on each bar's one.
        strings("stop", {"inst": "guitar_real", "mode": "riff", "gain": 0.45, "octave": -1, "hold": 1.0, "params": {"mute": False}, "pat": parts["stop_guitar"]}),
        {"inst": "bass_real", "mode": "riff", "gain": 0.27, "hold": 1.0, "octave": -1, "params": {"drive": 3.5}, "pat": parts["stop_bass"]},
        # The riff in D (on the driven bass and the crunch synth as the fourth round had it, the
        # map's dark synth alone, or the crunch synth alone two bars in four), held roots through
        # the breakdown.
        {"inst": "bass_real", "mode": "riff", "gain": 0.38, "hold": 1.1, "params": {"drive": 3.5}, "pat": {"D": riff} if d == "copy" else {}},
        {"inst": "bass", "mode": "riff", "gain": 0.3, "hold": 1.0, "params": {"drive": 3.5, "cutoff": 900.0}, "pat": {"D": riff}} if d == "copy" else
        dict(NOD, inst="bass", mode="riff", pat={"D": riff}) if d in ("piano", "factory", "blend") else
        {"inst": "bass", "mode": "riff", "gain": CALL, "octave": 1, "hold": 1.0, "params": {"drive": 3.5, "cutoff": 1200.0}, "pat": {"D": riff + "." * 32}},
        {"inst": "bass_real", "mode": "riff", "gain": 0.32, "legato": True, "params": {"drive": 3.5}, "pat": {"B": p("sub_bass", "B")}},
        # Ringing chords through the breakdown.
        strings("ring", {"inst": "guitar_hold", "mode": "stab", "gain": 0.55, "dur": 16, "pat": {"B": "x..............."}}),
        # The synth lines by turns, each voice in the bars its voicing gives it: the arpeggio, up
        # and down two octaves of each chord in sixteenths, and the chime's hook an octave under it.
    ] + [dict(ARP_VOICES[v], gain=ARP_VOICES[v]["gain"] * (10.0 ** (pluck_db / 20.0) if v == "pluck" else 1.0),
              mode="chord", octave=2, dur=1.4, pat=parts["arp:" + v]) for v in ARP_VOICES] + [
        dict(HOOK_VOICES[v], mode="chord", octave=1, dur=3.0, pat=parts["hook:" + v]) for v in HOOK_VOICES]
    # D's piano: the house piano's chord, each tone a voice an octave up, stabbing three-three-two.
    voices += [{"inst": "epiano", "mode": "chord", "octave": 1, "gain": PIANO_BLEND if d == "blend" else PIANO_D, "dur": 1.5,
                "pat": {"D": THREE_THREE_TWO.replace("r", str(k))} if d in ("piano", "blend") else {}} for k in range(3)]
    voices += [{k: w for k, w in v.items() if k != "duel"} for v in duel_voices(call, duel_b2, duel_backing, bass_db, support=duel_support, chords=duel_chords)]
    bv = BASS_VOICES[bass]
    voices = [dict(v, inst=bv["inst"], params=bv["params"], gain=v["gain"] * 10.0 ** (bass_db / 20.0) * bv["level"]) if v["inst"] == "bass_real" else v for v in voices]
    drums = {
        "kick": {"I": "x...x...x...x..." * 7 + "x...x...x.......", "A": GROOVE_KICK, "C": LEAD_KICK,
                 "B": "x.....x...x....." * 6 + "x...x...x...x..." + "x.x.x.x.x.x.x.x.",
                 "D": "x.xx..x.x.xx..x." * 3 + "x.xx..x.x.xx.xx." + "x.xx..x.x.xx..x." * 2 + "x.xx.xx.x.xx.xx." + "x...x...x.......",
                 "O": bars("x...x...x...x..x", "x...x..xx...x...") * 4},
        "kick_hard": {"D": "." * 120 + "xxxxxxxx"},   # a double-kick run out of the riff
        "snare": {"I": "....x.......x..." * 8, "A": GROOVE_SNARE, "C": GROOVE_SNARE,
                  "B": "........x......." * 6 + "4.4.5.5.6.6.7.7." + "5566778899xxxxxx",   # half time, then a build
                  "D": "....x..o.o..x..o" * 7 + "....x.......x.x.",
                  "O": bars("....x..o....x..o", "....x..o.o..x...") * 4},
        "hat": {"I": HATS, "A": HATS, "O": "xx.xxx.xxx.xxx.x",
                "B": "x.x.x.x.x.x.x.x." * 6 + "." * 32, "D": "x" * 120 + "........"},
        "open": {"I": OPENS, "A": OPENS, "O": "..x...x...x...x.", "C": "..............x." * 7 + "." * 16},
        "ride": {"C": "x.x.x.x.x.x.x.x." * 7 + "x.x.x.x........."},
        # A crash at every door but the top's (Ryan: it broke the loop), and each phrase.
        "crash": {"*": P.door_pattern(call, "ABCDRO"), "A": "x" + "." * 127, "C": "x" + "." * 127,
                  "D": "x" + "." * 31},
        "china": {"A": "." * 62 + "x." + "." * 64, "C": "." * 62 + "x." + "." * 64, "O": "." * 62 + "x." + "." * 64,
                  "D": "........x......." + "." * 16},
        "stack": {"D": "..x...x...x...x."},
        "tom": {s: FILLS["tom"] for s in "IAC"},
        "tom2": {s: FILLS["tom2"] for s in "IAC"},
        # The map's industry over the kit.
        "knock": {s: "......x.......x." for s in "ACO"} | {"D": "..x...x...x...x."},
        "tick": {s: "x" * 16 for s in "ACO"},
        "clank": {"A": "..............x" + "." * 49, "D": "..............x" + "." * 17},
        "glitch": {"I": "........x.......", "A": "...x.......x....x.........x.....", "D": "...x.......x....", "O": "........x......."},
    }
    for name, pat in duel_drums().items():
        drums.setdefault(name, {})["R"] = pat
    if d != "copy":
        # Night Shift's four on the floor under the map's sixteenths and its stack, the backbeat
        # over it, a crash every phrase; no gallop, china or double kick.
        drums["kick"]["D"] = "x...x...x...x..." * 7 + "x...x...x...x.x."
        drums["snare"]["D"] = "....x.......x..." * 7 + "....x.......x.x."
        drums["hat"]["D"] = "x" * 128
        drums["kick_hard"].pop("D")
        drums["china"].pop("D")
        drums["crash"]["D"] = "x" + "." * 31 if d == "trade" else "x" + "." * 63   # on each call and answer, or each phrase
        if d == "blend":
            drums["knock"]["D"] = BLEND_KNOCK
            drums["clank"]["D"] = BLEND_CLANK
            drums["tick"]["D"] = BLEND_TICK
        if d == "factory":
            # The industry on three-three-two: the knocks on it, a clank on three, the ticks in sixteenths.
            drums["knock"]["D"] = "x..x..x.x..x..x.".replace("x", FACTORY)
            drums["clank"]["D"] = "........x.......".replace("x", FACTORY)
            drums["tick"]["D"] = "x" * 16
    kit = P.fight_kit()
    kit.update({"knock": (F.knock_perc(), 0.5), "tick": (F.tick(), 0.22), "clank": (F.clank(), 0.25),
                "glitch": (F.glitch_perc(), 0.3), "kick_hard": (F.variants(F.kick_real), 1.9)})
    return {"kit": kit, "drums": drums, "voices": voices, "pad": [{"inst": "choir_real", "gain": 0.22, "vowel": "oh", "sections": "B"}],
            "drum_gain": {"I": 1.0, "A": 1.1, "B": 1.0, "C": 1.1, "D": 1.25 if d == "copy" else D_DRUMS, "R": 1.2, "O": 1.1},
            "air": (0.12, 0.06), "master": 1.1, "headroom": 0.6, "tilt": 1.5, "presence": 0.25, "low": (150.0, -6.0)}


# ---------------------------------------------------------------- the renders

def on_form(form):
    """The recipe's call on another form (an excerpt, or R twice as long)."""
    saved = F.MUSIC[NAME]["form"]
    F.MUSIC[NAME]["form"] = form
    try:
        return P.recipe_call(F.music_night_shift)
    finally:
        F.MUSIC[NAME]["form"] = saved


def settled(kw, mastered):
    """A call rendered, every pattern read from its section's start as the track reads it.
    Unmastered, the mix stops before its master and comes back with the master's settings, so a
    set's rows go through one master together (`master_together`): a master that brought each row
    under its knee by its own peak would take back what a louder part adds."""
    settings = (kw.get("headroom"), kw.get("master", 1.25))
    if not mastered:
        kw.update(headroom=None, master=1e-3)   # tanh at a thousandth of its drive: linear to a part in a million
    with P.Patched(_steps=run_steps):
        x = F.groove(**kw)
    return x if mastered else (x, settings)


def battle(form=FORM10, mastered=True, **opts):
    """The battle half on a form (the round's, or an excerpt's)."""
    call = on_form(form)
    kw = dict(call)
    kw.update(battle_half(call, **opts))
    return settled(kw, mastered)


def map_half(form=FORM10, mastered=True, guitar=MAP_GUITAR):
    """The map half on a form: the shipped map with its front cut, its muted guitar or not."""
    return settled(map_intro(on_form(form), guitar), mastered)


DUEL_FORM = "D" * 8 + " " + "R" * R_BARS + " " + "O" * 8   # D into the duel and out into the outro
SETS = [
    {"id": "nu", "half": "battle", "title": "R, the duel, the lower bass under the upper", "form": DUEL_FORM, "seed": NAME + "_battle",
     "note": "D into R and out into the outro, the duel with the lower bass playing on under the upper's phrases (Ryan, 5 November: \"don't cut out the lower one when the upper comes in\"), 3 dB under its own: the upper's line an octave down, three-three-two on the roots, or a walking line of its own; and the upper bass in chords. The two basses different voices, the backing 3 dB under them. Switch rows anywhere: each carries on from the same beat.",
     "rows": [("nu0", "The lower bass in unison", "The lower bass doubling the upper's line an octave down (the full pair's).", {"duel_support": "unison"}),
              ("nu1", "The lower bass on a rhythm", "The lower bass on three-three-two on the roots under the upper's phrases.", {"duel_support": "rhythm"}),
              ("nu2", "The lower bass on a line of its own", "The lower bass walking in quarters, root, third, fifth and a step into the next chord, under the upper's phrases.", {"duel_support": "line"}),
              ("nu3", "The upper in chords, the lower in unison", "The upper bass's notes each with its fifth, two strings into one amp, the lower doubling its line an octave down.", {"duel_support": "unison", "duel_chords": True}),
              ("nu4", "The upper in chords, the lower on a rhythm", "The upper bass in chords over the lower's three-three-two.", {"duel_support": "rhythm", "duel_chords": True})]},
]
PAIR = {"id": "night_shift_r18", "title": "Night Shift, round eighteen"}
INTRO = "intro: the kick on every beat and the hats, the pad fading in through the fourth bar and swelling from 0:10, the sub from the fifth"
MAP_SAID = dict(F.MUSIC[NAME]["names"], I=INTRO,   # each section on the map, without its muted guitar
                A="groove: the piano off the beat, the chime's hook, a soft clap, the sub, knocks and ticks",
                C="the lead in long notes over the sub's pulse and a ride",
                R="the groove again, sixteen bars")
TURNS_SAID = {   # each section's turns in the battle half, on the page beside the map half's
    "I": "three-three-two on the root all through, the arpeggio on the plucked string from the fifth bar",
    "A": "the hook pushed on the synth lead over the arpeggio on the FM synth and the hold, then the walk with the hook on the FM synth from the ninth bar",
    "B": "the breakdown: held roots and ringing chords under the choir",
    "C": "the lead guitar's long notes over the walk, the arpeggio joining behind them on the synth lead at the ninth bar",
    "D": "the piano and the factory blended: the house piano stabbing the chords in three-three-two alone, the knocks in its gaps, the riff dark and low as the map's nod",
    "R": "a duel between two basses: the track's bass and a second an octave over it trading phrases, two bars each, then a bar each, then half a bar each, the lower doubling the upper's line an octave down under its answers, through two bars of stop-time and a hole, then together on three-three-two under the band's hits, climbing into the outro; the backing trading the tune under them, every voice 3 dB under the basses",
    "O": "the arpeggio on the plucked string and the hook on the FM synth over the hold, into the top",
}


def sections_on(form):
    """Every run of bars in a form: its section, its bars and where it starts, and the bars' times."""
    form = form.replace(" ", "")
    bar_s = 16 * 15.0 / F.MUSIC[NAME]["bpm"]
    runs, b = [], 0
    while b < len(form):
        e = b
        while e < len(form) and form[e] == form[b]:
            e += 1
        runs.append((form[b], b + 1, e, b * bar_s))
        b = e
    return runs, [k * bar_s for k in range(len(form))], len(form) * bar_s


def render_row(job):
    si, ri = job
    s = SETS[si]
    F.seed(s["seed"])
    opts = s["rows"][ri][3]
    render = battle if s["half"] == "battle" else map_half
    return si, ri, render(s["form"], mastered=False, **opts)


def render_full(which):
    if which == "battle":
        F.seed(NAME + "_battle")
        x, db = battle(), BATTLE_LEVEL
    else:
        F.seed(NAME)
        x, db = map_half(), MAP_LEVEL
    P.write("%s_%s" % (PAIR["id"], which), F.limit(F.write_level(x, NAME, db)), aac=False)
    return which


def main(argv):
    wanted = argv or [s["id"] for s in SETS] + ["full"]
    os.makedirs(P.OUT, exist_ok=True)
    jobs = [(si, ri) for si, s in enumerate(SETS) if s["id"] in wanted for ri in range(len(s["rows"]))]
    with ProcessPoolExecutor(max_workers=4) as pool:
        fulls = [pool.submit(render_full, w) for w in (("battle", "map") if "full" in wanted else ())]
        raw = {(si, ri): x for si, ri, x in pool.map(render_row, jobs)}
        for f in fulls:
            f.result()
    path = os.path.join(P.OUT, "night18.json")
    manifest = json.load(open(path)) if os.path.exists(path) else {"sets": [], "tracks": [], "seams": []}
    for si, s in enumerate(SETS):
        if s["id"] not in wanted:
            continue
        # One master and one gain for the set, the gain the one that brings its first row to its
        # half's level, so the rows differ only by what changed.
        mastered = master_together([raw[si, ri] for ri in range(len(s["rows"]))])
        gain = 10.0 ** (((BATTLE_LEVEL if s["half"] == "battle" else MAP_LEVEL) - F.mean_level(mastered[0])) / 20.0)
        rows = []
        for ri, (rid, title, note, _opts) in enumerate(s["rows"]):
            x = F.limit(mastered[ri] * gain)
            rows.append({"id": rid, "title": title, "note": note, "file": os.path.basename(P.write("night18_" + rid, x)),
                         "seconds": round(len(x) / F.SR, 2), "phone_db": P.measure(rid, x)["phone_db"]})
        manifest["sets"] = [e for e in manifest["sets"] if e["id"] != s["id"]] + [{"id": s["id"], "half": s["half"], "title": s["title"], "note": s["note"], "rows": rows}]
        print("%-2s %s" % (s["id"], "  ".join("%s %.1f" % (r["id"], r["phone_db"]) for r in rows)))
    manifest["sets"].sort(key=lambda e: [s["id"] for s in SETS].index(e["id"]))
    manifest["seams"] = []
    if "full" in wanted:
        m, b = (P.read_wav(os.path.join(P.OUT, "%s_%s.wav" % (PAIR["id"], w))) for w in ("map", "battle"))
        if len(m) != len(b):
            raise ValueError("the halves are %d and %d samples" % (len(m), len(b)))
        P.write(PAIR["id"] + "_pair", [m, b], kbps=384)
        runs, bar_at, total = sections_on(FORM10)
        levels = [P.measure("map", m), P.measure("battle", b)]
        manifest["tracks"] = [{"id": PAIR["id"], "title": PAIR["title"], "new": "both", "bpm": F.MUSIC[NAME]["bpm"], "length": round(total, 3),
                               "loop_from_bar": 1, "bar_at": [round(float(t), 4) for t in bar_at],
                               "sections": [{"section": s, "bars": [b0, b1], "at": round(at, 2),
                                             "what": "%s; the battle: %s" % (MAP_SAID[s], TURNS_SAID[s])} for s, b0, b1, at in runs],
                               "levels": levels}]
        print("%s  map %.1f (phone %.1f)  battle %.1f (phone %.1f)" % (PAIR["id"], levels[0]["mean_db"], levels[0]["phone_db"], levels[1]["mean_db"], levels[1]["phone_db"]))
    with open(path, "w") as f:
        json.dump(manifest, f, indent=1)
    print(os.path.relpath(path))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
