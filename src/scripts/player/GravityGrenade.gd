extends "res://src/scripts/player/EnhancedBullet.gd"

@export var gravity_radius: float = 1.5
@export var vortex_strength: float = 2.0

var has_hit_target: bool = false

# Override _create_custom_bullet to prevent calling parent's _throw_grenade
func _create_custom_bullet(position: Vector2, direction: Vector2):
	# Do nothing - we handle everything in our own system
	pass

# Override create_bullet_visual to prevent accessing non-existent Sprite2D
func create_bullet_visual():
	# Do nothing - we handle our own visual effects
	pass

# Override create_custom_visual to prevent accessing non-existent Sprite2D
func create_custom_visual():
	# Do nothing - we handle our own visual effects
	pass

# Override collision detection for grenade behavior
func _on_body_entered(body):
	# Don't collide with player
	if body.is_in_group("player"):
		return
	
	# Only explode on enemies, not walls or other objects
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		print("Grenade hit enemy: ", body.name, " at: ", global_position)
		has_hit_target = true
		create_hit_effect()
		queue_free()
	else:
		print("Grenade passed through: ", body.name, " (not an enemy)")

func _ready():
	super._ready()
	lifetime = 3.0  # Longer lifetime to ensure timer triggers
	penetration = 999  # Don't explode on collision, let timer handle it
	setup_gravity_effect()
	
	# Set up automatic black hole creation for missed shots
	setup_black_hole_timer()
	
	# Track if we hit something
	has_hit_target = false
	print("Gravity grenade ready, lifetime: ", lifetime, " penetration: ", penetration)

func setup_gravity_effect():
	# Override visual for gravity grenade
	var sprite = $Sprite2D
	sprite.texture = create_gravity_texture()
	sprite.scale = Vector2(1.2, 1.2)
	
	# Add gravity vortex effect
	add_gravity_vortex()
	
	# Dark matter particles
	setup_gravity_particles()

func create_gravity_texture() -> Texture2D:
	var image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Create gravity grenade texture
	for y in range(16):
		for x in range(16):
			var dist = Vector2(x - 8, y - 8).length()
			if dist <= 6:
				# Outer edge - dark purple
				if dist >= 5:
					image.set_pixel(x, y, Color(0.2, 0.0, 0.4))
				# Middle - purple
				elif dist >= 3:
					image.set_pixel(x, y, Color.PURPLE)
				# Core - black hole
				else:
					image.set_pixel(x, y, Color.BLACK)
	
	return ImageTexture.create_from_image(image)

func add_gravity_vortex():
	# Create gravity vortex effect
	var vortex = Sprite2D.new()
	var vortex_texture = create_vortex_texture()
	vortex.texture = vortex_texture
	vortex.scale = Vector2(gravity_radius, gravity_radius)
	vortex.modulate = Color(0.5, 0.0, 1.0, 0.8)
	vortex.z_index = -1
	add_child(vortex)
	
	# Rotating vortex effect
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(vortex, "rotation", 0.0, 2.0)
	tween.tween_property(vortex, "rotation", PI * 2, 2.0)
	
	# Pulsing gravity effect
	var pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(vortex, "modulate:a", 0.5, 0.8)
	pulse_tween.tween_property(vortex, "modulate:a", 0.8, 0.8)

func create_vortex_texture() -> Texture2D:
	var image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Create spiral vortex pattern
	for y in range(16):
		for x in range(16):
			var pos = Vector2(x - 8, y - 8)
			var dist = pos.length()
			var angle = pos.angle()
			
			if dist <= 8:
				# Create spiral effect
				var spiral = fmod(angle + dist * 0.5, PI * 2)
				var intensity = (sin(spiral * 3) + 1.0) * 0.5
				var alpha = (1.0 - dist / 8.0) * intensity * 0.6
				
				if dist >= 4:
					image.set_pixel(x, y, Color(0.3, 0.0, 0.6, alpha))
				else:
					image.set_pixel(x, y, Color(0.5, 0.0, 1.0, alpha))
	
	return ImageTexture.create_from_image(image)

