extends "res://src/scripts/player/Weapon.gd"

@export var pull_radius: float = 100.0
@export var pull_force: float = 500.0
@export var damage_interval: float = 0.5

func _ready():
	weapon_name = "Gravity Anchor"
	damage = 5
	fire_rate = 0.5
	bullet_speed = 0.0  # Stationary
	pull_radius = 100.0
	pull_force = 500.0
	damage_interval = 0.5
	
	bullet_scene = preload("res://src/scenes/player/Bullet.tscn")

func shoot(position: Vector2, direction: Vector2):
	if not can_shoot():
		return
	
	time_since_last_shot = 0.0
	
	match current_form:
		1:
			_deploy_anchor(position, direction, pull_radius)
		2:
			_deploy_anchor(position, direction, pull_radius * 1.5)
		3:
			_deploy_explosive_anchor(position, direction)

func _deploy_anchor(position: Vector2, direction: Vector2, radius: float):
	var anchor = Node2D.new()
	anchor.name = "GravityAnchor"
	get_tree().current_scene.add_child(anchor)
	anchor.global_position = position
	
	# Create pull effect
	var pull_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = radius
	collision_shape.shape = circle_shape
	pull_area.add_child(collision_shape)
	anchor.add_child(pull_area)
	
	# Create damage timer
	var damage_timer = Timer.new()
	damage_timer.wait_time = damage_interval
	damage_timer.autostart = true
	anchor.add_child(damage_timer)
	damage_timer.timeout.connect(_anchor_deal_damage.bind(anchor))
	
	# Remove anchor after duration
	var remove_timer = Timer.new()
	remove_timer.wait_time = 3.0
	remove_timer.one_shot = true
	anchor.add_child(remove_timer)
	remove_timer.timeout.connect(anchor.queue_free)

func _anchor_deal_damage(anchor: Node2D):
	# Deal damage to enemies in pull area
	# For now, just create visual effect
	var particles = CPUParticles2D.new()
	particles.amount = 5
	particles.lifetime = 0.5
	particles.emitting = true
	anchor.add_child(particles)

func _deploy_explosive_anchor(position: Vector2, direction: Vector2):
	# Form 3: Anchor explodes after duration
	var anchor = _deploy_anchor(position, direction, pull_radius * 1.5)
	
	# Add explosion timer
	var explosion_timer = Timer.new()
	explosion_timer.wait_time = 3.0
	explosion_timer.one_shot = true
	anchor.add_child(explosion_timer)
	explosion_timer.timeout.connect(_anchor_explode.bind(anchor))

func _anchor_explode(anchor: Node2D):
	# Create large explosion
	damage = 200
	_anchor_deal_damage(anchor)
	anchor.queue_free()

func _on_evolution():
	match current_form:
		2:
			pull_radius = 150.0
			damage = 10
		3:
			damage = 200
			# Will add explosion effect
