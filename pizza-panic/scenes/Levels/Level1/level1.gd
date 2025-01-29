extends Node2D

@onready var level = name  # Stores the current level name
var score = 0
var bow_picked = false  # Local variable to track if the bow is picked

# JSON structure to track game data
var file_data = {
	"score": 0,
	"guns": [],
	"levels_beaten": []
}

# Save the game data to the save file
func save():
	var file = FileAccess.open("user://save_file.json", FileAccess.WRITE)
	file.store_line(JSON.stringify(file_data, "\t"))  # Pretty-printed JSON
	file.close()

# Load the game data from the save file
func _load():
	if not FileAccess.file_exists("user://save_file.json"):
		save()
		return
	var file = FileAccess.open("user://save_file.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) == TYPE_DICTIONARY:
		file_data = data
	file.close()

# Initialize the level
func _ready():
	_load()

	# Remove Pizza Bow sprite if already acquired
	if file_data["guns"].has("pizza_bow"):
		$Items/PizzaBowSprite.queue_free()
	else:
		bow_picked = false  # Reset local variable for this playthrough

	# Pass the reference of this level to all enemies
	for enemy in $Enemies.get_children():
		if enemy.has_method("set_level"):
			enemy.set_level(self)
			
	for item in $Items.get_children():
		if item.has_method("set_level"):
			item.set_level(self)

# Function to handle level completion
func beat_level():
	# Print debug information before saving
	print("Data before save:")
	print(JSON.stringify(file_data, "\t"))

	# Update game data
	file_data["score"] += score  # Add level score to total score
	if bow_picked and not file_data["guns"].has("pizza_bow"):
		file_data["guns"].append("pizza_bow")  # Add Pizza Bow to guns
	if not file_data["levels_beaten"].has(level):
		file_data["levels_beaten"].append(level)  # Add level to beaten levels
	
	# Save updated data
	save()

	# Print updated saved data
	if FileAccess.file_exists("user://save_file.json"):
		var file = FileAccess.open("user://save_file.json", FileAccess.READ)
		var saved_data = file.get_as_text()
		print("Data after save:")
		print(saved_data)
		file.close()

	# Transition to the world map scene
	get_tree().change_scene_to_file("res://scenes/world_map/world_map.tscn")


# Handle input events for pause menu
func _input(event):
	if event.is_action_pressed("pause_menu"):
		get_tree().paused = true  # Pause the game

# Function to update the score and reflect it on the Player HUD
func update_score(score_points: int):
	score += score_points
	$Player.update_score(score)  # Update Player's HUD score display

# Triggered when the player collects the level key
func _on_key_key_pick_up() -> void:
	beat_level()

# Triggered when the player picks up the Pizza Bow
func _on_pizza_bow_sprite__bow_pick_up() -> void:
	if not bow_picked:
		bow_picked = true
		print("Pizza Bow Picked")
