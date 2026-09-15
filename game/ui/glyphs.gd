class_name Glyphs
extends RefCounted

## Geometric placeholder glyphs, drawn with lines so they scale and recolour freely.
## Ids match Face kind, reach, and keyword names, plus "heat" and "star".


static func draw(ci: CanvasItem, id: String, c: Vector2, size: float, color: Color, width: float = 2.0) -> void:
	var s := size / 2.0
	match id:
		"line":
			ci.draw_arc(c, s * 0.62, 0.0, TAU, 28, color, width)
			ci.draw_line(c + Vector2(-s, 0), c + Vector2(s, 0), color, width)
			ci.draw_line(c + Vector2(0, -s), c + Vector2(0, s), color, width)
		"indirect":
			ci.draw_arc(c + Vector2(0, s * 0.5), s * 0.95, PI, TAU, 20, color, width)
			ci.draw_circle(c + Vector2(s * 0.95, s * 0.5), width * 1.6, color)
			ci.draw_line(c + Vector2(-s * 0.95, s * 0.5), c + Vector2(-s * 0.95, s * 0.95), color, width)
		"shield":
			var pts := PackedVector2Array([
				c + Vector2(-s, -s * 0.85), c + Vector2(s, -s * 0.85), c + Vector2(s, s * 0.1),
				c + Vector2(0, s), c + Vector2(-s, s * 0.1), c + Vector2(-s, -s * 0.85),
			])
			ci.draw_polyline(pts, color, width)
		"vent":
			for i in range(3):
				var y := -s * 0.6 + i * s * 0.6
				ci.draw_polyline(PackedVector2Array([
					c + Vector2(-s * 0.8, y + s * 0.35), c + Vector2(0, y - s * 0.15), c + Vector2(s * 0.8, y + s * 0.35),
				]), color, width)
		"blank":
			ci.draw_line(c + Vector2(-s, -s), c + Vector2(s, s), color, width)
			ci.draw_line(c + Vector2(-s, s), c + Vector2(s, -s), color, width)
		"cleave":
			for i in range(3):
				var x := -s * 0.7 + i * s * 0.7
				ci.draw_line(c + Vector2(x, -s), c + Vector2(x, s), color, width)
		"pierce":
			ci.draw_line(c + Vector2(-s, 0), c + Vector2(s, 0), color, width)
			ci.draw_line(c + Vector2(s * 0.3, -s * 0.6), c + Vector2(s, 0), color, width)
			ci.draw_line(c + Vector2(s * 0.3, s * 0.6), c + Vector2(s, 0), color, width)
			ci.draw_line(c + Vector2(-s * 0.2, -s), c + Vector2(-s * 0.2, s), color, width)
		"burn":
			ci.draw_polyline(PackedVector2Array([
				c + Vector2(0, -s), c + Vector2(s * 0.7, s * 0.1), c + Vector2(s * 0.3, s),
				c + Vector2(-s * 0.3, s), c + Vector2(-s * 0.7, s * 0.1), c + Vector2(0, -s),
			]), color, width)
		"suppress":
			ci.draw_arc(c, s * 0.9, 0.0, TAU, 28, color, width)
			ci.draw_line(c + Vector2(-s * 0.65, s * 0.65), c + Vector2(s * 0.65, -s * 0.65), color, width)
		"overcharge":
			ci.draw_polyline(PackedVector2Array([
				c + Vector2(s * 0.3, -s), c + Vector2(-s * 0.5, s * 0.1), c + Vector2(s * 0.1, s * 0.1), c + Vector2(-s * 0.3, s),
			]), color, width)
		"execute":
			ci.draw_polyline(PackedVector2Array([
				c + Vector2(-s, -s), c + Vector2(s, -s), c + Vector2(0, s * 0.9), c + Vector2(-s, -s),
			]), color, width)
			ci.draw_circle(c + Vector2(0, -s * 0.35), width * 1.2, color)
		"chain":
			ci.draw_arc(c + Vector2(-s * 0.45, 0), s * 0.5, 0.0, TAU, 20, color, width)
			ci.draw_arc(c + Vector2(s * 0.45, 0), s * 0.5, 0.0, TAU, 20, color, width)
		"lock":
			ci.draw_rect(Rect2(c + Vector2(-s * 0.8, -s * 0.1), Vector2(s * 1.6, s * 1.1)), color, false, width)
			ci.draw_arc(c + Vector2(0, -s * 0.15), s * 0.5, PI, TAU, 16, color, width)
		"heat":
			ci.draw_line(c + Vector2(0, -s), c + Vector2(0, s * 0.3), color, width)
			ci.draw_circle(c + Vector2(0, s * 0.55), s * 0.45, color)
		"star":
			var pts := PackedVector2Array()
			for i in range(11):
				var r := s if i % 2 == 0 else s * 0.45
				var a := -PI / 2.0 + i * PI / 5.0
				pts.append(c + Vector2(cos(a), sin(a)) * r)
			ci.draw_polyline(pts, color, width)
		"eye":
			# A hexagonal eye with a pupil: "show every target line".
			ci.draw_polyline(PackedVector2Array([
				c + Vector2(-s, 0), c + Vector2(-s * 0.55, -s * 0.7), c + Vector2(s * 0.55, -s * 0.7),
				c + Vector2(s, 0), c + Vector2(s * 0.55, s * 0.7), c + Vector2(-s * 0.55, s * 0.7), c + Vector2(-s, 0),
			]), color, width)
			ci.draw_arc(c, s * 0.3, 0.0, TAU, 16, color, width)
		"reroll":
			# A three-quarter circular arrow, clockwise from the top; the head points the way
			# the arc travels.
			ci.draw_arc(c, s * 0.8, -PI * 0.5, PI * 1.1, 20, color, width)
			var tip := c + Vector2(cos(PI * 1.1), sin(PI * 1.1)) * s * 0.8
			ci.draw_line(tip, tip + Vector2(s * 0.05, s * 0.5), color, width)
			ci.draw_line(tip, tip + Vector2(-s * 0.5, s * 0.05), color, width)
		# ---- the fantasy set: enemy intents, drawn in the register of the foes, not the HUD
		"sword":
			ci.draw_line(c + Vector2(-s * 0.7, s * 0.7), c + Vector2(s * 0.75, -s * 0.75), color, width)
			ci.draw_line(c + Vector2(s * 0.45, -s * 0.9), c + Vector2(s * 0.9, -s * 0.45), color, width)
			ci.draw_line(c + Vector2(-s * 0.75, s * 0.1), c + Vector2(-s * 0.1, s * 0.75), color, width)
			ci.draw_line(c + Vector2(-s * 0.9, s * 0.6), c + Vector2(-s * 0.6, s * 0.9), color, width)
		"heart":
			ci.draw_arc(c + Vector2(-s * 0.42, -s * 0.3), s * 0.45, PI * 0.8, PI * 2.0, 14, color, width)
			ci.draw_arc(c + Vector2(s * 0.42, -s * 0.3), s * 0.45, PI, PI * 2.2, 14, color, width)
			ci.draw_polyline(PackedVector2Array([
				c + Vector2(-s * 0.85, -s * 0.05), c + Vector2(0, s * 0.95), c + Vector2(s * 0.85, -s * 0.05),
			]), color, width)
		"kite":
			var pts := PackedVector2Array([
				c + Vector2(0, -s), c + Vector2(s * 0.8, -s * 0.55), c + Vector2(s * 0.6, s * 0.3),
				c + Vector2(0, s), c + Vector2(-s * 0.6, s * 0.3), c + Vector2(-s * 0.8, -s * 0.55), c + Vector2(0, -s),
			])
			ci.draw_polyline(pts, color, width)
			ci.draw_line(c + Vector2(0, -s * 0.6), c + Vector2(0, s * 0.6), color, width * 0.7)
		"buff":
			ci.draw_line(c + Vector2(0, s), c + Vector2(0, -s * 0.8), color, width)
			ci.draw_polyline(PackedVector2Array([c + Vector2(-s * 0.6, -s * 0.2), c + Vector2(0, -s * 0.85), c + Vector2(s * 0.6, -s * 0.2)]), color, width)
			ci.draw_line(c + Vector2(-s * 0.6, s * 0.5), c + Vector2(s * 0.6, s * 0.5), color, width * 0.7)
		"debuff":
			ci.draw_line(c + Vector2(0, -s), c + Vector2(0, s * 0.8), color, width)
			ci.draw_polyline(PackedVector2Array([c + Vector2(-s * 0.6, s * 0.2), c + Vector2(0, s * 0.85), c + Vector2(s * 0.6, s * 0.2)]), color, width)
			ci.draw_line(c + Vector2(-s * 0.6, -s * 0.5), c + Vector2(s * 0.6, -s * 0.5), color, width * 0.7)
		# ---- warnings and statuses
		"shieldbreak":
			var pts := PackedVector2Array([
				c + Vector2(-s, -s * 0.85), c + Vector2(s, -s * 0.85), c + Vector2(s, s * 0.1),
				c + Vector2(0, s), c + Vector2(-s, s * 0.1), c + Vector2(-s, -s * 0.85),
			])
			ci.draw_polyline(pts, color, width)
			ci.draw_polyline(PackedVector2Array([
				c + Vector2(s * 0.1, -s * 0.85), c + Vector2(-s * 0.25, -s * 0.2), c + Vector2(s * 0.2, s * 0.1), c + Vector2(-s * 0.1, s * 0.95),
			]), color, width)
		"crack":
			ci.draw_rect(Rect2(c - Vector2(s * 0.8, s * 0.8), Vector2(s * 1.6, s * 1.6)), color, false, width)
			ci.draw_polyline(PackedVector2Array([
				c + Vector2(-s * 0.8, -s * 0.5), c + Vector2(-s * 0.2, -s * 0.1), c + Vector2(-s * 0.4, s * 0.3), c + Vector2(s * 0.3, s * 0.1), c + Vector2(s * 0.8, s * 0.6),
			]), color, width)
		"skull":
			ci.draw_arc(c + Vector2(0, -s * 0.2), s * 0.75, PI * 0.85, PI * 2.15, 20, color, width)
			ci.draw_line(c + Vector2(-s * 0.7, s * 0.05), c + Vector2(-s * 0.5, s * 0.55), color, width)
			ci.draw_line(c + Vector2(s * 0.7, s * 0.05), c + Vector2(s * 0.5, s * 0.55), color, width)
			ci.draw_line(c + Vector2(-s * 0.5, s * 0.55), c + Vector2(s * 0.5, s * 0.55), color, width)
			ci.draw_circle(c + Vector2(-s * 0.3, -s * 0.2), width * 1.3, color)
			ci.draw_circle(c + Vector2(s * 0.3, -s * 0.2), width * 1.3, color)
			for i in range(3):
				var x := -s * 0.25 + i * s * 0.25
				ci.draw_line(c + Vector2(x, s * 0.55), c + Vector2(x, s * 0.9), color, width * 0.8)
		"exposed":
			# A reticle with its top open: nothing in front.
			ci.draw_arc(c, s * 0.8, PI * 0.15, PI * 1.85 + PI, 24, color, width)
			ci.draw_line(c + Vector2(-s * 0.35, 0), c + Vector2(s * 0.35, 0), color, width)
			ci.draw_line(c + Vector2(0, s * 0.35), c + Vector2(0, s * 0.8), color, width)
		_:
			ci.draw_rect(Rect2(c - Vector2(s, s), Vector2(size, size)), color, false, width)


## The fantasy-register icon for an enemy action kind.
static func intent_for(kind: String) -> String:
	match kind:
		"defend":
			return "kite"
		"heal":
			return "heart"
		"buff":
			return "buff"
		"debuff":
			return "debuff"
		_:
			return "sword"


static func primary_for(face: Face) -> String:
	match face.kind:
		Face.Kind.SHIELD:
			return "shield"
		Face.Kind.VENT:
			return "vent"
		Face.Kind.BLANK:
			return "blank"
		_:
			return "indirect" if face.reach == Face.Reach.INDIRECT else "line"
