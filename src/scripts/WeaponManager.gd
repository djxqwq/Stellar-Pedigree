extends Node

# Weapon database containing all 15 weapons
var weapon_database: Array[String] = [
	"res://src/scripts/weapons/PulseRifle.gd",
	"res://src/scripts/weapons/HeavyParticleCannon.gd",
	"res://src/scripts/weapons/StardustShotgun.gd",
	"res://src/scripts/weapons/ArcGun.gd",
	"res://src/scripts/weapons/Boomerang.gd",
	"res://src/scripts/weapons/GuardianDrone.gd",
	"res://src/scripts/weapons/GravitySatellite.gd",
	"res://src/scripts/weapons/NanoSwarm.gd",
	"res://src/scripts/weapons/MeteorSummon.gd",
	"res://src/scripts/weapons/GravityAnchor.gd",
	"res://src/scripts/weapons/TimeSlowField.gd",
	"res://src/scripts/weapons/VoidRift.gd",
	"res://src/scripts/weapons/MindControl.gd",
	"res://src/scripts/weapons/BlackHoleGrenade.gd"
]

var current_weapon_index: int = 0

func _ready():
	pass

func switch_to_next_weapon():
	current_weapon_index = (current_weapon_index + 1) % weapon_database.size()
	var weapon_script = weapon_database[current_weapon_index]
	print("Switching to index: ", current_weapon_index, " script: ", weapon_script)
	return create_weapon(weapon_script)

func switch_to_previous_weapon():
	current_weapon_index = (current_weapon_index - 1 + weapon_database.size()) % weapon_database.size()
	var weapon_script = weapon_database[current_weapon_index]
	return create_weapon(weapon_script)

func create_weapon(weapon_script_path: String):
	var weapon_script = load(weapon_script_path)
	var weapon = weapon_script.new()
	
	# Manually initialize weapon based on its type
	_initialize_weapon(weapon, weapon_script_path)
	
	return weapon

func _initialize_weapon(weapon: Node, script_path: String):
	print("Initializing weapon from: ", script_path)
	
	# Initialize weapon properties based on script path
	if script_path.contains("PulseRifle"):
		print("Setting up Pulse Rifle")
		weapon.weapon_name = "Pulse Rifle"
		weapon.damage = 12
		weapon.fire_rate = 3.0
		weapon.bullet_speed = 800.0
	elif script_path.contains("HeavyParticleCannon"):
		print("Setting up Heavy Particle Cannon")
		weapon.weapon_name = "Heavy Particle Cannon"
		weapon.damage = 40
		weapon.fire_rate = 1.0
		weapon.bullet_speed = 400.0
	elif script_path.contains("StardustShotgun"):
		print("Setting up Stardust Shotgun")
		weapon.weapon_name = "Stardust Shotgun"
		weapon.damage = 8
		weapon.fire_rate = 1.5
		weapon.bullet_speed = 600.0
	elif script_path.contains("BlackHoleGrenade"):
		print("Setting up Black Hole Grenade")
		weapon.weapon_name = "Black Hole Grenade"
		weapon.damage = 0
		weapon.fire_rate = 0.8
		weapon.bullet_speed = 400.0
	# Add more weapon types as needed
	
	# Load bullet scene
	weapon.bullet_scene = preload("res://src/scenes/player/Bullet.tscn")
	
	print("Weapon initialized. Name: ", weapon.weapon_name)

func get_random_weapon():
	var random_index = randi() % weapon_database.size()
	var weapon_script = weapon_database[random_index]
	return create_weapon(weapon_script)
