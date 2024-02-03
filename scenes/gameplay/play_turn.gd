class_name PlayTurn
extends HBoxContainer

var dice_in_play:Array[Die] = []
var tweens_finished = 0

signal attack_finished
signal die_finished_display

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_hand_end_turn_with_selected_dice(selection:Array[Die]):
	var pos_dice := []
	tweens_finished = selection.size()
	dice_in_play = selection.duplicate()
	for die in selection:
		var pos_die:Die = die.duplicate() as Die
		pos_die.hide_children()
		pos_dice.append(pos_die)
		add_child(pos_die)
		die.selected = false
		die.rotation = 0
	
	await sort_children
	var i = 0
	for die in selection:
		var new_pos = pos_dice[i].global_position
		die.global_position = die.global_position
		var tween = create_tween()
		
		tween.tween_property(die, "global_position", new_pos, .4)
		tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tween.tween_callback(func():
			die.get_parent().remove_child(die)
			remove_child(pos_dice[i])
			add_child(die)
			tweens_finished -= 1
			if tweens_finished == 0:
				display_calcs()
		)
		tween.play()
		i += 1

func display_calcs():
	var i = 0
	# Use the control as a mask for the label
	var control_mask = Control.new()
	control_mask.clip_contents = true
	control_mask.size_flags_horizontal = Control.SIZE_SHRINK_END
	control_mask.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	control_mask.custom_minimum_size = Vector2(8, 35)
	
	for die in dice_in_play:
		#die.position.y - 10
		for c in str(die.num_dots):
			var label = Label.new()
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.text = str(die.num_dots)
			label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
			#label.size = Vector2(8, 21)
			var label_control = control_mask.duplicate()
			label_control.add_child(label)
			#label.global_position = %AddScoreMarker.global_position
			%LeftScoreAdderContainer.add_child(label_control)
			var tween = create_tween()
			tween.tween_property(label, "position:y", label.position.y + 50, .4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
			tween.tween_callback(func(): 
				die_finished_display.emit()
				label_control.queue_free()
				label.queue_free())
			tween.play()
		await die_finished_display
		i += 1
	# Display the calculation
	for die in dice_in_play:
		die.queue_free()
	attack_finished.emit()

