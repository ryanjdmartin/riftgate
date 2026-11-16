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
var narrows: Array = []                # a river's narrows, each an Array of its hexes (water a hex thick, the short wade): the roads run to them
var narrow_widths: Array = []          # each narrow's length along the river, in hexes
var streets: Array = []                # the city's streets, each an Array of its hexes from the wall's end: the roads run along them (_lay_roads)
var kind := "steppe"                   # the map's shape, a key of KINDS: the intel the player will read

## The map shapes (Ryan, 28 and 29 October): six, each testing one thing the movement rule
## prices, so the name on the front card is the whole intel and the intel is the shape. Each
## lays its own water and walls, its own decorative ground (one or two of the four, which all
## play alike, never all of them) and its own relief, and a battle that names no shape draws one
## by its seed, every shape alike, until a domain lean is decided (the bible's section 12).
## On the long wall (Ryan, 9 November) the three wall shapes are a spectrum by the mass and the
## structure of what blocks you, none a band and none an orientation: the GORGE winding,
## branching channels through cliff mass; the RUINED CITY channels broken by side streets
## between large blocks of towers; the BADLANDS an open field of small obstacles no straight
## path crosses. Water lies in all three (flooded channels, flooded streets and fountains,
## ponds). The RIVER CROSSING and the FJORD are the water shapes and the OPEN STEPPE the
## baseline. Every number in the laying is a placeholder; the 200-seed survey measures each
## (tools/map_survey.gd).
##   name: the front card's word; ground: what the field is laid in; dress: what the 3D map
##   stands on the land beside water (bank), at a wall's foot (foot), out in the scenery
##   (scenery) and on the open field itself (field, sparse), each a prop's word for Map3D or ""
##   for none.
const KINDS := {
	"river": {"name": "RIVER CROSSING", "ground": Terrain.PLAIN, "dress": {"bank": "reeds", "foot": "rocks", "scenery": "grass", "field": ""}},
	"fjord": {"name": "FJORD", "ground": Terrain.PLAIN, "dress": {"bank": "shingle", "foot": "rocks", "scenery": "boulders"}},
	"badlands": {"name": "BADLANDS", "ground": Terrain.PLAIN, "dress": {"bank": "rocks", "foot": "", "scenery": ""}},
	"steppe": {"name": "OPEN STEPPE", "ground": Terrain.PLAIN, "dress": {"bank": "reeds", "foot": "rocks", "scenery": "grass", "field": "grass"}},
	"city": {"name": "RUINED CITY", "ground": Terrain.RUINS, "dress": {"bank": "", "foot": "", "scenery": ""}},
	"gorge": {"name": "GORGE", "ground": Terrain.PLAIN, "dress": {"bank": "", "foot": "scree", "scenery": "boulders"}},
}

const STRUCTURE_HALF_WIDTH := 1   # gate and rift span centre plus this many hexes each side
## The gate and the walls are two rows deep: the models stand on the bottom row and the row
## above is their apron, so the wall never hides a unit behind it from the map camera
## (Ryan, 20 September). A pack strikes the gate from the row above the apron.
const GATE_ROWS := 2
const RIFT_ROWS := 2   # the rows the rift's five hexes lie on: its own, and the next, where two of them stand in front of its middle
## A shape lays its water and walls from the rift's row to the last row short of the team's two
## rows above the gate's apron (_hi); the rows between are its open rows (_open_rows), which every
## shape is laid to fill at any size the ramp deals (9 November, the shapes relaid for the shallow
## field: the long wall brief's open item 5). The rift's mouth is the ground beside the rift and
## nothing more, bared by _clear_ends with the gate's front (Ryan, 10 November, after his play: "the
## flattened side needs features, all the way to the back"; until then the mouth was rows, four on
## the old field and a share of the depth for a day).
const FIRST_ROW := 0   # the first row a shape lays on: the rift's own


## A map of nothing but plain ground. Used by tests and as a fallback.
static func flat(w: int, h: int) -> BattleMap:
	var m := _bare(w, h)
	m._widen_rift()
	return m


## The field before its rift takes its two front hexes: what a shape is laid on (generate,
## _widen_rift).
static func _bare(w: int, h: int) -> BattleMap:
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
## The rift's shell (Ryan, 16 November: "The shell only needs to cover the 7 hexes in front of the
## rift ... The result should be that the 7 hexes next to the rift are inaccessible to player
## units. That also gives us a potential 7 cracks if we ever need it"): every hex beside the rift's
## five that is not one of them, the boss's hex among them, in order round the rift from one end of
## its row to the other. Seven on every field (the rift's row is the map's first). The battle holds
## them while the seal stands (Battlefield.shell).
func shell_hexes() -> Array[Vector2i]:
	if not _shell.is_empty():
		return _shell
	var out: Array[Vector2i] = []
	for r in rift_hexes:
		for n in Hex.neighbors(r):
			if has(n) and not rift_hexes.has(n) and not out.has(n):
				out.append(n)
	var mid := Vector2.ZERO
	for r in rift_hexes:
		mid += _plane(r)
	mid /= float(maxi(1, rift_hexes.size()))
	out.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		var da := _plane(a) - mid
		var db := _plane(b) - mid
		return atan2(da.x, da.y) < atan2(db.x, db.y))   # round the front from one end of the rift's row to the other: nothing of the ring lies straight behind it
	_shell = out
	return out


