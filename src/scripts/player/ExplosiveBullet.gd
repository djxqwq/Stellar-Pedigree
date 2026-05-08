extends "res://src/scripts/player/EnhancedBullet.gd"

@export var explosion_size: float = 2.0
@export var trail_intensity: float = 1.5

func _ready():
	super._ready()
	setup_explosive_effect()

func setup_explosive_effect():
	# Override visual for explosive bullet
	var sprite = $Sprite2D
	sprite.texture = create_explosive_texture()
	sprite.scale = Vector2(2.0, 2.0)
	
	# Enhanced explosive glow
	add_explosive_glow()
	
	# Heavy trail particles
	setup_explosive_particles()

func create_explosive_texture() -> Texture2D:
	var image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Create explosive bullet texture
	for y in range(16):
		for x in range(16):
			var dist = Vector2(x - 8, y - 8).length()
			if dist <= 7:
				# Outer layer - dark red
				if dist >= 5:
					image.set_pixel(x, y, Color.DARK_RED)
				# Middle layer - orange
				elif dist >= 3:
					image.set_pixel(x, y, Color.ORANGE_RED)
				# Inner core - bright orange
				else:
					image.set_pixel(x, y, Color.ORANGE)
	
	return ImageTexture.create_from_image(image)

func add_explosive_glow():
	# Create explosive glow effect
	var glow = Sprite2D.new()
	var glow_texture = create_explosive_glow_texture()
	glow.texture = glow_texture
	glow.scale = Vector2(3.0, 3.0)
	glow.modulate = Color(1.0, 0.3, 0.1, 0.7)
	glow.z_index = -1
	add_child(glow)
	
	# Pulsing glow effect
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(glow, "modulate:a", 0.4, 0.3)
	tween.tween_property(glow, "modulate:a", 0.7, 0.3)

func create_explosive_glow_texture() -> Texture2D:
	var image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Create explosive glow
	for y in range(16):
		for x in range(16):
			var dist = Vector2(x - 8, y - 8).length()
			if dist <= 8:
				var alpha = 1.0 - (dist / 8.0)
				alpha = alpha * alpha * 0.5
				image.set_pixel(x, y, Color(1.0, 0.5, 0.2, alpha))
	
	return ImageTexture.create_from_image(image)

func setup_explosive_particles():
	var trail = CPUParticles2D.new()
	trail.name = "ExplosiveParticles"
	trail.emitting = true
	trail.amount = 40
	trail.lifetime = 0.6
	trail.direction = Vector2(1, 0)
	trail.spread = 8.0
	trail.initial_velocity_min = -150.0
	trail.initial_velocity_max = -250.0
	trail.gravity = Vector2(0, 0)
	trail.scale_amount_min = 0.2
	trail.scale_amount_max = 0.6
	trail.color = Color.ORANGE_RED
	add_child(trail)
	
	# Align particles with direction
	trail.rotation = direction.angle() + PI

func _process(delta):
	super._process(delta)
	
	# Update explosive particles rotation
	var explosive_particles = get_node_or_null("ExplosiveParticles")
	if explosive_particles and direction != Vector2.ZERO:
		explosive_particles.rotation = direction.angle() + PI

func create_hit_effect():
	# Enhanced explosion effect
	var particles = $CPUParticles2D
	particles.amount = 50
	particles.lifetime = 1.5
	particles.initial_velocity_min = 100.0
	particles.initial_velocity_max = 300.0
	particles.scale_amount_min = 1.0
	particles.scale_amount_max = 2.5
	particles.color = Color.ORANGE
	particles.emitting = true
	particles.restart()
	
	# Create secondary explosion ring
	create_explosion_ring()

func create_explosion_ring():
	var ring = CPUParticles2D.new()
	get_tree().current_scene.add_child(ring)
	ring.global_position = global_position
	ring.amount = 30
	ring.lifetime = 0.8
	ring.direction = Vector2(1, 0)
	ring.spread = 360.0
	ring.initial_velocity_min = 200.0
	ring.initial_velocity_max = 400.0
	ring.gravity = Vector2(0, 0)
	ring.scale_amount_min = 0.5
	ring.scale_amount_max = 1.5
	ring.color = Color.RED
	ring.emitting = true
	
	# Remove ring after animation
	var timer = Timer.new()
	ring.add_child(timer)
	timer.wait_time = 1.0
	timer.one_shot = true
	timer.timeout.connect(ring.queue_free)
	timer.start()
