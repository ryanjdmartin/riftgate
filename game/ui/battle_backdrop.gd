class_name BattleBackdrop
extends RefCounted

## The other world as a JRPG battle screen's backdrop, the far part of the skirmish's field (29
## October; Ryan found the bare overworld tiles "amateurish, distracting, and
## immersion-breaking"): a sky, the far land on the horizon and a floor in perspective, the
## floor's bands laid by the field's camera, in the domain's palette (keyed by its `bleed` in
## content, DomainGround.BACKDROPS beside the map's tileset) and dressed by the contact hex's
## ground, painted once into an image at the foes' own pixel grid so they stand on it in the
## pixels they are drawn in. Nothing in it is outlined and its values sit in a narrow range: the
## sprites carry the outlines and the contrast. Deterministic per seed; every colour and size a
## placeholder, judged on the phone.

const BAYER := [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5]

## One palette a domain's bleed, kept beside its map tileset (DomainGround.BACKDROPS) so a
## domain's colours change in one place and the fight's water is the map's liquid.
const PALETTES := DomainGround.BACKDROPS


## The backdrop for one fight: `size` in art pixels, `horizon` the row the floor starts on.
## `biome` is a domain's bleed; one with no palette paints the first. `rows` lays the floor's
## bands on the floor camera's hex rows ({"k", "phase"}: the band at an art row d below the
## horizon is floor(k / d + phase)); without it they keep a spacing of their own.
static func paint(biome: String, terrain: int, seed_value: int, size: Vector2i, horizon: int, rows: Dictionary = {}) -> Image:
	var img := Image.create_empty(maxi(size.x, 16), maxi(size.y, 16), false, Image.FORMAT_RGBA8)
	var key := biome if PALETTES.has(biome) else str(PALETTES.keys()[0])
	var p := Painter.new(img, key, terrain, seed_value, horizon)
	p.rows = rows
	p.run()
	return img


static func bayer(x: int, y: int) -> float:
	return (float(BAYER[(y & 3) * 4 + (x & 3)]) + 0.5) / 16.0


