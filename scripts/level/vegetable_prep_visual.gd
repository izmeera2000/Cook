class_name VegetablePrepVisual
extends Node3D

const VEGETABLE_COLORS: Array[Color] = [
	Color("#e97832"),
	Color("#559342"),
	Color("#d94f42")
]
const VEGETABLE_NAMES: Array[String] = ["Carrot", "Cucumber", "Tomato"]

var _whole_vegetables: Array[MeshInstance3D] = []
var _chopped_vegetables: Array[Node3D] = []
var _knife: Node3D
var _knife_tween: Tween


func _ready() -> void:
	_build_prep_scene()


func reset_prep() -> void:
	visible = true
	for index in range(_whole_vegetables.size()):
		_whole_vegetables[index].show()
		_chopped_vegetables[index].hide()
	_knife.position.y = 0.36
	_knife.rotation.z = 0.0


func set_cut_progress(progress: float) -> void:
	var completed_cuts := mini(3, floori(clampf(progress, 0.0, 1.0) * 3.0 + 0.001))
	for index in range(_whole_vegetables.size()):
		var cut := index < completed_cuts
		_whole_vegetables[index].visible = not cut
		_chopped_vegetables[index].visible = cut


func chop() -> void:
	if _knife_tween and _knife_tween.is_running():
		_knife_tween.kill()
	_knife.position.y = 0.36
	_knife.rotation.z = 0.0
	_knife_tween = create_tween()
	_knife_tween.set_trans(Tween.TRANS_SINE)
	_knife_tween.set_ease(Tween.EASE_IN_OUT)
	_knife_tween.tween_property(_knife, "position:y", 0.12, 0.08)
	_knife_tween.tween_property(_knife, "position:y", 0.36, 0.14)
	_knife_tween.parallel().tween_property(_knife, "rotation:z", -0.22, 0.08)
	_knife_tween.tween_property(_knife, "rotation:z", 0.0, 0.14)


func _build_prep_scene() -> void:
	var board_material := StandardMaterial3D.new()
	board_material.albedo_color = Color("#a66c3f")
	board_material.roughness = 0.9
	var board_mesh := BoxMesh.new()
	board_mesh.size = Vector3(1.25, 0.08, 0.72)
	var board := MeshInstance3D.new()
	board.name = "CuttingBoard"
	board.position.y = 0.04
	board.mesh = board_mesh
	board.material_override = board_material
	add_child(board)

	for index in range(VEGETABLE_NAMES.size()):
		var vegetable := _make_vegetable(index)
		vegetable.name = VEGETABLE_NAMES[index]
		vegetable.position = Vector3((float(index) - 1.0) * 0.34, 0.17, -0.06)
		add_child(vegetable)
		_whole_vegetables.append(vegetable)

		var chopped := Node3D.new()
		chopped.name = "%sPieces" % VEGETABLE_NAMES[index]
		chopped.position = vegetable.position
		chopped.hide()
		add_child(chopped)
		_add_chopped_pieces(chopped, VEGETABLE_COLORS[index])
		_chopped_vegetables.append(chopped)

	_make_knife()


func _make_vegetable(index: int) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.radial_segments = 24
	match index:
		0:
			mesh.top_radius = 0.07
			mesh.bottom_radius = 0.12
			mesh.height = 0.34
		1:
			mesh.top_radius = 0.12
			mesh.bottom_radius = 0.12
			mesh.height = 0.34
		_:
			mesh.top_radius = 0.14
			mesh.bottom_radius = 0.14
			mesh.height = 0.2
	var material := StandardMaterial3D.new()
	material.albedo_color = VEGETABLE_COLORS[index]
	material.roughness = 0.74
	var vegetable := MeshInstance3D.new()
	vegetable.rotation.x = PI * 0.5
	vegetable.mesh = mesh
	vegetable.material_override = material
	return vegetable


func _add_chopped_pieces(parent: Node3D, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.74
	for piece_index in range(4):
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.105
		mesh.bottom_radius = 0.105
		mesh.height = 0.055
		mesh.radial_segments = 16
		var piece := MeshInstance3D.new()
		piece.position = Vector3(
			(float(piece_index) - 1.5) * 0.07,
			0.02,
			(float(piece_index % 2) - 0.5) * 0.1
		)
		piece.mesh = mesh
		piece.material_override = material
		parent.add_child(piece)


func _make_knife() -> void:
	_knife = Node3D.new()
	_knife.name = "Knife"
	_knife.position = Vector3(0.0, 0.36, 0.3)
	add_child(_knife)

	var blade_mesh := BoxMesh.new()
	blade_mesh.size = Vector3(0.28, 0.025, 0.12)
	var blade_material := StandardMaterial3D.new()
	blade_material.albedo_color = Color("#b8c2c3")
	blade_material.metallic = 0.65
	blade_material.roughness = 0.28
	var blade := MeshInstance3D.new()
	blade.position.z = -0.08
	blade.mesh = blade_mesh
	blade.material_override = blade_material
	_knife.add_child(blade)

	var handle_mesh := BoxMesh.new()
	handle_mesh.size = Vector3(0.11, 0.05, 0.16)
	var handle_material := StandardMaterial3D.new()
	handle_material.albedo_color = Color("#35251c")
	handle_material.roughness = 0.8
	var handle := MeshInstance3D.new()
	handle.position.z = 0.07
	handle.mesh = handle_mesh
	handle.material_override = handle_material
	_knife.add_child(handle)
