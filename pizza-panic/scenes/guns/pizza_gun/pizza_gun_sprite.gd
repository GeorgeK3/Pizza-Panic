extends Sprite2D

var amplitude: float = 20
var original_position: Vector2
var up = -1
var picked = false
var level_node: Node = null  # Reference to the Level node
var score = 70

signal _gun_pick_up


func _ready():
	get_node("PickUpArea").connect("area_entered",_on_pick_up_area_area_entered)
	original_position = position

func _process(delta):
	if abs(original_position.y-position.y)>=amplitude:
		up *= -1
	position.y = position.y + up*0.9

func set_level(level: Node) -> void:
	level_node = level

func _on_pick_up_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea") and !picked:
		picked = true
		$PickUpSound.play()
		hide()
		if level_node:
			level_node.update_score(score)			
		await $PickUpSound.finished
		_gun_pick_up.emit()
		queue_free()
	else:
		return
