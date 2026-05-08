extends CharacterBody2D

@export var max_health: int = 50
var current_health: int

func _ready():
	current_health = max_health
	add_to_group("enemies")
	
	# Create simple visual
	create_dummy_visual()

func create_dummy_visual():
	# Create a simple target dummy
	var sprite = $Sprite2D
	sprite.texture = create_dummy_texture()

func create_dummy_texture() -> Texture2D:
	var image = Image.create(40, 40, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Draw target dummy (circle with target pattern)
	for y in range(40):
		for x in range(40):
			var dist = Vector2(x - 20, y - 20).length()
			if dist <= 18:
				if dist <= 6:
					image.set_pixel(x, y, Color.RED)  # Center
				elif dist <= 12:
					image.set_pixel(x, y, Color.WHITE)  # Middle ring
				else:
					image.set_pixel(x, y, Color.RED)  # Outer ring
	
	return ImageTexture.create_from_image(image)

func take_damage(damage_amount: int):
	current_health -= damage_amount
	current_health = max(0, current_health)
	
	print("Target Dummy took ", damage_amount, " damage, health: ", current_health, "/", max_health)
	
	if current_health <= 0:
		die()

func die():
	print("Target Dummy destroyed!")
	queue_free()
