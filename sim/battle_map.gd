class_name BattleMap
extends RefCounted

## The battlefield terrain. Rows run north (row 0, the rift) to south (last row, the gate).
## Generation is seeded and guarantees the horde a way from the rift to the gate that no
## fewer than three hexes cut (the foe crossings: decided 2 October, three wide 3 October).

enum Terrain { PLAIN, ROAD, ROUGH, RUINS, WATER, MOUNTAIN }

const TERRAIN_NAMES := {
	Terrain.PLAIN: "plain", Terrain.ROAD: "road", Terrain.ROUGH: "rough",
	Terrain.RUINS: "ruins", Terrain.WATER: "water", Terrain.MOUNTAIN: "mountain",
}

const ROAD_GAP_CHANCE := 0.18   # a laid road is missing this share of its slabs: nobody paves between attacks

var width: int = 7
var height: int = 20              # the game's field (Battle.DEFAULT_HEIGHT): the rift, seventeen rows of ground, two of gate and wall
var terrain: Dictionary = {}  # Vector2i (axial) -> Terrain
var gate: Vector2i            # centre of the gate structure
var rift: Vector2i            # centre of the rift structure
var gate_hexes: Array[Vector2i] = []   # the gate: four wide on the apron row, three below, apron included
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
var opened: Dictionary = {}            # hex -> the ground the horde's guarantee opened there (the map survey reads it)
var water_feature := ""               # "river", "lake west", "lake east", "lake middle", or two joined by " + " (_lay_water)
var kind := "mixed"                    # the map's type, a key of KINDS: the intel the player will read

## Map types (4 October, Claude's proposal on Ryan's go; every share a placeholder, Ryan's
## to move): the generator's knobs as presets, so maps differ enough that the ground is a
## decision before the battle and the type's name is the whole intel ("RUBBLE FIELD"), never
## a percentage. Each is still a seeded noise map, so no two are alike. The 200-seed survey
## measures each (tools/map_survey.gd --type). `mixed` is the generator as it was.
##   rough_t: the roughness noise above which ground is rough (lower is more rough);
##   ruins: how many clusters, `ruins_r` their radius, and `belt` lays them across one band of rows;
##   crag_t: the ridge noise within which ground is a crag (higher is more crags);
##   water: "either" (a river six in ten, else a lake), "river", "lake", or "both";
##   river_thick: the share of river hexes with a second hex below them;
##   puddles_t: a wetness noise below which a hex is a puddle, or 1.0 for none.
const KINDS := {
	"mixed": {"name": "MIXED GROUND", "rough_t": 0.02, "ruins": [2, 4], "ruins_r": 2, "belt": false, "crag_t": 0.075, "water": "either", "river_thick": 0.3, "puddles_t": -1.0},
	"steppe": {"name": "OPEN STEPPE", "rough_t": 0.30, "ruins": [1, 2], "ruins_r": 2, "belt": false, "crag_t": 0.035, "water": "lake", "river_thick": 0.3, "puddles_t": -1.0},
	"rubble": {"name": "RUBBLE FIELD", "rough_t": 0.12, "ruins": [3, 5], "ruins_r": 2, "belt": true, "crag_t": 0.04, "water": "either", "river_thick": 0.3, "puddles_t": -1.0},
	"badlands": {"name": "BADLANDS", "rough_t": 0.02, "ruins": [1, 2], "ruins_r": 2, "belt": false, "crag_t": 0.12, "water": "either", "river_thick": 0.3, "puddles_t": -1.0},
	"flooded": {"name": "FLOODED", "rough_t": 0.08, "ruins": [1, 2], "ruins_r": 2, "belt": false, "crag_t": 0.05, "water": "both", "river_thick": 0.8, "puddles_t": -0.38},
}

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
		if row == h - GATE_ROWS:
			# The apron row is four wide: the gate's model covers the hex at its top right too
			# (Ryan, 29 September), so a pack there strikes the gate rather than a wall.
			var extra := Hex.offset_to_axial(w / 2 + STRUCTURE_HALF_WIDTH + 1, row)
			if m.has(extra):
				span.append(extra)
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


static func generate(w: int, h: int, seed_value: int, map_kind: String = "mixed") -> BattleMap:
	var m := flat(w, h)
	m.map_seed = seed_value
	m.kind = map_kind if KINDS.has(map_kind) else "mixed"
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	m._lay_landscape(rng)
	m._lay_water(rng)
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


