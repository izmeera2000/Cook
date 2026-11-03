class_name GameplayHUDUI
extends CanvasLayer

signal power_card_activated(index: int)
signal interact_pressed

const ORDER_TICKET_SCENE: PackedScene = preload("res://scenes/ui/order_ticket_ui.tscn")
const STATION_PROGRESS_HEIGHT := 2.65
const STATION_COUNTER_HALF_WIDTH := 0.91
const STATION_PROGRESS_BAR_HEIGHT := 22.0

var points := 0
var _movement_input := Vector2.ZERO
var _station_progress_overlays: Dictionary = {}
var _current_order := "Example order: Classic Cheeseburger  |  Reward: 100 points"
var _order_data: Array[Dictionary] = [
	{
		"name": "CLASSIC CHEESEBURGER",
		"ingredients": ["bun", "patty", "cheese", "lettuce", "tomato", "bun"],
		"reward": 100,
		"accent": Color("#a3c900"),
		"status": "EXAMPLE ORDER"
	},
	{
		"name": "DOUBLE CHEESE",
		"ingredients": ["bun", "patty", "cheese", "patty", "cheese", "bun"],
		"reward": 125,
		"accent": Color("#83b800"),
		"status": "NEXT"
	},
	{
		"name": "GARDEN BURGER",
		"ingredients": ["bun", "lettuce", "tomato", "onion", "pickle", "bun"],
		"reward": 110,
		"accent": Color("#72a900"),
		"status": "NEXT"
	},
	{
		"name": "PICKLE MELT",
		"ingredients": ["bun", "patty", "cheese", "pickle", "bun"],
		"reward": 115,
		"accent": Color("#5e9d00"),
		"status": "NEXT"
	},
	{
		"name": "HOUSE BURGER",
		"ingredients": ["bun", "patty", "lettuce", "tomato", "bun"],
		"reward": 100,
		"accent": Color("#498b00"),
		"status": "NEXT"
	},
	{
		"name": "WESTERN BURGER",
		"ingredients": ["bun", "patty", "cheese", "bacon", "onion", "barbecue sauce", "bun"],
		"reward": 135,
		"accent": Color("#bd5932"),
		"status": "NEXT"
	}
]
var _order_tickets: Array[OrderTicketUI] = []

@onready var orders_bar: PanelContainer = $Screen/OrdersBar
@onready var show_orders_button: Button = $Screen/ShowOrdersButton
@onready var order_summary: Label = $Screen/OrdersBar/Content/OrderSummary
@onready var points_panel: PanelContainer = $Screen/PointsPanel
@onready var points_label: Label = $Screen/PointsPanel/PointsLabel
@onready var powers_button: Button = $Screen/PowersButton
@onready var order_popup: Control = $Screen/OrderPopup
@onready var order_popup_text: Label = $Screen/OrderPopup/Dialog/Layout/OrderSummary
@onready var order_tickets_container: HBoxContainer = (
	$Screen/OrderPopup/Dialog/Layout/OrdersScroll/OrderTickets
)
@onready var power_cards: PowerCardsHUD = $PowerCardsUI
@onready var mobile_interact_button: Button = $Screen/MobileInteractButton


func _ready() -> void:
	$Screen/OrdersBar/Content/HideButton.pressed.connect(_hide_orders_bar)
	show_orders_button.pressed.connect(_show_orders_bar)
	$Screen/OrdersBar/Content/OrdersButton.pressed.connect(open_order_popup)
	$Screen/OrderPopup/Dialog/Layout/Header/CloseButton.pressed.connect(close_order_popup)
	powers_button.pressed.connect(_toggle_power_cards)
	power_cards.card_activated.connect(_on_power_card_activated)
	$Screen/MobileJoystick.movement_changed.connect(_on_movement_changed)
	$Screen/MobileInteractButton.pressed.connect(_on_mobile_interact_pressed)
	if OS.has_feature("mobile"):
		points_panel.offset_left = 230.0
		points_panel.offset_right = 422.0
	else:
		$Screen/MobileInteractButton.hide()
	$PowerCardsUI/Screen/Backdrop.gui_input.connect(_on_power_backdrop_input)
	$Screen/OrderPopup/Backdrop.gui_input.connect(_on_order_backdrop_input)
	_update_points_display()
	_update_order_display()
	_build_order_tickets()
	show_orders_button.hide()
	order_popup.hide()
	power_cards.hide()


func set_cards(cards: Array[PowerCard]) -> void:
	power_cards.set_cards(cards)


func get_movement_input() -> Vector2:
	return _movement_input


func set_mobile_interact_visible(is_visible: bool) -> void:
	mobile_interact_button.visible = is_visible and OS.has_feature("mobile")


func show_station_progress(station: KitchenStation, progress: float, is_ready: bool) -> void:
	var station_id := station.get_instance_id()
	if not _station_progress_overlays.has(station_id):
		var panel := PanelContainer.new()
		panel.name = "StationProgress_%d" % station_id
		panel.custom_minimum_size = Vector2.ZERO
		panel.size = Vector2(220, STATION_PROGRESS_BAR_HEIGHT)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var panel_style := StyleBoxFlat.new()
		panel_style.bg_color = Color(0.055, 0.06, 0.07, 0.92)
		panel_style.border_color = Color(0.96, 0.48, 0.24, 0.9)
		panel_style.set_border_width_all(1)
		panel_style.set_corner_radius_all(4)
		panel.add_theme_stylebox_override("panel", panel_style)

		var bar := ProgressBar.new()
		bar.custom_minimum_size = Vector2(0, STATION_PROGRESS_BAR_HEIGHT - 2)
		bar.max_value = 100.0
		bar.show_percentage = false
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(bar)
		$Screen.add_child(panel)
		_station_progress_overlays[station_id] = {
			"station": station,
			"panel": panel,
			"progress": bar
		}

	var entry: Dictionary = _station_progress_overlays[station_id]
	var progress_bar := entry["progress"] as ProgressBar
	progress_bar.value = 100.0 if is_ready else clampf(progress, 0.0, 1.0) * 100.0
	_position_station_progress(entry, station)


