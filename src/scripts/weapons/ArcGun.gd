extends "res://src/scripts/player/Weapon.gd"

@export var chain_count: int = 3
@export var damage_reduction: float = 0.8

func _ready():
	weapon_name = "Arc Gun"
	damage = 15
	fire_rate = 2.0
	bullet_speed = 1000.0
	chain_count = 3
	damage_reduction = 0.8
	
	bullet_scene = preload("res://src/scenes/player/Bullet.tscn")

func shoot(position: Vector2, direction: Vector2):
	if not can_shoot():
		return
	
	time_since_last_shot = 0.0
	
	match current_form:
		1:
			_shoot_chain(position, direction)
		2:
			_shoot_extended_chain(position, direction)
		3:
			_shoot_infinite_chain(position, direction)

func _shoot_chain(position: Vector2, direction: Vector2):
	var bullet = _create_chain_bullet(position, direction, chain_count)

func _shoot_extended_chain(position: Vector2, direction: Vector2):
	# Form 2: More chains, less damage reduction
	chain_count = 5
	damage_reduction = 0.7
	var bullet = _create_chain_bullet(position, direction, chain_count)

func _shoot_infinite_chain(position: Vector2, direction: Vector2):
	# Form 3: Infinite chains + stun
	chain_count = 999
	damage_reduction = 0.5
	var bullet = _create_chain_bullet(position, direction, chain_count)
	# Will add stun effect later

func _create_chain_bullet(position: Vector2, direction: Vector2, chains: int):
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = position
	bullet.setup(direction, damage, bullet_speed)
	# Will add chain properties later
	return bullet

func _on_evolution():
	match current_form:
		2:
			chain_count = 5
			damage_reduction = 0.7
		3:
			chain_count = 999
			damage_reduction = 0.5