## A believable landscape rather than per-hex rolls (Ryan, 21 September): gravel as belts
## from a roughness field, ruins in a few clusters, crags along ridge lines (the ground
## under a crag is kept as its flavour). The fields are seeded noise, so the same seed is
## the same map. Water is laid after, as one feature (`_lay_water`).
func _lay_landscape(rng: RandomNumberGenerator) -> void:
	var rough := FastNoiseLite.new()
	rough.seed = map_seed + 101
	rough.frequency = 0.30
	var ridge := FastNoiseLite.new()
	ridge.seed = map_seed + 202
	ridge.frequency = 0.22
	var relief := FastNoiseLite.new()   # terraces, decoupled from what the ground is
	relief.seed = map_seed + 303
	relief.frequency = 0.16
	var knobs: Dictionary = KINDS[kind]
	var centres: Array[Vector2i] = []
	var keys := terrain.keys()
	var n_ruins: int = rng.randi_range(knobs["ruins"][0], knobs["ruins"][1])
	var belt_rows := {}
	if knobs["belt"]:
		# A belt of rubble across the whole field, two or three rows deep, so the ruins lie
		# in the way of every lane (patches leave a lane, measured 4 October); the clusters
		# then fray its edges. A road through it is the one open lane, and the horde does
		# not care, since rubble is normal ground to a pack.
		var band := rng.randi_range(5, height - GATE_ROWS - 7)
		for r in range(band, band + rng.randi_range(2, 3)):
			belt_rows[r] = true
		for k in range(n_ruins):
			centres.append(Hex.offset_to_axial(rng.randi_range(0, width - 1), band + rng.randi_range(-2, 3)))
	else:
		for k in range(n_ruins):
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
	# The ground from the fields: wasteland across the rougher half, plain in between, ruins
	# in clusters with a dense core.
	for hx in all:
		var p := Hex.to_pixel(hx, 1.0)
		var t := Terrain.PLAIN
		if rough.get_noise_2d(p.x, p.y) > float(knobs["rough_t"]):
			t = Terrain.ROUGH
		for c in centres:
			var d := Hex.distance(hx, c)
			if d <= int(knobs["ruins_r"]) and rng.randf() < (0.9 if d <= 1 else (0.5 if d <= 2 else 0.4)):
				t = Terrain.RUINS
		if belt_rows.has(Hex.axial_to_offset(hx).y) and rng.randf() < 0.92:
			t = Terrain.RUINS
		var crag := absf(ridge.get_noise_2d(p.x, p.y)) < float(knobs["crag_t"]) and rng.randf() < 0.85 and not is_structure(hx)
		elevation[hx] = clampi(int(floor((relief.get_noise_2d(p.x, p.y) + 0.45) * 3.4)), 0, 3)
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


## One real water feature a map (decided 2 October, bible section 4: water is built around,
## and the generator changes for it), in place of the puddles a wetness field used to
## scatter (6% of the field in bodies of three hexes or so, never across it). Either a river
## that runs through the whole field and on past both edges, with fords, or a lake band:
## reaching in from one side, or lying in the middle with ground either side. The horde
## crosses where the land is: a river's fords are open ground anyone may use, one three
## wide or two two wide, and a lake leaves CROSSING_WIDTH columns dry or more, so the
## crossing guarantee seldom has to widen anything. Rows stay clear of the rift's mouth and
## of the team's ground. A hex chain is a wall to a hex chain, so a river one hex thick
## stops every foe that is not at a ford.
const RIVER_CHANCE := 0.6     # otherwise a lake band, when the kind says either
const LAKE_DEEP := 0.5        # a lake hex with a third row below it
const FEATURE_GAP := 4        # rows between two features' lines, when a kind has both


