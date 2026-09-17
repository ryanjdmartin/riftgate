"""The Badger's finishing touches. Runs inside the polish pass after Minerva's generic
manner (hard chamfers, corner bolts, rim bars, rear vent) and the Badger kit (work lights,
tow lugs). Everything here is placed by hand from the massing's part names and coordinates,
so it is the place to tweak: numbers are model units, x right, y forward, z up.

The brief, from the codex: the EX-45L was a mining machine, refitted with claws, teeth and
missiles. Minerva builds brick houses. So the finish should read as heavy industrial plant
with weapons bolted on, not as a weapon with a mining paint job: hydraulics where a digger
has them, at the back of the limbs across the joints, and nothing elegant.
"""

# Parts, by their names in badger.blend (mirrored copies carry .001 / .004 suffixes).
SHOULDER_L, SHOULDER_R = "steel_14", "steel_14.001"                # the pods either side of the cab, z 26..35
UPPER_L, UPPER_R = "steel_dark_15.001", "steel_dark_15.004"       # upper claw arms, z 18..25
BLADE_L, BLADE_R = "steel_dark_15.002", "steel_dark_15.002"       # the tall claw blades (left is the modelled one)

# Rams at the back of each arm, across the joints. Shoulder to elbow: from the rear top of the
# shoulder pod down to the rear of the upper arm. Elbow to claw: from the upper arm's rear
# down to the base of the blade. Left side first; the right mirrors in x.
for side, sx in (("l", -1.0), ("r", 1.0)):
    x = sx * 22.4
    hydraulic(f"shoulder_{side}", (x, -4.0, 34.0), (x, 8.0, 25.5), radius=0.9)
    hydraulic(f"wrist_{side}", (x, 8.5, 19.0), (x, 18.0, 15.5), radius=0.7)

# A tooth strip along the top of each claw blade: the "teeth" the codex mentions, as a row of
# small dark wedges the toon shader reads as a serrated edge.
for sx in (-1.0, 1.0):
    for i in range(4):
        y = 16.0 + i * 2.4
        box(f"tooth_{'l' if sx < 0 else 'r'}_{i}", (sx * 24.2, y, 28.6), (sx * 20.2, y + 1.2, 29.9), "steel_dark")

# Missile tubes are already modelled (the bore array on the cab's flank); leave them.
