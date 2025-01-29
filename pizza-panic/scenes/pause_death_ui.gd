extends CanvasLayer

func _ready() -> void:
	get_parent().get_node("Player").connect("game_over",_on_player_game_over)	
		
func _on_continue_pressed() -> void:
	get_tree().paused = false
	$Pause/pause_ui.hide()
	
	
func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene() 
	
func _on_menu_pressed() -> void:
	print("pressed")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")

func _input(event):
	if event.is_action_pressed("pause_menu"):  # Αν πατηθεί ESC
			$Pause/pause_ui.show()
			print("pressed esc from ui")

func _on_back_to_map_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/world_map/world_map.tscn")


func _on_map_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/world_map/world_map.tscn")


func _on_player_game_over() -> void:
	$Died/died_ui.show()
