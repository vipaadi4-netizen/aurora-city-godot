extends Control

## Virtual joystick for Android.
## It is intentionally self-drawn: no texture assets are required.

var value := Vector2.ZERO
var active_touch := -1
var knob_position := Vector2.ZERO

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()

func get_value() -> Vector2:
	return value

func _draw() -> void:
	var center := size / 2.0
	var radius := min(size.x, size.y) * 0.42
	draw_circle(center, radius, Color(0.04, 0.09, 0.16, 0.62))
	draw_arc(center, radius, 0, TAU, 48, Color("#5c91b3"), 2.0)
	var knob := center + knob_position
	draw_circle(knob, radius * 0.42, Color(0.35, 0.82, 0.88, 0.88))
	draw_circle(knob, radius * 0.28, Color(0.68, 0.95, 0.96, 0.8))

func _input(event: InputEvent) -> void:
	var center := size / 2.0
	var radius := min(size.x, size.y) * 0.42
	if event is InputEventScreenTouch:
		var local := event.position - global_position
		if event.pressed and Rect2(Vector2.ZERO, size).has_point(local) and active_touch == -1:
			active_touch = event.index
			_update_from_position(local, center, radius)
		elif not event.pressed and event.index == active_touch:
			active_touch = -1
			value = Vector2.ZERO
			knob_position = Vector2.ZERO
			queue_redraw()
	elif event is InputEventScreenDrag and event.index == active_touch:
		_update_from_position(event.position - global_position, center, radius)

func _update_from_position(local: Vector2, center: Vector2, radius: float) -> void:
	knob_position = (local - center).limit_length(radius * 0.72)
	value = knob_position / (radius * 0.72)
	queue_redraw()
