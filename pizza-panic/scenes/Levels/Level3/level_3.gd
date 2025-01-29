extends Node2D

var score = 0

# JSON structure to track game data
var file_data = {
	"score": 0,
	"guns": [],
	"levels_beaten": []
}

func save():
	var file = FileAccess.open("user://save_file.json", FileAccess.WRITE)
	file.store_line(JSON.stringify(file_data, "\t"))  # Pretty-printed JSON
	file.close()

func _load():
	if not FileAccess.file_exists("user://save_file.json"):
		save()
		return
	var file = FileAccess.open("user://save_file.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) == TYPE_DICTIONARY:
		file_data = data
	file.close()

func _ready():
	_load()
		
	for enemy in $Enemies.get_children():
		if enemy.has_method("set_level"):
			enemy.set_level(self)
	
	for item in $Items.get_children():
		if item.has_method("set_level"):
			item.set_level(self)

func update_score(score_points: int):
	score += score_points
	$Player.update_score(score)

func _game_over():
	print("Game Over")
	save()  # Save data on game over

func _on_player_game_over() -> void:
	_game_over()

func beat_level():
	# Calculate the score based on damage received
	var damage_received = 4 - $Player.current_health
	var final_score = score - (damage_received * 10)

	# Update total score
	file_data["score"] += final_score

	# Add beaten level to file_data if not already added
	if not file_data["levels_beaten"].has(name):
		file_data["levels_beaten"].append(name)

	# Save the updated game data
	save()

	# Print debug information
	print("Level Beaten:")
	print("Damage Received: ", damage_received)
	print("Final Score: ", final_score)
	print("Updated Game Data:")
	print(JSON.stringify(file_data, "\t"))

	# Load the next scene
	get_tree().change_scene_to_file("res://scenes/world_map/world_map.tscn")

func _on_key_key_pick_up() -> void:
	# Unified function to trigger `beat_level`
	beat_level()

func _input(event):
	if event.is_action_pressed("pause_menu"):  # Pause menu triggered by ESC
		get_tree().paused = true
