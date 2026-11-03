extends Node3D

var _chop_count := 0


func _ready() -> void:
	add_to_group("placed_tomatoes")


func register_chop() -> int:
	_chop_count += 1
	if _chop_count >= 3:
		queue_free()
	return _chop_count