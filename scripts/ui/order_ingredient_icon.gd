class_name OrderIngredientIcon
extends Control

var ingredient := "patty"


func _ready() -> void:
	custom_minimum_size = Vector2(48.0, 46.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var center := size * 0.5
	match ingredient:
		"bun":
			_draw_ellipse(center + Vector2(0.0, 4.0), Vector2(15.0, 8.0), Color("#a96831"))
			_draw_ellipse(center + Vector2(0.0, 0.0), Vector2(15.0, 6.0), Color("#e8a84f"))
			_draw_ellipse(center + Vector2(0.0, -4.0), Vector2(15.0, 8.0), Color("#edac4f"))
			for seed_position in [Vector2(-6.0, -6.0), Vector2(0.0, -8.0), Vector2(6.0, -5.0)]:
				draw_circle(center + seed_position, 1.0, Color("#fff2d5"))
		"patty":
			_draw_ellipse(center, Vector2(15.0, 11.0), Color("#753822"))
			_draw_ellipse(center + Vector2(0.0, -2.0), Vector2(11.0, 6.0), Color("#a65c38"))
			draw_arc(center, 14.0, PI, TAU, 20, Color("#d28a53"), 1.5, true)
		"lettuce":
			draw_colored_polygon(
				PackedVector2Array([
					center + Vector2(-17.0, 2.0),
					center + Vector2(-13.0, -9.0),
					center + Vector2(-6.0, -4.0),
					center + Vector2(0.0, -13.0),
					center + Vector2(7.0, -4.0),
					center + Vector2(14.0, -10.0),
					center + Vector2(18.0, 2.0),
					center + Vector2(12.0, 10.0),
					center + Vector2(-12.0, 10.0)
				]),
				Color("#64a94b")
			)
			draw_line(center + Vector2(-11.0, 3.0), center + Vector2(12.0, 3.0), Color("#c0dc79"), 2.0)
		"tomato":
			_draw_ellipse(center, Vector2(14.0, 13.0), Color("#c84232"))
			_draw_ellipse(center, Vector2(8.0, 7.0), Color("#f27d4c"))
			draw_circle(center + Vector2(-3.0, -2.0), 2.0, Color("#ffd097"))
			draw_circle(center + Vector2(4.0, 3.0), 2.0, Color("#ffd097"))
		"cheese":
			draw_colored_polygon(
				PackedVector2Array([
					center + Vector2(-16.0, -9.0),
					center + Vector2(16.0, -9.0),
					center + Vector2(16.0, 4.0),
					center + Vector2(9.0, 11.0),
					center + Vector2(4.0, 4.0),
					center + Vector2(-2.0, 12.0),
					center + Vector2(-6.0, 4.0),
					center + Vector2(-16.0, 4.0)
				]),
				Color("#f2c845")
			)
		"onion":
			draw_arc(center, 13.0, 0.0, TAU, 24, Color("#d4a0ce"), 6.0, true)
			draw_arc(center, 6.0, 0.0, TAU, 24, Color("#f1d8e8"), 3.0, true)
		"pickle":
			_draw_ellipse(center, Vector2(14.0, 8.0), Color("#557e35"))
			for dot in [Vector2(-6.0, 0.0), Vector2(0.0, -2.0), Vector2(6.0, 1.0)]:
				draw_circle(center + dot, 1.3, Color("#c5d77b"))
		_:
			_draw_ellipse(center, Vector2(15.0, 10.0), Color("#dca65c"))


func _draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in 24:
		var angle := TAU * float(index) / 24.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)