func _lay_water(rng: RandomNumberGenerator) -> void:
	var knobs: Dictionary = KINDS[kind]
	var mode: String = knobs["water"]
	var river := rng.randf() < RIVER_CHANCE if mode == "either" else mode != "lake"
	var first := _lay_feature(rng, river, float(knobs["river_thick"]), -99)
	if mode == "both" and first >= 0:
		# A lake as well as the river, on rows clear of it.
		_lay_feature(rng, false, 0.0, first)
	# Puddles from a wetness field, where the kind wants them: the odd one or two hexes the
	# 21 September landscape used to scatter, on top of the feature.
	if float(knobs["puddles_t"]) > -1.0:
		var wet := FastNoiseLite.new()
		wet.seed = map_seed
		wet.frequency = 0.14
		for hx in terrain.keys():
			var row := Hex.axial_to_offset(hx).y
			if row < 3 or row >= height - GATE_ROWS - 2 or is_structure(hx):
				continue
			var p := Hex.to_pixel(hx, 1.0)
			if wet.get_noise_2d(p.x, p.y) < float(knobs["puddles_t"]) and terrain[hx] != Terrain.MOUNTAIN:
				_flood(hx)


## One feature, a river or a lake band, its line on a row clear of `avoid_row` by
## FEATURE_GAP. Returns the line's row, or -1 when there was nowhere to put it.
func _lay_feature(rng: RandomNumberGenerator, river: bool, river_thick: float, avoid_row: int) -> int:
	var lo := 4                              # the rift's mouth stays dry
	var hi := height - GATE_ROWS - 5         # and clear of the team's ground, thickening included
	if not river:
		hi -= 2                              # a lake runs two rows deeper than its line
	var rows: Array[int] = []
	for r in range(lo, hi + 1):
		if absi(r - avoid_row) >= FEATURE_GAP:
			rows.append(r)
	if rows.is_empty():
		return -1
	var base: int = rows[rng.randi_range(0, rows.size() - 1)]
	var c0 := -MARGIN_COLS - 1               # past the west edge
	var c1 := width + MARGIN_COLS            # past the east edge
	var taper_west := false
	var taper_east := false
	var feature := "river"
	if not river:
		match rng.randi_range(0, 2):
			0:   # from the west, the east columns dry
				c1 = width - 1 - CROSSING_WIDTH
				taper_east = true
				feature = "lake west"
			1:   # from the east
				c0 = CROSSING_WIDTH
				taper_west = true
				feature = "lake east"
			_:   # in the middle, ground either side
				c0 = rng.randi_range(1, 2)
				c1 = mini(width - 2, c0 + 2)
				taper_west = true
				taper_east = true
				feature = "lake middle"
	water_feature = feature if water_feature.is_empty() else water_feature + " + " + feature
	# The line: eastward one hex at a time (east, or half a step north-east or south-east),
	# drifting about its row but never far.
	var line: Array[Vector2i] = []
	var cur := Hex.offset_to_axial(c0, base)
	while Hex.axial_to_offset(cur).x <= c1:
		line.append(cur)
		var steps: Array[Vector2i] = [Vector2i(1, 0), Vector2i(1, 0)]
		if cur.y > lo and cur.y > base - 2:
			steps.append(Vector2i(1, -1))
		if cur.y < hi and cur.y < base + 2:
			steps.append(Vector2i(0, 1))
		cur += steps[rng.randi_range(0, steps.size() - 1)]
	var wet: Array[Vector2i] = []
	var below := {}   # a river's line hex -> the hex thickening it, when it has one
	for i in range(line.size()):
		var hx: Vector2i = line[i]
		wet.append(hx)
		var col := Hex.axial_to_offset(hx).x
		if river:
			if rng.randf() < river_thick:
				wet.append(hx + Vector2i(0, 1))
				below[hx] = hx + Vector2i(0, 1)
			continue
		# A lake is two rows deep and three in places, rounded where it ends in the field.
		var end := (taper_west and col <= c0) or (taper_east and col >= c1)
		if end:
			continue
		wet.append(hx + Vector2i(0, 1))
		wet.append(hx + Vector2i(-1, 1))
		var near_end := (taper_west and col <= c0 + 1) or (taper_east and col >= c1 - 1)
		if not near_end and rng.randf() < LAKE_DEEP:
			wet.append(hx + Vector2i(-1, 2))
	for hx in wet:
		_flood(hx)
	if not river:
		return base
	# The fords: runs of the line inside the field, one of CROSSING_WIDTH hexes or two of
	# two, back to open ground with whatever thickened them. Along the line, so a ford is as
	# many hexes wide as it is long, whichever way the river bends there.
	var inside: Array[Vector2i] = []
	for hx in line:
		if has(hx):
			inside.append(hx)
	var picks: Array[int] = []
	var n := inside.size()
	if n < CROSSING_WIDTH + 4 or rng.randf() < 0.5:
		var j := rng.randi_range(0, maxi(0, n - CROSSING_WIDTH))
		for k in range(CROSSING_WIDTH):
			picks.append(j + k)
	else:
		var a := rng.randi_range(0, n - 5)
		var b := rng.randi_range(a + 3, n - 2)
		picks.append_array([a, a + 1, b, b + 1])
	for j in picks:
		if j >= n:
			continue
		for hx in [inside[j], below.get(inside[j], inside[j])]:
			if has(hx) and terrain[hx] == Terrain.WATER:
				terrain[hx] = Terrain.PLAIN
				elevation[hx] = 0
	return base


