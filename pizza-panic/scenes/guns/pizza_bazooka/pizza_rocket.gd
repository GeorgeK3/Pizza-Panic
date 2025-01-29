extends Area2D

var speed: int = 2500  # Initial horizontal speed
var velocity = Vector2()  # Current velocity of the bullet
@onready var explosion_particles = $Explosion  # Reference to the Particles2D node
@onready var collision_shape = $CollisionShape2D  # Reference to the collision shape (for disabling collisions)
@onready var explosion_area = preload("res://scenes/guns/pizza_bazooka/explosion_area.tscn")  # Reference to the Area2D used for proximity detection

func _ready() -> void:
	set_as_top_level(true)
	velocity = Vector2(speed, 0).rotated(rotation)

func _process(delta: float) -> void:
	position += velocity * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	trigger_explosion()

func _on_body_entered(body: Node2D) -> void:
	trigger_explosion()

func trigger_explosion() -> void:
	if not $Sprite2D.visible:
		return  # Prevent triggering the explosion multiple times
	
	velocity = Vector2(0,0)
	# Hide the bullet and disable collisions
	$Sprite2D.hide()
	collision_shape.disabled = true
	monitorable = false
	var explosion_instance = explosion_area.instantiate()
	add_child(explosion_instance)
	explosion_particles.emitting = true
	$ExplosionSound.play()

	# Schedule a timer to turn off the explosion area after the particles finish
	await $ExplosionSound.finished
	explosion_instance.queue_free()
	queue_free()
