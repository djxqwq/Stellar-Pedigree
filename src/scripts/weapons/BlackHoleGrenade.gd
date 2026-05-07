extends "res://src/scripts/player/Weapon.gd"

@export var black_hole_duration: float = 3.0
@export var pull_radius: float = 120.0

func _ready():
	weapon_name = "Black Hole Grenade"
	damage = 0  # Damage from black hole effect
	fire_rate = 0.8
	bullet_speed = 400.0
	black_hole_duration = 3.0
	pull_radius = 120.0
	
	bullet_scene = preload("res://src/scenes/player/Bullet.tscn")

func shoot(position: Vector2, direction: Vector2):
	if not can_shoot():
		return
	
	time_since_last_shot = 0.0
	
	match current_form:
		1:
			_throw_grenade(position, direction, black_hole_duration)
		2:
			_throw_grenade(position, direction, 5.0)
		3:
			_throw_explosive_grenade(position, direction)

func _throw_grenade(position: Vector2, direction: Vector2, duration: float):
	var grenade = bullet_scene.instantiate()
	get_tree().current_scene.add_child(grenade)
	grenade.global_position = position
	grenade.setup(direction, damage, bullet_speed)
	
	# Create black hole on impact
	# Will implement when we have collision detection
	_create_black_hole(grenade.global_position, duration)

func _create_black_hole(position: Vector2, duration: float):
	var black_hole = Node2D.new()
	black_hole.name = "BlackHole"
	get_tree().current_scene.add_child(black_hole)
	black_hole.global_position = position
	
	# Create pull effect
	var pull_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = pull_radius
	collision_shape.shape = circle_shape
	pull_area.add_child(collision_shape)
	black_hole.add_child(pull_area)
	
	# Create visual effect
	var particles = CPUParticles2D.new()
	particles.amount = 30
	particles.lifetime = 2.0
	particles.emitting = true
	particles.color = Color(0.2, 0.0, 0.5, 0.8)
	black_hole.add_child(particles)
	
	# Remove black hole after duration
	var remove_timer = Timer.new()
	remove_timer.wait_time = duration
	remove_timer.one_shot = true
	black_hole.add_child(remove_timer)
	remove_timer.timeout.connect(black_hole.queue_free)

func _throw_explosive_grenade(position: Vector2, direction: Vector2):
	# Form 3: Black hole explodes at end
	var grenade = _throw_grenade(position, direction, 5.0)
	
	# Add explosion effect
	# Will implement explosion at end of duration
	pass

func _on_evolution():
	match current_form:
		2:
			black_hole_duration = 5.0
		3:
			# Will add explosion effect
			pass
