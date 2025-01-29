extends Sprite2D

var starting_position

func _ready() -> void:
	starting_position = $Area2D/CollisionShape2D.position.x
	
func _process(delta: float) -> void:
	if flip_h:
		$Area2D/CollisionShape2D.position.x = starting_position - 820
	else:
		$Area2D/CollisionShape2D.position.x = starting_position
