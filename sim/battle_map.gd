class_name BattleMap
extends RefCounted

## The battlefield terrain. Rows run north (row 0, the rift) to south (last row, the gate).
## Generation is seeded, lays one of six shapes (KINDS), and guarantees the horde a way from
## the rift to the gate that no fewer than three hexes cut (the foe crossings: decided 2
## October, three wide 3 October).

enum Terrain { PLAIN, ROAD, ROUGH, RUINS, WATER, MOUNTAIN }

const TERRAIN_NAMES := {
	Terrain.PLAIN: "plain", Terrain.ROAD: "road", Terrain.ROUGH: "rough",
	Terrain.RUINS: "ruins", Terrain.WATER: "water", Terrain.MOUNTAIN: "mountain",
}

## A wall is named by what it is, one rule under every name (Ryan, 29 October: "the busted
## skyscraper that serves as a ruins crag, shouldn't be called a crag"): rock spikes are crags,
## the badlands' flat-topped rock mesas, the city's dead skyscrapers towers and the gorge's
## rock walls cliffs. Each is a vocabulary term, which the ground tap and a fight's label show.
const WALL_LOOKS := ["crags", "mesas", "towers", "cliffs"]

const ROAD_GAP_CHANCE := 0.18   # a laid road is missing this share of its slabs: nobody paves between attacks

var width: int = 7
var height: int = 20              # the rows from the rift's to the last wall row: a battle's is the ramp's (Ramp.depth_at, the long wall brief 3.1)
var terrain: Dictionary = {}  # Vector2i (axial) -> Terrain
var gate: Vector2i            # centre of the gate structure
var rift: Vector2i            # centre of the rift structure
var gate_hexes: Array[Vector2i] = []   # the gate: four wide on the apron row, three below, apron included
var rift_hexes: Array[Vector2i] = []
var wall_hexes: Array[Vector2i] = []   # the rest of the bottom GATE_ROWS rows: indestructible, nobody stands there
var crag_base: Dictionary = {}         # wall hex -> the ground under the rock: flavour only
var wall_look: Dictionary = {}         # wall hex -> what it is and is called (WALL_LOOKS)
var elevation: Dictionary = {}         # hex -> relief step 0..3 (water -1): landscape only, no rule reads it
var margin: Dictionary = {}            # hex beside the field -> terrain: scenery past the playable edge, never played on
var city: Dictionary = {}              # margin hex -> true: the city behind the wall, what the gate protects
const MARGIN_COLS := 4
const MARGIN_ROWS := 3                 # scenery rows beyond the rift
const CITY_ROWS := 2                   # city rows behind the wall
var map_seed: int = 0
var opened: Dictionary = {}            # hex -> the ground the horde's guarantee opened there (the map survey reads it)
var water_feature := ""               # "river", "fjord", "ponds", "a pond", or "" for none (the map survey reads it)
var fords: Array = []                  # a river's fords, each an Array of its hexes: the roads run to them
var ford_widths: Array = []            # each ford's width along the river, in hexes (_crossing_runs)
var gaps: Array = []                   # a city band's gaps, each an Array of its hexes: the streets run through them
var gap_widths: Array = []             # each gap's width across its band, in hexes (_crossing_runs)
var kind := "steppe"                   # the map's shape, a key of KINDS: the intel the player will read

## The map shapes (Ryan, 28 and 29 October): six, each testing one thing the movement rule
## prices, so the name on the front card is the whole intel and the intel is the shape. Each
## lays its own water and walls, its own decorative ground (one or two of the four, which all
## play alike, never all of them) and its own relief, and a battle that names no shape draws one
## by its seed, every shape alike, until a domain lean is decided (the bible's section 12).
## Every number in the laying is a placeholder; the 200-seed survey measures each
## (tools/map_survey.gd).
##   name: the front card's word; ground: what the field is laid in; dress: what the 3D map
##   stands on the land beside water (bank), at a wall's foot (foot) and out in the scenery
##   (scenery), each a prop's word for Map3D or "" for none.
const KINDS := {
	"river": {"name": "RIVER CROSSING", "ground": Terrain.PLAIN, "dress": {"bank": "reeds", "foot": "rocks", "scenery": "grass"}},
	"fjord": {"name": "FJORD", "ground": Terrain.PLAIN, "dress": {"bank": "shingle", "foot": "rocks", "scenery": "boulders"}},
	"badlands": {"name": "BADLANDS", "ground": Terrain.PLAIN, "dress": {"bank": "rocks", "foot": "", "scenery": ""}},
	"steppe": {"name": "OPEN STEPPE", "ground": Terrain.PLAIN, "dress": {"bank": "reeds", "foot": "rocks", "scenery": "grass"}},
	"city": {"name": "RUINED CITY", "ground": Terrain.RUINS, "dress": {"bank": "", "foot": "", "scenery": ""}},
	"gorge": {"name": "GORGE", "ground": Terrain.PLAIN, "dress": {"bank": "", "foot": "scree", "scenery": "boulders"}},
}

const STRUCTURE_HALF_WIDTH := 1   # gate and rift span centre plus this many hexes each side
## The gate and the walls are two rows deep: the models stand on the bottom row and the row
## above is their apron, so the wall never hides a unit behind it from the map camera
## (Ryan, 20 September). A pack strikes the gate from the row above the apron.
const GATE_ROWS := 2
## A shape lays its water and walls past the rift's mouth (mouth_rows) and short of the team's
## two rows above the gate's apron (_hi); the rows between are its open rows (_open_rows), which
## every shape is laid to fill at any size the ramp deals (9 November, the shapes relaid for the
## shallow field: the long wall brief's open item 5).
const MOUTH_FLOOR := 2   # the rift's row and the boss's: never laid on
const MOUTH_CAP := 4     # the old field's mouth; no depth needs more


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


## The shape a seed draws when a battle names none, every shape alike.
static func kind_for_seed(seed_value: int) -> String:
	var r := RandomNumberGenerator.new()
	r.seed = seed_value * 7919 + 101
	var keys: Array = KINDS.keys()
	return str(keys[r.randi_range(0, keys.size() - 1)])


