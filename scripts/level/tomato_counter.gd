extends KitchenStation

@export var lid: Node3D
@export var reveal_tomato: Node3D

var _lid_closed_rotation := Vector3.ZERO
var _is_animating := false


func _ready() -> void:
	super._ready()
	add_to_group("tomato_counters")
	if lid:
		_lid_closed_rotation = lid.rotation
	if reveal_tomato:
		reveal_tomato.visible = false


func take_tomato() -> bool:
	_animate_access()
	return true


func return_tomato() -> void:
	_animate_access()


func _animate_access() -> void:
	if not lid or _is_animating:
		return
	_is_animating = true
	if reveal_tomato:
		reveal_tomato.visible = true
	var tween := create_tween()
	tween.tween_property(
		lid,
		"rotation",
		_lid_closed_rotation + Vector3(deg_to_rad(82.0), 0.0, 0.0),
		0.22
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.14)
	if reveal_tomato:
		tween.tween_callback(_hide_reveal_tomato)
	tween.tween_property(lid, "rotation", _lid_closed_rotation, 0.26).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_IN)
	tween.finished.connect(_on_access_animation_finished)


func _hide_reveal_tomato() -> void:
	if reveal_tomato:
		reveal_tomato.visible = false


func _on_access_animation_finished() -> void:
	_is_animating = false