## Water on a hex of the field or of the scenery beside it, never on a structure, the
## city or the wall's rows.
func _flood(hx: Vector2i) -> void:
	if Hex.axial_to_offset(hx).y >= height - GATE_ROWS:
		return
	if has(hx):
		if is_structure(hx):
			return
		terrain[hx] = Terrain.WATER
	elif margin.has(hx) and not city.has(hx):
		margin[hx] = Terrain.WATER
	else:
		return
	crag_base.erase(hx)
	elevation[hx] = -1


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


func has(h: Vector2i) -> bool:
	return terrain.has(h)


func terrain_at(h: Vector2i) -> int:
	return terrain.get(h, Terrain.MOUNTAIN)


func all_hexes() -> Array:
	return terrain.keys()


## Movement by way of moving (decided 2 October, bible section 4). Each way of moving calls
## each ground a word: FAST costs 5 a hex, NORMAL 10, SLOW can always be entered with any
## move left and the step ends the move, WALL cannot be entered. The grounds are open (plain
## and road are the same ground; the road is art), rough, ruins and water; a crag is a wall
## to all but a flyer. Prices are never weighed against each other by the player: a hex is
## one of three words, and the map draws the reach. A unit with no way of moving (every
## pack and boss; the foes carry no trait) moves as the horde does: normal on any land,
## water and mountains walls, since it flattens the ground it crosses (Ryan, 2 October:
## the Final Fantasy overworld rule). A bigger move buys back any price, so a slow hex is
## the one thing no move buys through, which is what gives each way of moving a ground
## where it loses whatever its move.
const FAST := 5
const NORMAL := 10
const SLOW := -1          # the rest of the move, however much is left
const WALL := -2
## A slow hex on an unbounded path (`find_path`, which only the packs use today, and nothing
## is slow for a pack) counts as three normal hexes.
const SLOW_PATH_COST := 30
const WAYS := ["tracked", "walker", "wheeled", "hover", "flyer"]
## The table: way of moving -> [open, rough, ruins, water]. Mountains are a wall to every
## way but the flyer, which pays normal.
const WORDS := {
	"tracked": [NORMAL, NORMAL, SLOW, NORMAL],
	"walker": [NORMAL, NORMAL, NORMAL, SLOW],
	"wheeled": [FAST, SLOW, SLOW, SLOW],
	"hover": [NORMAL, SLOW, SLOW, FAST],
	"flyer": [NORMAL, NORMAL, NORMAL, NORMAL],
	"": [NORMAL, NORMAL, NORMAL, WALL],
}
const WORD_NAMES := {FAST: "fast", NORMAL: "normal", SLOW: "slow", WALL: "wall"}


## The way of moving among a unit's traits, or "" for none (the horde's rule).
static func way_of(traits: Array) -> String:
	for w in WAYS:
		if traits.has(w):
			return w
	return ""


## The word for this terrain under this way of moving: FAST, NORMAL, SLOW or WALL.
static func move_cost(t: int, traits: Array) -> int:
	var way := way_of(traits)
	if t == Terrain.MOUNTAIN:
		return NORMAL if way == "flyer" else WALL
	var row: Array = WORDS[way]
	match t:
		Terrain.ROUGH:
			return row[1]
		Terrain.RUINS:
			return row[2]
		Terrain.WATER:
			return row[3]
		_:
			return row[0]


static func move_word(t: int, traits: Array) -> String:
	return WORD_NAMES[move_cost(t, traits)]


## Whether a unit with these traits can enter this terrain at all.
static func passable(t: int, traits: Array) -> bool:
	return move_cost(t, traits) != WALL


