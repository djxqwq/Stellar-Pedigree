extends "res://src/scripts/player/Weapon.gd"

@export var rift_count: int = 1
@export var damage_bonus: float = 1.0

func _ready():
	weapon_name = "Void Rift"
	damage = 10
	fire_rate = 0.8
	bullet_speed = 1000.0
	rift_count = 1
	damage_bonus = 1.0
	
	bullet_scene = preload("res://src/scenes/player/Bullet.tscn")

func shoot(position: Vector2, direction: Vector2):
	if not can_shoot():
		return
	
	time_since_last_shot = 0.0
	
	match current_form:
		1:
			_create_rift_portal(position, direction)
		2:
			_create_dual_rifts(position, direction)
		3:
			_create_damage_boosted_rifts(position, direction)

func _create_rift_portal(position: Vector2, direction: Vector2):
	var rift = Node2D.new()
	rift.name = "VoidRift"
	get_tree().current_scene.add_child(rift)
	rift.global_position = position
	
	# Create portal visual
	var sprite = Sprite2D.new()
	sprite.modulate = Color(0.8, 0.2, 1.0, 0.7)
	rift.add_child(sprite)
	
	# Bullets passing through rift get damage bonus
	# Will implement when we have bullet-rift interaction

func _create_dual_rifts(position: Vector2, direction: Vector2):
	# Form 2: Can place two rifts manually
	var rift1 = _create_rift_portal(position, direction)
	
	# Create second rift at distance
	var rift2_pos = position + direction * 200
	var rift2 = _create_rift_portal(rift2_pos, direction)
	
	# Bullets entering rift1 exit from rift2
	# Will implement rift-to-rift teleportation

func _create_damage_boosted_rifts(position: Vector2, direction: Vector2):
	# Form 3: Rifts boost bullet damage by 100%
	var rift1 = _create_rift_portal(position, direction)
	var rift2_pos = position + direction * 200
	var rift2 = _create_rift_portal(rift2_pos, direction)
	
	damage_bonus = 2.0
	# Will implement damage boost effect

func _on_evolution():
	match current_form:
		2:
			rift_count = 2
		3:
			damage_bonus = 2.0
