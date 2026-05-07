extends Node

@onready var player = $Player
var weapon_manager: Node
var bullet_count: int = 0

func _ready():
	# Initialize game
	print("Stellar Pedigree - Game Started")
	
	# Create weapon manager
	weapon_manager = preload("res://src/scripts/WeaponManager.gd").new()
	add_child(weapon_manager)
	
	# Connect player signals
	player.health_changed.connect(_on_player_health_changed)
	player.experience_gained.connect(_on_player_experience_gained)
	player.player_leveled_up.connect(_on_player_level_up)
	player.died.connect(_on_player_died)
	
	# Give player starting weapon
	var pulse_rifle = preload("res://src/scripts/weapons/PulseRifle.gd").new()
	player.add_weapon(pulse_rifle)
	
	# Create test environment
	create_test_environment()

func create_test_environment():
	# Create simple background
	create_starfield_background()

func create_starfield_background():
	# Create a simple starfield effect
	var starfield = Node2D.new()
	starfield.name = "Starfield"
	add_child(starfield)
	
	# Add some background stars
	for i in range(100):
		var star = create_star()
		star.position = Vector2(
			randf() * get_viewport().get_visible_rect().size.x,
			randf() * get_viewport().get_visible_rect().size.y
		)
		starfield.add_child(star)

func create_star() -> Node2D:
	var star = Node2D.new()
	var sprite = Sprite2D.new()
	sprite.texture = create_star_texture()
	sprite.modulate = Color.WHITE
	sprite.scale = Vector2(randf() * 0.5 + 0.5, randf() * 0.5 + 0.5)
	star.add_child(sprite)
	
	# Add twinkling effect
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(sprite, "modulate", Color(0.5, 0.5, 0.5, 1.0), randf() * 2 + 1)
	tween.tween_property(sprite, "modulate", Color.WHITE, randf() * 2 + 1)
	
	return star

func create_star_texture() -> Texture2D:
	var image = Image.create(4, 4, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Draw small star
	image.set_pixel(1, 1, Color.WHITE)
	image.set_pixel(2, 1, Color.WHITE)
	image.set_pixel(1, 2, Color.WHITE)
	image.set_pixel(2, 2, Color.WHITE)
	
	return ImageTexture.create_from_image(image)

func _on_player_health_changed(current: int, maximum: int):
	print("Player Health: ", current, "/", maximum)

func _on_player_experience_gained(amount: int):
	print("Player gained ", amount, " experience")

func _on_player_level_up(new_level: int):
	print("Player leveled up to level ", new_level)

func _on_player_died():
	print("Player died! Game Over")
	get_tree().paused = true

func _process(delta):
	# Count bullets in scene
	bullet_count = get_tree().get_nodes_in_group("bullets").size()
	
	if Input.is_action_just_pressed("pause"):
		print("Game Paused")
		get_tree().paused = not get_tree().paused
	
	# Test damage with key press (for testing)
	if Input.is_action_just_pressed("ui_accept"): # Enter key
		player.take_damage(10)
		print("Test damage applied")
	
	# Test healing with key press
	if Input.is_action_just_pressed("ui_select"): # Shift key
		player.heal(20)
		print("Test healing applied")
	
	# Weapon switching for testing
	if Input.is_action_just_pressed("ui_next"): # Q key - next weapon
		print("Q pressed - switching to next weapon")
		var new_weapon = weapon_manager.switch_to_next_weapon()
		print("New weapon created: ", new_weapon)
		player.weapons.clear()
		player.add_weapon(new_weapon)
		print("Player current weapon: ", player.current_weapon)
		print("Player current weapon name: ", player.current_weapon.weapon_name if player.current_weapon else "None")
		print("Player weapons count: ", player.weapons.size())
	
	if Input.is_action_just_pressed("ui_prev"): # E key - previous weapon
		print("E pressed - switching to previous weapon")
		var new_weapon = weapon_manager.switch_to_previous_weapon()
		print("New weapon created: ", new_weapon)
		player.weapons.clear()
		player.add_weapon(new_weapon)
		print("Player current weapon: ", player.current_weapon)
		print("Player current weapon name: ", player.current_weapon.weapon_name if player.current_weapon else "None")
		print("Player weapons count: ", player.weapons.size())
	
	# Bullet count tracking (debug disabled)
	# if bullet_count > 0:
	#     print("Bullets in scene: ", bullet_count)
