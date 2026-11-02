class_name KitchenStation
extends Node3D

signal minigame_finished(success: bool)

enum GrillAction { TOO_RAW, FLIPPED, SERVED, BURNT, INACTIVE }

const GRILL_COOK_RATE := 0.18
const GRILL_MIN_INTERACT_DONENESS := 0.48
const GRILL_IDEAL_DONENESS_MIN := 0.65
const GRILL_IDEAL_DONENESS_MAX := 0.92
const GRILL_BURN_DONENESS := 1.12
const WOK_PROGRESS_PER_SHAKE := 0.2
const PREP_PROGRESS_PER_CHOP := 1.0 / 3.0

@export var station_name := "Kitchen Station"
@export var station_type: StringName = &"oven"
@export var interaction_camera: Marker3D
@export_range(0.5, 3.0, 0.1) var interaction_distance := 1.7

var _grill_active := false
var _grill_finished := false
var _grill_side := 0
var _grill_side_doneness: Array[float] = [0.0, 0.0]
var _grill_side_seared: Array[bool] = [false, false]
var _wok_active := false
var _wok_finished := false
var _wok_progress := 0.0
var _wok_shakes := 0
var _prep_active := false
var _prep_finished := false
var _prep_progress := 0.0
var _prep_chops := 0

@onready var _grill_burger: GrillBurgerVisual = get_node_or_null("GrillBurger") as GrillBurgerVisual
@onready var _wok_rice: WokRiceVisual = get_node_or_null("WokRice") as WokRiceVisual
@onready var _vegetable_prep: VegetablePrepVisual = (
	get_node_or_null("VegetablePrep") as VegetablePrepVisual
)


func _ready() -> void:
	add_to_group("kitchen_stations")


func complete_minigame(success: bool) -> void:
	minigame_finished.emit(success)


func start_grill() -> bool:
	if station_type != &"grill" or not _grill_burger:
		push_warning("Cannot start grill: this station is missing its burger visual.")
		return false
	_grill_active = true
	_grill_finished = false
	_grill_side = 0
	_grill_side_doneness = [0.0, 0.0]
	_grill_side_seared = [false, false]
	_grill_burger.reset_burger()
	return true


func advance_grill(delta: float, cooking_speed_multiplier := 1.0) -> bool:
	if not _grill_active or _grill_finished:
		return false
	_grill_side_doneness[_grill_side] = minf(
		GRILL_BURN_DONENESS,
		_grill_side_doneness[_grill_side]
		+ delta * GRILL_COOK_RATE * cooking_speed_multiplier
	)
	_grill_burger.set_cook_progress(_grill_side, _grill_side_doneness[_grill_side])
	if _grill_side_doneness[_grill_side] >= GRILL_BURN_DONENESS:
		_grill_active = false
		_grill_finished = true
		return true
	return false


func interact_with_grill() -> GrillAction:
	if not _grill_active or _grill_finished:
		return GrillAction.INACTIVE
	var doneness := _grill_side_doneness[_grill_side]
	if doneness >= GRILL_BURN_DONENESS:
		_grill_active = false
		_grill_finished = true
		return GrillAction.BURNT
	if doneness < GRILL_MIN_INTERACT_DONENESS:
		return GrillAction.TOO_RAW

	_grill_side_seared[_grill_side] = (
		doneness >= GRILL_IDEAL_DONENESS_MIN and doneness <= GRILL_IDEAL_DONENESS_MAX
	)
	if _grill_side == 0:
		_grill_side = 1
		_grill_burger.flip_to_side(_grill_side)
		return GrillAction.FLIPPED

	_grill_active = false
	_grill_finished = true
	return GrillAction.SERVED


func is_grill_order_successful() -> bool:
	return _grill_side_seared[0] and _grill_side_seared[1]


func get_grill_sides_seared() -> int:
	var seared_sides := 0
	for side_seared in _grill_side_seared:
		if side_seared:
			seared_sides += 1
	return seared_sides


func get_grill_side_doneness() -> Array[float]:
	return _grill_side_doneness.duplicate()


func get_grill_side() -> int:
	return _grill_side


func is_grill_finished() -> bool:
	return _grill_finished


func abort_grill() -> void:
	_grill_active = false
	_grill_finished = false
	if _grill_burger:
		_grill_burger.visible = false


func start_wok() -> bool:
	if station_type != &"wok" or not _wok_rice:
		push_warning("Cannot start wok: this station is missing its rice visual.")
		return false
	_wok_active = true
	_wok_finished = false
	_wok_progress = 0.0
	_wok_shakes = 0
	_wok_rice.reset_wok()
	return true


func shake_wok(cooking_speed_multiplier := 1.0) -> bool:
	if not _wok_active or _wok_finished:
		return false
	_wok_shakes += 1
	_wok_progress = minf(
		1.0, _wok_progress + WOK_PROGRESS_PER_SHAKE * cooking_speed_multiplier
	)
	_wok_rice.set_cook_progress(_wok_progress)
	_wok_rice.shake()
	if _wok_progress >= 1.0:
		_wok_active = false
		_wok_finished = true
		return true
	return false


func is_wok_finished() -> bool:
	return _wok_finished


func get_wok_progress() -> float:
	return _wok_progress


func get_wok_shakes() -> int:
	return _wok_shakes


func abort_wok() -> void:
	_wok_active = false
	_wok_finished = false
	if _wok_rice:
		_wok_rice.visible = false


func start_vegetable_prep() -> bool:
	if station_type != &"prep" or not _vegetable_prep:
		push_warning("Cannot start vegetable prep: this station is missing its prep visual.")
		return false
	_prep_active = true
	_prep_finished = false
	_prep_progress = 0.0
	_prep_chops = 0
	_vegetable_prep.reset_prep()
	return true


func chop_vegetables(cooking_speed_multiplier := 1.0) -> bool:
	if not _prep_active or _prep_finished:
		return false
	_prep_chops += 1
	_prep_progress = minf(1.0, _prep_progress + PREP_PROGRESS_PER_CHOP * cooking_speed_multiplier)
	_vegetable_prep.set_cut_progress(_prep_progress)
	_vegetable_prep.chop()
	if _prep_progress >= 1.0:
		_prep_active = false
		_prep_finished = true
		return true
	return false


func is_prep_finished() -> bool:
	return _prep_finished


func get_prep_progress() -> float:
	return _prep_progress


func get_prep_chops() -> int:
	return _prep_chops


func abort_vegetable_prep() -> void:
	_prep_active = false
	_prep_finished = false
	if _vegetable_prep:
		_vegetable_prep.visible = false
