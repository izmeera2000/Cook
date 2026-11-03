class_name CookingMinigameUI
extends CanvasLayer

signal action_pressed
signal leave_station_pressed

const METER_WIDTH := 440.0
const BURGER_METER_MAX := 1.2

@onready var interaction_prompt: Label = $Screen/InteractionPrompt
@onready var panel: PanelContainer = $Screen/CookingMinigame
@onready var title_label: Label = $Screen/CookingMinigame/MarginContainer/Layout/Title
@onready var instructions_label: Label = $Screen/CookingMinigame/MarginContainer/Layout/Instructions
@onready var burger_visual: BurgerFlipVisual = $Screen/CookingMinigame/MarginContainer/Layout/BurgerContainer/BurgerVisual
@onready var meter: Control = $Screen/CookingMinigame/MarginContainer/Layout/CookingProgress
@onready var meter_fill: ColorRect = $Screen/CookingMinigame/MarginContainer/Layout/CookingProgress/Fill
@onready var target_zone: ColorRect = $Screen/CookingMinigame/MarginContainer/Layout/CookingProgress/TargetZone
@onready var needle: ColorRect = $Screen/CookingMinigame/MarginContainer/Layout/CookingProgress/Needle
@onready var result_label: Label = $Screen/CookingMinigame/MarginContainer/Layout/Result
@onready var action_button: Button = $Screen/CookingMinigame/MarginContainer/Layout/ActionButton
@onready var grill_hud: Control = $Screen/GrillHUD
@onready var grill_title: Label = $Screen/GrillHUD/Panel/Margin/Layout/Title
@onready var grill_status: Label = $Screen/GrillHUD/Panel/Margin/Layout/Status
@onready var grill_side_one_row: HBoxContainer = $Screen/GrillHUD/Panel/Margin/Layout/SideOne
@onready var grill_side_one: ProgressBar = $Screen/GrillHUD/Panel/Margin/Layout/SideOne/Progress
@onready var grill_side_two_row: HBoxContainer = $Screen/GrillHUD/Panel/Margin/Layout/SideTwo
@onready var grill_side_two: ProgressBar = $Screen/GrillHUD/Panel/Margin/Layout/SideTwo/Progress
@onready var rice_progress: HBoxContainer = $Screen/GrillHUD/Panel/Margin/Layout/RiceProgress
@onready var rice_progress_bar: ProgressBar = $Screen/GrillHUD/Panel/Margin/Layout/RiceProgress/Progress
@onready var prep_progress: HBoxContainer = $Screen/GrillHUD/Panel/Margin/Layout/PrepProgress
@onready var prep_progress_bar: ProgressBar = $Screen/GrillHUD/Panel/Margin/Layout/PrepProgress/Progress
@onready var grill_action_button: Button = $Screen/GrillHUD/ActionButton
@onready var grill_leave_button: Button = $Screen/GrillHUD/LeaveButton


func _ready() -> void:
	action_button.pressed.connect(func() -> void: action_pressed.emit())
	grill_action_button.pressed.connect(func() -> void: action_pressed.emit())
	grill_leave_button.pressed.connect(func() -> void: leave_station_pressed.emit())
	panel.hide()
	grill_hud.hide()
	interaction_prompt.hide()


func set_interaction_prompt(text: String, is_visible: bool) -> void:
	interaction_prompt.text = text
	interaction_prompt.visible = is_visible


func begin_minigame(
	station_name: String,
	is_grill: bool,
	timing_target: float,
	timing_target_width: float,
	ideal_flip_min: float,
	ideal_flip_max: float
) -> void:
	title_label.text = (
		"GRILL  |  BURGER FLIP"
		if is_grill
		else "%s  |  COOKING" % station_name.to_upper()
	)
	instructions_label.text = (
		"Watch the sear. Flip each side in the golden zone, then plate it."
		if is_grill
		else "Press E or click Cook when the marker reaches the green zone."
	)
	target_zone.show()
	action_button.show()
	burger_visual.visible = is_grill
	meter_fill.visible = is_grill
	needle.visible = not is_grill
	if is_grill:
		target_zone.position.x = METER_WIDTH * ideal_flip_min / BURGER_METER_MAX
		target_zone.size.x = METER_WIDTH * (ideal_flip_max - ideal_flip_min) / BURGER_METER_MAX
		target_zone.color = Color("#dca647")
		meter_fill.size.x = 0.0
		meter_fill.color = Color("#d98243")
		burger_visual.set_cook_level(0.0, 0)
		result_label.text = "Side 1: raw — let it sear before flipping."
		action_button.text = "FLIP / INTERACT"
	else:
		target_zone.position.x = METER_WIDTH * (timing_target - timing_target_width * 0.5)
		target_zone.size.x = METER_WIDTH * timing_target_width
		target_zone.color = Color("#53b86c")
		result_label.text = "Hits: 0 / 3"
		action_button.text = "COOK / INTERACT"

	burger_visual.rotation = 0.0
	burger_visual.scale = Vector2.ONE
	panel.show()


func begin_grill_view(simple_mode := false) -> void:
	panel.hide()
	interaction_prompt.hide()
	grill_hud.show()
	grill_action_button.visible = not simple_mode
	grill_title.text = "GRILL STATION"
	grill_side_one_row.show()
	grill_side_two_row.show()
	rice_progress.hide()
	prep_progress.hide()
	grill_status.text = (
		"Cooking both sides automatically."
		if simple_mode
		else "Patty on the grill — wait for a good sear, then flip."
	)
	grill_side_one.value = 0.0
	grill_side_two.value = 0.0
	grill_action_button.text = "FLIP / PLATE  (E)" if not simple_mode else "INTERACT TO RETURN"
	grill_leave_button.text = "LEAVE STATION"
	grill_leave_button.visible = not simple_mode


