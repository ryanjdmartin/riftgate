class_name Plaque
extends Control

## The other world's own window (decided 9 October, bible section 5): when a foe uses a
## named move, its name shows on a plaque as a classic JRPG would, and the enemy's replay
## holds for it. It is the invasion at the interface layer, so it is drawn in the foes'
## sixteen-bit register and never in the vector HUD's chrome: a blue gradient box behind a
## double white border, the name in a code-drawn 5x7 pixel face with a dark drop shadow,
## every line a whole pixel at the plaque's own pixel size (`px`), nothing anti-aliased.
## A plain blow shows none; every defend, buff or debuff and every boss blow does.
## RIFTGATE_PLAQUE_DEBUG=1 on the skirmish screen fires one after another, to judge running.

const PAD_X := 4      # pixels of blue between the border and the text, each side
const PAD_Y := 3
const BORDER := 3     # white, dark, white
const GLYPH_W := 5
const GLYPH_H := 7
const SPACING := 1    # pixels between glyphs
const FADE_IN := 0.1
const FADE_OUT := 0.18
const DROP := 6.0     # design pixels the plaque settles down from as it fades in

static var WHITE := Color("f8f8f8")
static var DARK := Color("101030")
static var BLUE_TOP := Color("2444a8")
static var BLUE_BOTTOM := Color("0a1448")
static var SHADOW := Color("101030")

