extends StaticBody3D

const COUNTER_LENGTH := 5.4
const BIN_SPACING := 1.04
const BIN_LENGTH := 0.98
const BIN_WALL_HEIGHT := 0.28
const INGREDIENTS := [
	{
		"label": "TOMATOES",
		"kind": &"tomato",
		"color": Color("#d94c3e"),
		"leaf": Color("#4d8b47"),
		"panel": Color("#70413a")
	},
	{
		"label": "ONIONS",
		"kind": &"onion",
		"color": Color("#d9c1a8"),
		"leaf": Color("#709052"),
		"panel": Color("#685448")
	},
	{
		"label": "POTATOES",
		"kind": &"potato",
		"color": Color("#a87843"),
		"leaf": Color("#718349"),
		"panel": Color("#68533e")
	},
	{
		"label": "CARROTS",
		"kind": &"carrot",
		"color": Color("#ee8739"),
		"leaf": Color("#568747"),
		"panel": Color("#75503a")
	},
	{
		"label": "CABBAGES",
		"kind": &"cabbage",
		"color": Color("#75a34e"),
		"leaf": Color("#47733e"),
		"panel": Color("#4f6344")
	}
]


func _ready() -> void:
	_build_counter()
	for index in range(INGREDIENTS.size()):
		var center_z := (float(index) - 2.0) * BIN_SPACING
		_build_bin(INGREDIENTS[index], center_z, index)


func _build_counter() -> void:
	var cabinet_material := _create_material(Color("#493226"), 0.74)
	var steel_material := _create_material(Color("#879295"), 0.3, 0.58)
	_add_box("ContinuousCabinet", Vector3(0.82, 1.0, COUNTER_LENGTH), Vector3.ZERO, cabinet_material)
	_add_box_collision("CabinetCollision", Vector3(0.82, 1.0, COUNTER_LENGTH), Vector3.ZERO)
	_add_box(
		"ContinuousCountertop",
		Vector3(0.9, 0.12, COUNTER_LENGTH),
		Vector3(0.0, 0.56, 0.0),
		steel_material
	)
	_add_box_collision(
		"CountertopCollision", Vector3(0.9, 0.12, COUNTER_LENGTH), Vector3(0.0, 0.56, 0.0)
	)


func _build_bin(ingredient: Dictionary, center_z: float, index: int) -> void:
	var bin_material := _create_material(Color("#394548"), 0.42, 0.45)
	var panel_material := _create_material(ingredient["panel"], 0.58)
	var bin_name := str(ingredient["kind"]).capitalize()
	var side_size := Vector3(0.035, BIN_WALL_HEIGHT, BIN_LENGTH)
	var end_size := Vector3(0.72, BIN_WALL_HEIGHT, 0.035)
	var wall_y := 0.82
	_add_box(
		"%sBinFloor" % bin_name,
		Vector3(0.72, 0.04, BIN_LENGTH),
		Vector3(0.0, 0.66, center_z),
		bin_material
	)
	_add_box(
		"%sBinInnerWall" % bin_name,
		side_size,
		Vector3(0.36, wall_y, center_z),
		bin_material
	)
	_add_box(
		"%sBinOuterWall" % bin_name,
		side_size,
		Vector3(-0.36, wall_y, center_z),
		bin_material
	)
	_add_box(
		"%sBinEndWallA" % bin_name,
		end_size,
		Vector3(0.0, wall_y, center_z - BIN_LENGTH * 0.5),
		bin_material
	)
	_add_box(
		"%sBinEndWallB" % bin_name,
		end_size,
		Vector3(0.0, wall_y, center_z + BIN_LENGTH * 0.5),
		bin_material
	)
	_add_box(
		"%sFrontLabelPanel" % bin_name,
		Vector3(0.025, 0.26, BIN_LENGTH),
		Vector3(-0.39, 0.82, center_z),
		panel_material
	)
	_create_front_label(str(ingredient["label"]), center_z)
	_create_front_illustration(ingredient, center_z, index)
	_create_bin_contents(ingredient, center_z, index)


func _create_front_label(label_text: String, center_z: float) -> void:
	var label := Label3D.new()
	label.name = "%sLabel" % label_text.capitalize()
	label.text = label_text
	label.font_size = 30
	label.pixel_size = 0.005
	label.modulate = Color("#fff3dc")
	label.outline_size = 5
	label.outline_modulate = Color("#26302f")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.rotation.y = PI / 2.0
	label.position = Vector3(-0.415, 0.82, center_z + 0.17)
	add_child(label)


