extends "res://src/scripts/player/EnhancedBullet.gd"

@export var pellet_size: float = 0.6
@export var spread_variation: float = 0.2

func _ready():
	super._ready()
	setup_shotgun_effect()

func setup_shotgun_effect():
	# Override visual for shotgun pellet
	var sprite = $Sprite2D
	sprite.texture = create_pellet_texture()
	sprite.scale = Vector2(pellet_size, pellet_size)
	
	# Add metallic shine
	add_pellet_shine()
	
	# Light trail particles
	setup_pellet_particles()

func create_pellet_texture() -> Texture2D:
	var image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Create metallic pellet texture
	for y in range(16):
		for x in range(16):
			var dist = Vector2(x - 8, y - 8).length()
			if dist <= 5:
				# Outer edge - dark gold
				if dist >= 4:
					image.set_pixel(x, y, Color(0.6, 0.4, 0.1))
				# Middle - gold
				elif dist >= 2:
					image.set_pixel(x, y, Color.GOLD)
				# Core - bright gold
				else:
					image.set_pixel(x, y, Color(1.0, 0.8, 0.3))
	
	return ImageTexture.create_from_image(image)

func add_pellet_shine():
	# Create metallic shine effect
	var shine = Sprite2D.new()
	var shine_texture = create_shine_texture()
	shine.texture = shine_texture
	shine.scale = Vector2(pellet_size * 0.8, pellet_size * 0.8)
	shine.modulate = Color(1.0, 1.0, 0.8, 0.6)
	shine.z_index = 1
	add_child(shine)
	
	# Random shine animation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(shine, "modulate:a", 0.2, 0.1)
	tween.tween_property(shine, "modulate:a", 0.6, 0.1)

func create_shine_texture() -> Texture2D:
	var image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Create shine spot
	for y in range(16):
		for x in range(16):
			var dist = Vector2(x - 8, y - 8).length()
			if dist <= 3:
				var alpha = 1.0 - (dist / 3.0)
				alpha = alpha * alpha * 0.8
				image.set_pixel(x, y, Color(1.0, 1.0, 0.9, alpha))
	
	return ImageTexture.create_from_image(image)

func setup_pellet_particles():
	var trail = CPUParticles2D.new()
	trail.name = "PelletParticles"
	trail.emitting = true
	trail.amount = 15
	trail.lifetime = 0.4
	trail.direction = Vector2(1, 0)
	trail.spread = 5.0
	trail.initial_velocity_min = -80.0
	trail.initial_velocity_max = -120.0
	trail.gravity = Vector2(0, 0)
	trail.scale_amount_min = 0.1
	trail.scale_amount_max = 0.3
	trail.color = Color.GOLD
	add_child(trail)
	
	# Align particles with direction
	trail.rotation = direction.angle() + PI

func _process(delta):
	super._process(delta)
	
	# Update pellet particles rotation
	var pellet_particles = get_node_or_null("PelletParticles")
	if pellet_particles and direction != Vector2.ZERO:
		pellet_particles.rotation = direction.angle() + PI

func create_hit_effect():
	# Metallic spark effect
	var particles = $CPUParticles2D
	particles.amount = 25
	particles.lifetime = 0.6
	particles.initial_velocity_min = 80.0
	particles.initial_velocity_max = 150.0
	particles.scale_amount_min = 0.3
	particles.scale_amount_max = 0.8
	particles.color = Color.GOLD
	particles.emitting = true
	particles.restart()
	
	# Create small spark fragments
	create_spark_fragments()

func create_spark_fragments():
	var spark_count = 8
	for i in range(spark_count):
		var spark = CPUParticles2D.new()
		get_tree().current_scene.add_child(spark)
		spark.global_position = global_position
		spark.amount = 5
		spark.lifetime = 0.3
		spark.direction = Vector2.RIGHT.rotated((PI * 2 * i) / spark_count)
		spark.spread = 10.0
		spark.initial_velocity_min = 50.0
		spark.initial_velocity_max = 100.0
		spark.gravity = Vector2(0, 0)
		spark.scale_amount_min = 0.1
		spark.scale_amount_max = 0.2
		spark.color = Color.YELLOW
		spark.emitting = true
		
		# Remove spark after animation
		var timer = Timer.new()
		spark.add_child(timer)
		timer.wait_time = 0.5
		timer.one_shot = true
		timer.timeout.connect(spark.queue_free)
		timer.start()