var _shell: Array[Vector2i] = []   # shell_hexes, read once: the rift's five never move


## A hex's centre on a plain axial plane (pointy-top, unit size): an order round the rift, the
## same whichever way the view lays the field.
static func _plane(h: Vector2i) -> Vector2:
	return Vector2(sqrt(3.0) * (float(h.x) + float(h.y) * 0.5), 1.5 * float(h.y))


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
	var m := _bare(w, h)
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
	m._widen_rift()   # the rift's two front hexes, once the shape is laid and before its mouth is bared
	m._clear_ends()
	m._ensure_ground_path(rng)
	m._prune_narrows()
	m._dress_shores()
	m._lay_roads(rng)
	m._lay_relief(rng)
	return m


## The rift is five hexes, a half circle open to the field (Ryan, 10 November: "make the rift
## have the two hexes in front of it also out of play (so it's a 5 hex semicircle)"): its row's
## three and the two of the next row that touch its middle. A shape is laid on the rift's row
## alone, as it was, so no seed's water and walls move for them; the two are taken as soon as it
## is laid, and everything after reads all five: the mouth bared round them (_clear_ends), the
## horde's guarantee, the shores, the roads and the relief.
func _widen_rift() -> void:
	for n in Hex.neighbors(rift):
		if has(n) and Hex.axial_to_offset(n).y == 1 and not rift_hexes.has(n):
			rift_hexes.append(n)
			terrain[n] = Terrain.PLAIN
			crag_base.erase(n)
			wall_look.erase(n)
			elevation[n] = 0


## Where a shape's laying starts: the rift's row (FIRST_ROW). Kept as a function so the sim reads
## one name for it (the opening's packs and the seam read their own rows: Battle.OPENING_FLOOR_ROW,
## Battlefield.seam_start).
func mouth_rows() -> int:
	return FIRST_ROW


## The last row a shape lays water or a wall on: the team's two rows above the gate's apron
## stay clear, so a deployed machine always has somewhere to go.
func _hi() -> int:
	return height - GATE_ROWS - 3


## How many rows a shape has to lay in, the team's aside: eight at twelve deep, sixteen at
## twenty. A shape that needs more than it has lays less (a thinner river, one band
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


## RIVER CROSSING (Ryan, 10 November: "the river should wind through the whole map, crossing the
## center of the battlefield at least once. Remove the fords, instead just guarantee some
## narrower sections - so water fords, not land fords"; "some smaller tributaries"): a river
## from past the west edge to past the east, wandering a row up or down as it goes, through the
## field's centre hex; two hexes thick and three in places, with one or two narrows a hex thick
## (the water fords: where the wade is one hex) and one or two tributaries a hex thick wandering
## off it toward the rift's row or the team's ground; gravel bars in stretches along the banks
## (_shore), at most a crag on a bank. Everyone wades it at two a hex but a hovercraft and a
## flyer, the horde too, so a narrow is the quick way across for both sides. The roads run from
## the gate to the narrows and on past them. Tests the wade and where to cross.
const RIVER_DEEP := 0.35      # a river hex with a third row below it
const BANK_CRAG := 0.4        # the chance of a crag on a bank
const RIVER_WANDER := 0.35    # the chance a step ignores the river's heading and wanders
const RIVER_NARROWS := [1, 2]
const RIVER_TRIBUTARIES := [1, 2]


