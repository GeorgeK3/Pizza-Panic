extends Sprite2D

var target_rotation = 50.0
var elapsed_time = 0.0
var duration = 0.4  # Seconds
var rotation_dir = 1  # 1 for 0 to 50, -1 for 50 to 0
var rotation_speed = 300.0  # Degrees per second

func _ready():
	# Initialize the rotation based on the direction
	if rotation_dir == 1:
		rotation_degrees = -30
	else:
		rotation_degrees = target_rotation

func _process(delta):
	if elapsed_time < duration:
		elapsed_time += delta
		# Calculate how much to rotate based on the direction
		var rotation_delta = rotation_speed * delta * rotation_dir
		rotation_degrees += rotation_delta

		# Clamp the rotation to the target value based on direction
		if rotation_dir == 1 and rotation_degrees >= target_rotation:
			rotation_degrees = target_rotation
			queue_free()
		elif rotation_dir == -1 and rotation_degrees <= -30:
			rotation_degrees = 0
			queue_free()
	else:
		queue_free()
