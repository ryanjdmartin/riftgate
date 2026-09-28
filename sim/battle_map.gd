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
var crag_base: Dictionary = {}         # crag hex -> the ground under the rock (water, ruins, ...): flavour only
var elevation: Dictionary = {}         # hex -> relief step 0..3 (water -1): landscape only, no rule reads it
var margin: Dictionary = {}            # hex beside the field -> terrain: scenery past the playable edge, never played on
var city: Dictionary = {}              # margin hex -> true: the city behind the wall, what the gate protects
const MARGIN_COLS := 4
const MARGIN_ROWS := 3                 # scenery rows beyond the rift
const CITY_ROWS := 2                   # city rows behind the wall
var map_seed: int = 0

const STRUCTURE_HALF_WIDTH := 1   # gate and rift span centre plus this many hexes each side
## The gate and the walls are two rows deep: the models stand on the bottom row and the row
## above is their apron, so the wall never hides a unit behind it from the map camera
## (Ryan, 20 September). A pack strikes the gate from the row above the apron.
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


## Gate, rift and wall hexes are structures: nobody stands on them. Packs strike the gate;
## the walls cannot be hurt.
func is_structure(h: Vector2i) -> bool:
	return gate_hexes.has(h) or rift_hexes.has(h) or wall_hexes.has(h)


static func generate(w: int, h: int, seed_value: int) -> BattleMap:
	var m := flat(w, h)
	m.map_seed = seed_value
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	m._lay_landscape(rng)
	m._lay_roads(rng)
	# The gate, the rift, and the ground right in front of each are always open, and the
	# two rows above the gate's apron are the team's ground: never water or crag, so a
	# deployed machine always has somewhere to go.
	var open: Array[Vector2i] = []
	open.append_array(m.gate_hexes)
	open.append_array(m.rift_hexes)
	for hx in open:
		m.terrain[hx] = Terrain.PLAIN
		m.crag_base.erase(hx)
		m.elevation[hx] = 0
		for n in Hex.neighbors(hx):
			if m.has(n):
				m.terrain[n] = Terrain.PLAIN
				m.crag_base.erase(n)
				m.elevation[n] = 0
	for row in range(h - GATE_ROWS - 2, h):
		for col in range(w):
			var hx := Hex.offset_to_axial(col, row)
			if not m.has(hx):
				continue
			m.elevation[hx] = 0
			if m.terrain[hx] == Terrain.WATER or m.terrain[hx] == Terrain.MOUNTAIN:
				m.terrain[hx] = Terrain.PLAIN
				m.crag_base.erase(hx)
	m._ensure_ground_path(rng)
	return m


