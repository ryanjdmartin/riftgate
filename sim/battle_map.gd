class_name BattleMap
extends RefCounted

## The battlefield terrain. Rows run north (row 0, the rift) to south (last row, the gate).
## Generation is seeded and guarantees a ground-passable path from gate to rift.

enum Terrain { PLAIN, ROAD, ROUGH, RUINS, WATER, MOUNTAIN }

const TERRAIN_NAMES := {
	Terrain.PLAIN: "plain", Terrain.ROAD: "road", Terrain.ROUGH: "rough",
	Terrain.RUINS: "ruins", Terrain.WATER: "water", Terrain.MOUNTAIN: "mountain",
}

## Weighted roll. Plain dominates so the map reads as a field with features on it.
## Roads are never rolled: they are laid as paths (see `_lay_roads`).
const TERRAIN_WEIGHTS := {
	Terrain.PLAIN: 50, Terrain.ROAD: 0, Terrain.ROUGH: 14,
	Terrain.RUINS: 10, Terrain.WATER: 12, Terrain.MOUNTAIN: 8,
}
const ROAD_GAP_CHANCE := 0.18   # a laid road is missing this share of its slabs: nobody paves between attacks

var width: int = 7
var height: int = 14              # 14 rows: the rift, eleven of open ground, two of gate and wall
var terrain: Dictionary = {}  # Vector2i (axial) -> Terrain
var gate: Vector2i            # centre of the gate structure
var rift: Vector2i            # centre of the rift structure
var gate_hexes: Array[Vector2i] = []   # the gate: three wide and GATE_ROWS deep, apron included
var rift_hexes: Array[Vector2i] = []
var wall_hexes: Array[Vector2i] = []   # the rest of the bottom GATE_ROWS rows: indestructible, nobody stands there
var map_seed: int = 0

const STRUCTURE_HALF_WIDTH := 1   # gate and rift span centre plus this many hexes each side
## The gate and the walls are two rows deep: the models stand on the bottom row and the row
## above is their apron, so the wall never hides a unit behind it from the map camera
## (Ryan, 20 September). A squad strikes the gate from the row above the apron.
const GATE_ROWS := 2


## A map of nothing but plain ground. Used by tests and as a fallback.
static func flat(w: int, h: int) -> BattleMap:
	var m := BattleMap.new()
	m.width = w
	m.height = h
	for row in range(h):
		for col in range(w):
			m.terrain[Hex.offset_to_axial(col, row)] = Terrain.PLAIN
	m.gate = Hex.offset_to_axial(w / 2, h - 1)
	m.rift = Hex.offset_to_axial(w / 2, 0)
	m.rift_hexes = m._span(w / 2, 0)
	for row in range(h - GATE_ROWS, h):
		var span := m._span(w / 2, row)
		m.gate_hexes.append_array(span)
		for col in range(w):
			var hx := Hex.offset_to_axial(col, row)
			if not span.has(hx):
				m.wall_hexes.append(hx)
	return m


