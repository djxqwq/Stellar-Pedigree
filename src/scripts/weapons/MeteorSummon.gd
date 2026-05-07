extends "res://src/scripts/player/Weapon.gd"

@export var meteor_count: int = 1
@export var spawn_interval: float = 2.0

func _ready():
	weapon_name = "Meteor Summon"
	damage = 50
	fire_rate = 0.3  # For summoning meteors
	bullet_speed = 0.0  # Meteors fall from above
	meteor_count = 1
	spawn_interval = 2.0
	
	bullet_scene = preload("res://src/scenes/player/Bullet.tscn")

func shoot(position: Vector2, direction: Vector2):
	if not can_shoot():
		return
	
	time_since_last_shot = 0.0
	
	match current_form:
		1:
			_summon_meteors(position, meteor_count)
		2:
			_summon_meteors(position, 2)
		3:
			_summon_shockwave_meteors(position, 2)

func _summon_meteors(position: Vector2, direction: Vector2, count: int):
	for i in range(count):
		# Delay each meteor slightly
		var delay = i * 0.5
		var timer = Timer.new()
		timer.wait_time = delay
		timer.one_shot = true
		add_child(timer)
		timer.timeout.connect(_spawn_meteor.bind(position))
		timer.start()

func _spawn_meteor(target_position: Vector2):
	# Spawn meteor above target position
	var spawn_pos = Vector2(target_position.x, target_position.y - 500)
	var meteor = _create_meteor(spawn_pos, Vector2.DOWN)

func _create_meteor(position: Vector2, direction: Vector2):
	var meteor = bullet_scene.instantiate()
	get_tree().current_scene.add_child(meteor)
	meteor.global_position = position
	meteor.setup(direction, damage, 300.0)  # Fall speed
	return meteor

func _summon_shockwave_meteors(position: Vector2, direction: Vector2, count: int):
	# Form 3: Meteors create shockwaves on impact
	for i in range(count):
		var delay = i * 0.5
		var timer = Timer.new()
		timer.wait_time = delay
		timer.one_shot = true
		add_child(timer)
		timer.timeout.connect(_spawn_shockwave_meteor.bind(position))
		timer.start()

func _spawn_shockwave_meteor(target_position: Vector2):
	var spawn_pos = Vector2(target_position.x, target_position.y - 500)
	var meteor = _create_shockwave_meteor(spawn_pos, Vector2.DOWN)

func _create_shockwave_meteor(position: Vector2, direction: Vector2):
	var meteor = bullet_scene.instantiate()
	get_tree().current_scene.add_child(meteor)
	meteor.global_position = position
	meteor.setup(direction, damage, 300.0)
	# Will add shockwave effect on impact
	return meteor

func _on_evolution():
	match current_form:
		2:
			meteor_count = 2
		3:
			damage = 60
			# Will add shockwave effect