## A seeded map of one shape, or of the shape its seed draws when `map_kind` names none.
static func generate(w: int, h: int, seed_value: int, map_kind: String = "") -> BattleMap:
	var m := flat(w, h)
	m.map_seed = seed_value
	m.kind = map_kind if KINDS.has(map_kind) else kind_for_seed(seed_value)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	m._lay_ground()
	match m.kind:
		"river":
			m._lay_river(rng)
		"fjord":
			m._lay_fjord(rng)
		"badlands":
			m._lay_badlands(rng)
		"city":
			m._lay_city(rng)
		"gorge":
			m._lay_gorge(rng)
		_:
			m._lay_steppe(rng)
	m._clear_ends()
	m._ensure_ground_path(rng)
	m._lay_roads(rng)
	m._lay_relief(rng)
	return m


## The rift's mouth: the rows at the rift's end that hold no water and no wall, the enemy's
## staging ground (the rift's row, the boss's, where the packs land and where a pack opens no
## nearer the rift; the seam starts a row past it). One row for every five of depth, rounded up,
## two at least and four at most: rows 0 to 2 at twelve deep, 0 to 3 at twenty (the old field's
## four), so a shallow field keeps rows for its shape. A placeholder (the long wall brief).
func mouth_rows() -> int:
	return clampi(ceili(float(height) / 5.0), MOUTH_FLOOR, MOUTH_CAP)


## The last row a shape lays water or a wall on: the team's two rows above the gate's apron
## stay clear, so a deployed machine always has somewhere to go.
func _hi() -> int:
	return height - GATE_ROWS - 3


## How many rows a shape has to lay in, the mouth's and the team's aside: five at twelve deep,
## twelve at twenty. A shape that needs more than it has lays less (a thinner river, one band
## of towers), never into the mouth or the team's rows.
func _open_rows() -> int:
	return _hi() - mouth_rows() + 1


## Every hex of the field and of the scenery beside it starts as the shape's ground, level;
## behind the wall the city stands in paved blocks, and the wall's rows run across the
## scenery bare.
func _lay_ground() -> void:
	var base: int = int(KINDS[kind]["ground"])
	for hx in terrain.keys():
		terrain[hx] = Terrain.PLAIN if is_structure(hx) else base
		elevation[hx] = 0
	for row in range(-MARGIN_ROWS, height):
		for col in range(-MARGIN_COLS, width + MARGIN_COLS):
			var hx := Hex.offset_to_axial(col, row)
			if not has(hx):
				margin[hx] = Terrain.PLAIN if row >= height - GATE_ROWS else base
				elevation[hx] = 0
	for row in range(height, height + CITY_ROWS):
		for col in range(-MARGIN_COLS, width + MARGIN_COLS):
			var hx := Hex.offset_to_axial(col, row)
			margin[hx] = Terrain.ROAD
			elevation[hx] = 0
			city[hx] = true


## The scenery a shape dresses and stands walls in: the margin past the field's edges, the city
## and the wall's rows aside.
func _scenery() -> Array:
	var out: Array = []
	for hx in margin.keys():
		if not city.has(hx) and Hex.axial_to_offset(hx).y < height - GATE_ROWS:
			out.append(hx)
	return out


## A wall on a hex of the field or of the scenery, called by its look; never on a structure,
## the city, water, another wall, or a row past _hi.
func _wall(hx: Vector2i, look: String) -> void:
	if Hex.axial_to_offset(hx).y > _hi() or city.has(hx) or is_structure(hx):
		return
	var under := terrain_of(hx)
	if under == Terrain.WATER or under == Terrain.MOUNTAIN:
		return
	if has(hx):
		terrain[hx] = Terrain.MOUNTAIN
	elif margin.has(hx):
		margin[hx] = Terrain.MOUNTAIN
	else:
		return
	crag_base[hx] = under
	wall_look[hx] = look


## Water on a hex of the field or of the scenery beside it, never on a structure, the city or
## the wall's rows.
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
	wall_look.erase(hx)
	elevation[hx] = -1


## Decorative ground on a hex of the field or the scenery: never over water, a wall, a
## structure, the city or the wall's rows.
func _dress_ground(hx: Vector2i, t: int) -> void:
	if Hex.axial_to_offset(hx).y >= height - GATE_ROWS or city.has(hx) or is_structure(hx):
		return
	var was := terrain_of(hx)
	if was == Terrain.WATER or was == Terrain.MOUNTAIN:
		return
	if has(hx):
		terrain[hx] = t
	elif margin.has(hx):
		margin[hx] = t


## The hexes within `r` of `hx`, itself aside.
static func _within(hx: Vector2i, r: int) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for dq in range(-r, r + 1):
		for dr in range(maxi(-r, -dq - r), mini(r, -dq + r) + 1):
			if dq != 0 or dr != 0:
				out.append(hx + Vector2i(dq, dr))
	return out


## Whether a group may take `hx`: one of `spots`, not water or a wall, and `gap` hexes at least
## from any water or wall that is not the group's own (`mine`).
func _free(hx: Vector2i, spots: Dictionary, mine: Dictionary, gap: int) -> bool:
	if not spots.has(hx):
		return false
	var t := terrain_of(hx)
	if t == Terrain.WATER or t == Terrain.MOUNTAIN:
		return false
	for n in _within(hx, gap):
		if mine.has(n) or not (has(n) or margin.has(n)):
			continue
		var u := terrain_of(n)
		if u == Terrain.WATER or u == Terrain.MOUNTAIN:
			return false
	return true


## A group of `size` hexes grown from a free spot among `spots`, a hex at a time beside it: a
## wall of `look`, or water when `look` is empty, `gap` hexes at least from any other. Returns
## the group, empty when no spot was free.
func _grow(rng: RandomNumberGenerator, spots: Array, size: int, look: String, gap: int) -> Array[Vector2i]:
	var group: Array[Vector2i] = []
	if spots.is_empty():
		return group
	var inside := {}
	for hx in spots:
		inside[hx] = true
	var mine := {}
	for attempt in range(40):
		var hx: Vector2i = spots[rng.randi_range(0, spots.size() - 1)]
		if _free(hx, inside, mine, gap):
			group.append(hx)
			mine[hx] = true
			break
	if group.is_empty():
		return group
	while group.size() < size:
		var options: Array[Vector2i] = []
		for g in group:
			for nb in Hex.neighbors(g):
				if not mine.has(nb) and not options.has(nb) and _free(nb, inside, mine, gap):
					options.append(nb)
		if options.is_empty():
			break
		var pick: Vector2i = options[rng.randi_range(0, options.size() - 1)]
		group.append(pick)
		mine[pick] = true
	for hx in group:
		if look.is_empty():
			_flood(hx)
		else:
			_wall(hx, look)
	return group


