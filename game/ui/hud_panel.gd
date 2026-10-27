class_name HudPanel
extends PanelContainer

## A panel in the overlay style: dark chamfered fill, one-pixel HUD border, bracket corners.
## Children lay out inside the content margin like any PanelContainer.

var border: Color = Color(0, 0, 0, 0)   # zero alpha means "use the HUD colour"
var fill_alpha: float = 0.96            # a readout over the field's text is opaque (the die's hold)
var chamfer: float = 12.0
var bracket_len: float = 16.0


func _init(margin: float = 20.0) -> void:
	var sb := StyleBoxEmpty.new()
	sb.set_content_margin_all(margin)
	add_theme_stylebox_override("panel", sb)
	mouse_filter = Control.MOUSE_FILTER_STOP


func _draw() -> void:
	var col := border if border.a > 0.0 else Palette.HUD
	var rect := Rect2(Vector2.ZERO, size)
	Hud.box(self, rect.grow(-4.0), chamfer, Color(Palette.PANEL, fill_alpha), Color(col, 0.8), 1.0)
	Hud.brackets(self, rect, bracket_len, col, 1.5)
