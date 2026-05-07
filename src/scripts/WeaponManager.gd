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
	print("Weapon Manager initialized with ", weapon_database.size(), " weapons")

func switch_to_next_weapon():
	current_weapon_index = (current_weapon_index + 1) % weapon_database.size()
	var weapon_script = weapon_database[current_weapon_index]
	print("Switched to weapon: ", weapon_script)
	return create_weapon(weapon_script)

func switch_to_previous_weapon():
	current_weapon_index = (current_weapon_index - 1 + weapon_database.size()) % weapon_database.size()
	var weapon_script = weapon_database[current_weapon_index]
	print("Switched to weapon: ", weapon_script)
	return create_weapon(weapon_script)

func create_weapon(weapon_script_path: String):
	var weapon_script = load(weapon_script_path)
	var weapon = weapon_script.new()
	return weapon

func get_random_weapon():
	var random_index = randi() % weapon_database.size()
	var weapon_script = weapon_database[random_index]
	return create_weapon(weapon_script)
