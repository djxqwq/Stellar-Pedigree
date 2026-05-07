extends "res://src/scripts/player/Weapon.gd"

@export var field_radius: float = 80.0
@export var slow_amount: float = 0.6

func _ready():
	weapon_name = "Time Slow Field"
	damage = 0  # This is a utility weapon
	fire_rate = 0.3
	bullet_speed = 0.0  # Stationary field
	field_radius = 80.0
	slow_amount = 0.6
	
	bullet_scene = preload("res://src/scenes/player/Bullet.tscn")

func shoot(position: Vector2, direction: Vector2):
	if not can_shoot():
		return
	
	time_since_last_shot = 0.0
	
	match current_form:
		1:
			_create_slow_field(position, direction, field_radius, slow_amount)
		2:
			_create_slow_field(position, direction, field_radius * 1.5, 0.8)
		3:
			_create_buff_field(position, direction)

func _create_slow_field(position: Vector2, direction: Vector2, radius: float, slow_factor: float):
	var field = Node2D.new()
	field.name = "TimeSlowField"
	get_tree().current_scene.add_child(field)
	field.global_position = position
	
	# Create slow area
	var slow_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = radius
	collision_shape.shape = circle_shape
	slow_area.add_child(collision_shape)
	field.add_child(slow_area)
	
	# Create visual effect
	var particles = CPUParticles2D.new()
	particles.amount = 20
	particles.lifetime = 1.0
	particles.emitting = true
	particles.color = Color(0.5, 0.5, 1.0, 0.3)
	field.add_child(particles)
	
	# Remove field after duration
	var remove_timer = Timer.new()
	remove_timer.wait_time = 4.0
	remove_timer.one_shot = true
	field.add_child(remove_timer)
	remove_timer.timeout.connect(field.queue_free)

func _create_buff_field(position: Vector2, direction: Vector2):
	# Form 3: Field also buffs allies
	var field = _create_slow_field(position, direction, field_radius * 1.5, 0.8)
	
	# Add buff effect for allies
	# Will implement when we have ally system
	pass

func _on_evolution():
	match current_form:
		2:
			field_radius = 120.0
			slow_amount = 0.8
		3:
			# Will add ally buff effect
			pass
