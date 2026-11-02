class_name BurgerFlipVisual
extends Control

var cook_level := 0.0
var current_side := 0
var _steam_time := 0.0
var _flip_progress := 0.0
var _flip_tween: Tween


func _ready() -> void:
	custom_minimum_size = Vector2(440.0, 142.0)
	pivot_offset = custom_minimum_size * 0.5
	set_process(true)


func _process(delta: float) -> void:
	if cook_level > 0.0:
		_steam_time += delta
		queue_redraw()


func set_cook_level(level: float, side: int = 0) -> void:
	cook_level = clampf(level, 0.0, 1.0)
	current_side = side
	queue_redraw()


func play_flip() -> void:
	if _flip_tween and _flip_tween.is_running():
		_flip_tween.kill()
	_flip_progress = 0.0
	_flip_tween = create_tween()
	_flip_tween.tween_property(self, "_flip_progress", 1.0, 0.48)
	_flip_tween.set_trans(Tween.TRANS_SINE)
	_flip_tween.set_ease(Tween.EASE_IN_OUT)


func _draw() -> void:
	var center := size * 0.5
	var pan_center := center + Vector2(-14.0, 10.0)
	draw_line(pan_center + Vector2(112.0, 4.0), pan_center + Vector2(184.0, 22.0), Color("#292d30"), 18.0, true)
	draw_line(pan_center + Vector2(112.0, 4.0), pan_center + Vector2(184.0, 22.0), Color("#747b7b"), 10.0, true)
	_draw_ellipse(pan_center + Vector2(0.0, 8.0), Vector2(145.0, 55.0), Color("#181c1e"))
	_draw_ellipse(pan_center, Vector2(137.0, 49.0), Color("#565e60"))
	_draw_ellipse(pan_center, Vector2(126.0, 40.0), Color("#282d2f"))

	var patty_center := pan_center + Vector2(-5.0, -1.0)
	var flip_height := sin(_flip_progress * PI) * 34.0
	var patty_squash := maxf(0.08, absf(cos(_flip_progress * PI)))
	var patty_color := Color("#a95e38").lerp(Color("#34201a"), cook_level)
	draw_set_transform(patty_center + Vector2(0.0, -flip_height), 0.0, Vector2(1.0, patty_squash))
	_draw_ellipse(Vector2(0.0, 4.0), Vector2(58.0, 32.0), Color("#130f0d"))
	_draw_ellipse(Vector2.ZERO, Vector2(56.0, 30.0), patty_color)
	_draw_ellipse(
		Vector2(-9.0, -7.0),
		Vector2(37.0, 10.0),
		Color("#c77b4a").lerp(Color("#593126"), cook_level)
	)
	var sear_color := Color("#63351f").lerp(Color("#201612"), cook_level)
	var sear_offset := 4.0 if current_side == 0 else -4.0
	for mark_index in range(3):
		var mark_y := float(mark_index - 1) * 13.0 + sear_offset
		draw_line(
			Vector2(-35.0, mark_y + 5.0),
			Vector2(35.0, mark_y - 5.0),
			sear_color,
			3.0,
			true
		)
	draw_arc(Vector2.ZERO, 56.0, PI, TAU, 32, Color("#e2a36a"), 1.5, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	for wisp_index in range(3):
		var phase := _steam_time * 2.0 + float(wisp_index) * 1.8
		var steam_x := patty_center.x + sin(phase) * 7.0 + float(wisp_index - 1) * 24.0
		var steam_top := patty_center.y - 48.0 - fposmod(phase * 10.0, 13.0)
		draw_arc(
			Vector2(steam_x, steam_top),
			5.0 + float(wisp_index),
			PI * 1.15,
			PI * 1.85,
			10,
			Color(0.88, 0.91, 0.9, 0.42),
			2.0,
			true
		)


func _draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in 24:
		var angle := TAU * float(index) / 24.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)
