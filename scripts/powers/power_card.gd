class_name PowerCard
extends Resource

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export_range(0.0, 120.0, 0.5) var cooldown_seconds := 12.0
@export_range(0.1, 120.0, 0.5) var duration_seconds := 5.0
@export_range(1.0, 3.0, 0.05) var speed_multiplier := 1.0
@export_range(1.0, 3.0, 0.05) var jump_multiplier := 1.0
@export_range(1.0, 3.0, 0.05) var cooking_speed_multiplier := 1.0
