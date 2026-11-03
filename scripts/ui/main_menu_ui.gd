class_name MainMenuUI
extends Control

signal host_pressed(nickname: String, skin: String, map_id: String, control_mode: String)
signal join_pressed(nickname: String, skin: String, address: String)
signal quit_pressed

const SKIN_OPTIONS: Array[String] = ["Blue", "Yellow", "Green", "Red"]
const SAFE_AREA_MARGIN := 24.0

@onready var skin_input: OptionButton = $MainContainer/MainMenu/Form/Option2/SkinInput
@onready var map_input: OptionButton = $MainContainer/MainMenu/Form/Option5/MapInput
@onready var control_mode_input: OptionButton = $MainContainer/MainMenu/Form/Option6/ControlModeInput
@onready var nick_input: LineEdit = $MainContainer/MainMenu/Form/Option1/NickInput
@onready var address_input: LineEdit = $MainContainer/MainMenu/Form/Option3/AddressInput
@onready var main_container: VBoxContainer = $MainContainer


func _ready() -> void:
	skin_input.clear()
	for skin_name in SKIN_OPTIONS:
		skin_input.add_item(skin_name)
	skin_input.select(0)
	for map_id in Network.get_map_ids():
		map_input.add_item(Network.get_map_display_name(map_id))
		map_input.set_item_metadata(map_input.item_count - 1, map_id)
	map_input.select(0)
	control_mode_input.add_item("Advanced")
	control_mode_input.set_item_metadata(0, Network.CONTROL_MODE_ADVANCED)
	control_mode_input.add_item("Simple")
	control_mode_input.set_item_metadata(1, Network.CONTROL_MODE_SIMPLE)
	control_mode_input.select(0)
	resized.connect(_update_responsive_layout)
	call_deferred("_update_responsive_layout")


func _on_host_pressed() -> void:
	var nickname = nick_input.text.strip_edges()
	var skin = get_skin()
	host_pressed.emit(nickname, skin, get_map_id(), get_control_mode())


func _on_join_pressed() -> void:
	var nickname = nick_input.text.strip_edges()
	var skin = get_skin()
	var address = address_input.text.strip_edges()
	join_pressed.emit(nickname, skin, address)


func _on_quit_pressed():
	quit_pressed.emit()


func show_menu():
	show()
	call_deferred("_update_responsive_layout")


func hide_menu():
	hide()


func is_menu_visible() -> bool:
	return visible


func _update_responsive_layout() -> void:
	if not main_container:
		return
	var available_size := Vector2(
		maxf(1.0, size.x - SAFE_AREA_MARGIN * 2.0), maxf(1.0, size.y - SAFE_AREA_MARGIN * 2.0)
	)
	var content_size := main_container.get_combined_minimum_size()
	if content_size.x <= 0.0 or content_size.y <= 0.0:
		return
	var scale_factor := minf(1.0, minf(available_size.x / content_size.x, available_size.y / content_size.y))
	main_container.pivot_offset = main_container.size * 0.5
	main_container.scale = Vector2.ONE * scale_factor


func get_skin() -> String:
	return skin_input.get_item_text(skin_input.selected).to_lower()


func get_map_id() -> String:
	if map_input.selected < 0:
		return Network.DEFAULT_MAP_ID
	return Network.sanitize_map_id(str(map_input.get_item_metadata(map_input.selected)))


func get_control_mode() -> String:
	if control_mode_input.selected < 0:
		return Network.CONTROL_MODE_ADVANCED
	return Network.sanitize_control_mode(
		str(control_mode_input.get_item_metadata(control_mode_input.selected))
	)