## What entering this terrain spends of `left` move points, or -1 when it cannot be
## entered: a wall, a priced hex dearer than what is left, or a slow hex with nothing left.
## A slow hex spends everything left, which is how it ends the move.
static func spend(t: int, traits: Array, left: int) -> int:
	var c := move_cost(t, traits)
	if c == WALL:
		return -1
	if c == SLOW:
		return left if left > 0 else -1
	return c if c <= left else -1


## The terrain's word for every way of moving, for the terrain tap and the codex: the ways
## grouped by word, then the horde's rule.
static func ground_words(t: int) -> String:
	var by_word := {}
	for w in WAYS:
		var word := move_word(t, [w])
		if not by_word.has(word):
			by_word[word] = []
		by_word[word].append(w)
	var parts: Array[String] = []
	for word in ["fast", "normal", "slow", "wall"]:
		if by_word.has(word):
			parts.append("%s for %s" % [word, ", ".join(by_word[word])])
	var horde := move_cost(t, [])
	parts.append("packs cross" if horde != WALL else "packs never enter")
	return " · ".join(parts)


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
			var c := move_cost(t, traits)
			var nd := d + (SLOW_PATH_COST if c == SLOW else c)
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


## The horde's way to the gate (decided 2 October with the binary foe rule, widened 3
## October: water and crags are walls to a pack). Two guarantees. A path exists: when water
## and crags together cut the rift from the gate (7 of 200 seeds at the game's size), a
## corridor is carved, opening whatever is in the way. The narrowest crossing is at least
## CROSSING_WIDTH hexes: fewer than that many hexes never cut every foe route, so holding
## all the packs takes a line of three machines, never one or two. Each cut found is
## widened by the fewest openings that route the horde round it, until none is left.
func _ensure_ground_path(rng: RandomNumberGenerator) -> void:
	_carve_corridor(rng)
	for round in range(width * height):
		var cut := horde_cut(CROSSING_WIDTH)
		if cut.is_empty() or not _carve_around(cut, rng):
			return


func _carve_corridor(rng: RandomNumberGenerator) -> void:
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
		if not is_structure(cur) and not passable(terrain[cur], []):
			_open(cur)


## The horde's narrowest crossing in hexes (Ryan, 3 October; two until then): no fewer
## hexes than this together cut every foe route from the rift to the gate.
const CROSSING_WIDTH := 3


## The ground a pack may stand on between the rift and the gate: field, not structure,
## passable by the horde's rule.
func _horde_ground(h: Vector2i) -> bool:
	return has(h) and not is_structure(h) and passable(terrain[h], [])


## How many routes the horde has from the rift to the gate with no hex in common, counted up
## to `limit`: the width of the narrowest crossing, since that many hexes are the fewest
## that cut them all (Menger). Packs strike the gate from beside its apron, and come out of
## the rift onto the hexes around it.
func narrowest_crossing(limit: int = 9) -> int:
	return int(_horde_flow(limit)[0])


## The fewest hexes whose loss together cuts every foe route, when there are fewer than
## `limit` of them; empty when the crossing is at least that wide (or there is no route at
## all, which `_carve_corridor` mends first).
func horde_cut(limit: int = CROSSING_WIDTH) -> Array[Vector2i]:
	var res := _horde_flow(limit)
	var cut: Array[Vector2i] = []
	if int(res[0]) >= limit:
		return cut
	var reached: Dictionary = res[1]
	for h in terrain.keys():
		if reached.has(_flow_in(h)) and not reached.has(_flow_out(h)):
			cut.append(h)
	return cut


## Max flow with every hex of the horde's ground carrying one route: each hex is split into
## an in node and an out node joined by one unit of capacity. Returns [flow, the nodes the
## source still reaches in the residual graph]; that reach's edge is the minimum cut.
const _SOURCE := -1
const _SINK := -2


func _flow_in(h: Vector2i) -> Vector3i:
	return Vector3i(h.x, h.y, 0)


func _flow_out(h: Vector2i) -> Vector3i:
	return Vector3i(h.x, h.y, 1)