## The field's hexes on rows `lo` to `hi` and columns `west` to `east`, the structures aside.
func _field_spots(lo: int, hi: int, west: int = 0, east: int = -1) -> Array:
	var out: Array = []
	if east < 0:
		east = width - 1
	for hx in terrain.keys():
		var o := Hex.axial_to_offset(hx)
		if o.y >= lo and o.y <= hi and o.x >= west and o.x <= east and not is_structure(hx):
			out.append(hx)
	return out


## The crossings through a line `n` hexes long, a river's fords or a band's streets (Ryan, 29
## October: "we can allow more than one ford in a line, especially for the city map, and each
## can be smaller, as long as we have a total of say, 3 or 4 empty spaces. It symbolizes
## 'streets', and splitting the team up to cover them all forces the team to fight apart"):
## at most `most` runs of one to three hexes, three or four in all, every split of the total
## alike, spread at random along the line with at least a hex of it between two. A band takes
## up to four streets; a river two fords, since more broke it into ponds (29 October, its
## laying printed seed by seed). Each run as the indices it covers, west to east.
const CROSSING_RUN_MAX := 3
const STREETS_MOST := 4
const FORDS_MOST := 2


func _crossing_runs(rng: RandomNumberGenerator, n: int, most: int) -> Array:
	var splits: Array = []
	for total in [CROSSING_WIDTH, CROSSING_WIDTH + 1]:
		_splits_of(total, [], splits)
	var fit: Array = []
	for s in splits:
		if (s as Array).size() <= most and _span_of(s) <= n:
			fit.append(s)
	if fit.is_empty():
		return [range(0, n)]
	var widths: Array = fit[rng.randi_range(0, fit.size() - 1)]
	var slots: Array = []   # the spare hexes before, between and after the runs
	slots.resize(widths.size() + 1)
	slots.fill(0)
	for i in range(n - _span_of(widths)):
		var k := rng.randi_range(0, slots.size() - 1)
		slots[k] = int(slots[k]) + 1
	var runs: Array = []
	var at := int(slots[0])
	for i in range(widths.size()):
		runs.append(range(at, at + int(widths[i])))
		at += int(widths[i]) + 1 + int(slots[i + 1])
	return runs


## Every way to split `left` into runs of one to CROSSING_RUN_MAX, appended to `out`.
static func _splits_of(left: int, so_far: Array, out: Array) -> void:
	if left == 0:
		out.append(so_far.duplicate())
		return
	for w in range(1, mini(CROSSING_RUN_MAX, left) + 1):
		so_far.append(w)
		_splits_of(left - w, so_far, out)
		so_far.pop_back()


## The hexes a split takes along its line: its runs and a hex between each two.
static func _span_of(widths: Array) -> int:
	var span := widths.size() - 1
	for w in widths:
		span += int(w)
	return span


## RIVER CROSSING: a river across the field (along the wall) and on past both edges, two hexes
## thick and three where the field is deep, with one or two fords three or four hexes wide in
## all (_crossing_runs), at most a crag on a bank, and gravel bars in stretches along both
## banks (_shore). A bank row at the mouth's edge and one before the team's ground wherever
## the depth allows, so the river lies between two shores and is never a moat at the wall.
## Everyone but a hovercraft and a flyer wades the river at two a hex, the horde too, so a
## ford is the quick way across for both sides and a ford held only slows the horde. Tests
## the wade and where to cross. The line drifts about its row eastward, one hex at a time.
const RIVER_DEEP := 0.35   # a river hex with a third row below it
const BANK_CRAG := 0.4     # the chance of a crag on a bank


func _lay_river(rng: RandomNumberGenerator) -> void:
	var lo := mouth_rows()
	var hi := _hi()
	var open := _open_rows()
	var thick := 3 if open >= 7 else (2 if open >= 4 else 1)
	# A bank row at the mouth's edge and one before the team's ground where the field has them,
	# so the river is a thing between two shores and never a moat at the wall.
	var banked := open >= thick + 2
	var top := lo + 1 if banked else lo
	var bottom := maxi(top, (hi - thick) if banked else (hi - thick + 1))   # the line's southmost row, its thickening below it
	var drift := 2 if open >= 9 else 1   # how far the line wanders from its row
	var middle := (top + bottom) / 2
	var base := clampi(middle + rng.randi_range(-drift, drift), top, bottom)
	var line: Array[Vector2i] = []
	var cur := Hex.offset_to_axial(-MARGIN_COLS - 1, base)
	while Hex.axial_to_offset(cur).x <= width + MARGIN_COLS:
		line.append(cur)
		var steps: Array[Vector2i] = [Vector2i(1, 0), Vector2i(1, 0)]
		if cur.y > top and cur.y > base - drift:
			steps.append(Vector2i(1, -1))
		if cur.y < bottom and cur.y < base + drift:
			steps.append(Vector2i(0, 1))
		cur += steps[rng.randi_range(0, steps.size() - 1)]
	var rows_of := {}   # a line hex -> its hexes across the river's thickness, its own first
	for hx in line:
		var hexes: Array[Vector2i] = [hx]
		if thick >= 2:
			hexes.append(hx + Vector2i(0, 1))
		if thick >= 3 and rng.randf() < RIVER_DEEP:
			hexes.append(hx + Vector2i(-1, 2))
		rows_of[hx] = hexes
		for wet in hexes:
			_flood(wet)
	water_feature = "river"
	# The fords: runs of the line inside the field (_crossing_runs), back to open ground through
	# the river's whole thickness. Along the line, so a ford is as many hexes wide as it is
	# long, whichever way the river bends there.
	var inside: Array[Vector2i] = []
	for hx in line:
		if has(hx):
			inside.append(hx)
	for run in _crossing_runs(rng, inside.size(), FORDS_MOST):
		var ford: Array[Vector2i] = []
		for j in run:
			for hx in rows_of[inside[j]]:
				if has(hx) and terrain[hx] == Terrain.WATER:
					terrain[hx] = Terrain.PLAIN
					elevation[hx] = 0
					ford.append(hx)
		if not ford.is_empty():
			fords.append(ford)
			ford_widths.append((run as Array).size())
	if rng.randf() < BANK_CRAG:
		var banks: Array = []
		for hx in _field_spots(lo, hi, 1, width - 2):
			if terrain[hx] == Terrain.WATER:
				continue
			var wet := false
			for nb in Hex.neighbors(hx):
				wet = wet or terrain_of(nb) == Terrain.WATER
			var clear := true
			for ford in fords:
				for f in ford:
					clear = clear and Hex.distance(hx, f) >= 3
			if wet and clear:
				banks.append(hx)
		if not banks.is_empty():
			var at: Vector2i = banks[rng.randi_range(0, banks.size() - 1)]
			_wall(at, "crags")
			if rng.randf() < 0.5:
				for nb in Hex.neighbors(at):
					if banks.has(nb):
						_wall(nb, "crags")
						break
	_shore(Terrain.WATER, SHORE_SHARE)


