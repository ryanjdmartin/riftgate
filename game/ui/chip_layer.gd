class_name ChipLayer
extends Control

## The foes' chips and intent plates, drawn over the intent lines that run from under them (Ryan,
## 24 November: the lines run "under the chips layer but over the sprite layer"): one plate a
## view, standing where the view stands and taking its modulate, each drawing its view's chips
## (UnitView.draw_chips). A view it draws is set `chips_apart`, so it draws them no more itself.
## Ignores input.

var source: Callable   # () -> Array of UnitView: every view whose chips it draws
var _plates := {}      # UnitView -> its plate


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	var views: Array = source.call() if source.is_valid() else []
	var inv := get_global_transform().affine_inverse()
	for v in _plates.keys():
		if not is_instance_valid(v) or not views.has(v):
			(_plates[v] as Node).queue_free()
			_plates.erase(v)
	for v in views:
		var view := v as UnitView
		if view == null or not is_instance_valid(view):
			continue
		view.chips_apart = true
		var plate: Plate = _plates.get(view)
		if plate == null:
			plate = Plate.new()
			plate.view = view
			add_child(plate)
			_plates[view] = plate
		plate.visible = view.is_visible_in_tree() and not view.dead
		var xf := inv * view.get_global_transform()
		plate.position = xf.origin
		plate.scale = xf.get_scale()
		plate.modulate = view.modulate * view.self_modulate
		plate.queue_redraw()


class Plate extends Control:
	var view: UnitView

	func _init() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		if is_instance_valid(view):
			view.draw_chips(self)
