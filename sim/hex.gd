class_name Hex
extends RefCounted

## Hex math on axial coordinates (q, r), pointy-top orientation.
## Cube coordinates are implied: x = q, z = r, y = -q - r.
## Rectangular maps use odd-r offset coordinates (col, row) at the edges only;
## everything in the simulation speaks axial.

const DIRECTIONS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1),
]


static func neighbors(h: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for d in DIRECTIONS:
		out.append(h + d)
	return out


static func distance(a: Vector2i, b: Vector2i) -> int:
	var dq := a.x - b.x
	var dr := a.y - b.y
	return (absi(dq) + absi(dr) + absi(dq + dr)) / 2


static func are_adjacent(a: Vector2i, b: Vector2i) -> bool:
	return distance(a, b) == 1


## Pixel centre of a hex. `size` is the circumradius (centre to corner).
static func to_pixel(h: Vector2i, size: float) -> Vector2:
	var x := size * (sqrt(3.0) * h.x + sqrt(3.0) / 2.0 * h.y)
	var y := size * (1.5 * h.y)
	return Vector2(x, y)


static func from_pixel(p: Vector2, size: float) -> Vector2i:
	var q := (sqrt(3.0) / 3.0 * p.x - 1.0 / 3.0 * p.y) / size
	var r := (2.0 / 3.0 * p.y) / size
	return round_axial(q, r)


static func round_axial(q: float, r: float) -> Vector2i:
	var x := q
	var z := r
	var y := -x - z
	var rx := roundf(x)
	var ry := roundf(y)
	var rz := roundf(z)
	var dx := absf(rx - x)
	var dy := absf(ry - y)
	var dz := absf(rz - z)
	if dx > dy and dx > dz:
		rx = -ry - rz
	elif dy > dz:
		ry = -rx - rz
	else:
		rz = -rx - ry
	return Vector2i(int(rx), int(rz))


## Corner points of a pointy-top hex, for drawing.
static func corners(center: Vector2, size: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(6):
		var angle := deg_to_rad(60.0 * i - 30.0)
		pts.append(center + Vector2(size * cos(angle), size * sin(angle)))
	return pts


## odd-r offset -> axial. Rows shove odd rows right by half a hex.
static func offset_to_axial(col: int, row: int) -> Vector2i:
	var q := col - (row - (row & 1)) / 2
	return Vector2i(q, row)


static func axial_to_offset(h: Vector2i) -> Vector2i:
	var col := h.x + (h.y - (h.y & 1)) / 2
	return Vector2i(col, h.y)
