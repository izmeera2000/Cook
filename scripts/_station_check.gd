extends SceneTree


func _initialize() -> void:
	call_deferred("_run_check")


func _run_check() -> void:
	var kitchen_map: Node3D = load("res://scenes/level/kitchen_map.tscn").instantiate()
	root.add_child(kitchen_map)
	await process_frame

	var stations := get_nodes_in_group("kitchen_stations")
	if stations.size() != 7:
		push_error("Expected all seven kitchen map interaction stations.")
		quit(1)
		return

	for station_node in stations:
		var station := station_node as KitchenStation
		if not station or not station.interaction_camera:
			push_error("Kitchen station is missing its camera marker.")
			quit(1)
			return

	var player: Character = load("res://scenes/level/player.tscn").instantiate()
	player.name = "1"
	root.add_child(player)
	await process_frame

	var camera_rig: SpringArmCharacter = player.get_node("SpringArmOffset")
	var station := stations[0] as KitchenStation
	camera_rig.enter_station_view(station.interaction_camera.global_transform)
	await process_frame
	if not camera_rig.is_first_person:
		push_error("Station view did not switch to first person.")
		quit(1)
		return

	camera_rig.exit_station_view()
	if camera_rig.is_first_person:
		push_error("Station view did not restore the overhead camera.")
		quit(1)
		return

	print("All kitchen map stations and first-person camera switching passed.")
	quit()