func setup_gravity_particles():
	var trail = CPUParticles2D.new()
	trail.name = "GravityParticles"
	trail.emitting = true
	trail.amount = 35
	trail.lifetime = 0.8
	trail.direction = Vector2(1, 0)
	trail.spread = 12.0
	trail.initial_velocity_min = -120.0
	trail.initial_velocity_max = -200.0
	trail.gravity = Vector2(0, 0)
	trail.scale_amount_min = 0.15
	trail.scale_amount_max = 0.4
	trail.color = Color.PURPLE
	add_child(trail)
	
	# Align particles with direction
	trail.rotation = direction.angle() + PI

func setup_black_hole_timer():
	# Create timer to automatically spawn black hole
	var black_hole_timer = Timer.new()
	add_child(black_hole_timer)
	black_hole_timer.wait_time = 1.5  # Create black hole after 1.5 seconds
	black_hole_timer.one_shot = true
	black_hole_timer.timeout.connect(_auto_create_black_hole)
	black_hole_timer.start()
	print("Black hole timer started, will create black hole in 1.5 seconds, timer valid: ", black_hole_timer != null)

func _auto_create_black_hole():
	# Only create black hole if we haven't hit anything
	if not has_hit_target:
		print("Missed target, creating black hole explosion at: ", global_position)
		
		# Create the SAME explosion effects as hitting target
		create_spectacular_explosion()
		create_implosion_ring()
		create_energy_shockwave()
		create_gravitational_lensing()
		create_persistent_black_hole()
		
		# Remove the grenade after creating black hole
		queue_free()
	else:
		print("Already hit target, not creating additional black hole")
		queue_free()

func _process(delta):
	super._process(delta)
	
	# Update gravity particles rotation
	var gravity_particles = get_node_or_null("GravityParticles")
	if gravity_particles and direction != Vector2.ZERO:
		gravity_particles.rotation = direction.angle() + PI
	
	# Debug: check if timer is still valid
	time_alive += delta
	if time_alive < 2.0:  # Only check for first 2 seconds
		var timer = get_node_or_null("Timer")
		if timer == null:
			print("Timer disappeared at time: ", time_alive)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		print("Gravity grenade being destroyed at time: ", time_alive, " has_hit_target: ", has_hit_target)

func create_hit_effect():
	# Mark that we hit something
	has_hit_target = true
	print("Hit target, creating immediate black hole explosion at: ", global_position)
	
	# Create spectacular black hole explosion
	create_spectacular_explosion()
	
	# Create gravity implosion ring
	create_implosion_ring()
	
	# Create energy shockwave
	create_energy_shockwave()
	
	# Create gravitational lensing effect
	create_gravitational_lensing()
	
	# Create persistent black hole entity
	create_persistent_black_hole()

func create_spectacular_explosion():
	# Main explosion particles
	var particles = $CPUParticles2D
	particles.amount = 100
	particles.lifetime = 2.0
	particles.initial_velocity_min = -300.0
	particles.initial_velocity_max = -100.0
	particles.scale_amount_min = 0.8
	particles.scale_amount_max = 2.0
	particles.color = Color.PURPLE
	particles.emitting = true
	particles.restart()
	
	# Secondary bright core explosion
	var core_explosion = CPUParticles2D.new()
	get_tree().current_scene.add_child(core_explosion)
	core_explosion.global_position = global_position
	core_explosion.amount = 80
	core_explosion.lifetime = 1.5
	core_explosion.initial_velocity_min = 50.0
	core_explosion.initial_velocity_max = 200.0
	core_explosion.scale_amount_min = 1.0
	core_explosion.scale_amount_max = 3.0
	core_explosion.color = Color.MAGENTA
	core_explosion.emitting = true
	
	# Remove after animation
	var timer = Timer.new()
	core_explosion.add_child(timer)
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.timeout.connect(core_explosion.queue_free)
	timer.start()

