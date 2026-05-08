extends "res://src/scripts/player/Bullet.gd"

@export var bullet_type: String = "default"
@export var custom_color: Color = Color.YELLOW
@export var custom_size: float = 1.0

func _ready():
	super._ready()
	create_custom_visual()

func create_custom_visual():
	var sprite = $Sprite2D
	sprite.texture = create_custom_texture()
	sprite.scale = Vector2(custom_size, custom_size)

func create_custom_texture() -> Texture2D:
	var image = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	match bullet_type:
		"heavy_particle":
			# Create large red bullet
			for y in range(16):
				for x in range(16):
					var dist = Vector2(x - 8, y - 8).length()
					if dist <= 7:
						image.set_pixel(x, y, Color.RED)
					if dist <= 5:
						image.set_pixel(x, y, Color.ORANGE)
		"black_hole":
			# Create purple grenade
			for y in range(16):
				for x in range(16):
					var dist = Vector2(x - 8, y - 8).length()
					if dist <= 6:
						image.set_pixel(x, y, Color.PURPLE)
					if dist <= 4:
						image.set_pixel(x, y, Color.BLACK)
		"shotgun":
			# Create small yellow pellet
			for y in range(16):
				for x in range(16):
					var dist = Vector2(x - 8, y - 8).length()
					if dist <= 3:
						image.set_pixel(x, y, Color.YELLOW)
		_:
			# Default bullet
			for y in range(16):
				for x in range(16):
					var dist = Vector2(x - 8, y - 8).length()
					if dist <= 6:
						image.set_pixel(x, y, custom_color)
					if dist <= 4:
						image.set_pixel(x, y, Color.WHITE)
	
	return ImageTexture.create_from_image(image)
