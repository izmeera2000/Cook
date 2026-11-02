class_name OrderTicketUI
extends PanelContainer

@onready var accent_bar: ColorRect = $Layout/AccentBar
@onready var ticket_label: Label = $Layout/TicketHeader/TicketNumber
@onready var order_name_label: Label = $Layout/OrderName
@onready var ingredients_row: HBoxContainer = $Layout/IngredientsRow
@onready var status_label: Label = $Layout/Status
@onready var reward_label: Label = $Layout/Reward


func set_order(
	order_number: int,
	order_name: String,
	ingredients: Array[String],
	accent_color: Color,
	reward: int,
	status: String = "WAITING"
) -> void:
	accent_bar.color = accent_color
	ticket_label.text = "ORDER  %02d" % order_number
	order_name_label.text = order_name
	reward_label.text = "%d PTS" % reward
	set_status(status)

	for child in ingredients_row.get_children():
		child.queue_free()

	for ingredient_name in ingredients:
		var ingredient_slot := CenterContainer.new()
		ingredient_slot.custom_minimum_size = Vector2(36.0, 42.0)
		ingredient_slot.tooltip_text = ingredient_name.capitalize()
		ingredient_slot.mouse_filter = Control.MOUSE_FILTER_STOP
		var icon := OrderIngredientIcon.new()
		icon.ingredient = ingredient_name
		icon.custom_minimum_size = Vector2(32.0, 32.0)
		ingredient_slot.add_child(icon)
		ingredients_row.add_child(ingredient_slot)


func set_status(status: String) -> void:
	status_label.text = status
