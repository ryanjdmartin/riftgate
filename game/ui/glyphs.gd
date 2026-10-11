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
		"warning":
			# A hazard triangle with its bar and dot: the hexes a pack can strike the gate from.
			var tri := PackedVector2Array([c + Vector2(0, -s), c + Vector2(s * 0.95, s * 0.75), c + Vector2(-s * 0.95, s * 0.75), c + Vector2(0, -s)])
			ci.draw_polyline(tri, color, width)
			ci.draw_line(c + Vector2(0, -s * 0.35), c + Vector2(0, s * 0.2), color, width)
			ci.draw_circle(c + Vector2(0, s * 0.45), width * 0.6, color)
		"cleave":
			for i in range(3):
				var x := -s * 0.7 + i * s * 0.7
				ci.draw_line(c + Vector2(x, -s), c + Vector2(x, s), color, width)
		"penetrate":
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
		"hopper":
			# A funnel and its spout: what the claw digs out, waiting to be fired.
			ci.draw_polyline(PackedVector2Array([
				c + Vector2(-s, -s * 0.8), c + Vector2(s, -s * 0.8), c + Vector2(s * 0.22, s * 0.15),
				c + Vector2(s * 0.22, s), c + Vector2(-s * 0.22, s), c + Vector2(-s * 0.22, s * 0.15), c + Vector2(-s, -s * 0.8),
			]), color, width)
			ci.draw_line(c + Vector2(-s * 0.55, -s * 0.35), c + Vector2(s * 0.55, -s * 0.35), color, width * 0.7)
		"chain":
			ci.draw_arc(c + Vector2(-s * 0.45, 0), s * 0.5, 0.0, TAU, 20, color, width)
			ci.draw_arc(c + Vector2(s * 0.45, 0), s * 0.5, 0.0, TAU, 20, color, width)
		"cleanse":
			# A drop with a ring: what washes a status off.
			ci.draw_arc(c, s * 0.95, 0.0, TAU, 28, color, width * 0.8)
			ci.draw_polyline(PackedVector2Array([
				c + Vector2(0, -s * 0.6), c + Vector2(s * 0.4, s * 0.1), c + Vector2(0, s * 0.55), c + Vector2(-s * 0.4, s * 0.1), c + Vector2(0, -s * 0.6),
			]), color, width)
		"paradox":
			# A loop closing on itself: two rings touching, the past self and the present.
			ci.draw_arc(c + Vector2(-s * 0.45, 0.0), s * 0.47, 0.0, TAU, 20, color, width)
			ci.draw_arc(c + Vector2(s * 0.45, 0.0), s * 0.47, 0.0, TAU, 20, color, width)
		"numbed":
			# A suppress ring with a bar across it: the stun it shrugs off.
			ci.draw_arc(c, s * 0.9, 0.0, TAU, 28, color, width)
			ci.draw_line(c + Vector2(-s * 0.55, 0.0), c + Vector2(s * 0.55, 0.0), color, width * 1.4)
		"self":
			# One machine, ringed: this component reaches only its own.
			ci.draw_arc(c, s * 0.9, 0.0, TAU, 24, color, width * 0.8)
			ci.draw_rect(Rect2(c + Vector2(-s * 0.35, -s * 0.35), Vector2(s * 0.7, s * 0.7)), color, true)
		"ally":
			# Two machines side by side, the near one hollow: it reaches the other.
			ci.draw_rect(Rect2(c + Vector2(-s * 0.95, -s * 0.35), Vector2(s * 0.7, s * 0.7)), color, false, width * 0.8)
			ci.draw_rect(Rect2(c + Vector2(s * 0.25, -s * 0.35), Vector2(s * 0.7, s * 0.7)), color, true)
			ci.draw_line(c + Vector2(-s * 0.25, 0.0), c + Vector2(s * 0.25, 0.0), color, width * 0.8)
		"overshield":
			# A shield's arch with a second arch standing above its crown: more than the maximum.
			ci.draw_arc(c + Vector2(0, s * 0.3), s * 0.7, PI, TAU, 16, color, width)
			ci.draw_line(c + Vector2(-s * 0.7, s * 0.3), c + Vector2(s * 0.7, s * 0.3), color, width)
			ci.draw_arc(c + Vector2(0, -s * 0.15), s * 0.95, PI * 1.15, PI * 1.85, 12, color, width * 0.8)
		"spillover":
			# An arrow driven down through a bar: what carries past the kill into the rank behind.
			ci.draw_line(c + Vector2(-s * 0.8, -s * 0.15), c + Vector2(s * 0.8, -s * 0.15), color, width)
			ci.draw_line(c + Vector2(0, -s), c + Vector2(0, s * 0.9), color, width)
			ci.draw_polyline(PackedVector2Array([c + Vector2(-s * 0.5, s * 0.35), c + Vector2(0, s * 0.9), c + Vector2(s * 0.5, s * 0.35)]), color, width)
		"lure":
			# A siren: a bell on a base with two rays, what a monster comes for.
			ci.draw_arc(c + Vector2(0, s * 0.25), s * 0.6, PI, TAU, 16, color, width)
			ci.draw_line(c + Vector2(-s * 0.85, s * 0.3), c + Vector2(s * 0.85, s * 0.3), color, width)
			ci.draw_line(c + Vector2(-s * 0.55, -s * 0.5), c + Vector2(-s * 0.85, -s * 0.85), color, width * 0.8)
			ci.draw_line(c + Vector2(s * 0.55, -s * 0.5), c + Vector2(s * 0.85, -s * 0.85), color, width * 0.8)
			ci.draw_line(c + Vector2(0, -s * 0.5), c + Vector2(0, -s * 0.95), color, width * 0.8)
		"disrupt":
			# An arrow knocked off its line: a shaft that kinks and comes out another way.
			ci.draw_polyline(PackedVector2Array([
				c + Vector2(-s * 0.95, s * 0.3), c + Vector2(-s * 0.15, s * 0.3), c + Vector2(0.1 * s, -s * 0.35), c + Vector2(s * 0.85, -s * 0.35),
			]), color, width)
			ci.draw_polyline(PackedVector2Array([c + Vector2(s * 0.45, -s * 0.75), c + Vector2(s * 0.9, -s * 0.35), c + Vector2(s * 0.45, s * 0.05)]), color, width)
			ci.draw_line(c + Vector2(-s * 0.3, -s * 0.2), c + Vector2(0.25 * s, s * 0.6), color, width * 0.7)
		"rapid":
			# Two chevrons: spent, and the die rolls again.
			for i in range(2):
				var x := -s * 0.55 + i * s * 0.6
				ci.draw_polyline(PackedVector2Array([c + Vector2(x, -s * 0.7), c + Vector2(x + s * 0.5, 0), c + Vector2(x, s * 0.7)]), color, width)
		"shocked", "shock":
			# A bolt in a ring: the charge a foe carries until a blow spends it.
			ci.draw_arc(c, s * 0.95, 0.0, TAU, 28, color, width * 0.8)
			ci.draw_polyline(PackedVector2Array([
				c + Vector2(s * 0.2, -s * 0.65), c + Vector2(-s * 0.3, s * 0.05), c + Vector2(s * 0.05, s * 0.05), c + Vector2(-s * 0.2, s * 0.65),
			]), color, width)
		"devour":
			# Open jaws, teeth down: what takes something from a kill.
			ci.draw_arc(c + Vector2(0, -s * 0.15), s * 0.85, PI * 1.05, PI * 1.95, 16, color, width)
			for i in range(3):
				var x := -s * 0.5 + i * s * 0.5
				ci.draw_line(c + Vector2(x, -s * 0.1), c + Vector2(x, s * 0.55), color, width * 0.9)
			ci.draw_line(c + Vector2(-s * 0.85, -s * 0.1), c + Vector2(s * 0.85, -s * 0.1), color, width)
		"volatile":
			# A burst with a spark at its heart: the component that costs its owner to use.
			for i in range(8):
				var a := i * TAU / 8.0
				var r0 := s * (0.55 if i % 2 == 0 else 0.4)
				ci.draw_line(c + Vector2(cos(a), sin(a)) * r0, c + Vector2(cos(a), sin(a)) * s, color, width * 0.9)
			ci.draw_circle(c, s * 0.22, color)
		"corrupt":
			# A jagged crack through the entry: the rot the Chorus leaves in a component.
			ci.draw_polyline(PackedVector2Array([
				c + Vector2(-s * 0.2, -s), c + Vector2(s * 0.3, -s * 0.3), c + Vector2(-s * 0.3, s * 0.1), c + Vector2(s * 0.2, s),
			]), color, width)
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
		"prev", "next":
			# Skip back or on: a filled triangle against a bar, the transport's own mark.
			var d := 1.0 if id == "next" else -1.0
			ci.draw_colored_polygon(PackedVector2Array([
				c + Vector2(-s * 0.75 * d, -s * 0.8), c + Vector2(s * 0.35 * d, 0), c + Vector2(-s * 0.75 * d, s * 0.8),
			]), color)
			ci.draw_line(c + Vector2(s * 0.6 * d, -s * 0.8), c + Vector2(s * 0.6 * d, s * 0.8), color, width)
		"reroll":
			# A three-quarter circular arrow, clockwise from the top, with a filled head
			# pointing along the arc.
			var r := s * 0.72
			var a0 := -PI * 0.45
			var a1 := PI * 1.0
			ci.draw_arc(c, r, a0, a1, 24, color, width * 1.15)
			var p := c + Vector2(cos(a1), sin(a1)) * r
			var t := Vector2(-sin(a1), cos(a1))
			var n := Vector2(cos(a1), sin(a1))
			ci.draw_colored_polygon(PackedVector2Array([p + t * s * 0.5, p + n * s * 0.32, p - n * s * 0.32]), color)
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


## The colour a chip for this glyph takes. Most sit in the HUD colour; effects that mean
## damage or danger take their own, so a burn reads as fire at a glance and related effects
## can share a shape in different colours.
static func colour_for(id: String) -> Color:
	match id:
		"burn", "overcharge", "heat", "devour", "shocked", "shock":
			return Palette.HEAT
		"skull", "shieldbreak", "corrupt", "volatile":
			return Palette.ENEMY
		"star":
			return Palette.SELECT
		"suppress", "chain", "cleanse", "numbed", "lure", "disrupt":
			return Palette.SHIELD
		_:
			return Palette.HUD


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
		Face.Kind.BUFF:
			return "buff"
		_:
			if face.reach == Face.Reach.INDIRECT:
				return "indirect"
			return "line"   # direct: the crosshair glyph, whatever its tags
