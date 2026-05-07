extends "res://src/scripts/player/Weapon.gd"

@export var bullet_count: int = 1
@export var spread_angle: float = 0.0

func _ready():
	weapon_name = "Pulse Rifle"
	damage = 12
	fire_rate = 3.0
	bullet_speed = 800.0
	
	print("PulseRifle ready - Fire rate: ", fire_rate)
	
	# Create bullet scene
	bullet_scene = preload("res://src/scenes/player/Bullet.tscn")

func shoot(position: Vector2, direction: Vector2):
	print("Weapon shoot called")
	if not can_shoot():
		print("Cannot shoot - cooldown")
		return
	
	print("Shooting bullet")
	time_since_last_shot = 0.0
	
	match current_form:
		1:
			_shoot_single(position, direction)
		2:
			_shoot_double(position, direction)
		3:
			_shoot_triple(position, direction)

func _shoot_single(position: Vector2, direction: Vector2):
	print("Creating single bullet")
	_create_bullet(position, direction)

func _shoot_double(position: Vector2, direction: Vector2):
	# Form 2: Double shot with higher fire rate
	for i in range(2):
		var angle_offset = (i - 0.5) * 0.1
		var rotated_dir = direction.rotated(angle_offset)
		_create_bullet(position, rotated_dir)

func _shoot_triple(position: Vector2, direction: Vector2):
	# Form 3: Triple shot with penetration
	for i in range(3):
		var angle_offset = (i - 1) * 0.15
		var rotated_dir = direction.rotated(angle_offset)
		var bullet = _create_bullet_with_penetration(position, rotated_dir, 2)

func _create_bullet_with_penetration(position: Vector2, direction: Vector2, pen_count: int):
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = position
	bullet.setup(direction, damage, bullet_speed)
	bullet.penetration = pen_count
	return bullet

func _on_evolution():
	match current_form:
		2:
			fire_rate = 4.0
		3:
			damage = 15
			fire_rate = 5.0
