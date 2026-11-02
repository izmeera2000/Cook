class_name GrillBurgerVisual
extends Node3D

const BURGER_RADIUS := 0.38
const IDEAL_SEAR_MIN := 0.65
const IDEAL_SEAR_MAX := 0.92

var side_doneness: Array[float] = [0.0, 0.0]
var current_side := 0
var _flip_tween: Tween
var _patty_material: StandardMaterial3D
var _sear_materials: Array[StandardMaterial3D] = []


func _ready() -> void:
	_build_burger()


func reset_burger() -> void:
	side_doneness = [0.0, 0.0]
	current_side = 0
	rotation = Vector3.ZERO
	visible = true
	_update_surface_materials()


func set_cook_progress(side: int, progress: float) -> void:
	if side < 0 or side >= side_doneness.size():
		return
	side_doneness[side] = clampf(progress, 0.0, 1.2)
	_update_surface_materials()


func flip_to_side(side: int) -> void:
	if side < 0 or side >= side_doneness.size():
		return
	if _flip_tween and _flip_tween.is_running():
		_flip_tween.kill()
	current_side = side
	_flip_tween = create_tween()
	_flip_tween.tween_property(self, "rotation:x", rotation.x + PI, 0.55)
	_flip_tween.set_trans(Tween.TRANS_SINE)
	_flip_tween.set_ease(Tween.EASE_IN_OUT)


func _build_burger() -> void:
	var patty_mesh := CylinderMesh.new()
	patty_mesh.top_radius = BURGER_RADIUS
	patty_mesh.bottom_radius = BURGER_RADIUS * 0.94
	patty_mesh.height = 0.14
	patty_mesh.radial_segments = 40
	patty_mesh.rings = 4
	_patty_material = StandardMaterial3D.new()
	_patty_material.albedo_color = Color("#a95e38")
	_patty_material.roughness = 0.78
	var patty := MeshInstance3D.new()
	patty.name = "Patty"
	patty.mesh = patty_mesh
	patty.material_override = _patty_material
	add_child(patty)

	for side in range(2):
		var surface := Node3D.new()
		surface.name = "TopSear" if side == 0 else "BottomSear"
		surface.position.y = 0.071 if side == 0 else -0.071
		if side == 1:
			surface.rotation.x = PI
		add_child(surface)

		var sear_material := StandardMaterial3D.new()
		sear_material.albedo_color = Color("#a95e38")
		sear_material.roughness = 0.9
		_sear_materials.append(sear_material)
		for mark_index in range(3):
			var mark_mesh := BoxMesh.new()
			mark_mesh.size = Vector3(0.52, 0.006, 0.026)
			var mark := MeshInstance3D.new()
			mark.position.y = 0.003
			mark.position.z = (float(mark_index) - 1.0) * 0.13
			mark.rotation.y = -0.3
			mark.mesh = mark_mesh
			mark.material_override = sear_material
			surface.add_child(mark)

	_update_surface_materials()


func _update_surface_materials() -> void:
	if not _patty_material:
		return
	var average_doneness := (side_doneness[0] + side_doneness[1]) * 0.5
	_patty_material.albedo_color = Color("#a95e38").lerp(
		Color("#38231d"), clampf(average_doneness, 0.0, 1.0)
	)
	for side in range(_sear_materials.size()):
		var progress := side_doneness[side]
		var ideal := progress >= IDEAL_SEAR_MIN and progress <= IDEAL_SEAR_MAX
		var sear_color := Color("#a95e38").lerp(
			Color("#281810"), clampf(progress * 1.25, 0.0, 1.0)
		)
		if ideal:
			sear_color = Color("#392017")
		_sear_materials[side].albedo_color = sear_color
