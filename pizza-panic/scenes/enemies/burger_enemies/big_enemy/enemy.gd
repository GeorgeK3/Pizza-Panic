extends CharacterBody2D

class_name big_burger_enemy

@export var score = 100

@export var SPEED: float
@export var flip = false
@export var hitpoints: int

@onready var wall_raycast = $RayCast2D_Wall
@onready var fall_raycast = $RayCast2D_Fall

@onready var small_enemy = preload("res://scenes/enemies/burger_enemies/small_enemy/small_enemy.tscn")

signal stepped_on_head
var has_gun = true
var level_node: Node = null  # Reference to the Level node

func _ready() -> void:
	$EnemySprite.hide()
	
func _dir_changed():
	flip = !flip
	$EnemySprite.flip_h = flip
	$EnemySprite2.flip_h = flip
	$RayCast2D_Wall.rotation = 180 if flip else 0
	SPEED = -SPEED

	# Flip raycast directions
	wall_raycast.position.x *= -1
	fall_raycast.position.x *= -1

func _physics_process(delta: float) -> void:
	$EnemySprite.play()
	$EnemySprite.animation = "moving"
	$EnemySprite2.play()
	$EnemySprite2.animation = "moving"

	if not is_on_floor():
		velocity += get_gravity() * delta

	# Check for wall or fall
	if _check_fall_or_wall():
		_dir_changed()

	# Update velocity for horizontal movement
	velocity.x = SPEED

	# Apply movement and collision detection
	move_and_slide()

func _check_fall_or_wall() -> bool:
	# Check if wall raycast detects a collision
	var wall_hit = wall_raycast.is_colliding()

	# Check if fall raycast does not detect a collision (indicating a fall)
	var fall_miss = not fall_raycast.is_colliding()

	# Return true if wall is hit or there’s no platform below
	return wall_hit or fall_miss

func set_level(level: Node) -> void:
	level_node = level
	
func _on_hit_box_area_entered(area: Area2D) -> void:
	# Check if the area is part of the "PizzaBullets" group
	if area.is_in_group("PizzaBullets") or area.is_in_group("BladeEdge"):
		
		if area.is_in_group("BladeEdge"):
			_dir_changed()
			
		hitpoints -= 1
		
		$EnemySprite2.hide()
		$EnemySprite.show()
		$AnimationPlayer.play("flash")
		await $AnimationPlayer.animation_finished
		$EnemySprite.hide()
		$EnemySprite2.show()
		
		if hitpoints == 0:
			SPEED=0
			$DeathSound.play()
			if level_node:
				level_node.update_score(score)
			await get_tree().create_timer(0.5).timeout
			queue_free()
			return
		
		

	# Check if the area is part of the "PlayerArea" group
	elif area.is_in_group("PlayerArea"):
		_dir_changed()  # Change direction when hitting the player's area


func _on_head_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea") or  area.is_in_group("PizzaBullets") or area.is_in_group("BladeEdge"):
		if area.is_in_group("PlayerArea"):
			stepped_on_head.emit()
			spawn_small_enemy()
			return
			
		if area.is_in_group("BladeEdge"):
			_dir_changed()
			
		hitpoints -= 1
		
		$EnemySprite2.hide()
		$EnemySprite.show()
		$AnimationPlayer.play("flash")
		await $AnimationPlayer.animation_finished
		$EnemySprite.hide()
		$EnemySprite2.show()
		
		if hitpoints <= 0:
			SPEED=0
			$DeathSound.play()
			if level_node:
				level_node.update_score(score)
			await get_tree().create_timer(0.5).timeout
			queue_free()
			return
			
func spawn_small_enemy():
	# Play the death sound
	$DeathSound.play()

	# Update the score if level_node is valid
	if level_node:
		level_node.update_score(score)

	# Trigger the death animation
	await play_death_animation()

	# Disable collisions and physics processing
	disable_collision()

	# Free the enemy gun if it exists
	if has_gun:
		if $EnemyGun:
			$EnemyGun.queue_free()

	# Spawn a new small enemy
	spawn_new_enemy()


func play_death_animation():
	# Show alternate sprite and play animation
	hide_all_sprites()
	$EnemySprite.show()
	$AnimationPlayer.play("flash")
	await $AnimationPlayer.animation_finished
	hide_all_sprites()


func hide_all_sprites():
	# Hide all sprites related to the enemy
	$EnemySprite.hide()
	$EnemySprite2.hide()


func disable_collision():
	# Disable all collision shapes and stop physics
	self.set_physics_process(false)
	$CollisionShape2D.disabled = true
	$HitBox/CollisionShape2D.disabled = true
	$HeadHitBox/CollisionShape2D.disabled = true


func spawn_new_enemy():
	# Instantiate and add the small enemy
	if small_enemy and level_node:
		var small_enemy_instance = small_enemy.instantiate()
		small_enemy_instance.set_level(level_node)
		add_child(small_enemy_instance)

	
