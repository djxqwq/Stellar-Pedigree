extends Node2D

signal weapon_evolved(new_form: int)

@export var weapon_name: String
@export var damage: int
@export var fire_rate: float
@export var bullet_speed: float
@export var bullet_scene: PackedScene

var current_form: int = 1  # 1, 2, or 3
var evolution_levels: Array[int] = [3, 6]  # Evolve at level 3 and 6
var time_since_last_shot: float = 999.0  # Start ready to shoot

func _ready():
	pass

func _process(delta):
	time_since_last_shot += delta

func can_shoot() -> bool:
	var cooldown_time = 1.0 / fire_rate
	return time_since_last_shot >= cooldown_time

func shoot(position: Vector2, direction: Vector2):
	if not can_shoot():
		return
	
	time_since_last_shot = 0.0
	_create_bullet(position, direction)

func _create_bullet(position: Vector2, direction: Vector2):
	# Override in specific weapon classes for custom effects
	print("Creating bullet for weapon: ", weapon_name)
	_create_custom_bullet(position, direction)

func _create_custom_bullet(position: Vector2, direction: Vector2):
	# Default bullet creation
	print("Using DEFAULT bullet creation for: ", weapon_name)
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = position
	bullet.setup(direction, damage, bullet_speed)

func evolve():
	if current_form < 3:
		current_form += 1
		_on_evolution()
		weapon_evolved.emit(current_form)

func _on_evolution():
	# Override in specific weapon classes
	pass

func add_upgrade(upgrade_data: Dictionary):
	# Override in specific weapon classes
	pass
