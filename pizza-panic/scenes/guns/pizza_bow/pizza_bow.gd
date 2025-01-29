extends AnimatedSprite2D


@export var firerate :float
var max_ammo :int = 1

var current_ammo = max_ammo
var reserve_ammo = 6

signal use_reserve_ammo(new_value)

var can_fire = true
var arrow = preload("res://scenes/guns/pizza_bow/pizza_arrow.tscn")
var hide_pizza_bow = true

const gun_position_x = 30
const DEADZONE: float = 30.0 
var last_target_x: float = 0.0

var fire_pressed_time: float = 0.0
var is_firing: bool = false
var fire_power: int = 0

# Variables for sprite handling
var sprite_change_timer: float = 0.0  # Timer to track sprite changes
var sprite_index: int = 0  # Index for the current sprite

func _ready() -> void:
	get_parent().connect("arrows_recieved",add_ammo)
	get_parent().connect("picked_pizza_bow",_on_player_picked_pizza_bow)
	get_parent().connect("picked_pizza_gun",_on_player_picked_pizza_gun)
	get_parent().connect("picked_pizza_bazooka",_on_player_picked_pizza_gun)
	if hide_pizza_bow:
		hide()
		get_node("PizzaBowHUD").get_node("PizzaArrowDisplay").hide()
		get_node("PizzaBowHUD").get_node("BowAmmoCount").hide()
		set_physics_process(false)
	else:
		animation = "idle"
		set_as_top_level(true)
		get_node("PizzaBowHUD").get_node("PizzaArrowDisplay").show()
		get_node("PizzaBowHUD").get_node("BowAmmoCount").show()
		_refill_ammo()
		set_physics_process(true)
		
	
func _physics_process(delta: float) -> void:
	
	#Position of gun(left/right) regarding the mouse position
	var mouse_x = get_global_mouse_position().x

	# Check if the mouse is outside the deadzone
	if abs(mouse_x - global_position.x) > DEADZONE:
		if mouse_x > global_position.x:
			last_target_x = get_parent().position.x + gun_position_x
		else:
			last_target_x = get_parent().position.x - gun_position_x

	# Smoothly move toward the last target position
	position.x = lerp(position.x, last_target_x, 0.5)
	
	position.y = lerp(position.y,get_parent().position.y-35,0.5)
	var mouse_pos = get_global_mouse_position()
	look_at(mouse_pos)
	
	if Input.is_action_pressed("fire") and can_fire:
		if not is_firing:
			$Bow.play()
			# Start tracking time
			if current_ammo>0:
				animation = "started_charge"
			fire_pressed_time = 0.0
			sprite_change_timer = 0.0  # Reset sprite timer
			sprite_index = 0  # Reset sprite index
			is_firing = true

		# Increment pressed time
		fire_pressed_time += delta
		sprite_change_timer += delta

		# Change sprite every 0.5 seconds
		if sprite_change_timer >= 0.5 and sprite_index<3 and current_ammo>0:
			sprite_change_timer -= 0.5  # Reset timer for next interval
			sprite_index = sprite_index + 1
			if sprite_index == 1:
				animation = "half_charged"
			if sprite_index == 2:
				animation = "full_charged"

		# Calculate fire_power (0 to 1000, max at 1.5 seconds)
		fire_power = int(min(fire_pressed_time / 1.5 * 1000, 1000))  # Clamp to 1000
		

	if Input.is_action_just_released("fire"):
		# Fire a bullet when the fire key is released
		if current_ammo > 0:
			$Arrow.play()
			# Reset sprite when the fire key is released
			animation = "idle"
			sprite_index = 0

			current_ammo -= 1

			var arrow_instance = arrow.instantiate()
			arrow_instance.rotation = rotation
			arrow_instance.global_position = $Marker2D.global_position
			arrow_instance.speed = fire_power
			get_parent().add_child(arrow_instance)
			
			_reload()

			
		# Reset firing state
		fire_power = 0
		is_firing = false


func _reload() -> void:
	if reserve_ammo <= 0:
		return
		
	can_fire = false
	_refill_ammo()
	can_fire = true
	
func _refill_ammo() -> void:
	var ammo_missing = max_ammo - current_ammo
	if reserve_ammo >= ammo_missing:
		reserve_ammo -= ammo_missing
		
		use_reserve_ammo.emit(str(reserve_ammo))
		
		await get_tree().create_timer(firerate).timeout
		
		current_ammo = max_ammo
	else:
		
		reserve_ammo = 0
		
		use_reserve_ammo.emit(str(reserve_ammo))
		
		await get_tree().create_timer(firerate).timeout
		current_ammo += reserve_ammo


func add_ammo():
	reserve_ammo+=3
	use_reserve_ammo.emit(str(reserve_ammo))
		
func _show_bow():
	hide_pizza_bow = false
	animation = "idle"
	show()
	set_as_top_level(true)
	get_node("PizzaBowHUD").get_node("PizzaArrowDisplay").show()
	get_node("PizzaBowHUD").get_node("BowAmmoCount").show()
	_refill_ammo()
	set_physics_process(true)
	
func _hide_bow():
	hide_pizza_bow = true
	hide()
	get_node("PizzaBowHUD").get_node("PizzaArrowDisplay").hide()
	get_node("PizzaBowHUD").get_node("BowAmmoCount").hide()
	set_physics_process(false)


func _on_player_picked_pizza_bow() -> void:
	_show_bow()


func _on_player_picked_pizza_gun() -> void:
	_hide_bow()