## FJORD: water down the field from the rift's mouth to the team's ground, two hexes wide and
## three in places, drifting a column at most a row (so no land crosses it) with lanes two
## wide at least either side, and shingle in stretches along its shores (_shore). On a wide
## field one fjord for every ten hexes of wall (two on twenty, three on thirty), each in a
## stretch of the wall of its own with a lane two wide at least at the field's edges and four
## between two, so the wall is cut into sectors: the packs walk the lanes, and a ground squad
## and a hunter alike wade from one to the other at two a hex where a hover and a flyer cross
## at one. Tests lane choice and a detachment across water.
const FJORD_DRIFT := 0.35   # the chance a row's water sits a column over from the row above's
const FJORD_WIDE := 0.3     # the chance a row is three wide
const FJORD_PER := 10       # hexes of wall a fjord
const FJORD_MOST := 3


## How many fjords the width takes: one for every FJORD_PER hexes of wall, one at least.
func _fjord_count() -> int:
	return clampi(roundi(float(width) / float(FJORD_PER)), 1, FJORD_MOST)


func _lay_fjord(rng: RandomNumberGenerator) -> void:
	var n := _fjord_count()
	var laid := 0
	for i in range(n):
		# The fjord's stretch of the wall, a lane two wide kept at each side of it.
		var west_most := (width * i) / n + 2
		var east_most := (width * (i + 1)) / n - 1 - 2   # the eastmost column its water may take
		if east_most - west_most + 1 < 2:
			continue   # a field too narrow for a lane either side lays none here
		var west := rng.randi_range(west_most, maxi(west_most, east_most - 2))
		for row in range(mouth_rows(), _hi() + 1):
			var wide := 3 if rng.randf() < FJORD_WIDE else 2
			wide = mini(wide, east_most - west_most + 1)
			if row > mouth_rows() and rng.randf() < FJORD_DRIFT:
				west += -1 if rng.randf() < 0.5 else 1
			west = clampi(west, west_most, east_most - wide + 1)
			for c in range(west, west + wide):
				_flood(Hex.offset_to_axial(c, row))
		laid += 1
	water_feature = "fjord" if laid > 0 else ""
	_shore(Terrain.WATER, SHORE_SHARE)


## BADLANDS: mesas in groups of two to four with a hex between groups at least, and two or
## three ponds of two or three hexes, breaking the field into winding paths; scrub at the
## mesas' feet and out in the scenery, dry ground between. Tests everything at once, and the
## longest walks.
func _lay_badlands(rng: RandomNumberGenerator) -> void:
	var spots := _field_spots(mouth_rows(), _hi())
	for g in range(maxi(2, spots.size() / 15)):
		_grow(rng, spots, rng.randi_range(3, 5), "mesas", 1)
	var ponds := 0
	for p in range(rng.randi_range(2, 3)):
		if not _grow(rng, spots, rng.randi_range(2, 3), "", 1).is_empty():
			ponds += 1
	water_feature = "ponds" if ponds > 1 else ("a pond" if ponds == 1 else "")
	var scenery := _scenery()
	for g in range(rng.randi_range(5, 8)):
		_grow(rng, scenery, rng.randi_range(2, 4), "mesas", 1)
	for hx in scenery:
		_dress_ground(hx, Terrain.ROUGH)
	for hx in wall_look.keys():
		for nb in Hex.neighbors(hx):
			_dress_ground(nb, Terrain.ROUGH)


## OPEN STEPPE: relatively clear, the baseline the others are read against: a lone crag at
## most and a pond at most for every ten hexes of wall (one of each on the old field of nine,
## two on twenty: the same clear ground at any width), and the odd crag out in the scenery.
const STEPPE_CRAG := 0.5
const STEPPE_POND := 0.5
const STEPPE_PER := 10   # hexes of wall a crag and a pond at most


## How many crags, and how many ponds, the steppe may take: one each for every STEPPE_PER
## hexes of wall, one at least.
func _steppe_count() -> int:
	return maxi(1, width / STEPPE_PER)


func _lay_steppe(rng: RandomNumberGenerator) -> void:
	var spots := _field_spots(mouth_rows() + 1, _hi() - 1, 1, width - 2)
	var ponds := 0
	for i in range(_steppe_count()):
		if rng.randf() < STEPPE_CRAG:
			_grow(rng, spots, 1, "crags", 2)
		if rng.randf() < STEPPE_POND and not _grow(rng, spots, rng.randi_range(2, 3), "", 2).is_empty():
			ponds += 1
	water_feature = "ponds" if ponds > 1 else ("a pond" if ponds == 1 else "")
	var scenery := _scenery()
	for g in range(rng.randi_range(1, 3)):
		_grow(rng, scenery, rng.randi_range(1, 2), "crags", 2)