## A believable landscape rather than per-hex rolls (Ryan, 21 September): water as bodies
## with shores from a wetness field, gravel as belts from a roughness field, ruins in a few
## clusters, crags along ridge lines (the ground under a crag is kept as its flavour). The
## fields are seeded noise, so the same seed is the same map.
func _lay_landscape(rng: RandomNumberGenerator) -> void:
	var wet := FastNoiseLite.new()   # slow, so water gathers into a few bodies
	wet.seed = map_seed
	wet.frequency = 0.12
	var rough := FastNoiseLite.new()
	rough.seed = map_seed + 101
	rough.frequency = 0.30
	var ridge := FastNoiseLite.new()
	ridge.seed = map_seed + 202
	ridge.frequency = 0.22
	var relief := FastNoiseLite.new()   # terraces, decoupled from what the ground is
	relief.seed = map_seed + 303
	relief.frequency = 0.16
	var centres: Array[Vector2i] = []
	var keys := terrain.keys()
	for k in range(rng.randi_range(2, 4)):
		centres.append(keys[rng.randi_range(0, keys.size() - 1)])
	# The field, then the margin columns either side of it: seen past the edge, never played.
	var all: Array = keys.duplicate()
	for row in range(-MARGIN_ROWS, height):
		for col in range(-MARGIN_COLS, width + MARGIN_COLS):
			var hx := Hex.offset_to_axial(col, row)
			if not has(hx):
				all.append(hx)
	# Behind the wall, the city: flat paved rows the map builds as blocks.
	for row in range(height, height + CITY_ROWS):
		for col in range(-MARGIN_COLS, width + MARGIN_COLS):
			var hx := Hex.offset_to_axial(col, row)
			margin[hx] = Terrain.ROAD
			elevation[hx] = 0
			city[hx] = true
	# The ground from the fields: water where it is wet, wasteland across the rougher
	# half of what is left, plain in between, ruins in clusters with a dense core.
	for hx in all:
		var p := Hex.to_pixel(hx, 1.0)
		var t := Terrain.PLAIN
		if wet.get_noise_2d(p.x, p.y) < -0.34:
			t = Terrain.WATER
		elif rough.get_noise_2d(p.x, p.y) > 0.02:
			t = Terrain.ROUGH
		if t != Terrain.WATER:
			for c in centres:
				var d := Hex.distance(hx, c)
				if d <= 2 and rng.randf() < (0.9 if d <= 1 else 0.5):
					t = Terrain.RUINS
		var crag := absf(ridge.get_noise_2d(p.x, p.y)) < 0.075 and rng.randf() < 0.85 and not is_structure(hx)
		elevation[hx] = -1 if t == Terrain.WATER else clampi(int(floor((relief.get_noise_2d(p.x, p.y) + 0.45) * 3.4)), 0, 3)
		if has(hx):
			terrain[hx] = t
			if crag:
				crag_base[hx] = t
				terrain[hx] = Terrain.MOUNTAIN
		else:
			margin[hx] = t
			if crag:
				crag_base[hx] = t
				margin[hx] = Terrain.MOUNTAIN
			if Hex.axial_to_offset(hx).y >= height - GATE_ROWS:
				# The wall runs across the margin: level ground under it, nothing on it.
				margin[hx] = Terrain.PLAIN
				crag_base.erase(hx)
				elevation[hx] = 0


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
		# Northward steps, steering around water and crags when there is a way round.
		var options: Array[Vector2i] = []
		var any: Array[Vector2i] = []
		for n in Hex.neighbors(cur):
			if has(n) and n.y < cur.y and not is_structure(n):
				any.append(n)
				if terrain[n] != Terrain.WATER and terrain[n] != Terrain.MOUNTAIN:
					options.append(n)
		if options.is_empty():
			options = any
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
		var dir: int = [1, 2, 4, 5][rng.randi_range(0, 3)]   # diagonal only: roads run north-east or north-west, never across
		for i in range(rng.randi_range(3, 5)):
			var n: Vector2i = from + Hex.DIRECTIONS[dir]
			if not has(n) or is_structure(n):
				break
			branch.append(n)
			from = n
		branches.append(branch)
	for path in branches:
		for i in range(path.size()):
			var h: Vector2i = path[i]
			var t: int = terrain[h]
			# The team's rows above the apron are cleared to open ground after this, so a
			# road may cross them whatever the noise put there.
			var team_rows := Hex.axial_to_offset(h).y >= height - GATE_ROWS - 2
			if (t == Terrain.MOUNTAIN or t == Terrain.WATER) and not team_rows:
				continue
			if rng.randf() < ROAD_GAP_CHANCE and not (path == trunk and i < 3):
				continue   # a gap, except the first slabs off the gate: there is always a road
			terrain[h] = Terrain.ROAD
			crag_base.erase(h)
	# A road is never a lone slab: a road hex with no road (or gate) beside it goes back to
	# plain. Roads sit at one level, like water, so a road never breaks over a terrace.
	var lone: Array[Vector2i] = []
	for h in terrain.keys():
		if terrain[h] != Terrain.ROAD:
			continue
		var joined := false
		for n in Hex.neighbors(h):
			if terrain.get(n, -1) == Terrain.ROAD or gate_hexes.has(n):
				joined = true
		if not joined:
			lone.append(h)
	for h in lone:
		terrain[h] = Terrain.PLAIN
	for h in terrain.keys():
		if terrain[h] == Terrain.ROAD:
			elevation[h] = 0


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
## Only a crag stops anyone but a flyer. Water is fordable by machines this size (Ryan, 21
## September): it costs, by how the machine moves.
static func passable(t: int, traits: Array) -> bool:
	match t:
		Terrain.MOUNTAIN:
			return traits.has("flyer")
		_:
			return true


## Movement points spent to enter this terrain. Each way of moving has its own worst
## ground: tracks wade slowly, walkers hate nothing but water, hover skims water and
## chokes on rubble, flyers ignore it all.
static func move_cost(t: int, traits: Array) -> int:
	if traits.has("flyer"):
		return 1
	var walker := traits.has("walker")
	var hover := traits.has("hover")
	match t:
		Terrain.WATER:
			return 1 if hover else (2 if walker else 3)
		Terrain.ROUGH:
			return 1 if walker else 2
		Terrain.RUINS:
			return 1 if walker else (3 if hover else 2)
		_:
			return 1


## The ground of a hex on or beside the field: the margin columns exist to be seen, not
## played on, and `has` stays false for them.
func terrain_of(h: Vector2i) -> int:
	return terrain.get(h, margin.get(h, Terrain.PLAIN))


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
