class_name Profile
extends RefCounted

## What outlives a run (bible section 10, between campaigns: the pool, never power). A run
## lost or won leaves its first finds in the pool, the codex and a tier; one rare piece a
## maker placed in the next run's kit; the colours unlocked by favour. Nothing here is
## power the next run starts with but that one piece. Placeholder fields where the systems
## that fill them are not built yet (the favour measures, livery, the offers' catalogues).

var pool: Array = []          # blueprint ids found in any run: what a later run's offers may show
var codex: Array = []         # chassis and foe ids the player has met
var tier: int = 0             # difficulty tiers cleared
var favour_piece: String = "" # the rare component a maker placed in the next run's kit ("" for none)
var livery: Array = []        # colours unlocked by a maker's favour (section 10; after the hangar)
var runs: int = 0
var runs_won: int = 0


## Fold a finished run in: its finds join the pool and the codex; a won run clears a tier.
func absorb(c: Campaign) -> void:
	runs += 1
	if c.won:
		runs_won += 1
		tier += 1
	for b in c.blueprints:
		if not pool.has(b):
			pool.append(b)
	for m in c.roster:
		if not codex.has(m.chassis):
			codex.append(m.chassis)
	for f in c.bosses_beaten.keys():
		if not codex.has(f):
			codex.append(f)


func to_dict() -> Dictionary:
	return {"pool": pool, "codex": codex, "tier": tier, "favour_piece": favour_piece,
		"livery": livery, "runs": runs, "runs_won": runs_won}


static func from_dict(d: Dictionary) -> Profile:
	var p := Profile.new()
	for x in d.get("pool", []):
		p.pool.append(str(x))
	for x in d.get("codex", []):
		p.codex.append(str(x))
	p.tier = int(d.get("tier", 0))
	p.favour_piece = str(d.get("favour_piece", ""))
	for x in d.get("livery", []):
		p.livery.append(str(x))
	p.runs = int(d.get("runs", 0))
	p.runs_won = int(d.get("runs_won", 0))
	return p
