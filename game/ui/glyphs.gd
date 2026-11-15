class_name Glyphs
extends RefCounted

## Geometric placeholder glyphs, drawn with lines so they scale and recolour freely.
## Ids match Face kind, reach, and keyword names, plus "heat" and "star".


static func draw(ci: CanvasItem, id: String, c: Vector2, size: float, color: Color, width: float = 2.0) -> void:
	var s := size / 2.0
	match id:
		"sap", "overcharge":
			# A blow's number, down and up, one blade and an arrow at its lower right. Sapped (Ryan,
			# 11 November): the blade, smaller up and to the left, and the arrow down: blows a point
			# lower a stack. Empowered (Ryan, 12 November: "Yes use the up sword for empowered") is
			# its pair, the arrow turned up: blows a point higher a stack. It wore a bare bolt until
			# then, Shock's bolt without the ring; the bolt is Shock's alone now.
			draw(ci, "sword", c + Vector2(-s * 0.22, -s * 0.2), size * 0.78, color, width)
			var ax := c + Vector2(s * 0.55, s * 0.05)
			if id == "sap":
				ci.draw_line(ax + Vector2(0, -s * 0.45), ax + Vector2(0, s * 0.85), color, width)
				ci.draw_polyline(PackedVector2Array([ax + Vector2(-s * 0.36, s * 0.45), ax + Vector2(0, s * 0.88), ax + Vector2(s * 0.36, s * 0.45)]), color, width)
			else:
				ci.draw_line(ax + Vector2(0, s * 0.85), ax + Vector2(0, -s * 0.4), color, width)
				ci.draw_polyline(PackedVector2Array([ax + Vector2(-s * 0.36, 0.0), ax + Vector2(0, -s * 0.43), ax + Vector2(s * 0.36, 0.0)]), color, width)
		"pin_flak", "pin_ablate":
			# A pin (Ryan, 11 November: "Can we combine the lock and the flak/burn for these
			# glyphs?"): the status it holds, drawn a little smaller up and to the left, with the
			# lock at its lower right.
			draw(ci, {"pin_flak": "flak", "pin_ablate": "ablate"}[id], c + Vector2(-s * 0.2, -s * 0.16), size * 0.8, color, width)
			draw(ci, "lock", c + Vector2(s * 0.5, s * 0.48), size * 0.52, color, width)
		"pin_empower":
			# Empowered's pin (the Soul Siphon's hold, 12 November): the pins' lock at the lower
			# right, and Empowered's two parts set around it rather than shrunk over it, where the
			# lock sat on the arrow and left a caret: a smaller blade up and to the left, and the
			# arrow up standing tall on the lock, so the arrow reads at a chip's size on the desk too.
			draw(ci, "sword", c + Vector2(-s * 0.44, -s * 0.3), size * 0.56, color, width)
			var px := c + Vector2(s * 0.5, 0.0)
			ci.draw_line(px + Vector2(0, s * 0.2), px + Vector2(0, -s * 0.9), color, width)
			ci.draw_polyline(PackedVector2Array([px + Vector2(-s * 0.3, -s * 0.52), px + Vector2(0, -s * 0.93), px + Vector2(s * 0.3, -s * 0.52)]), color, width)
			draw(ci, "lock", c + Vector2(s * 0.5, s * 0.5), size * 0.52, color, width)
		"soul":
			# A small ghost (the Ammit's Souls, 12 November; a first cut for Ryan's eye, a wisp with
			# a tail having read as a letter at a chip's size): a domed head, straight sides, a hem
			# in three points and two eyes, what it takes from a foe that falls.
			var crown := c + Vector2(0.0, -s * 0.22)
			ci.draw_arc(crown, s * 0.72, PI, TAU, 14, color, width)
			ci.draw_polyline(PackedVector2Array([
				crown + Vector2(s * 0.72, 0.0), c + Vector2(s * 0.72, s * 0.95), c + Vector2(s * 0.36, s * 0.58), c + Vector2(0.0, s * 0.95),
				c + Vector2(-s * 0.36, s * 0.58), c + Vector2(-s * 0.72, s * 0.95), crown + Vector2(-s * 0.72, 0.0),
			]), color, width)
			ci.draw_circle(c + Vector2(-s * 0.27, -s * 0.2), maxf(1.0, s * 0.13), color)
			ci.draw_circle(c + Vector2(s * 0.27, -s * 0.2), maxf(1.0, s * 0.13), color)
		# ---- the die's targeting marks (Ryan, 2 November): one width, under the main mark
		"aim_direct", "aim_indirect":
			# Whom a weapon or a debuff reaches (Ryan, 3 November: "I think we had it right with
			# straight versus curved before, just needed to be cleaned up. Maybe a straight line that
			# breaks up into smaller and smaller dashes towards the end for direct, and then just
			# gently curve that for indirect, so it doesn't get much bigger than the 3-hex view"):
			# a line of fire, a long solid run breaking into ever smaller dashes, thinning as it
			# goes; straight for Direct, a gentle lob for Indirect, as wide as the three hexes.
			_fire_line(ci, c, size, color, width, id == "aim_indirect")
		"aim_every_foe":
			# Every Foe (a targeting mode since 4 November): the enemy's formation whole, both ranks
			# of its four columns lit, the far rank smaller and narrower, as the field is seen from
			# behind the machines (Ryan, 4 November: "I actually like the 8 squares with the 4 rear
			# ones smaller"), the ranks close ("we can gain a bit by narrowing the gap between the two
			# rows"), held in square brackets at its sides ("Can we get side-brackets on All Foes?
			# Round or square, not sure"; then "Square brackets are good"), the whole the marks' one
			# width.
			var fw := size * 0.68
			var fc := fw * 0.19
			var fp := (fw - fc) / 3.0
			var bc := fc * 0.72
			var bp := (fw * 0.74 - bc) / 3.0
			for k in range(4):
				var back := c + Vector2((k - 1.5) * bp, -s * 0.17)
				ci.draw_rect(Rect2(back - Vector2(bc, bc) * 0.5, Vector2(bc, bc)), color, true)
				var front := c + Vector2((k - 1.5) * fp, s * 0.17)
				ci.draw_rect(Rect2(front - Vector2(fc, fc) * 0.5, Vector2(fc, fc)), color, true)
			var reach := s * 0.38
			for side in [-1.0, 1.0]:
				var x: float = side * (s - width * 0.5)
				var serif: float = -side * s * 0.2
				ci.draw_polyline(PackedVector2Array([c + Vector2(x + serif, -reach), c + Vector2(x, -reach), c + Vector2(x, reach), c + Vector2(x + serif, reach)]), color, width)
		"aim_every_ally", "aim_every_other_ally":
			# Every Ally and Every Other Ally (targeting modes since 4 November): the three hexes, the
			# middle its own machine, lit for the whole team and dark for every other ally (Ryan: "the
			# difference is whether the center one is lit or not, its two modes"), under one low arch
			# carried out past the outer cells' edges and touching none of them ("ii works for that,
			# I'd like to see it with the arch widened to carry to the edges of the hexes, but not
			# actually touching them"); the cells a little smaller than a single target's, so the arch
			# keeps the marks' one width.
			var k34 := size / 34.0
			var r := 4.8 * k34
			var pitch := sqrt(3.0) * r
			var hc := c + Vector2(0.0, 2.3 * k34)   # the whole centred on the slot, inside its band
			for k in range(3):
				var h := hc + Vector2((k - 1) * pitch, 0.0)
				if k != 1 or id == "aim_every_ally":
					ci.draw_colored_polygon(_hex_pts(h, r * 0.72), color)
				Hud.stroke_poly(ci, _hex_pts(h, r), color, maxf(1.0, width * 0.7))
			var rx := pitch + sqrt(3.0) * 0.5 * r + 2.6 * k34
			var base := hc + Vector2(0.0, -r * 0.5 - 1.6 * k34)
			var arch := PackedVector2Array()
			for i in range(25):
				var a := PI + PI * i / 24.0
				arch.append(base + Vector2(cos(a) * rx, sin(a) * (r * 0.5 + 2.6 * k34)))
			ci.draw_polyline(arch, color, width)
		# ---- the die's main marks (Ryan, 3 November): each holds what the entry delivers
		"weapon":
			# A weapon (Ryan, 3 November: the faces did not "read weapon"): a sight, its ring broken
			# where four heavy ticks cross it, in a little and out to the edge ("bigger sight lines,
			# or have the sight lines extend inwards"; then "I like your second option the most.
			# broken ring, inner broken circle ... with an additional outer circle"), its blow
			# inside. The side ticks reach in less, clear of the widest number. At the die's size an
			# inner broken circle, four short arcs on the diagonals clear of the number, and a thin
			# whole circle round the ring.
			if size < INNER_FROM:
				# Drawn small (a readout's head, a passive box, a chip: under 30 wide), plain: a whole
				# ring and the four ticks crossing it, the breaks and linings a blur at that size
				# (Ryan, 4 November: the next chamber "looks a little muddy for some icons").
				var small := s * 0.6
				ci.draw_arc(c, small, 0.0, TAU, 20, color, width)
				for d in [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]:
					ci.draw_line(c + d * small * 0.45, c + d * s, color, width)
				return
			var ring := s * SIGHT_RING
			var seg := maxi(8, int(size * 0.3))
			for k in range(4):
				var a0 := k * PI * 0.5 + SIGHT_GAP
				ci.draw_arc(c, ring, a0, a0 + PI * 0.5 - 2.0 * SIGHT_GAP, seg, color, width)
			for d in [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]:
				var inside := s * (0.12 if absf(d.x) > 0.5 else 0.2)
				ci.draw_line(c + d * (ring - inside), c + d * s, color, width * 1.25)
			if size >= INNER_FROM:
				var faint := Color(color, color.a * (INNER_ALPHA + 0.15))
				for k in range(4):
					var am := PI * 0.25 + k * PI * 0.5
					ci.draw_arc(c, ring - s * 0.13, am - 0.23, am + 0.23, 8, faint, 1.2)
				ci.draw_arc(c, ring + s * 0.12, 0.0, TAU, maxi(48, int(size * 1.1)), Color(color, color.a * 0.55), 1.2)
		"equipment":
			# Equipment, one mark for a buff and a debuff (Ryan, 2 November: "merging buff/debuff
			# into one 'equipment' face type"): gear, a cog of eight square teeth (3 November: the
			# module before it did not read), what it grants or lays inside it; at the die's size a
			# lining, a ring inside its teeth.
			Hud.stroke_poly(ci, _cog(c, s, s * GEAR_ROOT), color, width)
			if size >= INNER_FROM:
				ci.draw_arc(c, s * GEAR_ROOT * 0.84, 0.0, TAU, 40, Color(color, color.a * INNER_ALPHA), 1.0)
		"shield_vent":
			# A shield and a vent in one entry (Ryan, 3 November: "If the vent was simplified to just
			# wavy lines, it could be combined with shield as a combo face"; "Shield-vent should have
			# the vent lines over the whole thing, not just half"; "The shield-vent combo is
			# squished. Too tight"): the shield, its top lowered to make room, the vent's steam
			# rising off its whole top; its numbers shield | cool, each in its colour, a size down.
			var pts := PackedVector2Array([c + Vector2(-s, -s * 0.5), c + Vector2(s, -s * 0.5), c + Vector2(s, s * 0.3), c + Vector2(0, s), c + Vector2(-s, s * 0.3)])
			Hud.stroke_poly(ci, pts, color, width)
			_vapour(ci, c + Vector2(0.0, -s * 0.82), s * 0.5, s * 0.25, color, width * 0.9, size >= INNER_FROM)
			if size >= INNER_FROM:
				Hud.stroke_poly(ci, _inset(pts, c + Vector2(0.0, s * 0.18), 0.85), Color(color, color.a * INNER_ALPHA), 1.0)
		"hull":
			# The hull (2 November, a cost's mark): a machine's body, shoulders over its torso.
			Hud.stroke_poly(ci, PackedVector2Array([c + Vector2(-s * 0.95, -s * 0.45), c + Vector2(-s * 0.35, -s * 0.85), c + Vector2(s * 0.35, -s * 0.85), c + Vector2(s * 0.95, -s * 0.45), c + Vector2(s * 0.55, s * 0.9), c + Vector2(-s * 0.55, s * 0.9)]), color, width)
			ci.draw_line(c + Vector2(-s * 0.3, -s * 0.1), c + Vector2(s * 0.3, -s * 0.1), color, width)
		"aim_self", "aim_ally", "aim_any":
			# Whom a piece spent on machines reaches (Ryan, 2 November: "just 3 connected hexes:
			# center filled for self-only, left/right filled for ally only, all filled for self or
			# ally"): three hex cells sharing their edges, as the map's are, the middle its own
			# machine; a cell it may be spent on lit, filled inside its edge. As wide as the size given.
			var r := size / (3.0 * sqrt(3.0))
			for k in range(3):
				var hc := c + Vector2((k - 1) * sqrt(3.0) * r, 0.0)
				var hex := PackedVector2Array()
				for i in range(6):
					var a := PI / 6.0 + i * PI / 3.0
					hex.append(hc + Vector2(cos(a), sin(a)) * r)
				if id == "aim_any" or (id == "aim_self") == (k == 1):
					var lit := PackedVector2Array()
					for q in hex:
						lit.append(hc + (q - hc) * 0.72)
					ci.draw_colored_polygon(lit, color)
				Hud.stroke_poly(ci, hex, color, maxf(1.0, width * 0.7))
		"shield":
			var pts := PackedVector2Array([
				c + Vector2(-s, -s * 0.85), c + Vector2(s, -s * 0.85), c + Vector2(s, s * 0.1),
				c + Vector2(0, s), c + Vector2(-s, s * 0.1), c + Vector2(-s, -s * 0.85),
			])
			ci.draw_polyline(pts, color, width)
			if size >= INNER_FROM:
				# At the die's size, its lining (Ryan, 3 November: "I liked the previous iterations
				# inner lining ... extra little flairs").
				Hud.stroke_poly(ci, PackedVector2Array([c + Vector2(-s * 0.8, -s * 0.68), c + Vector2(s * 0.8, -s * 0.68), c + Vector2(s * 0.8, s * 0.04), c + Vector2(0, s * 0.77), c + Vector2(-s * 0.8, s * 0.04)]), Color(color, color.a * INNER_ALPHA), 1.0)
		"seal", "unseal":
			# The Polar Bear's shell (Ryan, 2 November: "armadillo needs indication when a die face
			# will transform it"): a seam, and an arrow either side driving shut onto it (seal) or
			# thrown open off it (unseal), so the two read apart by structure, never by hue.
			ci.draw_line(c + Vector2(0.0, -s), c + Vector2(0.0, s), color, width * 1.3)
			for side in [-1.0, 1.0]:
				var near := Vector2(side * s * 0.2, 0.0)
				var far := Vector2(side * s, 0.0)
				var tip := near if id == "seal" else far
				var tail := far if id == "seal" else near
				var back := (tail - tip).normalized() * s * 0.45
				ci.draw_line(c + tail, c + tip, color, width)
				ci.draw_colored_polygon(PackedVector2Array([c + tip + back + Vector2(0.0, -s * 0.45), c + tip, c + tip + back + Vector2(0.0, s * 0.45)]), color)   # a solid head, so it holds at a chip's size
		"barrier", "ward":
			# The block as a buff (21 October): the shield's outline, and inside it a wall for a
			# Barrier (a solid bar: the next blow stops there) or a ring struck through for a
			# Ward (no rider gets in). One colour, parted by what sits inside.
			var pts := PackedVector2Array([
				c + Vector2(-s, -s * 0.85), c + Vector2(s, -s * 0.85), c + Vector2(s, s * 0.1),
				c + Vector2(0, s), c + Vector2(-s, s * 0.1), c + Vector2(-s, -s * 0.85),
			])
			ci.draw_polyline(pts, color, width)
			if id == "barrier":
				ci.draw_rect(Rect2(c + Vector2(-s * 0.62, -s * 0.38), Vector2(s * 1.24, s * 0.42)), color, true)
			else:
				var o := c + Vector2(0, -s * 0.12)
				ci.draw_arc(o, s * 0.42, 0.0, TAU, 18, color, width * 0.85)
				ci.draw_line(o + Vector2(-s * 0.3, s * 0.3), o + Vector2(s * 0.3, -s * 0.3), color, width * 0.85)
		"silence":
			# Silenced (21 October; keywords alone, 28 October): a voice's three arcs struck
			# through, its keywords muted through its next round.
			for k in range(3):
				ci.draw_arc(c + Vector2(-s * 0.45, 0), s * (0.35 + 0.3 * k), -PI * 0.3, PI * 0.3, 10, color, width)
			ci.draw_line(c + Vector2(-s * 0.9, s * 0.9), c + Vector2(s * 0.9, -s * 0.9), color, width * 1.2)
		"spin":
			# The drum spun up (Spun Up, the Cassowary's, 21 October): three-quarters of a ring
			# with an arrowhead where it runs on, and the cylinder's hub at its centre.
			ci.draw_arc(c, s * 0.78, -PI * 0.35, PI * 1.25, 22, color, width)
			var head := c + Vector2(cos(-PI * 0.35), sin(-PI * 0.35)) * s * 0.78
			ci.draw_colored_polygon(PackedVector2Array([head + Vector2(-s * 0.42, -s * 0.12), head + Vector2(s * 0.12, -s * 0.38), head + Vector2(s * 0.1, s * 0.22)]), color)
			ci.draw_circle(c, s * 0.2, color)
		"vent":
			# A vent (Ryan, 3 November: "simplified to just wavy lines"; then "Plain vent looks weird
			# that close to the number, maybe it needs a chamfered box back"): a plate cut as the
			# die's, its number inside, three waves of steam rising off its top; at the die's size a
			# lining inside the plate.
			# Ryan, the next pass: "can they have secondary thin lines as well? And move the bottom
			# chamfer to the top, so its got corners on the bottom and chamfers on the top (a
			# little smaller than now)": its plate cut on both top corners, square below, and at
			# the die's size two thin waves among the three.
			var plate := Rect2(c + Vector2(-s * 0.9, -s * 0.28), Vector2(s * 1.8, s * 1.12))
			Hud.stroke_poly(ci, _top_cut(plate, s * 0.17), color, width)
			_vapour(ci, c + Vector2(0.0, -s * 0.62), s * 0.47, s * 0.28, color, width * 0.9, size >= INNER_FROM)
			if size >= INNER_FROM:
				Hud.stroke_poly(ci, _top_cut(plate.grow(-s * 0.12), s * 0.13), Color(color, color.a * INNER_ALPHA), 1.0)
		"blank":
			ci.draw_line(c + Vector2(-s, -s), c + Vector2(s, s), color, width)
			ci.draw_line(c + Vector2(-s, s), c + Vector2(s, -s), color, width)
		"swap":
			# Swap (the Dingo's Combat Translocator, 30 October): two arrows passing, one each way,
			# two places trading what stands in them.
			ci.draw_line(c + Vector2(-s * 0.85, -s * 0.38), c + Vector2(s * 0.85, -s * 0.38), color, width)
			ci.draw_line(c + Vector2(s * 0.85, -s * 0.38), c + Vector2(s * 0.42, -s * 0.8), color, width)
			ci.draw_line(c + Vector2(s * 0.85, s * 0.38), c + Vector2(-s * 0.85, s * 0.38), color, width)
			ci.draw_line(c + Vector2(-s * 0.85, s * 0.38), c + Vector2(-s * 0.42, s * 0.8), color, width)
		"steal":
			# Steal (a foe's, 30 October): the die entry's box with an arrow pulling out of it, the
			# piece taken to be swung back.
			ci.draw_rect(Rect2(c + Vector2(-s * 0.9, -s * 0.2), Vector2(s * 1.1, s * 1.1)), color, false, width)
			ci.draw_line(c + Vector2(-s * 0.35, s * 0.35), c + Vector2(s * 0.85, -s * 0.85), color, width)
			ci.draw_line(c + Vector2(s * 0.85, -s * 0.85), c + Vector2(s * 0.25, -s * 0.85), color, width)
			ci.draw_line(c + Vector2(s * 0.85, -s * 0.85), c + Vector2(s * 0.85, -s * 0.25), color, width)
		"all":
			# A blow at every machine (30 October): one bar, three blows falling from it.
			ci.draw_line(c + Vector2(-s * 0.9, -s * 0.75), c + Vector2(s * 0.9, -s * 0.75), color, width)
			for k in range(3):
				var x := -s * 0.6 + k * s * 0.6
				ci.draw_line(c + Vector2(x, -s * 0.45), c + Vector2(x, s * 0.55), color, width)
				ci.draw_colored_polygon(PackedVector2Array([c + Vector2(x - s * 0.22, s * 0.45), c + Vector2(x + s * 0.22, s * 0.45), c + Vector2(x, s * 0.9)]), color)
		"parts":
			# A foe in parts (30 October): the core's ring and the two parts standing by it.
			ci.draw_arc(c + Vector2(0, s * 0.15), s * 0.5, 0.0, TAU, 20, color, width)
			ci.draw_circle(c + Vector2(-s * 0.72, -s * 0.62), s * 0.22, color)
			ci.draw_circle(c + Vector2(s * 0.72, -s * 0.62), s * 0.22, color)
		"cooldown":
			# A cooldown (30 October): a clock face, its hands at twelve and three, the rounds an
			# entry stays dark.
			ci.draw_arc(c, s * 0.88, 0.0, TAU, 24, color, width)
			ci.draw_line(c, c + Vector2(0, -s * 0.58), color, width)
			ci.draw_line(c, c + Vector2(s * 0.46, 0), color, width)
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
		"juggernaut":
			# The Wild Boar's Juggernaut Drive waiting (its next weapon ignores armour): the blow
			# through the plate. The plate is two bars with the gap an arrow drives down through,
			# its structure apart from Penetrate's sideways arrow and the shield's crack. Breach's
			# mark until the keyword was cut (15 November), and this state's alone since.
			ci.draw_line(c + Vector2(-s, s * 0.05), c + Vector2(-s * 0.32, s * 0.05), color, width)
			ci.draw_line(c + Vector2(s * 0.32, s * 0.05), c + Vector2(s, s * 0.05), color, width)
			ci.draw_line(c + Vector2(0, -s), c + Vector2(0, s), color, width)
			ci.draw_line(c + Vector2(-s * 0.45, s * 0.5), c + Vector2(0, s), color, width)
			ci.draw_line(c + Vector2(s * 0.45, s * 0.5), c + Vector2(0, s), color, width)
		"splash":
			# Splash (28 October): the plus round the target, Spread's row and Penetrate's column at
			# one number. A solid core with four arms standing off it, a burst, so it reads apart
			# from Spread's three bars, Penetrate's arrow and the crosshair's ringed cross.
			ci.draw_rect(Rect2(c - Vector2(s * 0.28, s * 0.28), Vector2(s * 0.56, s * 0.56)), color, true)
			for d in [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
				ci.draw_line(c + d * s * 0.5, c + d * s, color, width)
		"penetrate":
			ci.draw_line(c + Vector2(-s, 0), c + Vector2(s, 0), color, width)
			ci.draw_line(c + Vector2(s * 0.3, -s * 0.6), c + Vector2(s, 0), color, width)
			ci.draw_line(c + Vector2(s * 0.3, s * 0.6), c + Vector2(s, 0), color, width)
			ci.draw_line(c + Vector2(-s * 0.2, -s), c + Vector2(-s * 0.2, s), color, width)
		"ablate":
			ci.draw_polyline(PackedVector2Array([
				c + Vector2(0, -s), c + Vector2(s * 0.7, s * 0.1), c + Vector2(s * 0.3, s),
				c + Vector2(-s * 0.3, s), c + Vector2(-s * 0.7, s * 0.1), c + Vector2(0, -s),
			]), color, width)
		"primed":
			# Primed (28 October, the same chip on both sides): Ablate's hollow flame with its core
			# lit, a blow primed to lay it, so on a foe it never reads as the team's Ablating,
			# which keeps the bare hollow flame.
			ci.draw_polyline(PackedVector2Array([
				c + Vector2(0, -s), c + Vector2(s * 0.7, s * 0.1), c + Vector2(s * 0.3, s),
				c + Vector2(-s * 0.3, s), c + Vector2(-s * 0.7, s * 0.1), c + Vector2(0, -s),
			]), color, width)
			ci.draw_colored_polygon(PackedVector2Array([
				c + Vector2(0, -s * 0.2), c + Vector2(s * 0.32, s * 0.4), c + Vector2(0, s * 0.72), c + Vector2(-s * 0.32, s * 0.4),
			]), color)
		"regenerating":
			# Regenerating (28 October): the heart's outline with a plus inside it, HP regrown at
			# each action, so it never reads as Undying's star.
			draw(ci, "heart", c, size, color, width)
			ci.draw_line(c + Vector2(-s * 0.3, -s * 0.02), c + Vector2(s * 0.3, -s * 0.02), color, width)
			ci.draw_line(c + Vector2(0, -s * 0.32), c + Vector2(0, s * 0.28), color, width)
		"dispel", "purge":
			# Purge (the player's keyword, 28 October; a placeholder, judged running): the buff's
			# arrow struck through, every buff the foe carries unmade.
			draw(ci, "buff", c, size * 0.8, color, width)
			ci.draw_line(c + Vector2(-s * 0.85, s * 0.85), c + Vector2(s * 0.85, -s * 0.85), color, width * 1.2)
		"suppress":
			ci.draw_arc(c, s * 0.9, 0.0, TAU, 28, color, width)
			ci.draw_line(c + Vector2(-s * 0.65, s * 0.65), c + Vector2(s * 0.65, -s * 0.65), color, width)
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
		"web":
			# A web: three threads through the centre and two rings of silk, drawn as hexagons
			# (the funnel-web's Web Bomb and the Webbed it leaves, 18 October).
			for i in range(3):
				var a := PI / 6.0 + i * PI / 3.0
				ci.draw_line(c + Vector2(cos(a), sin(a)) * s, c - Vector2(cos(a), sin(a)) * s, color, width * 0.8)
			for r in [s * 0.42, s * 0.86]:
				var ring := PackedVector2Array()
				for i in range(7):
					var a := PI / 6.0 + i * PI / 3.0
					ring.append(c + Vector2(cos(a), sin(a)) * r)
				ci.draw_polyline(ring, color, width * 0.9)
		"vitriol":
			# Acid: a drop, point up, over two pits it has eaten into the plate beneath (the
			# funnel-web's Vitriol, 18 October). The hollow flame stays Ablate's.
			ci.draw_polyline(PackedVector2Array([
				c + Vector2(0, -s), c + Vector2(s * 0.55, -s * 0.05), c + Vector2(s * 0.45, s * 0.35),
				c + Vector2(0, s * 0.55), c + Vector2(-s * 0.45, s * 0.35), c + Vector2(-s * 0.55, -s * 0.05), c + Vector2(0, -s),
			]), color, width)
			ci.draw_line(c + Vector2(-s * 0.95, s * 0.9), c + Vector2(-s * 0.35, s * 0.9), color, width * 0.9)
			ci.draw_line(c + Vector2(s * 0.35, s * 0.9), c + Vector2(s * 0.95, s * 0.9), color, width * 0.9)
		"cryo":
			# A snowflake: six arms, each with a fork near its tip (Cryo, the Polar Bear's mark,
			# 20 October; its glyph from 21 October, the keyword and the foe's chip alike). The web
			# is rings on three threads; this is forks on six arms.
			for i in range(6):
				var a := -PI / 2.0 + i * PI / 3.0
				var dir := Vector2(cos(a), sin(a))
				var side := Vector2(-dir.y, dir.x)
				ci.draw_line(c, c + dir * s, color, width)
				var fork := c + dir * s * 0.6
				ci.draw_line(fork, fork + (dir + side) * s * 0.28, color, width * 0.8)
				ci.draw_line(fork, fork + (dir - side) * s * 0.28, color, width * 0.8)
		"blast":
			# A blast (drawn for the Whip Scorpion's vent blast, 22 October; a foe's self-destruct
			# now): Indirect's arc, lobbed over and landing in a burst where Indirect lands on a
			# dot, so it reads as a blow landing.
			ci.draw_arc(c + Vector2(-s * 0.15, s * 0.55), s * 0.8, PI, TAU, 18, color, width)
			var hit := c + Vector2(s * 0.65, s * 0.55)
			for i in range(6):
				var a := -PI * 0.5 + i * TAU / 6.0
				var dir := Vector2(cos(a), sin(a))
				ci.draw_line(hit + dir * s * 0.16, hit + dir * s * 0.45, color, width)
		"flak":
			# An airburst: a small shell ring and the dashes of shrapnel thrown off it (Flak,
			# 21 October). Ablating's flame is a closed shape; this one is open, so the two part
			# by structure as well as colour.
			ci.draw_arc(c, s * 0.24, 0.0, TAU, 14, color, width)
			for i in range(8):
				var a := PI / 8.0 + i * PI / 4.0
				var dir := Vector2(cos(a), sin(a))
				ci.draw_line(c + dir * s * 0.5, c + dir * s, color, width)
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
		"ricochet":
			# A shot glancing off a plate and away: the line in, the bounce, the arrow out (a
			# placeholder for Ryan's eye, 11 November).
			ci.draw_line(c + Vector2(-s * 0.9, s * 0.65), c + Vector2(s * 0.9, s * 0.65), color, width * 0.7)
			ci.draw_polyline(PackedVector2Array([c + Vector2(-s * 0.9, -s * 0.5), c + Vector2(-s * 0.1, s * 0.65), c + Vector2(s * 0.8, -s * 0.7)]), color, width)
			ci.draw_polyline(PackedVector2Array([c + Vector2(s * 0.25, -s * 0.7), c + Vector2(s * 0.8, -s * 0.7), c + Vector2(s * 0.75, -s * 0.15)]), color, width)
		"rapid":
			# Two chevrons: spent, and the die rolls again.
			for i in range(2):
				var x := -s * 0.55 + i * s * 0.6
				ci.draw_polyline(PackedVector2Array([c + Vector2(x, -s * 0.7), c + Vector2(x + s * 0.5, 0), c + Vector2(x, s * 0.7)]), color, width)
		"instant":
			# One chevron with a loop curling back over it onto its own tail (Instant, Ryan, 12
			# November: "reroll after use, can land on itself"): Rapid's chevron, its roll coming
			# back to it. Apart from Rapid's two chevrons by its structure, from the reroll's arc
			# by the chevron inside and the loop's way round.
			var tip := c + Vector2(s * 0.32, s * 0.12)
			ci.draw_polyline(PackedVector2Array([c + Vector2(-s * 0.2, -s * 0.4), tip, c + Vector2(-s * 0.2, s * 0.64)]), color, width * 1.15)
			var r := s * 0.82
			var a0 := -PI * 0.1
			var a1 := -PI * 1.12
			var lc := c + Vector2(0, s * 0.04)
			ci.draw_arc(lc, r, a0, a1, 22, color, width * 1.15)
			var end := lc + Vector2(cos(a1), sin(a1)) * r
			var along := Vector2(sin(a1), -cos(a1))   # the way the loop runs on at its end, the angle falling
			var side := Vector2(-along.y, along.x)
			ci.draw_colored_polygon(PackedVector2Array([end + along * s * 0.62, end + side * s * 0.38, end - side * s * 0.38]), color)
		"shocked", "shock":
			# A bolt in a ring: the charge a foe carries until a blow spends it.
			ci.draw_arc(c, s * 0.95, 0.0, TAU, 28, color, width * 0.8)
			ci.draw_polyline(PackedVector2Array([
				c + Vector2(s * 0.2, -s * 0.65), c + Vector2(-s * 0.3, s * 0.05), c + Vector2(s * 0.05, s * 0.05), c + Vector2(-s * 0.2, s * 0.65),
			]), color, width)
		"corrupt":
			# A jagged crack through the entry: the rot a foe's corrupt leaves in a component.
			ci.draw_polyline(PackedVector2Array([
				c + Vector2(-s * 0.2, -s), c + Vector2(s * 0.3, -s * 0.3), c + Vector2(-s * 0.3, s * 0.1), c + Vector2(s * 0.2, s),
			]), color, width)
		"lock":
			ci.draw_rect(Rect2(c + Vector2(-s * 0.8, -s * 0.1), Vector2(s * 1.6, s * 1.1)), color, false, width)
			ci.draw_arc(c + Vector2(0, -s * 0.15), s * 0.5, PI, TAU, 16, color, width)
		"heat":
			ci.draw_line(c + Vector2(0, -s), c + Vector2(0, s * 0.3), color, width)
			ci.draw_circle(c + Vector2(0, s * 0.55), s * 0.45, color)
		"scorch":
			# Heat rising off a barrel: Scorched, every weapon and debuff running hotter (13 October).
			ci.draw_line(c + Vector2(-s, s * 0.75), c + Vector2(s, s * 0.75), color, width)
			for i in range(3):
				var x := -s * 0.55 + i * s * 0.55
				ci.draw_polyline(PackedVector2Array([
					c + Vector2(x, s * 0.4), c + Vector2(x + s * 0.2, s * 0.05), c + Vector2(x - s * 0.12, -s * 0.3), c + Vector2(x + s * 0.14, -s * 0.65), c + Vector2(x, -s),
				]), color, width * 0.9)
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
		"controls_middle", "controls_bottom":
			# The skirmish's controls switch (29 October): a phone's frame, the controls a solid band
			# where they sit, a chevron toward where a press moves them.
			var w := s * 0.62
			ci.draw_polyline(PackedVector2Array([
				c + Vector2(-w, -s), c + Vector2(w, -s), c + Vector2(w, s), c + Vector2(-w, s), c + Vector2(-w, -s),
			]), color, width)
			var low := id == "controls_bottom"
			var band_y := s * 0.52 if low else -s * 0.16
			ci.draw_rect(Rect2(c + Vector2(-w + width * 1.5, band_y), Vector2((w - width * 1.5) * 2.0, s * 0.34)), color)
			var tip := -s * 0.62 if low else s * 0.78
			var d := 1.0 if low else -1.0   # the chevron's arms open away from its tip
			ci.draw_polyline(PackedVector2Array([
				c + Vector2(-s * 0.3, tip + s * 0.26 * d), c + Vector2(0.0, tip), c + Vector2(s * 0.3, tip + s * 0.26 * d),
			]), color, width)
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
		"rises":
			# A kill a foe gets back up from (Ryan, 7 November: the preview's chip in the death
			# chip's place): an arrow rising off the ground it fell to, its head open.
			ci.draw_line(c + Vector2(-s * 0.8, s * 0.8), c + Vector2(s * 0.8, s * 0.8), color, width)
			ci.draw_line(c + Vector2(0, s * 0.8), c + Vector2(0, -s * 0.85), color, width)
			ci.draw_polyline(PackedVector2Array([c + Vector2(-s * 0.55, -s * 0.3), c + Vector2(0, -s * 0.9), c + Vector2(s * 0.55, -s * 0.3)]), color, width)
		"splits":
			# A kill that splits a foe in two (the Gel's, Ryan, 7 November: the preview's chip in the
			# death chip's place): one body above, forking into two below.
			ci.draw_arc(c + Vector2(0, -s * 0.55), s * 0.32, 0.0, TAU, 16, color, width)
			ci.draw_line(c + Vector2(0, -s * 0.23), c + Vector2(0, s * 0.05), color, width)
			ci.draw_line(c + Vector2(0, s * 0.05), c + Vector2(-s * 0.5, s * 0.4), color, width)
			ci.draw_line(c + Vector2(0, s * 0.05), c + Vector2(s * 0.5, s * 0.4), color, width)
			ci.draw_arc(c + Vector2(-s * 0.6, s * 0.65), s * 0.26, 0.0, TAU, 14, color, width)
			ci.draw_arc(c + Vector2(s * 0.6, s * 0.65), s * 0.26, 0.0, TAU, 14, color, width)
		"mine":
			# A sea mine (the Lammergeier's, 21 October): a ring and four horned spikes, a shot
			# waiting in a slot. Unlike Volatile's burst it has a body.
			ci.draw_arc(c, s * 0.5, 0.0, TAU, 20, color, width)
			for d in [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]:
				var tip: Vector2 = c + d * s * 0.95
				ci.draw_line(c + d * s * 0.5, tip, color, width)
				var side := Vector2(-d.y, d.x) * s * 0.22
				ci.draw_line(tip - side, tip + side, color, width)
			ci.draw_circle(c, s * 0.16, color)
		"ammo":
			# Ammo (the Musk Ox's magazine, 21 October): three shells standing, a reload's mark
			# and the price slot's.
			for i in range(3):
				var x := -s * 0.6 + i * s * 0.6
				ci.draw_rect(Rect2(c + Vector2(x - s * 0.17, -s * 0.25), Vector2(s * 0.34, s * 1.05)), color, false, width)
				ci.draw_arc(c + Vector2(x, -s * 0.25), s * 0.17, PI, TAU, 8, color, width)
		"swallowed":
			# Swallowed (a foe's swallow, 30 October): a maw closing on the machine's mark, its teeth
			# meeting, out of the fight until its rounds run out or its swallower falls.
			ci.draw_arc(c, s * 0.82, PI * 0.15, PI * 0.85, 10, color, width)
			ci.draw_arc(c, s * 0.82, PI * 1.15, PI * 1.85, 10, color, width)
			for i in range(4):
				var x := -s * 0.48 + i * s * 0.32
				ci.draw_line(c + Vector2(x, -s * 0.5), c + Vector2(x + s * 0.16, -s * 0.18), color, width)
				ci.draw_line(c + Vector2(x, s * 0.5), c + Vector2(x + s * 0.16, s * 0.18), color, width)
			ci.draw_circle(c, s * 0.14, color)
		"phased":
			# Phased (the Swallowtail's Mooring Screens, 21 October): the machine's outline gone to
			# dashes, out of the fight until the round's end.
			for i in range(8):
				var a0 := i * TAU / 8.0
				ci.draw_arc(c, s * 0.8, a0, a0 + TAU / 16.0, 4, color, width)
			ci.draw_circle(c, s * 0.18, color)
		"syrinx_drone", "drone":
			# The Syrinx Drone (21 October): a small body under two arcs of a call, the voice that
			# copies the killing shot.
			ci.draw_circle(c + Vector2(0, s * 0.45), s * 0.28, color)
			ci.draw_arc(c + Vector2(0, s * 0.45), s * 0.62, PI * 1.2, PI * 1.8, 12, color, width)
			ci.draw_arc(c + Vector2(0, s * 0.45), s * 1.0, PI * 1.25, PI * 1.75, 14, color, width)
		"exposed", "expose", "exposure":
			# A reticle with its top open: nothing in front (Exposed's chip and
			# the Expose keyword's).
			ci.draw_arc(c, s * 0.8, PI * 0.15, PI * 1.85 + PI, 24, color, width)
			ci.draw_line(c + Vector2(-s * 0.35, 0), c + Vector2(s * 0.35, 0), color, width)
			ci.draw_line(c + Vector2(0, s * 0.35), c + Vector2(0, s * 0.8), color, width)
		_:
			ci.draw_rect(Rect2(c - Vector2(s, s), Vector2(size, size)), color, false, width)


## The colour a mark for this id takes: a term's, by its group in the one table (Terms), so the
## die's keyword marks, the chips and the text agree, never the HUD colour (Ryan, 30 October:
## "Stay away from HUD colour"); a mark that is no term keeps its own: heat's for what heats, the
## enemy's violet for a foe's doing, the red-red for a death, white for a written-out rule, and
## the HUD colour for the chrome's own marks (a lock).
static func colour_for(id: String) -> Color:
	if Terms.has(id):
		return Terms.colour(id)
	match id:
		"seal", "unseal":
			return Terms.colour("sealed")   # the Polar Bear's shell, the Sealed status's colour
		"exposed":
			return Terms.colour("exposure")
		"overcharge", "heat", "scorch", "spin", "mine":
			return Palette.HEAT
		"shieldbreak", "silence":
			return Palette.ENEMY
		"skull":
			return Palette.LOSS
		"star":
			return Palette.SELECT
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


## An entry's main mark (Ryan, 3 November: the number inside it, whom it reaches under it): a
## weapon's sight, equipment's gear (a buff and a debuff alike), a shield, a vent's steam, the
## shield and the vent together for an entry that does both (the Wake Diffuser, the Sutler's
## Hoist), a reload's shells (the Musk Ox's Quick Reload cools nothing: its mark is the one its
## ammo wears in a cost, no mark of its own, Ryan, 2 November), or the blank.
static func primary_for(face: Face) -> String:
	match face.kind:
		Face.Kind.SHIELD:
			return "shield_vent" if face.vents > 0 else "shield"
		Face.Kind.VENT:
			if face.power <= 0 and face.reloads_ammo > 0:
				return "ammo"
			return "shield_vent" if face.shields > 0 else "vent"
		Face.Kind.BLANK:
			return "blank"
		Face.Kind.BUFF:
			return "equipment"
		_:
			return "equipment" if face.is_debuff() else "weapon"   # aimed at a foe: whether it deals damage says which


## The weapon's sight: its ring's radius as a share of the mark's half-width, the ticks crossing
## it out to the edge. Equipment's gear: the root of its teeth as a share of their tips' reach.
## A main mark this wide or wider wears its lining, a thin line inside it at INNER_ALPHA (Ryan, 3
## November: "I liked the previous iterations inner lining, that's the kind of thing that moves
## it out of amateurish, extra little flairs"). A vent's number sits VENT_NUMBER of its
## half-width under its centre, in its plate's middle.
const SIGHT_RING := 0.82
const SIGHT_GAP := 0.19     # radians either side of a tick where the sight's ring breaks for it
const GEAR_ROOT := 0.76
const INNER_FROM := 30.0
const INNER_ALPHA := 0.4
const VENT_NUMBER := 0.28


## A closed outline `pts` drawn in toward `ctr` by `k`, a main mark's lining.
static func _inset(pts: PackedVector2Array, ctr: Vector2, k: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		out.append(ctr + (p - ctr) * k)
	return out


## A line of fire as a targeting mark, `size` wide (Ryan, 3 November): a long solid run, then
## two dashes each well short of the last, with room between (4 November: "more space between
## segments"), every one the same thickness ("make sure that each segment is the same height");
## straight (Direct), or along a gentle lob about a sixth as high as it is wide (Indirect: "Flatten
## the indirect a little").
const FIRE_RUNS := [0.42, 0.22, 0.12, 0.06]   # a line of fire: a solid run and three ever shorter dashes, one height (Ryan, 4 November: "You lost your 4-segment direct and indirect that I approved")
const FIRE_GAPS := [0.07, 0.06, 0.05]


static func _fire_line(ci: CanvasItem, c: Vector2, size: float, color: Color, width: float, lobbed: bool) -> void:
	_segmented(ci, _fire_pts(c, size, lobbed), FIRE_RUNS, FIRE_GAPS, color, width)


## A line of fire's path, `size` wide about `c`: straight, or lobbed low (`lift` its height's share),
## the lob even about its middle (Ryan, 4 November: "is your arch actually even? looks like the
## right side is flatter": its peak had stood left of centre, its right end lower).
static func _fire_pts(c: Vector2, size: float, lobbed: bool, lift: float = 1.0) -> PackedVector2Array:
	var s := size * 0.5
	var h := size * 0.17 * lift
	var pts := PackedVector2Array()
	var a0 := c + Vector2(-s, h * 0.5 if lobbed else 0.0)
	var a1 := c + Vector2(0.0, -h * 1.5 if lobbed else 0.0)
	var a2 := c + Vector2(s, h * 0.5 if lobbed else 0.0)
	for i in range(41):
		var t := i / 40.0
		pts.append(a0.lerp(a1, t).lerp(a1.lerp(a2, t), t))
	return pts


static func _path_length(pts: PackedVector2Array) -> float:
	var total := 0.0
	for i in range(1, pts.size()):
		total += pts[i].distance_to(pts[i - 1])
	return total


## A path drawn as a line of fire: its runs, with the gaps between them, as shares of its length.
static func _segmented(ci: CanvasItem, pts: PackedVector2Array, runs: Array, gaps: Array, color: Color, width: float) -> void:
	var total := _path_length(pts)
	var sum := 0.0
	for v in runs + gaps:
		sum += float(v)
	var at := 0.0
	for k in range(runs.size()):
		var b: float = at + float(runs[k]) / sum * total
		_run(ci, pts, at, b, color, width)
		if k < gaps.size():
			at = b + float(gaps[k]) / sum * total


## A hex's six corners about `c`, pointy side up as the map's.
static func _hex_pts(c: Vector2, r: float) -> PackedVector2Array:
	var hex := PackedVector2Array()
	for i in range(6):
		var a := PI / 6.0 + i * PI / 3.0
		hex.append(c + Vector2(cos(a), sin(a)) * r)
	return hex


## The point a share `u` of the way along a path.
static func _along(pts: PackedVector2Array, u: float) -> Vector2:
	var want := u * _path_length(pts)
	var run := 0.0
	for i in range(1, pts.size()):
		var d := pts[i].distance_to(pts[i - 1])
		if run + d >= want:
			return pts[i - 1].lerp(pts[i], (want - run) / maxf(d, 0.001))
		run += d
	return pts[pts.size() - 1]


## The stretch of a polyline from arc length `a` to `b`, drawn.
static func _run(ci: CanvasItem, pts: PackedVector2Array, a: float, b: float, color: Color, width: float) -> void:
	var out := PackedVector2Array()
	var run := 0.0
	for i in range(1, pts.size()):
		var p0: Vector2 = pts[i - 1]
		var p1: Vector2 = pts[i]
		var l := p0.distance_to(p1)
		if l > 0.0 and run + l >= a and run <= b:
			if out.is_empty():
				out.append(p0.lerp(p1, clampf((a - run) / l, 0.0, 1.0)))
			out.append(p0.lerp(p1, clampf((b - run) / l, 0.0, 1.0)))
		run += l
	if out.size() >= 2:
		ci.draw_polyline(out, color, width)


## A plate chamfered on its two top corners by `k`, square below (a vent's).
static func _top_cut(r: Rect2, k: float) -> PackedVector2Array:
	var p := r.position
	var e := r.end
	return PackedVector2Array([Vector2(p.x + k, p.y), Vector2(e.x - k, p.y), Vector2(e.x, p.y + k), e, Vector2(p.x, e.y), Vector2(p.x, p.y + k)])


## A vent's steam: three waves `half_w` either side of the middle one, `half_h` from their middle
## to their ends; with `thin`, two thin shorter waves among them (Ryan: "secondary thin lines").
static func _vapour(ci: CanvasItem, c: Vector2, half_w: float, half_h: float, color: Color, width: float, thin: bool) -> void:
	_steam(ci, c, half_w, half_h, 3, color, width)
	if thin:
		_steam(ci, c + Vector2(0.0, half_h * 0.2), half_w * 0.5, half_h * 0.72, 2, Color(color, color.a * 0.5), 1.0)


## A cog `tip` from its centre to its teeth's faces, `root` to the ring between them: eight square
## teeth, one at each of the eight points between the compass's.
static func _cog(c: Vector2, tip: float, root: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(8):
		var a := (i + 0.5) * TAU / 8.0
		for q in [-0.2, -0.13, 0.13, 0.2]:
			pts.append(c + Vector2(cos(a + q), sin(a + q)) * (root if absf(q) > 0.15 else tip))
	return pts


## Steam: `n` waves rising, each one full turn of a sine a third as wide as it is tall, `half_w`
## from the middle to the outer waves' centres and `half_h` from the middle to each wave's ends.
static func _steam(ci: CanvasItem, c: Vector2, half_w: float, half_h: float, n: int, color: Color, width: float) -> void:
	for j in range(n):
		var x := (j - (n - 1) * 0.5) * (2.0 * half_w / maxf(1.0, n - 1.0)) if n > 1 else 0.0
		var pts := PackedVector2Array()
		for i in range(17):
			var t := i / 16.0
			pts.append(c + Vector2(x + sin(t * TAU) * half_h * 0.34, half_h - t * 2.0 * half_h))
		ci.draw_polyline(pts, color, width)


## Whom an entry is aimed at, the targeting mark under its main mark (Ryan, 2 November: one
## width, "the width of the 3 hex symbol"; 3 November: "putting targeting underneath"): a foe by
## its reach, a line of fire, straight (Direct) or lobbed (Indirect); a
## machine by three hexes, its own only, its allies only, or either; "" for a blank. A reach past
## the target is its keyword's chip (an area, Every Foe, Every Ally).
static func aim_for(face: Face) -> String:
	if face == null or face.kind == Face.Kind.BLANK:
		return ""
	if face.kind == Face.Kind.ATTACK:
		if face.reach == Face.Reach.EVERY_FOE:
			return "aim_every_foe"   # every foe at once (4 November)
		return "aim_indirect" if face.reach == Face.Reach.INDIRECT else "aim_direct"
	match face.targets:
		Face.Target.SELF:
			return "aim_self"
		Face.Target.ALLY:
			return "aim_ally"
		Face.Target.EVERY_ALLY:
			return "aim_every_ally"   # the whole team at once (4 November)
		Face.Target.EVERY_OTHER_ALLY:
			return "aim_every_other_ally"   # every machine but its own at once
	return "aim_any"