class Painter:
	var img: Image
	var pal: Dictionary
	var biome: String
	var terrain: int
	var seed_value: int
	var rng := RandomNumberGenerator.new()
	var w: int
	var h: int
	var hz: int        # the horizon's row
	var s: float       # feature scale: 1 on a band 540 art pixels wide (the 1080 phone's)
	var rows: Dictionary = {}   # the floor camera's hex rows for the floor's bands (paint)

	func _init(i: Image, key: String, t: int, sd: int, horizon: int) -> void:
		img = i
		biome = key
		pal = PALETTES[key]
		terrain = t
		seed_value = sd
		rng.seed = sd
		w = img.get_width()
		h = img.get_height()
		hz = clampi(horizon, 8, h - 8)
		s = float(w) / 540.0

	func c(name: String, i: int = 0) -> Color:
		var v = pal.get(name, "ff00ff")
		return Color(str(v[clampi(i, 0, v.size() - 1)] if v is Array else v))

	func run() -> void:
		sky()
		match biome:
			"sand": sun()
			"marsh": moon()
		match biome:
			"plains": clouds()
			"sand": streaks()
			"lava": ash()
		far_land()
		match terrain:
			BattleMap.Terrain.MOUNTAIN: mountains()
			BattleMap.Terrain.ROUGH: thicket()
		floor_plane()
		match terrain:
			BattleMap.Terrain.WATER: lake()
			BattleMap.Terrain.ROAD: road()
			BattleMap.Terrain.RUINS: ruins()
		if biome == "marsh":
			mist()
		horizon_dressing()
		floor_details()

	# ------------------------------------------------------------ primitives

	func px(x: int, y: int, col: Color) -> void:
		if x >= 0 and y >= 0 and x < w and y < h:
			img.set_pixel(x, y, col)

	## A vertical span [y0, y1).
	func vspan(x: int, y0: int, y1: int, col: Color) -> void:
		var a := maxi(y0, 0)
		var b := mini(y1, h)
		if b > a and x >= 0 and x < w:
			img.fill_rect(Rect2i(x, a, 1, b - a), col)

	## A horizontal span [x0, x1).
	func hspan(x0: int, x1: int, y: int, col: Color) -> void:
		var a := maxi(x0, 0)
		var b := mini(x1, w)
		if b > a and y >= 0 and y < h:
			img.fill_rect(Rect2i(a, y, b - a, 1), col)

	## A row between two colours, `f` of it the second by the ordered dither.
	func row(x0: int, x1: int, y: int, a: Color, b: Color, f: float) -> void:
		if f <= 0.0:
			hspan(x0, x1, y, a)
		elif f >= 1.0:
			hspan(x0, x1, y, b)
		else:
			for x in range(maxi(x0, 0), mini(x1, w)):
				img.set_pixel(x, y, b if BattleBackdrop.bayer(x, y) < f else a)

	## `f` of a row's pixels laid over in `col` by the ordered dither, the rest left.
	func veil(x0: int, x1: int, y: int, col: Color, f: float) -> void:
		if f <= 0.0 or y < 0 or y >= h:
			return
		if f >= 1.0:
			hspan(x0, x1, y, col)
			return
		for x in range(maxi(x0, 0), mini(x1, w)):
			if BattleBackdrop.bayer(x, y) < f:
				img.set_pixel(x, y, col)

	## A filled ellipse by rows, cut off below `floor_y`.
	func disc(cx: float, cy: float, rx: float, ry: float, col: Color, floor_y: float = 1.0e9) -> void:
		if rx < 0.5 or ry < 0.5:
			px(int(cx), int(cy), col)
			return
		for y in range(int(floorf(cy - ry)), int(ceilf(cy + ry)) + 1):
			if float(y) > floor_y:
				break
			var dy := (float(y) + 0.5 - cy) / ry
			if absf(dy) > 1.0:
				continue
			var half := rx * sqrt(1.0 - dy * dy)
			hspan(int(roundf(cx - half)), int(roundf(cx + half)), y, col)

	## A filled polygon by rows (convex or not), for the shapes the land is made of.
	func poly(pts: PackedVector2Array, col: Color) -> void:
		var y0 := INF
		var y1 := -INF
		for p in pts:
			y0 = minf(y0, p.y)
			y1 = maxf(y1, p.y)
		for y in range(int(floorf(y0)), int(ceilf(y1)) + 1):
			var yc := float(y) + 0.5
			var xs: Array = []
			for k in range(pts.size()):
				var a := pts[k]
				var b := pts[(k + 1) % pts.size()]
				if (a.y <= yc and b.y > yc) or (b.y <= yc and a.y > yc):
					xs.append(a.x + (yc - a.y) / (b.y - a.y) * (b.x - a.x))
			xs.sort()
			for k in range(0, xs.size() - 1, 2):
				hspan(int(roundf(xs[k])), int(roundf(xs[k + 1])), y, col)

	func line(a: Vector2, b: Vector2, col: Color) -> void:
		var n := int(maxf(absf(b.x - a.x), absf(b.y - a.y))) + 1
		for k in range(n + 1):
			var p := a.lerp(b, float(k) / float(n))
			px(int(roundf(p.x)), int(roundf(p.y)), col)

	func noise(salt: int, period: float, octaves: int = 3) -> FastNoiseLite:
		var n := FastNoiseLite.new()
		n.seed = seed_value + salt
		n.noise_type = FastNoiseLite.TYPE_PERLIN
		n.frequency = 1.0 / maxf(1.0, period)
		n.fractal_octaves = octaves
		return n

	## The sky's last band: what the far land fades toward.
	func haze() -> Color:
		return c("sky", 4)

	## A row's depth into the floor, 0 at the horizon and 1 at the foot of the band: how large a
	## thing standing there is drawn.
	func scale_at(y: float) -> float:
		return clampf((y - float(hz)) / float(h - hz), 0.0, 1.0)

	# ------------------------------------------------------------ the sky

	func sky() -> void:
		var cols: Array = pal["sky"]
		var n := cols.size()
		for y in range(hz):
			var t := float(y) / float(maxi(1, hz - 1)) * float(n - 1)
			var i := mini(int(t), n - 2)
			var f := t - float(i)
			# The change gathered into a dithered step in the middle of each band, in quarters:
			# the console's sky, never a smooth ramp.
			var g := roundf(clampf((f - 0.5) * 2.4 + 0.5, 0.0, 1.0) * 4.0) / 4.0
			row(0, w, y, Color(str(cols[i])), Color(str(cols[i + 1])), g)

	func sun() -> void:
		var cx := w * 0.78
		var cy := hz * 0.34
		var r := 15.0 * s
		var halo := c("sky", 3).lerp(Color("fff4d0"), 0.35)
		for k in range(3, 0, -1):
			var rr := r + k * 5.0 * s
			for y in range(int(cy - rr), int(cy + rr) + 1):
				var dy := (float(y) + 0.5 - cy) / rr
				if absf(dy) > 1.0:
					continue
				var half := rr * sqrt(1.0 - dy * dy)
				veil(int(cx - half), int(cx + half), y, halo, 0.5 - 0.13 * k)
		disc(cx, cy, r, r, Color("fff6dc"))
		disc(cx + r * 0.2, cy - r * 0.2, r * 0.6, r * 0.6, Color("fffcf0"))

	func moon() -> void:
		var cx := w * 0.2
		var cy := hz * 0.3
		var r := 11.0 * s
		var halo := c("sky", 2).lerp(Color("c8d0b8"), 0.25)
		for k in range(2, 0, -1):
			var rr := r + k * 6.0 * s
			for y in range(int(cy - rr), int(cy + rr) + 1):
				var dy := (float(y) + 0.5 - cy) / rr
				if absf(dy) > 1.0:
					continue
				var half := rr * sqrt(1.0 - dy * dy)
				veil(int(cx - half), int(cx + half), y, halo, 0.38 - 0.12 * k)
		disc(cx, cy, r, r, Color("dfe6cc"))
		disc(cx - r * 0.3, cy + r * 0.15, r * 0.25, r * 0.22, Color("c2caae"))
		disc(cx + r * 0.35, cy - r * 0.3, r * 0.18, r * 0.16, Color("c2caae"))
		disc(cx + r * 0.1, cy + r * 0.5, r * 0.14, r * 0.12, Color("c2caae"))

	## Fair-weather cumulus, flat-bottomed, lit from the right as the overworld's mountains are.
	func clouds() -> void:
		var n := 3 + rng.randi() % 2
		for k in range(n):
			var cx := (float(k) + rng.randf_range(0.15, 0.85)) * float(w) / float(n)
			var cy := rng.randf_range(0.3, 0.72) * float(hz)
			var size_px := rng.randf_range(16.0, 30.0) * s * (0.6 + 0.4 * cy / float(hz))
			cumulus(cx, cy, size_px, clampf(cy / float(hz) - 0.35, 0.0, 0.6))

	func cumulus(cx: float, cy: float, size_px: float, haze_k: float) -> void:
		var light := c("cloud", 0).lerp(haze(), haze_k * 0.6)
		var body := c("cloud", 1).lerp(haze(), haze_k)
		var shade := c("cloud", 2).lerp(haze(), haze_k)
		var puffs: Array = []
		var n := 3 + rng.randi() % 3
		for i in range(n):
			var off := float(i) - float(n - 1) * 0.5
			var r := size_px * rng.randf_range(0.36, 0.52) * (1.0 - absf(off) / float(n) * 0.7)
			puffs.append(Vector3(cx + off * size_px * 0.5, cy - r * 0.55, r))
		for p in puffs:
			disc(p.x, p.y + 2.0 * s, p.z, p.z * 0.92, shade, cy)
		for p in puffs:
			disc(p.x - 1.0 * s, p.y - 0.5 * s, p.z * 0.9, p.z * 0.84, body, cy - 2.0 * s)
		for p in puffs:
			disc(p.x + p.z * 0.25, p.y - p.z * 0.3, p.z * 0.42, p.z * 0.36, light, cy)

	## High thin cloud over the desert: long dithered streaks.
	func streaks() -> void:
		for k in range(3):
			var cy := rng.randf_range(0.18, 0.62) * float(hz)
			var cx := rng.randf_range(0.1, 0.8) * float(w)
			var len_px := rng.randf_range(60.0, 130.0) * s
			for dy in range(int(3.0 * s) + 1):
				var shrink := float(dy) * 9.0 * s
				veil(int(cx - len_px * 0.5 + shrink), int(cx + len_px * 0.5 - shrink * 0.4), int(cy) + dy, c("cloud", 0), 0.5 if dy > 0 else 0.75)

	## Ash over the Peak: heavy masses, their bellies lit by the fire under them.
	func ash() -> void:
		var n := 3
		for k in range(n):
			var cx := (float(k) + rng.randf_range(0.2, 0.8)) * float(w) / float(n)
			var cy := rng.randf_range(0.18, 0.45) * float(hz)
			var size_px := rng.randf_range(34.0, 52.0) * s
			for i in range(5):
				var off := float(i) - 2.0
				var r := size_px * rng.randf_range(0.3, 0.42) * (1.0 - absf(off) * 0.12)
				disc(cx + off * size_px * 0.42, cy + 2.0 * s, r * 1.15, r * 0.62, c("cloud", 0))
			for i in range(5):
				var off := float(i) - 2.0
				var r := size_px * rng.randf_range(0.3, 0.42) * (1.0 - absf(off) * 0.12)
				disc(cx + off * size_px * 0.42, cy - 1.0 * s, r * 1.12, r * 0.6, c("cloud", 1))
				disc(cx + off * size_px * 0.42 - r * 0.2, cy - r * 0.3, r * 0.7, r * 0.42, c("cloud", 2))

	# ------------------------------------------------------------ the far land

	func far_land() -> void:
		match biome:
			"plains":
				ridge(float(hz) - 2.0, 26.0 * s, 150.0 * s, 3, c("far", 0), c("far", 1), 11)
				ridge(float(hz), 15.0 * s, 90.0 * s, 3, c("hill", 0).lerp(haze(), 0.35), c("hill", 1).lerp(haze(), 0.3), 12)
			"sand":
				mesas(c("far", 0), c("far", 1), 21, 0.75)
				dunes(float(hz), 9.0 * s, c("hill", 0).lerp(haze(), 0.3), c("hill", 1).lerp(haze(), 0.25), 22)
			"marsh":
				var tops := ridge(float(hz) - 1.0, 12.0 * s, 110.0 * s, 3, c("far", 0), c("far", 1), 31)
				dead_skyline(tops, c("far", 0))
			"lava":
				volcano()
				crags(float(hz), 16.0 * s, c("hill", 0).lerp(haze(), 0.25), c("glow", 0), 41)

	## A line of land on the horizon from noise; returns each column's top.
	func ridge(base: float, amp: float, period: float, octaves: int, fill: Color, rim: Color, salt: int) -> PackedFloat32Array:
		var n := noise(salt, period, octaves)
		var tops := PackedFloat32Array()
		tops.resize(w)
		for x in range(w):
			var v := clampf(0.5 + n.get_noise_1d(float(x)) * 1.1, 0.0, 1.0)
			tops[x] = base - v * amp
		for x in range(w):
			var top := int(roundf(tops[x]))
			vspan(x, top, hz, fill)
			# The lit edge on the slopes facing the light (the right), a darker one elsewhere.
			var right := tops[mini(x + 1, w - 1)]
			px(x, top, rim if right >= tops[x] - 0.2 else fill.lerp(rim, 0.5))
		return tops

	## Low dunes: a smooth ridge with its lee darkened.
	func dunes(base: float, amp: float, fill: Color, rim: Color, salt: int) -> void:
		var n := noise(salt, 70.0 * s, 2)
		var tops := PackedFloat32Array()
		tops.resize(w)
		for x in range(w):
			tops[x] = base - clampf(0.5 + n.get_noise_1d(float(x)) * 1.2, 0.0, 1.0) * amp
		var lee := fill.darkened(0.12)
		for x in range(w):
			var top := int(roundf(tops[x]))
			var falling := tops[mini(x + 1, w - 1)] > tops[x]
			vspan(x, top, hz, lee if falling else fill)
			px(x, top, rim)

	## Flat-topped mesas, strata and a shadowed face, the Waste's far land.
	func mesas(fill: Color, rim: Color, salt: int, haze_k: float) -> void:
		var r2 := RandomNumberGenerator.new()
		r2.seed = seed_value + salt
		var n := 3 + r2.randi() % 2
		for k in range(n):
			var cx := (float(k) + r2.randf_range(0.2, 0.8)) * float(w) / float(n)
			var half := r2.randf_range(18.0, 46.0) * s
			var top := float(hz) - r2.randf_range(14.0, 30.0) * s
			var body := fill.lerp(haze(), haze_k * 0.35)
			var dark := body.darkened(0.14)
			var light := rim.lerp(haze(), haze_k * 0.25)
			var skirt := 6.0 * s
			poly(PackedVector2Array([Vector2(cx - half, top), Vector2(cx + half, top), Vector2(cx + half + skirt, float(hz)), Vector2(cx - half - skirt, float(hz))]), body)
			# The left face in shade, the right lit.
			poly(PackedVector2Array([Vector2(cx - half, top), Vector2(cx - half + 3.0 * s, top), Vector2(cx - half - skirt + 4.0 * s, float(hz)), Vector2(cx - half - skirt, float(hz))]), dark)
			hspan(int(cx - half), int(cx + half), int(top), light)
			var y := top + 4.0 * s
			while y < float(hz) - 2.0:
				veil(int(cx - half), int(cx + half), int(y), dark, 0.5)
				y += 5.0 * s

	## Bare trees on the far marsh's hills, their branches a pixel wide.
	func dead_skyline(tops: PackedFloat32Array, col: Color) -> void:
		var x := 3.0
		while x < float(w) - 3.0:
			var top := tops[int(x)]
			var tall := rng.randf_range(8.0, 22.0) * s
			dead_tree(Vector2(x, top + 1.0), tall, col, 1)
			x += rng.randf_range(7.0, 22.0) * s

	func dead_tree(foot: Vector2, tall: float, col: Color, width: int) -> void:
		var top := foot + Vector2(rng.randf_range(-2.0, 2.0) * s, -tall)
		for k in range(width):
			line(foot + Vector2(k, 0), top + Vector2(k, 0), col)
		var branches := 2 + rng.randi() % 3
		for b in range(branches):
			var t := rng.randf_range(0.3, 0.85)
			var at := foot.lerp(top, t)
			var side := -1.0 if b % 2 == 0 else 1.0
			var reach := tall * rng.randf_range(0.2, 0.42)
			var tip := at + Vector2(side * reach, -reach * rng.randf_range(0.5, 1.0))
			line(at, tip, col)
			if reach > 5.0 * s:
				line(tip, tip + Vector2(side * reach * 0.3, reach * 0.2), col)

	## The Peak's volcano: a smoking cone, its crater and its runs alight.
	func volcano() -> void:
		var cx := float(w) * rng.randf_range(0.58, 0.72)
		var top := float(hz) - 48.0 * s
		var crater := 7.0 * s
		var base := 82.0 * s
		var body := c("far", 0)
		var lit := c("far", 1)
		var pts := PackedVector2Array()
		for k in range(13):
			var t := float(k) / 12.0
			pts.append(Vector2(cx - crater - (base - crater) * pow(t, 1.6), top + (float(hz) - top) * t))
		for k in range(12, -1, -1):
			var t := float(k) / 12.0
			pts.append(Vector2(cx + crater + (base - crater) * pow(t, 1.6), top + (float(hz) - top) * t))
		poly(pts, body)
		# The right flank catches the crater's light.
		var flank := PackedVector2Array()
		for k in range(13):
			var t := float(k) / 12.0
			flank.append(Vector2(cx + crater * 0.3 + (base - crater) * 0.35 * pow(t, 1.6), top + (float(hz) - top) * t))
		for k in range(12, -1, -1):
			var t := float(k) / 12.0
			flank.append(Vector2(cx + crater + (base - crater) * pow(t, 1.6), top + (float(hz) - top) * t))
		poly(flank, lit)
		# The crater's glow and two runs of lava down the flanks.
		hspan(int(cx - crater), int(cx + crater), int(top), c("glow", 2))
		hspan(int(cx - crater + 1.0), int(cx + crater - 1.0), int(top) - 1, c("glow", 3))
		for side in [-1.0, 1.0]:
			var p := Vector2(cx + side * crater * 0.5, top + 1.0)
			var steps := int((float(hz) - top) * 0.7)
			for k in range(steps):
				p += Vector2(side * rng.randf_range(0.2, 0.9), 1.0)
				var heat := 1.0 - float(k) / float(steps)
				px(int(p.x), int(p.y), c("glow", 1) if heat < 0.5 else c("glow", 2))
				if heat > 0.7:
					px(int(p.x) + 1, int(p.y), c("glow", 1))
		# Smoke leaning off to the right, lit from below.
		var sp := Vector2(cx, top - 4.0 * s)
		for k in range(7):
			var r := (5.0 + k * 2.6) * s
			disc(sp.x, sp.y + 1.5 * s, r, r * 0.7, c("cloud", 0).lerp(c("cloud", 1), clampf(float(k) / 3.0, 0.0, 1.0)))
			disc(sp.x - 1.0 * s, sp.y - 1.0 * s, r * 0.92, r * 0.62, c("cloud", 1))
			sp += Vector2(rng.randf_range(4.0, 8.0) * s, -rng.randf_range(5.0, 8.0) * s)

	## Jagged low crags along the horizon, a hot edge at their feet.
	func crags(base: float, amp: float, fill: Color, glow: Color, salt: int) -> void:
		var n := noise(salt, 26.0 * s, 4)
		for x in range(w):
			var v := clampf(0.5 + n.get_noise_1d(float(x)) * 1.3, 0.0, 1.0)
			var top := int(roundf(base - v * v * amp))
			vspan(x, top, hz, fill)
			px(x, top, fill.lightened(0.18))
			veil(x, x + 1, hz - 1, glow, 0.5)

	# ------------------------------------------------------------ the floor

	func floor_plane() -> void:
		var f0 := c("floor", 0)
		var f1 := c("floor", 1)
		var f2 := c("floor", 2)
		var stripe: float = pal.get("stripe", 0.05)
		var span_px := float(h - hz)
		# Bands of equal ground in perspective: the k-th at depth K/d, so they grow toward the
		# viewer (on the floor camera's hex rows when given); faded out where they would be
		# under three pixels.
		var k := float(rows.get("k", 1500.0 * s))
		var phase := float(rows.get("phase", 0.0))
		var fade0 := sqrt(3.0 * k)
		var fade1 := sqrt(9.0 * k)
		var last := -1
		for y in range(hz, h):
			var d := float(y - hz) + 1.0
			var t := d / span_px
			var base := f0.lerp(f1, clampf(t * 2.0, 0.0, 1.0)) if t < 0.5 else f1.lerp(f2, (t - 0.5) * 2.0)
			# The horizon's haze over the farthest rows.
			base = base.lerp(haze(), clampf(1.0 - t * 6.0, 0.0, 1.0) * 0.55)
			var band := int(floorf(k / d + phase))
			var amp := stripe * smoothstep(fade0, fade1, d)
			var dark := base.darkened(amp)
			if posmod(band, 2) == 1:
				hspan(0, w, y, dark)
			else:
				hspan(0, w, y, base)
			# The edge between bands half-dithered, a row wide.
			if band != last and last >= 0 and amp > 0.01:
				row(0, w, y, base if posmod(band, 2) == 1 else dark, dark if posmod(band, 2) == 1 else base, 0.5)
			last = band

	## A lake out on the far floor, its shore short of where the back rank stands; on the Peak a
	## lake of lava crusted over, its cracks alight.
	func lake() -> void:
		var shore := float(hz) + 30.0 * s
		var n := noise(51, 60.0 * s, 3)
		var body := c("water", 1)
		var light := c("water", 2)
		var glint := c("water", 3)
		if biome == "lava":
			body = c("crust", 0)   # the lava crusted over: the map's crust, its cracks alight below
		for x in range(w):
			var edge := int(roundf(shore + n.get_noise_1d(float(x)) * 8.0 * s))
			for y in range(hz, edge):
				var t := float(y - hz) / maxf(1.0, float(edge - hz))
				hspan(x, x + 1, y, body if t > 0.3 else body.lerp(haze(), 0.45 * (1.0 - t / 0.3)))
			if biome == "marsh":
				px(x, edge, light)
			elif biome == "lava":
				px(x, edge, c("glow", 0))
			else:
				vspan(x, edge, edge + int(2.0 * s), c("road", 1))
		if biome == "lava":
			# Cracks in the crust: short wandering runs, a hot core here and there.
			for k in range(26):
				var p := Vector2(rng.randf_range(0.0, float(w)), rng.randf_range(float(hz) + 2.0, shore - 2.0))
				for step in range(int(rng.randf_range(6.0, 20.0) * s)):
					p += Vector2(1.0, rng.randf_range(-0.5, 0.5))
					if p.y < float(hz) + 1.0 or p.y > shore:
						break
					px(int(p.x), int(p.y), c("glow", 1) if step % 7 != 3 else c("glow", 2))
			return
		# Glints: short bright dashes, longer toward the viewer.
		for k in range(30):
			var y := float(hz) + 2.0 + pow(rng.randf(), 1.4) * (shore - float(hz) - 4.0)
			var x := rng.randf_range(0.0, float(w))
			var len_px := (2.0 + (y - float(hz)) / (shore - float(hz)) * 8.0) * s
			hspan(int(x), int(x + len_px), int(y), light if rng.randf() < 0.75 else glint)
		if biome == "marsh":
			for k in range(6):
				var y := rng.randf_range(float(hz) + 3.0, shore - 3.0)
				var x := rng.randf_range(0.0, float(w))
				var r := (3.0 + (y - float(hz)) * 0.3) * s
				disc(x, y, r, r * 0.22, c("bog", 0))   # moss on the bog water
			for k in range(5):
				var y := rng.randf_range(float(hz) + 2.0, shore)
				dead_tree(Vector2(rng.randf_range(0.0, float(w)), y), (8.0 + (y - float(hz)) * 0.5) * s, c("tree", 1), 1)

	## A road out of the viewer's feet to the horizon, between the middle columns.
	func road() -> void:
		var vx := float(w) * 0.5
		var near_half := 46.0 * s
		for y in range(hz + 1, h):
			var t := scale_at(float(y))
			var half := 1.0 + near_half * t
			var x0 := int(roundf(vx - half))
			var x1 := int(roundf(vx + half))
			var col := c("road", 1).lerp(haze(), clampf(1.0 - t * 5.0, 0.0, 1.0) * 0.5)
			hspan(x0, x1, y, col)
			px(x0, y, c("road", 0))
			px(x1 - 1, y, c("road", 2))
			# Two ruts.
			if t > 0.15:
				px(int(roundf(vx - half * 0.45)), y, c("road", 0))
				px(int(roundf(vx + half * 0.45)), y, c("road", 0))

	# ------------------------------------------------------------ the ground's own dress

	## The thicket on the horizon: a wood, a cactus stand, a dead wood or a field of spires.
	func thicket() -> void:
		match biome:
			"plains":
				crowns(float(hz) + 1.0, 9.0 * s, 0.82, c("tree", 0), c("tree", 1), c("tree", 2))
			"sand":
				var x := 4.0
				while x < float(w):
					cactus(Vector2(x, float(hz) + rng.randf_range(0.0, 4.0) * s), rng.randf_range(9.0, 15.0) * s)
					x += rng.randf_range(14.0, 30.0) * s
			"marsh":
				var x := 2.0
				while x < float(w):
					dead_tree(Vector2(x, float(hz) + 1.0), rng.randf_range(12.0, 30.0) * s, c("tree", 1), 2 if rng.randf() < 0.4 else 1)
					x += rng.randf_range(6.0, 16.0) * s
			"lava":
				var x := 2.0
				while x < float(w):
					spire(Vector2(x, float(hz) + 1.0), rng.randf_range(10.0, 26.0) * s, rng.randf_range(3.0, 6.0) * s)
					x += rng.randf_range(8.0, 20.0) * s

	## A wood's crowns along a line: overlapping rounds, dark below, lit at the right.
	func crowns(base: float, r: float, cover: float, dark: Color, mid: Color, light: Color) -> void:
		var x := -r
		while x < float(w) + r:
			if rng.randf() < cover:
				var rr := r * rng.randf_range(0.7, 1.25)
				var cy := base - rr * rng.randf_range(0.6, 1.1)
				disc(x, cy, rr, rr * 0.92, dark, base)
				disc(x - rr * 0.12, cy - rr * 0.12, rr * 0.82, rr * 0.75, mid, base)
				disc(x + rr * 0.3, cy - rr * 0.35, rr * 0.38, rr * 0.32, light, base)
			x += r * rng.randf_range(0.9, 1.4)
		hspan(0, w, int(base), dark)

	func tree(foot: Vector2, tall: float) -> void:
		var r := tall * 0.38
		vspan(int(foot.x), int(foot.y - tall * 0.4), int(foot.y) + 1, c("trunk"))
		var cy := foot.y - tall * 0.62
		disc(foot.x, cy, r, r * 0.95, c("tree", 0))
		disc(foot.x - r * 0.12, cy - r * 0.12, r * 0.84, r * 0.78, c("tree", 1))
		disc(foot.x + r * 0.3, cy - r * 0.35, r * 0.4, r * 0.34, c("tree", 2))

	func cactus(foot: Vector2, tall: float) -> void:
		var body := c("tree", 1)
		var lit := c("tree", 2)
		var wd := maxf(2.0, tall * 0.2)
		var x := int(foot.x)
		for k in range(int(wd)):
			vspan(x + k, int(foot.y - tall), int(foot.y) + 1, lit if k == int(wd) - 1 else body)
		# The arms, all on the same side and at the same height: "cacti in rows all facing the
		# same way" (the Waste's fantasy in content).
		var arm_y := int(foot.y - tall * 0.55)
		hspan(x - int(wd * 1.2), x, arm_y, body)
		vspan(x - int(wd * 1.2), arm_y - int(tall * 0.3), arm_y + 1, body)
		hspan(x + int(wd), x + int(wd * 2.0), arm_y + int(tall * 0.12), body)
		vspan(x + int(wd * 2.0) - 1, arm_y - int(tall * 0.18), arm_y + int(tall * 0.12) + 1, lit)

	func spire(foot: Vector2, tall: float, half: float) -> void:
		var pts := PackedVector2Array([Vector2(foot.x - half, foot.y), Vector2(foot.x - half * 0.2, foot.y - tall), Vector2(foot.x + half * 0.35, foot.y - tall * 0.8), Vector2(foot.x + half, foot.y)])
		poly(pts, c("tree", 1))
		line(pts[1], pts[2], c("tree", 3))
		line(pts[2], pts[3], c("tree", 2))
		veil(int(foot.x - half), int(foot.x + half), int(foot.y) - 1, c("glow", 0) if pal.has("glow") else c("tree", 0), 0.5)

	## A range in the middle distance, in front of the far land: peaks lit at the right,
	## snow on the Meadow's, flat tops in the Waste, black crags on the Marsh and the Peak.
	func mountains() -> void:
		if biome == "sand":
			mesas(c("rock", 1), c("rock", 2), 61, 0.0)
			return
		var n := 4 + rng.randi() % 3
		var placed: Array = []
		for k in range(n):
			placed.append(Vector3((float(k) + rng.randf_range(0.1, 0.9)) * float(w) / float(n), rng.randf_range(34.0, 62.0) * s, rng.randf_range(30.0, 52.0) * s))
		placed.sort_custom(func(a: Vector3, b: Vector3) -> bool: return a.y < b.y)   # the lower in front
		for m in placed:
			peak(m.x, float(hz) - m.y, m.z)

	func peak(cx: float, top: float, half: float) -> void:
		var body := c("rock", 1)
		var shade := c("rock", 0)
		var lit := c("rock", 2)
		var foot := float(hz) + 1.0
		var lx := cx - half
		var rx := cx + half * rng.randf_range(0.8, 1.1)
		poly(PackedVector2Array([Vector2(lx, foot), Vector2(cx, top), Vector2(rx, foot)]), shade)
		# The lit face: from the summit down a jagged ridge line to the right foot.
		var ridge_pts := PackedVector2Array([Vector2(cx, top)])
		var steps := 6
		for k in range(1, steps + 1):
			var t := float(k) / float(steps)
			ridge_pts.append(Vector2(cx + (rx - cx) * 0.25 * t + rng.randf_range(-2.0, 2.0) * s, top + (foot - top) * t))
		ridge_pts.append(Vector2(rx, foot))
		poly(ridge_pts, body)
		poly(PackedVector2Array([Vector2(cx, top), ridge_pts[2], Vector2(rx - (rx - cx) * 0.25, foot), Vector2(rx, foot)]), lit.lerp(body, 0.45))
		if biome == "plains":
			var cap := (foot - top) * 0.32
			var sl := (cx - lx) / (foot - top)
			var sr := (rx - cx) / (foot - top)
			var y := top
			while y < top + cap:
				var t := y - top
				var jag := rng.randf_range(-1.0, 1.0) * s if y > top + cap * 0.6 else 0.0
				hspan(int(cx - t * sl), int(cx), int(y), c("snow", 0))
				hspan(int(cx), int(cx + t * sr + jag), int(y), c("snow", 1))
				y += 1.0
			# A ragged lower edge to the cap.
			for k in range(int(cap * (sl + sr))):
				var x := cx - cap * sl + float(k)
				if rng.randf() < 0.5:
					px(int(x), int(top + cap), c("snow", 0) if x < cx else c("snow", 1))
		elif biome == "lava":
			line(Vector2(cx, top + 2.0), Vector2(cx + rng.randf_range(-6.0, 6.0) * s, foot - 2.0), c("glow", 1))

	## Ruins on the horizon: a broken wall and a tower, roofs in the Meadow, columns in the
	## Waste, a churchyard in the Marsh, black stone in the Peak.
	func ruins() -> void:
		var y := float(hz) + 2.0 * s
		match biome:
			"plains":
				wall(float(w) * 0.12, float(w) * 0.38, y, 14.0 * s)
				tower(float(w) * 0.3, y, 9.0 * s, 34.0 * s)
				house(float(w) * 0.66, y, 13.0 * s)
				house(float(w) * 0.76, y + 1.0, 10.0 * s)
				wall(float(w) * 0.82, float(w) * 0.95, y, 9.0 * s)
			"sand":
				for k in range(6):
					var x := float(w) * (0.1 + 0.15 * float(k)) + rng.randf_range(-6.0, 6.0) * s
					column(x, y, 3.0 * s, rng.randf_range(10.0, 30.0) * s if k != 3 else 0.0)
				arch(float(w) * 0.55, y, 22.0 * s, 26.0 * s)
			"marsh":
				for k in range(16):
					var x := rng.randf_range(0.0, float(w))
					var yy := float(hz) + 2.0 + pow(rng.randf(), 1.5) * float(h - hz) * 0.35
					tomb(x, yy, (2.0 + scale_at(yy) * 9.0) * s)
				crypt(float(w) * 0.7, y, 16.0 * s)
				wall(float(w) * 0.12, float(w) * 0.3, y, 12.0 * s)
			"lava":
				for k in range(5):
					var x := float(w) * (0.12 + 0.18 * float(k)) + rng.randf_range(-8.0, 8.0) * s
					column(x, y, 4.0 * s, rng.randf_range(12.0, 34.0) * s)
					line(Vector2(x, y - 2.0), Vector2(x + 2.0, y - 8.0 * s), c("glow", 1))

	func wall(x0: float, x1: float, foot: float, tall: float) -> void:
		var x := x0
		while x < x1:
			var seg := rng.randf_range(4.0, 9.0) * s
			var top := foot - tall * rng.randf_range(0.45, 1.0)
			img.fill_rect(Rect2i(int(x), int(top), int(seg) + 1, int(foot - top) + 1), c("stone", 1))
			hspan(int(x), int(x + seg) + 1, int(top), c("stone", 2))
			x += seg
		var yy := foot - tall * 0.3
		while yy < foot:
			veil(int(x0), int(x1), int(yy), c("stone", 0), 0.5)
			yy += 4.0 * s

	func tower(cx: float, foot: float, half: float, tall: float) -> void:
		img.fill_rect(Rect2i(int(cx - half), int(foot - tall), int(half * 2.0), int(tall) + 1), c("stone", 1))
		vspan(int(cx + half) - 1, int(foot - tall), int(foot) + 1, c("stone", 2))
		vspan(int(cx - half), int(foot - tall), int(foot) + 1, c("stone", 0))
		# A broken crown: merlons, one gone.
		for k in range(3):
			if k != 1:
				img.fill_rect(Rect2i(int(cx - half + k * half * 0.8), int(foot - tall - 3.0 * s), int(half * 0.5), int(3.0 * s)), c("stone", 1))
		img.fill_rect(Rect2i(int(cx - 1.0 * s), int(foot - tall * 0.6), int(2.0 * s), int(4.0 * s)), c("stone", 0))

	func house(cx: float, foot: float, half: float) -> void:
		img.fill_rect(Rect2i(int(cx - half * 0.8), int(foot - half), int(half * 1.6), int(half) + 1), c("stone", 2))
		vspan(int(cx - half * 0.8), int(foot - half), int(foot) + 1, c("stone", 1))
		poly(PackedVector2Array([Vector2(cx - half, foot - half), Vector2(cx, foot - half * 1.7), Vector2(cx + half, foot - half)]), c("roof", 1))
		poly(PackedVector2Array([Vector2(cx - half, foot - half), Vector2(cx, foot - half * 1.7), Vector2(cx - half * 0.1, foot - half)]), c("roof", 0))
		img.fill_rect(Rect2i(int(cx + half * 0.2), int(foot - half * 0.6), int(maxf(1.0, half * 0.25)), int(half * 0.6)), c("stone", 0))

	func column(cx: float, foot: float, half: float, tall: float) -> void:
		if tall <= 0.0:
			# Fallen: a drum on its side.
			img.fill_rect(Rect2i(int(cx - half * 3.0), int(foot - half * 1.6), int(half * 6.0), int(half * 1.6)), c("stone", 1))
			hspan(int(cx - half * 3.0), int(cx + half * 3.0), int(foot - half * 1.6), c("stone", 2))
			return
		img.fill_rect(Rect2i(int(cx - half), int(foot - tall), int(half * 2.0), int(tall) + 1), c("stone", 1))
		vspan(int(cx + half) - 1, int(foot - tall), int(foot) + 1, c("stone", 2))
		vspan(int(cx - half), int(foot - tall), int(foot) + 1, c("stone", 0))
		hspan(int(cx - half * 1.6), int(cx + half * 1.6), int(foot - tall), c("stone", 2))
		hspan(int(cx - half * 1.6), int(cx + half * 1.6), int(foot), c("stone", 0))

	func arch(cx: float, foot: float, half: float, tall: float) -> void:
		var th := 4.0 * s
		img.fill_rect(Rect2i(int(cx - half), int(foot - tall), int(th), int(tall) + 1), c("stone", 1))
		img.fill_rect(Rect2i(int(cx + half - th), int(foot - tall), int(th), int(tall) + 1), c("stone", 1))
		img.fill_rect(Rect2i(int(cx - half), int(foot - tall - th), int(half * 2.0), int(th)), c("stone", 1))
		hspan(int(cx - half), int(cx + half), int(foot - tall - th), c("stone", 2))
		vspan(int(cx + half) - 1, int(foot - tall - th), int(foot) + 1, c("stone", 2))

	func tomb(cx: float, foot: float, half: float) -> void:
		var tall := half * 2.2
		img.fill_rect(Rect2i(int(cx - half), int(foot - tall + half), int(half * 2.0) + 1, int(tall - half) + 1), c("stone", 1))
		disc(cx, foot - tall + half, half, half, c("stone", 1))
		vspan(int(cx + half), int(foot - tall + half), int(foot) + 1, c("stone", 2))
		hspan(int(cx - half), int(cx + half) + 1, int(foot), c("tuft", 0))

	func crypt(cx: float, foot: float, half: float) -> void:
		img.fill_rect(Rect2i(int(cx - half), int(foot - half * 1.4), int(half * 2.0), int(half * 1.4) + 1), c("stone", 1))
		poly(PackedVector2Array([Vector2(cx - half * 1.15, foot - half * 1.4), Vector2(cx, foot - half * 2.3), Vector2(cx + half * 1.15, foot - half * 1.4)]), c("roof", 1))
		img.fill_rect(Rect2i(int(cx - half * 0.3), int(foot - half * 0.9), int(half * 0.6), int(half * 0.9) + 1), c("stone", 0))
		vspan(int(cx), int(foot - half * 3.0), int(foot - half * 2.2), c("stone", 2))
		hspan(int(cx - half * 0.3), int(cx + half * 0.3) + 1, int(foot - half * 2.7), c("stone", 2))

	## The open ground's few landmarks on the horizon: a copse, a cactus, a dead tree, a rock.
	func horizon_dressing() -> void:
		if terrain == BattleMap.Terrain.ROUGH or terrain == BattleMap.Terrain.MOUNTAIN or terrain == BattleMap.Terrain.RUINS:
			return
		var groups := 2 + rng.randi() % 2
		for g in range(groups):
			var gx := (float(g) + rng.randf_range(0.15, 0.85)) * float(w) / float(groups)
			var y := float(hz) + rng.randf_range(1.0, 4.0) * s
			match biome:
				"plains":
					for k in range(1 + rng.randi() % 3):
						tree(Vector2(gx + float(k) * 9.0 * s, y + float(k % 2)), rng.randf_range(12.0, 18.0) * s)
				"sand":
					cactus(Vector2(gx, y), rng.randf_range(8.0, 13.0) * s)
				"marsh":
					dead_tree(Vector2(gx, y), rng.randf_range(14.0, 24.0) * s, c("tree", 1), 2)
				"lava":
					spire(Vector2(gx, y), rng.randf_range(8.0, 16.0) * s, 4.0 * s)

	## The floor's small change: tufts and flowers, pebbles and bones, reeds and puddles,
	## embers in the cracks; smaller and closer together toward the horizon.
	func floor_details() -> void:
		var count := int(110.0 * float(h - hz) / (240.0 * s))   # as many to the glass's area at any width
		var water_edge := float(hz) + 40.0 * s if terrain == BattleMap.Terrain.WATER else float(hz)
		for k in range(count):
			var y := float(hz) + 3.0 + pow(rng.randf(), 0.8) * float(h - hz - 4)
			if y < water_edge:
				continue
			var x := rng.randf_range(0.0, float(w))
			var t := scale_at(y)
			var size_px := maxf(1.0, roundf((1.0 + t * 3.0) * s))
			match biome:
				"plains":
					if rng.randf() < 0.82:
						tuft(x, y, size_px)
					else:
						px(int(x), int(y), c("speck", rng.randi() % 3))
				"sand":
					if rng.randf() < 0.94:
						pebble(x, y, size_px)
					else:
						bone(x, y, size_px)
				"marsh":
					var roll := rng.randf()
					if roll < 0.8:
						tuft(x, y, size_px + 1.0)
					elif roll < 0.95:
						var r := (2.0 + t * 12.0) * s
						disc(x, y, r, r * 0.25, c("water", 1))
						hspan(int(x - r * 0.4), int(x + r * 0.2), int(y), c("water", 2))
					else:
						var r := (2.0 + t * 10.0) * s
						disc(x, y, r, r * 0.25, c("bog", 0))
						hspan(int(x - r * 0.4), int(x + r * 0.1), int(y), c("bog", 1))
				"lava":
					if rng.randf() < 0.85:
						pebble(x, y, size_px)
					else:
						crack(x, y, (3.0 + t * 16.0) * s)
		if terrain == BattleMap.Terrain.ROUGH or terrain == BattleMap.Terrain.MOUNTAIN:
			for k in range(12):
				var y := float(hz) + 4.0 + pow(rng.randf(), 0.9) * float(h - hz - 6)
				if y < water_edge:
					continue
				boulder(rng.randf_range(0.0, float(w)), y, (2.0 + scale_at(y) * 9.0) * s)

	func tuft(x: float, y: float, size_px: float) -> void:
		var dark := c("tuft", 0)
		var light := c("tuft", 1)
		var n := int(size_px)
		vspan(int(x), int(y - n), int(y) + 1, dark)
		vspan(int(x) + 2, int(y - n + 1), int(y) + 1, dark)
		px(int(x) + 1, int(y - n - 1), light)

	func pebble(x: float, y: float, size_px: float) -> void:
		var n := int(size_px)
		img.fill_rect(Rect2i(int(x), int(y), n + 1, maxi(1, n / 2 + 1)), c("tuft", 0))
		hspan(int(x) + 1, int(x) + n + 1, int(y) - 1, c("tuft", 1))

	func bone(x: float, y: float, size_px: float) -> void:
		var n := int(size_px * 1.6)
		hspan(int(x), int(x) + n + 1, int(y), c("speck", 0))
		px(int(x), int(y) - 1, c("speck", 0))
		px(int(x) + n, int(y) - 1, c("speck", 0))

	func crack(x: float, y: float, len_px: float) -> void:
		var p := Vector2(x, y)
		var steps := int(len_px)
		for k in range(steps):
			p += Vector2(1.0, rng.randf_range(-0.6, 0.6))
			px(int(p.x), int(p.y), c("speck", 0) if k % 5 != 2 else c("speck", 1))
			px(int(p.x), int(p.y) + 1, c("speck", 2))

	func boulder(x: float, y: float, r: float) -> void:
		disc(x, y - r * 0.5, r, r * 0.7, c("rock", 0), y)
		disc(x + r * 0.15, y - r * 0.65, r * 0.75, r * 0.5, c("rock", 1), y)
		disc(x + r * 0.35, y - r * 0.85, r * 0.35, r * 0.25, c("rock", 2), y)

	## Ground mist over the marsh's horizon, thinning upward.
	func mist() -> void:
		var top := float(hz) - 16.0 * s
		var bottom := float(hz) + 10.0 * s
		var col := c("cloud", 2).lerp(c("cloud", 1), 0.3)
		for y in range(int(top), int(bottom)):
			var t := (float(y) - top) / (bottom - top)
			var f := 0.5 * (1.0 - absf(t - 0.55) * 1.8)
			veil(0, w, y, col, roundf(f * 4.0) / 4.0)
