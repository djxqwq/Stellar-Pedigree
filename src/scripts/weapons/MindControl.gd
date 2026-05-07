extends "res://src/scripts/player/Weapon.gd"

@export var control_duration: float = 5.0
@export var control_chance: float = 0.2

func _ready():
	weapon_name = "Mind Control"
	damage = 0  # Utility weapon
	fire_rate = 1.0
	bullet_speed = 600.0
	control_duration = 5.0
	control_chance = 0.2
	
	bullet_scene = preload("res://src/scenes/player/Bullet.tscn")

func shoot(position: Vector2, direction: Vector2):
	if not can_shoot():
		return
	
	time_since_last_shot = 0.0
	
	match current_form:
		1:
			_shoot_control_beam(position, direction, control_duration)
		2:
			_shoot_control_beam(position, direction, 10.0)
		3:
			_shoot_explosive_control(position, direction)

func _shoot_control_beam(position: Vector2, direction: Vector2, duration: float):
	var beam = bullet_scene.instantiate()
	get_tree().current_scene.add_child(beam)
	beam.global_position = position
	beam.setup(direction, damage, bullet_speed)
	
	# On hit, attempt to control enemy
	# Will implement when we have enemy system
	# For now, just create visual effect
	var particles = CPUParticles2D.new()
	particles.amount = 10
	particles.lifetime = 1.0
	particles.emitting = true
	particles.color = Color(1.0, 0.5, 1.0, 0.5)
	beam.add_child(particles)

func _shoot_explosive_control(position: Vector2, direction: Vector2):
	# Form 3: Controlled enemies explode when duration ends
	var beam = _shoot_control_beam(position, direction, 10.0)
	
	# Will add explosive effect when control ends
	pass

func _on_evolution():
	match current_form:
		2:
			control_duration = 10.0
		3:
			# Will add explosion effect
			pass