## RUINED CITY: bands of towers across the field (along the wall) and on past both edges, one
## or two hexes thick, two bands on a deep field (nine open rows or more) and one on a shallow,
## a band standing mid the open rows with a row of rubble before it and after it wherever the
## depth allows, each with streets through it three or four hexes wide in all, one to four of
## them (_crossing_runs); rubble everywhere else, and towers standing in the scenery as the
## city goes on. Tests the streets held, a machine to a street and the team fighting apart,
## and the flyer's one crossing of its own.
const CITY_SCENERY_TOWERS := 0.22   # the share of the scenery a tower stands on


func _lay_city(rng: RandomNumberGenerator) -> void:
	var lo := mouth_rows()
	var hi := _hi()
	var bands: Array = []   # [the band's northmost row, its thickness]
	var t1 := rng.randi_range(1, 2)
	if _open_rows() >= 9:
		var r1 := rng.randi_range(lo + 1, lo + 3)
		var t2 := rng.randi_range(1, 2)
		var first := r1 + t1 + 3   # three rows of street between the bands at least
		var r2 := rng.randi_range(first, maxi(first, hi - t2))   # and a row clear before the team's ground
		bands = [[r1, t1], [r2, t2]]
	else:
		t1 = mini(t1, maxi(1, _open_rows() - 2))
		var first := lo + 1   # a row of rubble at the mouth's edge
		var last := hi - t1   # and one before the team's ground
		if last < first:
			first = lo
			last = maxi(lo, hi - t1 + 1)
		bands = [[rng.randi_range(first, last), t1]]
	for band in bands:
		var open := {}
		for run in _crossing_runs(rng, width, STREETS_MOST):
			var gap: Array[Vector2i] = []
			for c in run:
				open[c] = true
				for row in range(int(band[0]), int(band[0]) + int(band[1])):
					gap.append(Hex.offset_to_axial(c, row))
			gaps.append(gap)
			gap_widths.append((run as Array).size())
		for row in range(int(band[0]), int(band[0]) + int(band[1])):
			for col in range(-MARGIN_COLS, width + MARGIN_COLS):
				if not open.has(col):
					_wall(Hex.offset_to_axial(col, row), "towers")
	for hx in _scenery():
		if rng.randf() < CITY_SCENERY_TOWERS:
			_wall(hx, "towers")


## GORGE: cliff walls down the field from the rift's mouth to the team's ground, one hex
## thick, one for every six hexes of wall (one on a field of seven, two on nine, three on
## twenty, four at most), each in a stretch of the wall of its own, drifting a column at most
## a row (a hex below another is beside it only one way at each row's parity, odd rows sitting
## half a hex east), with lanes two hexes wide at least between and beside them, so the wall is
## cut into sectors no ground machine crosses between but round a cliff's end; scree in
## stretches at the cliffs' feet (_shore); the gorge's own sides stand in the scenery past both
## edges. Tests the hardest commitment to a lane, changed only round a wall's ends.
const GORGE_DRIFT := 0.3
const GORGE_PER := 6     # hexes of wall a cliff wall
const GORGE_MOST := 4
const CLIFF_GAP := 3     # columns between two cliffs: a lane two wide


## How many cliff walls the width takes: one for every GORGE_PER hexes of wall, one at least.
func _cliff_count() -> int:
	return clampi(roundi(float(width) / float(GORGE_PER)), 1, GORGE_MOST)


func _lay_gorge(rng: RandomNumberGenerator) -> void:
	var n := _cliff_count()
	var cols: Array[int] = []
	for i in range(n):
		cols.append((width * (2 * i + 1)) / (2 * n) + rng.randi_range(-1, 1))   # about its stretch's middle
	# The lanes: two wide at the field's edges and between two cliffs, pushed in from both ends.
	cols[0] = maxi(cols[0], 2)
	for i in range(1, n):
		cols[i] = maxi(cols[i], cols[i - 1] + CLIFF_GAP)
	cols[n - 1] = mini(cols[n - 1], width - 3)
	for i in range(n - 2, -1, -1):
		cols[i] = mini(cols[i], cols[i + 1] - CLIFF_GAP)
	while cols.size() > 1 and cols[0] < 2:
		cols.pop_back()   # a field too narrow for them all: fewer cliffs
		cols[cols.size() - 1] = mini(cols[cols.size() - 1], width - 3)
		for i in range(cols.size() - 2, -1, -1):
			cols[i] = mini(cols[i], cols[i + 1] - CLIFF_GAP)
	n = cols.size()
	for row in range(mouth_rows(), _hi() + 1):
		for i in range(n):
			if row > mouth_rows() and rng.randf() < GORGE_DRIFT:
				var c: int = cols[i] + (-1 if (row - 1) % 2 == 0 else 1)
				var ok := c >= 2 and c <= width - 3
				if i > 0:
					ok = ok and c - cols[i - 1] >= CLIFF_GAP
				if i < n - 1:
					ok = ok and cols[i + 1] - c >= CLIFF_GAP
				if ok:
					cols[i] = c
			_wall(Hex.offset_to_axial(cols[i], row), "cliffs")
	for row in range(0, _hi() + 1):
		_wall(Hex.offset_to_axial(-1, row), "cliffs")
		_wall(Hex.offset_to_axial(width, row), "cliffs")
	_shore(Terrain.MOUNTAIN, SHORE_SHARE)


## Rough ground in stretches along the water's edge or at a wall's foot: a river's gravel bars,
## a fjord's shingle, a gorge's scree, the shape's second decorative ground (the bible's shapes
## row: one or two a shape, laid to be read). From a seeded noise, so it comes in runs rather
## than per-hex rolls (Ryan, 21 September: a believable landscape), on about `share` of the
## plain hexes of the field and the scenery beside `beside` (water or a wall); never over a
## road, water or a wall, and the ground in front of a structure is bared after (_clear_ends).
const SHORE_SHARE := 0.45