func _lay_river(rng: RandomNumberGenerator) -> void:
	var lo := mouth_rows()
	var hi := _hi()
	var open := _open_rows()
	var thick := 3 if open >= 6 else (2 if open >= 3 else 1)
	var line_lo := lo
	var line_hi := hi - (thick - 1)   # the line's southmost row, its thickening below it, short of the team's ground
	var centre := Hex.offset_to_axial(width / 2, (lo + hi) / 2)
	# The narrows: one or two stretches of two or three columns inside the field, a column apart
	# at least and clear of the rift's and the gate's columns, where the line runs straight and
	# lies a hex thick; the rest two, and three where the deep lies.
	var narrow_cols := {}   # a column -> its narrow's number
	var n_narrows := int(RIVER_NARROWS[rng.randi_range(0, RIVER_NARROWS.size() - 1)])
	var rift_col := Hex.axial_to_offset(rift).x
	for k in range(n_narrows):
		# Clear of the rift's bared ring and a column from another narrow where the field has the
		# room; a narrow field takes what fits, the first narrow anywhere at all.
		for attempt in range(24):
			var run := rng.randi_range(2, 3)
			var at := rng.randi_range(1, maxi(1, width - 1 - run))
			var clear := STRUCTURE_HALF_WIDTH + 2 if attempt < 12 else (STRUCTURE_HALF_WIDTH if attempt < 18 else -1)
			var margin_cols := 1 if attempt < 18 else 0
			var ok := true
			for col in range(at - margin_cols, at + run + margin_cols):
				ok = ok and not narrow_cols.has(col) and absi(col - rift_col) > clear
			if ok:
				for col in range(at, at + run):
					narrow_cols[col] = k
				narrows.append([] as Array[Vector2i])
				narrow_widths.append(run)
				break
	var line: Array[Vector2i] = []
	# West of the field to the centre, then the centre to east of it, each leg a walk that heads
	# for its goal's row and wanders, straight through a narrow.
	var start := Hex.offset_to_axial(-MARGIN_COLS - 1, clampi(rng.randi_range(line_lo, line_hi), line_lo, line_hi))
	var far := Hex.offset_to_axial(width + MARGIN_COLS, clampi(rng.randi_range(line_lo, line_hi), line_lo, line_hi))
	var cur := start
	for goal in [centre, far]:
		var guard := (width + 2 * MARGIN_COLS) * 4
		while Hex.axial_to_offset(cur).x < Hex.axial_to_offset(goal).x and guard > 0:
			guard -= 1
			line.append(cur)
			var steps: Array[Vector2i] = []
			var east := cur + Vector2i(1, 0)
			var up := cur + Vector2i(1, -1)
			var down := cur + Vector2i(0, 1)
			if up.y >= line_lo:
				steps.append(up)
			if down.y <= line_hi:
				steps.append(down)
			var next := east
			var col := Hex.axial_to_offset(cur).x
			if narrow_cols.has(col) or narrow_cols.has(col + 1):
				next = east   # straight through a narrow, and into it
			elif rng.randf() < RIVER_WANDER and not steps.is_empty():
				next = steps[rng.randi_range(0, steps.size() - 1)]
			elif cur.y > goal.y and up.y >= line_lo:
				next = up
			elif cur.y < goal.y and down.y <= line_hi:
				next = down
			cur = next
		cur = goal if Hex.axial_to_offset(cur).x <= Hex.axial_to_offset(goal).x else cur
	line.append(cur)
	for hx in line:
		_flood(hx)
		var col := Hex.axial_to_offset(hx).x
		if narrow_cols.has(col) and has(hx):
			(narrows[int(narrow_cols[col])] as Array).append(hx)
			continue
		if thick >= 2 and hx.y + 1 <= hi:
			_flood(hx + Vector2i(0, 1))
		if thick >= 3 and hx.y + 2 <= hi and rng.randf() < RIVER_DEEP:
			_flood(hx + Vector2i(-1, 2))
	# The tributaries keep clear of the narrows.
	var inside: Array[int] = []
	for i in range(line.size()):
		if has(line[i]) and not narrow_cols.has(Hex.axial_to_offset(line[i]).x):
			inside.append(i)
	# The tributaries: a hex thick, off a line hex inside the field, wandering toward the rift's
	# row or the team's ground for a few hexes, never onto the team's rows.
	for k in range(int(RIVER_TRIBUTARIES[rng.randi_range(0, RIVER_TRIBUTARIES.size() - 1)])):
		if inside.is_empty():
			break
		var from := line[inside[rng.randi_range(0, inside.size() - 1)]]
		var toward_rift := from.y > (lo + hi) / 2 or (from.y > lo and rng.randf() < 0.5)
		var at := from
		for step in range(rng.randi_range(3, 6)):
			var options: Array[Vector2i] = []
			if toward_rift:
				options = [at + Vector2i(0, -1), at + Vector2i(1, -1)]
			else:
				options = [at + Vector2i(0, 1), at + Vector2i(-1, 1)]
			if rng.randf() < 0.3:
				options.append(at + (Vector2i(1, 0) if rng.randf() < 0.5 else Vector2i(-1, 0)))
			var next: Vector2i = options[rng.randi_range(0, options.size() - 1)]
			if not has(next) or is_structure(next) or next.y < lo or next.y > hi:
				break
			var by_narrow := false
			for narrow in narrows:
				for nh in narrow:
					by_narrow = by_narrow or Hex.distance(next, nh) <= 1
			if by_narrow:
				break
			_flood(next)
			at = next
	water_feature = "river"
	if rng.randf() < BANK_CRAG:
		var banks: Array = []
		for hx in _field_spots(lo, hi, 1, width - 2):
			if terrain[hx] == Terrain.WATER:
				continue
			var wet := false
			for nb in Hex.neighbors(hx):
				wet = wet or terrain_of(nb) == Terrain.WATER
			var clear := true
			for narrow in narrows:
				for f in narrow:
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


## FJORD (Ryan, 10 November: "the new flooded, it can use more water. I'd say 50-60% of it should
## be water, at least"): the open rows under water, the scenery beside them too, with land lanes
## winding from the rift's row to the team's ground, two hexes wide and pinched to one in places,
## one for every seven hexes of wall, a branch or two off each, and islands of one to three
## hexes out in the water; shingle on the shores (_shore). Everyone wades the rest at two a hex,
## the horde too, where a hovercraft and a flyer cross at one, so the lanes are the quick way and
## the water the short cut that costs. Tests lane choice and a detachment across water.
const FJORD_PER := 7          # hexes of wall a lane
const FJORD_MOST := 4
const FJORD_WIDEN := 0.8      # the chance a lane's step is two hexes wide
const FJORD_SIDEWAYS := 0.35  # the chance a lane's step runs along the row rather than toward the wall
const FJORD_BRANCHES := [1, 2]
const FJORD_ISLANDS := [3, 5]


