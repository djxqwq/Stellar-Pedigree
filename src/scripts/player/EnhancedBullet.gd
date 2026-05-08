extends "res://src/scripts/player/CustomBullet.gd"

@export var trail_particles: bool = true
@export var explosion_particles: bool = true
@export var glow_effect: bool = true
@export var bullet_trail: Array[Node2D] = []

func _ready():
	super._ready()
	setup_enhanced_effects()

func setup_enhanced_effects():
	# Add glow effect
	if glow_effect:
		add_glow_effect()
	
	# Add trail particles
	if trail_particles:
		setup_trail_particles()
	
	# Enhanced explosion effect
	if explosion_particles:
		setup_explosion_particles()

func add_glow_effect():
	# Create glowing aura around bullet
	var glow = Sprite2D.new()
	var glow_texture = create_glow_texture()
	glow.texture = glow_texture
	glow.scale = Vector2(2.0, 2.0)
	glow.modulate = get_glow_color()
	glow.z_index = -1
	add_child(glow)
	
	# Animate glow
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(glow, "modulate:a", 0.5, 0.3)
	tween.tween_property(glow, "modulate:a", 1.0, 0.3)

func create_glow_texture() -> Texture2D:
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Create radial gradient glow
	for y in range(32):
		for x in range(32):
			var dist = Vector2(x - 16, y - 16).length()
			if dist <= 15:
				var alpha = 1.0 - (dist / 15.0)
				alpha = alpha * alpha * 0.3  # Quadratic falloff
				image.set_pixel(x, y, Color(1, 1, 1, alpha))
	
	return ImageTexture.create_from_image(image)

func get_glow_color() -> Color:
	match bullet_type:
		"heavy_particle":
			return Color.RED
		"black_hole":
			return Color.PURPLE
		"shotgun":
			return Color.YELLOW
		"pulse_rifle":
			return Color.CYAN
		_:
			return Color.WHITE

func setup_trail_particles():
	var trail = CPUParticles2D.new()
	trail.name = "TrailParticles"
	trail.emitting = true
	trail.amount = 50
	trail.lifetime = 0.5
	trail.direction = Vector2(1, 0)
	trail.spread = 5.0
	trail.initial_velocity_min = -50.0
	trail.initial_velocity_max = -100.0
	trail.gravity = Vector2(0, 0)
	trail.scale_amount_min = 0.1
	trail.scale_amount_max = 0.3
	trail.color = get_trail_color()
	add_child(trail)
	
	# Rotate trail to match bullet direction
	trail.rotation = direction.angle() + PI

func get_trail_color() -> Color:
	match bullet_type:
		"heavy_particle":
			return Color.ORANGE_RED
		"black_hole":
			return Color.PURPLE
		"shotgun":
			return Color.YELLOW
		"pulse_rifle":
			return Color.CYAN
		_:
			return Color.WHITE

func setup_explosion_particles():
	# Enhanced hit effect
	var particles = $CPUParticles2D
	particles.amount = 20
	particles.lifetime = 1.0
	particles.initial_velocity_min = 50.0
	particles.initial_velocity_max = 150.0
	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 1.5
	particles.color = get_explosion_color()

func get_explosion_color() -> Color:
	match bullet_type:
		"heavy_particle":
			return Color.ORANGE
		"black_hole":
			return Color.MAGENTA
		"shotgun":
			return Color.GOLD
		"pulse_rifle":
			return Color.LIGHT_CYAN
		_:
			return Color.WHITE

func _process(delta):
	super._process(delta)
	
	# Update trail rotation to match direction
	var trail = get_node_or_null("TrailParticles")
	if trail and direction != Vector2.ZERO:
		trail.rotation = direction.angle() + PI
