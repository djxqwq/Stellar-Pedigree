extends "res://src/scripts/player/EnhancedBullet.gd"

@export var laser_length: float = 100.0
@export var laser_width: float = 4.0

func _ready():
	super._ready()
	setup_laser_effect()

func setup_laser_effect():
	# Override visual for laser beam
	var sprite = $Sprite2D
	sprite.texture = create_laser_texture()
	sprite.scale = Vector2(laser_length / 16.0, laser_width / 16.0)
	
	# Enhanced laser glow
	add_laser_glow()
	
	# Laser trail particles
	setup_laser_particles()

func create_laser_texture() -> Texture2D:
	var image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Create laser beam texture
	for y in range(16):
		for x in range(16):
			var dist_y = abs(y - 8)
			if dist_y <= laser_width / 2:
				# Core beam - bright cyan
				if dist_y <= 1:
					image.set_pixel(x, y, Color.CYAN)
				# Outer glow
				else:
					var alpha = 1.0 - (dist_y / (laser_width / 2))
					image.set_pixel(x, y, Color(0.5, 1.0, 1.0, alpha))
	
	return ImageTexture.create_from_image(image)

func add_laser_glow():
	# Create laser glow effect
	var glow = Sprite2D.new()
	var glow_texture = create_laser_glow_texture()
	glow.texture = glow_texture
	glow.scale = Vector2(laser_length / 16.0 * 1.5, laser_width / 16.0 * 3.0)
	glow.modulate = Color(0.3, 1.0, 1.0, 0.6)
	glow.z_index = -1
	add_child(glow)
	
	# Pulse glow effect
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(glow, "modulate:a", 0.3, 0.2)
	tween.tween_property(glow, "modulate:a", 0.6, 0.2)

func create_laser_glow_texture() -> Texture2D:
	var image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Create radial glow for laser
	for y in range(16):
		for x in range(16):
			var dist_y = abs(y - 8)
			if dist_y <= 8:
				var alpha = 1.0 - (dist_y / 8.0)
				alpha = alpha * alpha * 0.4
				image.set_pixel(x, y, Color(0.5, 1.0, 1.0, alpha))
	
	return ImageTexture.create_from_image(image)

func setup_laser_particles():
	var trail = CPUParticles2D.new()
	trail.name = "LaserParticles"
	trail.emitting = true
	trail.amount = 30
	trail.lifetime = 0.3
	trail.direction = Vector2(1, 0)
	trail.spread = 2.0
	trail.initial_velocity_min = -100.0
	trail.initial_velocity_max = -200.0
	trail.gravity = Vector2(0, 0)
	trail.scale_amount_min = 0.05
	trail.scale_amount_max = 0.2
	trail.color = Color.CYAN
	add_child(trail)
	
	# Align particles with laser direction
	trail.rotation = direction.angle() + PI

func _process(delta):
	super._process(delta)
	
	# Update laser rotation to match direction
	var laser_particles = get_node_or_null("LaserParticles")
	if laser_particles and direction != Vector2.ZERO:
		laser_particles.rotation = direction.angle() + PI
