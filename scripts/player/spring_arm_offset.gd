class_name SpringArmCharacter
extends Node3D

signal perspective_changed(first_person: bool)

const FIXED_CAMERA_PITCH := deg_to_rad(-55.0)
const THIRD_PERSON_SIDE_OFFSET := 0.35
const OCCLUDER_TRANSPARENCY := 0.5
const MAX_OCCLUDERS := 8

@export_category("Objects")
@export var _spring_arm: SpringArm3D = null
@export var _first_person_anchor: Node3D = null

@export_category("Camera Perspective")
@export_range(0.0, 30.0, 0.05) var third_person_distance := 8.0
@export_range(0.0, 1.0, 0.05) var first_person_distance := 0.0
@export_range(0.0, 3.0, 0.05) var third_person_height := 2.0
@export_range(8.0, 50.0, 0.5) var third_person_orthographic_size := 8.5
@export_range(1.0, 179.0, 1.0) var third_person_fov := 75.0
@export_range(1.0, 179.0, 1.0) var first_person_fov := 90.0

var is_first_person := false
var _yaw := 0.0
var _pitch := 0.0
var _station_camera_active := false
var _station_camera_transform := Transform3D.IDENTITY
var _faded_meshes: Dictionary[MeshInstance3D, float] = {}

@onready var _camera: Camera3D = _spring_arm.get_node_or_null("Camera3D") as Camera3D


func _ready() -> void:
	_yaw = rotation.y
	_pitch = FIXED_CAMERA_PITCH
	_apply_axis_lock()
	_apply_perspective()


func _process(_delta: float) -> void:
	_apply_axis_lock()
	if _station_camera_active and _camera:
		_camera.global_transform = _station_camera_transform
	elif is_first_person and _spring_arm and _first_person_anchor:
		_spring_arm.global_position = _first_person_anchor.global_position
	_update_camera_occlusion()


func enter_station_view(camera_transform: Transform3D, field_of_view := 70.0) -> void:
	_station_camera_transform = camera_transform
	_station_camera_active = true
	is_first_person = true
	if _spring_arm:
		_spring_arm.spring_length = 0.0
	if _camera:
		_camera.projection = Camera3D.PROJECTION_PERSPECTIVE
		_camera.fov = field_of_view
		_camera.global_transform = _station_camera_transform
	perspective_changed.emit(true)


func exit_station_view() -> void:
	if not _station_camera_active:
		return
	_station_camera_active = false
	is_first_person = false
	_apply_perspective()
	perspective_changed.emit(false)


func _update_camera_occlusion() -> void:
	var player_body := get_parent() as CollisionObject3D
	if (
		not is_multiplayer_authority()
		or not _camera
		or not _camera.current
		or _station_camera_active
		or not player_body
	):
		_restore_faded_meshes()
		return

	var focus_position := player_body.global_position + Vector3.UP * 0.9
	var camera_position := _camera.global_position
	if camera_position.distance_squared_to(focus_position) < 0.01:
		_restore_faded_meshes()
		return

	var desired_fades: Dictionary[MeshInstance3D, bool] = {}
	var excluded_rids: Array[RID] = [player_body.get_rid()]
	var query := PhysicsRayQueryParameters3D.create(camera_position, focus_position)
	query.collision_mask = 3
	query.exclude = excluded_rids
	query.collide_with_areas = false
	var space_state := get_world_3d().direct_space_state

	for _hit_index in MAX_OCCLUDERS:
		var hit := space_state.intersect_ray(query)
		if hit.is_empty():
			break

		var collider := hit.get("collider") as Node
		if not collider:
			break
		if collider is CollisionObject3D:
			excluded_rids.append((collider as CollisionObject3D).get_rid())
			query.exclude = excluded_rids
		_add_occluder_meshes(collider, desired_fades)

	for mesh in _faded_meshes.keys():
		if not is_instance_valid(mesh):
			continue
		if not desired_fades.has(mesh):
			mesh.transparency = _faded_meshes[mesh]
			_faded_meshes.erase(mesh)

	for mesh in desired_fades:
		if not is_instance_valid(mesh):
			continue
		if not _faded_meshes.has(mesh):
			_faded_meshes[mesh] = mesh.transparency
		mesh.transparency = OCCLUDER_TRANSPARENCY


func _add_occluder_meshes(
	collider: Node,
	desired_fades: Dictionary[MeshInstance3D, bool]
) -> void:
	if collider is MeshInstance3D:
		var mesh := collider as MeshInstance3D
		if mesh.visible:
			desired_fades[mesh] = true
	for node in collider.find_children("*", "MeshInstance3D", true, false):
		var mesh := node as MeshInstance3D
		if mesh and mesh.visible:
			desired_fades[mesh] = true


func _restore_faded_meshes() -> void:
	for mesh in _faded_meshes.keys():
		if is_instance_valid(mesh):
			mesh.transparency = _faded_meshes[mesh]
	_faded_meshes.clear()


func _apply_axis_lock() -> void:
	rotation = Vector3(0.0, _yaw, 0.0)
	if _spring_arm:
		_spring_arm.rotation = Vector3(_pitch, 0.0, 0.0)
	if _camera:
		_camera.rotation = Vector3.ZERO


func _apply_perspective() -> void:
	if not _spring_arm:
		return
	if is_first_person:
		_spring_arm.spring_length = first_person_distance
		if _first_person_anchor:
			_spring_arm.global_position = _first_person_anchor.global_position
		if _camera:
			_camera.projection = Camera3D.PROJECTION_PERSPECTIVE
			_camera.fov = first_person_fov
	else:
		_spring_arm.spring_length = third_person_distance
		_spring_arm.position = Vector3(THIRD_PERSON_SIDE_OFFSET, third_person_height, 0.0)
		if _camera:
			_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
			_camera.size = third_person_orthographic_size
			_camera.fov = third_person_fov
