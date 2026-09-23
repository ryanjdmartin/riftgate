class_name TearLayer
extends ColorRect

## The corrupted side's tear: input the display cannot hold. Laid over the enemy side of
## the skirmish, sprites included, it reads the screen back (tear.gdshader) and redraws one
## or two slices of it for under half a second, each over part of the width as often as
## all of it, sheared sideways as the rift's ground is on the map, a little dimmed, a
## bright hairline on top. One tear every several seconds at most and one slot in three
## silent, so it never becomes a rhythm (Ryan, 23 September: drawn under the sprites, in
## the ground, it was lost; the earlier ticking full-width bands read as extra scan lines;
## a dimming-only flavour was cut the same day, the shear alone). Off with the glitch setting. Hidden
## between tears, so the screen is read back only while one shows. Deterministic in the
## clock it is given, so a screenshot can catch it. RIFTGATE_FEED_DEBUG=1: every two
## seconds, never silent.

const PERIOD := 8.0
const SECONDS := 0.45
const SHADER := preload("res://game/ui/tear.gdshader")

var clock: Callable = Callable()   # -> float: the backdrop's seconds


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	color = Color.WHITE
	var m := ShaderMaterial.new()
	m.shader = SHADER
	material = m
	visible = false
	set_process(true)


static func period() -> float:
	return 2.0 if FeedFX.DEBUG else PERIOD


## When the first tear fires, in clock seconds (screenshots).
static func fire_time() -> float:
	var p := period()
	for slot in range(40):
		if not FeedFX.DEBUG and Hud.noise(slot * 7.7 + 0.3) > 0.66:
			continue
		return (slot + 0.1 + 0.75 * Hud.noise(slot * 3.1 + 0.7)) * p
	return 0.0


func _process(_delta: float) -> void:
	var t: float = clock.call() if clock.is_valid() else 0.0
	var slices := _slices_at(t)
	if slices.is_empty():
		visible = false
		return
	visible = true
	var m := material as ShaderMaterial
	m.set_shader_parameter("count", slices.size())
	m.set_shader_parameter("px_y", 1.0 / maxf(1.0, size.y))
	for i in range(2):
		var s: Dictionary = slices[i] if i < slices.size() else {"rect": Rect2(), "shift": 0.0, "dim": 0.0}
		var r: Rect2 = s["rect"]
		m.set_shader_parameter("slice%d" % i, Vector4(r.position.x / size.x, r.position.y / size.y, r.size.x / size.x, r.size.y / size.y))
		m.set_shader_parameter("shift%d" % i, float(s["shift"]) / size.x)
		m.set_shader_parameter("dim%d" % i, float(s["dim"]))


## The slices torn at clock time `t`, in this layer's pixels: none most of the time.
func _slices_at(t: float) -> Array:
	if not bool(Settings.display.get("glitch", true)):
		return []
	var p := period()
	var slot := floorf(t / p)
	if not FeedFX.DEBUG and Hud.noise(slot * 7.7 + 0.3) > 0.66:
		return []
	var at := (slot + 0.1 + 0.75 * Hud.noise(slot * 3.1 + 0.7)) * p
	var age := t - at
	if age < 0.0 or age > SECONDS:
		return []
	var tick := floorf(age * 16.0)   # a new position every few frames, held long enough to see
	var n := 1 + int(Hud.noise(slot * 1.3 + 0.2) * 2.0)
	var out: Array = []
	for k in range(n):
		# Clear of the band's softened top and bottom, where a slice would be lost.
		var yy := size.y * 0.07 + Hud.noise(slot * 11.1 + k * 0.37) * (size.y * 0.86 - 16.0)
		var full := Hud.noise(slot * 5.5 + k * 0.91) < 0.3
		var wfrac := 1.0 if full else 0.2 + 0.5 * Hud.noise(slot * 2.2 + k * 0.53)
		var x0 := 0.0 if full else Hud.noise(slot * 9.9 + k * 0.71) * (1.0 - wfrac) * size.x
		var hh := 5.0 + 9.0 * Hud.noise(slot * 4.4 + k * 0.29)
		var shift := (Hud.noise(slot * 6.6 + k * 0.43 + tick * 1.7) - 0.5) * 36.0
		out.append({"rect": Rect2(x0, yy, wfrac * size.x, hh), "shift": shift, "dim": 0.12})
	return out
