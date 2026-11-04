class_name ShotTrail
extends Node2D

## The shot crossing the field (Ryan, 3 November: "Table shots crossing the field for now, it might
## be too busy. Maybe just build a simple version so I can judge"): off unless a debug build's
## Settings turns SHOT TRAILS on (RIFTGATE_SHOTS=1 on the desk). From the firing machine to what it
## fires at, a tracer for a direct shot, an arc for a launcher's, a beam held for the blow's length,
## nothing for a weapon that lunges (MuzzleFlare.lunges; its lunge is the travel), landing when the
## blow's sound says it lands. Its
## colour is the shot's flare's (MuzzleFlare), which carries no meaning in play.

enum { TRACER, ARC, BEAM }
const STREAK := 0.28      # a tracer's streak, this share of its run
const HOLD := 0.18        # a beam held this long past the blow's landing
const FADE := 0.12        # and anything gone this long after
const MIN_FLIGHT := 0.12  # the shortest a shot takes, for a blow whose sound lands at once

var kind := TRACER
var from := Vector2.ZERO
var to := Vector2.ZERO
var colour := Color.WHITE
var start := 0.0      # seconds from now that it leaves the muzzle
var flight := 0.2     # seconds it takes to land
var _t := 0.0


## Whether trails show: a debug build's SHOT TRAILS, or RIFTGATE_SHOTS=1.
static func on() -> bool:
	return OS.get_environment("RIFTGATE_SHOTS") == "1" or (OS.is_debug_build() and bool(Settings.display.get("shot_trails", false)))


## The trail a component's shot takes: none for a weapon that lunges (MuzzleFlare.lunges: melee
## with nothing that crosses the field; the lunge is the travel), a beam for a laser's (its tag),
## an arc for an indirect weapon's (its reach: lobbed over the front), else a tracer, a shotgun
## tagged melee among them; -1 for none.
static func kind_for(c: Dictionary) -> int:
	var tags = c.get("tags", [])
	tags = tags if tags is Array else []
	if MuzzleFlare.lunges(tags, str(c.get("shape", ""))):
		return -1
	if (tags as Array).has("beam"):
		return BEAM
	var face = c.get("face", {})
	if face is Dictionary and str(face.get("reach", "direct")) == "indirect":
		return ARC
	return TRACER


static func make(k: int, a: Vector2, b: Vector2, col: Color, leaves: float, lands: float) -> ShotTrail:
	var s := ShotTrail.new()
	s.kind = k
	s.from = a
	s.to = b
	s.colour = col
	s.start = maxf(0.0, leaves)
	s.flight = maxf(MIN_FLIGHT, lands - leaves)
	s.z_index = 20
	return s


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()
	if _t > start + flight + HOLD + FADE:
		queue_free()


## Where an arc stands `s` of the way along: a lobbed shell rises over the field and drops onto
## its target. The field runs up the glass, so a rise straight up would lie along the shot and
## read as a tracer: it bows out to the side it came from as well, and peaks above the target.
func arc_at(s: float) -> Vector2:
	var d := from.distance_to(to)
	var side := 1.0 if from.x >= to.x else -1.0
	var mid := (from + to) * 0.5 + Vector2(side * 0.25 * d, -0.5 * d)
	var u := 1.0 - s
	return from * u * u + mid * 2.0 * u * s + to * s * s


func _draw() -> void:
	var u := (_t - start) / flight
	if u < 0.0:
		return
	var after := maxf(0.0, _t - start - flight)
	# Drawn hot (a phone's glass wants every mark louder than the desk suggests): a soft glow
	# under a bright line, a white-hot head.
	match kind:
		BEAM:
			var a := 1.0 if after <= HOLD else clampf(1.0 - (after - HOLD) / FADE, 0.0, 1.0)
			var flick := 0.8 + 0.2 * sin(_t * 70.0)
			draw_line(from, to, Color(colour, 0.35 * a * flick), 16.0, true)
			draw_line(from, to, Color(colour, 0.95 * a), 6.0, true)
			draw_line(from, to, Color(1.0, 1.0, 1.0, 0.85 * a), 2.0, true)
		ARC:
			if u > 1.0 + FADE / flight:
				return
			var head := clampf(u, 0.0, 1.0)
			var pts := PackedVector2Array()
			for k in range(9):
				pts.append(arc_at(clampf(head - STREAK + STREAK * float(k) / 8.0, 0.0, 1.0)))
			var a2 := clampf(1.0 - after / FADE, 0.0, 1.0)
			draw_polyline(pts, Color(colour, 0.3 * a2), 14.0, true)
			draw_polyline(pts, Color(colour, 0.95 * a2), 6.0, true)
			draw_circle(arc_at(head), 7.0, Color(1.0, 1.0, 0.9, a2))
		_:
			if u > 1.0 + FADE / flight:
				return
			var h := clampf(u, 0.0, 1.0)
			var tail := from.lerp(to, clampf(h - STREAK, 0.0, 1.0))
			var tip := from.lerp(to, h)
			var a3 := clampf(1.0 - after / FADE, 0.0, 1.0)
			draw_line(tail, tip, Color(colour, 0.3 * a3), 14.0, true)
			draw_line(tail, tip, Color(colour, 0.95 * a3), 6.0, true)
			draw_circle(tip, 5.0, Color(1.0, 1.0, 0.9, a3))
