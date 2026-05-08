extends Control

@onready var weapon_name_label: Label = $WeaponName
@onready var weapon_form_label: Label = $WeaponForm
@onready var weapon_icon: Sprite2D = $WeaponIcon
@onready var ammo_bar: ProgressBar = $AmmoBar

var current_weapon: Node

func _ready():
	# Simple positioning
	position = Vector2(20, get_viewport().get_visible_rect().size.y - 100)
	size = Vector2(300, 80)
	
	# Style the display
	setup_style()

func setup_style():
	# Create background panel
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.1, 0.1, 0.2, 0.8)
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.3, 0.6, 1.0, 0.9)
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	
	add_theme_stylebox_override("panel", style_box)
	
	# Setup labels
	if weapon_name_label:
		weapon_name_label.add_theme_font_size_override("font_size", 18)
		weapon_name_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
		weapon_name_label.position = Vector2(10, 10)
		
	if weapon_form_label:
		weapon_form_label.add_theme_font_size_override("font_size", 14)
		weapon_form_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		weapon_form_label.position = Vector2(10, 35)
		
	if ammo_bar:
		ammo_bar.position = Vector2(10, 55)
		ammo_bar.size = Vector2(280, 10)
		ammo_bar.value = 100
		ammo_bar.modulate = Color(0.2, 0.8, 1.0)

func update_weapon_display(weapon: Node):
	current_weapon = weapon
	
	if not weapon:
		weapon_name_label.text = "无武器"
		weapon_form_label.text = ""
		return
	
	# Update weapon name
	if weapon.get("weapon_name") != null:
		weapon_name_label.text = weapon.weapon_name
	else:
		weapon_name_label.text = "未知武器"
	
	# Update weapon form
	if weapon.get("current_form") != null:
		var form_text = ""
		match weapon.current_form:
			1:
				form_text = "形态 I"
			2:
				form_text = "形态 II"
			3:
				form_text = "形态 III"
			_:
				form_text = "形态 " + str(weapon.current_form)
		weapon_form_label.text = form_text
	else:
		weapon_form_label.text = ""
	
	# Update ammo bar based on fire rate
	if weapon.get("fire_rate") != null and weapon.get("time_since_last_shot") != null:
		var cooldown_progress = 1.0 - (weapon.time_since_last_shot * weapon.fire_rate)
		ammo_bar.value = cooldown_progress * 100
	else:
		ammo_bar.value = 100

func _process(delta):
	if current_weapon and current_weapon.get("time_since_last_shot") != null and current_weapon.get("fire_rate") != null:
		# Update ammo bar animation
		var cooldown_progress = 1.0 - (current_weapon.time_since_last_shot * current_weapon.fire_rate)
		ammo_bar.value = cooldown_progress * 100
