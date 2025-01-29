extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().get_parent().connect("use_reserve_ammo",_on_pizza_gun_use_reserve_ammo)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pizza_gun_use_reserve_ammo(new_value: String) -> void:
	set_text(str(new_value))
