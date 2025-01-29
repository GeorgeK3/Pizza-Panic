extends Sprite2D

@onready var player = get_tree().current_scene.get_node('Player')
var can_fire = true
var firerate
var bullet = preload("res://scenes/enemies/burger_enemies/big_enemy/enemy_bullet.tscn")
var rng = RandomNumberGenerator.new()


func _ready():
	pass

func _process(delta):
	flip_v = true if player.global_position.x < global_position.x else false

	if global_position.distance_to(player.global_position) < 600:
		look_at(Vector2(player.global_position.x,player.global_position.y-30))
		if can_fire:
			$Gunshot.play()
			var bullet_instance = bullet.instantiate()
			bullet_instance.rotation = rotation + rng.randf_range(-0.1, 0.1)
			bullet_instance.global_position = $Marker2D.global_position
			get_parent().add_child(bullet_instance)
			can_fire = false
			firerate = rng.randf_range(2, 4)
			await get_tree().create_timer(firerate).timeout
			can_fire = true
