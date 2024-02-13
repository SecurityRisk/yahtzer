@icon("res://assets/sprites/dice-outline.png")
class_name Die
extends CenterContainer

# Load your dot texture
var dot_texture = preload("res://assets/sprites/dice-dot.png")
var selected := false
var selectable := true
var num_dots := 0
var is_decoy := false

var hand:Hand

var wobble_tween:Tween

signal die_selected(die:Die)
signal die_deselected(die:Die)

func _ready():
	# Ensure random numbers are different each time the game runs
	randomize()

	var number_of_dots = randi() % 6 + 1  # Generate a random number between 1 and 6
	num_dots = number_of_dots
	if (!is_decoy):
		add_dots(number_of_dots)
		start_wobble()

func start_wobble():
	wobble_tween = create_tween()  # Adjust the path to your Tween node
	var duration = 0.5  # Duration of one wobble movement
	rotation_degrees = 10
	#pivot_offset = size / 2

	# Rotate to one side
	wobble_tween.tween_property(self, "rotation_degrees", rotation_degrees, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	wobble_tween.tween_property(self, "rotation_degrees", -rotation_degrees, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	wobble_tween.set_loops() # Make the tween repeat indefinitely

	# Start the tween
	wobble_tween.play()

func hide_children():
	is_decoy = true
	for child in get_children():
		child.visible = false

func change_dots(i:int):
	num_dots = i
	
	# Remove existing dots
	for child in get_children():
		if (child.is_in_group("dots")):
			remove_child(child)
			child.queue_free()
	
	add_dots(num_dots)
	if (selected):
		selected = false
		position.y += 20

func add_dots(number_of_dots):
	var positions = get_dot_positions(number_of_dots)
	for pos in positions:
		var dot = Sprite2D.new()  # Create a new TextureRect instance
		dot.texture = dot_texture  # Assign the preloaded dot texture to it
		dot.centered = false
		dot.add_to_group("dots")
		add_child(dot)  # Add the dot to the Outline TextureRect
		#dot.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
		#dot.layout_mode = 1
		dot.position = pos

func get_dot_positions(number_of_dots):
	var positions = []
	var mid = Vector2(13, 13)
	var offset = Vector2(9, 9)  # Adjust this value based on your texture sizes and desired layout

	# Define positions for each dot based on the number
	match number_of_dots:
		1:
			positions.append(mid)
		2:
			positions.append(mid - offset)
			positions.append(mid + offset)
		3:
			positions.append(mid - offset)
			positions.append(mid)
			positions.append(mid + offset)
		4:
			positions.append(mid - offset)
			positions.append(mid + offset)
			positions.append(mid + Vector2(offset.x, -offset.y))
			positions.append(mid - Vector2(offset.x, -offset.y))
		5:
			positions.append(mid)
			positions.append(mid - offset)
			positions.append(mid + offset)
			positions.append(mid + Vector2(offset.x, -offset.y))
			positions.append(mid - Vector2(offset.x, -offset.y))
		6:
			positions.append(mid - Vector2(offset.x, 0))
			positions.append(mid + Vector2(offset.x, 0))
			positions += [mid - offset, mid + offset, mid + Vector2(offset.x, -offset.y), mid - Vector2(offset.x, -offset.y)]
	
	return positions
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and selectable:
		# Move the container 20 pixels up in the y direction
		if (selected):
			selected = !selected
			die_deselected.emit(self)
			position.y += 20
		elif (hand.number_of_selected_dice() < 5):
			selected = !selected
			die_selected.emit(self)
			position.y -= 20
