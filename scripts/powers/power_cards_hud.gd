class_name PowerCardsHUD
extends CanvasLayer

signal card_activated(index: int)

var _cards: Array[PowerCard] = []
var _buttons: Array[Button] = []
@onready var _card_layout: HBoxContainer = $Screen/PowerCardsPanel/Layout/CardLayout
@onready var _close_button: Button = $Screen/PowerCardsPanel/Layout/Header/CloseButton


func _ready() -> void:
	_close_button.pressed.connect(close_cards)


func open_cards() -> void:
	show()


func close_cards() -> void:
	hide()


func set_cards(cards: Array[PowerCard]) -> void:
	_cards.clear()
	_buttons.clear()
	for child in _card_layout.get_children():
		child.queue_free()

	for index in range(cards.size()):
		var card := cards[index]
		_cards.append(card)
		var button := Button.new()
		button.custom_minimum_size = Vector2(185.0, 104.0)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.add_theme_font_size_override("font_size", 17)
		button.tooltip_text = card.description
		button.pressed.connect(_on_card_pressed.bind(index))
		_card_layout.add_child(button)
		_buttons.append(button)


func set_card_state(
	cooldowns: Array[float], active_card_index: int, active_duration_remaining: float
) -> void:
	for index in range(_buttons.size()):
		var cooldown := cooldowns[index] if index < cooldowns.size() else 0.0
		var status := "READY"
		if index == active_card_index:
			status = "ACTIVE  %.1fs" % active_duration_remaining
		elif cooldown > 0.0:
			status = "COOLDOWN  %.1fs" % cooldown

		_buttons[index].text = "%d   %s\n%s\n%s" % [
			index + 1, _cards[index].display_name, _cards[index].description, status
		]
		_buttons[index].disabled = cooldown > 0.0


func _on_card_pressed(index: int) -> void:
	card_activated.emit(index)
