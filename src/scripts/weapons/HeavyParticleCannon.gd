extends "res://src/scripts/player/Weapon.gd"

@export var explosion_radius: float = 1.0

func _ready():
	weapon_name = "Heavy Particle Cannon"
	damage = 40
	fire_rate = 1.0
	bullet_speed = 400.0
	explosion_radius = 1.0
	
	bullet_scene = preload("res://src/scenes/player/Bullet.tscn")

func shoot(position: Vector2, direction: Vector2):
	if not can_shoot():
		return
	
	time_since_last_shot = 0.0
	
	match current_form:
		1:
			_shoot_single(position, direction)
		2:
			_shoot_explosive(position, direction)
		3:
			_shoot_burning(position, direction)

func _shoot_single(position: Vector2, direction: Vector2):
	var bullet = _create_explosive_bullet(position, direction, explosion_radius)

func _shoot_explosive(position: Vector2, direction: Vector2):
	# Form 2: Larger explosion
	var bullet = _create_explosive_bullet(position, direction, explosion_radius * 2.0)
	damage = 60

func _shoot_burning(position: Vector2, direction: Vector2):
	# Form 3: Explosion + burning ground
	var bullet = _create_explosive_bullet(position, direction, explosion_radius * 2.0)
	damage = 60
	# Will add burning ground effect later

func _create_explosive_bullet(position: Vector2, direction: Vector2, radius: float):
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = position
	bullet.setup(direction, damage, bullet_speed)
	# Will add explosion radius property later
	return bullet

func _on_evolution():
	match current_form:
		2:
			explosion_radius = 2.0
		3:
			damage = 60
			explosion_radius = 2.0
