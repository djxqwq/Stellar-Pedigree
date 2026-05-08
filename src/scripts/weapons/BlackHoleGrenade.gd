extends "res://src/scripts/player/Weapon.gd"

@export var black_hole_duration: float = 3.0
@export var pull_radius: float = 120.0

func _ready():
	weapon_name = "黑洞手雷"
	damage = 0  # Damage from black hole effect
	fire_rate = 0.8
	bullet_speed = 400.0
	black_hole_duration = 3.0
	pull_radius = 120.0
	
	bullet_scene = preload("res://src/scenes/player/GravityGrenade.tscn")

func shoot(position: Vector2, direction: Vector2):
	if not can_shoot():
		return
	
	time_since_last_shot = 0.0
	
	match current_form:
		1:
			_throw_grenade(position, direction, black_hole_duration)
		2:
			_throw_grenade(position, direction, 5.0)
		3:
			_throw_explosive_grenade(position, direction)

func _create_custom_bullet(position: Vector2, direction: Vector2):
	# Override for black hole grenade
	print("Creating BLACK HOLE GRENADE")
	_throw_grenade(position, direction, black_hole_duration)

func _throw_grenade(position: Vector2, direction: Vector2, duration: float):
	# Create grenade using custom bullet scene
	var grenade = bullet_scene.instantiate()
	get_tree().current_scene.add_child(grenade)
	grenade.global_position = position
	grenade.bullet_type = "black_hole"
	grenade.custom_size = 1.2
	grenade.setup(direction, damage, bullet_speed)
	
	# Create black hole after delay
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = true
	grenade.add_child(timer)
	timer.timeout.connect(_create_black_hole_at_grenade_position.bind(grenade, duration))
	timer.start()

func _move_grenade(grenade: Node2D, direction: Vector2, progress: float):
	grenade.global_position += direction * bullet_speed * 0.016

func _create_black_hole_at_grenade_position(grenade: Node2D, duration: float):
	# Create black hole at grenade's current position
	_create_black_hole(grenade.global_position, duration)
	# Remove the grenade after creating black hole
	grenade.queue_free()

func _create_black_hole(position: Vector2, duration: float):
	print("Creating large black hole at: ", position)
	
	# Create black hole entity
	var black_hole = Node2D.new()
	black_hole.name = "PersistentBlackHole"
	get_tree().current_scene.add_child(black_hole)
	black_hole.global_position = position
	
	# Create main black hole sprite (large size)
	var sprite = Sprite2D.new()
	var texture = ImageTexture.create_from_image(create_black_hole_image())
	sprite.texture = texture
	sprite.scale = Vector2(3.0, 3.0)  # Large scale like GravityGrenade
	black_hole.add_child(sprite)
	
	# Create rotating vortex effect
	var vortex = Sprite2D.new()
	var vortex_texture = ImageTexture.create_from_image(create_vortex_image())
	vortex.texture = vortex_texture
	vortex.scale = Vector2(4.0, 4.0)  # Large scale like GravityGrenade
	vortex.modulate = Color.PURPLE
	black_hole.add_child(vortex)
	
	# Animate vortex rotation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(vortex, "rotation", 0.0, 2.0)
	tween.tween_property(vortex, "rotation", PI * 2, 2.0)
	
	# Create particle effects
	var particles = CPUParticles2D.new()
	particles.amount = 100
	particles.lifetime = 5.0
	particles.emitting = true
	particles.color = Color(0.5, 0.0, 1.0, 0.6)
	black_hole.add_child(particles)
	
	# Create gravity area
	var gravity_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = 150.0  # Large radius like GravityGrenade
	collision_shape.shape = circle_shape
	gravity_area.add_child(collision_shape)
	black_hole.add_child(gravity_area)
	
	# Remove black hole after duration
	var remove_timer = Timer.new()
	remove_timer.wait_time = duration
	remove_timer.one_shot = true
	black_hole.add_child(remove_timer)
	remove_timer.timeout.connect(black_hole.queue_free)

func create_black_hole_image() -> Image:
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	# Draw black circle
	for y in range(32):
		for x in range(32):
			var dist = Vector2(x - 16, y - 16).length()
			if dist <= 12:
				image.set_pixel(x, y, Color.BLACK)
	return image

func create_vortex_image() -> Image:
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	# Draw purple spiral
	for y in range(32):
		for x in range(32):
			var dist = Vector2(x - 16, y - 16).length()
			if dist <= 12:
				image.set_pixel(x, y, Color(0.5, 0.0, 1.0, 0.8))
	return image

func _on_enemy_entered_black_hole(body):
	if body.is_in_group("enemies"):
		# Start pulling enemy towards black hole
		# This would need to be implemented with continuous pulling
		pass

func _black_hole_deal_damage(black_hole: Node2D):
	# Deal damage to enemies in range
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		var dist = enemy.global_position.distance_to(black_hole.global_position)
		if dist <= pull_radius:
			# Pull enemy closer
			var pull_dir = (black_hole.global_position - enemy.global_position).normalized()
			var pull_strength = (1.0 - dist / pull_radius) * 200.0
			if enemy.has_method("take_damage"):
				enemy.take_damage(5)  # Small damage over time

func _throw_explosive_grenade(position: Vector2, direction: Vector2):
	# Form 3: Black hole explodes at end
	var grenade = _throw_grenade(position, direction, 5.0)
	
	# Add explosion effect
	# Will implement explosion at end of duration
	pass

func _on_evolution():
	match current_form:
		2:
			black_hole_duration = 5.0
		3:
			# Will add explosion effect
			pass
