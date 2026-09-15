# Status

Handoff note for the next session. Replace stale lines; keep it under a screen.

## As of 15 September 2026

**State.** All 14 September work is committed. Tests: 90 tests, 1093 checks, green.

**Last done.** The vector HUD is the skirmish UI, with a selectable HUD colour, confirms on
Withdraw and on End turn with dice unspent, codex panels with head-on sprites and italic flavour
quotes, and keyword chips hugging the dice. Mech sprites come from `tools/spriter/spriter.py`
for Bulwark, Sentinel, and Raptor. Foes carry an `actions` roster; the engine still runs only
the basic attack. Design bible is at v0.4.

**Next, in order.**

1. Wire the battle loop: routes by touch, resolve, skirmish on contact, apply the result,
   continue. Pieces exist on both sides (`Battlefield.detect_skirmishes`,
   `Battlefield.apply_skirmish_result`); nothing in `game/` connects them yet.
2. Play on a phone with the damage ranges in; tune min, max, crit, injury thresholds.
3. Art: mech sheet round two on the grit brief, the Anvil model, enemy art when images exist.
4. Small HUD fixes owed: roomy log at round one, faint disabled eye button, gesture tutorial.
5. Hangar: repair cost for cracked and destroyed faces, then rewards, one-shots, command die.

**Open decisions.** See design bible section 12.
