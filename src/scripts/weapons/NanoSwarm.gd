extends "res://src/scripts/player/Weapon.gd"

@export var swarm_duration: float = 5.0
@export var damage_interval: float = 0.5

func _ready():
	weapon_name = "Nano Swarm"
	damage = 5
	fire_rate = 1.0
	bullet_speed = 200.0
	swarm_duration = 5.0
	damage_interval = 0.5
	
	bullet_scene = preload("res://src/scenes/player/Bullet.tscn")

func shoot(position: Vector2, direction: Vector2):
	if not can_shoot():
		return
	
	time_since_last_shot = 0.0
	
	match current_form:
		1:
			_release_swarm(position, direction, swarm_duration)
		2:
			_release_swarm(position, direction, 8.0)
		3:
			_release_splitting_swarm(position, direction)

func _release_swarm(position: Vector2, direction: Vector2, duration: float):
	var swarm = Node2D.new()
	swarm.name = "NanoSwarm"
	get_tree().current_scene.add_child(swarm)
	swarm.global_position = position
	
	# Create damage timer
	var damage_timer = Timer.new()
	damage_timer.wait_time = damage_interval
	damage_timer.autostart = true
	swarm.add_child(damage_timer)
	
	var total_damage = 0
	damage_timer.timeout.connect(_swarm_deal_damage.bind(swarm, damage_timer))
	
	# Remove swarm after duration
	var remove_timer = Timer.new()
	remove_timer.wait_time = duration
	remove_timer.one_shot = true
	swarm.add_child(remove_timer)
	remove_timer.timeout.connect(swarm.queue_free)

func _swarm_deal_damage(swarm: Node2D, timer: Timer):
	# Deal damage to enemies in swarm area
	# For now, just create visual effect
	var particles = CPUParticles2D.new()
	particles.amount = 10
	particles.lifetime = 1.0
	particles.emitting = true
	swarm.add_child(particles)

func _release_splitting_swarm(position: Vector2, direction: Vector2):
	# Form 3: Swarm splits into smaller swarms
	var main_swarm = _release_swarm(position, direction, swarm_duration)
	
	# Create splitting behavior
	var split_timer = Timer.new()
	split_timer.wait_time = 2.0
	split_timer.one_shot = true
	main_swarm.add_child(split_timer)
	split_timer.timeout.connect(_split_swarm.bind(main_swarm))

func _split_swarm(main_swarm: Node2D):
	# Create smaller swarms around main swarm
	for i in range(3):
		var offset = Vector2(30, 0).rotated((TAU / 3) * i)
		var small_swarm_pos = main_swarm.global_position + offset
		_release_swarm(small_swarm_pos, Vector2.ZERO, 3.0)

func _on_evolution():
	match current_form:
		2:
			swarm_duration = 8.0
		3:
			damage = 8
			# Will add lifesteal effect
