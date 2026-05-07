extends Area2D

@export var speed: float = 600.0
@export var damage: int = 10
@export var penetration: int = 1
@export var lifetime: float = 10.0

var direction: Vector2
var current_penetration: int = 0
var time_alive: float = 0.0

signal bullet_hit(target: Node)

func _ready():
	body_entered.connect(_on_body_entered)
	create_bullet_visual()
	add_to_group("bullets")

func create_bullet_visual():
	# Create simple bullet visual
	var sprite = $Sprite2D
	sprite.texture = create_bullet_texture()

func create_bullet_texture() -> Texture2D:
	var image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Draw larger bullet shape (bigger circle)
	for y in range(16):
		for x in range(16):
			var dist = Vector2(x - 8, y - 8).length()
			if dist <= 6:
				image.set_pixel(x, y, Color.YELLOW)
			if dist <= 4:
				image.set_pixel(x, y, Color.WHITE)  # Bright center
	
	var texture = ImageTexture.create_from_image(image)
	return texture

func setup(dir: Vector2, dmg: int, spd: float):
	direction = dir.normalized()
	damage = dmg
	speed = spd
	
	# Rotate sprite to face direction
	if direction != Vector2.ZERO:
		$Sprite2D.rotation = direction.angle()

func _process(delta):
	position += direction * speed * delta
	time_alive += delta
	
	if time_alive >= lifetime:
		create_hit_effect()
		queue_free()

func _on_body_entered(body):
	# Don't collide with player
	if body.is_in_group("player"):
		return
	
	if body.has_method("take_damage"):
		body.take_damage(damage)
		current_penetration += 1
		bullet_hit.emit(body)
		create_hit_effect()
		
		if current_penetration >= penetration:
			queue_free()
		else:
			# Reduce damage for subsequent hits
			damage = int(damage * 0.7)

func create_hit_effect():
	# Create particle effect when bullet hits something
	var particles = $CPUParticles2D
	particles.emitting = true
	particles.restart()
