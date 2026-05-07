extends CharacterBody2D

signal health_changed(current_health: int, max_health: int)
signal experience_gained(amount: int)
signal player_leveled_up(new_level: int)
signal died

@export var max_health: int = 100
@export var speed: float = 400.0
@export var acceleration: float = 1000.0
@export var friction: float = 1000.0
@export var invulnerable_time: float = 1.0

var current_health: int
var current_level: int = 1
var current_experience: int = 0
var experience_to_next_level: int = 100
var is_invulnerable: bool = false
var invulnerable_timer: float = 0.0

# Weapon system
var current_weapon
var weapons = []

# Visual effects
var original_color: Color
var flash_timer: float = 0.0

func _ready():
	current_health = max_health
	health_changed.emit(current_health, max_health)
	original_color = $Sprite2D.modulate
	
	# Create visual shape for player
	create_player_shape()
	
	# Add to player group for collision management
	add_to_group("player")

func create_player_shape():
	# Create a simple spaceship shape using drawing
	var sprite = $Sprite2D
	sprite.texture = create_spaceship_texture()

func create_spaceship_texture() -> Texture2D:
	var image = Image.create(40, 40, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Draw spaceship shape (triangle)
	for y in range(40):
		for x in range(40):
			# Simple triangle shape pointing up
			if y >= 10 and y <= 35:
				var width = (35 - y) * 0.8
				if abs(x - 20) <= width:
					image.set_pixel(x, y, Color.CYAN)
	
	var texture = ImageTexture.create_from_image(image)
	return texture

func _physics_process(delta):
	handle_movement(delta)
	handle_shooting()
	handle_invulnerability(delta)
	handle_visual_effects(delta)

func _process(delta):
	# Handle shooting in process for better responsiveness
	handle_shooting()

func handle_movement(delta):
	var input_vector = Vector2.ZERO
	
	# Try both action mapping and direct key codes
	if Input.is_action_pressed("move_left") or Input.is_key_pressed(KEY_A):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right") or Input.is_key_pressed(KEY_D):
		input_vector.x += 1
	if Input.is_action_pressed("move_up") or Input.is_key_pressed(KEY_W):
		input_vector.y -= 1
	if Input.is_action_pressed("move_down") or Input.is_key_pressed(KEY_S):
		input_vector.y += 1
	
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	move_and_slide()

func handle_shooting():
	if Input.is_action_pressed("shoot") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if current_weapon:
			var mouse_position = get_global_mouse_position()
			var direction = (mouse_position - global_position).normalized()
			current_weapon.shoot(global_position, direction)

func handle_invulnerability(delta):
	if is_invulnerable:
		invulnerable_timer -= delta
		if invulnerable_timer <= 0:
			is_invulnerable = false

func handle_visual_effects(delta):
	if is_invulnerable:
		flash_timer += delta * 10
		$Sprite2D.modulate = original_color if int(flash_timer) % 2 == 0 else Color.WHITE
	else:
		$Sprite2D.modulate = original_color

func take_damage(damage: int):
	if is_invulnerable:
		return
	
	current_health -= damage
	current_health = max(0, current_health)
	health_changed.emit(current_health, max_health)
	
	# Start invulnerability
	is_invulnerable = true
	invulnerable_timer = invulnerable_time
	
	if current_health <= 0:
		die()

func heal(amount: int):
	current_health += amount
	current_health = min(max_health, current_health)
	health_changed.emit(current_health, max_health)

func gain_experience(amount: int):
	current_experience += amount
	experience_gained.emit(amount)
	
	while current_experience >= experience_to_next_level:
		level_up()

func level_up():
	current_experience -= experience_to_next_level
	current_level += 1
	experience_to_next_level = int(experience_to_next_level * 1.5)
	player_leveled_up.emit(current_level)

func die():
	died.emit()
	# Handle player death
	print("Player died!")
	# Will implement game over logic later

func add_weapon(weapon):
	weapons.append(weapon)
	$WeaponHolder.add_child(weapon)
	if not current_weapon:
		current_weapon = weapon

func switch_weapon(weapon_index: int):
	if weapon_index >= 0 and weapon_index < weapons.size():
		current_weapon = weapons[weapon_index]
