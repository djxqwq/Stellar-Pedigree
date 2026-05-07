extends Node2D

@onready var player = $Player

func _ready():
	print("Stellar Pedigree - Game Started!")
	print("Use WASD to move, ESC to quit")

func _process(delta):
	# Movement
	if Input.is_key_pressed(KEY_W):
		player.position.y -= 5
	if Input.is_key_pressed(KEY_S):
		player.position.y += 5
	if Input.is_key_pressed(KEY_A):
		player.position.x -= 5
	if Input.is_key_pressed(KEY_D):
		player.position.x += 5
	
	# Quit
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
