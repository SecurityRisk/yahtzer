class_name PlayTurn
extends HBoxContainer

var dice_in_play:Array[Die] = []
var tweens_finished = 0

signal attack_finished
signal die_finished_display
signal damage_time

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
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
	# Use the control as a mask for the label
	var control_mask = Control.new()
	#control_mask.clip_contents = true
	control_mask.size_flags_horizontal = Control.SIZE_SHRINK_END
	control_mask.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	control_mask.custom_minimum_size = Vector2(8, 35)
	
	await sort_children
	
	for die in dice_in_play:
		#die.position.y -= 20
		
		# Display the addition on each dice
		var addition_display = str(die.num_dots)
		var on_dice_label_control = Control.new()
		var on_dice_label = Label.new()
		on_dice_label.label_settings = LabelSettings.new()
		on_dice_label.label_settings.font_size = 18
		on_dice_label.label_settings.outline_color = Color.DARK_GREEN
		on_dice_label.label_settings.outline_size = 4
		on_dice_label.label_settings.shadow_color = "#000"
		on_dice_label.label_settings.shadow_size = 3
		on_dice_label.label_settings.shadow_color = "#000"
		on_dice_label.text = addition_display
		on_dice_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		on_dice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		on_dice_label_control.add_child(on_dice_label)
		die.add_child(on_dice_label_control)
		on_dice_label.pivot_offset = on_dice_label.size / 2
		on_dice_label.position = -on_dice_label.size / 2
		on_dice_label.position.y -= 30
		on_dice_label.scale = Vector2(.1, .1)
		var label_tween = create_tween()
		label_tween.parallel().tween_property(on_dice_label, "scale", Vector2(2.5, 2.5), .7).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		label_tween.play()
		label_tween.tween_callback(on_dice_label.queue_free)
		
		# Display the addition to the damage
		#var tween = create_tween()
		#for c in addition_display:
			#var label = Label.new()
			#label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			#label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			#label.text = str(c)
			#label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
			##label.size = Vector2(8, 21)
			#var label_control = control_mask.duplicate()
			#label_control.add_child(label)
			##label.global_position = %AddScoreMarker.global_position
			#%LeftScoreAdderContainer.add_child(label_control)
			#tween.parallel().tween_property(label, "position:y", label.position.y + 50, .4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN).set_delay(.5)
		#tween.tween_callback(func(): 
			#for ch in %LeftScoreAdderContainer.get_children():
				#ch.free()
			#die_finished_display.emit())
		#tween.play()
		#await die_finished_display
		#die.position.y += 20
		(%DamageLabel as DamageLabel)._add_die_to_score(die)
		await label_tween.finished
	
	# Display the damage on enemy
	var damage_label = %DamageToEnemyLabel
	damage_label.visible = true
	damage_label.text = str(ScoreHandler.current_score)
	var animation = damage_label.get_child(0) as AnimationPlayer
	animation.play("damaged")
	damage_time.emit()
	await animation.animation_finished
	damage_label.visible = false
	
	# Remove the dice
	var t = create_tween()
	for die in dice_in_play:
		var end_pos = Vector2(Game.size.x + 40, die.position.y + randi_range(-20, 20))
		t.parallel().tween_property(die, "position", end_pos, .7).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN).set_delay(randf_range(0, .3))
	t.tween_callback(func():
		for die in dice_in_play:
			die.visible = false
			die.get_parent().remove_child(die)
			die.queue_free())
	t.play()
	ScoreHandler.reset_score()
	await t.finished
	attack_finished.emit()

