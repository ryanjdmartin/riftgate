"""Reads tools/special_probe.gd's parts (python3 tools/special_probe_read.py build): per special,
how often its condition held and it was picked, as built and with the player-state gates
opened; per cell, the fights' outcome both ways."""
import glob, json, sys
from collections import defaultdict

rows = {}
meta = None
for p in sorted(glob.glob(sys.argv[1] + "/special_[0-9].json")):
    d = json.load(open(p))
    meta = (d["trios"], d["cells"], d["seeds"])
    rows.update(d["rows"])
print("trios %d, cells %d, seeds %d, rows %d" % (meta[0], meta[1], meta[2], len(rows)))

spec = {"built": defaultdict(lambda: [0, 0, 0]), "open": defaultdict(lambda: [0, 0, 0])}
when = {}
cell = {"built": defaultdict(lambda: [0, 0, 0, 0, 0]), "open": defaultdict(lambda: [0, 0, 0, 0, 0])}
for key, r in rows.items():
    trio, cid, variant = key.split("|")
    c = cell[variant][cid]
    c[0] += r["fights"]; c[1] += r["won"]; c[2] += r["rounds"]; c[3] += r["hull_lost"]; c[4] += r["hull_max"]
    for sk, s in r["specials"].items():
        t = spec[variant][sk]
        t[0] += s["draws"]; t[1] += s["held"]; t[2] += s["picked"]
        when[sk] = s["when"]

print("\n%-34s %-16s %7s %7s %7s %8s" % ("special", "condition", "draws", "held", "picked", "opened"))
for sk in sorted(spec["built"], key=lambda k: when[k]):
    b = spec["built"][sk]; o = spec["open"].get(sk, [0, 0, 0])
    print("%-34s %-16s %7d %6.0f%% %6.0f%% %7.0f%%" % (sk, when[sk], b[0], 100.0 * b[1] / max(1, b[0]), 100.0 * b[2] / max(1, b[0]), 100.0 * o[2] / max(1, o[0])))

print("\n%-22s %14s %14s %16s" % ("cell", "won b/o", "rounds b/o", "hull lost b/o"))
for cid in sorted(cell["built"]):
    b = cell["built"][cid]; o = cell["open"][cid]
    print("%-22s %6.0f%%/%4.0f%% %6.2f/%6.2f %7.1f%%/%5.1f%%" % (cid, 100.0 * b[1] / b[0], 100.0 * o[1] / o[0], b[2] / b[0], o[2] / o[0], 100.0 * b[3] / b[4], 100.0 * o[3] / o[4]))
