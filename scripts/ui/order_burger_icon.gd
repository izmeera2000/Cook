class_name OrderBurgerIcon
extends Control


func _ready() -> void:
	custom_minimum_size = Vector2(70.0, 62.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var center := size * 0.5
	_draw_ellipse(center + Vector2(0.0, 12.0), Vector2(28.0, 10.0), Color("#75401f"))
	_draw_ellipse(center + Vector2(0.0, 8.0), Vector2(27.0, 8.0), Color("#e8a84f"))
	_draw_ellipse(center + Vector2(0.0, 2.0), Vector2(25.0, 7.0), Color("#69402b"))
	_draw_ellipse(center + Vector2(0.0, -2.0), Vector2(27.0, 8.0), Color("#4b8c43"))
	_draw_ellipse(center + Vector2(0.0, -6.0), Vector2(24.0, 6.0), Color("#f0ca57"))
	_draw_ellipse(center + Vector2(0.0, -12.0), Vector2(27.0, 12.0), Color("#edac4f"))
	_draw_ellipse(center + Vector2(0.0, -15.0), Vector2(22.0, 9.0), Color("#f5c46e"))
	for seed_position in [
		Vector2(-12.0, -18.0),
		Vector2(-4.0, -21.0),
		Vector2(5.0, -20.0),
		Vector2(13.0, -15.0),
		Vector2(0.0, -14.0)
	]:
		draw_circle(center + seed_position, 1.4, Color("#fff2d5"))


func _draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in 24:
		var angle := TAU * float(index) / 24.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)
