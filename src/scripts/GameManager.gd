extends Node

# Game states
enum GameState {
	MAIN_MENU,
	WEAPON_SELECT,
	PLAYING,
	PAUSED,
	GAME_OVER
}

var current_state: GameState = GameState.MAIN_MENU

# Scene references
var main_menu: Control
var weapon_select: Control
var game_scene: Node

# Selected weapon
var selected_weapon_script: String = ""

func _ready():
	# Load UI scenes
	load_ui_scenes()
	
	# Show main menu first
	show_main_menu()
	
	print("GameManager ready, main_menu loaded: ", main_menu != null)

func load_ui_scenes():
	# Load main menu (simple version)
	var main_menu_scene = preload("res://src/scenes/ui/MainMenu_simple.tscn")
	main_menu = main_menu_scene.instantiate()
	add_child(main_menu)
	main_menu.visible = false
	
	# Connect main menu signals
	main_menu.start_game.connect(_on_start_game)
	main_menu.open_options.connect(_on_open_options)
	main_menu.quit_game.connect(_on_quit_game)
	
	# Load weapon select
	var weapon_select_scene = preload("res://src/scenes/ui/WeaponSelect_fixed.tscn")
	weapon_select = weapon_select_scene.instantiate()
	add_child(weapon_select)
	weapon_select.visible = false
	
	# Connect weapon select signals
	weapon_select.weapon_selected.connect(_on_weapon_selected)
	weapon_select.back_to_menu.connect(_on_back_to_menu)

func show_main_menu():
	current_state = GameState.MAIN_MENU
	
	# Hide all other UI
	if weapon_select:
		weapon_select.visible = false
	if game_scene:
		game_scene.visible = false
	
	# Show main menu
	if main_menu:
		main_menu.visible = true
		main_menu.show_menu()
		print("Main menu shown")
	else:
		print("Error: main_menu is null")

func show_weapon_select():
	current_state = GameState.WEAPON_SELECT
	
	# Hide main menu
	main_menu.hide_menu()
	
	# Show weapon select
	weapon_select.visible = true
	weapon_select.show_weapon_select()

func start_game_with_weapon(weapon_script_path: String):
	selected_weapon_script = weapon_script_path
	current_state = GameState.PLAYING
	
	# Hide UI
	weapon_select.visible = false
	main_menu.visible = false
	
	# Load or create game scene
	if not game_scene:
		load_game_scene()
	
	# Setup game with selected weapon
	setup_game_with_weapon()
	
	# Show game
	game_scene.visible = true

func load_game_scene():
	# Load the main game scene
	var game_scene_resource = preload("res://src/scenes/Main.tscn")
	game_scene = game_scene_resource.instantiate()
	add_child(game_scene)
	game_scene.visible = false

func setup_game_with_weapon():
	if not game_scene or selected_weapon_script.is_empty():
		return
	
	# Get player reference
	var player = game_scene.get_node_or_null("Player")
	if not player:
		return
	
	# Clear existing weapons
	player.weapons.clear()
	
	# Create and add selected weapon
	var weapon_script = load(selected_weapon_script)
	var weapon = weapon_script.new()
	
	# Initialize weapon properties
	initialize_weapon(weapon, selected_weapon_script)
	
	# Add weapon to player
	player.add_weapon(weapon)
	
	# Update weapon display
	if game_scene.has_method("update_weapon_display"):
		game_scene.update_weapon_display(weapon)