func create_energy_shockwave():
	# Create expanding energy ring
	var shockwave = CPUParticles2D.new()
	get_tree().current_scene.add_child(shockwave)
	shockwave.global_position = global_position
	shockwave.amount = 60
	shockwave.lifetime = 1.8
	shockwave.direction = Vector2(1, 0)
	shockwave.spread = 360.0
	shockwave.initial_velocity_min = 400.0
	shockwave.initial_velocity_max = 600.0
	shockwave.gravity = Vector2(0, 0)
	shockwave.scale_amount_min = 0.5
	shockwave.scale_amount_max = 1.5
	shockwave.color = Color.CYAN
	shockwave.emitting = true
	
	# Remove after animation
	var timer = Timer.new()
	shockwave.add_child(timer)
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.timeout.connect(shockwave.queue_free)
	timer.start()

func create_gravitational_lensing():
	# Create visual distortion effect
	var distortion = CPUParticles2D.new()
	get_tree().current_scene.add_child(distortion)
	distortion.global_position = global_position
	distortion.amount = 40
	distortion.lifetime = 2.5
	distortion.direction = Vector2(1, 0)
	distortion.spread = 360.0
	distortion.initial_velocity_min = 200.0
	distortion.initial_velocity_max = 350.0
	distortion.gravity = Vector2(0, 0)
	distortion.scale_amount_min = 0.3
	distortion.scale_amount_max = 0.8
	distortion.color = Color(0.8, 0.0, 1.0, 0.6)
	distortion.emitting = true
	
	# Remove after animation
	var timer = Timer.new()
	distortion.add_child(timer)
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(distortion.queue_free)
	timer.start()

func create_implosion_ring():
	# Create multiple implosion rings for depth
	create_single_implosion_ring(Color.MAGENTA, 300.0, 400.0, 1.0)
	create_single_implosion_ring(Color.PURPLE, 250.0, 350.0, 1.2)
	create_single_implosion_ring(Color.CYAN, 200.0, 300.0, 1.4)

func create_single_implosion_ring(ring_color: Color, min_vel: float, max_vel: float, delay: float):
	var ring = CPUParticles2D.new()
	get_tree().current_scene.add_child(ring)
	ring.global_position = global_position
	ring.amount = 30
	ring.lifetime = 1.5
	ring.direction = Vector2(1, 0)
	ring.spread = 360.0
	ring.initial_velocity_min = min_vel
	ring.initial_velocity_max = max_vel
	ring.gravity = Vector2(0, 0)
	ring.scale_amount_min = 0.3
	ring.scale_amount_max = 0.8
	ring.color = ring_color
	ring.emitting = true
	
	# Start animation after delay
	var start_timer = Timer.new()
	ring.add_child(start_timer)
	start_timer.wait_time = delay
	start_timer.one_shot = true
	start_timer.timeout.connect(_start_implosion_animation.bind(ring))
	start_timer.start()
	
	# Remove ring after animation
	var remove_timer = Timer.new()
	ring.add_child(remove_timer)
	remove_timer.wait_time = 2.5
	remove_timer.one_shot = true
	remove_timer.timeout.connect(ring.queue_free)
	remove_timer.start()

func _start_implosion_animation(ring: CPUParticles2D):
	# Create dramatic implosion effect
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Animate particles to spiral inward
	for i in range(15):
		var angle = (PI * 2 * i) / 15
		var start_radius = 150.0
		var end_radius = 0.0
		
		# Spiral path
		var spiral_points = []
		for j in range(20):
			var progress = j / 20.0
			var radius = start_radius * (1.0 - progress) + end_radius * progress
			var spiral_angle = angle + progress * PI * 2
			spiral_points.append(Vector2(cos(spiral_angle), sin(spiral_angle)) * radius)
		
		# Animate along spiral path
		for j in range(spiral_points.size() - 1):
			tween.tween_property(ring, "position", spiral_points[j], 0.05)
	
	# Scale effect
	tween.tween_property(ring, "scale", Vector2.ONE, 0.0)
	tween.tween_property(ring, "scale", Vector2(0.1, 0.1), 1.0)

