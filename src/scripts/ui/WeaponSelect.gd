extends Control

# Signal for weapon selection
signal weapon_selected(weapon_script_path: String)
signal back_to_menu()

# Weapon data
var weapon_data: Array[Dictionary] = [
	{
		"name": "脉冲步枪",
		"description": "平衡的基础武器，适合新手",
		"damage": 12,
		"fire_rate": 3.0,
		"script_path": "res://src/scripts/weapons/PulseRifle.gd",
		"icon": "🔫",
		"color": Color.CYAN
	},
	{
		"name": "重粒子炮",
		"description": "高伤害慢射速，对付坦克敌人",
		"damage": 40,
		"fire_rate": 1.0,
		"script_path": "res://src/scripts/weapons/HeavyParticleCannon.gd",
		"icon": "💥",
		"color": Color.ORANGE
	},
	{
		"name": "星尘霰弹枪",
		"description": "近距离高伤害，散射攻击",
		"damage": 40,
		"fire_rate": 1.5,
		"script_path": "res://src/scripts/weapons/StardustShotgun.gd",
		"icon": "🔥",
		"color": Color.RED
	},
	{
		"name": "弧光枪",
		"description": "闪电可在敌人间传导",
		"damage": 15,
		"fire_rate": 2.5,
		"script_path": "res://src/scripts/weapons/ArcGun.gd",
		"icon": "⚡",
		"color": Color.YELLOW
	},
	{
		"name": "回旋镖",
		"description": "抛射出去后飞回，可击中两次",
		"damage": 50,
		"fire_rate": 1.8,
		"script_path": "res://src/scripts/weapons/Boomerang.gd",
		"icon": "🌀",
		"color": Color.GREEN
	},
	{
		"name": "守护者无人机",
		"description": "自动攻击附近敌人",
		"damage": 10,
		"fire_rate": 2.0,
		"script_path": "res://src/scripts/weapons/GuardianDrone.gd",
		"icon": "🛡️",
		"color": Color.BLUE
	},
	{
		"name": "重力卫星",
		"description": "围绕玩家轨道攻击",
		"damage": 20,
		"fire_rate": 2.0,
		"script_path": "res://src/scripts/weapons/GravitySatellite.gd",
		"icon": "🪐",
		"color": Color.PURPLE
	},
	{
		"name": "纳米集群",
		"description": "发射追踪纳米机器人",
		"damage": 50,
		"fire_rate": 3.0,
		"script_path": "res://src/scripts/weapons/NanoSwarm.gd",
		"icon": "🦠",
		"color": Color.LIME
	},
	{
		"name": "流星召唤",
		"description": "从天而降的流星攻击",
		"damage": 50,
		"fire_rate": 0.8,
		"script_path": "res://src/scripts/weapons/MeteorSummon.gd",
		"icon": "☄️",
		"color": Color.FIREBRICK
	},
	{
		"name": "重力锚",
		"description": "在指定位置产生重力场",
		"damage": 0,
		"fire_rate": 1.5,
		"script_path": "res://src/scripts/weapons/GravityAnchor.gd",
		"icon": "⚓",
		"color": Color.DARK_BLUE
	},
	{
		"name": "时间减缓场",
		"description": "减缓区域内时间流速",
		"damage": 0,
		"fire_rate": 1.2,
		"script_path": "res://src/scripts/weapons/TimeSlowField.gd",
		"icon": "⏰",
		"color": Color.TEAL
	},
	{
		"name": "虚空裂隙",
		"description": "撕裂空间造成伤害",
		"damage": 35,
		"fire_rate": 1.0,
		"script_path": "res://src/scripts/weapons/VoidRift.gd",
		"icon": "🌀",
		"color": Color.MAGENTA
	},
	{
		"name": "精神控制",
		"description": "控制敌人攻击其他敌人",
		"damage": 0,
		"fire_rate": 2.0,
		"script_path": "res://src/scripts/weapons/MindControl.gd",
		"icon": "🧠",
		"color": Color.PINK
	},
	{
		"name": "黑洞手雷",
		"description": "产生黑洞吸引并伤害敌人",
		"damage": 0,
		"fire_rate": 0.8,
		"script_path": "res://src/scripts/weapons/BlackHoleGrenade.gd",
		"icon": "⚫",
		"color": Color.BLACK
	},
	{
		"name": "待定武器",
		"description": "特殊机制武器",
		"damage": 25,
		"fire_rate": 2.0,
		"script_path": "res://src/scripts/weapons/SpecialWeapon.gd",
		"icon": "❓",
		"color": Color.GRAY
	}
]

