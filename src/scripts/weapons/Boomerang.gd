extends "res://src/scripts/player/Weapon.gd"

@export var boomerang_count: int = 1
@export var return_speed: float = 600.0

func _ready():
	weapon_name = "Boomerang"
	damage = 15
	fire_rate = 1.2
	bullet_speed = 500.0
	boomerang_count = 1
	return_speed = 600.0
	
	bullet_scene = preload("res://src/scenes/player/Bullet.tscn")

func shoot(position: Vector2, direction: Vector2):
	if not can_shoot():
		return
	
	time_since_last_shot = 0.0
	
	match current_form:
		1:
			_shoot_single_boomerang(position, direction)
		2:
			_shoot_double_boomerang(position, direction)
		3:
			_shoot_triple_boomerang(position, direction)

func _shoot_single_boomerang(position: Vector2, direction: Vector2):
	var boomerang = _create_boomerang(position, direction)

func _shoot_double_boomerang(position: Vector2, direction: Vector2):
	# Form 2: 2 boomerangs
	boomerang_count = 2
	for i in range(2):
		var angle_offset = (i - 0.5) * 0.2
		var boomerang_dir = direction.rotated(angle_offset)
		_create_boomerang(position, boomerang_dir)

func _shoot_triple_boomerang(position: Vector2, direction: Vector2):
	# Form 3: 3 boomerangs + 50% speed
	boomerang_count = 3
	bullet_speed = 750.0
	for i in range(3):
		var angle_offset = (i - 1) * 0.15
		var boomerang_dir = direction.rotated(angle_offset)
		_create_boomerang(position, boomerang_dir)

func _create_boomerang(position: Vector2, direction: Vector2):
	var boomerang = bullet_scene.instantiate()
	get_tree().current_scene.add_child(boomerang)
	boomerang.global_position = position
	boomerang.setup(direction, damage, bullet_speed)
	# Will add boomerang return behavior later
	return boomerang

func _on_evolution():
	match current_form:
		2:
			boomerang_count = 2
		3:
			boomerang_count = 3
			bullet_speed = 750.0