func _span(col: int, row: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for dc in range(-STRUCTURE_HALF_WIDTH, STRUCTURE_HALF_WIDTH + 1):
		var h := Hex.offset_to_axial(col + dc, row)
		if has(h):
			out.append(h)
	return out


## Gate, rift and wall hexes are structures: nobody stands on them. Squads strike the gate;
## the walls cannot be hurt.
func is_structure(h: Vector2i) -> bool:
	return gate_hexes.has(h) or rift_hexes.has(h) or wall_hexes.has(h)


static func generate(w: int, h: int, seed_value: int) -> BattleMap:
	var m := flat(w, h)
	m.map_seed = seed_value
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for hx in m.terrain.keys():
		m.terrain[hx] = _roll_terrain(rng)
	m._lay_roads(rng)
	# The gate, the rift, and the ground right in front of each are always open.
	var open: Array[Vector2i] = []
	open.append_array(m.gate_hexes)
	open.append_array(m.rift_hexes)
	for hx in open:
		m.terrain[hx] = Terrain.PLAIN
		for n in Hex.neighbors(hx):
			if m.has(n):
				m.terrain[n] = Terrain.PLAIN
	m._ensure_ground_path(rng)
	return m


## A paved road runs north from the gate as a connected path with drift, most of the way
## to the rift, with a branch or two, and gaps where the slabs are gone (Ryan, 21
## September: the road need not reach the rift, and gaps suit the fiction). Crags and
## water are never paved.
func _lay_roads(rng: RandomNumberGenerator) -> void:
	var trunk: Array[Vector2i] = []
	# From the open row above the gate's apron (the gate hexes themselves are structure).
	var gate_o := Hex.axial_to_offset(gate)
	var cur := Hex.offset_to_axial(gate_o.x, gate_o.y - GATE_ROWS)
	if has(cur) and not is_structure(cur):
		trunk.append(cur)
	var steps := int(float(height) * rng.randf_range(0.55, 0.8))
	for i in range(steps):
		var options: Array[Vector2i] = []
		for n in Hex.neighbors(cur):
			if has(n) and n.y < cur.y and not is_structure(n):
				options.append(n)
		if options.is_empty():
			break
		cur = options[rng.randi_range(0, options.size() - 1)]
		trunk.append(cur)
	var branches: Array = [trunk]
	for k in range(rng.randi_range(1, 2)):
		if trunk.size() < 4:
			break
		var from: Vector2i = trunk[rng.randi_range(1, trunk.size() - 2)]
		var branch: Array[Vector2i] = []
		var dir: int = rng.randi_range(0, 5)
		for i in range(rng.randi_range(3, 5)):
			var n: Vector2i = from + Hex.DIRECTIONS[dir]
			if not has(n) or is_structure(n):
				break
			branch.append(n)
			from = n
		branches.append(branch)
	for path in branches:
		for h in path:
			var t: int = terrain[h]
			if t == Terrain.MOUNTAIN or t == Terrain.WATER:
				continue
			if rng.randf() < ROAD_GAP_CHANCE:
				continue
			terrain[h] = Terrain.ROAD


static func _roll_terrain(rng: RandomNumberGenerator) -> int:
	var total := 0
	for wgt in TERRAIN_WEIGHTS.values():
		total += wgt
	var pick := rng.randi_range(1, total)
	for t in TERRAIN_WEIGHTS.keys():
		pick -= TERRAIN_WEIGHTS[t]
		if pick <= 0:
			return t
	return Terrain.PLAIN


func has(h: Vector2i) -> bool:
	return terrain.has(h)


func terrain_at(h: Vector2i) -> int:
	return terrain.get(h, Terrain.MOUNTAIN)


func all_hexes() -> Array:
	return terrain.keys()


## Whether a unit with these traits can enter this terrain at all.
static func passable(t: int, traits: Array) -> bool:
	match t:
		Terrain.MOUNTAIN:
			return traits.has("flyer")
		Terrain.WATER:
			return traits.has("flyer") or traits.has("hover")
		_:
			return true


## Movement points spent to enter this terrain.
static func move_cost(t: int, traits: Array) -> int:
	if traits.has("flyer"):
		return 1
	match t:
		Terrain.ROUGH:
			return 1 if traits.has("walker") else 2
		Terrain.RUINS:
			return 1 if traits.has("walker") else 2
		_:
			return 1


## Cheapest path from `from` to `to` for a unit with `traits`, as the hexes after `from`.
## Hexes in `blocked` are avoided, except the destination itself. Empty if unreachable.
func find_path(from: Vector2i, to: Vector2i, traits: Array, blocked: Dictionary = {}) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	if from == to:
		return path
	var dist := {from: 0}
	var prev := {}
	var frontier: Array = [[0, from]]
	# A path that starts inside the gate may cross the rest of the gate (its apron) to get
	# out; that is how the gate-to-rift guarantee is checked. Nothing else crosses a structure.
	var own_gate := gate_hexes.has(from)
	while not frontier.is_empty():
		var best := 0
		for i in range(1, frontier.size()):
			if frontier[i][0] < frontier[best][0]:
				best = i
		var cur: Array = frontier.pop_at(best)
		var d: int = cur[0]
		var h: Vector2i = cur[1]
		if h == to:
			break
		if d > dist[h]:
			continue
		for n in Hex.neighbors(h):
			if not has(n):
				continue
			if n != to and (blocked.has(n) or (is_structure(n) and not (own_gate and gate_hexes.has(n)))):
				continue
			var t: int = terrain[n]
			if not passable(t, traits):
				continue
			var nd := d + move_cost(t, traits)
			if not dist.has(n) or nd < dist[n]:
				dist[n] = nd
				prev[n] = h
				frontier.append([nd, n])
	if not prev.has(to):
		return path
	var c := to
	while c != from:
		path.push_front(c)
		c = prev[c]
	return path


func _ensure_ground_path(rng: RandomNumberGenerator) -> void:
	if not find_path(gate, rift, []).is_empty():
		return
	# Carve a corridor: walk from the gate toward the rift, always reducing distance,
	# opening whatever is in the way. Random choice among the closer neighbours.
	var cur := gate
	var guard := width * height
	while cur != rift and guard > 0:
		guard -= 1
		var options: Array[Vector2i] = []
		var best := Hex.distance(cur, rift)
		for n in Hex.neighbors(cur):
			if has(n) and Hex.distance(n, rift) < best:
				options.append(n)
		if options.is_empty():
			break
		cur = options[rng.randi_range(0, options.size() - 1)]
		if not passable(terrain[cur], []):
			terrain[cur] = Terrain.PLAIN