var selected_weapon_index: int = -1

func _ready():
	# Create weapon cards
	create_weapon_cards()
	
	# Setup animations
	setup_title_animation()

func create_weapon_cards():
	var grid = get_node("WeaponGrid")
	
	for i in range(weapon_data.size()):
		var weapon_info = weapon_data[i]
		var card = create_weapon_card(weapon_info, i)
		grid.add_child(card)

func create_weapon_card(weapon_info: Dictionary, index: int) -> Control:
	var card = Control.new()
	card.custom_minimum_size = Vector2(150, 180)
	
	# Background panel
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(150, 180)
	card.add_child(panel)
	
	# Weapon icon (using colored rectangle as placeholder)
	var icon = ColorRect.new()
	icon.custom_minimum_size = Vector2(60, 60)
	icon.position = Vector2(45, 10)
	icon.color = weapon_info.color
	card.add_child(icon)
	
	# Weapon name
	var name_label = Label.new()
	name_label.text = weapon_info.name
	name_label.position = Vector2(10, 80)
	name_label.size = Vector2(130, 20)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card.add_child(name_label)
	
	# Weapon description
	var desc_label = Label.new()
	desc_label.text = weapon_info.description
	desc_label.position = Vector2(10, 105)
	desc_label.size = Vector2(130, 40)
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card.add_child(desc_label)
	
	# Stats
	var stats_label = Label.new()
	stats_label.text = "伤害: %d\n射速: %.1f" % [weapon_info.damage, weapon_info.fire_rate]
	stats_label.position = Vector2(10, 150)
	stats_label.size = Vector2(130, 30)
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stats_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card.add_child(stats_label)
	
	# Button for selection
	var button = Button.new()
	button.custom_minimum_size = Vector2(150, 180)
	button.position = Vector2(0, 0)
	button.flat = true
	button.pressed.connect(_on_weapon_card_pressed.bind(index))
	card.add_child(button)
	
	# Store index
	card.set_meta("weapon_index", index)
	
	return card

func setup_title_animation():
	# Animate title appearance
	var title = get_node("Title")
	var subtitle = get_node("Subtitle")
	
	# Start with invisible
	title.modulate = Color.TRANSPARENT
	subtitle.modulate = Color.TRANSPARENT
	
	# Fade in animation
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(title, "modulate", Color.WHITE, 1.0)
	tween.tween_property(subtitle, "modulate", Color.WHITE, 1.0).set_delay(0.3)

func _on_weapon_card_pressed(index: int):
	selected_weapon_index = index
	
	# Play selection effect
	play_selection_sound()
	
	# Highlight selected card
	highlight_selected_card(index)
	
	# Start game with selected weapon
	var weapon_info = weapon_data[index]
	weapon_selected.emit(weapon_info.script_path)

func highlight_selected_card(index: int):
	var grid = get_node("WeaponGrid")
	var cards = grid.get_children()
	
	# Reset all cards
	for i in range(cards.size()):
		var card = cards[i]
		var panel = card.get_child(0)
		if i == index:
			panel.modulate = Color.YELLOW
		else:
			panel.modulate = Color.WHITE

func _on_back_button_pressed():
	# Play button sound
	play_selection_sound()
	
	# Return to main menu
	back_to_menu.emit()

func play_selection_sound():
	# Simple sound effect
	var audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	var sound = AudioStreamGenerator.new()
	sound.sample_rate = 44100
	sound.buffer_length = 0.2
	audio_player.stream = sound
	audio_player.play()
	
	audio_player.finished.connect(audio_player.queue_free)

func show_weapon_select():
	visible = true
	
	# Animate appearance
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color.WHITE, 0.5)
	tween.tween_property($WeaponGrid, "position:y", 0, 0.5).from(50)

func hide_weapon_select():
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
	tween.tween_property($WeaponGrid, "position:y", -50, 0.5)
	
	tween.finished.connect(func(): visible = false)
