extends "res://src/scripts/player/Weapon.gd"

@export var pellet_count: int = 5
@export var spread_angle: float = 30.0

func _ready():
	weapon_name = "Stardust Shotgun"
	damage = 8
	fire_rate = 1.5
	bullet_speed = 600.0
	pellet_count = 5
	spread_angle = 30.0
	
	bullet_scene = preload("res://src/scenes/player/Bullet.tscn")

func shoot(position: Vector2, direction: Vector2):
	if not can_shoot():
		return
	
	time_since_last_shot = 0.0
	
	match current_form:
		1:
			_shoot_spread(position, direction, pellet_count)
		2:
			_shoot_wide(position, direction)
		3:
			_shoot_360(position, direction)

func _create_custom_bullet(position: Vector2, direction: Vector2):
	# Override for shotgun spread shot
	print("Creating SHOTGUN SPREAD with ", pellet_count, " pellets")
	_shoot_spread(position, direction, pellet_count)

func _shoot_spread(position: Vector2, direction: Vector2, pellets: int):
	var angle_step = spread_angle / (pellets - 1)
	var start_angle = -spread_angle / 2
	
	for i in range(pellets):
		var angle = start_angle + i * angle_step
		var pellet_dir = direction.rotated(deg_to_rad(angle))
		_create_shotgun_pellet(position, pellet_dir)

func _create_shotgun_pellet(position: Vector2, direction: Vector2):
	# Create individual pellet with custom visual
	var pellet = Node2D.new()
	pellet.name = "ShotgunPellet"
	get_tree().current_scene.add_child(pellet)
	pellet.global_position = position
	
	# Add visual effect - smaller yellow pellet
	var sprite = Sprite2D.new()
	var texture = ImageTexture.new()
	var image = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	# Draw small yellow circle
	for y in range(8):
		for x in range(8):
			var dist = Vector2(x - 4, y - 4).length()
			if dist <= 3:
				image.set_pixel(x, y, Color.YELLOW)
	texture.set_image(image)
	sprite.texture = texture
	pellet.add_child(sprite)
	
	# Add movement
	var tween = create_tween()
	tween.tween_method(_move_shotgun_pellet.bind(pellet, direction), 0.0, 1.0, 2.0)
	
	# Remove after lifetime
	var remove_timer = Timer.new()
	remove_timer.wait_time = 2.0
	remove_timer.one_shot = true
	pellet.add_child(remove_timer)
	remove_timer.timeout.connect(pellet.queue_free)

func _move_shotgun_pellet(pellet: Node2D, direction: Vector2, progress: float):
	pellet.global_position += direction * bullet_speed * 0.016

func _shoot_wide(position: Vector2, direction: Vector2):
	# Form 2: More pellets, narrower spread
	pellet_count = 8
	spread_angle = 20.0
	_shoot_spread(position, direction, pellet_count)

func _shoot_360(position: Vector2, direction: Vector2):
	# Form 3: 360 degree shot
	pellet_count = 12
	var angle_step = 360.0 / pellet_count
	
	for i in range(pellet_count):
		var angle = i * angle_step
		var pellet_dir = direction.rotated(deg_to_rad(angle))
		_create_pellet(position, pellet_dir)

func _create_pellet(position: Vector2, direction: Vector2):
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = position
	bullet.setup(direction, damage, bullet_speed)

func _on_evolution():
	match current_form:
		2:
			pellet_count = 8
			spread_angle = 20.0
		3:
			pellet_count = 12
			damage = 10