## The pixel face: 7 rows of 5, '#' lit. Uppercase only; a character it lacks is a space.
const FONT := {
	"A": [".###.", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"],
	"B": ["####.", "#...#", "#...#", "####.", "#...#", "#...#", "####."],
	"C": [".####", "#....", "#....", "#....", "#....", "#....", ".####"],
	"D": ["####.", "#...#", "#...#", "#...#", "#...#", "#...#", "####."],
	"E": ["#####", "#....", "#....", "####.", "#....", "#....", "#####"],
	"F": ["#####", "#....", "#....", "####.", "#....", "#....", "#...."],
	"G": [".####", "#....", "#....", "#.###", "#...#", "#...#", ".####"],
	"H": ["#...#", "#...#", "#...#", "#####", "#...#", "#...#", "#...#"],
	"I": ["#####", "..#..", "..#..", "..#..", "..#..", "..#..", "#####"],
	"J": ["..###", "...#.", "...#.", "...#.", "...#.", "#..#.", ".##.."],
	"K": ["#...#", "#..#.", "#.#..", "##...", "#.#..", "#..#.", "#...#"],
	"L": ["#....", "#....", "#....", "#....", "#....", "#....", "#####"],
	"M": ["#...#", "##.##", "#.#.#", "#.#.#", "#...#", "#...#", "#...#"],
	"N": ["#...#", "##..#", "#.#.#", "#..##", "#...#", "#...#", "#...#"],
	"O": [".###.", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."],
	"P": ["####.", "#...#", "#...#", "####.", "#....", "#....", "#...."],
	"Q": [".###.", "#...#", "#...#", "#...#", "#.#.#", "#..#.", ".##.#"],
	"R": ["####.", "#...#", "#...#", "####.", "#.#..", "#..#.", "#...#"],
	"S": [".####", "#....", "#....", ".###.", "....#", "....#", "####."],
	"T": ["#####", "..#..", "..#..", "..#..", "..#..", "..#..", "..#.."],
	"U": ["#...#", "#...#", "#...#", "#...#", "#...#", "#...#", ".###."],
	"V": ["#...#", "#...#", "#...#", "#...#", ".#.#.", ".#.#.", "..#.."],
	"W": ["#...#", "#...#", "#...#", "#.#.#", "#.#.#", "##.##", "#...#"],
	"X": ["#...#", ".#.#.", "..#..", "..#..", "..#..", ".#.#.", "#...#"],
	"Y": ["#...#", ".#.#.", "..#..", "..#..", "..#..", "..#..", "..#.."],
	"Z": ["#####", "....#", "...#.", "..#..", ".#...", "#....", "#####"],
	"0": [".###.", "#...#", "#..##", "#.#.#", "##..#", "#...#", ".###."],
	"1": ["..#..", ".##..", "..#..", "..#..", "..#..", "..#..", ".###."],
	"2": [".###.", "#...#", "....#", "...#.", "..#..", ".#...", "#####"],
	"3": ["#####", "...#.", "..#..", "...#.", "....#", "#...#", ".###."],
	"4": ["...#.", "..##.", ".#.#.", "#..#.", "#####", "...#.", "...#."],
	"5": ["#####", "#....", "####.", "....#", "....#", "#...#", ".###."],
	"6": ["..##.", ".#...", "#....", "####.", "#...#", "#...#", ".###."],
	"7": ["#####", "....#", "...#.", "..#..", ".#...", ".#...", ".#..."],
	"8": [".###.", "#...#", "#...#", ".###.", "#...#", "#...#", ".###."],
	"9": [".###.", "#...#", "#...#", ".####", "....#", "...#.", ".##.."],
	"-": [".....", ".....", ".....", "#####", ".....", ".....", "....."],
	".": [".....", ".....", ".....", ".....", ".....", ".##..", ".##.."],
	",": [".....", ".....", ".....", ".....", ".##..", "..#..", ".#..."],
	":": [".....", ".##..", ".##..", ".....", ".##..", ".##..", "....."],
	"'": [".##..", "..#..", ".#...", ".....", ".....", ".....", "....."],
	"!": ["..#..", "..#..", "..#..", "..#..", "..#..", ".....", "..#.."],
	"/": ["....#", "...#.", "...#.", "..#..", ".#...", ".#...", "#...."],
	"&": [".##..", "#..#.", "#..#.", ".##..", "#.#.#", "#..#.", ".##.#"],
	"×": [".....", "#...#", ".#.#.", "..#..", ".#.#.", "#...#", "....."],
}

var text: String = ""
var px: float = 4.0        # one plaque pixel in design units; the foes stand at 2, the plaque is louder on purpose
var _tween: Tween = null


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	visible = false


## The window's size in design units for a name, at this pixel size.
func size_for(name: String) -> Vector2:
	var n := maxi(1, name.length())
	var w := BORDER * 2 + PAD_X * 2 + n * GLYPH_W + (n - 1) * SPACING
	var h := BORDER * 2 + PAD_Y * 2 + GLYPH_H
	return Vector2(w, h) * px


func is_showing() -> bool:
	return visible


## Show a name: the window fades in over a tenth of a second settling down from a little
## above its place, holds, and fades out. Outside a tree (tests, headless) it simply shows.
## The caller places it; `position` is its resting place.
func announce(name: String, hold: float) -> void:
	text = name.to_upper()
	size = size_for(text)
	visible = true
	queue_redraw()
	if _tween != null and _tween.is_valid():
		_tween.kill()
	if not is_inside_tree():
		modulate.a = 1.0
		return
	var rest := position
	position = rest - Vector2(0.0, DROP)
	modulate.a = 0.0
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(self, "modulate:a", 1.0, FADE_IN)
	_tween.tween_property(self, "position", rest, FADE_IN).set_ease(Tween.EASE_OUT)
	_tween.set_parallel(false)
	_tween.tween_interval(maxf(0.0, hold - FADE_IN - FADE_OUT))
	_tween.tween_property(self, "modulate:a", 0.0, FADE_OUT)
	_tween.tween_callback(func() -> void:
		visible = false
		position = rest)


## The lit pixels of one character, as rows of '#' and '.'; a space for one the face lacks.
static func glyph_rows(ch: String) -> Array:
	return FONT.get(ch.to_upper(), [".....", ".....", ".....", ".....", ".....", ".....", "....."])


func _px_rect(x: int, y: int, w: int = 1, h: int = 1) -> Rect2:
	return Rect2(x * px, y * px, w * px, h * px)


func _draw() -> void:
	var cols := int(roundf(size.x / px))
	var rows := int(roundf(size.y / px))
	if cols < 7 or rows < 7:
		return
	# The border, outside in: white, dark, white.
	draw_rect(_px_rect(0, 0, cols, rows), WHITE, true)
	draw_rect(_px_rect(1, 1, cols - 2, rows - 2), DARK, true)
	draw_rect(_px_rect(2, 2, cols - 4, rows - 4), WHITE, true)
	# The blue, a gradient in whole pixel rows.
	var inner_top := BORDER
	var inner_rows := rows - BORDER * 2
	for r in range(inner_rows):
		var t := float(r) / maxf(1.0, float(inner_rows - 1))
		draw_rect(_px_rect(BORDER, inner_top + r, cols - BORDER * 2, 1), BLUE_TOP.lerp(BLUE_BOTTOM, t), true)
	# The name, shadow first.
	var x0 := BORDER + PAD_X
	var y0 := BORDER + PAD_Y
	for pass_i in range(2):
		var shadow := pass_i == 0
		var dx := 1 if shadow else 0
		var x := x0
		for i in range(text.length()):
			var g := glyph_rows(text[i])
			for gy in range(GLYPH_H):
				var row: String = g[gy]
				for gx in range(GLYPH_W):
					if row[gx] == "#":
						draw_rect(_px_rect(x + gx + dx, y0 + gy + dx), SHADOW if shadow else WHITE, true)
			x += GLYPH_W + SPACING
