extends "res://src/scripts/player/Weapon.gd"

@export var satellite_count: int = 1
@export var orbit_radius: float = 60.0
@export var orbit_speed: float = 2.0

func _ready():
	weapon_name = "Gravity Satellite"
	damage = 30
	fire_rate = 0.8
	bullet_speed = 300.0
	satellite_count = 1
	orbit_radius = 60.0
	orbit_speed = 2.0
	
	bullet_scene = preload("res://src/scenes/player/Bullet.tscn")

func shoot(position: Vector2, direction: Vector2):
	if not can_shoot():
		return
	
	time_since_last_shot = 0.0
	
	match current_form:
		1:
			_summon_satellites(position, satellite_count)
		2:
			_summon_satellites(position, 2)
		3:
			_summon_black_hole_satellites(position, 2)

func _summon_satellites(position: Vector2, count: int):
	for i in range(count):
		var angle = (TAU / count) * i
		_create_satellite(position, angle)

func _create_satellite(position: Vector2, start_angle: float):
	var satellite = Node2D.new()
	satellite.name = "Satellite"
	add_child(satellite)
	
	# Create orbiting behavior
	var tween = create_tween()
	tween.set_loops()
	tween.tween_method(_orbit_satellite.bind(satellite, position), 0.0, TAU, 2.0 / orbit_speed)

func _orbit_satellite(satellite: Node2D, center: Vector2, angle: float):
	var orbit_pos = center + Vector2(orbit_radius, 0).rotated(angle)
	satellite.global_position = orbit_pos
	
	# Check collision with enemies
	# For now, just update position
	pass

func _summon_black_hole_satellites(position: Vector2, count: int):
	# Form 3: Satellites create black holes on explosion
	for i in range(count):
		var angle = (TAU / count) * i
		_create_black_hole_satellite(position, angle)

func _create_black_hole_satellite(position: Vector2, start_angle: float):
	var satellite = Node2D.new()
	satellite.name = "BlackHoleSatellite"
	add_child(satellite)
	
	# Create orbiting behavior with black hole properties
	var tween = create_tween()
	tween.set_loops()
	tween.tween_method(_orbit_black_hole_satellite.bind(satellite, position), 0.0, TAU, 2.0 / orbit_speed)

func _orbit_black_hole_satellite(satellite: Node2D, center: Vector2, angle: float):
	var orbit_pos = center + Vector2(orbit_radius, 0).rotated(angle)
	satellite.global_position = orbit_pos
	
	# Will add black hole gravity effect later
	pass

func _on_evolution():
	match current_form:
		2:
			satellite_count = 2
		3:
			damage = 50
			# Will add black hole explosion
