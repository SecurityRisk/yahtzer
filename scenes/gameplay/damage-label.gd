class_name DamageLabel
extends Label

var current_base_string:String = ""
var current_mult_string:String = ""

#var wobble_tween:Tween
# Called when the node enters the scene tree for the first time.
func _ready():
	ScoreHandler.current_combo_changed.connect(_update_score)
	labelify_into_left_and_right_score("0","0")


func _update_score(combo:ScoreHandler.YahtzeeCombo):
	ScoreHandler.current_score = combo.base_score * combo.multiplier
	labelify_into_left_and_right_score(str(combo.base_score), str(combo.multiplier))

func _add_die_to_score(die:Die):
	var combo := ScoreHandler.current_combo as ScoreHandler.YahtzeeCombo
	combo.base_adder += die.num_dots
	ScoreHandler.current_score = (combo.base_score + combo.base_adder) * (combo.multiplier)
	labelify_into_left_and_right_score(str(combo.base_score + combo.base_adder), str(combo.multiplier))
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func labelify_into_left_and_right_score(base_score:String, multiplier:String):
	if (base_score != current_base_string):
		current_base_string = base_score
		for child in %LeftScoreContainer.get_children():
			%LeftScoreContainer.remove_child(child)
			child.queue_free()
		
		for c in base_score:
			var label = Label.new()
			label.add_theme_color_override("font_outline_color", Color.DARK_GREEN)
			label.text = c
			%LeftScoreContainer.add_child(label)
			label.pivot_offset = Vector2(label.size.x / 2, label.size.y / 2 + 1)
			
			var duration = 0.05  # Duration of one wobble movement
			var rot_degrees = 20
			label.rotation_degrees = 0
			#pivot_offset = size / 2

			# Rotate to one side
			var wobble_tween = create_tween()
			wobble_tween.tween_property(label, "rotation_degrees", rot_degrees, duration/2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
			wobble_tween.tween_property(label, "rotation_degrees", -rot_degrees, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
			wobble_tween.tween_property(label, "rotation_degrees", 0, duration/2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
			wobble_tween.set_loops(3)
			# Start the tween
			wobble_tween.play()
		
	if (current_mult_string != multiplier):
		current_mult_string = multiplier
		for child in %RightMultiplierContainer.get_children():
			%RightMultiplierContainer.remove_child(child)
			child.queue_free()
			
		for c in multiplier:
			var label = Label.new()
			label.add_theme_color_override("font_outline_color", Color.CORAL)
			label.text = c
			%RightMultiplierContainer.add_child(label)
			label.pivot_offset = Vector2(label.size.x / 2, label.size.y / 2 + 1)
			
			var duration = 0.05  # Duration of one wobble movement
			var rot_degrees = 20
			label.rotation_degrees = 0
			#pivot_offset = size / 2

			# Rotate to one side
			var wobble_tween = create_tween()
			wobble_tween.tween_property(label, "rotation_degrees", rot_degrees, duration/2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
			wobble_tween.tween_property(label, "rotation_degrees", -rot_degrees, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
			wobble_tween.tween_property(label, "rotation_degrees", 0, duration/2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
			wobble_tween.set_loops(3)
			# Start the tween
			wobble_tween.play()
