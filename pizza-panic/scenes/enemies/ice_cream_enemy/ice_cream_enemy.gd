extends CharacterBody2D

var SPEED: float = 300
var flip = false
var hitpoints: int = 4
var score = 150

@onready var wall_raycast = $RayCast2D_Wall
@onready var fall_raycast = $RayCast2D_Fall
@onready var melee_weapon = $IceCreamSpoon

var starting_position 
var level_node: Node = null  # Reference to the Level node

func _ready() -> void:
	$AnimationSprite.hide()
	starting_position = melee_weapon.position.x

func _dir_changed():
	flip = !flip
	$AnimationSprite.flip_h = flip
	$IceCreamSprite.flip_h = flip
	$RayCast2D_Wall.rotation = 180 if flip else 0
	SPEED = -SPEED
	
	if flip:
		melee_weapon.position.x = starting_position-184
		melee_weapon.flip_h = true
	else:
		melee_weapon.position.x = starting_position
		melee_weapon.flip_h = false
	# Flip raycast directions
	wall_raycast.position.x *= -1
	fall_raycast.position.x *= -1


func _physics_process(delta: float) -> void:
	$AnimationSprite.play()
	$AnimationSprite.animation = "default"
	$IceCreamSprite.play()
	$IceCreamSprite.animation = "default"

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
	
func _on_hitbox_area_entered(area: Area2D) -> void:
	# Check if the area is part of the "PizzaBullets" group
	if area.is_in_group("PizzaBullets") or area.is_in_group("BladeEdge"):

		if area.is_in_group("BladeEdge"):
			_dir_changed()

		hitpoints -= 1

		$IceCreamSprite.hide()
		$AnimationSprite.show()
		$AnimationPlayer.play("flash")
		await $AnimationPlayer.animation_finished
		$AnimationSprite.hide()
		$IceCreamSprite.show()

		if hitpoints == 0:
			SPEED = 0
			$DeathSound.play()
			await get_tree().create_timer(0.5).timeout
			if level_node:
				level_node.update_score(score)
			queue_free()
			return

	# Check if the area is part of the "PlayerArea" group
	elif area.is_in_group("PlayerArea"):
		_dir_changed()  # Change direction when hitting the player's area


func _on_head_hit_box_area_entered(area: Area2D) -> void:
		# Check if the area is part of the "PizzaBullets" group
	if area.is_in_group("PlayerArea") or area.is_in_group("PizzaBullets") or area.is_in_group("BladeEdge"):

		hitpoints -= 2

		$IceCreamSprite.hide()
		$AnimationSprite.show()
		$AnimationPlayer.play("flash")
		await $AnimationPlayer.animation_finished
		$AnimationSprite.hide()
		$IceCreamSprite.show()

		if hitpoints <= 0:
			SPEED = 0
			$DeathSound.play()
			await get_tree().create_timer(0.5).timeout
			if level_node:
				level_node.update_score(score)
			queue_free()
			return
