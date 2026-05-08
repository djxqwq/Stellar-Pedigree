extends Node2D

var direction: Vector2
var speed: float
var lifetime: float = 1.0

func _ready():
	set_process(true)

func _process(delta):
	# Simple movement
	global_position += direction * speed * delta
	
	# Decrease lifetime
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
