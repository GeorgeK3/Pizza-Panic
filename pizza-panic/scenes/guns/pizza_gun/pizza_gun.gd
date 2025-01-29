extends Sprite2D

@export var fire_power: int
@export var firerate :float
@export var reload_timer :float
@export var max_ammo :int

@onready var reloading_bar = $PizzaGunHUD/ReloadingBar  # Reference to ProgressBar node

var current_ammo = max_ammo
var reserve_ammo = 12

signal use_ammo
signal use_reserve_ammo(new_value)
signal refill_ammo(current_ammo)

var can_fire = true
var reloading = false
var bullet = preload("res://scenes/guns/pizza_gun/pizza_bullet.tscn")
var hide_pizza_gun = true



func _ready() -> void:
	get_parent().connect("bullets_recieved",add_ammo)
	get_parent().connect("picked_pizza_bow",_on_player_picked_pizza_bow)
	get_parent().connect("picked_pizza_bazooka",_on_player_picked_pizza_bow)
	get_parent().connect("picked_pizza_gun",_on_player_picked_pizza_gun)
	reloading_bar.hide()
	if hide_pizza_gun:
		hide()
		get_node("PizzaGunHUD").get_node("AmmoDisplay").hide()
		get_node("PizzaGunHUD").get_node("GunAmmoCount").hide()
		set_physics_process(false)
	else:
		set_as_top_level(true)
		get_node("PizzaGunHUD").get_node("AmmoDisplay").show()
		get_node("PizzaGunHUD").get_node("GunAmmoCount").show()
		_refill_ammo()
		set_physics_process(true)
		
	
func _physics_process(delta: float) -> void:
	
	#Position of gun(left/right) regarding the mouse position
	var mouse_x = get_global_mouse_position().x
	# Smoothly move toward the last target position
	position.x = lerp(position.x, get_parent().position.x, 0.5)
	
	position.y = lerp(position.y,get_parent().position.y-35,0.5)
	var mouse_pos = get_global_mouse_position()
	look_at(mouse_pos)
	flip_v = true if mouse_pos.x < global_position.x else false
	

	if Input.is_action_pressed("fire") and can_fire and !reloading:
		
		if current_ammo > 0 :

			current_ammo -= 1

			var bullet_instance = bullet.instantiate()
			bullet_instance.rotation = rotation
			bullet_instance.global_position = $Marker2D.global_position
			bullet_instance.speed = fire_power
			$Shoot.play()
			get_parent().add_child(bullet_instance)

			use_ammo.emit()

			# Start cooldown
			can_fire = false
			await get_tree().create_timer(firerate).timeout
			can_fire = true
		else:
			_reload()

			
	if Input.is_action_just_pressed("reload") and current_ammo!= max_ammo:
		_reload()

func _reload() -> void:
	reloading = true
	if reserve_ammo <= 0:
		reloading = false
		return
		
	# Show and reset the reloading bar
	reloading_bar.value = 0
	# Start a tween for the reloading bar
	var tween = reloading_bar.create_tween()
	reloading_bar.show()
	tween.tween_property(
		reloading_bar,
		"value",
		100,
		reload_timer
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	await get_tree().create_timer(reload_timer).timeout
		
	_refill_ammo()

	# Hide the reloading bar after completion
	reloading_bar.hide()
	reloading = false
	
func _refill_ammo() -> void:
	var ammo_missing = max_ammo - current_ammo
	if reserve_ammo >= ammo_missing:
		reserve_ammo -= ammo_missing
		
		use_reserve_ammo.emit(str(reserve_ammo))
		
		current_ammo = max_ammo
	else:
		current_ammo += reserve_ammo
		reserve_ammo = 0
		
		use_reserve_ammo.emit(str(reserve_ammo))
		
	refill_ammo.emit(current_ammo)

func add_ammo():
	reserve_ammo+=6
	use_reserve_ammo.emit(str(reserve_ammo))
	
func _show_gun():
	hide_pizza_gun = false
	show()
	set_as_top_level(true)
	get_node("PizzaGunHUD").get_node("AmmoDisplay").show()
	get_node("PizzaGunHUD").get_node("GunAmmoCount").show()
	_refill_ammo()
	set_physics_process(true)
	
func _hide_gun():
	hide_pizza_gun = true
	hide()
	get_node("PizzaGunHUD").get_node("AmmoDisplay").hide()
	get_node("PizzaGunHUD").get_node("GunAmmoCount").hide()
	set_physics_process(false)
	

func _on_player_picked_pizza_gun() -> void:
	_show_gun()


func _on_player_picked_pizza_bow() -> void:
	_hide_gun()
