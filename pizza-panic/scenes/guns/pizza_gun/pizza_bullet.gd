extends Area2D

var speed:int = 2000 # Initial horizontal speed
var velocity = Vector2()  # Current velocity of the bullet

func _ready() -> void:
	set_as_top_level(true)
	# Initialize velocity to move to the right, rotated by the bullet's angle
	velocity = Vector2(speed, 0).rotated(rotation)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta

# Remove the bullet when it exits the screen
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

# Remove the bullet when it hits another body
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea"):
		return
	queue_free()


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("PlayerArea"):
		return
	queue_free()
