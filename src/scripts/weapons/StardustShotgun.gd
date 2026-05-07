extends "res://src/scripts/player/Weapon.gd"

@export var pellet_count: int = 5
@export var spread_angle: float = 30.0

func _ready():
	weapon_name = "Stardust Shotgun"
	damage = 8
	fire_rate = 1.5
	bullet_speed = 600.0
	pellet_count = 5
	spread_angle = 30.0
	
	bullet_scene = preload("res://src/scenes/player/Bullet.tscn")

func shoot(position: Vector2, direction: Vector2):
	if not can_shoot():
		return
	
	time_since_last_shot = 0.0
	
	match current_form:
		1:
			_shoot_spread(position, direction, pellet_count)
		2:
			_shoot_wide(position, direction)
		3:
			_shoot_360(position, direction)

func _shoot_spread(position: Vector2, direction: Vector2, pellets: int):
	var angle_step = spread_angle / (pellets - 1)
	var start_angle = -spread_angle / 2
	
	for i in range(pellets):
		var angle = start_angle + i * angle_step
		var pellet_dir = direction.rotated(deg_to_rad(angle))
		_create_pellet(position, pellet_dir)

func _shoot_wide(position: Vector2, direction: Vector2):
	# Form 2: More pellets, narrower spread
	pellet_count = 8
	spread_angle = 20.0
	_shoot_spread(position, direction, pellet_count)

func _shoot_360(position: Vector2, direction: Vector2):
	# Form 3: 360 degree shot
	pellet_count = 12
	var angle_step = 360.0 / pellet_count
	
	for i in range(pellet_count):
		var angle = i * angle_step
		var pellet_dir = direction.rotated(deg_to_rad(angle))
		_create_pellet(position, pellet_dir)

func _create_pellet(position: Vector2, direction: Vector2):
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = position
	bullet.setup(direction, damage, bullet_speed)

func _on_evolution():
	match current_form:
		2:
			pellet_count = 8
			spread_angle = 20.0
		3:
			pellet_count = 12
			damage = 10