## How many lanes the width takes: one for every FJORD_PER hexes of wall, one at least.
func _fjord_count() -> int:
	return clampi(roundi(float(width) / float(FJORD_PER)), 1, FJORD_MOST)


func _lay_fjord(rng: RandomNumberGenerator) -> void:
	var lo := mouth_rows()
	var hi := _hi()
	for hx in _field_spots(lo, hi):
		_flood(hx)
	for hx in _scenery():
		var row := Hex.axial_to_offset(hx).y
		if row >= lo and row <= hi:
			_flood(hx)
	# A shallow band keeps its lanes thinner and its branches fewer, so the water stays half the
	# field or more at any depth.
	var shallow := _open_rows() < 8
	_carve_lanes(rng, _fjord_count(), FJORD_WIDEN if not shallow else FJORD_WIDEN * 0.7, FJORD_SIDEWAYS, FJORD_BRANCHES if not shallow else [0, 1], 0.5)
	for k in range(int(FJORD_ISLANDS[rng.randi_range(0, FJORD_ISLANDS.size() - 1)])):
		var spots := _field_spots(lo, hi)
		for attempt in range(20):
			var hx: Vector2i = spots[rng.randi_range(0, spots.size() - 1)]
			if terrain[hx] != Terrain.WATER:
				continue
			var land := false
			for nb in Hex.neighbors(hx):
				land = land or (has(nb) and terrain[nb] != Terrain.WATER)
			if land:
				continue
			_cut(hx)
			for extra in range(rng.randi_range(0, 2)):
				var nb: Vector2i = Hex.neighbors(hx)[rng.randi_range(0, 5)]
				if has(nb) and terrain[nb] == Terrain.WATER and nb.y >= lo and nb.y <= hi:
					_cut(nb)
			break
	water_feature = "fjord"


## Lanes carved through a flooded or walled band, from the rift's row to the team's ground:
## `n` trunks, each in its stretch of the wall, wandering a column or so a row (`sideways`) and
## two hexes wide at `widen` (a pinch otherwise), with `branches` off each running sideways
## toward the neighbouring trunk until they meet a lane or run out, `branch_widen` wide. The
## gorge's channels and the fjord's lanes are the same carving (Ryan, 10 November: the gorge
## "more winding lanes between walls, with junctions and branches"). Returns every lane hex in
## the order cut.
func _carve_lanes(rng: RandomNumberGenerator, n: int, widen: float, sideways: float, branches: Array, branch_widen: float) -> Array[Vector2i]:
	var lo := mouth_rows()
	var hi := _hi()
	var lane: Array[Vector2i] = []
	var trunks: Array = []   # each trunk's hexes
	var cols: Array[int] = []
	for i in range(n):
		var west := (width * i) / n
		var east := (width * (i + 1)) / n - 1
		var col := rng.randi_range(west, east)
		cols.append(col)
		var row := lo
		var cur := Hex.offset_to_axial(col, row)
		var mine: Array[Vector2i] = [cur]
		_cut(cur)
		var guard := width * 4
		while row < hi and guard > 0:
			guard -= 1
			var options: Array[Vector2i] = []
			for nb in Hex.neighbors(cur):
				var o := Hex.axial_to_offset(nb)
				if not has(nb) or is_structure(nb) or o.y < lo or o.y > hi:
					continue
				if o.y == row + 1:
					options.append(nb)
				elif o.y == row and rng.randf() < sideways and o.x >= west - 1 and o.x <= east + 1:
					options.append(nb)
			if options.is_empty():
				break
			cur = options[rng.randi_range(0, options.size() - 1)]
			row = Hex.axial_to_offset(cur).y
			_cut(cur)
			mine.append(cur)
			if rng.randf() < widen:
				var beside := Hex.neighbors(cur)
				var side: Vector2i = beside[rng.randi_range(0, beside.size() - 1)]
				var so := Hex.axial_to_offset(side)
				if has(side) and so.y >= lo and so.y <= hi and not is_structure(side):
					_cut(side)
					mine.append(side)
		trunks.append(mine)
		lane.append_array(mine)
	# The branches: from a point on a trunk, sideways toward the neighbouring trunk's column,
	# wandering a row now and then, until they meet a lane hex or run out: a junction, or a blind
	# end.
	for i in range(n):
		var mine: Array = trunks[i]
		for b in range(int(branches[rng.randi_range(0, branches.size() - 1)])):
			var from: Vector2i = mine[rng.randi_range(0, mine.size() - 1)]
			var dir := 1 if (i + 1 < n and (i == 0 or rng.randf() < 0.5)) else -1
			if n == 1:
				dir = -1 if rng.randf() < 0.5 else 1
			var at := from
			for step in range(rng.randi_range(4, 8)):
				var o := Hex.axial_to_offset(at)
				var next := Hex.offset_to_axial(o.x + dir, o.y)
				if rng.randf() < 0.3:
					next = Hex.offset_to_axial(o.x + (dir if o.y % 2 == 1 else 0), o.y + (1 if rng.randf() < 0.5 else -1))
				var no := Hex.axial_to_offset(next)
				if not has(next) or is_structure(next) or no.y < lo or no.y > hi:
					break
				var joined := _is_cut(next) and not mine.has(next)
				_cut(next)
				lane.append(next)
				if rng.randf() < branch_widen:
					var wide := Hex.offset_to_axial(no.x, no.y + (1 if no.y < hi else -1))
					if has(wide) and Hex.axial_to_offset(wide).y >= lo and not is_structure(wide):
						_cut(wide)
						lane.append(wide)
				if joined:
					break   # a junction
				at = next
	return lane