func _shore(beside: int, share: float) -> void:
	var noise := FastNoiseLite.new()
	noise.seed = map_seed + 505
	noise.frequency = 0.3
	noise.fractal_type = FastNoiseLite.FRACTAL_NONE
	var threshold := 1.0 - 2.0 * share
	for hx in terrain.keys() + _scenery():
		if terrain_of(hx) != Terrain.PLAIN:
			continue
		var by := false
		for n in Hex.neighbors(hx):
			by = by or ((has(n) or margin.has(n)) and terrain_of(n) == beside)
		if not by:
			continue
		var p := Hex.to_pixel(hx, 1.0)
		if noise.get_noise_2d(p.x, p.y) > threshold:
			_dress_ground(hx, Terrain.ROUGH)


## The gate, the rift and the ground right in front of each are always open and bare; the
## rift's mouth (mouth_rows, the boss's patrol) and the team's two rows above the gate's
## apron hold no water and no wall, so a deployed machine always has somewhere to go.
func _clear_ends() -> void:
	var base: int = int(KINDS[kind]["ground"])
	for hx in terrain.keys():
		if is_structure(hx):
			continue
		var row := Hex.axial_to_offset(hx).y
		var near := false
		for n in Hex.neighbors(hx):
			near = near or gate_hexes.has(n) or rift_hexes.has(n)
		var t: int = terrain[hx]
		if near:
			terrain[hx] = Terrain.PLAIN
		elif (row < mouth_rows() or row > _hi()) and (t == Terrain.WATER or t == Terrain.MOUNTAIN):
			terrain[hx] = base
		else:
			continue
		crag_base.erase(hx)
		wall_look.erase(hx)


## The roads lead somewhere (Ryan, 29 October): the river's from the gate to each ford two
## hexes wide or more (to the nearest ford when none is) and on across it, the steppe's one road
## north from the gate, the city's streets from the gate through a gap of every band and on
## toward the rift, its other gaps joined to them. The fjord, the badlands and the gorge lay
## none. A road keeps its gaps (nobody paves between attacks) but for its first slabs off the
## gate, never routes through or paves water or a wall, and is never a lone slab.
func _lay_roads(rng: RandomNumberGenerator) -> void:
	var o := Hex.axial_to_offset(gate)
	var front := Hex.offset_to_axial(o.x, o.y - GATE_ROWS)   # in front of the gate, above its apron
	var wet := _wet()
	var paths: Array = []
	match kind:
		"river":
			var roaded: Array = []
			for i in range(fords.size()):
				if int(ford_widths[i]) >= 2:
					roaded.append(i)
			if roaded.is_empty() and not fords.is_empty():
				var near := 0
				for i in range(fords.size()):
					if Hex.distance(front, _ends_of(fords[i])[0]) < Hex.distance(front, _ends_of(fords[near])[0]):
						near = i
				roaded.append(near)
			for i in roaded:
				var ends := _ends_of(fords[i])
				var path: Array = [front]
				path.append_array(find_path(front, ends[0], [], wet))
				path.append_array(find_path(ends[0], ends[1], [], wet))
				path.append_array(find_path(ends[1], _north_of(ends[1], rng.randi_range(3, 5)), [], wet))
				paths.append(path)
		"steppe":
			paths.append(_trunk(front, rng))
		"city":
			var bands := {}   # a band's northmost row -> its gaps by index, so the street meets the bands south to north
			for i in range(gaps.size()):
				var row := (_ends_of(gaps[i])[1] as Vector2i).y
				if not bands.has(row):
					bands[row] = []
				bands[row].append(i)
			var rows: Array = bands.keys()
			rows.sort()
			rows.reverse()
			var street: Array = [front]
			var cur := front
			var joined := {}
			for row in rows:
				var best: int = bands[row][0]
				for i in bands[row]:
					if Hex.distance(cur, _ends_of(gaps[i])[0]) < Hex.distance(cur, _ends_of(gaps[best])[0]):
						best = i
				var ends := _ends_of(gaps[best])
				street.append_array(find_path(cur, ends[0], [], wet))
				street.append_array(find_path(ends[0], ends[1], [], wet))
				cur = ends[1]
				joined[best] = true
			street.append_array(find_path(cur, _north_of(cur, height), [], wet))
			paths.append(street)
			for i in range(gaps.size()):
				if joined.has(i):
					continue
				var ends := _ends_of(gaps[i])
				var near: Vector2i = street[0]
				for hx in street:
					if Hex.distance(ends[0], hx) < Hex.distance(ends[0], near):
						near = hx
				var branch: Array = [near]
				branch.append_array(find_path(near, ends[0], [], wet))
				branch.append_array(find_path(ends[0], ends[1], [], wet))
				paths.append(branch)
	for path in paths:
		for i in range(path.size()):
			var h: Vector2i = path[i]
			if not has(h) or is_structure(h) or not _dry(h):
				continue
			if i >= 3 and rng.randf() < ROAD_GAP_CHANCE:
				continue
			terrain[h] = Terrain.ROAD
	# A road is never a lone slab: a road hex with no road (or gate) beside it goes back to the
	# shape's ground.
	var lone: Array[Vector2i] = []
	for h in terrain.keys():
		if terrain[h] != Terrain.ROAD:
			continue
		var joined_up := false
		for n in Hex.neighbors(h):
			if terrain.get(n, -1) == Terrain.ROAD or gate_hexes.has(n):
				joined_up = true
		if not joined_up:
			lone.append(h)
	for h in lone:
		terrain[h] = int(KINDS[kind]["ground"])


## The steppe's road: north from the gate with drift, most of the way to the rift (Ryan, 21
## September: the road need not reach it), steering round water and crags where it can.
func _trunk(front: Vector2i, rng: RandomNumberGenerator) -> Array:
	var trunk: Array = [front]
	var cur := front
	for i in range(int(float(height) * rng.randf_range(0.55, 0.8))):
		var options: Array[Vector2i] = []
		var any: Array[Vector2i] = []
		for n in Hex.neighbors(cur):
			if has(n) and n.y < cur.y and not is_structure(n):
				any.append(n)
				if _dry(n):
					options.append(n)
		if options.is_empty():
			options = any
		if options.is_empty():
			break
		cur = options[rng.randi_range(0, options.size() - 1)]
		trunk.append(cur)
	return trunk


## Land a road may pave: neither water nor a wall.
func _dry(h: Vector2i) -> bool:
	return terrain[h] != Terrain.WATER and terrain[h] != Terrain.MOUNTAIN