func _create_front_illustration(ingredient: Dictionary, center_z: float, index: int) -> void:
	var kind: StringName = ingredient["kind"]
	var color: Color = ingredient["color"]
	var leaf: Color = ingredient["leaf"]
	var icon_center := Vector3(-0.43, 0.82, center_z - 0.31)
	match kind:
		&"tomato":
			_add_ellipsoid("TomatoIcon%d" % index, icon_center, Vector3(0.18, 0.16, 0.05), color)
			_add_ellipsoid(
				"TomatoLeafIcon%d" % index,
				icon_center + Vector3(0.0, 0.095, 0.0),
				Vector3(0.1, 0.04, 0.025),
				leaf
			)
		&"onion":
			_add_ellipsoid("OnionIcon%d" % index, icon_center, Vector3(0.16, 0.2, 0.05), color)
			_add_ellipsoid(
				"OnionStemIcon%d" % index,
				icon_center + Vector3(0.0, 0.13, 0.0),
				Vector3(0.035, 0.09, 0.025),
				leaf
			)
		&"potato":
			_add_ellipsoid(
				"PotatoIconA%d" % index,
				icon_center + Vector3(0.0, 0.025, 0.0),
				Vector3(0.19, 0.13, 0.045),
				color
			)
			_add_ellipsoid(
				"PotatoIconB%d" % index,
				icon_center + Vector3(0.0, -0.055, 0.0),
				Vector3(0.15, 0.1, 0.04),
				Color("#bd925d")
			)
		&"carrot":
			_add_cone(
				"CarrotIcon%d" % index,
				icon_center,
				0.09,
				0.24,
				color,
				Vector3(0.0, 0.0, PI)
			)
			_add_ellipsoid(
				"CarrotLeafIcon%d" % index,
				icon_center + Vector3(0.0, 0.13, 0.0),
				Vector3(0.13, 0.04, 0.025),
				leaf
			)
		&"cabbage":
			_add_ellipsoid("CabbageIcon%d" % index, icon_center, Vector3(0.2, 0.18, 0.05), color)
			_add_ellipsoid(
				"CabbageLeafIconA%d" % index,
				icon_center + Vector3(0.0, 0.0, 0.035),
				Vector3(0.13, 0.15, 0.02),
				leaf
			)


func _create_bin_contents(ingredient: Dictionary, center_z: float, index: int) -> void:
	var kind: StringName = ingredient["kind"]
	var color: Color = ingredient["color"]
	var leaf: Color = ingredient["leaf"]
	var offsets := [-0.28, 0.0, 0.28]
	for item_index in range(offsets.size()):
		var item_position := Vector3(
			float(item_index % 2) * 0.18 - 0.09,
			0.94 + float(item_index % 2) * 0.02,
			center_z + float(offsets[item_index])
		)
		match kind:
			&"tomato":
				_add_ellipsoid(
					"TomatoBin%d_%d" % [index, item_index],
					item_position,
					Vector3(0.24, 0.22, 0.24),
					color
				)
				_add_ellipsoid(
					"TomatoLeaf%d_%d" % [index, item_index],
					item_position + Vector3(0.0, 0.12, 0.0),
					Vector3(0.1, 0.035, 0.1),
					leaf
				)
			&"onion":
				_add_ellipsoid(
					"OnionBin%d_%d" % [index, item_index],
					item_position,
					Vector3(0.23, 0.25, 0.23),
					color
				)
			&"potato":
				_add_ellipsoid(
					"PotatoBin%d_%d" % [index, item_index],
					item_position,
					Vector3(0.27, 0.19, 0.23),
					color
				)
			&"carrot":
				_add_cone(
					"CarrotBin%d_%d" % [index, item_index],
					item_position,
					0.11,
				0.42,
				color,
				Vector3(0.0, 0.0, PI / 2.0)
				)
			&"cabbage":
				_add_ellipsoid(
					"CabbageBin%d_%d" % [index, item_index],
					item_position,
					Vector3(0.3, 0.28, 0.27),
					color
				)


func _add_box(
	box_name: String, box_size: Vector3, box_position: Vector3, material: Material
) -> MeshInstance3D:
	var box := BoxMesh.new()
	box.size = box_size
	var instance := MeshInstance3D.new()
	instance.name = box_name
	instance.mesh = box
	instance.material_override = material
	instance.position = box_position
	add_child(instance)
	return instance


func _add_box_collision(shape_name: String, shape_size: Vector3, shape_position: Vector3) -> void:
	var shape := BoxShape3D.new()
	shape.size = shape_size
	var collision := CollisionShape3D.new()
	collision.name = shape_name
	collision.shape = shape
	collision.position = shape_position
	add_child(collision)


func _add_ellipsoid(
	mesh_name: String, mesh_position: Vector3, mesh_scale: Vector3, color: Color
) -> MeshInstance3D:
	var sphere := SphereMesh.new()
	var instance := MeshInstance3D.new()
	instance.name = mesh_name
	instance.mesh = sphere
	instance.material_override = _create_material(color, 0.48)
	instance.position = mesh_position
	instance.scale = mesh_scale
	add_child(instance)
	return instance


func _add_cone(
	mesh_name: String,
	mesh_position: Vector3,
	base_radius: float,
	cone_height: float,
	color: Color,
	mesh_rotation: Vector3
) -> MeshInstance3D:
	var cone := CylinderMesh.new()
	cone.bottom_radius = base_radius
	cone.top_radius = 0.0
	cone.height = cone_height
	cone.radial_segments = 12
	var instance := MeshInstance3D.new()
	instance.name = mesh_name
	instance.mesh = cone
	instance.material_override = _create_material(color, 0.5)
	instance.position = mesh_position
	instance.rotation = mesh_rotation
	add_child(instance)
	return instance


func _create_material(color: Color, material_roughness: float, material_metallic := 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = material_roughness
	material.metallic = material_metallic
	return material
