extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Enemy.get_node("EnemyGun").queue_free()
	$Enemy.has_gun = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