## Whether a hex of the field is cut ground: the shape's own ground, neither water nor a wall.
func _is_cut(hx: Vector2i) -> bool:
	return has(hx) and terrain[hx] != Terrain.WATER and terrain[hx] != Terrain.MOUNTAIN


## BADLANDS (Ryan, 9 November: "winding paths broken by small obstacles, like an open field that
## you can't take a straight path through"; 10 November: "can use more spires, and I barely see
## any grouping"): mesas in groups of two to five, many of them, a hex of ground between any two
## groups, so no straight line crosses the field and every walk winds; two or three ponds of two
## to four hexes among them; scrub at the mesas' feet and out in the scenery, where the mesas go
## on. Tests the longest walks and the pack that cannot come straight.
const BADLANDS_PER := 9      # open hexes a group of mesas
const BADLANDS_SIZES := [2, 2, 3, 3, 3, 4, 4, 5]   # a group's hexes, drawn from this


func _lay_badlands(rng: RandomNumberGenerator) -> void:
	var spots := _field_spots(mouth_rows(), _hi())
	var ponds := 0
	for p in range(rng.randi_range(2, 3)):
		if not _grow(rng, spots, rng.randi_range(2, 4), "", 1).is_empty():
			ponds += 1
	for g in range(maxi(3, spots.size() / BADLANDS_PER)):
		_grow(rng, spots, int(BADLANDS_SIZES[rng.randi_range(0, BADLANDS_SIZES.size() - 1)]), "mesas", 1)
	water_feature = "ponds" if ponds > 1 else ("a pond" if ponds == 1 else "")
	var scenery := _scenery()
	for g in range(rng.randi_range(6, 10)):
		_grow(rng, scenery, rng.randi_range(1, 3), "mesas", 1)
	for hx in scenery:
		_dress_ground(hx, Terrain.ROUGH)
	for hx in wall_look.keys():
		for nb in Hex.neighbors(hx):
			_dress_ground(nb, Terrain.ROUGH)


## OPEN STEPPE: relatively clear, the baseline the others are read against, but never bare
## (Ryan, 10 November: "Steppe is VERY barren"): a crag of one or two hexes at most for every
## seven hexes of wall and a pond at most for every ten, scrub in belts from a seeded noise
## over about a sixth of the field, the one rise, grass on the open field (the dress) and the
## odd crag out in the scenery.
const STEPPE_CRAG := 0.6
const STEPPE_POND := 0.5
const STEPPE_PER := 10        # hexes of wall a pond at most
const STEPPE_CRAG_PER := 7    # hexes of wall a crag at most
const STEPPE_SCRUB := 0.17    # the share of the field in scrub belts


## How many ponds the steppe may take: one for every STEPPE_PER hexes of wall, one at least.
func _steppe_count() -> int:
	return maxi(1, width / STEPPE_PER)


func _lay_steppe(rng: RandomNumberGenerator) -> void:
	var spots := _field_spots(mouth_rows() + 1, _hi() - 1, 1, width - 2)
	var ponds := 0
	for i in range(_steppe_count()):
		if rng.randf() < STEPPE_POND and not _grow(rng, spots, rng.randi_range(2, 3), "", 2).is_empty():
			ponds += 1
	for i in range(maxi(1, width / STEPPE_CRAG_PER)):
		if rng.randf() < STEPPE_CRAG:
			_grow(rng, spots, rng.randi_range(1, 2), "crags", 2)
	water_feature = "ponds" if ponds > 1 else ("a pond" if ponds == 1 else "")
	# Scrub in belts: a low-frequency noise over the field, rough on the share of the field
	# where it runs highest (the threshold the share's quantile, so the share holds at any size).
	var noise := FastNoiseLite.new()
	noise.seed = map_seed + 606
	noise.frequency = 0.18
	noise.fractal_type = FastNoiseLite.FRACTAL_NONE
	var band := _field_spots(mouth_rows(), _hi())
	var values: Array[float] = []
	for hx in band:
		var p := Hex.to_pixel(hx, 1.0)
		values.append(noise.get_noise_2d(p.x, p.y))
	var sorted := values.duplicate()
	sorted.sort()
	var threshold: float = sorted[clampi(int(float(sorted.size()) * (1.0 - STEPPE_SCRUB)), 0, sorted.size() - 1)]
	for i in range(band.size()):
		if values[i] >= threshold:
			_dress_ground(band[i], Terrain.ROUGH)
	var scenery := _scenery()
	for g in range(rng.randi_range(1, 3)):
		_grow(rng, scenery, rng.randi_range(1, 2), "crags", 2)