func create_persistent_black_hole():
	print("Creating PERSISTENT black hole at: ", global_position)
	# Create a persistent black hole entity
	var black_hole = Node2D.new()
	black_hole.name = "PersistentBlackHole"
	get_tree().current_scene.add_child(black_hole)
	black_hole.global_position = global_position
	
	# Create visual black hole
	create_black_hole_visual(black_hole)
	
	# Create gravity area
	create_gravity_area(black_hole)
	
	# Create damage timer
	create_damage_system(black_hole)
	
	# Set duration
	var duration_timer = Timer.new()
	black_hole.add_child(duration_timer)
	duration_timer.wait_time = 5.0  # Black hole lasts 5 seconds
	duration_timer.one_shot = true
	duration_timer.timeout.connect(black_hole.queue_free)
	duration_timer.start()

func create_black_hole_visual(black_hole: Node2D):
	# Create main black hole sprite
	var sprite = Sprite2D.new()
	var texture = create_black_hole_texture()
	sprite.texture = texture
	sprite.scale = Vector2(3.0, 3.0)
	black_hole.add_child(sprite)
	
	# Create rotating vortex effect
	var vortex = Sprite2D.new()
	var vortex_texture = create_vortex_texture()
	vortex.texture = vortex_texture
	vortex.scale = Vector2(4.0, 4.0)
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
	particles.lifetime = 2.0
	particles.direction = Vector2(1, 0)
	particles.spread = 360.0
	particles.initial_velocity_min = -50.0
	particles.initial_velocity_max = 50.0
	particles.gravity = Vector2(0, 0)
	particles.scale_amount_min = 0.2
	particles.scale_amount_max = 0.8
	particles.color = Color.PURPLE
	particles.emitting = true
	black_hole.add_child(particles)

func create_black_hole_texture() -> Texture2D:
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Create black hole texture
	for y in range(32):
		for x in range(32):
			var dist = Vector2(x - 16, y - 16).length()
			if dist <= 15:
				# Event horizon - pure black
				if dist <= 8:
					image.set_pixel(x, y, Color.BLACK)
				# Accretion disk - purple gradient
				else:
					var alpha = 1.0 - (dist - 8) / 7.0
					image.set_pixel(x, y, Color(0.5, 0.0, 1.0, alpha))
	
	return ImageTexture.create_from_image(image)

func create_gravity_area(black_hole: Node2D):
	# Create area for gravity effect
	var gravity_area = Area2D.new()
	black_hole.add_child(gravity_area)
	
	var collision_shape = CollisionShape2D.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = 150.0  # Large gravity radius
	collision_shape.shape = circle_shape
	gravity_area.add_child(collision_shape)
	
	# Connect to body detection
	gravity_area.body_entered.connect(_on_enemy_entered_gravity.bind(black_hole))

func create_damage_system(black_hole: Node2D):
	# Create damage timer
	var damage_timer = Timer.new()
	black_hole.add_child(damage_timer)
	damage_timer.wait_time = 0.5  # Damage every 0.5 seconds
	damage_timer.autostart = true
	damage_timer.timeout.connect(_apply_gravity_damage.bind(black_hole))

func _on_enemy_entered_gravity(black_hole: Node2D, body):
	if body.is_in_group("enemies"):
		# Start pulling enemy towards black hole
		_pull_enemy_to_black_hole(black_hole, body)

func _pull_enemy_to_black_hole(black_hole: Node2D, enemy):
	# Continuous pulling effect
	var pull_timer = Timer.new()
	black_hole.add_child(pull_timer)
	pull_timer.wait_time = 0.1
	pull_timer.autostart = true
	
	pull_timer.timeout.connect(func():
		if enemy and is_instance_valid(enemy):
			var direction = (black_hole.global_position - enemy.global_position).normalized()
			var distance = enemy.global_position.distance_to(black_hole.global_position)
			
			if distance > 10:  # Don't pull if too close
				var pull_strength = max(50.0, 200.0 * (1.0 - distance / 150.0))
				if enemy.has_method("take_damage"):
					# Apply pull force (this would need enemy movement system)
					enemy.take_damage(2)  # Small damage over time
		else:
			pull_timer.queue_free()
	)

func _apply_gravity_damage(black_hole: Node2D):
	# Apply damage to all enemies in range
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		var distance = enemy.global_position.distance_to(black_hole.global_position)
		if distance <= 150.0:
			if enemy.has_method("take_damage"):
				enemy.take_damage(5)  # Gravity damage