func initialize_weapon(weapon: Node, script_path: String):
	# Initialize weapon based on script path
	if script_path.contains("PulseRifle"):
		weapon.weapon_name = "脉冲步枪"
		weapon.damage = 12
		weapon.fire_rate = 3.0
		weapon.bullet_speed = 800.0
	elif script_path.contains("HeavyParticleCannon"):
		weapon.weapon_name = "重粒子炮"
		weapon.damage = 40
		weapon.fire_rate = 1.0
		weapon.bullet_speed = 400.0
	elif script_path.contains("StardustShotgun"):
		weapon.weapon_name = "星尘霰弹枪"
		weapon.damage = 8
		weapon.fire_rate = 1.5
		weapon.bullet_speed = 600.0
	elif script_path.contains("ArcGun"):
		weapon.weapon_name = "弧光枪"
		weapon.damage = 15
		weapon.fire_rate = 2.5
		weapon.bullet_speed = 700.0
	elif script_path.contains("Boomerang"):
		weapon.weapon_name = "回旋镖"
		weapon.damage = 25
		weapon.fire_rate = 1.8
		weapon.bullet_speed = 500.0
	elif script_path.contains("GuardianDrone"):
		weapon.weapon_name = "守护者无人机"
		weapon.damage = 10
		weapon.fire_rate = 2.0
		weapon.bullet_speed = 600.0
	elif script_path.contains("GravitySatellite"):
		weapon.weapon_name = "重力卫星"
		weapon.damage = 20
		weapon.fire_rate = 2.0
		weapon.bullet_speed = 600.0
	elif script_path.contains("NanoSwarm"):
		weapon.weapon_name = "纳米集群"
		weapon.damage = 5
		weapon.fire_rate = 3.0
		weapon.bullet_speed = 600.0
	elif script_path.contains("MeteorSummon"):
		weapon.weapon_name = "流星召唤"
		weapon.damage = 50
		weapon.fire_rate = 0.8
		weapon.bullet_speed = 600.0
	elif script_path.contains("GravityAnchor"):
		weapon.weapon_name = "重力锚"
		weapon.damage = 0
		weapon.fire_rate = 1.5
		weapon.bullet_speed = 600.0
	elif script_path.contains("TimeSlowField"):
		weapon.weapon_name = "时间减缓场"
		weapon.damage = 0
		weapon.fire_rate = 1.2
		weapon.bullet_speed = 600.0
	elif script_path.contains("VoidRift"):
		weapon.weapon_name = "虚空裂隙"
		weapon.damage = 35
		weapon.fire_rate = 1.0
		weapon.bullet_speed = 600.0
	elif script_path.contains("MindControl"):
		weapon.weapon_name = "精神控制"
		weapon.damage = 0
		weapon.fire_rate = 2.0
		weapon.bullet_speed = 600.0
	elif script_path.contains("BlackHoleGrenade"):
		weapon.weapon_name = "黑洞手雷"
		weapon.damage = 0
		weapon.fire_rate = 0.8
		weapon.bullet_speed = 400.0
	else:
		# Default values for unknown weapons
		weapon.weapon_name = "未知武器"
		weapon.damage = 25
		weapon.fire_rate = 2.0
		weapon.bullet_speed = 600.0
	
	# Load bullet scene
	weapon.bullet_scene = preload("res://src/scenes/player/Bullet.tscn")

func _on_start_game():
	show_weapon_select()

func _on_open_options():
	print("Options menu not implemented yet")

func _on_quit_game():
	get_tree().quit()

func _on_weapon_selected(weapon_script_path: String):
	start_game_with_weapon(weapon_script_path)

func _on_back_to_menu():
	show_main_menu()

func _input(event):
	if event is InputEventKey and event.pressed:
		match current_state:
			GameState.PLAYING:
				if event.keycode == KEY_ESCAPE:
					pause_game()
			GameState.PAUSED:
				if event.keycode == KEY_ESCAPE:
					resume_game()

func pause_game():
	current_state = GameState.PAUSED
	get_tree().paused = true
	# TODO: Show pause menu

func resume_game():
	current_state = GameState.PLAYING
	get_tree().paused = false
	# TODO: Hide pause menu

func game_over():
	current_state = GameState.GAME_OVER
	print("Game Over!")
	# TODO: Show game over screen

func restart_game():
	# Reset game state
	current_state = GameState.MAIN_MENU
	
	# Reset game scene
	if game_scene:
		game_scene.queue_free()
		game_scene = null
	
	# Return to main menu
	show_main_menu()
