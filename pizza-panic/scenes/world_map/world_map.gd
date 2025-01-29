extends Node2D

@onready var player = $Player
@onready var level_nodes = {
	1: $LevelsHolder/Level1,
	2: $LevelsHolder/Level2,
	3: $LevelsHolder/Level3,
	4: $LevelsHolder/Level4
}

var player_level = 1
var target_position = Vector2() # Current target position
var is_moving = false
var move_speed = 700 # Speed of the transition
var move_queue = [] # Queue of positions for multi-step movement

var unlocked_levels = [1] # Tracks levels the player can access
var levels_beaten = [] # Tracks levels completed (from save file)
var save_file_path = "user://save_file.json"
var save_data = { "score": 0, "guns": [], "levels_beaten": [] }

func _ready() -> void:
	load_save_file()
	setup_game_state()
	player.play("idle")
	player.position = level_nodes[player_level].position - Vector2(0, 100)

func _process(delta: float) -> void:
	# Movement logic
	if Input.is_action_just_pressed("ui_up") and player_level == 1 and not is_moving and can_move_to_level(2):
		queue_movement([Vector2(player.position.x, level_nodes[2].position.y - 100)])
		player_level = 2

	if Input.is_action_just_pressed("ui_down") and player_level == 2 and not is_moving and can_move_to_level(1):
		queue_movement([Vector2(player.position.x, level_nodes[1].position.y - 100)])
		player_level = 1

	if Input.is_action_just_pressed("ui_right") and player_level == 2 and not is_moving and can_move_to_level(3):
		queue_movement([
			Vector2(-600, player.position.y),                # Move X to -600
			Vector2(-600, 130),                             # Move Y to 130
			Vector2(-108, 130),                             # Move X to -108
			Vector2(-108, level_nodes[3].position.y - 100)  # Move Y to Level 3
		])
		player_level = 3

	if Input.is_action_just_pressed("ui_left") and player_level == 3 and not is_moving and can_move_to_level(2):
		queue_movement([
			Vector2(-108, player.position.y),                # Move X to -108
			Vector2(-108, 130),                              # Move Y to 130
			Vector2(-600, 130),                              # Move X to -600
			Vector2(-600, level_nodes[2].position.y - 100),  # Move Y to Level 2
			Vector2(level_nodes[2].position.x, level_nodes[2].position.y - 100)
		])
		player_level = 2

	if Input.is_action_just_pressed("ui_right") and player_level == 3 and not is_moving and can_move_to_level(4):
		queue_movement([
			Vector2(65, player.position.y),                 # Move X to 65
			Vector2(65, 135),                               # Move Y to 135
			Vector2(655, 135),                              # Move X to 655
			Vector2(655, level_nodes[4].position.y - 100)   # Move Y to Level 4
		])
		player_level = 4

	if Input.is_action_just_pressed("ui_left") and player_level == 4 and not is_moving and can_move_to_level(3):
		queue_movement([
			Vector2(655, player.position.y),                # Move X to 655
			Vector2(655, 135),                              # Move Y to 135
			Vector2(65, 135),                               # Move X to 65
			Vector2(65, level_nodes[3].position.y - 100),   # Move Y to Level 3
			Vector2(level_nodes[3].position.x, level_nodes[3].position.y - 100)
		])
		player_level = 3

	# Enter level logic
	if Input.is_action_just_pressed("ui_accept"):
		enter_level(player_level)

	# Update movement
	if is_moving:
		update_movement(delta)

# Queue multiple positions for sequential movement
func queue_movement(positions: Array) -> void:
	move_queue = positions
	start_next_movement()

# Start the next movement in the queue
func start_next_movement() -> void:
	if move_queue.size() > 0:
		target_position = move_queue.pop_front()
		is_moving = true
	else:
		is_moving = false # Stop movement if queue is empty

# Update movement logic
func update_movement(delta: float) -> void:
	var difference = target_position - player.position

	# Move incrementally towards the target position
	if difference.length() > 10: # Stop moving when close enough
		player.position += difference.normalized() * move_speed * delta
	else:
		# Snap to target and start next movement
		player.position = target_position
		is_moving = false
		start_next_movement()

# Load save data from file
func load_save_file() -> void:
	if FileAccess.file_exists(save_file_path):
		var file = FileAccess.open(save_file_path, FileAccess.READ)
		save_data = JSON.parse_string(file.get_as_text())
		file.close()
		
		if typeof(save_data) == TYPE_DICTIONARY and save_data.has("levels_beaten"):
			for level_name in save_data["levels_beaten"]:
				print(level_name)
				var level_id = int(level_name.right(level_name.length()-5))
				if level_id not in levels_beaten:
					levels_beaten.append(level_id)
					if level_id+1 not in unlocked_levels:
						unlocked_levels.append(level_id+1)
	else:
		print("Save file not found. Starting fresh.")

# Setup game state based on beaten levels
func setup_game_state() -> void:
	for level_id in unlocked_levels:
		if level_nodes.has(level_id):
			var level_node = level_nodes[level_id]
			if level_node.has_node("Locked"):
				level_node.get_node("Locked").queue_free()

	for level_id in levels_beaten:
		if level_nodes.has(level_id):
			var level_node = level_nodes[level_id]
			if level_node.has_node("NotBeaten"):
				level_node.get_node("NotBeaten").queue_free()
				
	# Update score display
	var saved_score = save_data.get("score", 0)
	$Player/Camera2D/Score.text = "Total Score: " + str(saved_score)

# Enter a specified level
func enter_level(level_id: int) -> void:
	if level_id in unlocked_levels: # Level 1 is always enterable
		var level_scene_path = "res://scenes/Levels/Level" + str(level_id) + "/Level" + str(level_id) + ".tscn"
		if ResourceLoader.exists(level_scene_path):
			get_tree().change_scene_to_file(level_scene_path)
		else:
			push_error("Level scene not found: " + level_scene_path)

# Check if movement to the specified level is allowed
func can_move_to_level(level_id: int) -> bool:
	return level_id == 1 or (level_id - 1) in levels_beaten
