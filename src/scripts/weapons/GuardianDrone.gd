extends "res://src/scripts/player/Weapon.gd"

@export var drone_count: int = 2
@export var drone_fire_rate: float = 2.0

func _ready():
	weapon_name = "Guardian Drone"
	damage = 8
	fire_rate = 0.5  # This is for drone spawning, not shooting
	bullet_speed = 800.0
	drone_count = 2
	drone_fire_rate = 2.0
	
	bullet_scene = preload("res://src/scenes/player/Bullet.tscn")

func shoot(position: Vector2, direction: Vector2):
	# This weapon summons drones that auto-shoot
	if not can_shoot():
		return
	
	time_since_last_shot = 0.0
	
	match current_form:
		1:
			_summon_drones(position, drone_count)
		2:
			_summon_drones(position, 4)
		3:
			_summon_drones(position, 6)

func _summon_drones(position: Vector2, count: int):
	for i in range(count):
		var angle = (360.0 / count) * i
		var drone_pos = position + Vector2(80, 0).rotated(deg_to_rad(angle))
		_create_drone(drone_pos)

func _create_drone(position: Vector2):
	var drone = Node2D.new()
	drone.name = "Drone"
	add_child(drone)
	drone.global_position = position
	
	# Add shooting behavior to drone
	var timer = Timer.new()
	timer.wait_time = 1.0 / drone_fire_rate
	timer.autostart = true
	timer.timeout.connect(_drone_shoot.bind(drone))
	drone.add_child(timer)

func _drone_shoot(drone):
	# Find nearest enemy and shoot
	# For now, just shoot in random direction
	var direction = Vector2.RIGHT.rotated(randf() * TAU)
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = drone.global_position
	bullet.setup(direction, damage, bullet_speed)

func _on_evolution():
	match current_form:
		2:
			drone_count = 4
		3:
			drone_count = 6
			drone_fire_rate = 4.0
