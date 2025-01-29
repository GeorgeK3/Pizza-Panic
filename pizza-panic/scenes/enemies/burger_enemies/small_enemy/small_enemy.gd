extends CharacterBody2D

class_name small_burger_enemy

@export var score = 50
@export var SPEED: float
@export var flip = false
@export var hitpoints: int
@onready var wall_raycast_right = $RayCast2DWallRight
@onready var wall_raycast_left = $RayCast2DWallLeft
@onready var fall_raycast = $RayCast2DFloor

var level_node: Node = null  # Reference to the Level node
	
func _ready() -> void:
	$Hitbox.connect("area_entered",_on_hitbox_area_entered)
	$HeadHitbox.connect("area_entered",_on_head_hitbox_area_entered)
	$SmallEnemySprite.hide()
	
func _dir_changed():
	if velocity.y ==0:
		flip = !flip
		$SmallEnemySprite.flip_h = flip
		$Sprite2D.flip_h = flip
		SPEED = -SPEED

		fall_raycast.position.x *= -1

func _physics_process(delta: float) -> void:

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
	var wall_hit = wall_raycast_right.is_colliding() or wall_raycast_left.is_colliding()

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
		
		$SmallEnemySprite.show()
		$Sprite2D.hide()
		$AnimationPlayer.play("flash")
		await $AnimationPlayer.animation_finished
		$SmallEnemySprite.hide()
		$Sprite2D.show()
		
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


func _on_head_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerArea") or area.is_in_group("PizzaBullets") or area.is_in_group("BladeEdge"):
		
		hitpoints -= 2
		
		$SmallEnemySprite.show()
		$Sprite2D.hide()
		$AnimationPlayer.play("flash")
		await $AnimationPlayer.animation_finished
		$SmallEnemySprite.hide()
		$Sprite2D.show()
		
		if hitpoints <= 0:
			SPEED=0
			$DeathSound.play()
			if level_node:
				level_node.update_score(score)
			await get_tree().create_timer(0.5).timeout
			queue_free()
			return
		
		if area.is_in_group("BladeEdge"):
			_dir_changed()
	
	