func hide_station_progress(station: KitchenStation) -> void:
	var station_id := station.get_instance_id()
	if not _station_progress_overlays.has(station_id):
		return
	var entry: Dictionary = _station_progress_overlays[station_id]
	var panel := entry["panel"] as Control
	panel.queue_free()
	_station_progress_overlays.erase(station_id)


func set_card_state(
	cooldowns: Array[float], active_card_index: int, active_duration_remaining: float
) -> void:
	power_cards.set_card_state(cooldowns, active_card_index, active_duration_remaining)


func set_powers_visible(is_visible: bool) -> void:
	powers_button.visible = is_visible
	if not is_visible:
		power_cards.close_cards()


func is_modal_open() -> bool:
	return order_popup.visible or power_cards.visible


func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	for station_id in _station_progress_overlays.keys():
		var entry: Dictionary = _station_progress_overlays[station_id]
		var station := entry["station"] as KitchenStation
		if not is_instance_valid(station):
			var panel := entry["panel"] as Control
			panel.queue_free()
			_station_progress_overlays.erase(station_id)
			continue
		if camera:
			_position_station_progress(entry, station)


func _position_station_progress(entry: Dictionary, station: KitchenStation) -> void:
	var camera := get_viewport().get_camera_3d()
	var panel := entry["panel"] as Control
	if not camera:
		panel.hide()
		return
	var world_position := station.global_transform * Vector3(0.0, STATION_PROGRESS_HEIGHT, 0.0)
	if camera.is_position_behind(world_position):
		panel.hide()
		return
	var left_edge := station.global_transform * Vector3(
		-STATION_COUNTER_HALF_WIDTH, STATION_PROGRESS_HEIGHT, 0.0
	)
	var right_edge := station.global_transform * Vector3(
		STATION_COUNTER_HALF_WIDTH, STATION_PROGRESS_HEIGHT, 0.0
	)
	var projected_left := camera.unproject_position(left_edge)
	var projected_right := camera.unproject_position(right_edge)
	panel.size = Vector2(
		projected_left.distance_to(projected_right), STATION_PROGRESS_BAR_HEIGHT
	)
	panel.position = camera.unproject_position(world_position) - panel.size * 0.5
	panel.show()


func set_current_order(order_text: String) -> void:
	_current_order = order_text
	_update_order_display()
	var normalized_order := order_text.to_lower()
	var status := (
		"ON GRILL"
		if normalized_order.contains("grill")
		else (
			"AT WOK"
			if normalized_order.contains("wok")
			else ("PREPPING" if normalized_order.contains("vegetable") else "IN OVEN")
		)
	)
	_set_first_ticket_status(status)


func set_order_result(result_text: String, ticket_status: String = "") -> void:
	_current_order = result_text
	_update_order_display()
	if order_popup.visible:
		order_popup_text.text = _current_order
	var status := ticket_status
	if status.is_empty():
		status = "SERVED" if result_text.begins_with("Order complete!") else "RETRY"
	_set_first_ticket_status(status)


func add_points(amount: int) -> void:
	if amount <= 0:
		return
	points += amount
	_update_points_display()


func open_order_popup() -> void:
	order_popup_text.text = _current_order
	order_popup.show()


func close_order_popup() -> void:
	order_popup.hide()


func _update_points_display() -> void:
	points_label.text = "POINTS\n%d" % points


func _update_order_display() -> void:
	order_summary.text = _current_order


func _build_order_tickets() -> void:
	_order_tickets.clear()
	for index in range(_order_data.size()):
		var order: Dictionary = _order_data[index]
		var ticket := ORDER_TICKET_SCENE.instantiate() as OrderTicketUI
		if not ticket:
			push_error("Order ticket scene root must use OrderTicketUI.")
			continue
		order_tickets_container.add_child(ticket)
		var ingredients: Array[String] = []
		for ingredient in order["ingredients"]:
			ingredients.append(str(ingredient))
		ticket.set_order(
			index + 1,
			str(order["name"]),
			ingredients,
			order["accent"],
			int(order["reward"]),
			str(order["status"])
		)
		_order_tickets.append(ticket)


func _set_first_ticket_status(status: String) -> void:
	if _order_tickets.is_empty():
		return
	var ticket := _order_tickets[0]
	ticket.set_status(status)


func _hide_orders_bar() -> void:
	orders_bar.hide()
	show_orders_button.show()


func _show_orders_bar() -> void:
	orders_bar.show()
	show_orders_button.hide()


func _toggle_power_cards() -> void:
	if power_cards.visible:
		power_cards.close_cards()
	else:
		power_cards.open_cards()


func _on_power_card_activated(index: int) -> void:
	power_cards.close_cards()
	power_card_activated.emit(index)


func _on_movement_changed(direction: Vector2) -> void:
	_movement_input = direction


func _on_mobile_interact_pressed() -> void:
	interact_pressed.emit()


func _on_power_backdrop_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		power_cards.close_cards()


func _on_order_backdrop_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close_order_popup()