## The water hexes, which a road never routes through.
func _wet() -> Dictionary:
	var out := {}
	for h in terrain.keys():
		if terrain[h] == Terrain.WATER:
			out[h] = true
	return out


## Where a road enters a ford or a gap from the south and leaves it to the north: the middle
## hex of its southmost row and of its northmost.
func _ends_of(hexes: Array) -> Array:
	var rows := {}
	for hx in hexes:
		if not rows.has(hx.y):
			rows[hx.y] = []
		rows[hx.y].append(hx)
	var keys: Array = rows.keys()
	keys.sort()
	var north: Array = rows[keys[0]]
	var south: Array = rows[keys[keys.size() - 1]]
	north.sort()
	south.sort()
	return [south[south.size() / 2], north[north.size() / 2]]


## A hex `rows` rows north of `hx` in its column, short of the rift's mouth.
func _north_of(hx: Vector2i, rows: int) -> Vector2i:
	var o := Hex.axial_to_offset(hx)
	return Hex.offset_to_axial(o.x, maxi(mouth_rows(), o.y - rows))


## The relief is the shape's (Ryan, 29 October, of the 3D: "I like the look but maybe it's a
## bit too much for the phone screen"): height is landscape and no rule reads it, so it rises
## only along the shape's landforms and never in a lane. The field is level but for the
## badlands' mesas on their shoulders and the steppe's one broad rise; the valleys' sides rise
## out in the scenery, away from the river, the fjord and the gorge, and the steppe's scenery
## rolls. At most two steps on the field and three in the scenery, eased up from the field's
## edge and down to the wall's rows, and never a lone hex (_settle_relief).
const STEPPE_RISE := 0.6   # the chance of the steppe's one rise


func _lay_relief(rng: RandomNumberGenerator) -> void:
	var want := {}   # hex -> the step the shape wants there
	match kind:
		"badlands":
			for hx in wall_look.keys():
				want[hx] = 1
				for n in Hex.neighbors(hx):
					want[n] = 1
		"steppe":
			_steppe_rise(rng, want)
			var roll := FastNoiseLite.new()
			roll.seed = map_seed + 404
			roll.frequency = 0.12
			roll.fractal_type = FastNoiseLite.FRACTAL_NONE
			for hx in _scenery():
				var p := Hex.to_pixel(hx, 1.0)
				want[hx] = clampi(int(floor((roll.get_noise_2d(p.x, p.y) + 0.35) * 2.5)), 0, 2)
		"river":
			var dist := _water_distance()
			for hx in _scenery():
				want[hx] = clampi(int(dist.get(hx, 9)) - 1, 0, 3)
		"fjord", "gorge":
			for hx in _scenery():
				want[hx] = 3
	for hx in elevation.keys():
		if terrain_of(hx) == Terrain.WATER:
			elevation[hx] = -1
		elif _level(hx):
			elevation[hx] = 0
		elif has(hx):
			elevation[hx] = mini(int(want.get(hx, 0)), 2)
		else:
			elevation[hx] = mini(int(want.get(hx, 0)), _scenery_cap(hx))
	_settle_relief()


## The steppe's one broad rise, at most: a hill a step up, three hexes across or so, clear of
## the road, the water and the crag by two.
func _steppe_rise(rng: RandomNumberGenerator, want: Dictionary) -> void:
	if rng.randf() >= STEPPE_RISE:
		return
	var options: Array = []
	for hx in _field_spots(mouth_rows() + 1, _hi() - 1, 2, width - 3):
		var clear := true
		for n in _within(hx, 2):
			var t := terrain_of(n)
			clear = clear and t != Terrain.ROAD and t != Terrain.WATER and t != Terrain.MOUNTAIN
		if clear:
			options.append(hx)
	if options.is_empty():
		return
	var c: Vector2i = options[rng.randi_range(0, options.size() - 1)]
	want[c] = 1
	for n in _within(c, 2):
		var t := terrain_of(n)
		if has(n) and t != Terrain.ROAD and t != Terrain.WATER and t != Terrain.MOUNTAIN and (Hex.distance(n, c) == 1 or rng.randf() < 0.4):
			want[n] = 1


## Every hex's distance from the nearest water, across the field and the scenery.
func _water_distance() -> Dictionary:
	var dist := {}
	var queue: Array = []
	for hx in terrain.keys() + margin.keys():
		if terrain_of(hx) == Terrain.WATER:
			dist[hx] = 0
			queue.append(hx)
	while not queue.is_empty():
		var cur: Vector2i = queue.pop_front()
		for n in Hex.neighbors(cur):
			if (has(n) or margin.has(n)) and not dist.has(n):
				dist[n] = int(dist[cur]) + 1
				queue.append(n)
	return dist


## The ground that stays level whatever the shape wants: the structures and the ground in
## front of them, the team's rows and the gate's, the roads, the city and the wall's rows in
## the scenery (the scenery beside the team's rows eases down to them, _scenery_cap).
func _level(hx: Vector2i) -> bool:
	var row := Hex.axial_to_offset(hx).y
	if city.has(hx) or is_structure(hx):
		return true
	if not has(hx):
		return row >= height - GATE_ROWS
	if row > _hi() or terrain[hx] == Terrain.ROAD:
		return true
	for n in Hex.neighbors(hx):
		if gate_hexes.has(n) or rift_hexes.has(n):
			return true
	return false


## How high the scenery may rise at a hex: a step a column (or a row) past the field's edge,
## and a step a row less toward the wall's rows, so the scenery eases down to the wall.
func _scenery_cap(hx: Vector2i) -> int:
	var o := Hex.axial_to_offset(hx)
	var d := 0
	if o.x < 0:
		d = -o.x
	elif o.x >= width:
		d = o.x - width + 1
	if o.y < 0:
		d = maxi(d, -o.y)
	return clampi(mini(d, height - GATE_ROWS - 1 - o.y), 0, 3)


