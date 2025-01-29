extends GridContainer

var AmmoVisualScenes = [preload("res://scenes/ammo_visual_scenes/ammo_visual_scene_1.tscn"), preload("res://scenes/ammo_visual_scenes/ammo_visual_scene_2.tscn"), preload("res://scenes/ammo_visual_scenes/ammo_visual_scene_3.tscn"), preload("res://scenes/ammo_visual_scenes/ammo_visual_scene_4.tscn"), preload("res://scenes/ammo_visual_scenes/ammo_visual_scene_5.tscn"), preload("res://scenes/ammo_visual_scenes/ammo_visual_scene_6.tscn")]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().get_parent().connect("refill_ammo",_on_pizza_gun_refill_ammo)
	get_parent().get_parent().connect("use_ammo",_on_pizza_gun_use_ammo)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pizza_gun_refill_ammo(current_ammo: int) -> void:
	for child in get_children():
		child.queue_free()
	for i in current_ammo:
		var instance = AmmoVisualScenes[i].instantiate()
		add_child(instance)


func _on_pizza_gun_use_ammo() -> void:
	get_child(0).queue_free()
