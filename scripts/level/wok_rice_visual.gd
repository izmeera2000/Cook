class_name WokRiceVisual
extends Node3D

var _rice_material: StandardMaterial3D
var _pan: Node3D
var _rice: Node3D
var _shake_tween: Tween


func _ready() -> void:
	_build_wok()


func reset_wok() -> void:
	rotation = Vector3.ZERO
	visible = true
	_set_rice_color(0.0)


func set_cook_progress(progress: float) -> void:
	_set_rice_color(progress)


func shake() -> void:
	if _shake_tween and _shake_tween.is_running():
		_shake_tween.kill()
	_pan.rotation = Vector3.ZERO
	_rice.position.y = 0.17
	_shake_tween = create_tween()
	_shake_tween.set_trans(Tween.TRANS_SINE)
	_shake_tween.set_ease(Tween.EASE_OUT)
	_shake_tween.tween_property(_pan, "rotation:z", 0.24, 0.1)
	_shake_tween.parallel().tween_property(_rice, "position:y", 0.42, 0.12)
	_shake_tween.tween_property(_pan, "rotation:z", -0.2, 0.12)
	_shake_tween.parallel().tween_property(_rice, "position:y", 0.3, 0.12)
	_shake_tween.tween_property(_pan, "rotation:z", 0.0, 0.1)
	_shake_tween.parallel().tween_property(_rice, "position:y", 0.17, 0.1)


func _build_wok() -> void:
	_pan = Node3D.new()
	_pan.name = "Pan"
	add_child(_pan)

	var bowl_mesh := SphereMesh.new()
	bowl_mesh.radius = 0.55
	bowl_mesh.height = 0.44
	var metal := StandardMaterial3D.new()
	metal.albedo_color = Color("#353b3d")
	metal.metallic = 0.72
	metal.roughness = 0.28
	var bowl := MeshInstance3D.new()
	bowl.name = "WokBowl"
	bowl.position.y = 0.04
	bowl.scale = Vector3(1.0, 0.54, 0.78)
	bowl.mesh = bowl_mesh
	bowl.material_override = metal
	_pan.add_child(bowl)

	var rim_mesh := TorusMesh.new()
	rim_mesh.inner_radius = 0.43
	rim_mesh.outer_radius = 0.49
	var rim := MeshInstance3D.new()
	rim.name = "WokRim"
	rim.position.y = 0.17
	rim.scale.z = 0.78
	rim.mesh = rim_mesh
	rim.material_override = metal
	_pan.add_child(rim)

	var handle_mesh := CylinderMesh.new()
	handle_mesh.top_radius = 0.055
	handle_mesh.bottom_radius = 0.07
	handle_mesh.height = 0.58
	var handle_material := StandardMaterial3D.new()
	handle_material.albedo_color = Color("#4c3322")
	handle_material.roughness = 0.8
	var handle := MeshInstance3D.new()
	handle.name = "Handle"
	handle.position = Vector3(0.0, 0.13, 0.67)
	handle.rotation.x = PI * 0.5
	handle.mesh = handle_mesh
	handle.material_override = handle_material
	_pan.add_child(handle)

	_rice = Node3D.new()
	_rice.name = "Rice"
	_rice.position.y = 0.17
	_pan.add_child(_rice)
	_rice_material = StandardMaterial3D.new()
	_rice_material.albedo_color = Color("#eee1b8")
	_rice_material.roughness = 0.9
	for index in range(13):
		var grain_mesh := SphereMesh.new()
		grain_mesh.radius = 0.045
		grain_mesh.height = 0.07
		var grain := MeshInstance3D.new()
		var angle := TAU * float(index) / 13.0
		var radius := 0.23 if index % 2 == 0 else 0.12
		grain.position = Vector3(cos(angle) * radius, 0.0, sin(angle) * radius * 0.72)
		grain.rotation.z = angle * 0.35
		grain.scale = Vector3(1.0, 0.45, 0.7)
		grain.mesh = grain_mesh
		grain.material_override = _rice_material
		_rice.add_child(grain)


func _set_rice_color(progress: float) -> void:
	if _rice_material:
		_rice_material.albedo_color = Color("#eee1b8").lerp(
			Color("#d2a84a"), clampf(progress, 0.0, 1.0)
		)
