extends "res://src/scripts/player/Weapon.gd"

@export var explosion_radius: float = 1.0

func _ready():
	weapon_name = "Heavy Particle Cannon"
	damage = 40
	fire_rate = 1.0
	bullet_speed = 400.0
	explosion_radius = 1.0
	
	bullet_scene = preload("res://src/scenes/player/Bullet.tscn")

func shoot(position: Vector2, direction: Vector2):
	if not can_shoot():
		return
	
	time_since_last_shot = 0.0
	
	match current_form:
		1:
			_shoot_single(position, direction)
		2:
			_shoot_explosive(position, direction)
		3:
			_shoot_burning(position, direction)

func _create_custom_bullet(position: Vector2, direction: Vector2):
	# Override for heavy particle cannon - create large red bullet
	print("Creating HEAVY PARTICLE BULLET")
	_create_heavy_bullet(position, direction)

func _shoot_single(position: Vector2, direction: Vector2):
	_create_heavy_bullet(position, direction)

func _create_heavy_bullet(position: Vector2, direction: Vector2):
	# Create large red bullet for Heavy Particle Cannon
	var bullet = Node2D.new()
	bullet.name = "HeavyParticleBullet"
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = position
	
	# Add visual effect - large red bullet
	var sprite = Sprite2D.new()
	var texture = ImageTexture.new()
	var image = Image.create(20, 20, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	# Draw large red circle
	for y in range(20):
		for x in range(20):
			var dist = Vector2(x - 10, y - 10).length()
			if dist <= 8:
				image.set_pixel(x, y, Color.RED)
			if dist <= 6:
				image.set_pixel(x, y, Color.ORANGE)
	texture.set_image(image)
	sprite.texture = texture
	bullet.add_child(sprite)
	
	# Add movement
	var tween = create_tween()
	tween.tween_method(_move_heavy_bullet.bind(bullet, direction), 0.0, 1.0, 1.5)
	
	# Remove after lifetime
	var remove_timer = Timer.new()
	remove_timer.wait_time = 1.5
	remove_timer.one_shot = true
	bullet.add_child(remove_timer)
	remove_timer.timeout.connect(bullet.queue_free)

func _move_heavy_bullet(bullet: Node2D, direction: Vector2, progress: float):
	print("Moving heavy bullet: ", bullet.global_position, " direction: ", direction)
	bullet.global_position += direction * bullet_speed * 0.016
	print("New position: ", bullet.global_position)

func _shoot_explosive(position: Vector2, direction: Vector2):
	# Form 2: Larger explosion
	var bullet = _create_explosive_bullet(position, direction, explosion_radius * 2.0)
	damage = 60

func _shoot_burning(position: Vector2, direction: Vector2):
	# Form 3: Explosion + burning ground
	var bullet = _create_explosive_bullet(position, direction, explosion_radius * 2.0)
	damage = 60
	# Will add burning ground effect later

func _create_explosive_bullet(position: Vector2, direction: Vector2, radius: float):
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = position
	bullet.setup(direction, damage, bullet_speed)
	# Will add explosion radius property later
	return bullet

func _on_evolution():
	match current_form:
		2:
			explosion_radius = 2.0
		3:
			damage = 60
			explosion_radius = 2.0