## Never a lone hex: a land hex whose every land neighbour, three at least, stands at another
## height takes the commonest of theirs (the lower on a tie), the level ground aside, until
## none is left.
func _settle_relief() -> void:
	var land: Array = []
	for hx in elevation.keys():
		if int(elevation[hx]) >= 0 and not _level(hx):
			land.append(hx)
	for round in range(6):
		var changed := false
		for hx in land:
			var e: int = elevation[hx]
			var count := {}
			var n_land := 0
			var same := false
			for n in Hex.neighbors(hx):
				if not elevation.has(n) or int(elevation[n]) < 0:
					continue
				n_land += 1
				if int(elevation[n]) == e:
					same = true
					break
				count[int(elevation[n])] = int(count.get(int(elevation[n]), 0)) + 1
			if same or n_land < 3:
				continue
			var best := -1
			var best_n := 0
			for f in count.keys():
				if int(count[f]) > best_n or (int(count[f]) == best_n and int(f) < best):
					best = int(f)
					best_n = int(count[f])
			elevation[hx] = best
			changed = true
		if not changed:
			break


## The ground's word, a vocabulary id: a wall by what it is (WALL_LOOKS), the rest by their
## terrain.
func ground_id(h: Vector2i) -> String:
	var t := terrain_of(h)
	if t == Terrain.MOUNTAIN:
		return str(wall_look.get(h, WALL_LOOKS[0]))
	return str(TERRAIN_NAMES[t])


## Every ground word the map can show, for the vocabulary's check: each terrain's but the
## wall class's, and the walls by their looks.
static func ground_ids() -> Array:
	var out: Array = []
	for t in TERRAIN_NAMES.keys():
		if t != Terrain.MOUNTAIN:
			out.append(TERRAIN_NAMES[t])
	out.append_array(WALL_LOOKS)
	return out


func has(h: Vector2i) -> bool:
	return terrain.has(h)


func terrain_at(h: Vector2i) -> int:
	return terrain.get(h, Terrain.MOUNTAIN)


func all_hexes() -> Array:
	return terrain.keys()


## Movement in hexes (Ryan, 27 and 28 October; bible section 4): a step is one hex, and the
## ground is ground. Open ground (plain and road, the road being art), rough and ruins cost
## everyone a step; rough and ruins are landscape like height, and no rule reads them. Water
## is the one priced ground: a ground machine (tracked, walker, wheeled) wades it at two of
## its move a hex and can always enter one with whatever move it has left; a hovercraft and a
## flyer cross it at a step. Crags are a wall to all but a flyer. A pack carries no trait
## unless its foe is winged and moves as the horde does (Ryan, 2 October: the Final Fantasy
## overworld rule): every land hex at a step, water and crags walls; a winged pack crosses
## both as a flyer does (28 October). A way of moving is the model, the footfall and a word a
## passive may read; beyond this table it is never a rule.
const STEP := 1
const WADE := 2
const WALL := -1
## The machines' ways of moving, exactly one a chassis (the validator and the survey read them).
const WAYS := ["tracked", "walker", "wheeled", "hover", "flyer"]
## The crossing table: a word -> [water, walls], each a step's cost or WALL; every other
## ground is a STEP to everyone. "winged" is a pack's word, never a chassis's; "" is the
## horde's rule, which wades water as a ground machine does (Ryan, 29 October: "Enemies can
## cross water just like player units, since that seems fair").
const CROSSINGS := {
	"tracked": [WADE, WALL],
	"walker": [WADE, WALL],
	"wheeled": [WADE, WALL],
	"hover": [STEP, WALL],
	"flyer": [STEP, STEP],
	"winged": [STEP, STEP],
	"": [WADE, WALL],
}


## The word among a unit's traits the crossing table reads: its way of moving, "winged" for a
## winged pack, or "" for none (the horde's rule).
static func way_of(traits: Array) -> String:
	for w in WAYS:
		if traits.has(w):
			return w
	if traits.has("winged"):
		return "winged"
	return ""


## What one step onto this terrain costs a unit with these traits: STEP, WADE or WALL.
static func step_cost(t: int, traits: Array) -> int:
	var row: Array = CROSSINGS[way_of(traits)]
	if t == Terrain.WATER:
		return int(row[0])
	if t == Terrain.MOUNTAIN:
		return int(row[1])
	return STEP


## Whether a unit with these traits can enter this terrain at all.
static func passable(t: int, traits: Array) -> bool:
	return step_cost(t, traits) != WALL


## What entering this terrain spends of `left` move, or -1 when it cannot be entered: a wall,
## or no move left. A wade costs two and can always be entered with whatever is left, so a
## step never spends more than remains (Ryan, 28 October: a move of 1 wades a hex a turn, a
## move of 3 two).
static func spend(t: int, traits: Array, left: int) -> int:
	var c := step_cost(t, traits)
	if c == WALL or left <= 0:
		return -1
	return mini(c, left)


## The terrain's word for every machine's way of moving, for the ground tap: [word, ways] for
## "wade", "cross" and "wall" in that order, each only when some way gets it, the ways in WAYS
## order. The packs' rule is the screen's, read from `step_cost` with no trait and with
## "winged".
static func ground_ways(t: int) -> Array:
	var by_word := {"wade": [], "cross": [], "wall": []}
	for w in WAYS:
		var c := step_cost(t, [w])
		var word := "wall" if c == WALL else ("wade" if c == WADE else "cross")
		(by_word[word] as Array).append(w)
	var out: Array = []
	for word in ["wade", "cross", "wall"]:
		if not (by_word[word] as Array).is_empty():
			out.append([word, by_word[word]])
	return out


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
			var nd := d + step_cost(t, traits)
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


## The horde's way to the gate (3 October; since 29 October the horde wades water, so only
## walls cut it). Two guarantees. A path exists: when walls cut the rift from the gate, a
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
## passable by the horde's rule (land and water; never a wall).
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
## the gate where the horde's ground costs nothing and a wall one, and the cut's own hexes
## are refused; its walls are opened. Seeded ties, so the same map widens the same way.
## False when there is no such way (the field's own edge).
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
	return 0 if passable(terrain[h], []) else 1


## Open a hex to the horde: plain ground, no crag, level.
func _open(h: Vector2i) -> void:
	opened[h] = terrain[h]
	terrain[h] = Terrain.PLAIN
	crag_base.erase(h)
	wall_look.erase(h)
	elevation[h] = 0
