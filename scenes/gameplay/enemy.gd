extends CenterContainer

@onready var health_label:Label = $VBoxContainer/CenterContainer/HealthLabel
@onready var progress_bar:ProgressBar = $VBoxContainer/CenterContainer/ProgressBar

var health := 300

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_end_turn_button_pressed():
	if (ScoreHandler.current_score == 0):
		return
	# Ensure there's a Tween node available
	var tween = create_tween()  # Adjust the path if your Tween node is elsewhere in the hierarchy
	if not tween:
		tween = Tween.new()
		add_child(tween)

	# Start a new tween animation
	var new_value = max(progress_bar.value - ScoreHandler.current_score, 0)  # Calculate the new progress bar value
	tween.parallel().tween_property(progress_bar, "value", new_value, .5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_method(set_health_label, health, new_value, .5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)

	# Reset the score
	ScoreHandler.current_score = 0

	# Update the health label when the tween completes
	tween.tween_callback(func(): _on_tween_completed(new_value))

	# Start the tween
	tween.play()

func set_health_label(label :int):
	health = label
	health_label.text = "%d / %d" % [label, 300]

func _on_tween_completed(new_value):
	health_label.text = "%d / %d" % [new_value, 300]
