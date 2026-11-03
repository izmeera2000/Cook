class_name MobileJoystick
extends Control

signal movement_changed(direction: Vector2)

const RADIUS := 78.0
const KNOB_RADIUS := 34.0

var _touch_index := -1
var _direction := Vector2.ZERO


func _ready() -> void:
	visible = OS.has_feature("mobile")
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and _touch_index == -1:
			if event.position.distance_to(size * 0.5) <= RADIUS:
				_touch_index = event.index
				_update_direction(event.position)
				accept_event()
		elif not event.pressed and event.index == _touch_index:
			_touch_index = -1
			_set_direction(Vector2.ZERO)
			accept_event()
	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_direction(event.position)
		accept_event()


func _draw() -> void:
	var center := size * 0.5
	draw_circle(center, RADIUS, Color(0.06, 0.08, 0.09, 0.55))
	draw_arc(center, RADIUS, 0.0, TAU, 48, Color(0.85, 0.9, 0.88, 0.65), 3.0)
	draw_circle(center + _direction * RADIUS, KNOB_RADIUS, Color(0.94, 0.48, 0.24, 0.82))
	draw_arc(
		center + _direction * RADIUS,
		KNOB_RADIUS,
		0.0,
		TAU,
		32,
		Color(1.0, 0.85, 0.68, 0.9),
		2.0
	)


func _update_direction(position: Vector2) -> void:
	var offset := position - size * 0.5
	_set_direction(offset.limit_length(RADIUS) / RADIUS)


func _set_direction(direction: Vector2) -> void:
	if _direction.is_equal_approx(direction):
		return
	_direction = direction
	movement_changed.emit(_direction)
	queue_redraw()
