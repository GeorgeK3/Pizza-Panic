extends CharacterBody2D

# Variables and exports
@export var SPEED: float
@export var JUMP_VELOCITY: float
@export var MAX_HEALTH: float
@export var DASH_SPEED: float
@export var dash_duration: float
@export var dash_cooldown: float
@export var invicibilty_frames: float
@export var melee_attack_cooldown: float

@onready var melee_weapon = preload("res://scenes/guns/pizza_cutter.tscn")

var current_health: int
var can_doublejump = false
var can_attack = true
var sprite_change_timer = 0
var sprite_index = 0
var invincible = false

var can_dash = true
var dashing = false
var last_direction = 1

var bow_acquired = false
var gun_acquired = false
var bazooka_acquired = false

var bow_equipped = false
var gun_equipped = false
var bazooka_equipped = false

# Signals for weapon handling
signal picked_pizza_gun()
signal drop_pizza_gun()
signal bullets_recieved()

signal picked_pizza_bow()
signal drop_pizza_bow()
signal arrows_recieved()

signal picked_pizza_bazooka()
signal drop_pizza_bazooka()
signal rockets_received()

# Signals for player state
signal damage_received(new_health)
signal health_received(new_health)
signal game_over()

func _ready() -> void:
	# Connect signals for collision areas
	get_node("Feet").connect("area_entered", _stepped_on_enemy)
	get_node("Hitbox").connect("area_entered", _on_hitbox_area_entered)
	get_node("DeathSound").connect("finished", die)

	# Initialize health and emit signal
	current_health = MAX_HEALTH
	health_received.emit(MAX_HEALTH)

	# Load player's acquired weapons from the save file
	_load_player_guns()

