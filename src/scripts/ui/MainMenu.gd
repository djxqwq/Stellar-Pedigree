extends Control

# Signal for menu actions
signal start_game()
signal open_options()
signal quit_game()

# Animation variables
var title_animation_time: float = 0.0
var star_positions: Array[Vector2] = []
var star_speeds: Array[float] = []

func _ready():
	# Initialize starfield
	create_starfield()
	
	# Setup animations
	setup_title_animation()
	
	# Connect input for ESC key
	set_process_input(true)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			_on_quit_button_pressed()

func create_starfield():
	# Create background stars
	var starfield = get_node("Background/Starfield")
	
	# Generate random stars
	for i in range(100):
		var star = create_star()
		var pos = Vector2(
			randf() * get_viewport().get_visible_rect().size.x,
			randf() * get_viewport().get_visible_rect().size.y
		)
		star.position = pos
		starfield.add_child(star)
		star_positions.append(pos)
		star_speeds.append(randf() * 0.5 + 0.1)

func create_star() -> Node2D:
	var star = Node2D.new()
	var sprite = Sprite2D.new()
	sprite.texture = create_star_texture()
	sprite.modulate = Color.WHITE
	sprite.scale = Vector2(randf() * 0.5 + 0.5, randf() * 0.5 + 0.5)
	star.add_child(sprite)
	
	# Add twinkling effect
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(sprite, "modulate", Color(0.5, 0.5, 0.5, 1.0), randf() * 2 + 1)
	tween.tween_property(sprite, "modulate", Color.WHITE, randf() * 2 + 1)
	
	return star

func create_star_texture() -> Texture2D:
	var image = Image.create(4, 4, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	# Draw small star
	image.set_pixel(1, 1, Color.WHITE)
	image.set_pixel(2, 1, Color.WHITE)
	image.set_pixel(1, 2, Color.WHITE)
	image.set_pixel(2, 2, Color.WHITE)
	
	return ImageTexture.create_from_image(image)

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
	tween.tween_property(title, "modulate", Color.WHITE, 1.5)
	tween.tween_property(subtitle, "modulate", Color.WHITE, 1.5).set_delay(0.5)
	
	# Scale animation
	tween.tween_property(title, "scale", Vector2.ONE * 1.1, 2.0).set_delay(1.5)
	tween.tween_property(title, "scale", Vector2.ONE, 2.0).set_delay(3.5)

func _process(delta):
	# Animate starfield
	animate_starfield(delta)
	
	# Animate title
	animate_title(delta)

func animate_starfield(delta):
	var starfield = get_node("Background/Starfield")
	var children = starfield.get_children()
	
	for i in range(min(children.size(), star_positions.size())):
		var star = children[i]
		var original_pos = star_positions[i]
		var speed = star_speeds[i]
		
		# Gentle floating animation
		var offset = Vector2(
			sin(title_animation_time * speed + i) * 2,
			cos(title_animation_time * speed + i) * 1
		)
		star.position = original_pos + offset

func animate_title(delta):
	title_animation_time += delta
	
	var title = get_node("Title")
	var subtitle = get_node("Subtitle")
	
	# Gentle floating animation
	var title_offset = sin(title_animation_time * 0.5) * 5
	var subtitle_offset = sin(title_animation_time * 0.5 + 1) * 3
	
	title.position.y = -300 + title_offset
	subtitle.position.y = -180 + subtitle_offset

func _on_start_button_pressed():
	# Play button press effect
	play_button_sound()
	
	# Transition to weapon selection
	start_game.emit()

func _on_options_button_pressed():
	# Play button press effect
	play_button_sound()
	
	# Open options menu
	open_options.emit()

func _on_quit_button_pressed():
	# Play button press effect
	play_button_sound()
	
	# Quit game
	quit_game.emit()

func play_button_sound():
	# Simple sound effect using Godot's audio system
	var audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	# Create a simple beep sound
	var sound = AudioStreamGenerator.new()
	sound.sample_rate = 44100
	sound.buffer_length = 0.1
	audio_player.stream = sound
	audio_player.play()
	
	# Remove audio player after playing
	audio_player.finished.connect(audio_player.queue_free)

func show_menu():
	# Show the menu immediately without animation
	visible = true
	modulate = Color.WHITE  # Ensure visible immediately
	$MenuContainer.position.y = 0  # Reset position
	print("MainMenu.show_menu() called, visible: ", visible)

func hide_menu():
	# Hide the menu with animation
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
	tween.tween_property($MenuContainer, "position:y", -50, 0.5)
	
	tween.finished.connect(func(): visible = false)
