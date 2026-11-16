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
const WALL_LOOKS := ["crags", "mesas", "towers", "cliffs", "chasms"]

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
var elevation: Dictionary = {}         # hex -> relief step 0..3 (water -1, a chasm -2): landscape only, no rule reads it
var margin: Dictionary = {}            # hex beside the field -> terrain: scenery past the playable edge, never played on
var city: Dictionary = {}              # margin hex -> true: the city behind the wall, what the gate protects
const MARGIN_COLS := 4
const MARGIN_ROWS := 3                 # scenery rows beyond the rift
const CITY_ROWS := 2                   # city rows behind the wall
var map_seed: int = 0
var opened: Dictionary = {}            # hex -> the ground the horde's guarantee opened there (the map survey reads it)
var water_feature := ""               # "river", "delta", "ponds", "a pond", "lakes", "a lake", "a flooded chasm", or "" for none (the map survey reads it)
var narrows: Array = []                # a river's narrows, each an Array of its hexes (water a hex thick, the short wade): the roads run to them
var narrow_widths: Array = []          # each narrow's length along the river, in hexes
var streets: Array = []                # the city's streets, each an Array of its hexes from the wall's end: the roads run along them (_lay_roads)
var city_open: Array = []              # the city's sections of ruins where towers stood, its suburb and its plazas, each an Array of hexes: two at most
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
## path crosses. Water lies in the gorge and the badlands (flooded channels, ponds), never in the
## city (Ryan, 16 November). The RIVER CROSSING and the RIVER DELTA are the water shapes and the
## OPEN STEPPE the baseline. Every number in the laying is a placeholder; the 200-seed survey measures each
## (tools/map_survey.gd).
##   name: the front card's word; ground: what the field is laid in; dress: what the 3D map
##   stands on the land beside water (bank), at a wall's foot (foot), out in the scenery
##   (scenery) and on the open field itself (field, sparse), each a prop's word for Map3D or ""
##   for none.
const KINDS := {
	"river": {"name": "RIVER CROSSING", "ground": Terrain.PLAIN, "dress": {"bank": "reeds", "foot": "rocks", "scenery": "grass", "field": ""}},
	"delta": {"name": "RIVER DELTA", "ground": Terrain.PLAIN, "dress": {"bank": "shingle", "foot": "rocks", "scenery": "boulders"}},
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
		"delta":
			m._lay_delta(rng)
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


## The last row a shape lays a wall on: the team's two rows above the gate's apron hold none, so a
## deployed machine always has somewhere to go (_clear_ends). Most shapes lay their water short of
## them too; the delta runs its streams on to the wall (_apron_row).
func _hi() -> int:
	return height - GATE_ROWS - 3


## The last row of the field: the apron in front of the wall, where a pack strikes from
## (Battlefield.apron_row).
func _apron_row() -> int:
	return height - GATE_ROWS - 1


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
func _grow(rng: RandomNumberGenerator, spots: Array, size: int, look: String, gap: int, compact: bool = false) -> Array[Vector2i]:
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
		if compact:
			# A round patch (a lake): only the hexes the group holds most of round them.
			var most := 0
			var held := {}
			for o in options:
				var k := 0
				for nb in Hex.neighbors(o):
					k += 1 if mine.has(nb) else 0
				held[o] = k
				most = maxi(most, k)
			var round: Array[Vector2i] = []
			for o in options:
				if int(held[o]) == most:
					round.append(o)
			options = round
		var pick: Vector2i = options[rng.randi_range(0, options.size() - 1)]
		group.append(pick)
		mine[pick] = true
	for hx in group:
		if look.is_empty():
			_flood(hx)
		else:
			_wall(hx, look)
	return group


## A patch of `size` hexes among `spots`, kept `gap` from the water and walls laid before it, as
## _grow lays a group, its hexes returned for the caller to dress.
func _grow_ground(rng: RandomNumberGenerator, spots: Array, size: int, gap: int) -> Array[Vector2i]:
	var group: Array[Vector2i] = []
	var inside := {}
	for hx in spots:
		inside[hx] = true
	var mine := {}
	for attempt in range(40):
		var hx: Vector2i = spots[rng.randi_range(0, spots.size() - 1)]
		if _free(hx, inside, mine, gap) and terrain_of(hx) != Terrain.RUINS:
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
## narrower sections - so water fords, not land fords"; 16 November: "River crossing, no
## tributaries. Just a fat winding river with a couple narrower portions"; then "go to one,
## centered narrow crossing area. The main pushers are pushing over the crossing, the sides are
## the challenging portions to navigate"): one fat river from past the west edge to past the
## east, winding up and down the open rows in long bends and through the field's centre, three
## hexes thick and four in places, with one narrow a hex thick across the field's middle columns
## (the water ford, where the wade is short) where it runs straight; gravel bars in stretches
## along the banks (_shore), at most a crag on a bank. Everyone wades it at two a hex but a
## hovercraft and a flyer, the horde too, so the narrow is the quick way across for both sides and
## the flanks the long wade. The road runs from the gate to the narrow and on past it. Tests the
## wade and where to cross.
const RIVER_DEEP := 0.35      # a river hex with a fourth row below it
const BANK_CRAG := 0.4        # the chance of a crag on a bank
const RIVER_NARROW := 3       # the narrow's columns, about the field's middle
const RIVER_BEND := [14, 18]  # columns a whole bend takes, down the open rows and back up


func _lay_river(rng: RandomNumberGenerator) -> void:
	var lo := mouth_rows()
	var hi := _hi()
	var open := _open_rows()
	var thick := 3 if open >= 6 else (2 if open >= 3 else 1)
	var line_lo := lo
	var line_hi := hi - (thick - 1)   # the line's southmost row, its thickening below it, short of the team's ground
	var centre := Hex.offset_to_axial(width / 2, (lo + hi) / 2)
	# The narrow: the field's middle columns, the line straight there and a hex thick, where the
	# pushers cross; the rest three thick, and four where the deep lies.
	var narrow_cols := {}   # a column -> its narrow's number
	var run := mini(RIVER_NARROW, maxi(1, width - 2))
	for col in range(width / 2 - run / 2, width / 2 - run / 2 + run):
		narrow_cols[col] = 0
	narrows.append([] as Array[Vector2i])
	narrow_widths.append(run)
	# The bends: the line follows a wave down the open rows and back, whole bends of fourteen to
	# eighteen columns, through the field's centre at the middle of the open rows, so it winds the
	# whole width; it turns a row at most a step, and runs straight through a narrow.
	var period := float(rng.randi_range(int(RIVER_BEND[0]), int(RIVER_BEND[1])))
	var swing := 1.0 if rng.randf() < 0.5 else -1.0
	var mid := float(Hex.axial_to_offset(centre).y)
	# As far as the open rows let it swing, and no further than a bend can turn, a row a column at
	# its steepest, so a deep field's river winds rather than running down it.
	var amp := minf(maxf(0.0, minf(mid - float(line_lo), float(line_hi) - mid) + 0.5), period / TAU)
	var wave := func(col: int) -> int:
		return clampi(roundi(mid + swing * amp * sin(TAU * float(col - width / 2) / period)), line_lo, line_hi)
	# A narrow runs straight at the wave's row at its middle, and the line heads there a few columns
	# before it, so a narrow over the centre still crosses it.
	var narrow_row := {}   # a narrow's number -> its row
	for k in range(narrows.size()):
		var cols: Array = []
		for c in narrow_cols.keys():
			if int(narrow_cols[c]) == k:
				cols.append(int(c))
		cols.sort()
		# Below the rift's mouth, which is bared, where the open rows run that deep.
		narrow_row[k] = maxi(wave.call(int(cols[cols.size() / 2])), mini(lo + RIFT_ROWS + 1, line_hi))
	var line: Array[Vector2i] = []
	var cur := Hex.offset_to_axial(-MARGIN_COLS - 1, wave.call(-MARGIN_COLS - 1))
	var guard := (width + 2 * MARGIN_COLS) * 4
	while Hex.axial_to_offset(cur).x <= width + MARGIN_COLS and guard > 0:
		guard -= 1
		line.append(cur)
		var o := Hex.axial_to_offset(cur)
		var want: int = wave.call(o.x + 1)
		for ahead in range(1, 4):
			if narrow_cols.has(o.x + ahead):
				want = int(narrow_row[int(narrow_cols[o.x + ahead])])
				break
		var next := cur + Vector2i(1, 0)
		if narrow_cols.has(o.x) or narrow_cols.has(o.x + 1):
			next = cur + Vector2i(1, 0)   # straight through a narrow, and into it
		elif o.y > want and o.y - 1 >= line_lo:
			next = cur + Vector2i(1, -1)
		elif o.y < want and o.y + 1 <= line_hi:
			next = cur + Vector2i(0, 1)
		cur = next
	for i in range(line.size()):
		var hx: Vector2i = line[i]
		_flood(hx)
		var col := Hex.axial_to_offset(hx).x
		if narrow_cols.has(col) and has(hx):
			(narrows[int(narrow_cols[col])] as Array).append(hx)
			continue
		# A bend's steep step widens the band beside it, so the river stays as fat on its turns
		# as on its runs.
		var steep := i + 1 < line.size() and line[i + 1] != hx + Vector2i(1, 0)
		for k in range(1, thick):
			var below := hx + _below(k)
			if Hex.axial_to_offset(below).y <= hi:
				_flood(below)
				if steep and not narrow_cols.has(Hex.axial_to_offset(below + Vector2i(1, 0)).x):
					_flood(below + Vector2i(1, 0))
		if thick >= 3 and Hex.axial_to_offset(hx + _below(thick)).y <= hi and rng.randf() < RIVER_DEEP:
			_flood(hx + _below(thick))
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


## The hex `k` rows below a hex, as near straight down as the grid lets: south-east, then south-
## west, and so on, so a column of them stays under its top.
static func _below(k: int) -> Vector2i:
	return Vector2i(-(k / 2), k)


## RIVER DELTA (Ryan, 16 November, of the fjord laid before it: "too much water, there aren't
## enough land paths from the gate to the rift. I think that's my bad, as I was thinking more of a
## River Delta with lots of inlets, and not actually a true fjord"; then "the water going all the
## way from the wall to the other edge"; then "thinner water and more of them. Many small
## intertwining streams, not a few fat rivers. We don't need to guarantee land bridges if that's a
## problem. We could even make it like a true delta and put the "mouth" at either the gate or
## rift"): a true delta, a river fanning out into streams a hex wide. The river comes in at one end,
## by the seed: down past the rift's end beside it, or out from under the wall off the gate's front;
## it runs whole and two hexes wide for a row or two, then splits, and splits again, each stream
## taking its share of the fan's width as the delta's arms do, until one runs for every four
## columns across the field and past both edges at the far end; there it meets the wall, or the
## lagoon past the rift that a delta from the gate empties into. The streams wander, touch and
## part, and a short cut joins two now and then, so they braid round islands of land; no dry way
## from the rift to the gate is kept, since every stream is a single wade. Shingle on some shores
## (_shore). Tests the wade at every step and where to cross, a formation standing in water.
const DELTA_PER := 3.5        # columns of the fan's far end a stream
const DELTA_TRUNK := 2        # rows the river runs whole, two wide, before it first splits
const DELTA_SPLIT := 0.55     # the chance a stream bound to become several splits on a row, before it must
const DELTA_WANDER := 0.8     # how far a stream's course may wander off its share, in columns a row
const DELTA_ISLET := 0.18     # the chance a stream forks round an islet on a row of a fan ten rows deep, the fork rejoining it
const DELTA_LINK := 0.15      # the chance two streams two or three columns apart are joined on a row of a fan ten rows deep
const DELTA_SHINGLE := 0.2    # the share of the delta's shores dressed as shingle


## How many columns the delta's fan runs past each edge: two, one on a field under twelve wide.
func _delta_over() -> int:
	return 2 if width >= 12 else 1


## How many streams the delta's far end takes: one for every DELTA_PER columns of the fan, three
## at least.
func _delta_count() -> int:
	return maxi(3, roundi(float(width + 2 * _delta_over()) / DELTA_PER))


func _lay_delta(rng: RandomNumberGenerator) -> void:
	var from_rift := rng.randf() < 0.5
	var side := 1 if rng.randf() < 0.5 else -1
	var rift_col := Hex.axial_to_offset(rift).x
	var gate_col := Hex.axial_to_offset(gate).x
	var first := -MARGIN_ROWS
	var last := _apron_row()
	# The rift's five hexes, its row's three and the two in front of its middle (_widen_rift, which
	# runs after the shape): no stream runs through them.
	var block := {}
	for hx in rift_hexes:
		block[hx] = true
	for n in Hex.neighbors(rift):
		if has(n) and Hex.axial_to_offset(n).y == 1:
			block[n] = true
	var row := first
	var dir := 1
	var apex: Vector2i
	if from_rift:
		apex = Hex.offset_to_axial(rift_col + side * rng.randi_range(3, 4), first)
	else:
		apex = Hex.offset_to_axial(clampi(gate_col + side * rng.randi_range(2, 3), 0, width - 1), last)
		row = last
		dir = -1
		# The lagoon past the rift, where a delta from the gate empties.
		for hx in _scenery():
			if Hex.axial_to_offset(hx).y < 0:
				_flood(hx)
	var end_row := last if from_rift else first
	# Each stream: [its hex, the west and east of its share of the fan, its course's wander, how many
	# streams it is still to become, the rows an islet's fork has still to run apart].
	var over := float(_delta_over())
	var streams: Array = [[apex, -over, float(width - 1) + over, 0.0, _delta_count(), 0]]
	var whole := DELTA_TRUNK
	# The braids' chances read for a fan ten rows deep, so a deep field braids no more than a shallow.
	var per_row := 10.0 / float(absi(end_row - row) + 1)
	while true:
		for st in streams:
			_flood(st[0])
			if whole > 0:
				_flood(st[0] + Vector2i(1, 0))   # the river whole, two wide
		_delta_links(rng, streams, DELTA_LINK * per_row)
		if row == end_row:
			break
		var left := absi(end_row - row)
		row += dir
		whole -= 1
		var next: Array = []
		for st in streams:
			var lo: float = st[1]
			var hi: float = st[2]
			var bound: int = st[4]
			var apart: int = st[5]
			var wander := clampf(float(st[3]) + rng.randf_range(-DELTA_WANDER, DELTA_WANDER), -(hi - lo) * 0.3, (hi - lo) * 0.3)
			if whole <= 0 and bound >= 2 and (rng.randf() < DELTA_SPLIT or left <= bound + 3):
				# A split: each arm its share of the fan by the streams it is to become, so the far
				# end's streams lie evenly across it.
				var west_n := bound / 2
				var mid := lo + (hi - lo) * float(west_n) / float(bound)
				var a := _delta_step(rng, st[0], (lo + mid) * 0.5, dir, left, block, -1)
				var b := _delta_step(rng, st[0], (mid + hi) * 0.5, dir, left, block, 1)
				next.append([a, lo, mid, 0.0, west_n, 0])
				next.append([b, mid, hi, 0.0, bound - west_n, 0])
				continue
			var aim := (lo + hi) * 0.5 + wander
			if apart > 0:
				aim += minf(2.0, (hi - lo) * 0.4) * signf(float(st[3]))   # an islet's fork, running apart for its rows
			next.append([_delta_step(rng, st[0], aim, dir, left, block, 0), lo, hi, wander if apart <= 0 else float(st[3]), bound, maxi(0, apart - 1)])
			if whole <= 0 and bound == 1 and apart <= 0 and left >= 4 and rng.randf() < DELTA_ISLET * per_row:
				# An islet: the stream forks, the fork running two or three rows apart before it
				# turns back and rejoins.
				var lean := 1 if rng.randf() < 0.5 else -1
				next.append([_delta_step(rng, st[0], aim + minf(2.0, (hi - lo) * 0.4) * float(lean), dir, left, block, lean), lo, hi, float(lean) * 0.01, 1, rng.randi_range(2, 3)])
		# Streams that meet run on as one, its share both of theirs; a fork back beside the stream
		# it left joins it.
		streams = []
		for st in next:
			var joined := false
			for kept in streams:
				var same: bool = kept[0] == st[0]
				var rejoin: bool = int(kept[5]) <= 0 and int(st[5]) <= 0 and is_equal_approx(float(kept[1]), float(st[1])) and is_equal_approx(float(kept[2]), float(st[2])) and Hex.distance(kept[0], st[0]) <= 1
				if same or rejoin:
					kept[1] = minf(float(kept[1]), float(st[1]))
					kept[2] = maxf(float(kept[2]), float(st[2]))
					kept[4] = maxi(int(kept[4]), int(st[4])) if rejoin else int(kept[4]) + int(st[4])
					joined = true
					break
			if not joined:
				streams.append(st)
	water_feature = "delta"


## One step of a delta's stream to the next row (`dir`, down the field or up it), toward the column
## `aim`: the nearer of the two hexes there (`lean` picks one when splitting), never a hex of the
## rift, with a step or two along the row first where the far end is too near to reach its aim
## from the slant alone; the hexes it crosses flooded. Returns where it lands.
func _delta_step(rng: RandomNumberGenerator, from: Vector2i, aim: float, dir: int, left: int, block: Dictionary, lean: int) -> Vector2i:
	var cur := from
	for k in range(2):
		var col := float(Hex.axial_to_offset(cur).x)
		if absf(aim - col) - 0.5 * float(left) <= 1.0:
			break
		var side := Vector2i(1 if aim > col else -1, 0)
		if block.has(cur + side):
			break
		cur += side
		_flood(cur)
	var open: Array[Vector2i] = []
	for attempt in range(5):
		var options: Array[Vector2i] = []
		if dir > 0:
			options.append_array([cur + Vector2i(0, 1), cur + Vector2i(-1, 1)])
		else:
			options.append_array([cur + Vector2i(0, -1), cur + Vector2i(1, -1)])
		for o in options:
			if not block.has(o):
				open.append(o)
		if not open.is_empty():
			break
		# The rift in the way: round it along the row, away from its middle.
		cur += Vector2i(1 if Hex.axial_to_offset(cur).x >= Hex.axial_to_offset(rift).x else -1, 0)
		_flood(cur)
	if open.is_empty():
		return cur
	if open.size() == 1:
		return open[0]
	var x0 := float(Hex.axial_to_offset(open[0]).x) + (0.5 if Hex.axial_to_offset(open[0]).y % 2 != 0 else 0.0)
	var x1 := float(Hex.axial_to_offset(open[1]).x) + (0.5 if Hex.axial_to_offset(open[1]).y % 2 != 0 else 0.0)
	var west := open[0] if x0 < x1 else open[1]
	var east := open[1] if x0 < x1 else open[0]
	if lean < 0:
		return west
	if lean > 0:
		return east
	var dw := absf(minf(x0, x1) - aim)
	var de := absf(maxf(x0, x1) - aim)
	if absf(dw - de) < 0.25:
		return west if rng.randf() < 0.5 else east
	return west if dw < de else east


## A short cut between two of the delta's streams on their row, two or three columns apart, now and
## then, so the streams braid round islands rather than only fan.
func _delta_links(rng: RandomNumberGenerator, streams: Array, chance: float) -> void:
	var cols: Array = []
	for st in streams:
		cols.append(Hex.axial_to_offset(st[0]))
	cols.sort_custom(func(a: Vector2i, b: Vector2i) -> bool: return a.x < b.x)
	for i in range(cols.size() - 1):
		var a: Vector2i = cols[i]
		var b: Vector2i = cols[i + 1]
		if a.y != b.y or b.x - a.x < 2 or b.x - a.x > 3 or rng.randf() >= chance:
			continue
		for c in range(a.x + 1, b.x):
			_flood(Hex.offset_to_axial(c, a.y))


## BADLANDS (Ryan, 9 November: "winding paths broken by small obstacles, like an open field that
## you can't take a straight path through"; 10 November: "can use more spires, and I barely see
## any grouping"): mesas in groups of two to five, many of them, a hex of ground between any two
## groups, so no straight line crosses the field and every walk winds; two or three ponds of two
## to four hexes among them; scrub at about two thirds of the mesas' feet and out in the scenery, where the
## mesas go on (Ryan, 16 November: "reduce the number of Rough hexes a bit"; every foot was scrub).
## Tests the longest walks and the pack that cannot come straight.
const BADLANDS_PER := 9      # open hexes a group of mesas
const BADLANDS_SIZES := [2, 2, 3, 3, 3, 4, 4, 5]   # a group's hexes, drawn from this
const BADLANDS_SCRUB := 0.65  # the chance a hex at a mesa's foot, or out in the scenery, is scrub


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
		if rng.randf() < BADLANDS_SCRUB:
			_dress_ground(hx, Terrain.ROUGH)
	var feet := {}
	for hx in wall_look.keys():
		for nb in Hex.neighbors(hx):
			feet[nb] = true
	var at_feet := feet.keys()
	at_feet.sort()
	for nb in at_feet:
		if rng.randf() < BADLANDS_SCRUB:
			_dress_ground(nb, Terrain.ROUGH)


## OPEN STEPPE: relatively clear, the baseline the others are read against, but never bare
## (Ryan, 10 November: "Steppe is VERY barren"; 16 November: "Open steppe is still too sparse"),
## and the anything-goes ground (the same day: "I think Open Steppe is the anything-goes terrain,
## it pulls from all the others in small doses. Multiple crag types, even"; then "Water features
## can be larger where they appear. Little lakes ... I guess use every crag EXCEPT gorge's, now"; then
## "Agreed about the cliffs. They can take a larger share of the Steppe's crags"): a wall of one to
## three hexes for every six columns of the width, half of them cliffs, the steppe's own look since
## the gorge's went to chasms, and the rest each of another look (a crag, a mesa's spires, a lone
## tower; never the gorge's chasm); a little lake of five to eight hexes, round, for every eight; a
## patch of ruins of two to four for every ten; scrub in belts from a seeded noise over about a
## sixth of it, the one rise, grass on the open field (the dress) and the odd crag out in the
## scenery.
const STEPPE_PER := 8         # columns of the width a lake
const STEPPE_LAKE := [5, 8]   # a lake's hexes, from the first to the second
const STEPPE_CRAG_PER := 6    # columns of the width a wall
const STEPPE_RUINS_PER := 10  # columns of the width a patch of ruins
const STEPPE_CLIFFS := 0.5    # the share of its walls that are cliffs, rounded up
const STEPPE_LOOKS := ["crags", "mesas", "towers"]   # the rest of its walls, each once before any twice: every look but the gorge's
const STEPPE_SCRUB := 0.17    # the share of the field in scrub belts


## An array shuffled in place by the map's seed.
static func _shuffle(rng: RandomNumberGenerator, arr: Array) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t = arr[i]
		arr[i] = arr[j]
		arr[j] = t


## How many lakes the steppe takes: one for every STEPPE_PER columns, one at least.
func _steppe_count() -> int:
	return maxi(1, width / STEPPE_PER)


func _lay_steppe(rng: RandomNumberGenerator) -> void:
	var spots := _field_spots(mouth_rows() + 1, _hi() - 1, 1, width - 2)
	var ponds := 0
	for i in range(_steppe_count()):
		if not _grow(rng, spots, rng.randi_range(int(STEPPE_LAKE[0]), int(STEPPE_LAKE[1])), "", 2, true).is_empty():
			ponds += 1
	var looks: Array = STEPPE_LOOKS.duplicate()
	_shuffle(rng, looks)
	var count := maxi(1, width / STEPPE_CRAG_PER)
	var cliffs := ceili(float(count) * STEPPE_CLIFFS)
	# The other looks first, so each finds room among the lakes; then the cliffs. None in front of
	# the rift, where the mouth is bared of walls once the shape is laid (_clear_ends).
	var wall_spots: Array = spots.filter(func(hx: Vector2i) -> bool: return Hex.distance(hx, rift) > 2)
	var walls: Array = []
	for i in range(count - cliffs):
		walls.append(str(looks[i % looks.size()]))
	for i in range(cliffs):
		walls.append("cliffs")
	for look in walls:
		_grow(rng, wall_spots, rng.randi_range(1, 3), str(look), 2)
	var ruins: Array = []
	for i in range(maxi(1, width / STEPPE_RUINS_PER)):
		ruins.append_array(_grow_ground(rng, spots, rng.randi_range(2, 4), 1))
	water_feature = "lakes" if ponds > 1 else ("a lake" if ponds == 1 else "")
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
	for hx in ruins:
		_dress_ground(hx, Terrain.RUINS)   # over the scrub: a patch of ruins stands out of it
	var scenery := _scenery()
	for g in range(rng.randi_range(1, 3)):
		_grow(rng, scenery, rng.randi_range(1, 2), "crags", 2)


## RUINED CITY (Ryan, 9 November: "channels broken by side streets, larger groups of impassible
## terrain", the future's cities "towering massive entities, so dense sections of skyscrapers"):
## a grid of streets between large blocks of towers. Avenues run from the wall toward the rift
## one hex wide, four to five columns apart with the gate's column always one of them (two wide,
## the main avenue the roads start on); cross-streets run along the wall every third row, so a
## block is two rows deep (Ryan, 16 November: "it might need more cross-streets (i.e. parallel to
## the wall), meaning each chunk of city crags is thinner, 2 instead of 3"), every segment of it
## open; an avenue segment may be fallen in (a collapsed tower), so the way round is the
## cross-street. On a field twelve wide or more the blocks between the field's edge and the first
## avenue on one side are a suburb, ruins in place of towers (the same day: "at least one suburbs
## section, where instead of Crags its Ruins"), and a block elsewhere is a plaza, open ground,
## two on a narrower field with no suburb: two such sections at most, whatever the field (his
## next notes: "limit to two suburbs"). No
## water (the same day: "Lets take all water out"; its fountains and flooded streets went).
## Rubble everywhere else, towers thick in the scenery as the city goes on. The streets are the
## city's roads (_lay_roads). Tests the streets held and the team fighting apart, the channel a
## pack must take and the flyer's crossing of its own.
const CITY_SCENERY_TOWERS := 0.5   # the share of the scenery a tower stands on
const CITY_FALLEN := 0.15          # the chance an avenue's segment between two cross-streets has fallen in
const CITY_PLAZAS := [1, 2]        # how many blocks are plazas, a suburb counting as one: two open sections at most


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
	# The cross-streets: every third row, the last open row one where it falls there, so no block
	# is more than two rows deep.
	var side_rows: Array[int] = []
	var row_at := lo + 2
	while row_at <= hi:
		side_rows.append(row_at)
		row_at += 3
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
			var seg: Array = []
			for col in range(int(stops[i]) + 1, int(stops[i + 1])):
				var hx := Hex.offset_to_axial(col, row)
				if has(hx):
					_cut(hx)
					street_hexes[hx] = true
					seg.append(hx)
			if not seg.is_empty():
				paths.append(seg)
	# The suburb: the blocks between one edge of the field and its first avenue, ruins where the
	# towers stood, the side picked by the seed.
	var blocks: Array = _city_blocks(avenues, side_rows)
	var west_side := rng.randf() < 0.5
	var suburb: Array = []
	if width >= 12 and not avenues.is_empty():
		var edge_col: int = avenues[0] if west_side else avenues[avenues.size() - 1]
		for block in blocks:
			var col := Hex.axial_to_offset(block[0]).x
			if (west_side and col < edge_col) or (not west_side and col > edge_col):
				suburb.append(block)
	var sub_hexes: Array = []
	for block in suburb:
		blocks.erase(block)
		for hx in block:
			_cut(hx)
			sub_hexes.append(hx)
	if not sub_hexes.is_empty():
		city_open.append(sub_hexes)
	# The plazas: a block or two opened whole, with the suburb two at most.
	var plazas := int(CITY_PLAZAS[rng.randi_range(0, CITY_PLAZAS.size() - 1)])
	if not suburb.is_empty():
		plazas = 1
	for n in range(plazas):
		if blocks.is_empty():
			break
		var block: Array = blocks.pop_at(rng.randi_range(0, blocks.size() - 1))
		for hx in block:
			_cut(hx)
		city_open.append(block)
	water_feature = ""
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


## GORGE (Ryan, 9 November: "winding, branching channels"; 16 November, of a gorge of holes rather
## than cliffs: "Invert it. I had always intended gorge, even as cliffs, to be narrow winding paths
## and less large sections of impassible area. So this makes sense. It should be medium-sized
## chunks of land, with narrow land bridges between them. That makes it different from Delta in
## that you funnel through a narrow area to get to a wider skirmish space"): the ground broken into
## chunks of land by chasms a hex wide that wind along their borders, the field's and the
## scenery's alike, each chunk joined to a chunk beside it by a land bridge a hex wide, or by none
## where the chunks stay joined the long way round; now and then a stretch of chasm flooded, a
## wade. Scree at the chasms' edges. Tests the funnel: the bridge held, the open ground past it
## fought over.
const GORGE_CHUNK := 4            # the least distance between two chunks' middles
const GORGE_BEND := 0.9           # how far a seeded noise bends the chasms off the straight
const GORGE_UNBRIDGED := 0.3      # the chance two chunks beside each other get no bridge, where every chunk stays joined
const GORGE_FLOODED := 0.4        # the chance a stretch of chasm is flooded
const GORGE_SCREE := 0.3          # the share of the chasms' edges in scree


func _lay_gorge(rng: RandomNumberGenerator) -> void:
	var lo := mouth_rows()
	var hi := _hi()
	# The band: the field's open rows and the scenery beside them.
	var band: Array = _field_spots(lo, hi)
	for hx in _scenery():
		var row := Hex.axial_to_offset(hx).y
		if row >= lo and row <= hi:
			band.append(hx)
	# The chunks' middles, thrown in a seeded order and kept GORGE_CHUNK apart.
	var order := band.duplicate()
	for i in range(order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t: Vector2i = order[i]
		order[i] = order[j]
		order[j] = t
	var middles: Array[Vector2i] = []
	for hx in order:
		var apart := true
		for m in middles:
			apart = apart and Hex.distance(hx, m) >= GORGE_CHUNK
		if apart:
			middles.append(hx)
	# Each hex to its nearest middle, a noise bending the borders so the chasms wind.
	var noise := FastNoiseLite.new()
	noise.seed = map_seed + 707
	noise.frequency = 0.35
	noise.fractal_type = FastNoiseLite.FRACTAL_NONE
	var owner := {}
	for hx in band:
		var best := -1
		var best_d := INF
		for i in range(middles.size()):
			var p := Hex.to_pixel(hx, 1.0)
			var d := float(Hex.distance(hx, middles[i])) + noise.get_noise_3d(p.x, p.y, float(i) * 7.0) * GORGE_BEND
			if d < best_d:
				best_d = d
				best = i
		owner[hx] = best
	# The chasm: a hex of the later chunk where two chunks meet, so it runs a hex wide.
	var chasm := {}
	for hx in band:
		for n in Hex.neighbors(hx):
			if owner.has(n) and int(owner[n]) != int(owner[hx]) and int(owner[hx]) > int(owner[n]):
				chasm[hx] = true
				break
	# The bridges: for each two chunks the chasm parts, one chasm hex between their land made land.
	var bridges := {}   # "a,b" -> the chasm hexes that would join them
	for hx in chasm.keys():
		var sides := {}
		for n in Hex.neighbors(hx):
			if owner.has(n) and not chasm.has(n):
				sides[int(owner[n])] = true
		var chunks := sides.keys()
		chunks.sort()
		for i in range(chunks.size()):
			for j in range(i + 1, chunks.size()):
				var key := "%d,%d" % [chunks[i], chunks[j]]
				if not bridges.has(key):
					bridges[key] = []
				(bridges[key] as Array).append(hx)
	var keys := bridges.keys()
	keys.sort()
	var laid: Array = []   # [key, hex]
	for key in keys:
		var options: Array = bridges[key]
		laid.append([key, options[rng.randi_range(0, options.size() - 1)]])
	# Some pairs go unbridged, where every chunk stays joined to the rest.
	for i in range(laid.size() - 1, -1, -1):
		if rng.randf() >= GORGE_UNBRIDGED:
			continue
		var kept: Array = laid.duplicate()
		kept.remove_at(i)
		if _chunks_joined(kept, middles.size()):
			laid = kept
	for b in laid:
		chasm.erase(b[1])
	for hx in chasm.keys():
		_wall(hx, "chasms")
	# A flooded stretch now and then: chasm a wade, two or three hexes of it on the field.
	var flooded := 0
	if rng.randf() < GORGE_FLOODED:
		var field_chasm: Array = []
		for hx in chasm.keys():
			if has(hx):
				field_chasm.append(hx)
		field_chasm.sort()
		if not field_chasm.is_empty():
			var at: Vector2i = field_chasm[rng.randi_range(0, field_chasm.size() - 1)]
			_flood(at)
			flooded += 1
			for n in Hex.neighbors(at):
				if flooded < 3 and chasm.has(n) and has(n) and terrain[n] == Terrain.MOUNTAIN:
					_flood(n)
					flooded += 1
	water_feature = "a flooded chasm" if flooded > 0 else ""


## Whether the bridges in `laid` ([key "a,b", hex] each) join all `n` chunks into one.
static func _chunks_joined(laid: Array, n: int) -> bool:
	if n <= 1:
		return true
	var links := {}
	for b in laid:
		var ab := str(b[0]).split(",")
		var a := int(ab[0])
		var c := int(ab[1])
		if not links.has(a):
			links[a] = []
		if not links.has(c):
			links[c] = []
		links[a].append(c)
		links[c].append(a)
	var seen := {0: true}
	var queue: Array = [0]
	while not queue.is_empty():
		var cur: int = queue.pop_front()
		for nxt in links.get(cur, []):
			if not seen.has(nxt):
				seen[nxt] = true
				queue.append(nxt)
	return seen.size() >= n


## Rough ground in stretches along the water's edge or at a wall's foot: a river's gravel bars,
## a delta's shingle, a gorge's scree, the shape's second decorative ground (the bible's shapes
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
		"river":
			_shore(Terrain.WATER, SHORE_SHARE)
		"delta":
			_shore(Terrain.WATER, DELTA_SHINGLE)   # nearly every hex of the delta is a shore
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


## The ground right in front of the gate and the rift (the rift's ring is its mouth, where the
## packs land) and the team's two rows above the gate's apron hold no wall, so a deployed machine
## always has somewhere to go and a pack somewhere to land; soft ground may lie there as anywhere
## (Ryan, 16 November: "The apron in front of the wall, and by the rift (if that exists), needs to
## disallow crags, not other soft terrain tiles"): water, rough and ruins stay as the shape laid
## them.
func _clear_ends() -> void:
	var base: int = int(KINDS[kind]["ground"])
	for hx in terrain.keys():
		if is_structure(hx) or terrain[hx] != Terrain.MOUNTAIN:
			continue
		var row := Hex.axial_to_offset(hx).y
		var near := false
		for n in Hex.neighbors(hx):
			near = near or gate_hexes.has(n) or rift_hexes.has(n)
		if near or row < mouth_rows() or row > _hi():
			terrain[hx] = base
			crag_base.erase(hx)
			wall_look.erase(hx)


## The roads lead somewhere (Ryan, 29 October): the river's from the gate to each narrow (the
## water fords) and on across it, the steppe's one road
## north from the gate, the city's streets (its avenues from the wall's end toward the rift, the
## main one from the gate, and its side streets). The delta, the badlands and the gorge lay
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
## out in the scenery, away from the river, the delta and the gorge, and the steppe's scenery
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
		"gorge":
			for hx in _scenery():
				want[hx] = 3
		"delta":
			# The delta's mouth lies low: its scenery rises off its water as the river's does.
			var dist := _water_distance()
			for hx in _scenery():
				want[hx] = clampi(int(dist.get(hx, 9)) - 1, 0, 2)
	for hx in elevation.keys():
		if terrain_of(hx) == Terrain.WATER:
			elevation[hx] = -1
		elif str(wall_look.get(hx, "")) == "chasms":
			elevation[hx] = -2   # a chasm drops deep
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


## How many dry routes run from the rift to the gate with no hex in common, counted up to
## `limit`: the narrowest crossing with water counted a wall (the delta's land paths, Ryan, 16
## November: "there aren't enough land paths from the gate to the rift").
func dry_crossing(limit: int = 9) -> int:
	return int(_horde_flow(limit, true)[0])


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


func _horde_flow(limit: int, dry: bool = false) -> Array:
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
	var ground := func(h: Vector2i) -> bool:
		return _horde_ground(h) and not (dry and terrain[h] == Terrain.WATER)
	for h in terrain.keys():
		if not ground.call(h):
			continue
		link.call(_flow_in(h), _flow_out(h), 1)
		for n in Hex.neighbors(h):
			if ground.call(n):
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
