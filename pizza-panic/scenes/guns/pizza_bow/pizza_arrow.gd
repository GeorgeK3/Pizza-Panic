extends Area2D

var speed:int =0 # Initial horizontal speed
var velocity = Vector2()  # Current velocity of the bullet

func _ready() -> void:
	set_as_top_level(true)
	# Initialize velocity to move to the right, rotated by the bullet's angle
	velocity = Vector2(speed, 0).rotated(rotation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Apply gravity to the vertical component of velocity
	velocity.y += gravity* delta

	# Update the position based on velocity
	position += velocity * delta

	# Rotate the bullet to match its velocity direction (arrow effect)
	rotation = velocity.angle()

# Remove the bullet when it exits the screen
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	return

# Remove the bullet when it hits another body
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		return
	queue_free()


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("PlayerArea"):
		return
	queue_free()
