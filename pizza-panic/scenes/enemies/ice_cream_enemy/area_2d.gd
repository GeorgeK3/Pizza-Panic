extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_parent().flip_h:
		position.x = get_parent().position.x-410
	else:
		position.x = get_parent().position.x+410