## RUINED CITY (Ryan, 9 November: "channels broken by side streets, larger groups of impassible
## terrain", the future's cities "towering massive entities, so dense sections of skyscrapers"):
## a grid of streets between large blocks of towers. Avenues run from the wall toward the rift
## one hex wide, four to five columns apart with the gate's column always one of them (two wide,
## the main avenue the roads start on); side streets run along the wall mid the blocks, each
## segment between two avenues there or not, so a channel is broken by a side street here and
## walled there; an avenue segment may be fallen in (a collapsed tower), so the way round is the
## side street. A block or two is a plaza, open ground with a fountain (water) in some; a street
## segment or two is flooded. Rubble everywhere else, towers thick in the scenery as the city
## goes on. The streets are the city's roads (_lay_roads). Tests the streets held and the team
## fighting apart, the channel a pack must take and the flyer's crossing of its own.
const CITY_SCENERY_TOWERS := 0.5   # the share of the scenery a tower stands on
const CITY_SIDE_SEGMENT := 0.65    # the chance a side street's segment between two avenues is open
const CITY_FALLEN := 0.15          # the chance an avenue's segment between two side streets has fallen in
const CITY_PLAZAS := [1, 2]        # how many blocks are plazas
const CITY_FOUNTAIN := 0.5         # the chance a plaza has a fountain
const CITY_FLOODED := 0.4          # the chance a street segment is flooded, twice


func _lay_city(rng: RandomNumberGenerator) -> void:
	var lo := mouth_rows()
	var hi := _hi()
	var open := _open_rows()
	# The mass: towers on every open hex of the field, then the streets cut through them.
	for hx in _field_spots(lo, hi):
		_wall(hx, "towers")
	var gate_col := Hex.axial_to_offset(gate).x
	var k := rng.randi_range(4, 5)   # columns between avenues
	var avenues: Array[int] = []
	var c := gate_col % k
	while c < width:
		if c >= 1 and c <= width - 2:
			avenues.append(c)
		c += k
	# The side streets: one mid the open rows; two where there is room for blocks between.
	var side_rows: Array[int] = []
	if open >= 7:
		side_rows = [lo + open / 3, lo + (2 * open) / 3]
	elif open >= 3:
		side_rows = [lo + open / 2]
	var street_hexes := {}   # hex -> true
	var paths: Array = []
	for a in avenues:
		var path: Array = []
		var cols: Array[int] = [a]
		if a == gate_col:
			cols.append(a + 1)   # the main avenue two wide: the gate's column and the one beside
		# The avenue's segments between side streets, each standing or fallen in.
		var cuts: Array[int] = [lo - 1]
		cuts.append_array(side_rows)
		cuts.append(hi + 1)
		for i in range(cuts.size() - 1):
			var fallen := a != gate_col and rng.randf() < CITY_FALLEN
			for row in range(int(cuts[i]) + 1, int(cuts[i + 1])):
				for col in cols:
					var hx := Hex.offset_to_axial(col, row)
					if not fallen and has(hx):
						_cut(hx)
						street_hexes[hx] = true
					if not fallen and col == a:
						path.append(hx)
		for row in side_rows:
			for col in cols:
				var hx := Hex.offset_to_axial(col, row)
				if has(hx):
					_cut(hx)
					street_hexes[hx] = true
				if col == a:
					path.append(hx)
		path.sort_custom(func(x: Vector2i, y: Vector2i) -> bool: return x.y > y.y)   # from the wall's end
		paths.append(path)
	for row in side_rows:
		var stops: Array[int] = [-1]
		stops.append_array(avenues)
		stops.append(width)
		for i in range(stops.size() - 1):
			if rng.randf() >= CITY_SIDE_SEGMENT:
				continue
			var seg: Array = []
			for col in range(int(stops[i]) + 1, int(stops[i + 1])):
				var hx := Hex.offset_to_axial(col, row)
				if has(hx):
					_cut(hx)
					street_hexes[hx] = true
					seg.append(hx)
			if not seg.is_empty():
				paths.append(seg)
	# The plazas: a block or two opened whole, a fountain in some.
	var blocks: Array = _city_blocks(avenues, side_rows)
	var fountains := 0
	for n in range(int(CITY_PLAZAS[rng.randi_range(0, CITY_PLAZAS.size() - 1)])):
		if blocks.is_empty():
			break
		var block: Array = blocks.pop_at(rng.randi_range(0, blocks.size() - 1))
		for hx in block:
			_cut(hx)
		if rng.randf() < CITY_FOUNTAIN and block.size() >= 3:
			var mid: Vector2i = block[block.size() / 2]
			_flood(mid)
			fountains += 1
	# The flooded streets: a segment or two under water, never the main avenue.
	var flooded := 0
	for n in range(2):
		if rng.randf() < CITY_FLOODED and paths.size() > 1:
			var path: Array = paths[rng.randi_range(1, paths.size() - 1)]
			if path.size() >= 3:
				var at := rng.randi_range(0, path.size() - 3)
				for j in range(at, at + rng.randi_range(2, 3)):
					if j < path.size() and has(path[j]) and terrain[path[j]] != Terrain.WATER:
						_flood(path[j])
						flooded += 1
	water_feature = ""
	if flooded > 0:
		water_feature = "flooded streets"
	if fountains > 0:
		water_feature += (" + " if not water_feature.is_empty() else "") + ("fountains" if fountains > 1 else "a fountain")
	streets = paths
	for hx in _scenery():
		if rng.randf() < CITY_SCENERY_TOWERS:
			_wall(hx, "towers")


