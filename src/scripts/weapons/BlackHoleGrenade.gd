extends "res://src/scripts/player/Weapon.gd"

@export var black_hole_duration: float = 3.0
@export var pull_radius: float = 120.0

func _ready():
	weapon_name = "Black Hole Grenade"
	damage = 0  # Damage from black hole effect
	fire_rate = 0.8
	bullet_speed = 400.0
	black_hole_duration = 3.0
	pull_radius = 120.0
	
	bullet_scene = preload("res://src/scenes/player/Bullet.tscn")

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
	# Create a custom black hole grenade instead of using regular bullet
	var grenade = Node2D.new()
	grenade.name = "BlackHoleGrenade"
	get_tree().current_scene.add_child(grenade)
	grenade.global_position = position
	
	# Add visual effect
	var sprite = Sprite2D.new()
	var texture = ImageTexture.new()
	var image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	# Draw purple circle for grenade
	for y in range(16):
		for x in range(16):
			var dist = Vector2(x - 8, y - 8).length()
			if dist <= 6:
				image.set_pixel(x, y, Color.PURPLE)
			if dist <= 4:
				image.set_pixel(x, y, Color.BLACK)
	texture.set_image(image)
	sprite.texture = texture
	grenade.add_child(sprite)
	
	# Add movement
	var tween = create_tween()
	tween.tween_method(_move_grenade.bind(grenade, direction), 0.0, 1.0, 1.0)
	
	# Create black hole after delay
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = true
	grenade.add_child(timer)
	timer.timeout.connect(_create_black_hole.bind(grenade.global_position, duration))
	timer.start()

func _move_grenade(grenade: Node2D, direction: Vector2, progress: float):
	grenade.global_position += direction * bullet_speed * 0.016

func _create_black_hole(position: Vector2, duration: float):
	var black_hole = Node2D.new()
	black_hole.name = "BlackHole"
	get_tree().current_scene.add_child(black_hole)
	black_hole.global_position = position
	
	# Create visual effect - larger purple circle
	var sprite = Sprite2D.new()
	var texture = ImageTexture.new()
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	# Draw purple circle for black hole
	for y in range(32):
		for x in range(32):
			var dist = Vector2(x - 16, y - 16).length()
			if dist <= 12:
				image.set_pixel(x, y, Color(0.5, 0.0, 1.0, 0.8))
			if dist <= 8:
				image.set_pixel(x, y, Color.BLACK)
	texture.set_image(image)
	sprite.texture = texture
	black_hole.add_child(sprite)
	
	# Create particle effect
	var particles = CPUParticles2D.new()
	particles.amount = 50
	particles.lifetime = 3.0
	particles.emitting = true
	particles.color = Color(0.5, 0.0, 1.0, 0.6)
	black_hole.add_child(particles)
	
	# Remove black hole after duration
	var remove_timer = Timer.new()
	remove_timer.wait_time = duration
	remove_timer.one_shot = true
	black_hole.add_child(remove_timer)
	remove_timer.timeout.connect(black_hole.queue_free)

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