func set_grill_view(
	status: String, side_doneness: Array[float], active_side: int
) -> void:
	grill_status.text = status
	grill_side_one.value = side_doneness[0] * 100.0
	grill_side_two.value = side_doneness[1] * 100.0
	grill_side_one.modulate = Color("#dca647") if active_side == 0 else Color.WHITE
	grill_side_two.modulate = Color("#dca647") if active_side == 1 else Color.WHITE


func begin_wok_view(simple_mode := false) -> void:
	panel.hide()
	interaction_prompt.hide()
	grill_hud.show()
	grill_title.text = "WOK STATION"
	grill_status.text = "Rice cooking automatically." if simple_mode else (
		"Shake your phone to toss the rice."
		if OS.has_feature("mobile")
		else "Swipe the mouse side-to-side to toss the rice."
	)
	grill_side_one_row.hide()
	grill_side_two_row.hide()
	rice_progress.show()
	prep_progress.hide()
	rice_progress_bar.value = 0.0
	grill_action_button.hide()
	grill_action_button.disabled = false
	grill_action_button.text = "INTERACT TO RETURN"
	grill_leave_button.visible = not simple_mode
	grill_leave_button.text = "LEAVE STATION"


func set_wok_view(progress: float, shakes: int, simple_mode := false) -> void:
	var status := (
		"Cooking automatically"
		if simple_mode
		else ("Phone shakes: %d" % shakes if OS.has_feature("mobile") else "Mouse swipes: %d" % shakes)
	)
	grill_status.text = "%s  |  %d%% cooked" % [status, roundi(progress * 100.0)]
	rice_progress_bar.value = progress * 100.0


func finish_wok_view(shakes: int, simple_mode := false) -> void:
	grill_status.text = (
		"RICE READY!\nCooked automatically."
		if simple_mode
		else "RICE READY!\nWok shakes: %d" % shakes
	)
	rice_progress_bar.value = 100.0
	grill_action_button.disabled = false
	grill_action_button.visible = simple_mode
	grill_leave_button.visible = not simple_mode
	grill_leave_button.text = "RETURN TO KITCHEN"


func begin_prep_view(simple_mode := false) -> void:
	panel.hide()
	interaction_prompt.hide()
	grill_hud.show()
	grill_title.text = "VEGETABLE PREP"
	grill_status.text = "Chopping vegetables automatically." if simple_mode else "Chop the vegetables into pieces."
	grill_side_one_row.hide()
	grill_side_two_row.hide()
	rice_progress.hide()
	prep_progress.show()
	prep_progress_bar.value = 0.0
	grill_action_button.visible = not simple_mode
	grill_action_button.disabled = false
	grill_action_button.text = "CHOP  (E)" if not simple_mode else "INTERACT TO RETURN"
	grill_leave_button.visible = not simple_mode
	grill_leave_button.text = "LEAVE STATION"


func set_prep_view(progress: float, chops: int, simple_mode := false) -> void:
	grill_status.text = (
		"Chopping automatically  |  %d%% prepared" % roundi(progress * 100.0)
		if simple_mode
		else "Chopping vegetables — chop %d  |  %d%% prepared"
		% [chops, roundi(progress * 100.0)]
	)
	prep_progress_bar.value = progress * 100.0


func finish_prep_view(chops: int, simple_mode := false) -> void:
	grill_status.text = "VEGETABLES READY!\nChops: %d" % chops
	prep_progress_bar.value = 100.0
	grill_action_button.show()
	grill_action_button.text = "INTERACT TO RETURN" if simple_mode else "RETURN TO KITCHEN"
	grill_leave_button.hide()


func finish_grill_view(title: String, status: String, side_doneness: Array[float]) -> void:
	grill_status.text = "%s\n%s" % [title, status]
	grill_side_one.value = side_doneness[0] * 100.0
	grill_side_two.value = side_doneness[1] * 100.0
	grill_action_button.show()
	grill_action_button.text = "RETURN TO KITCHEN"
	grill_leave_button.hide()


func close_grill_view() -> void:
	grill_hud.hide()
	grill_leave_button.show()
	grill_action_button.disabled = false
	grill_action_button.show()


func set_interaction_result(text: String) -> void:
	result_label.text = text


func set_timing_cursor(cursor: float) -> void:
	needle.position.x = cursor * METER_WIDTH - needle.size.x * 0.5


func set_burger_state(doneness: float, side: int) -> void:
	burger_visual.set_cook_level(doneness, side)
	meter_fill.size.x = METER_WIDTH * doneness / BURGER_METER_MAX
	meter_fill.color = Color("#d98243").lerp(
		Color("#613522"), doneness / BURGER_METER_MAX
	)


func flip_burger(doneness: float, side: int) -> void:
	burger_visual.set_cook_level(doneness, side)
	burger_visual.play_flip()


func set_finished(title: String, instructions: String, result: String) -> void:
	title_label.text = title
	instructions_label.text = instructions
	result_label.text = result
	action_button.text = "RETURN TO KITCHEN"
	action_button.show()


func close_minigame() -> void:
	panel.hide()
	close_grill_view()