## The city's blocks: the tower hexes between two avenues and two side streets, each as an
## Array, the blocks of fewer than three hexes aside.
func _city_blocks(avenues: Array[int], side_rows: Array[int]) -> Array:
	var out: Array = []
	var col_stops: Array[int] = [-1]
	col_stops.append_array(avenues)
	col_stops.append(width)
	var row_stops: Array[int] = [mouth_rows() - 1]
	row_stops.append_array(side_rows)
	row_stops.append(_hi() + 1)
	for i in range(col_stops.size() - 1):
		for j in range(row_stops.size() - 1):
			var block: Array = []
			for col in range(int(col_stops[i]) + 1, int(col_stops[i + 1])):
				for row in range(int(row_stops[j]) + 1, int(row_stops[j + 1])):
					var hx := Hex.offset_to_axial(col, row)
					if has(hx) and terrain[hx] == Terrain.MOUNTAIN:
						block.append(hx)
			if block.size() >= 3:
				out.append(block)
	return out


## A hex of the field cut back to the shape's ground: a channel through the gorge's cliffs, a
## street through the city's towers.
func _cut(hx: Vector2i) -> void:
	if not has(hx) or is_structure(hx):
		return
	terrain[hx] = int(KINDS[kind]["ground"])
	crag_base.erase(hx)
	wall_look.erase(hx)
	elevation[hx] = 0


## GORGE (Ryan, 9 November: "winding, branching channels"; 10 November: "more winding lanes
## between walls, with junctions and branches"): cliff mass over the whole open band, the field
## and the scenery beside it, cut by channels (_carve_lanes). Trunks run from the rift's row to
## the team's ground, one for every five hexes of wall, each wandering a column or so a row and
## one or two hexes wide; three or four branches leave each trunk sideways toward the next and
## wander, meeting another channel at a junction or ending blind; a stretch or two of channel
## lies flooded, a wade. The gorge's own sides stand in the scenery past both edges, and scree
## lies at the cliffs' feet. Tests the pack that must come the long way and the channel held at
## its mouth.
const GORGE_PER := 5          # hexes of wall a trunk
const GORGE_MOST := 5
const GORGE_WIDEN := 0.75     # the chance a trunk's step is two hexes wide (a pinch otherwise)
const GORGE_SIDEWAYS := 0.4   # the chance a trunk's step runs along the row rather than toward the wall
const GORGE_BRANCHES := [3, 4]
const GORGE_FLOODED := 0.5    # the chance a stretch of channel is flooded, twice
const GORGE_SCREE := 0.3      # the share of the channels' edges in scree


## How many trunks the width takes: one for every GORGE_PER hexes of wall, one at least.
func _cliff_count() -> int:
	return clampi(roundi(float(width) / float(GORGE_PER)), 1, GORGE_MOST)


func _lay_gorge(rng: RandomNumberGenerator) -> void:
	var lo := mouth_rows()
	var hi := _hi()
	for hx in _field_spots(lo, hi):
		_wall(hx, "cliffs")
	for hx in _scenery():
		var row := Hex.axial_to_offset(hx).y
		if row >= lo and row <= hi:
			_wall(hx, "cliffs")
	for row in range(0, hi + 1):
		_wall(Hex.offset_to_axial(-1, row), "cliffs")
		_wall(Hex.offset_to_axial(width, row), "cliffs")
	var channel := _carve_lanes(rng, _cliff_count(), GORGE_WIDEN, GORGE_SIDEWAYS, GORGE_BRANCHES, 0.5)
	# The flooded stretches: a run of channel under water, a wade for everyone.
	var flooded := 0
	for n2 in range(2):
		if rng.randf() < GORGE_FLOODED and channel.size() >= 4:
			var at := rng.randi_range(0, channel.size() - 3)
			for j in range(at, mini(channel.size(), at + rng.randi_range(2, 3))):
				if terrain[channel[j]] != Terrain.WATER:
					_flood(channel[j])
					flooded += 1
	water_feature = "flooded channels" if flooded > 0 else ""


## Rough ground in stretches along the water's edge or at a wall's foot: a river's gravel bars,
## a fjord's shingle, a gorge's scree, the shape's second decorative ground (the bible's shapes
## row: one or two a shape, laid to be read). From a seeded noise, so it comes in runs rather
## than per-hex rolls (Ryan, 21 September: a believable landscape), on about `share` of the
## plain hexes of the field and the scenery beside `beside` (water or a wall); never over a
## road, water or a wall, and the ground in front of a structure is bared after (_clear_ends).
const SHORE_SHARE := 0.45


