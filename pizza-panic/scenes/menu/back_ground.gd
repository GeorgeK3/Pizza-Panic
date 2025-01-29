extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Character.animation = "idle"
	$Character.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _mouse_entered() -> void:
	pass # Replace with function body.
