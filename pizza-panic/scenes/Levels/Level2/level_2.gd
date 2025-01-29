extends Node2D

var score = 0  # Local score for the current level
var gun_picked = false  # Track if the gun is picked locally

# JSON structure to track game data across levels
var file_data = {
	"score": 0,
	"guns": [],
	"levels_beaten": []
}

func save():
	var file = FileAccess.open("user://save_file.json", FileAccess.WRITE)
	file.store_line(JSON.stringify(file_data, "\t"))  # Save with formatting
	file.close()

func _load():
	if not FileAccess.file_exists("user://save_file.json"):
		save()  # Initialize file if it doesn't exist
		return
	var file = FileAccess.open("user://save_file.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) == TYPE_DICTIONARY:
		file_data = data  # Load data only if valid
	file.close()

func _ready() -> void:
	_load()

	# Check if the pizza gun is already acquired
	if file_data["guns"].has("pizza_gun"):
		$Items/PizzaGunSprite.queue_free()  # Remove gun sprite if already picked
	else:
		gun_picked = false  # Reset local tracking for this playthrough
	
	# Set up enemies and link them to this level
	for enemy in $Enemies.get_children():
		if enemy.has_method("set_level"):
			enemy.set_level(self)
	
	for item in $Items.get_children():
		if item.has_method("set_level"):
			item.set_level(self)

func _input(event):
	if event.is_action_pressed("pause_menu"):
		get_tree().paused = true  # Pause the game
		
func update_score(score_points: int):
	# Update local level score and notify player
	score += score_points
	$Player.update_score(score)

func _on_pizza_gun_sprite__gun_pick_up() -> void:
	# Track gun pickup and update file_data if necessary
	if not gun_picked:
		gun_picked = true
		print("Pizza Gun Picked")
		if not file_data["guns"].has("pizza_gun"):
			file_data["guns"].append("pizza_gun")
			save()  # Save the gun acquisition

func beat_level():
	# Print debug info before updating game data
	print("Data before save:")
	print(JSON.stringify(file_data, "\t"))

	# Update game data for beaten level
	var level = name  # Use the current level's node name
	if not file_data["levels_beaten"].has(level):
		file_data["levels_beaten"].append(level)  # Mark level as beaten
	file_data["score"] += score  # Add local score to total score

	# Save game progress
	save()

	# Debug info after saving
	print("Data after save:")
	print(JSON.stringify(file_data, "\t"))

	# Load the world map scene after beating the level
	print("Level Beaten. Loading next scene...")
	get_tree().change_scene_to_file("res://scenes/world_map/world_map.tscn")

func _on_key_key_pick_up() -> void:
	# Trigger level completion when a key is picked
	beat_level()