## A narrow is what is left of it once the structures' fronts are bared: its hexes still water,
## and a narrow with none gone.
func _prune_narrows() -> void:
	var kept: Array = []
	var widths: Array = []
	for i in range(narrows.size()):
		var hexes: Array = []
		for hx in narrows[i]:
			if has(hx) and terrain[hx] == Terrain.WATER:
				hexes.append(hx)
		if not hexes.is_empty():
			kept.append(hexes)
			widths.append(hexes.size())
	narrows = kept
	narrow_widths = widths


## Each shape's second ground, laid once the horde's guarantee has opened what it opens and the
## structures' fronts are bared, so no bar or scree outlives the water or the cliff it lay by.
func _dress_shores() -> void:
	match kind:
		"river", "fjord":
			_shore(Terrain.WATER, SHORE_SHARE)
		"gorge":
			_shore(Terrain.MOUNTAIN, GORGE_SCREE)


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


## The gate, the rift and the ground right in front of each are always open and bare (the rift's
## ring is its mouth, where the packs land); the team's two rows above the gate's apron hold no
## water and no wall, so a deployed machine always has somewhere to go.
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


## The roads lead somewhere (Ryan, 29 October): the river's from the gate to each narrow (the
## water fords) and on across it, the steppe's one road
## north from the gate, the city's streets (its avenues from the wall's end toward the rift, the
## main one from the gate, and its side streets). The fjord, the badlands and the gorge lay
## none. A road keeps its gaps (nobody paves between attacks) but for its first slabs off the
## gate, never routes through or paves water or a wall, and is never a lone slab.
func _lay_roads(rng: RandomNumberGenerator) -> void:
	var o := Hex.axial_to_offset(gate)
	var front := Hex.offset_to_axial(o.x, o.y - GATE_ROWS)   # in front of the gate, above its apron
	var wet := _wet()
	var paths: Array = []
	match kind:
		"river":
			for i in range(narrows.size()):
				# To the narrow's middle hex by dry ground, or to whichever of its hexes dry ground
				# reaches, and on past it.
				var ends := _ends_of(narrows[i])
				var there: Array = find_path(front, ends[0], [], wet)
				var at: Vector2i = ends[0]
				if there.is_empty():
					for hx in narrows[i]:
						there = find_path(front, hx, [], wet)
						if not there.is_empty():
							at = hx
							break
				if there.is_empty():
					continue
				var path: Array = [front]
				path.append_array(there)
				path.append_array(find_path(at, _north_of(at, rng.randi_range(3, 5)), [], wet))
				paths.append(path)
			if paths.is_empty():
				paths.append(_trunk(front, rng))   # no narrow dry ground reaches: the road runs for the water as the steppe's does
		"steppe":
			paths.append(_trunk(front, rng))
		"city":
			for street in streets:
				var path: Array = []
				if not street.is_empty() and Hex.axial_to_offset(street[0]).x == o.x:
					path.append(front)   # the main avenue starts in front of the gate
				path.append_array(street)
				paths.append(path)
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


## Where a road meets a narrow from the south and leaves it to the north: the middle hex of its
## southmost row and of its northmost (one and the same for a narrow on one row).
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
## the scenery (the scenery beside the team's rows eases down to them, _scenery_cap), and the
## whole field of every shape but the badlands and the steppe (the rule: the field is level but
## for the mesas' shoulders and the steppe's one rise, so no settling lifts a channel's hex at
## the field's edge to its scenery neighbours' height).
func _level(hx: Vector2i) -> bool:
	var row := Hex.axial_to_offset(hx).y
	if city.has(hx) or is_structure(hx):
		return true
	if not has(hx):
		return row >= height - GATE_ROWS
	if row > _hi() or terrain[hx] == Terrain.ROAD:
		return true
	if kind != "badlands" and kind != "steppe":
		return true
	for n in Hex.neighbors(hx):
		if gate_hexes.has(n) or rift_hexes.has(n):
			return true
	return false


## How high the scenery may rise at a hex: level in the ring beside the field, then a step a
## column (or a row) further out, and a step a row less toward the wall's rows, so the scenery
## eases up from the field's edge and down to the wall (the ring level since 9 November: a
## channel's hex at a gorge's edge stood alone between its flooded neighbour and a raised side).
func _scenery_cap(hx: Vector2i) -> int:
	var o := Hex.axial_to_offset(hx)
	var d := 0
	if o.x < 0:
		d = -o.x
	elif o.x >= width:
		d = o.x - width + 1
	if o.y < 0:
		d = maxi(d, -o.y)
	return clampi(mini(d - 1, height - GATE_ROWS - 1 - o.y), 0, 3)


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
	# out, and one that ends inside the rift the rest of the rift to get in (its middle lies
	# behind the two hexes in front of it); that is how the gate-to-rift guarantee is checked.
	# Nothing else crosses a structure.
	var own_gate := gate_hexes.has(from)
	var own_rift := rift_hexes.has(to)
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
			if n != to and (blocked.has(n) or (is_structure(n) and not (own_gate and gate_hexes.has(n)) and not (own_rift and rift_hexes.has(n)))):
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