func _load_player_guns() -> void:
	# Check if the JSON save file exists
	if FileAccess.file_exists("user://save_file.json"):
		var file = FileAccess.open("user://save_file.json", FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()

		if typeof(data) == TYPE_DICTIONARY and data.has("guns"):
			var guns = data["guns"]

			# Set acquisition and equipment states based on the presence of guns
			if guns.has("pizza_bow"):
				picked_pizza_bow.emit()
				bow_acquired = true
				bow_equipped = true
			if guns.has("pizza_gun"):
				gun_acquired = true
				if not bow_equipped:
					picked_pizza_gun.emit()
					gun_equipped = true
			if guns.has("pizza_bazooka"):
				bazooka_acquired = true
				if not bow_equipped and not gun_equipped:
					picked_pizza_bazooka.emit()
					bazooka_equipped = true

	# Debugging output to verify equipment state
	print("Bow Equipped:", bow_equipped, "| Gun Equipped:", gun_equipped, "| Bazooka Equipped:", bazooka_equipped)

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	handle_jumping()
	handle_movement_and_animations(delta)
	handle_fire_action(delta)
	handle_melee()
	handle_weapon_switching()
	handle_dash()
	move_and_slide()

func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func handle_jumping() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		can_doublejump = true

	if not is_on_floor() and can_doublejump and velocity.y > 0 and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		can_doublejump = false

func handle_movement_and_animations(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if !dashing:
		if direction != 0:
			last_direction = direction
			velocity.x = direction * SPEED
			if is_on_floor():
				$PlayerSprite.play("walking")
			$PlayerSprite.flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if is_on_floor():
				$PlayerSprite.play("idle")

	if velocity.y < 0:
		$PlayerSprite.play("jump")
	elif velocity.y > 0 and not is_on_floor():
		$PlayerSprite.play("fall")

func handle_fire_action(delta: float) -> void:
	if Input.is_action_pressed("fire") and (bow_equipped or gun_equipped or bazooka_equipped) and velocity.x == 0:
		var mouse_position = get_global_mouse_position()
		$PlayerSprite.flip_h = mouse_position.x < position.x

		sprite_change_timer += delta

		match sprite_index:
			0:
				$PlayerSprite.play("aim")
				if sprite_change_timer >= 0.5:
					sprite_change_timer -= 0.5
					if bow_equipped:
						sprite_index = 1
			1:
				$PlayerSprite.play("aim_0")
				if sprite_change_timer >= 0.5:
					sprite_change_timer -= 0.5
					sprite_index = 2
			2:
				$PlayerSprite.play("aim_1")

	if Input.is_action_just_released("fire"):
		sprite_index = 0
		sprite_change_timer = 0
		$PlayerSprite.play("idle")

func handle_melee():
	if Input.is_action_just_pressed("melee_attack") and can_attack:
		can_attack = false
		$CutSound.play()
		var melee_weapon_instance = melee_weapon.instantiate()
		melee_weapon_instance.global_position.x += 20
		melee_weapon_instance.global_position.y -= 30
		melee_weapon_instance.rotation_dir = 1
		if velocity.x < 0:
			melee_weapon_instance.global_position.x -= 40
			melee_weapon_instance.rotation_dir = -1
			melee_weapon_instance.scale.x = -abs(melee_weapon_instance.scale.x)
		add_child(melee_weapon_instance)

		await get_tree().create_timer(melee_attack_cooldown).timeout
		can_attack = true

func handle_weapon_switching() -> void:
	if Input.is_action_just_pressed("pizza_bow") and bow_acquired:
		picked_pizza_bow.emit()
		bow_equipped = true
		gun_equipped = false
		bazooka_equipped = false
	elif Input.is_action_just_pressed("pizza_gun") and gun_acquired:
		picked_pizza_gun.emit()
		gun_equipped = true
		bow_equipped = false
		bazooka_equipped = false
	elif Input.is_action_just_pressed("pizza_bazooka") and bazooka_acquired:
		picked_pizza_bazooka.emit()
		gun_equipped = false
		bow_equipped = false
		bazooka_equipped = true

func handle_dash():
	var direction = Input.get_axis("move_left", "move_right")

	if Input.is_action_just_pressed("dash") and can_dash:
		can_dash = false
		$PlayerSprite.play("dash")
		dashing = true

		velocity.x = last_direction * DASH_SPEED

		await get_tree().create_timer(dash_duration).timeout

		dashing = false

		await get_tree().create_timer(dash_cooldown).timeout
		can_dash = true

func _on_hitbox_area_entered(area: Area2D) -> void:
	if not area.is_in_group("BladeEdge") and not area.is_in_group("PizzaBullets") and not area.is_in_group("EnemyHeadsArea") and not invincible and current_health > 0:
		invincible = true

		current_health -= 1
		get_parent().update_score(-10)
		$Camera2D.start_shake(1, 0.02, 3)
		$Camera2D.start_flash(0.15, 0.25)

		if current_health <= 0:
			current_health = 0
			damage_received.emit(current_health)
			$PlayerSprite.play("dead")
			$DeathSound.play()
			position.y += 45
			set_physics_process(false)
		else:
			damage_received.emit(current_health)

		$AnimationPlayer.play("flash")
		await get_tree().create_timer(invicibilty_frames).timeout
		invincible = false

func _stepped_on_enemy(area: Area2D):
	if area.is_in_group("EnemyHeadsArea"):
		velocity.y = JUMP_VELOCITY

func update_score(score: int) -> void:
	$PlayerHUD/Score.text = "Score: " + str(score)
	
func _on_pizza_bow_sprite__bow_pick_up() -> void:
	picked_pizza_bow.emit()
	bow_acquired = true
	bow_equipped = true
	gun_equipped = false
	bazooka_equipped = false

func _on_pizza_gun_sprite__gun_pick_up() -> void:
	picked_pizza_gun.emit()
	gun_acquired = true
	gun_equipped = true
	bow_equipped = false
	bazooka_equipped = false

func _on_pizza_bazooka_sprite__bazooka_pick_up() -> void:
	picked_pizza_bazooka.emit()
	bazooka_acquired = true
	bazooka_equipped = true
	gun_equipped = false
	bow_equipped = false
	
func _on_quiver__arrow_pick_up() -> void:
	arrows_recieved.emit()
	

func _on_pizza_box__bullets_pick_up() -> void:
	bullets_recieved.emit()


func _on_pizza_heart__heart_pick_up() -> void:
	health_received.emit(1)
	if current_health<4:
		current_health+=1
		
func die():
	game_over.emit()
