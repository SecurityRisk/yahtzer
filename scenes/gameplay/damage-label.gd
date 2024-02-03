extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	ScoreHandler.current_combo_changed.connect(_update_score)
	labelify_into_left_and_right_score("0","0")


func _update_score(combo:ScoreHandler.YahtzeeCombo):
	ScoreHandler.current_score = combo.base_score * combo.multiplier
	labelify_into_left_and_right_score(str(combo.base_score), str(combo.multiplier))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func labelify_into_left_and_right_score(base_score:String, multiplier:String):
	for child in %LeftScoreContainer.get_children():
		%LeftScoreContainer.remove_child(child)
		child.queue_free()
	
	for child in %RightMultiplierContainer.get_children():
		%RightMultiplierContainer.remove_child(child)
		child.queue_free()
	
	var color_base = Color(randf(), randf(), randf())
	var i = 0
	for c in base_score:
		var label = Label.new()
		#label.label_settings.font_color = Color(randf(), randf(), randf())
		label.text = c
		%LeftScoreContainer.add_child(label)
		i += 1
	for c in multiplier:
		var label = Label.new()
		#label.label_settings.font_color = Color(randf(), randf(), randf())
		label.text = c
		%RightMultiplierContainer.add_child(label)
		i += 1
