extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		var direction = (body.global_position - global_position).normalized()
		body.velocity += direction * 500  # Adjust the force magnitude as needed
		if body.name == "Player":
			body.velocity.x += direction.x * 2000 
		print("CharacterBody2D affected: ", body.name)
