extends CharacterBody2D

@onready var player = get_tree().current_scene.get_node('Player')
@onready var hitbox = $HitBox
@export var hitpoints: int = 12
@export var invincibility_frames:int = 1.5
@onready var pumpkin_rocket_1 = preload("res://scenes/enemies/boss/pumpkin_rocket.tscn")
@onready var pumpkin_rocket_2 = preload("res://scenes/enemies/boss/pumpkin_rocket.tscn")
@onready var pumpkin_rocket_3 = preload("res://scenes/enemies/boss/pumpkin_rocket.tscn")
var invinvible=false
var firerate
var rng = RandomNumberGenerator.new()
var can_fire = true
var score = 1000
var level_node: Node = null  # Reference to the Level node
signal died

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	$TextureRect.hide()
	hitbox.connect("area_entered",_hit)
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if global_position.distance_to(player.global_position) < 1600:
		
		if can_fire:
			can_fire = false
			#$Gunshot.play()
			var pumpkin_rocket_instance_1 = pumpkin_rocket_1.instantiate()
			pumpkin_rocket_instance_1.rotation = rotation + rng.randf_range(-0.1, 0.1)
			pumpkin_rocket_instance_1.global_position = $LaunchSpotUpLeft.global_position
			get_parent().add_child(pumpkin_rocket_instance_1)
			
			firerate = rng.randf_range(0, 1)
			await get_tree().create_timer(firerate).timeout
			
			var pumpkin_rocket_instance_2 = pumpkin_rocket_2.instantiate()
			pumpkin_rocket_instance_2.rotation = rotation + rng.randf_range(-0.1, 0.1)
			pumpkin_rocket_instance_2.global_position = $LaunchSpotCenterLeft.global_position
			get_parent().add_child(pumpkin_rocket_instance_2)
			
			firerate = rng.randf_range(0, 1)
			await get_tree().create_timer(firerate).timeout
			
			var pumpkin_rocket_instance_3 = pumpkin_rocket_3.instantiate()
			pumpkin_rocket_instance_3.rotation = rotation + rng.randf_range(-0.1, 0.1)
			pumpkin_rocket_instance_3.global_position = $LaunchSpotLowerLeft.global_position
			get_parent().add_child(pumpkin_rocket_instance_3)
			
			
			firerate = rng.randf_range(2, 4)
			await get_tree().create_timer(firerate).timeout
			can_fire = true
			
	move_and_slide()
	

func set_level(level: Node) -> void:
	level_node = level
	
func _hit(area :Area2D):
	# Check if the area is part of the "PizzaBullets" group
	print("HIT BY AREA",area.get_groups())
	if !invinvible:
		print("HIT_REGISTERED")
		if area.is_in_group("ExplosionArea"):
			invinvible = true
			$AnimationPlayer.play("flash")
			hitpoints -=5
			$Hurt.play()
			print("Hitpoints left: ",hitpoints)
			if hitpoints <= 0:
				if level_node:
					level_node.update_score(score)
				set_physics_process(false)
				$TextureRect.show()
				$Fireworks.play()
				await get_tree().create_timer(4).timeout
				died.emit()
				queue_free()
				return
			await  get_tree().create_timer(invincibility_frames).timeout
		
		
		elif area.is_in_group("PizzaBullets") or area.is_in_group("BladeEdge") :
			invinvible = true
			$AnimationPlayer.play("flash")
			hitpoints -= 1
			$Hurt.play()
			print("Hitpoints left: ",hitpoints)
			if hitpoints == 0:
				if level_node:
					level_node.update_score(score)
				set_physics_process(false)
				$TextureRect.show()
				$Fireworks.play()
				await get_tree().create_timer(4).timeout
				died.emit()
				queue_free()
				return
			await  get_tree().create_timer(invincibility_frames).timeout
				
		invinvible = false