func _horde_flow(limit: int) -> Array:
	var src := Vector3i(0, 0, _SOURCE)
	var snk := Vector3i(0, 0, _SINK)
	var cap := {}    # [from, to] -> capacity left
	var adj := {}    # node -> the nodes an edge runs to, either way
	var link := func(a: Vector3i, b: Vector3i, c: int) -> void:
		cap[[a, b]] = int(cap.get([a, b], 0)) + c
		if not cap.has([b, a]):
			cap[[b, a]] = 0
		if not adj.has(a):
			adj[a] = []
		if not adj.has(b):
			adj[b] = []
		if not (adj[a] as Array).has(b):
			adj[a].append(b)
			adj[b].append(a)
	var big := width * height
	for h in terrain.keys():
		if not _horde_ground(h):
			continue
		link.call(_flow_in(h), _flow_out(h), 1)
		for n in Hex.neighbors(h):
			if _horde_ground(n):
				link.call(_flow_out(h), _flow_in(n), big)
			elif rift_hexes.has(n):
				link.call(src, _flow_in(h), big)
			elif gate_hexes.has(n):
				link.call(_flow_out(h), snk, big)
	var flow := 0
	var reached := {src: true}
	while true:
		# Breadth first through what capacity is left; every augmenting route carries one,
		# since every route crosses a hex.
		reached = {src: true}
		var prev := {}
		var queue: Array = [src]
		while not queue.is_empty() and not reached.has(snk):
			var cur: Vector3i = queue.pop_front()
			for nxt in adj.get(cur, []):
				if not reached.has(nxt) and int(cap[[cur, nxt]]) > 0:
					reached[nxt] = true
					prev[nxt] = cur
					queue.append(nxt)
		if not reached.has(snk) or flow >= limit:
			break
		var v := snk
		while v != src:
			var u: Vector3i = prev[v]
			cap[[u, v]] = int(cap[[u, v]]) - 1
			cap[[v, u]] = int(cap[[v, u]]) + 1
			v = u
		flow += 1
	return [flow, reached]


## Route the horde round a cut by the cheapest openings: the cheapest way from the rift to
## the gate where the horde's ground costs nothing, a crag costs one and water two (a gap
## in a ridge before another ford in the river, which is the map's one water feature), and
## the cut's own hexes are refused; its blocked hexes are opened. Seeded ties, so the same
## map widens the same way. False when there is no such way (the field's own edge).
func _carve_around(cut: Array[Vector2i], rng: RandomNumberGenerator) -> bool:
	var refused := {}
	for h in cut:
		refused[h] = true
	var dist := {}
	var prev := {}
	var frontier: Array = []
	for r in rift_hexes:
		for n in Hex.neighbors(r):
			if has(n) and not is_structure(n) and not refused.has(n) and not dist.has(n):
				dist[n] = _opening_cost(n)
				frontier.append([dist[n], n])
	var goal := Vector2i(1 << 20, 0)
	while not frontier.is_empty():
		var best := 0
		for i in range(1, frontier.size()):
			if frontier[i][0] < frontier[best][0]:
				best = i
		var top: Array = frontier.pop_at(best)
		var h: Vector2i = top[1]
		if int(top[0]) > int(dist[h]):
			continue
		var at_gate := false
		for n in Hex.neighbors(h):
			if gate_hexes.has(n):
				at_gate = true
		if at_gate:
			goal = h
			break
		var around := Hex.neighbors(h)
		for k in range(around.size() - 1, 0, -1):
			var j := rng.randi_range(0, k)
			var tmp: Vector2i = around[k]
			around[k] = around[j]
			around[j] = tmp
		for n in around:
			if not has(n) or is_structure(n) or refused.has(n):
				continue
			var nd: int = int(dist[h]) + _opening_cost(n)
			if not dist.has(n) or nd < int(dist[n]):
				dist[n] = nd
				prev[n] = h
				frontier.append([nd, n])
	if not dist.has(goal):
		return false
	var opened := false
	var cur := goal
	while true:
		if not passable(terrain[cur], []):
			_open(cur)
			opened = true
		if not prev.has(cur):
			break
		cur = prev[cur]
	return opened


func _opening_cost(h: Vector2i) -> int:
	if passable(terrain[h], []):
		return 0
	return 2 if terrain[h] == Terrain.WATER else 1


## Open a hex to the horde: plain ground, no crag, level.
func _open(h: Vector2i) -> void:
	opened[h] = terrain[h]
	terrain[h] = Terrain.PLAIN
	crag_base.erase(h)
	elevation[h] = 0
