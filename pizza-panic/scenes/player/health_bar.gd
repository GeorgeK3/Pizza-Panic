extends GridContainer

var HealthVisualScene := preload("res://scenes/player/health_visual_scene.tscn")
signal health_depleted
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().get_parent().connect("damage_received",_on_player_damage_received)
	get_parent().get_parent().connect("health_received",_on_player_health_received)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_health_received(new_health: int) -> void:
	for health in new_health:
		if get_child_count() < 4:
			var instance = HealthVisualScene.instantiate()
			add_child(instance)
		else:
			return
	


func _on_player_damage_received(new_health: int) -> void:
	for health in new_health:
		get_child(-1).queue_free()
	if new_health ==0:
		if get_child_count()>0:
			get_child(-1).queue_free()
